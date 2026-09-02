import 'package:drift/drift.dart';

import '../../../shared/database/deen_database.dart';
import 'supabase_service.dart';

class SyncRepository {
  SyncRepository(this.db, this.service);

  final DeenDatabase db;
  final SupabaseService service;

  Future<void> pushLocalDataToCloud() async {
    final client = service.client;
    if (client == null) return;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    // Profiles: upsert display_name from SettingsCache user_name
    final nameRow = await (db.select(
      db.settingsCache,
    )..where((t) => t.key.equals('user_name'))).getSingleOrNull();
    final displayName = nameRow?.value;
    if (displayName != null && displayName.isNotEmpty) {
      try {
        await client.from('profiles').upsert({
          'id': userId,
          'display_name': displayName,
        });
      } catch (_) {}
    }

    // Streaks: push highest streak
    final streak = await db.streak;
    if (streak != null) {
      // For weekly stats, aggregate current week minutes/ayahs
      final now = DateTime.now();
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final weekStr =
          '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      // Sum week minutes/ayahs from DailyReads where date >= monday
      final weekReads = await (db.select(
        db.dailyReads,
      )..where((t) => t.date.isBiggerOrEqualValue(weekStr))).get();
      final totalMinutes = weekReads.fold<int>(0, (s, r) => s + r.minutesRead);
      final totalAyahs = weekReads.fold<int>(0, (s, r) => s + r.ayahsRead);
      try {
        await client.from('weekly_stats').upsert({
          'user_id': userId,
          'week_start_date': weekStr,
          'total_minutes': totalMinutes,
          'total_ayahs': totalAyahs,
        });
      } catch (_) {}
    }

    // Bookmarks: upsert each
    final bookmarks = await db.select(db.bookmarks).get();
    for (final b in bookmarks) {
      try {
        // Assuming a Supabase table bookmarks exists; if not, ignore
        await client.from('bookmarks').upsert({
          'id': b.id,
          'user_id': userId,
          'surah_id': b.surahId,
          'ayah_id': b.ayahId,
        });
      } catch (_) {}
    }
  }

  Future<void> pullCloudDataToLocal() async {
    final client = service.client;
    if (client == null) return;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final remote = await client
          .from('weekly_stats')
          .select('total_minutes, total_ayahs, week_start_date')
          .eq('user_id', userId)
          .maybeSingle();
      if (remote != null) {
        // Example merge: take highest streak via separate table if exists
        // For now, handle streaks table if a remote streaks table were present
        // This is a placeholder for conflict resolution: highest streak wins
        final remoteStreak = remote['streak'] as int?;
        if (remoteStreak != null) {
          final local = await db.streak;
          if (local != null && remoteStreak > local.currentStreak) {
            await (db.update(
              db.streaks,
            )..where((t) => t.id.equals(local.id))).write(
              StreaksCompanion(
                currentStreak: Value(remoteStreak),
                longestStreak: Value(remoteStreak),
              ),
            );
          }
        }
      }
    } catch (_) {}

    // Bookmarks pull
    try {
      final rows = await client
          .from('bookmarks')
          .select('surah_id, ayah_id')
          .eq('user_id', userId);
      for (final r in rows as List) {
        final surahId = r['surah_id'] as int;
        final ayahId = r['ayah_id'] as int;
        final existing =
            await (db.select(db.bookmarks)
                  ..where((t) => t.surahId.equals(surahId))
                  ..where((t) => t.ayahId.equals(ayahId)))
                .getSingleOrNull();
        if (existing == null) {
          await db
              .into(db.bookmarks)
              .insert(
                BookmarksCompanion.insert(surahId: surahId, ayahId: ayahId),
              );
        }
      }
    } catch (_) {}
  }
}
