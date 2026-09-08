import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/database/database_providers.dart';
import '../../prayer/data/prayer_times_repository.dart';

/// Design v3 Home stats (DEEN 8.2). Sums of verified DailyReads rows only.

enum StatsRange { today, week, all }

final statsRangeProvider = StateProvider<StatsRange>((ref) => StatsRange.today);

class DayTotals {
  const DayTotals({
    required this.minutes,
    required this.ayahs,
    required this.hasanat,
  });

  final int minutes;
  final int ayahs;
  final int hasanat;

  DayTotals operator +(DayTotals other) => DayTotals(
    minutes: minutes + other.minutes,
    ayahs: ayahs + other.ayahs,
    hasanat: hasanat + other.hasanat,
  );
}

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  return '$y-$m-${d.day.toString().padLeft(2, '0')}';
}

/// Monday of the week containing [now] (1 Mon .. 7 Sun).
DateTime mondayOfWeek(DateTime now) {
  final date = DateTime(now.year, now.month, now.day);
  return date.subtract(Duration(days: now.weekday - 1));
}

const _gregorianMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Header subline: numeric Hijri (tabular, display approximation) plus
/// Gregorian date, e.g. "1447-09-01 • 18 Feb 2026". Hijri stays numeric:
/// month names wait for verified metadata (DEEN 8.2).
String hijriGregorianLabel(DateTime now) {
  final h = HijriDate.fromGregorian(now);
  final hy = h.year.toString().padLeft(4, '0');
  final hm = h.month.toString().padLeft(2, '0');
  final hd = h.day.toString().padLeft(2, '0');
  final gm = _gregorianMonths[now.month - 1];
  return '$hy-$hm-$hd • ${now.day} $gm ${now.year}';
}

/// Sums DailyReads for Monday..Sunday of the current week.
final weekStatsProvider = FutureProvider<DayTotals>((ref) async {
  final db = ref.watch(deenDatabaseProvider);
  final monday = mondayOfWeek(DateTime.now());
  var total = const DayTotals(minutes: 0, ayahs: 0, hasanat: 0);
  for (var i = 0; i < 7; i++) {
    final read = await db.getDailyReadByDate(
      _fmtDate(monday.add(Duration(days: i))),
    );
    if (read != null) {
      total += DayTotals(
        minutes: read.minutesRead,
        ayahs: read.ayahsRead,
        hasanat: read.hasanatEarned,
      );
    }
  }
  return total;
});

/// Sums DailyReads across all time.
final allStatsProvider = FutureProvider<DayTotals>((ref) async {
  final db = ref.watch(deenDatabaseProvider);
  final rows = await db.select(db.dailyReads).get();
  var total = const DayTotals(minutes: 0, ayahs: 0, hasanat: 0);
  for (final r in rows) {
    total += DayTotals(
      minutes: r.minutesRead,
      ayahs: r.ayahsRead,
      hasanat: r.hasanatEarned,
    );
  }
  return total;
});
