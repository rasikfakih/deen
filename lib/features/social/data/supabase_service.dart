import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // ignore: prefer_initializing_formals
  SupabaseService({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get client {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isConfigured => client != null;

  Future<User?> signInAnonymously() async {
    final c = client;
    if (c == null) return null;
    final res = await c.auth.signInAnonymously();
    return res.user;
  }

  Future<void> signInWithOtp(String email) async {
    final c = client;
    if (c == null) return;
    await c.auth.signInWithOtp(email: email);
  }

  Future<void> signOut() async {
    final c = client;
    if (c == null) return;
    await c.auth.signOut();
  }

  Stream<AuthState> get authStateChanges {
    final c = client;
    if (c == null) return const Stream.empty();
    return c.auth.onAuthStateChange;
  }

  User? get currentUser => client?.auth.currentUser;

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<Map<String, dynamic>> createCircle(String name) async {
    final c = client;
    if (c == null) throw StateError('Supabase not configured');
    final userId = c.auth.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');
    final code = generateInviteCode();
    final row = await c
        .from('circles')
        .insert({'name': name, 'invite_code': code, 'created_by': userId})
        .select()
        .single();
    await c.from('circle_members').insert({
      'circle_id': row['id'],
      'user_id': userId,
    });
    return row;
  }

  Future<void> joinCircle(String inviteCode) async {
    final c = client;
    if (c == null) throw StateError('Supabase not configured');
    final userId = c.auth.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');
    final code = inviteCode.trim().toUpperCase();
    if (code.length != 6) {
      throw ArgumentError('Invite code must be 6 characters');
    }
    final circle = await c
        .from('circles')
        .select('id')
        .eq('invite_code', code)
        .maybeSingle();
    if (circle == null) throw StateError('Circle not found for code $code');
    final circleId = circle['id'] as String;
    await c.from('circle_members').insert({
      'circle_id': circleId,
      'user_id': userId,
    });
  }

  static const _weekColumns =
      'user_id, total_minutes, total_ayahs, total_hasanat, current_streak, profiles!inner(display_name)';
  static const _weekColumnsLegacy =
      'user_id, total_minutes, total_ayahs, profiles!inner(display_name)';

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(
    String circleId,
  ) async {
    final c = client;
    if (c == null) return [];
    // Current week Monday
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekStr =
        '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

    final rows = await _selectWeekly(c, weekStr);
    return await _filterToCircle(c, circleId, rows, 'total_minutes');
  }

  /// Weekly select with graceful fallback when the leaderboard-scope
  /// migration is not applied yet (missing columns -> legacy select,
  /// missing keys normalized to 0 by callers).
  Future<List<dynamic>> _selectWeekly(SupabaseClient c, String weekStr) async {
    try {
      return await c
              .from('weekly_stats')
              .select(_weekColumns)
              .eq('week_start_date', weekStr)
              .order('total_minutes', ascending: false)
          as List;
    } catch (_) {
      return await c
              .from('weekly_stats')
              .select(_weekColumnsLegacy)
              .eq('week_start_date', weekStr)
              .order('total_minutes', ascending: false)
          as List;
    }
  }

  /// Today tab: daily_stats rows for the current date. Empty when the
  /// table is missing (pre-push backend) — callers show Sync CTA.
  Future<List<Map<String, dynamic>>> getTodayLeaderboard(
    String circleId,
  ) async {
    final c = client;
    if (c == null) return [];
    try {
      final now = DateTime.now();
      final dayStr =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final rows =
          await c
                  .from('daily_stats')
                  .select(
                    'user_id, total_minutes, total_ayahs, total_hasanat, profiles!inner(display_name)',
                  )
                  .eq('date', dayStr)
                  .order('total_minutes', ascending: false)
              as List;
      return await _filterToCircle(c, circleId, rows, 'total_minutes');
    } catch (_) {
      return [];
    }
  }

  /// All-time tab: sums every weekly row per member client-side.
  /// Streak shown is each member's max stored weekly streak.
  Future<List<Map<String, dynamic>>> getAllTimeLeaderboard(
    String circleId,
  ) async {
    final c = client;
    if (c == null) return [];
    try {
      List<dynamic> rows;
      try {
        rows =
            await c
                    .from('weekly_stats')
                    .select(_weekColumns)
                    .order('total_minutes', ascending: false)
                as List;
      } catch (_) {
        rows =
            await c
                    .from('weekly_stats')
                    .select(_weekColumnsLegacy)
                    .order('total_minutes', ascending: false)
                as List;
      }
      final members = await c
          .from('circle_members')
          .select('user_id')
          .eq('circle_id', circleId);
      final memberIds = {
        for (final m in members as List) m['user_id'] as String,
      };
      final totals = <String, Map<String, dynamic>>{};
      for (final r in rows) {
        final map = r as Map<String, dynamic>;
        final uid = map['user_id'] as String;
        if (!memberIds.contains(uid)) continue;
        final agg = totals.putIfAbsent(
          uid,
          () => {
            'user_id': uid,
            'display_name': _displayNameOf(map),
            'total_minutes': 0,
            'total_ayahs': 0,
            'total_hasanat': 0,
            'current_streak': 0,
          },
        );
        agg['total_minutes'] =
            (agg['total_minutes'] as int) + (map['total_minutes'] as int? ?? 0);
        agg['total_ayahs'] =
            (agg['total_ayahs'] as int) + (map['total_ayahs'] as int? ?? 0);
        agg['total_hasanat'] =
            (agg['total_hasanat'] as int) + (map['total_hasanat'] as int? ?? 0);
        final streak = map['current_streak'] as int? ?? 0;
        if (streak > (agg['current_streak'] as int)) {
          agg['current_streak'] = streak;
        }
      }
      final out = totals.values.toList()
        ..sort(
          (a, b) =>
              (b['total_minutes'] as int).compareTo(a['total_minutes'] as int),
        );
      return out;
    } catch (_) {
      return [];
    }
  }

  static String _displayNameOf(Map<String, dynamic> row) {
    final profiles = row['profiles'];
    if (profiles is Map && profiles['display_name'] != null) {
      return profiles['display_name'] as String;
    }
    return (row['user_id'] as String).substring(0, 6);
  }

  /// Filters weekly/daily rows to circle members and re-sorts.
  /// Missing numeric keys (pre-push backends) normalize to 0.
  Future<List<Map<String, dynamic>>> _filterToCircle(
    SupabaseClient c,
    String circleId,
    List<dynamic> rows,
    String orderKey,
  ) async {
    // Filter to members of the circle: fetch member ids first
    final members = await c
        .from('circle_members')
        .select('user_id')
        .eq('circle_id', circleId);
    final memberIds = {for (final m in members as List) m['user_id'] as String};

    final filtered = rows.where((r) {
      final map = r as Map<String, dynamic>;
      return memberIds.contains(map['user_id'] as String);
    }).toList();

    // Already ordered by total_minutes desc from query, but after filtering re-sort
    filtered.sort(
      (a, b) => ((b as Map<String, dynamic>)[orderKey] as int? ?? 0).compareTo(
        ((a as Map<String, dynamic>)[orderKey] as int? ?? 0),
      ),
    );
    return filtered.cast<Map<String, dynamic>>();
  }
}
