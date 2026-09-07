import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../providers/home_stats_providers.dart';

/// Design v3 stats row: three DeenCards (Hasanat, Verses, Minutes) with
/// Today/Week/All segmented control. Sums of verified DailyReads only.
/// Includes the encouragement microcopy (DEEN 3). Static paint, no glow.
class StatsRow extends ConsumerWidget {
  const StatsRow({super.key});

  String _valueFor(
    StatsRange range,
    DayTotals? today,
    DayTotals? week,
    DayTotals? all,
    int Function(DayTotals) pick,
  ) {
    final totals = switch (range) {
      StatsRange.today => today,
      StatsRange.week => week,
      StatsRange.all => all,
    };
    if (totals == null) return '–';
    return '${pick(totals)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final range = ref.watch(statsRangeProvider);
    final today = ref.watch(todayProgressProvider).valueOrNull;
    final week = ref.watch(weekStatsProvider).valueOrNull;
    final all = ref.watch(allStatsProvider).valueOrNull;

    final todayTotals = today == null
        ? null
        : DayTotals(
            minutes: today.minutesRead,
            ayahs: today.ayahsRead,
            hasanat: today.hasanatEarned,
          );

    final cards = [
      (
        label: 'Hasanat',
        value: _valueFor(range, todayTotals, week, all, (t) => t.hasanat),
      ),
      (
        label: 'Verses',
        value: _valueFor(range, todayTotals, week, all, (t) => t.ayahs),
      ),
      (
        label: 'Minutes',
        value: _valueFor(range, todayTotals, week, all, (t) => t.minutes),
      ),
    ];

    return Semantics(
      label: 'Reading statistics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Statistics range',
            child: SegmentedButton<StatsRange>(
              segments: const [
                ButtonSegment(value: StatsRange.today, label: Text('Today')),
                ButtonSegment(value: StatsRange.week, label: Text('Week')),
                ButtonSegment(value: StatsRange.all, label: Text('All')),
              ],
              selected: {range},
              onSelectionChanged: (s) =>
                  ref.read(statsRangeProvider.notifier).state = s.first,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(
                  child: Semantics(
                    label: '${cards[i].label} ${cards[i].value}',
                    child: DeenCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceSM,
                        vertical: AppSpacing.spaceMD,
                      ),
                      child: Column(
                        children: [
                          Text(
                            cards[i].value,
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkOnSurface
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cards[i].label,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i < cards.length - 1)
                  const SizedBox(width: AppSpacing.spaceSM),
              ],
            ],
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
