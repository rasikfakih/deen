import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_canvas.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass/deen_glass_app_bar.dart';
import '../../../shared/widgets/icons/deen_symbol_effects.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../../shared/providers/display_providers.dart';

final tasbihCountProvider = StateProvider<int>((ref) => 0);
final tasbihTargetProvider = StateProvider<int>((ref) => 33);
final tasbihRoundsProvider = StateProvider<int>((ref) => 0);

/// Design v5 Tasbih: gradient displayNumerals counter, rounds, target
/// chips directly under the counter, thin progress, goldFlow orb with a
/// progress ring and tap bounce, reset button. Adaptive via Flexible,
/// FittedBox and LayoutBuilder (no fixed heights). Haptics unchanged.
class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  Future<void> _tap(BuildContext context, WidgetRef ref) async {
    final elderly = ref.read(elderlyModeProvider).valueOrNull ?? false;
    if (!elderly) HapticFeedback.lightImpact();
    final current = ref.read(tasbihCountProvider.notifier).state;
    final tgt = ref.read(tasbihTargetProvider);
    final newCount = current + 1;
    if (newCount >= tgt && tgt > 0) {
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = ref.watch(tasbihCountProvider);
    final target = ref.watch(tasbihTargetProvider);
    final rounds = ref.watch(tasbihRoundsProvider);
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    final progress = target == 0 ? 0.0 : (count / target).clamp(0.0, 1.0);

    return Scaffold(
      // Non-scrolling screen: no extendBodyBehindAppBar (top-leak rule).
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: const DeenGlassAppBar(title: 'Tasbih'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: CanvasGradient.forBrightness(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            child: Column(
              children: [
                // Gradient counter with overflow-safe fit.
                Semantics(
                  key: const ValueKey('tasbih-counter'),
                  label: 'Tasbih count',
                  value: '$count of $target',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          AppGradients.goldFlow.createShader(bounds),
                      child: Text(
                        '$count',
                        key: ValueKey<int>(count),
                        style: AppTypography.displayNumerals.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Rounds: $rounds',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                // Target chips directly under the counter.
                Semantics(
                  label: 'Counter target',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [33, 99, 100].map((t) {
                      final selected = target == t;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceXS,
                        ),
                        child: ChoiceChip(
                          label: Text('$t'),
                          selected: selected,
                          selectedColor: AppColors.gold,
                          labelStyle: AppTypography.labelMedium.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textMuted,
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
                const SizedBox(height: AppSpacing.spaceSM),
                Semantics(
                  excludeSemantics: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark
                          ? AppColors.darkOutlineVariant
                          : AppColors.creamDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                // Adaptive orb zone: shrinks on short screens/landscape.
                Flexible(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final orbSize = math.min(
                        200.0,
                        math.min(
                          constraints.maxWidth - 32,
                          constraints.maxHeight - 32,
                        ),
                      );
                      return Center(
                        child: Semantics(
                          button: true,
                          label: 'Tasbih counter',
                          value: '$count of $target, $rounds rounds completed',
                          child: GestureDetector(
                            onTap: () => _tap(context, ref),
                            child: DeenAnimatedIcon(
                              effect: DeenSymbolEffect.bounce,
                              replayKey: count,
                              child: CustomPaint(
                                painter: _ProgressRingPainter(
                                  progress: progress,
                                  isDark: isDark,
                                ),
                                child: Container(
                                  width: orbSize,
                                  height: orbSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppGradients.goldFlow,
                                    boxShadow: [
                                      BoxShadow(
                                        color: elderly
                                            ? Colors.black.withValues(
                                                alpha: 0.12,
                                              )
                                            : AppColors.gold.withValues(
                                                alpha: 0.32,
                                              ),
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
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  'Tap the circle to count',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Reset counter',
                  child: TextButton(
                    onPressed: () =>
                        ref.read(tasbihCountProvider.notifier).state = 0,
                    child: const Text('Reset'),
                  ),
                ),
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
        ],
      ),
    );
  }
}

/// Thin progress ring painted around the orb.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final track = Paint()
      ..color = isDark ? AppColors.darkOutlineVariant : AppColors.creamDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    if (progress <= 0) return;
    final fill = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
