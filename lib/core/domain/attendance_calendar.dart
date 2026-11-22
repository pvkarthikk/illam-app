import 'dart:math';

import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/time/dates.dart';

enum CellKind { worked, absent, leave, off, beforeStart, upcoming, notMarkedYet }

class DayCell {
  const DayCell(
    this.date,
    this.kind,
    this.minutes,
    this.intensity,
    this.isToday,
  );

  final String date;
  final CellKind kind;
  final int minutes;
  final double intensity;
  final bool isToday;
}

DayCell cellFor({
  required String date,
  required String today,
  required List<int> workDays,
  required String? startDate,
  required String? endDate,
  required List<VisitLite> visits,
  required bool leave,
  required int nowMs,
}) {
  final isToday = date == today;
  final afterStart = startDate == null || date.compareTo(startDate) >= 0;
  final beforeEnd = endDate == null || date.compareTo(endDate) <= 0;
  final employed = afterStart && beforeEnd;
  final workDay = workDays.contains(Dates.weekdayIso(date));

  if (date.compareTo(today) > 0) {
    return DayCell(
      date,
      employed && workDay ? CellKind.upcoming : CellKind.off,
      0,
      0,
      isToday,
    );
  }
  if (visits.isNotEmpty) {
    final minutes = liveMinutes(visits, nowMs);
    final intensity = min(1.0, 0.25 + minutes / 240);
    return DayCell(date, CellKind.worked, minutes, intensity, isToday);
  }
  if (leave) return DayCell(date, CellKind.leave, 0, 0, isToday);
  if (!afterStart) return DayCell(date, CellKind.beforeStart, 0, 0, isToday);
  if (!beforeEnd) return DayCell(date, CellKind.off, 0, 0, isToday);
  if (workDay && date.compareTo(today) < 0) {
    return DayCell(date, CellKind.absent, 0, 0, isToday);
  }
  if (workDay && isToday) {
    return DayCell(date, CellKind.notMarkedYet, 0, 0, isToday);
  }
  return DayCell(date, CellKind.off, 0, 0, isToday);
}

class MonthStats {
  const MonthStats(this.present, this.absent, this.hours);
  final int present;
  final int absent;
  final double hours;
}

MonthStats statsFor(
  List<DayCell> cells,
  Map<String, List<VisitLite>> visitsByDate,
) {
  var present = 0;
  var absent = 0;
  var totalMinutes = 0;

  for (final cell in cells) {
    if (cell.kind == CellKind.worked) {
      present++;
    } else if (cell.kind == CellKind.absent) {
      absent++;
    }
    totalMinutes += mergedMinutes(visitsByDate[cell.date] ?? const []);
  }
  return MonthStats(present, absent, totalMinutes / 60);
}
