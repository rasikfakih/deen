import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/notification_service.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/screen_insets.dart';
import '../../../shared/widgets/chrome/deen_app_bar.dart';
import '../../../shared/widgets/chrome/deen_chrome.dart';
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

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(dataExportServiceProvider);
      final file = await service.exportToFile();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export saved: ${file.path}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all my data?'),
        content: const Text(
          'This permanently deletes goals, reads, streaks, bookmarks, '
          'and settings on this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await NotificationService.instance.cancelAll();
    } catch (_) {}
    try {
      await ref.read(dataExportServiceProvider).deleteAllLocalData();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All local data deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeModeProvider);
    final elderlyAsync = ref.watch(elderlyModeProvider);
    final methodAsync = ref.watch(prayerMethodProvider);
    final analyticsAsync = ref.watch(analyticsOptInProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const DeenAppBar(title: 'Settings'),
      body: DeenChromeListener(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.spaceMD,
            topContentPad(context),
            AppSpacing.spaceMD,
            100,
          ),
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
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
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
            Text('Reminders', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            Consumer(
              builder: (context, ref, _) {
                final timeAsync = ref.watch(dailyReminderTimeProvider);
                return timeAsync.when(
                  data: (time) => ListTile(
                    title: Text(
                      time == null
                          ? 'Daily reading reminder'
                          : 'Daily reminder at ${time.format(context)}',
                    ),
                    subtitle: const Text('Tap to pick time'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            time ?? const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        await saveDailyReminderTime(ref, picked);
                        await NotificationService.instance
                            .scheduleDailyReadingReminder(picked);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reminder set for ${picked.format(context)}',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  loading: () =>
                      const ListTile(title: Text('Loading reminder')),
                  error: (_, _) =>
                      const ListTile(title: Text('Error loading reminder')),
                );
              },
            ),
            TextButton(
              onPressed: () => context.push('/notifications'),
              child: const Text('Open Notification Settings'),
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text('About', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Deen is free forever, no ads, offline first. Your data stays on your device.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.spaceLG),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/support'),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Support the App'),
              ),
            ),
            const Divider(height: AppSpacing.spaceXL),
            Text('Privacy & Data', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            analyticsAsync.when(
              data: (enabled) => SwitchListTile(
                title: Text(
                  'Analytics (opt-in)',
                  style: AppTypography.titleMedium,
                ),
                subtitle: Text(
                  'Minimal, anonymous. Never logs verses read or search text.',
                  style: AppTypography.bodySmall,
                ),
                value: enabled,
                onChanged: (v) => saveAnalyticsOptIn(ref, v),
              ),
              loading: () => const SwitchListTile(
                title: Text('Analytics (opt-in)'),
                value: false,
                onChanged: null,
              ),
              error: (_, _) => const Text('Error loading analytics setting'),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            OutlinedButton.icon(
              onPressed: () => _exportData(context, ref),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export my data'),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete my data',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
