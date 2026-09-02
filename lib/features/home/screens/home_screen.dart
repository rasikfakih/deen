import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../prayer/providers/prayer_providers.dart';
import '../widgets/daily_goal_ring.dart';
import '../widgets/hasanat_ticker.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/weekly_streak_tracker.dart';

// Top-level providers for Home dashboard - keeps build pure.

final greetingNameProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(deenDatabaseProvider);
  final row = await (db.select(
    db.settingsCache,
  )..where((t) => t.key.equals('user_name'))).getSingleOrNull();
  return row?.value;
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final db = ref.watch(deenDatabaseProvider);
  // Watch clock to rebuild at midnight for weekly header.
  final clockAsync = ref.watch(clockProvider);
  final now = clockAsync.value ?? DateTime.now();
  final goal = await db.activeGoal;
  final targetMinutes = goal?.dailyTargetMinutes ?? 15;
  final targetAyahs = goal?.dailyTargetAyahs ?? 5;

  // Decide unit: if no goal, default ayahs (CTO 1 fallback 1 ayah).
  // If goal exists and ayahs was customized (not 5), show ayahs, else minutes.
  bool useMinutes;
  if (goal == null) {
    useMinutes = false;
  } else if (goal.dailyTargetAyahs != 5) {
    useMinutes = false;
  } else {
    useMinutes = true;
  }

  final monday = _mondayOfWeek(now);
  final completed = <bool>[];
  for (var i = 0; i < 7; i++) {
    final date = monday.add(Duration(days: i));
    final dateStr = _fmtDate(date);
    final read = await db.getDailyReadByDate(dateStr);
    bool met = false;
    if (read != null) {
      if (goal != null) {
        met =
            read.ayahsRead >= goal.dailyTargetAyahs ||
            read.minutesRead >= goal.dailyTargetMinutes;
      } else {
        met = read.ayahsRead >= 1;
      }
    }
    completed.add(met);
  }
  return HomeDashboardData(
    targetMinutes: targetMinutes,
    targetAyahs: targetAyahs,
    useMinutes: useMinutes,
    completedByWeekday: completed,
  );
});

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime _mondayOfWeek(DateTime now) {
  final weekday = now.weekday; // 1 Mon .. 7 Sun
  return DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: weekday - 1));
}

/// Premium Home Dashboard - playful layer, spacious, motivating.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
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
    final now = DateTime.now();

    final streakAsync = ref.watch(streakStreamProvider);
    final todayAsync = ref.watch(todayProgressProvider);
    final nextPrayerAsync = ref.watch(nextPrayerProvider);
    final clockAsync = ref.watch(clockProvider);
    final greetingAsync = ref.watch(greetingNameProvider);
    final homeDataAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            sliver: SliverList.list(
              children: [
                // Greeting - SettingsCache user_name per CTO 1
                greetingAsync.when(
                  data: (name) {
                    final displayName = (name != null && name.trim().isNotEmpty)
                        ? ', $name'
                        : '';
                    final greet = _greeting(now);
                    // CTO: if exists use "Peace be upon you, [Name]" else generic
                    final line2 = displayName.isEmpty
                        ? 'Peace be upon you'
                        : 'Peace be upon you$displayName';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greet$displayName',
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          line2,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Text(
                    '${_greeting(now)}, there',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.textDark,
                    ),
                  ),
                  error: (_, _) => Text(
                    'Peace be upon you',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                // Next Prayer Card - watches clock for live countdown
                nextPrayerAsync.when(
                  data: (next) {
                    final nowClock = clockAsync.value ?? now;
                    final countdown = _formatCountdown(next.time, nowClock);
                    return NextPrayerCard(
                      prayerName: next.name,
                      prayerTime: next.time,
                      countdown: countdown,
                      onViewAll: () => context.push('/prayer-times'),
                    );
                  },
                  loading: () => NextPrayerCard(
                    prayerName: '-',
                    prayerTime: null,
                    countdown: '-',
                    isLoading: true,
                    onViewAll: () => context.push('/prayer-times'),
                  ),
                  error: (_, _) => NextPrayerCard(
                    prayerName: '-',
                    prayerTime: null,
                    countdown: '-',
                    isLoading: true,
                    onViewAll: () => context.push('/prayer-times'),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                // Daily Goal Ring - flexible unit per CTO 2
                todayAsync.when(
                  data: (today) {
                    final homeData = homeDataAsync.valueOrNull;
                    final targetAyahs = homeData?.targetAyahs ?? 5;
                    final targetMinutes = homeData?.targetMinutes ?? 15;
                    final useMinutes = homeData?.useMinutes ?? true;
                    final current = useMinutes
                        ? (today?.minutesRead ?? 0)
                        : (today?.ayahsRead ?? 0);
                    final target = useMinutes ? targetMinutes : targetAyahs;
                    final unit = useMinutes ? 'min' : 'ayahs';
                    return DailyGoalRing(
                      current: current,
                      target: target,
                      unit: unit,
                    );
                  },
                  loading: () =>
                      const DailyGoalRing(current: 0, target: 15, unit: 'min'),
                  error: (_, _) =>
                      const DailyGoalRing(current: 0, target: 15, unit: 'min'),
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                // Weekly Streak Tracker - actual DailyReads per CTO 3
                streakAsync.when(
                  data: (streak) {
                    final homeData = homeDataAsync.valueOrNull;
                    final completed =
                        homeData?.completedByWeekday ?? List.filled(7, false);
                    return WeeklyStreakTracker(
                      currentStreak: streak?.currentStreak ?? 0,
                      completedByWeekday: completed,
                      todayWeekday: now.weekday,
                    );
                  },
                  loading: () => WeeklyStreakTracker(
                    currentStreak: 0,
                    completedByWeekday: List.filled(7, false),
                    todayWeekday: now.weekday,
                  ),
                  error: (_, _) => WeeklyStreakTracker(
                    currentStreak: 0,
                    completedByWeekday: List.filled(7, false),
                    todayWeekday: now.weekday,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                // Hasanat Ticker - subtle scale+fade per CTO 4
                todayAsync.when(
                  data: (today) =>
                      HasanatTicker(todayHasanat: today?.hasanatEarned ?? 0),
                  loading: () => const HasanatTicker(todayHasanat: 0),
                  error: (_, _) => const HasanatTicker(todayHasanat: 0),
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

class HomeDashboardData {
  HomeDashboardData({
    required this.targetMinutes,
    required this.targetAyahs,
    required this.useMinutes,
    required this.completedByWeekday,
  });

  final int targetMinutes;
  final int targetAyahs;
  final bool useMinutes;
  final List<bool> completedByWeekday;
}
