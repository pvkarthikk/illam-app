import 'package:nm_flat/core/time/dates.dart';

String nextMonth(String m) => Dates.addMonths(m, 1);

String prevMonth(String m) => Dates.addMonths(m, -1);

List<String> salaryMonths({
  required String startDate,
  String? endDate,
  required String today,
}) {
  final startMonth = Dates.month(startDate);
  final currentMonth = Dates.month(today);
  final endCap = endDate == null
      ? currentMonth
      : (Dates.month(endDate).compareTo(currentMonth) < 0
            ? Dates.month(endDate)
            : currentMonth);

  if (startMonth.compareTo(endCap) > 0) return const [];

  final months = <String>[];
  var cur = startMonth;
  while (cur.compareTo(endCap) <= 0) {
    months.add(cur);
    cur = nextMonth(cur);
  }
  return months;
}

String defaultSalaryMonth({
  required String today,
  required List<String> months,
  required bool Function(String month) isSettled,
}) {
  final cur = Dates.month(today);
  final prev = prevMonth(cur);
  final dayOfMonth = Dates.parse(today).day;
  if (dayOfMonth <= 10 && months.contains(prev) && !isSettled(prev)) {
    return prev;
  }
  if (months.contains(cur)) {
    return cur;
  }
  return months.last;
}
