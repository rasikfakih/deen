import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../shared/database/deen_database.dart';

/// GDPR export/delete — local-first, offline, no network.
///
/// Reads/wipes the Drift tables only. Cloud rows (Supabase) are removed on
/// next sync by sign-out; users can also request server deletion via support.
/// Never logs verse content or search text — export stays on-device.
class DataExportService {
  DataExportService(this.db);

  final DeenDatabase db;

  /// Collects all user data as a JSON-encodable map.
  Future<Map<String, Object?>> collectExport() async {
    final goals = await db.select(db.userGoals).get();
    final reads = await db.select(db.dailyReads).get();
    final streaks = await db.select(db.streaks).get();
    final settings = await db.select(db.settingsCache).get();
    final bookmarks = await db.select(db.bookmarks).get();
    final lastRead = await db.select(db.lastRead).get();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'Deen',
      'userGoals': [
        for (final g in goals)
          {
            'id': g.id,
            'dailyTargetMinutes': g.dailyTargetMinutes,
            'dailyTargetAyahs': g.dailyTargetAyahs,
            'isActive': g.isActive,
          },
      ],
      'dailyReads': [
        for (final r in reads)
          {
            'date': r.date,
            'minutesRead': r.minutesRead,
            'ayahsRead': r.ayahsRead,
            'hasanatEarned': r.hasanatEarned,
          },
      ],
      'streaks': [
        for (final s in streaks)
          {
            'currentStreak': s.currentStreak,
            'longestStreak': s.longestStreak,
            'availableFreezes': s.availableFreezes,
            'lastReadDate': s.lastReadDate,
          },
      ],
      'bookmarks': [
        for (final b in bookmarks) {'surahId': b.surahId, 'ayahId': b.ayahId},
      ],
      'lastRead': [
        for (final l in lastRead) {'surahId': l.surahId, 'ayahId': l.ayahId},
      ],
      // Settings excluding nothing — all keys are non-sensitive prefs.
      'settings': {for (final s in settings) s.key: s.value},
    };
  }

  /// Writes the export to `<docs>/deen-export-<date>.json` and returns it.
  Future<File> exportToFile() async {
    final data = await collectExport();
    final dir = await getApplicationDocumentsDirectory();
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final file = File(p.join(dir.path, 'deen-export-$date.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  /// Deletes ALL local user data (GDPR "delete my data").
  /// Clears goals, reads, streaks, bookmarks, last-read, and settings
  /// (including onboarding flag, so the app returns to onboarding).
  Future<void> deleteAllLocalData() async {
    await db.delete(db.dailyReads).go();
    await db.delete(db.streaks).go();
    await db.delete(db.userGoals).go();
    await db.delete(db.bookmarks).go();
    await db.delete(db.lastRead).go();
    await db.delete(db.settingsCache).go();
  }
}
