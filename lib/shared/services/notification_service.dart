import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Schedules reminders 15 min before each prayer.
  /// Takes primitives (not DeenPrayerTimes) so shared never imports a feature.
  Future<void> schedulePrayerNotifications(
    List<({String name, DateTime time})> prayers,
  ) async {
    await init();
    // Cancel previous prayer notifications (ids 1-5)
    for (var i = 1; i <= 5; i++) {
      await _plugin.cancel(id: i);
    }
    final wanted = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};
    final filtered = prayers
        .where((p) => wanted.contains(p.name))
        .take(5)
        .toList();
    var id = 1;
    for (final p in filtered) {
      final scheduleTime = p.time.subtract(const Duration(minutes: 15));
      if (scheduleTime.isBefore(DateTime.now())) continue;
      final tzTime = tz.TZDateTime.from(scheduleTime, tz.local);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Times',
          channelDescription: 'Prayer time reminders 15 minutes before',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        id: id++,
        title: 'Prayer Reminder',
        body: '${p.name} in 15 minutes',
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> scheduleDailyReadingReminder(TimeOfDay time) async {
    await init();
    const id = 1001;
    await _plugin.cancel(id: id);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reading_channel',
        'Daily Reading',
        channelDescription: 'Daily Quran reading reminder',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id: id,
      title: 'Daily Reading',
      body: 'Time for your daily Quran',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
