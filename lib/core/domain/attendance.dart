import 'dart:math';

import 'package:nm_flat/core/time/dates.dart';

const kMaxVisitMs = 16 * 3600 * 1000;
const kMemberWindowMs = 48 * 3600 * 1000;

class VisitLite {
  const VisitLite({
    required this.id,
    required this.date,
    required this.inAt,
    this.outAt,
  });

  final String id;
  final String date;
  final int inAt;
  final int? outAt;

  bool get isOpen => outAt == null;
}

sealed class StaffStatus {
  const StaffStatus();
}

class StatusLeave extends StaffStatus {
  const StatusLeave();
}

class StatusIn extends StaffStatus {
  const StatusIn(this.sinceMs);
  final int sinceMs;
}

class StatusDone extends StaffStatus {
  const StatusDone(this.totalMinutes, this.lastOutMs);
  final int totalMinutes;
  final int lastOutMs;
}

class StatusExpected extends StaffStatus {
  const StatusExpected();
}

class StatusOff extends StaffStatus {
  const StatusOff();
}

StaffStatus staffStatusToday({
  required String today,
  required List<int> workDays,
  required List<VisitLite> visitsToday,
  required bool leaveToday,
}) {
  if (leaveToday) return const StatusLeave();

  VisitLite? newestOpen;
  for (final v in visitsToday) {
    if (v.isOpen && (newestOpen == null || v.inAt > newestOpen.inAt)) {
      newestOpen = v;
    }
  }
  if (newestOpen != null) return StatusIn(newestOpen.inAt);

  if (visitsToday.isNotEmpty) {
    var lastOut = 0;
    for (final v in visitsToday) {
      final out = v.outAt;
      if (out != null && out > lastOut) lastOut = out;
    }
    return StatusDone(mergedMinutes(visitsToday), lastOut);
  }

  return workDays.contains(Dates.weekdayIso(today))
      ? const StatusExpected()
      : const StatusOff();
}

int mergedMinutes(List<VisitLite> visits) => _unionMinutes([
  for (final v in visits)
    if (v.outAt != null && v.outAt! > v.inAt) (v.inAt, v.outAt!),
]);

int liveMinutes(List<VisitLite> visits, int nowMs) => _unionMinutes([
  for (final v in visits)
    if ((v.outAt ?? nowMs) > v.inAt) (v.inAt, v.outAt ?? nowMs),
]);

int _unionMinutes(List<(int, int)> intervals) {
  if (intervals.isEmpty) return 0;
  intervals.sort((a, b) {
    final cmp = a.$1.compareTo(b.$1);
    return cmp != 0 ? cmp : a.$2.compareTo(b.$2);
  });

  var curStart = intervals.first.$1;
  var curEnd = intervals.first.$2;
  var totalMs = 0;

  for (var i = 1; i < intervals.length; i++) {
    final (start, end) = intervals[i];
    if (start <= curEnd) {
      curEnd = max(curEnd, end);
    } else {
      totalMs += curEnd - curStart;
      curStart = start;
      curEnd = end;
    }
  }
  totalMs += curEnd - curStart;
  return totalMs ~/ 60000;
}

enum VisitError { missingIn, outNotAfterIn, tooLong, memberTooOld }

bool canMemberTouchVisit({
  required bool isAdmin,
  required int nowMs,
  int? oldInAt,
  int? newInAt,
}) {
  if (isAdmin) return true;
  if (oldInAt != null && (nowMs - oldInAt).abs() > kMemberWindowMs) {
    return false;
  }
  if (newInAt != null && (nowMs - newInAt).abs() > kMemberWindowMs) {
    return false;
  }
  return true;
}

VisitError? validateVisit({
  required int? inAt,
  required int? outAt,
  required bool isAdmin,
  required int nowMs,
  int? oldInAt,
}) {
  if (inAt == null) return VisitError.missingIn;
  if (outAt != null && outAt <= inAt) return VisitError.outNotAfterIn;
  if (outAt != null && outAt - inAt > kMaxVisitMs) return VisitError.tooLong;
  if (!canMemberTouchVisit(
    isAdmin: isAdmin,
    nowMs: nowMs,
    oldInAt: oldInAt,
    newInAt: inAt,
  )) {
    return VisitError.memberTooOld;
  }
  return null;
}

bool canTouchLeave({
  required bool isAdmin,
  required String date,
  required String today,
}) => isAdmin || date == today || date == Dates.addDays(today, -1);

VisitLite? firstOverlap(
  List<VisitLite> others, {
  required int inAt,
  int? outAt,
  required int nowMs,
  String? ignoreId,
}) {
  final aEnd = outAt ?? nowMs;
  VisitLite? earliest;
  for (final b in others) {
    if (ignoreId != null && b.id == ignoreId) continue;
    final bEnd = b.outAt ?? nowMs;
    if (inAt < bEnd && b.inAt < aEnd) {
      if (earliest == null || b.inAt < earliest.inAt) {
        earliest = b;
      }
    }
  }
  return earliest;
}

sealed class AttendanceAlert {
  const AttendanceAlert(this.date);
  final String date;
}

class NotMarkedOut extends AttendanceAlert {
  const NotMarkedOut(super.date);
}

class TwoOpenVisits extends AttendanceAlert {
  const TwoOpenVisits(super.date);
}

List<AttendanceAlert> alertsFor({
  required List<VisitLite> openVisits,
  required String today,
}) {
  final byDate = <String, List<VisitLite>>{};
  for (final v in openVisits) {
    if (!v.isOpen) continue;
    byDate.putIfAbsent(v.date, () => []).add(v);
  }
  final dates = byDate.keys.toList()..sort();
  final out = <AttendanceAlert>[];
  for (final date in dates) {
    if (date.compareTo(today) < 0) {
      out.add(NotMarkedOut(date));
    }
    if ((byDate[date]?.length ?? 0) >= 2) {
      out.add(TwoOpenVisits(date));
    }
  }
  return out;
}
