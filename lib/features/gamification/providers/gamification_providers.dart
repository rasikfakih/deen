import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/database/deen_database.dart';
import '../data/gamification_repository.dart';

/// Single database instance for the app (offline-first).
/// Heavy DB work off main isolate is handled inside NativeDatabase.createInBackground.
final deenDatabaseProvider = Provider<DeenDatabase>((ref) {
  final db = DeenDatabase();
  ref.onDispose(() async {
    await db.close();
  });
  return db;
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return GamificationRepository(db);
});

/// Stream of current streak row - UI can listen for changes.
final streakStreamProvider = StreamProvider<Streak?>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  // Watch single row id=1; if table empty, emit null then created.
  return (db.select(
    db.streaks,
  )..where((t) => t.id.equals(1))).watchSingleOrNull();
});

/// Stream of today's DailyReads - UI can listen for progress ring.
final todayProgressProvider = StreamProvider<DailyRead?>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  final today = _formatDate(DateTime.now());
  return (db.select(
    db.dailyReads,
  )..where((t) => t.date.equals(today))).watchSingleOrNull();
});

/// Manual provider for testing with specific date.
final todayProgressForDateProvider = StreamProvider.family<DailyRead?, String>((
  ref,
  dateStr,
) {
  final db = ref.watch(deenDatabaseProvider);
  return (db.select(
    db.dailyReads,
  )..where((t) => t.date.equals(dateStr))).watchSingleOrNull();
});

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
