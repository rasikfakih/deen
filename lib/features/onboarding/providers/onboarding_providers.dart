import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gamification/providers/gamification_providers.dart';

/// True if SettingsCache has_completed_onboarding == 'true'.
final hasCompletedOnboardingProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(deenDatabaseProvider);
  return db.select(db.settingsCache).watch().map((rows) {
    final row = rows.where((r) => r.key == 'has_completed_onboarding').toList();
    if (row.isEmpty) return false;
    return row.first.value == 'true';
  });
});
