import 'package:nm_flat/core/time/dates.dart';

enum ReminderKind { arrival, digest, bill, evening }

class StaffInfo {
  const StaffInfo({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.active,
    required this.workDays,
    required this.expectedTimes,
  });

  final String id;
  final String name;
  final String startDate;
  final String? endDate;
  final bool active;
  final List<int> workDays;
  final List<String> expectedTimes;
}

class BillInfo {
  const BillInfo({
    required this.id,
    required this.name,
    required this.method,
    required this.dueDate,
    required this.firstDueMonth,
    required this.usualPaise,
    required this.active,
    required this.remind,
    required this.paidThisMonth,
  });

  final String id;
  final String name;
  final String method;
  final String dueDate;
  final String firstDueMonth;
  final int usualPaise;
  final bool active;
  final bool remind;
  final bool paidThisMonth;
}

class ReminderInputs {
  const ReminderInputs({
    required this.today,
    required this.now,
    required this.staff,
    required this.visitStartsToday,
    required this.onLeaveToday,
    required this.dueCount,
    required this.dueTitles,
    required this.bills,
    required this.iAddedSpendToday,
    required this.arrivalOn,
    required this.digestOn,
    required this.billOn,
    required this.eveningOn,
  });

  final String today;
  final DateTime now;
  final List<StaffInfo> staff;
  final Map<String, List<DateTime>> visitStartsToday;
  final Set<String> onLeaveToday;
  final int dueCount;
  final List<String> dueTitles;
  final List<BillInfo> bills;
  final bool iAddedSpendToday;
  final bool arrivalOn;
  final bool digestOn;
  final bool billOn;
  final bool eveningOn;
}

class PlannedReminder {
  const PlannedReminder(this.key, this.kind, this.at, this.data);

  final String key;
  final ReminderKind kind;
  final DateTime at;
  final Map<String, Object> data;
}

bool inQuietHours(DateTime t) => t.hour >= 22 || t.hour < 7;

List<PlannedReminder> planToday(ReminderInputs i) {
  final out = <PlannedReminder>[];
  final day = Dates.parse(i.today);
  final weekday = day.weekday;
  final month = Dates.month(i.today);

  if (i.arrivalOn) {
    for (final s in i.staff) {
      if (!s.active) continue;
      if (s.startDate.compareTo(i.today) > 0) continue;
      final end = s.endDate;
      if (end != null && end.isNotEmpty && end.compareTo(i.today) < 0) continue;
      if (!s.workDays.contains(weekday)) continue;
      if (i.onLeaveToday.contains(s.id)) continue;

      final starts = i.visitStartsToday[s.id] ?? const <DateTime>[];
      for (final e in s.expectedTimes) {
        final parts = e.split(':');
        if (parts.length != 2) continue;
        final h = int.tryParse(parts[0].trim());
        final m = int.tryParse(parts[1].trim());
        if (h == null || m == null) continue;
        final expectedAt = DateTime(day.year, day.month, day.day, h, m);
        final within2h = starts.any(
          (v) =>
              v.difference(expectedAt).inMilliseconds.abs() <=
              const Duration(hours: 2).inMilliseconds,
        );
        if (within2h) continue;
        final hhmm = e.replaceAll(':', '');
        out.add(
          PlannedReminder(
            'arrival:${s.id}:${i.today}:$hhmm',
            ReminderKind.arrival,
            expectedAt.add(const Duration(minutes: 15)),
            {'staffId': s.id, 'name': s.name, 'time': e},
          ),
        );
      }
    }
  }

  if (i.digestOn && i.dueCount > 0) {
    out.add(
      PlannedReminder(
        'digest:${i.today}',
        ReminderKind.digest,
        DateTime(day.year, day.month, day.day, 8, 0),
        {'count': i.dueCount, 'titles': i.dueTitles},
      ),
    );
  }

  if (i.billOn) {
    for (final b in i.bills) {
      if (!b.active || !b.remind || b.paidThisMonth) continue;
      if (b.firstDueMonth.compareTo(month) > 0) continue;
      if (b.dueDate != i.today) continue;
      out.add(
        PlannedReminder(
          'bill:${b.id}:${i.today}',
          ReminderKind.bill,
          DateTime(day.year, day.month, day.day, 10, 0),
          {
            'billId': b.id,
            'name': b.name,
            'usual': b.usualPaise,
            'method': b.method,
          },
        ),
      );
    }
  }

  if (i.eveningOn && !i.iAddedSpendToday) {
    out.add(
      PlannedReminder(
        'evening:${i.today}',
        ReminderKind.evening,
        DateTime(day.year, day.month, day.day, 21, 0),
        const <String, Object>{},
      ),
    );
  }

  out.sort((a, b) {
    final c = a.at.compareTo(b.at);
    return c != 0 ? c : a.key.compareTo(b.key);
  });
  return out;
}

bool stillValid(PlannedReminder r, ReminderInputs fresh) {
  if ((r.kind == ReminderKind.digest || r.kind == ReminderKind.evening) &&
      inQuietHours(fresh.now)) {
    return false;
  }
  return planToday(fresh).any((p) => p.key == r.key);
}
