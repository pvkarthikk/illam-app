import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/time/dates.dart';

/// Lightweight helper record used by the pure home-screen widget snapshot builder.
class StaffWidgetInput {
  const StaffWidgetInput({
    required this.id,
    required this.name,
    this.role = '',
    this.color = '#23503A',
    this.workDaysCsv = '1,2,3,4,5,6',
    this.expectedTimesCsv = '09:00',
    this.usualEndTime,
    this.workDaysOverride,
  });

  final String id;
  final String name;
  final String role;
  final String color;
  final String workDaysCsv;
  final String expectedTimesCsv;
  final String? usualEndTime;
  final List<int>? workDaysOverride;
}

/// Open/closed visit paired with its helper id for pure widget snapshot building.
class StaffVisitRecord {
  const StaffVisitRecord({required this.staffId, required this.visit});

  final String staffId;
  final VisitLite visit;
}

/// One helper row displayed in the Android Help at home widget.
class StaffWidgetItem {
  const StaffWidgetItem({
    required this.id,
    required this.name,
    required this.initial,
    required this.role,
    required this.colorHex,
    required this.status,
    required this.subtitle,
    required this.action,
    required this.actionLabel,
    this.openVisitId,
  });

  final String id;
  final String name;
  final String initial;
  final String role;
  final String colorHex;
  final String status;
  final String subtitle;
  final String action;
  final String actionLabel;
  final String? openVisitId;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'initial': initial,
    'role': role,
    'colorHex': colorHex,
    'status': status,
    'subtitle': subtitle,
    'action': action,
    'actionLabel': actionLabel,
    if (openVisitId != null) 'openVisitId': openVisitId,
  };
}

/// Complete snapshot payload consumed by the Android Help at home widget.
class StaffWidgetSnapshot {
  const StaffWidgetSnapshot({
    required this.hasHome,
    required this.homeName,
    required this.date,
    required this.items,
  });

  const StaffWidgetSnapshot.noHome({this.date = ''})
    : hasHome = false,
      homeName = '',
      items = const [];

  final bool hasHome;
  final String homeName;
  final String date;
  final List<StaffWidgetItem> items;

  Map<String, Object?> toJson() => {
    'hasHome': hasHome,
    'homeName': homeName,
    'date': date,
    'items': [for (final item in items) item.toJson()],
  };
}

/// Lightweight to-do input for pure widget snapshot building.
class TodoWidgetInput {
  const TodoWidgetInput({
    required this.id,
    required this.title,
    required this.due,
    this.assigneeType = 'member',
    this.assigneeId = '',
    this.assigneeName = '',
    this.done = false,
  });

  final String id;
  final String title;
  final String due;
  final String assigneeType;
  final String assigneeId;
  final String assigneeName;
  final bool done;
}

/// Lightweight routine input for pure widget snapshot building.
class RoutineWidgetInput {
  const RoutineWidgetInput({
    required this.id,
    required this.name,
    this.room = '',
    required this.lastDone,
    required this.everyDays,
    this.assigneeType = 'member',
    this.assigneeId = '',
    this.assigneeName = '',
  });

  final String id;
  final String name;
  final String room;
  final String lastDone;
  final int everyDays;
  final String assigneeType;
  final String assigneeId;
  final String assigneeName;
}

/// One due item (to-do or cleaning routine) rendered in the Due today widget.
class TodoWidgetItem {
  const TodoWidgetItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.meta,
    required this.overdue,
  });

  final String id;
  final String kind;
  final String title;
  final String meta;
  final bool overdue;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'meta': meta,
    'overdue': overdue,
  };
}

/// Complete snapshot payload consumed by the Android Due today widget.
class TodoWidgetSnapshot {
  const TodoWidgetSnapshot({
    required this.hasHome,
    required this.homeName,
    required this.date,
    required this.totalCount,
    required this.items,
  });

  const TodoWidgetSnapshot.noHome({this.date = ''})
    : hasHome = false,
      homeName = '',
      totalCount = 0,
      items = const [];

  final bool hasHome;
  final String homeName;
  final String date;
  final int totalCount;
  final List<TodoWidgetItem> items;

