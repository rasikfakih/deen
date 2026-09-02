import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _methodName(CalculationMethod m) {
    switch (m) {
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League';
      case CalculationMethod.north_america:
        return 'ISNA (North America)';
      case CalculationMethod.egyptian:
        return 'Egypt';
      case CalculationMethod.umm_al_qura:
        return 'Makkah (Umm Al Qura)';
      case CalculationMethod.karachi:
        return 'Karachi';
      default:
        return m.name;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeModeProvider);
    final elderlyAsync = ref.watch(elderlyModeProvider);
    final methodAsync = ref.watch(prayerMethodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        children: [
          Text('Appearance', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          themeAsync.when(
            data: (mode) => DropdownButtonFormField<ThemeMode>(
              initialValue: mode,
              decoration: const InputDecoration(
                labelText: 'Theme Mode',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) {
                if (v != null) saveThemeMode(ref, v);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Error loading theme'),
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          elderlyAsync.when(
            data: (enabled) => SwitchListTile(
              title: Text('Elderly Mode', style: AppTypography.titleMedium),
              subtitle: Text(
                'Increases text size by 20 percent and reduces motion',
                style: AppTypography.bodySmall,
              ),
              value: enabled,
              onChanged: (v) => saveElderlyMode(ref, v),
            ),
            loading: () => const SwitchListTile(
              title: Text('Elderly Mode'),
              value: false,
              onChanged: null,
            ),
            error: (_, _) => const Text('Error loading elderly mode'),
          ),
          const Divider(height: AppSpacing.spaceXL),
          Text('Prayer', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          methodAsync.when(
            data: (method) => DropdownButtonFormField<CalculationMethod>(
              initialValue: method,
              decoration: const InputDecoration(
                labelText: 'Calculation Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: CalculationMethod.muslim_world_league,
                  child: Text('Muslim World League'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.north_america,
                  child: Text('ISNA'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.egyptian,
                  child: Text('Egypt'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.umm_al_qura,
                  child: Text('Makkah'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.karachi,
                  child: Text('Karachi'),
                ),
              ],
              onChanged: (v) {
                if (v != null) savePrayerMethod(ref, v);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Error loading method'),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Current: ${methodAsync.valueOrNull != null ? _methodName(methodAsync.valueOrNull!) : ''}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          Text('About', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Deen is free forever, no ads, offline first. Your data stays on your device.',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
