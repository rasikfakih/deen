import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_canvas.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/screen_insets.dart';
import '../../../shared/widgets/chrome/deen_app_bar.dart';
import '../../../shared/widgets/chrome/deen_chrome.dart';
import '../../../shared/widgets/chrome/deen_scroll_edge_fade.dart';
import '../../../shared/widgets/pattern_overlay.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../prayer/providers/prayer_providers.dart';
import '../../quran/providers/quran_providers.dart';
import '../providers/home_stats_providers.dart';
import '../widgets/ayah_of_day_card.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/family_card.dart';
import '../widgets/goal_hero_card.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_strip.dart';
import '../widgets/stats_row.dart';
import '../widgets/surah_chips.dart';
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

  final monday = mondayOfWeek(now);
  final completed = <bool>[];
  for (var i = 0; i < 7; i++) {
    final date = monday.add(Duration(days: i));
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

/// Design v3 Home - playful canvas layer, modules in spec order.
/// Canvas + pattern behind; glass only on app bar + nav bar.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final streakAsync = ref.watch(streakStreamProvider);
    final todayAsync = ref.watch(todayProgressProvider);
    final greetingAsync = ref.watch(greetingNameProvider);
    final homeDataAsync = ref.watch(homeDashboardProvider);
    final lastReadAsync = ref.watch(lastReadProvider);

    final streak = streakAsync.valueOrNull?.currentStreak ?? 0;
    final today = todayAsync.valueOrNull;
    final homeData = homeDataAsync.valueOrNull;
    final targetAyahs = homeData?.targetAyahs ?? 5;
    final todayAyahs = today?.ayahsRead ?? 0;
    final last = lastReadAsync.valueOrNull;
    final dateLine = hijriGregorianLabel(now);

    Widget header(String? name) {
      final trimmed = (name ?? '').trim();
      // Full-bleed night band (DEEN 8.2 v6): no radius, edge to edge.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spaceMD,
          AppSpacing.spaceMD,
          AppSpacing.spaceMD,
          AppSpacing.spaceLG,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF191410), Color(0xFF2A2018)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: HomeHeader(
          key: const ValueKey('home-header'),
          userName: trimmed.isEmpty ? null : trimmed,
          greeting: 'As-salamu alaykum',
          greeting2: dateLine,
          streakCount: streak,
          todayCount: todayAyahs,
          targetCount: targetAyahs,
          goalUnit: 'ayahs',
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const DeenAppBar(title: 'Home'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: CanvasGradient.forBrightness(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          const Positioned.fill(child: DeenPatternOverlay()),
          DeenChromeListener(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: topContentPad(context)),
                ),
                const SliverToBoxAdapter(
                  child: DeenScrollEdgeFade(isTop: true),
                ),
                SliverToBoxAdapter(
                  child: greetingAsync.when(
                    data: (name) => header(name),
                    loading: () => header(null),
                    error: (_, _) => header(null),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spaceMD)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spaceMD,
                    AppSpacing.spaceSM,
                    AppSpacing.spaceMD,
                    AppSpacing.spaceMD,
                  ),
                  sliver: SliverList.list(
                    children: [
                      // 1. Night header band is full-bleed (own sliver below).
                      // 2. Week pills restyled on canvas.
                      WeeklyStreakTracker(
                        key: const ValueKey('week-pills'),
                        currentStreak: streak,
                        completedByWeekday:
                            homeData?.completedByWeekday ??
                            List.filled(7, false),
                        todayWeekday: now.weekday,
                        transparent: true,
                      ),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 3. Goal hero with last-read + Continue.
                      GoalHeroCard(
                        key: const ValueKey('goal-hero'),
                        current: todayAyahs,
                        target: targetAyahs,
                        lastSurahId: last?.surahId,
                        lastAyahId: last?.ayahId,
                      ),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 4. Quick surah chips.
                      const SurahChips(key: ValueKey('surah-chips')),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 5. Ayah of the Day (verbatim verified data).
                      const AyahOfDayCard(key: ValueKey('ayah-of-day')),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 6. Daily challenge dark card.
                      DailyChallengeCard(
                        key: const ValueKey('challenge-card'),
                        targetAyahs: targetAyahs,
                        todayAyahs: todayAyahs,
                      ),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 7. Stats row with Today/Week/All tabs.
                      const StatsRow(key: ValueKey('stats-row')),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 8. Family circles card.
                      const FamilyCirclesHomeCard(key: ValueKey('family-card')),
                      const SizedBox(height: AppSpacing.spaceMD),
                      // 9. Next prayer strip.
                      const NextPrayerStrip(key: ValueKey('prayer-strip')),
                      const SizedBox(height: AppSpacing.spaceSM),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: DeenScrollEdgeFade(isTop: false),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
