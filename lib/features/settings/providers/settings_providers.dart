import 'package:adhan/adhan.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/database/deen_database.dart';
import '../../gamification/providers/gamification_providers.dart';

final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.settingsCache).watch().map((rows) {
    final row = rows.where((r) => r.key == 'theme_mode').toList();
    if (row.isEmpty || row.first.value == null) return ThemeMode.system;
    final v = row.first.value!;
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  });
});

final elderlyModeProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.settingsCache).watch().map((rows) {
    final row = rows.where((r) => r.key == 'elderly_mode').toList();
    if (row.isEmpty) return false;
    return row.first.value == 'true';
  });
});

final prayerMethodProvider = StreamProvider<CalculationMethod>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.settingsCache).watch().map((rows) {
    final row = rows.where((r) => r.key == 'prayer_method').toList();
    if (row.isEmpty || row.first.value == null) {
      return CalculationMethod.muslim_world_league;
    }
    final v = row.first.value!;
    switch (v) {
      case 'north_america':
        return CalculationMethod.north_america;
      case 'egyptian':
        return CalculationMethod.egyptian;
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura;
      case 'karachi':
        return CalculationMethod.karachi;
      default:
        return CalculationMethod.muslim_world_league;
    }
  });
});

Future<void> saveThemeMode(WidgetRef ref, ThemeMode mode) async {
  final db = ref.read(deenDatabaseProvider);
  final value = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
  await db
      .into(db.settingsCache)
      .insertOnConflictUpdate(
        SettingsCacheCompanion.insert(key: 'theme_mode', value: Value(value)),
      );
}

Future<void> saveElderlyMode(WidgetRef ref, bool enabled) async {
  final db = ref.read(deenDatabaseProvider);
  await db
      .into(db.settingsCache)
      .insertOnConflictUpdate(
        SettingsCacheCompanion.insert(
          key: 'elderly_mode',
          value: Value(enabled ? 'true' : 'false'),
        ),
      );
}

Future<void> savePrayerMethod(WidgetRef ref, CalculationMethod method) async {
  final db = ref.read(deenDatabaseProvider);
  await db
      .into(db.settingsCache)
      .insertOnConflictUpdate(
        SettingsCacheCompanion.insert(
          key: 'prayer_method',
          value: Value(method.name),
        ),
      );
}

final dailyReminderTimeProvider = StreamProvider<TimeOfDay?>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.settingsCache).watch().map((rows) {
    final row = rows.where((r) => r.key == 'daily_reminder_time').toList();
    if (row.isEmpty || row.first.value == null) return null;
    final parts = row.first.value!.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  });
});

Future<void> saveDailyReminderTime(WidgetRef ref, TimeOfDay time) async {
  final db = ref.read(deenDatabaseProvider);
  final value =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  await db
      .into(db.settingsCache)
      .insertOnConflictUpdate(
        SettingsCacheCompanion.insert(
          key: 'daily_reminder_time',
          value: Value(value),
        ),
      );
}
