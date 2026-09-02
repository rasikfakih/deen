import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Glassmorphism / soft-shadow card for next prayer countdown.
/// Expects already-resolved next prayer name + time + countdown string.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.countdown,
    this.isLoading = false,
  });

  final String prayerName;
  final DateTime? prayerTime;
  final String countdown;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading || prayerTime == null) {
      return Container(
        height: 92,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: isDark
                ? AppColors.darkOutlineVariant
                : AppColors.lightOutlineVariant,
          ),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final timeStr = _formatTime(prayerTime!);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.goldDark,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next prayer',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  prayerName,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.textDark,
                  ),
                ),
                Text(
                  timeStr,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMD,
              vertical: AppSpacing.spaceXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              countdown,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}
