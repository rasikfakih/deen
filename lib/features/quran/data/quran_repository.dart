import 'dart:convert';

import 'package:flutter/services.dart';

/// Immutable Ayah with both verified texts — loaded verbatim via
/// `rootBundle.loadString` (never generated/rewritten per DEEN 3).
/// Surah = chapter, Ayah = verse. Holds Arabic Uthmani and English
/// Sahih International translation.
class QuranAyah {
  const QuranAyah({
    required this.surahId,
    required this.ayahId,
    required this.arabic,
    required this.english,
  });

  final int surahId;
  final int ayahId;
  final String arabic;
  final String english;

  String get key => '$surahId:$ayahId';
}

/// Loads verified Quran data from bundled assets.
/// Data files are checksummed by `scripts/verify_quran_integrity.dart`.
class QuranRepository {
  static const _arPath = 'assets/data/raw/quran_ar.json';
  static const _enPath = 'assets/data/raw/quran_en.json';

  List<QuranAyah>? _cache;

  /// Loads and parses both JSON files verbatim into memory.
  /// Returns cached list on subsequent calls.
  Future<List<QuranAyah>> loadQuran() async {
    if (_cache != null) return _cache!;
    final arStr = await rootBundle.loadString(_arPath);
    final enStr = await rootBundle.loadString(_enPath);
    // Preserve verbatim text exactly — no trimming beyond JSON parsing.
    final arJson = jsonDecode(arStr) as Map<String, dynamic>;
    final enJson = jsonDecode(enStr) as Map<String, dynamic>;
    final arList = arJson['quran'] as List<dynamic>;
    final enList = enJson['quran'] as List<dynamic>;
    if (arList.length != enList.length) {
      throw StateError(
        'Mismatched lengths ar=${arList.length} en=${enList.length}',
      );
    }
    final result = <QuranAyah>[];
    for (var i = 0; i < arList.length; i++) {
      final ar = arList[i] as Map<String, dynamic>;
      final en = enList[i] as Map<String, dynamic>;
      // Upstream is chapter/verse — map to surahId/ayahId per CTO.
      result.add(
        QuranAyah(
          surahId: ar['chapter'] as int,
          ayahId: ar['verse'] as int,
          arabic: ar['text'] as String,
          english: en['text'] as String,
        ),
      );
    }
    _cache = result;
    return result;
  }

  Future<List<QuranAyah>> loadSurah(int surahId) async {
    final all = await loadQuran();
    return all.where((e) => e.surahId == surahId).toList();
  }

  void clearCache() => _cache = null;
}
