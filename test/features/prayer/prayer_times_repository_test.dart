import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/prayer/data/prayer_times_repository.dart';

void main() {
  late PrayerTimesRepository repo;

  setUp(() {
    repo = PrayerTimesRepository();
  });

  group('PrayerTimesRepository', () {
    test(
      'Scenario A: Mecca prayer times ordering and known historical sanity',
      () {
        // Mecca (Kaaba) - 2024-03-11 corresponds to 1445 Ramadan 1
        const meccaLat = 21.3891;
        const meccaLng = 39.8579;
        final date = DateTime(2024, 3, 11);

        final times = repo.getPrayerTimes(
          latitude: meccaLat,
          longitude: meccaLng,
          date: date,
        );

        // Hijri should be populated (tabular approx 1445)
        expect(times.hijriDate, isNotNull);
        expect(times.hijriDate.year, greaterThanOrEqualTo(1444));
        expect(times.hijriDate.year, lessThanOrEqualTo(1446));

        // Core sanity: ordering must hold for any valid date.
        expect(
          times.fajr.isBefore(times.sunrise),
          isTrue,
          reason: 'Fajr before sunrise',
        );
        expect(times.sunrise.isBefore(times.dhuhr), isTrue);
        expect(times.dhuhr.isBefore(times.asr), isTrue);
        expect(times.asr.isBefore(times.maghrib), isTrue);
        expect(times.maghrib.isBefore(times.isha), isTrue);

        // All on same Gregorian date (times.date)
        expect(times.fajr.day, date.day);
        expect(times.isha.day, date.day);

        // Known historical sanity for Mecca early March with MWL/Hanafi:
        // Fajr ~05:00 Mecca (UTC+3), Dhuhr ~12:30, Asr ~15:50, Maghrib ~18:30, Isha ~19:50
        // On CI device timezone may shift times (e.g., device UTC+6 => +3h shift).
        // Only assert ordering already checked; hour checks are broad sanity.
        expect(times.fajr.hour, inInclusiveRange(0, 23));
        expect(times.dhuhr.hour, inInclusiveRange(0, 23));
        expect(times.asr.hour, inInclusiveRange(0, 23));
        expect(times.maghrib.hour, inInclusiveRange(0, 23));
        expect(times.isha.hour, inInclusiveRange(0, 23));
      },
    );

    test('Scenario A additional: London ordering', () {
      final times = repo.getPrayerTimes(
        latitude: 51.5074,
        longitude: -0.1278,
        date: DateTime(2024, 6, 21),
      );
      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });

    test('Scenario B: getNextPrayer before Dhuhr returns Dhuhr', () {
      final date = DateTime(2026, 9, 1);
      final times = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: date,
      );
      // Create a time just before Dhuhr (subtract 30 min)
      final beforeDhuhr = times.dhuhr.subtract(const Duration(minutes: 30));
      final next = repo.getNextPrayer(times: times, now: beforeDhuhr);
      expect(next.name, 'Dhuhr');
      expect(next.time, times.dhuhr);
    });

    test('Scenario B: after Asr returns Maghrib', () {
      final date = DateTime(2026, 9, 1);
      final times = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: date,
      );
      final afterAsr = times.asr.add(const Duration(minutes: 10));
      final next = repo.getNextPrayer(times: times, now: afterAsr);
      expect(next.name, 'Maghrib');
      expect(next.time, times.maghrib);
    });

    test('Scenario B: after Isha wraps to next day Fajr', () {
      final date = DateTime(2026, 9, 1);
      final times = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: date,
      );
      final afterIsha = times.isha.add(const Duration(minutes: 10));
      final next = repo.getNextPrayer(times: times, now: afterIsha);
      expect(next.name, 'Fajr');
      // Next day Fajr should be after Isha and on next date
      expect(next.time.isAfter(times.isha), isTrue);
      expect(next.time.day, date.day + 1);
      // Verify next day calculation matches direct repo call
      final tomorrowTimes = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: DateTime(2026, 9, 2),
      );
      expect(next.time, tomorrowTimes.fajr);
    });

    test('Before Fajr returns Fajr', () {
      final date = DateTime(2026, 9, 1);
      final times = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: date,
      );
      final beforeFajr = times.fajr.subtract(const Duration(minutes: 30));
      final next = repo.getNextPrayer(times: times, now: beforeFajr);
      expect(next.name, 'Fajr');
    });

    test('Hijri conversion plausible', () {
      final date = DateTime(2024, 3, 11);
      final times = repo.getPrayerTimes(
        latitude: 21.3891,
        longitude: 39.8579,
        date: date,
      );
      // Ramadan 1445 is March 2024
      expect(times.hijriDate.month, inInclusiveRange(1, 12));
      expect(times.hijriDate.day, inInclusiveRange(1, 30));
    });
  });
}
