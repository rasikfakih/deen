import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/database/deen_database.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../data/supabase_service.dart';
import '../data/sync_repository.dart';

final supabaseServiceProvider = Provider<SupabaseService>(
  (ref) => SupabaseService(),
);

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  final service = ref.watch(supabaseServiceProvider);
  return SyncRepository(db, service);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.currentUser;
});

/// Auto-sync on auth upgrade: when user signs in with OTP (Guest -> Email),
/// silently push local data to cloud. Keeps streak and name backed up.
final autoSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
    final prevUser = prev?.valueOrNull?.session?.user;
    final nextUser = next.valueOrNull?.session?.user;
    if (nextUser != null && nextUser.id != prevUser?.id) {
      // Trigger silent push on any new sign-in / upgrade
      final syncRepo = ref.read(syncRepositoryProvider);
      // ignore: discarded_futures
      syncRepo.pushLocalDataToCloud();
    }
  });
  return;
});

final weeklyLeaderboardProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      circleId,
    ) async {
      final service = ref.watch(supabaseServiceProvider);
      final db = ref.watch(deenDatabaseProvider);
      final cacheKey = 'last_leaderboard_$circleId';
      final timeKey = '${cacheKey}_time';
      try {
        final rows = await service.getWeeklyLeaderboard(circleId);
        // Cache successful fetch for offline use
        final jsonStr = jsonEncode(rows);
        final nowIso = DateTime.now().toIso8601String();
        await db
            .into(db.settingsCache)
            .insertOnConflictUpdate(
              SettingsCacheCompanion.insert(
                key: cacheKey,
                value: Value(jsonStr),
              ),
            );
        await db
            .into(db.settingsCache)
            .insertOnConflictUpdate(
              SettingsCacheCompanion.insert(key: timeKey, value: Value(nowIso)),
            );
        return rows;
      } catch (_) {
        // Offline: try cached
        final cached = await (db.select(
          db.settingsCache,
        )..where((t) => t.key.equals(cacheKey))).getSingleOrNull();
        if (cached?.value != null) {
          try {
            final decoded = jsonDecode(cached!.value!) as List;
            return decoded.cast<Map<String, dynamic>>();
          } catch (_) {}
        }
        rethrow;
      }
    });

/// My circles for the Home card (CTO-approved, graceful guest/offline).
/// Returns [{id, name}] for circles the current user joined.
/// Empty when signed out, unconfigured, offline, or member of none.
final myCirclesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(supabaseServiceProvider);
  final c = service.client;
  if (c == null) return const [];
  final userId = c.auth.currentUser?.id;
  if (userId == null) return const [];
  try {
    final rows = await c
        .from('circle_members')
        .select('circle_id, joined_at, circles(id, name)')
        .eq('user_id', userId)
        .order('joined_at', ascending: false);
    final result = <Map<String, dynamic>>[];
    for (final r in rows as List) {
      final circle = r['circles'];
      if (circle is Map) {
        result.add({
          'id': circle['id'],
          'name': circle['name'] ?? 'Family circle',
        });
      }
    }
    return result;
  } catch (_) {
    return const [];
  }
});

/// Member count for one circle. Zero on any failure (offline/guest).
final circleMemberCountProvider = FutureProvider.family<int, String>((
  ref,
  circleId,
) async {
  final service = ref.watch(supabaseServiceProvider);
  final c = service.client;
  if (c == null) return 0;
  try {
    final rows = await c
        .from('circle_members')
        .select('user_id')
        .eq('circle_id', circleId);
    return (rows as List).length;
  } catch (_) {
    return 0;
  }
});

/// Returns human readable "Last updated X ago" for cached leaderboard.
final lastLeaderboardUpdatedProvider = FutureProvider.family<String?, String>((
  ref,
  circleId,
) async {
  final db = ref.watch(deenDatabaseProvider);
  final timeKey = 'last_leaderboard_${circleId}_time';
  final row = await (db.select(
    db.settingsCache,
  )..where((t) => t.key.equals(timeKey))).getSingleOrNull();
  if (row?.value == null) return null;
  try {
    final updated = DateTime.parse(row!.value!);
    final diff = DateTime.now().difference(updated);
    if (diff.inMinutes < 1) return 'Last updated just now';
    if (diff.inMinutes < 60) return 'Last updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last updated ${diff.inHours}h ago';
    return 'Last updated ${diff.inDays}d ago';
  } catch (_) {
    return null;
  }
});
