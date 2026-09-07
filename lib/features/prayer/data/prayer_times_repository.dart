import 'package:adhan/adhan.dart';

/// Simple Hijri date (arithmetical / tabular calendar).
/// True Hijri months begin with the sighted crescent (Umm al-Qura calendar),
/// so this can differ by ±1-2 days from observed dates. It is a display
/// approximation only — never used for religious rulings.
/// Uses the standard Gregorian→JDN→Islamic tabular conversion
/// (30-year leap cycle: years 2,5,7,10,13,16,18,21,24,26,29), which stays
/// offline with zero dependencies.
class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  /// Arithmetical conversion from Gregorian to Hijri (tabular calendar).
  /// Accurate to ±1-2 days vs observed (moon-sighting) dates.
  /// Known anchors: 2024-03-11 → 1445-09-01, 2025-03-01 → 1446-09-01.
  factory HijriDate.fromGregorian(DateTime gregorian) {
    final jd = _gregorianToJdn(gregorian.year, gregorian.month, gregorian.day);
    return _jdnToHijri(jd);
  }

  /// Julian Day Number for a Gregorian date (integer, noon-based).
  static int _gregorianToJdn(int y, int m, int d) {
    final a = (14 - m) ~/ 12;
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d +
        ((153 * mm + 2) ~/ 5) +
        365 * yy +
        (yy ~/ 4) -
        (yy ~/ 100) +
        (yy ~/ 400) -
        32045;
  }

  /// Tabular Islamic date from Julian Day Number.
  static HijriDate _jdnToHijri(int jd) {
    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j =
        ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l =
        l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;
    return HijriDate(year: year, month: month, day: day);
  }

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Structured prayer times for a single day.
class DeenPrayerTimes {
  const DeenPrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.coordinates,
    required this.calculationMethod,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime date; // Gregorian date (midnight local)
  final HijriDate hijriDate;
  final Coordinates coordinates;
  final CalculationMethod calculationMethod;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  List<({String name, DateTime time})> get ordered => [
    (name: 'Fajr', time: fajr),
    (name: 'Sunrise', time: sunrise),
    (name: 'Dhuhr', time: dhuhr),
    (name: 'Asr', time: asr),
    (name: 'Maghrib', time: maghrib),
    (name: 'Isha', time: isha),
  ];
}

class NextPrayer {
  const NextPrayer({required this.name, required this.time});

  final String name;
  final DateTime time;
}

class PrayerTimesRepository {
  /// Default params per task spec: Muslim World League + Hanafi Asr.
  /// Now accepts CalculationMethod from Settings - recalculates when method changes.
  CalculationParameters _paramsFor(CalculationMethod method) {
    final params = method.getParameters();
    params.madhab = Madhab.hanafi;
    return params;
  }

  DeenPrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
  }) {
    final coords = Coordinates(latitude, longitude);
    final components = DateComponents(date.year, date.month, date.day);
    final params = _paramsFor(method);
    final times = PrayerTimes(coords, components, params);
    // times are in local timezone automatically via CalendarUtil
    return DeenPrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      hijriDate: HijriDate.fromGregorian(date),
      coordinates: coords,
      calculationMethod: method,
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
    );
  }

  /// Returns next upcoming prayer relative to [now]. Wraps to next day Fajr if after Isha.
  NextPrayer getNextPrayer({
    required DeenPrayerTimes times,
    required DateTime now,
  }) {
    for (final entry in times.ordered) {
      // Skip Sunrise for next-prayer logic? Task lists Fajr..Isha inclusive,
      // but typically next prayer excludes Sunrise. Include for completeness
      // and filter if needed. We'll include Sunrise so before Dhuhr returns Dhuhr correctly,
      // and after Isha wraps to next Fajr. To match expected "before Dhuhr → Dhuhr",
      // we keep Sunrise in ordering.
      if (now.isBefore(entry.time)) {
        return NextPrayer(name: entry.name, time: entry.time);
      }
    }
    // After Isha → next day Fajr (preserve calculation method)
    final tomorrow = times.date.add(const Duration(days: 1));
    final nextTimes = getPrayerTimes(
      latitude: times.coordinates.latitude,
      longitude: times.coordinates.longitude,
      date: tomorrow,
      method: times.calculationMethod,
    );
    return NextPrayer(name: 'Fajr', time: nextTimes.fajr);
  }
}
