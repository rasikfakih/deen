import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../settings/providers/settings_providers.dart';

/// Playful hasanat ticker with subtle scale+fade on value change.
/// Includes mandatory microcopy per DEEN 3.
class HasanatTicker extends ConsumerWidget {
  const HasanatTicker({super.key, required this.todayHasanat});

  final int todayHasanat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: AppSpacing.elevationSM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Hasanat today',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          // AnimatedSwitcher-like via flutter_animate keyed scale+fade
          // Disabled in elderly mode per settings
          Builder(
            builder: (context) {
              final text = Text(
                '$todayHasanat',
                key: ValueKey<int>(todayHasanat),
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              );
              if (elderly) return text;
              return text
                  .animate(key: ValueKey<int>(todayHasanat))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 420.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut);
            },
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          Text(
            'Counts are encouragement only; true reward is with Allah.',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
