import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/database/deen_database.dart';
import '../../gamification/providers/gamification_providers.dart'
    show deenDatabaseProvider;
import '../data/quran_repository.dart';

// ---------------------------------------------------------------------------
// Quran data - verbatim bundled JSON
// ---------------------------------------------------------------------------

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final quranDataProvider = FutureProvider<List<QuranAyah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.loadQuran();
});

// ---------------------------------------------------------------------------
// Bookmarks - offline Drift
// ---------------------------------------------------------------------------

final bookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.bookmarks).watch();
});

// Helper Set<String> "surah:ayah" for fast isBookmarked check
final bookmarkedKeysProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(bookmarksProvider);
  final list = async.valueOrNull ?? const <Bookmark>[];
  return {for (final b in list) '${b.surahId}:${b.ayahId}'};
});

// Toggle helper - exposed via provider for testability and UI.
final toggleBookmarkProvider =
    Provider<
      Future<void> Function({required int surahId, required int ayahId})
    >((ref) {
      return ({required int surahId, required int ayahId}) async {
        final db = ref.read(deenDatabaseProvider);
        final existing =
            await (db.select(db.bookmarks)
                  ..where((t) => t.surahId.equals(surahId))
                  ..where((t) => t.ayahId.equals(ayahId)))
                .getSingleOrNull();
        if (existing != null) {
          await (db.delete(
            db.bookmarks,
          )..where((t) => t.id.equals(existing.id))).go();
        } else {
          await db
              .into(db.bookmarks)
              .insert(
                BookmarksCompanion.insert(surahId: surahId, ayahId: ayahId),
              );
        }
      };
    });

// ---------------------------------------------------------------------------
// LastRead - single row id=1
// ---------------------------------------------------------------------------

final lastReadProvider = StreamProvider<LastReadData?>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return (db.select(
    db.lastRead,
  )..where((t) => t.id.equals(1))).watchSingleOrNull();
});

final updateLastReadProvider =
    Provider<
      Future<void> Function({required int surahId, required int ayahId})
    >((ref) {
      return ({required int surahId, required int ayahId}) async {
        final db = ref.read(deenDatabaseProvider);
        await db
            .into(db.lastRead)
            .insertOnConflictUpdate(
              LastReadCompanion.insert(
                id: const Value(1),
                surahId: surahId,
                ayahId: ayahId,
                updatedAt: Value(DateTime.now()),
              ),
            );
      };
    });
