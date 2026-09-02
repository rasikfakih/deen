import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/gamification/data/gamification_repository.dart';
import 'package:deen/shared/database/deen_database.dart';

String _fmt(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

Future<void> _seedGoal(
  DeenDatabase db, {
  int ayahs = 5,
  int minutes = 15,
}) async {
  await db
      .into(db.userGoals)
      .insert(
        UserGoalsCompanion.insert(
          dailyTargetAyahs: Value(ayahs),
          dailyTargetMinutes: Value(minutes),
          isActive: const Value(true),
        ),
      );
}

Future<void> _seedStreak(
  DeenDatabase db, {
  int current = 0,
  int longest = 0,
  int freezes = 0,
  String? lastReadDate,
}) async {
  final existing = await db.streak;
  if (existing != null) {
    await (db.update(db.streaks)..where((t) => t.id.equals(existing.id))).write(
      StreaksCompanion(
        currentStreak: Value(current),
        longestStreak: Value(longest),
        availableFreezes: Value(freezes),
        lastReadDate: lastReadDate == null
            ? const Value.absent()
            : Value(lastReadDate),
      ),
    );
  } else {
    await db
        .into(db.streaks)
        .insert(
          StreaksCompanion.insert(
            id: const Value(1),
            currentStreak: Value(current),
            longestStreak: Value(longest),
            availableFreezes: Value(freezes),
            lastReadDate: lastReadDate == null
                ? const Value.absent()
                : Value(lastReadDate),
          ),
        );
  }
}

void main() {
  late DeenDatabase db;
  late GamificationRepository repo;

  setUp(() async {
    db = DeenDatabase.forTesting(NativeDatabase.memory());
    repo = GamificationRepository(db);
    // Default goal: 5 ayahs or 15 min
    await _seedGoal(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('GamificationRepository', () {
    test('Scenario A: consecutive days increment streak', () async {
      final day1 = DateTime(2026, 9, 1);
      final day2 = DateTime(2026, 9, 2);

      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day1);
      var streak = await repo.checkAndUpdateStreak(now: day1);
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
      expect(streak.lastReadDate, _fmt(day1));

      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day2);
      streak = await repo.checkAndUpdateStreak(now: day2);
      expect(streak.currentStreak, 2);
      expect(streak.longestStreak, 2);
      expect(streak.lastReadDate, _fmt(day2));
    });

    test('Scenario B: missing a day with freeze maintains streak', () async {
      // Start with streak 2 and 1 freeze, last read 2026-09-01
      await _seedStreak(
        db,
        current: 2,
        longest: 2,
        freezes: 1,
        lastReadDate: _fmt(DateTime(2026, 9, 1)),
      );
      final dayMissed = DateTime(2026, 9, 2); // missed
      final dayAfter = DateTime(2026, 9, 3);

      await repo.logReadingSession(minutes: 10, ayahs: 5, now: dayAfter);
      final streak = await repo.checkAndUpdateStreak(now: dayAfter);

      // Gap 2 days => missed 1 day, freeze consumed
      expect(streak.currentStreak, 3);
      expect(streak.availableFreezes, 0);
      expect(streak.lastReadDate, _fmt(dayAfter));
      // Avoid unused
      expect(dayMissed, isA<DateTime>());
    });

    test('Scenario B extended: 2-day gap consumes 2 freezes', () async {
      await _seedStreak(
        db,
        current: 5,
        longest: 5,
        freezes: 2,
        lastReadDate: _fmt(DateTime(2026, 9, 1)),
      );
      final dayAfterGap = DateTime(2026, 9, 4); // missed 2,3 => 2 days gap
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: dayAfterGap);
      final streak = await repo.checkAndUpdateStreak(now: dayAfterGap);
      expect(streak.currentStreak, 6);
      expect(streak.availableFreezes, 0);
    });

    test('Scenario C: missing a day without freeze resets streak', () async {
      await _seedStreak(
        db,
        current: 3,
        longest: 3,
        freezes: 0,
        lastReadDate: _fmt(DateTime(2026, 9, 1)),
      );
      final dayAfterMiss = DateTime(2026, 9, 3); // missed 2026-09-02
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: dayAfterMiss);
      final streak = await repo.checkAndUpdateStreak(now: dayAfterMiss);

      // Per spec: reset to 0 then today's success starts new streak as 1.
      // We assert 1 (new streak). If strict 0 is required, change expectation to 0.
      // Documented as assumption: reset to 1 for UX; strict spec would be 0.
      expect(streak.currentStreak, 1);
      expect(streak.availableFreezes, 0);
    });

    test('Scenario C strict reset variant: gap without freeze with no goal met keeps streak', () async {
      // If no log today, streak should not change (goal not met).
      await _seedStreak(
        db,
        current: 3,
        longest: 3,
        freezes: 0,
        lastReadDate: _fmt(DateTime(2026, 9, 1)),
      );
      final dayAfterMissNoLog = DateTime(2026, 9, 3);
      // No logReadingSession for today
      final streak = await repo.checkAndUpdateStreak(now: dayAfterMissNoLog);
      // No goal met, no change
      expect(streak.currentStreak, 3);
    });

    test('Scenario D: Beast Mode 2x multiplier for 30+ minutes', () async {
      final day = DateTime(2026, 9, 1);
      // 30 min => 2x
      var read = await repo.logReadingSession(minutes: 30, ayahs: 10, now: day);
      expect(read.hasanatEarned, 200); // 10*10*2
      expect(read.minutesRead, 30);
      expect(read.ayahsRead, 10);

      // New DB for 29 min no multiplier
      await db.close();
      db = DeenDatabase.forTesting(NativeDatabase.memory());
      repo = GamificationRepository(db);
      await _seedGoal(db);
      final day2 = DateTime(2026, 9, 2);
      read = await repo.logReadingSession(minutes: 29, ayahs: 10, now: day2);
      expect(read.hasanatEarned, 100); // no beast
    });

    test('Beast mode cumulative sessions sum correctly', () async {
      final day = DateTime(2026, 9, 1);
      await repo.logReadingSession(minutes: 20, ayahs: 5, now: day); // 50
      var read = await repo.logReadingSession(
        minutes: 15,
        ayahs: 5,
        now: day,
      ); // +50 =100 total, but second not beast
      // First 20->50, second 15->50, total 100. Neither had 30 alone.
      expect(read.hasanatEarned, 100);
      expect(read.minutesRead, 35);
      expect(read.ayahsRead, 10);

      // But if single session 30 => 2x
      await db.close();
      db = DeenDatabase.forTesting(NativeDatabase.memory());
      repo = GamificationRepository(db);
      await _seedGoal(db);
      final day3 = DateTime(2026, 9, 3);
      read = await repo.logReadingSession(minutes: 35, ayahs: 5, now: day3);
      expect(read.hasanatEarned, 100); // 5*10*2
    });

    test('Freeze awarded every 7-day streak, cap at 3', () async {
      // Seed streak 6 with 0 freezes, last read yesterday
      await _seedStreak(
        db,
        current: 6,
        longest: 6,
        freezes: 0,
        lastReadDate: _fmt(DateTime(2026, 9, 1)),
      );
      final day7 = DateTime(2026, 9, 2);
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day7);
      var streak = await repo.checkAndUpdateStreak(now: day7);
      expect(streak.currentStreak, 7);
      expect(streak.availableFreezes, 1); // awarded

      // Continue to 14 => should award again
      // Simulate streak 13 -> 14
      await _seedStreak(
        db,
        current: 13,
        longest: 13,
        freezes: 1,
        lastReadDate: _fmt(DateTime(2026, 9, 3)),
      );
      final day14 = DateTime(2026, 9, 4);
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day14);
      streak = await repo.checkAndUpdateStreak(now: day14);
      expect(streak.currentStreak, 14);
      expect(streak.availableFreezes, 2);

      // Cap at 3
      await _seedStreak(
        db,
        current: 20,
        longest: 20,
        freezes: 3,
        lastReadDate: _fmt(DateTime(2026, 9, 5)),
      );
      final day21 = DateTime(2026, 9, 6);
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day21);
      streak = await repo.checkAndUpdateStreak(now: day21);
      expect(streak.currentStreak, 21);
      expect(streak.availableFreezes, 3); // cap, not 4
    });

    test('Default goal fallback: 1 ayah if no UserGoals', () async {
      await db.close();
      db = DeenDatabase.forTesting(NativeDatabase.memory());
      repo = GamificationRepository(db);
      // No goal seeded
      final day = DateTime(2026, 9, 1);
      await repo.logReadingSession(minutes: 0, ayahs: 1, now: day);
      final streak = await repo.checkAndUpdateStreak(now: day);
      expect(streak.currentStreak, 1);
    });

    test('Idempotent checkAndUpdateStreak same day', () async {
      final day = DateTime(2026, 9, 1);
      await repo.logReadingSession(minutes: 10, ayahs: 5, now: day);
      var s1 = await repo.checkAndUpdateStreak(now: day);
      var s2 = await repo.checkAndUpdateStreak(now: day);
      expect(s2.currentStreak, s1.currentStreak);
      expect(s2.lastReadDate, s1.lastReadDate);
    });

    test(
      'logDhikrSession does not affect ayahsRead/minutesRead/currentStreak',
      () async {
        final day = DateTime(2026, 9, 1);
        await repo.logReadingSession(minutes: 10, ayahs: 5, now: day);
        await repo.checkAndUpdateStreak(now: day);
        final before = await db.getDailyReadByDate(_fmt(day));
        final streakBefore = await db.getOrCreateStreak();
        await repo.logDhikrSession(count: 33, now: day);
        final after = await db.getDailyReadByDate(_fmt(day));
        final streakAfter = await db.getOrCreateStreak();
        expect(after!.ayahsRead, before!.ayahsRead);
        expect(after.minutesRead, before.minutesRead);
        expect(after.hasanatEarned, before.hasanatEarned + 330);
        expect(streakAfter.currentStreak, streakBefore.currentStreak);
        expect(streakAfter.lastReadDate, streakBefore.lastReadDate);
      },
    );

    test('logDhikrSession creates row with zero ayahs/minutes', () async {
      await db.close();
      db = DeenDatabase.forTesting(NativeDatabase.memory());
      repo = GamificationRepository(db);
      final day = DateTime(2026, 9, 2);
      final read = await repo.logDhikrSession(count: 10, now: day);
      expect(read.ayahsRead, 0);
      expect(read.minutesRead, 0);
      expect(read.hasanatEarned, 100);
      final streak = await db.getOrCreateStreak();
      expect(streak.currentStreak, 0);
    });
  });
}
