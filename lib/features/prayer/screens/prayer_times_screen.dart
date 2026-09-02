import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/prayer_providers.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timesAsync = ref.watch(prayerTimesProvider);
    final nextAsync = ref.watch(nextPrayerProvider);
    final locAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Prayer Times'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            sliver: SliverList.list(
              children: [
                // Location header - raw coordinates + Mecca default label per CTO
                locAsync.when(
                  data: (loc) {
                    final isMeccaDefault =
                        loc.latitude == 21.3891 && loc.longitude == 39.8579;
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLG,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkOutlineVariant
                              : AppColors.lightOutlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.goldDark,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.spaceXS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMeccaDefault
                                      ? 'Mecca default'
                                      : 'Current location',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.textDark,
                                  ),
                                ),
                                if (isMeccaDefault)
                                  Text(
                                    'Enable location for local times',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.my_location,
                            color: AppColors.textMuted,
                            size: AppSpacing.iconSM,
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                // Hijri + Gregorian header
                timesAsync.when(
                  data: (times) => Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceSM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.creamDark,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${times.date.year}-${times.date.month.toString().padLeft(2, '0')}-${times.date.day.toString().padLeft(2, '0')}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Hijri ${times.hijriDate}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                // Prayer list - 6 rows including Sunrise muted
                timesAsync.when(
                  data: (times) {
                    final nextName = nextAsync.valueOrNull?.name;
                    final items = [
                      (name: 'Fajr', time: times.fajr),
                      (name: 'Sunrise', time: times.sunrise),
                      (name: 'Dhuhr', time: times.dhuhr),
                      (name: 'Asr', time: times.asr),
                      (name: 'Maghrib', time: times.maghrib),
                      (name: 'Isha', time: times.isha),
                    ];
                    return Column(
                      children: items.map((e) {
                        final isSunrise = e.name == 'Sunrise';
                        final isNext = e.name == nextName && !isSunrise;
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppSpacing.spaceSM,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.spaceMD),
                          decoration: BoxDecoration(
                            color: isNext
                                ? AppColors.gold.withValues(alpha: 0.14)
                                : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLG,
                            ),
                            border: Border.all(
                              color: isNext
                                  ? AppColors.gold
                                  : (isDark
                                        ? AppColors.darkOutlineVariant
                                        : AppColors.lightOutlineVariant),
                            ),
                            boxShadow: isNext
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSunrise
                                    ? Icons.wb_twilight
                                    : Icons.access_time,
                                color: isNext
                                    ? AppColors.goldDark
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.spaceMD),
                              Expanded(
                                child: Text(
                                  e.name,
                                  style: isSunrise
                                      ? AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textMuted,
                                        )
                                      : AppTypography.titleMedium.copyWith(
                                          color: isNext
                                              ? AppColors.goldDark
                                              : (isDark
                                                    ? AppColors.darkOnSurface
                                                    : AppColors.textDark),
                                          fontWeight: isNext
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                ),
                              ),
                              Text(
                                _formatTime(e.time),
                                style: isSunrise
                                    ? AppTypography.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                      )
                                    : AppTypography.titleMedium.copyWith(
                                        color: isDark
                                            ? AppColors.darkOnSurface
                                            : AppColors.textDark,
                                      ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: AppSpacing.spaceSM),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Text('Error: $e', style: AppTypography.bodyMedium),
                ),
                const SizedBox(height: AppSpacing.spaceXL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
