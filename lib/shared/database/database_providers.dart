import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'deen_database.dart';

/// Single database instance for the app (offline-first).
/// Owned by shared — features import this, never define their own.
/// Heavy DB work off main isolate is handled inside NativeDatabase.createInBackground.
final deenDatabaseProvider = Provider<DeenDatabase>((ref) {
  final db = DeenDatabase();
  ref.onDispose(() async {
    await db.close();
  });
  return db;
});
