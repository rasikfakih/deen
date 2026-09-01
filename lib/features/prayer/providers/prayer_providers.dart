import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/location_service.dart';
import '../data/prayer_times_repository.dart';

// Repositories
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>(
  (ref) => PrayerTimesRepository(),
);

/// Ticking clock — every minute, for nextPrayer countdown.
/// Starts immediately with current time.
final clockProvider = StreamProvider<DateTime>((ref) {
  // Emit now immediately, then every minute.
  final controller = StreamController<DateTime>();
  controller.add(DateTime.now());
  final timer = Timer.periodic(const Duration(minutes: 1), (_) {
    controller.add(DateTime.now());
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Current location — never throws, falls back to Mecca.
final currentLocationProvider = FutureProvider<AppLocation>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentLocation();
});

/// Today's prayer times — depends on location, offline via adhan.
/// Invalidate at midnight to fetch new day (handled via clock watch).
final prayerTimesProvider = FutureProvider<DeenPrayerTimes>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  // Watch clock to auto-refresh at midnight — rebuild when date changes.
  final clockAsync = ref.watch(clockProvider);
  final now = clockAsync.value ?? DateTime.now();
  final repo = ref.watch(prayerTimesRepositoryProvider);
  return repo.getPrayerTimes(
    latitude: location.latitude,
    longitude: location.longitude,
    date: DateTime(now.year, now.month, now.day),
  );
});

/// Family for testing specific date/location.
final prayerTimesForDateProvider =
    FutureProvider.family<
      DeenPrayerTimes,
      ({double lat, double lng, DateTime date})
    >((ref, args) {
      final repo = ref.watch(prayerTimesRepositoryProvider);
      return Future.value(
        repo.getPrayerTimes(
          latitude: args.lat,
          longitude: args.lng,
          date: args.date,
        ),
      );
    });

/// Next prayer — depends on prayerTimes + clock, updates every minute.
final nextPrayerProvider = Provider<AsyncValue<NextPrayer>>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  // Also watch clock so this provider rebuilds every minute.
  final clockAsync = ref.watch(clockProvider);
  final now = clockAsync.value ?? DateTime.now();

  return timesAsync.whenData((times) {
    final repo = ref.watch(prayerTimesRepositoryProvider);
    return repo.getNextPrayer(times: times, now: now);
  });
});