  Map<String, Object?> toJson() => {
    'hasHome': hasHome,
    'homeName': homeName,
    'date': date,
    'totalCount': totalCount,
    'items': [for (final item in items) item.toJson()],
  };
}

List<int> _parseWorkDays(String csv) {
  final out = <int>[];
  for (final part in csv.split(',')) {
    final v = int.tryParse(part.trim());
    if (v != null && v >= 1 && v <= 7) {
      out.add(v);
    }
  }
  return out;
}

List<String> _parseTimes(String csv) => [
  for (final s in csv.split(','))
    if (s.trim().isNotEmpty) s.trim(),
];

String _time12(DateTime t) {
  final period = t.hour >= 12 ? 'PM' : 'AM';
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute.toString().padLeft(2, '0');
  return '$h12:$mm $period';
}

String _time12Ms(int ms) =>
    _time12(DateTime.fromMillisecondsSinceEpoch(ms));

String _time12Of(String hhmm) {
  final p = hhmm.split(':');
  final h = p.isNotEmpty ? (int.tryParse(p[0].trim()) ?? 0) : 0;
  final m = p.length > 1 ? (int.tryParse(p[1].trim()) ?? 0) : 0;
  return _time12(DateTime(2026, 1, 1, h, m));
}

String _timesText(List<String> times, String? usualEnd) {
  if (times.isEmpty) return '';
  if (times.length == 1 && usualEnd != null && usualEnd.trim().isNotEmpty) {
    final start = _time12Of(times.first);
    final end = _time12Of(usualEnd);
    final sParts = start.split(' ');
    final eParts = end.split(' ');
    if (sParts.length == 2 && eParts.length == 2 && sParts[1] == eParts[1]) {
      return '${sParts[0]}\u2013$end';
    }
    return '$start\u2013$end';
  }
  return times.map(_time12Of).join(' & ');
}

String _durationText(int minutes) => minutes < 60
    ? '${minutes}m'
    : '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';

String _normalizeHex(String? raw) {
  if (raw == null) return '#23503A';
  final s = raw.trim();
  if (RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(s)) return s;
  if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(s)) return '#$s';
  return '#23503A';
}

String _initialOf(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return String.fromCharCode(t.runes.first).toUpperCase();
}

/// Builds a pure JSON-serializable snapshot for the Android Help at home widget.
StaffWidgetSnapshot buildStaffWidgetSnapshot({
  required bool hasHome,
  String homeName = '',
  required String today,
  required int nowMs,
  required List<StaffWidgetInput> staff,
  required List<StaffVisitRecord> visitsToday,
  required Set<String> leavesToday,
  Set<String> paidLeavesToday = const {},
}) {
  if (!hasHome) return StaffWidgetSnapshot.noHome(date: today);

  final items = <StaffWidgetItem>[];
  for (final s in staff) {
    final lites = <VisitLite>[
      for (final r in visitsToday)
        if (r.staffId == s.id) r.visit,
    ];
    final leave = leavesToday.contains(s.id);
    final paidLeave = paidLeavesToday.contains(s.id);
    final workDays = s.workDaysOverride ?? _parseWorkDays(s.workDaysCsv);
    final st = staffStatusToday(
      today: today,
      workDays: workDays,
      visitsToday: lites,
      leaveToday: leave,
      paidLeaveToday: paidLeave,
    );

    VisitLite? newestOpen;
    for (final v in lites) {
      if (v.isOpen && (newestOpen == null || v.inAt > newestOpen.inAt)) {
        newestOpen = v;
      }
    }

    final expected = _timesText(_parseTimes(s.expectedTimesCsv), s.usualEndTime);
    final (String statusKey, String subtitle, String action, String label) =
        switch (st) {
          StatusIn(:final sinceMs) => (
            'in',
            'In since ${_time12Ms(sinceMs)} \u00b7 ${_durationText(liveMinutes(lites, nowMs))}',
            'mark_out',
            'Mark out',
          ),
          StatusExpected() => (
            'expected',
            expected.isEmpty ? 'Expected today' : 'Expected $expected',
            'mark_in',
            'Mark in',
          ),
          StatusDone(:final totalMinutes, :final lastOutMs) => (
            'done',
            'Done ${_durationText(totalMinutes)} \u00b7 out ${_time12Ms(lastOutMs)}',
            'mark_in',
            '+ Visit',
          ),
          StatusLeave(:final paid) => (
            'leave',
            paid ? 'Paid leave today' : 'On leave today',
            'mark_in',
            'Mark in',
          ),
          StatusOff() => ('off', 'Day off', 'mark_in', 'Mark in'),
        };

    final displayName = s.name.trim().isEmpty ? 'Helper' : s.name.trim();
    items.add(
      StaffWidgetItem(
        id: s.id,
        name: displayName,
        initial: _initialOf(displayName),
        role: s.role.trim(),
        colorHex: _normalizeHex(s.color),
        status: statusKey,
        subtitle: subtitle,
        action: action,
        actionLabel: label,
        openVisitId: statusKey == 'in' ? newestOpen?.id : null,
      ),
    );
  }

  return StaffWidgetSnapshot(
    hasHome: true,
    homeName: homeName,
    date: today,
    items: items,
  );
}

