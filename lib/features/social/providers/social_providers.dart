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
