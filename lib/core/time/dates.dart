import 'package:nm_flat/core/time/clock.dart';

abstract final class Dates {
  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}';

  static DateTime parse(String s) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  static String today(Clock c) => iso(c.now());

  static String addDays(String s, int n) {
    final d = parse(s);
    return iso(DateTime(d.year, d.month, d.day + n));
  }

  /// b - a, DST-safe
  static int daysBetween(String a, String b) {
    final x = parse(a);
    final y = parse(b);
    return DateTime.utc(y.year, y.month, y.day)
        .difference(DateTime.utc(x.year, x.month, x.day))
        .inDays;
  }

  static int weekdayIso(String s) => parse(s).weekday; // 1 = Mon … 7 = Sun
  static String month(String s) => s.substring(0, 7); // 'YYYY-MM'
  static String monthStart(String yyyyMm) => '$yyyyMm-01';

  static int daysInMonth(String yyyyMm) {
    final p = yyyyMm.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1] + 1, 0).day;
  }

  static String addMonths(String yyyyMm, int n) {
    final p = yyyyMm.split('-').map(int.parse).toList();
    final d = DateTime(p[0], p[1] + n);
    return '${d.year}-${_pad2(d.month)}';
  }

  static String dateOfMs(int ms) =>
      iso(DateTime.fromMillisecondsSinceEpoch(ms));

  static int msAt(String date, int minutesOfDay) {
    final d = parse(date);
    return DateTime(
      d.year,
      d.month,
      d.day,
      minutesOfDay ~/ 60,
      minutesOfDay % 60,
    ).millisecondsSinceEpoch;
  }

  static String _pad2(int v) => v.toString().padLeft(2, '0');
}
