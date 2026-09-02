import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass/deen_glass_app_bar.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../settings/providers/settings_providers.dart';

final tasbihCountProvider = StateProvider<int>((ref) => 0);
final tasbihTargetProvider = StateProvider<int>((ref) => 33);
final tasbihRoundsProvider = StateProvider<int>((ref) => 0);

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = ref.watch(tasbihCountProvider);
    final target = ref.watch(tasbihTargetProvider);
    final rounds = ref.watch(tasbihRoundsProvider);
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    final progress = target == 0 ? 0.0 : (count / target).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: const DeenGlassAppBar(title: 'Tasbih'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        child: Column(
          children: [
            // Preset targets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [33, 99, 100].map((t) {
                  final selected = target == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.spaceSM),
                    child: ChoiceChip(
                      label: Text('$t'),
                      selected: selected,
                      selectedColor: AppColors.gold,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: selected ? Colors.white : AppColors.textMuted,
                      ),
                      onSelected: (_) {
                        ref.read(tasbihTargetProvider.notifier).state = t;
                        ref.read(tasbihCountProvider.notifier).state = 0;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLG),
            // Progress ring reuse style
            Builder(
              builder: (context) {
                final text = Text(
                  '$count',
                  key: ValueKey<int>(count),
                  style: AppTypography.displayLarge.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                );
                if (elderly) return text;
                return text
                    .animate(key: ValueKey<int>(count))
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 220.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 180.ms);
              },
            ),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              'Rounds: $rounds',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXS),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.darkOutlineVariant
                  : AppColors.creamDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 6,
            ),
            const Spacer(),
            // Large tap target
            GestureDetector(
              onTap: () async {
                if (!elderly) HapticFeedback.lightImpact();
                final current = ref.read(tasbihCountProvider.notifier).state;
                final tgt = ref.read(tasbihTargetProvider);
                final newCount = current + 1;
                if (newCount >= tgt && tgt > 0) {
                  // Celebration will be triggered by rebuild with ValueKey + animate
                  ref.read(tasbihCountProvider.notifier).state = 0;
                  ref.read(tasbihRoundsProvider.notifier).state =
                      ref.read(tasbihRoundsProvider) + 1;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('MashaAllah - $tgt completed!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                  // Gamification: hasanat only, no streak (critical correction)
                  final repo = ref.read(gamificationRepositoryProvider);
                  await repo.logDhikrSession(count: tgt);
                } else {
                  ref.read(tasbihCountProvider.notifier).state = newCount;
                }
              },
              child: Builder(
                builder: (context) {
                  final circle = Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.goldFlow,
                      boxShadow: [
                        BoxShadow(
                          color: elderly
                              ? Colors.black.withValues(alpha: 0.12)
                              : AppColors.gold.withValues(alpha: 0.32),
                          blurRadius: elderly ? 8 : 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      size: 64,
                      color: Colors.white,
                    ),
                  );
                  if (elderly) return circle;
                  return circle.animate().scale(
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
            const Spacer(),
            Text(
              'Tap the circle to count',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Counts are encouragement only; true reward is with Allah.',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
          ],
        ),
      ),
    );
  }
}
