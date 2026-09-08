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
      final todayStr =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      // Sum week minutes/ayahs from DailyReads where date >= monday
      final weekReads = await (db.select(
        db.dailyReads,
      )..where((t) => t.date.isBiggerOrEqualValue(weekStr))).get();
      final totalMinutes = weekReads.fold<int>(0, (s, r) => s + r.minutesRead);
      final totalAyahs = weekReads.fold<int>(0, (s, r) => s + r.ayahsRead);
      final totalHasanat = weekReads.fold<int>(
        0,
        (s, r) => s + r.hasanatEarned,
      );
      // Max-merge: read the cloud row first and write per-column maxima so
      // a stale device never clobbers higher totals from another device.
      // Missing table/columns (pre-push backend) fall back to plain upsert.
      try {
        final remote = await client
            .from('weekly_stats')
            .select('total_minutes, total_ayahs, total_hasanat, current_streak')
            .eq('user_id', userId)
            .eq('week_start_date', weekStr)
            .maybeSingle();
        int remoteMinutes = 0;
        int remoteAyahs = 0;
        int remoteHasanat = 0;
        int remoteStreak = 0;
        if (remote != null) {
          remoteMinutes = remote['total_minutes'] as int? ?? 0;
          remoteAyahs = remote['total_ayahs'] as int? ?? 0;
          remoteHasanat = remote['total_hasanat'] as int? ?? 0;
          remoteStreak = remote['current_streak'] as int? ?? 0;
        }
        final payload = {
          'user_id': userId,
          'week_start_date': weekStr,
          'total_minutes': totalMinutes > remoteMinutes
              ? totalMinutes
              : remoteMinutes,
          'total_ayahs': totalAyahs > remoteAyahs ? totalAyahs : remoteAyahs,
          'total_hasanat': totalHasanat > remoteHasanat
              ? totalHasanat
              : remoteHasanat,
          'current_streak': streak.currentStreak > remoteStreak
              ? streak.currentStreak
              : remoteStreak,
        };
        try {
          await client.from('weekly_stats').upsert(payload);
        } catch (_) {
          // Pre-push backend without new columns: legacy payload.
          await client.from('weekly_stats').upsert({
            'user_id': userId,
            'week_start_date': weekStr,
            'total_minutes': payload['total_minutes'],
            'total_ayahs': payload['total_ayahs'],
          });
        }
      } catch (_) {}

      // Daily row for the Today tab (max-merged the same way).
      final today = await db.getDailyReadByDate(todayStr);
      if (today != null) {
        try {
          final remoteDay = await client
              .from('daily_stats')
              .select('total_minutes, total_ayahs, total_hasanat')
              .eq('user_id', userId)
              .eq('date', todayStr)
              .maybeSingle();
          final rMin = remoteDay?['total_minutes'] as int? ?? 0;
          final rAyah = remoteDay?['total_ayahs'] as int? ?? 0;
          final rHas = remoteDay?['total_hasanat'] as int? ?? 0;
          await client.from('daily_stats').upsert({
            'user_id': userId,
            'date': todayStr,
            'total_minutes': today.minutesRead > rMin
                ? today.minutesRead
                : rMin,
            'total_ayahs': today.ayahsRead > rAyah ? today.ayahsRead : rAyah,
            'total_hasanat': today.hasanatEarned > rHas
                ? today.hasanatEarned
                : rHas,
          });
        } catch (_) {}
      }
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

    // Conflict resolution is local-first: DailyReads/Streaks computed on-device
    // by GamificationRepository are authoritative (offline-first, DEEN 4).
    // weekly_stats in Supabase is a read-only aggregate mirror for family
    // leaderboards — we never overwrite the local streak from it (the table
    // has total_minutes/total_ayahs only, no streak column). Highest-streak
    // logic lives in checkAndUpdateStreak, not here.
    try {
      await client
          .from('weekly_stats')
          .select('total_minutes, total_ayahs, week_start_date')
          .eq('user_id', userId)
          .maybeSingle();
      // Intentionally no local write: cloud aggregate is for leaderboards.
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
