import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/database/database_providers.dart';
import '../../../shared/database/deen_database.dart';
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

// ---------------------------------------------------------------------------
// Recent surahs - last 3 read surah IDs in SettingsCache (local only).
// IDs only, no names: surah metadata ships in R1.5 (DEEN 8.2).
// ---------------------------------------------------------------------------

const _recentSurahsKey = 'recent_surahs';
const _recentSurahsMax = 3;

/// Most-recent-first surah IDs, max 3. Empty when nothing read yet.
final recentSurahsProvider = FutureProvider<List<int>>((ref) async {
  final db = ref.watch(deenDatabaseProvider);
  final row = await (db.select(
    db.settingsCache,
  )..where((t) => t.key.equals(_recentSurahsKey))).getSingleOrNull();
  final raw = row?.value;
  if (raw == null || raw.isEmpty) return const <int>[];
  try {
    final decoded = jsonDecode(raw) as List;
    return decoded.whereType<int>().take(_recentSurahsMax).toList();
  } catch (_) {
    return const <int>[];
  }
});

final pushRecentSurahProvider = Provider<Future<void> Function(int surahId)>((
  ref,
) {
  return (int surahId) async {
    final db = ref.read(deenDatabaseProvider);
    final row = await (db.select(
      db.settingsCache,
    )..where((t) => t.key.equals(_recentSurahsKey))).getSingleOrNull();
    var ids = <int>[];
    if (row?.value != null && row!.value!.isNotEmpty) {
      try {
        ids = (jsonDecode(row.value!) as List).whereType<int>().toList();
      } catch (_) {
        ids = <int>[];
      }
    }
    ids.remove(surahId);
    ids.insert(0, surahId);
    final trimmed = ids.take(_recentSurahsMax).toList();
    await db
        .into(db.settingsCache)
        .insertOnConflictUpdate(
          SettingsCacheCompanion.insert(
            key: _recentSurahsKey,
            value: Value(jsonEncode(trimmed)),
          ),
        );
    ref.invalidate(recentSurahsProvider);
  };
});

// ---------------------------------------------------------------------------
// Ayah of the Day - deterministic pick from verified data (DEEN 3).
// Index = (dayOfYear - 1) % ayahs.length. Verbatim ayah, no generation.
// ---------------------------------------------------------------------------

final ayahOfDayProvider = FutureProvider<QuranAyah?>((ref) async {
  final ayahs = await ref.watch(quranDataProvider.future);
  if (ayahs.isEmpty) return null;
  final now = DateTime.now();
  final dayOfYear =
      DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(now.year, 1, 1)).inDays +
      1;
  return ayahs[(dayOfYear - 1) % ayahs.length];
});
