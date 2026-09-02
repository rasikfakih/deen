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

    final rows = await c
        .from('weekly_stats')
        .select(
          'user_id, total_minutes, total_ayahs, profiles!inner(display_name)',
        )
        .eq('week_start_date', weekStr)
        .order('total_minutes', ascending: false);

    // Filter to members of the circle: fetch member ids first
    final members = await c
        .from('circle_members')
        .select('user_id')
        .eq('circle_id', circleId);
    final memberIds = {for (final m in members as List) m['user_id'] as String};

    final filtered = (rows as List)
        .where((r) => memberIds.contains(r['user_id'] as String))
        .toList();

    // Already ordered by total_minutes desc from query, but after filtering re-sort
    filtered.sort(
      (a, b) =>
          (b['total_minutes'] as int).compareTo(a['total_minutes'] as int),
    );
    return filtered.cast<Map<String, dynamic>>();
  }
}