/// Builds a pure JSON-serializable snapshot for the Android Due today widget.
TodoWidgetSnapshot buildTodoWidgetSnapshot({
  required bool hasHome,
  String homeName = '',
  required String today,
  required List<TodoWidgetInput> todos,
  required List<RoutineWidgetInput> routines,
  String? onlyMemberId,
  int maxItems = 25,
}) {
  if (!hasHome) return TodoWidgetSnapshot.noHome(date: today);

  final filterMine = onlyMemberId != null && onlyMemberId.isNotEmpty;
  final dueTodos = [
    for (final t in todos)
      if (!t.done &&
          (!filterMine ||
              (t.assigneeType == 'member' && t.assigneeId == onlyMemberId)) &&
          t.due.isNotEmpty &&
          Dates.daysBetween(t.due, today) >= 0)
        t,
  ]..sort((a, b) {
      final cmp = a.due.compareTo(b.due);
      return cmp != 0 ? cmp : a.title.compareTo(b.title);
    });

  final dueRoutines = <({RoutineWidgetInput row, RoutineState st})>[];
  for (final r in routines) {
    if (filterMine &&
        (r.assigneeType != 'member' || r.assigneeId != onlyMemberId)) {
      continue;
    }
    final st = routineState(
      lastDone: r.lastDone,
      everyDays: r.everyDays,
      today: today,
    );
    if (st.isDue) {
      dueRoutines.add((row: r, st: st));
    }
  }
  dueRoutines.sort((a, b) {
    final cmp = a.st.left.compareTo(b.st.left);
    return cmp != 0 ? cmp : a.row.name.compareTo(b.row.name);
  });

  final all = <TodoWidgetItem>[
    for (final t in dueTodos) ...[
      () {
        final overdue = Dates.daysBetween(t.due, today) > 0;
        final dueTag = overdue ? 'Overdue' : 'Due today';
        final who = t.assigneeName.trim();
        final meta = who.isEmpty ? dueTag : '$dueTag \u00b7 $who';
        return TodoWidgetItem(
          id: t.id,
          kind: 'todo',
          title: t.title,
          meta: meta,
          overdue: overdue,
        );
      }(),
    ],
    for (final item in dueRoutines) ...[
      () {
        final overdue = item.st.left < 0;
        final dueTag = overdue ? 'Overdue' : 'Due today';
        final room = item.row.room.trim();
        final who = item.row.assigneeName.trim();
        final parts = <String>[
          'Routine',
          if (room.isNotEmpty) room,
          dueTag,
          if (who.isNotEmpty) who,
        ];
        return TodoWidgetItem(
          id: item.row.id,
          kind: 'routine',
          title: item.row.name,
          meta: parts.join(' \u00b7 '),
          overdue: overdue,
        );
      }(),
    ],
  ];

  final visible = all.length <= maxItems ? all : all.sublist(0, maxItems);
  return TodoWidgetSnapshot(
    hasHome: true,
    homeName: homeName,
    date: today,
    totalCount: all.length,
    items: visible,
  );
}
