import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../prayer/providers/prayer_providers.dart';

/// Design v3 next-prayer strip: compact DeenCard row with name, time,
/// and countdown pill. Taps through to full prayer times.
/// Static paint, no glow.
class NextPrayerStrip extends ConsumerWidget {
  const NextPrayerStrip({super.key});

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  String _formatCountdown(DateTime next, DateTime now) {
    final diff = next.difference(now);
    if (diff.isNegative) return 'now';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return 'in ${hours}h ${minutes}m';
    return 'in ${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextAsync = ref.watch(nextPrayerProvider);
    final clockAsync = ref.watch(clockProvider);
    final onDark = isDark ? AppColors.darkOnSurface : AppColors.textDark;

    return nextAsync.when(
      loading: () => const DeenCard(
        child: SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => DeenCard(
        child: Text(
          'Prayer times unavailable offline.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
      data: (next) {
        final now = clockAsync.value ?? DateTime.now();
        final countdown = _formatCountdown(next.time, now);
        return Semantics(
          label: 'Next prayer',
          value: '${next.name} at ${_formatTime(next.time)}, $countdown',
          child: DeenCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMD,
              vertical: AppSpacing.spaceSM,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              onTap: () => context.push('/prayer-times'),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: AppColors.goldDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          next.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: onDark,
                          ),
                        ),
                        Text(
                          _formatTime(next.time),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSM,
                      vertical: AppSpacing.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
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
            ),
          ),
        );
      },
    );
  }
}
