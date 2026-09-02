import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../settings/providers/settings_providers.dart';

/// Horizontal 7-pill tracker Mon→Sun.
/// Gold filled if completed for that date; today incomplete pulses via flutter_animate.
class WeeklyStreakTracker extends ConsumerWidget {
  const WeeklyStreakTracker({
    super.key,
    required this.currentStreak,
    required this.completedByWeekday,
    required this.todayWeekday,
  });

  /// Overall streak count for label.
  final int currentStreak;

  /// Length 7, index 0 = Monday ... 6 = Sunday, true if goal met on that date.
  final List<bool> completedByWeekday;

  /// 1 = Monday ... 7 = Sunday for today.
  final int todayWeekday;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    assert(completedByWeekday.length == 7, 'completedByWeekday must be 7');

    return Container(
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
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 18,
                color: AppColors.goldDark,
              ),
              const SizedBox(width: AppSpacing.spaceXS),
              Text(
                currentStreak > 0
                    ? '$currentStreak day streak'
                    : 'Start your streak today',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                currentStreak >= 7 ? 'on fire!' : 'keep it alive',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isCompleted = completedByWeekday[i];
              final isToday = (i + 1) == todayWeekday;
              final shouldPulse = isToday && !isCompleted;

              Widget pill = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.gold : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.goldDark
                        : (isDark
                              ? AppColors.darkOutline
                              : AppColors.lightOutline),
                    width: isToday ? 1.8 : 1,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          _labels[i],
                          style: AppTypography.labelSmall.copyWith(
                            color: isToday
                                ? (isDark
                                      ? AppColors.darkOnSurface
                                      : AppColors.textDark)
                                : AppColors.textMuted,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                ),
              );

              if (shouldPulse && !elderly) {
                pill = pill
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 900.ms,
                      curve: Curves.easeInOut,
                    )
                    .then(delay: 100.ms)
                    .scale(
                      begin: const Offset(1.08, 1.08),
                      end: const Offset(1, 1),
                      duration: 900.ms,
                    );
              }

              return Column(
                children: [
                  pill,
                  const SizedBox(height: 4),
                  Text(
                    _labels[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isToday ? AppColors.goldDark : AppColors.textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
