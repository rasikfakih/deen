import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/home/providers/home_stats_providers.dart';
import 'package:deen/features/quran/data/quran_repository.dart';
import 'package:deen/features/quran/providers/quran_providers.dart';
import 'package:deen/shared/database/database_providers.dart';
import 'package:deen/shared/database/deen_database.dart';

Future<void> _seedRead(
  DeenDatabase db,
  String date, {
  int minutes = 0,
  int ayahs = 0,
  int hasanat = 0,
}) async {
  await db
      .into(db.dailyReads)
      .insert(
        DailyReadsCompanion.insert(
          date: date,
          minutesRead: Value(minutes),
          ayahsRead: Value(ayahs),
          hasanatEarned: Value(hasanat),
        ),
      );
}

String _fmt(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

void main() {
  group('Home stats providers (sums of verified DailyReads)', () {
    late DeenDatabase db;

    setUp(() {
      db = DeenDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('mondayOfWeek returns Monday for any weekday', () {
      // 2026-09-07 is a Monday.
      expect(mondayOfWeek(DateTime(2026, 9, 7)), DateTime(2026, 9, 7));
      expect(mondayOfWeek(DateTime(2026, 9, 13)), DateTime(2026, 9, 7));
      expect(mondayOfWeek(DateTime(2026, 9, 6)), DateTime(2026, 8, 31));
    });

    test('weekStats sums Mon-Sun only, allStats sums everything', () async {
      final monday = mondayOfWeek(DateTime.now());
      await _seedRead(db, _fmt(monday), minutes: 10, ayahs: 5, hasanat: 50);
      await _seedRead(
        db,
        _fmt(monday.add(const Duration(days: 2))),
        minutes: 20,
        ayahs: 7,
        hasanat: 70,
      );
      // Outside this week: counts for all-time only.
      await _seedRead(
        db,
        _fmt(monday.subtract(const Duration(days: 10))),
        minutes: 30,
        ayahs: 9,
        hasanat: 90,
      );

      final container = ProviderContainer(
        overrides: [deenDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final week = await container.read(weekStatsProvider.future);
      expect(week.minutes, 30);
      expect(week.ayahs, 12);
      expect(week.hasanat, 120);

      final all = await container.read(allStatsProvider.future);
      expect(all.minutes, 60);
      expect(all.ayahs, 21);
      expect(all.hasanat, 210);
    });

    test('weekStats is zero with no rows', () async {
      final container = ProviderContainer(
        overrides: [deenDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final week = await container.read(weekStatsProvider.future);
      expect(week.minutes, 0);
      expect(week.ayahs, 0);
      expect(week.hasanat, 0);
    });
  });

  group('Ayah of the Day determinism (verbatim data, no generation)', () {
    // Obviously-fake fixtures: selection logic only, never displayed copy.
    List<QuranAyah> fakes(int n) => List.generate(
      n,
      (i) => QuranAyah(
        surahId: 1,
        ayahId: i + 1,
        arabic: 'test-ar-$i',
        english: 'test-en-$i',
      ),
    );

    test('same day always picks the same index in range', () async {
      final list = fakes(100);
      final container = ProviderContainer(
        overrides: [quranDataProvider.overrideWith((ref) async => list)],
      );
      addTearDown(container.dispose);

      final first = await container.read(ayahOfDayProvider.future);
      final now = DateTime.now();
      final dayOfYear =
          DateTime(
            now.year,
            now.month,
            now.day,
          ).difference(DateTime(now.year, 1, 1)).inDays +
          1;
      final expected = list[(dayOfYear - 1) % list.length];
      expect(first?.key, expected.key);

      container.invalidate(ayahOfDayProvider);
      final second = await container.read(ayahOfDayProvider.future);
      expect(second?.key, expected.key);
    });

    test('returns null when data is empty', () async {
      final container = ProviderContainer(
        overrides: [quranDataProvider.overrideWith((ref) async => const [])],
      );
      addTearDown(container.dispose);

      expect(await container.read(ayahOfDayProvider.future), isNull);
    });
  });

  group('Recent surahs (IDs only, max 3, most-recent-first)', () {
    test('push dedups, orders, and trims', () async {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [deenDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final push = container.read(pushRecentSurahProvider);
      await push(2);
      await push(36);
      await push(2);
      await push(67);
      await push(114);

      final recents = await container.read(recentSurahsProvider.future);
      expect(recents, [114, 67, 2]);
    });

    test('empty when nothing read yet', () async {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [deenDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      expect(await container.read(recentSurahsProvider.future), isEmpty);
    });
  });
}
