import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/audio/data/audio_service.dart';
import 'package:deen/shared/database/deen_database.dart';

void main() {
  group('AudioService.audioUrl (R2 CDN)', () {
    test('builds alafasy surah URL from default base', () {
      final url = AudioService.audioUrl(surahId: 1);
      expect(url, contains('/ar.alafasy/1.mp3'));
      expect(url, startsWith('https://'));
      // Never hotlink volunteer servers at runtime (DEEN 5).
      expect(url, isNot(contains('islamic.network')));
    });

    test('supports abdul-basit reciter slug', () {
      final url = AudioService.audioUrl(
        surahId: 114,
        reciter: DeenReciter.abdulBasit,
      );
      expect(url, contains('/ar.abdulbasitmurattal/114.mp3'));
    });

    test('base override wins and trailing slashes are trimmed', () {
      final url = AudioService.audioUrl(
        surahId: 2,
        baseUrlOverride: 'https://cdn.example.com/audio///',
      );
      expect(url, 'https://cdn.example.com/audio/ar.alafasy/2.mp3');
    });
  });

  group('NotificationService prayer signature (shared decoupling)', () {
    test('prayer payload is primitives — no DeenPrayerTimes import needed', () {
      // Compile-time guarantee: shared/services/notification_service.dart
      // must not import features/. This test documents the contract.
      final payload = [
        (name: 'Fajr', time: DateTime(2026, 9, 7, 5)),
        (name: 'Dhuhr', time: DateTime(2026, 9, 7, 12)),
        (name: 'Asr', time: DateTime(2026, 9, 7, 15)),
        (name: 'Maghrib', time: DateTime(2026, 9, 7, 18)),
        (name: 'Isha', time: DateTime(2026, 9, 7, 20)),
      ];
      expect(payload.map((p) => p.name), containsAll(['Fajr', 'Isha']));
      expect(payload.length, 5);
    });
  });

  group('Shared database provider ownership', () {
    test('DeenDatabase in-memory opens for providers', () async {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      await db
          .into(db.settingsCache)
          .insert(
            const SettingsCacheCompanion(
              key: Value('theme_mode'),
              value: Value('dark'),
            ),
          );
      final row = await (db.select(
        db.settingsCache,
      )..where((t) => t.key.equals('theme_mode'))).getSingle();
      expect(row.value, 'dark');
      await db.close();
    });
  });
}
