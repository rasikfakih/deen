import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/settings/data/data_export_service.dart';
import 'package:deen/shared/database/deen_database.dart';

Future<DeenDatabase> _openDb() async {
  final db = DeenDatabase.forTesting(NativeDatabase.memory());
  await db
      .into(db.userGoals)
      .insert(
        UserGoalsCompanion.insert(
          dailyTargetAyahs: const Value(5),
          dailyTargetMinutes: const Value(15),
        ),
      );
  await db
      .into(db.dailyReads)
      .insert(
        DailyReadsCompanion.insert(
          date: '2026-09-07',
          minutesRead: const Value(10),
          ayahsRead: const Value(5),
          hasanatEarned: const Value(50),
        ),
      );
  await db
      .into(db.bookmarks)
      .insert(BookmarksCompanion.insert(surahId: 1, ayahId: 1));
  await db
      .into(db.settingsCache)
      .insert(
        const SettingsCacheCompanion(
          key: Value('theme_mode'),
          value: Value('dark'),
        ),
      );
  return db;
}

void main() {
  group('DataExportService (GDPR)', () {
    test('collectExport includes all tables', () async {
      final db = await _openDb();
      try {
        final data = await DataExportService(db).collectExport();
        expect((data['userGoals'] as List), hasLength(1));
        expect((data['dailyReads'] as List), hasLength(1));
        expect((data['bookmarks'] as List), hasLength(1));
        expect((data['settings'] as Map)['theme_mode'], 'dark');
        expect(data['app'], 'Deen');
      } finally {
        await db.close();
      }
    });

    test('deleteAllLocalData wipes everything', () async {
      final db = await _openDb();
      try {
        await DataExportService(db).deleteAllLocalData();
        expect(await db.select(db.userGoals).get(), isEmpty);
        expect(await db.select(db.dailyReads).get(), isEmpty);
        expect(await db.select(db.bookmarks).get(), isEmpty);
        expect(await db.select(db.settingsCache).get(), isEmpty);
        expect(await db.select(db.streaks).get(), isEmpty);
        expect(await db.select(db.lastRead).get(), isEmpty);
      } finally {
        await db.close();
      }
    });
  });
}
