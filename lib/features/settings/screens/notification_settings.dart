import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/notification_service.dart';
import '../providers/settings_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAsync = ref.watch(dailyReminderTimeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        children: [
          Text('Daily Reading Reminder', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          timeAsync.when(
            data: (time) => ListTile(
              title: Text(
                time == null
                    ? 'No reminder set'
                    : 'Reminder at ${time.format(context)}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
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
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Error loading time'),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'You will receive a daily notification at your chosen time. You can disable it by clearing the time in Settings.',
            style: AppTypography.bodySmall.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await NotificationService.instance.cancelAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications cancelled'),
                    ),
                  );
                }
              },
              child: const Text('Cancel All Notifications'),
            ),
          ),
        ],
      ),
    );
  }
}
