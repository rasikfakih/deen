import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_providers.dart';
import '../database/deen_database.dart';

/// Global display preferences — owned by shared so glass widgets,
/// main.dart, and all features can watch without feature-to-feature imports.
///
/// Backed by SettingsCache; written from Settings / onboarding.
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
