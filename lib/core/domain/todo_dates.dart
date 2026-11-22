import 'package:nm_flat/core/time/dates.dart';

enum TodoGroup { overdue, today, tomorrow, later }

TodoGroup todoGroup(String due, String today) {
  final diff = Dates.daysBetween(today, due);
  if (diff < 0) return TodoGroup.overdue;
  if (diff == 0) return TodoGroup.today;
  if (diff == 1) return TodoGroup.tomorrow;
  return TodoGroup.later;
}

({String today, String tomorrow, String weekend, String nextWeek}) whenDates(
  String today,
) {
  final wIso = Dates.weekdayIso(today);
  var toSat = (6 - wIso) % 7;
  if (toSat <= 0) toSat += 7;
  return (
    today: today,
    tomorrow: Dates.addDays(today, 1),
    weekend: Dates.addDays(today, toSat),
    nextWeek: Dates.addDays(today, 7),
  );
}
