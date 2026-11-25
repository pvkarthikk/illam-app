import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/widget_snapshot.dart';
import 'package:nm_flat/core/notify/notifications.dart' show Reader;
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/widgets/widget_bridge.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';

String _capitaliseTitle(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  return t[0].toUpperCase() + t.substring(1);
}

/// Executes one action triggered from an Android home-screen widget.
/// Returns true if a local ChangeWriter mutation ran.
Future<bool> executeWidgetAction(
  Reader read,
  Map<String, Object?> action,
) async {
  final homeId =
      read(currentHomeIdProvider).value ?? read(prefsProvider).currentHomeId;
  if (homeId == null) return false;

  final kind = action['action'] as String? ?? '';
  final me = read(myMemberIdProvider);
  final clock = read(clockProvider);
  final today = Dates.today(clock);

  switch (kind) {
    case 'staff_mark_in':
      final staffId = action['staffId'] as String?;
      if (staffId == null || staffId.isEmpty) return false;
      final staff = await read(staffRepoProvider).watchOne(staffId).first;
      if (staff == null || !staff.active || staff.homeId != homeId) {
        return false;
      }
      final visits = await read(
        staffRepoProvider,
      ).watchVisitsOn(homeId, today).first;
      final hasOpen = visits.any(
        (v) => v.staffId == staffId && v.outAt == null,
      );
      if (hasOpen) return false;
      await read(staffRepoProvider).markIn(staffId, me);
      return true;

    case 'staff_mark_out':
      final staffId = action['staffId'] as String?;
      if (staffId == null || staffId.isEmpty) return false;
      final visits = await read(
        staffRepoProvider,
      ).watchVisitsOn(homeId, today).first;
      Visit? newestOpen;
      for (final v in visits) {
        if (v.staffId == staffId &&
            v.outAt == null &&
            (newestOpen == null || (v.inAt ?? 0) > (newestOpen.inAt ?? 0))) {
          newestOpen = v;
        }
      }
      if (newestOpen == null) return false;
      await read(staffRepoProvider).markOut(newestOpen, me);
      return true;

    case 'complete_todo':
      final id = action['itemId'] as String?;
      if (id == null || id.isEmpty) return false;
      final todos = await read(tasksRepoProvider).watchTodos(homeId).first;
      final exists = todos.any((t) => t.id == id && !t.done);
      if (!exists) return false;
      await read(tasksRepoProvider).setTodoDone(id, true);
      return true;

    case 'complete_routine':
      final id = action['itemId'] as String?;
      if (id == null || id.isEmpty) return false;
      final routines = await read(
        tasksRepoProvider,
      ).watchRoutines(homeId).first;
      final row = routines.where((r) => r.id == id).firstOrNull;
      if (row == null || row.lastDone == today) return false;
      await read(tasksRepoProvider).markRoutineDone(id, today);
      return true;

    case 'add_todo':
      final rawTitle = action['title'] as String? ?? '';
      final title = _capitaliseTitle(rawTitle);
      if (title.isEmpty) return false;
      final rawDue = action['due'] as String?;
      final due = (rawDue != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDue))
          ? rawDue
          : today;
      await read(tasksRepoProvider).createTodo(
        title: title,
        due: due,
        assigneeType: 'member',
        assignee: me,
      );
      return true;

    case 'refresh':
      return false;

    default:
      return false;
  }
}

/// Drains queued native widget actions sequentially and acknowledges every ID.
Future<bool> drainPendingWidgetActions(
  Reader read, {
  WidgetBridge? bridge,
}) async {
  final target = bridge ?? WidgetBridge.instance;
  final pending = await target.takePendingActions();
  if (pending.isEmpty) return false;

  var wrote = false;
  final processedIds = <String>[];
  for (final action in pending) {
    final id = action['id'] as String?;
    try {
      if (await executeWidgetAction(read, action)) {
        wrote = true;
      }
    } on Object {
      // Acknowledge invalid/rejected actions so poison entries cannot loop forever.
    }
    if (id != null && id.isNotEmpty) {
      processedIds.add(id);
    }
  }
  await target.ackPendingActions(processedIds);
  return wrote;
}

/// Queries live Drift tables and pushes fresh snapshots to Android widgets.
Future<void> pushWidgetSnapshots(Reader read, {WidgetBridge? bridge}) async {
  final target = bridge ?? WidgetBridge.instance;
  final clock = read(clockProvider);
  final today = Dates.today(clock);
  final nowMs = clock.nowMs;
  final homeId =
      read(currentHomeIdProvider).value ?? read(prefsProvider).currentHomeId;

  if (homeId == null) {
    await target.updateSnapshots(
      staff: StaffWidgetSnapshot.noHome(date: today).toJson(),
      todos: TodoWidgetSnapshot.noHome(date: today).toJson(),
    );
    return;
  }

  final home = await read(homeRepoProvider).watchHome(homeId).first;
  if (home == null) {
    await target.updateSnapshots(
      staff: StaffWidgetSnapshot.noHome(date: today).toJson(),
      todos: TodoWidgetSnapshot.noHome(date: today).toJson(),
    );
    return;
  }

  final staffRows = await read(staffRepoProvider).watchActive(homeId).first;
  final visitsToday = await read(
    staffRepoProvider,
  ).watchVisitsOn(homeId, today).first;
  final leavesToday = await read(
    staffRepoProvider,
  ).watchLeavesOn(homeId, today).first;
  final todos = await read(tasksRepoProvider).watchTodos(homeId).first;
  final routines = await read(tasksRepoProvider).watchRoutines(homeId).first;
  final members = await read(homeRepoProvider).watchMembers(homeId).first;

  final month = Dates.month(today);
  final salaryRepo = read(salaryRepoProvider);
  final workDaysByStaff = <String, List<int>>{};
  for (final s in staffRows) {
    final rules = await salaryRepo.watchRules(s.id).first;
    final days = workDaysForMonth([
      for (final r in rules) rulesFromRow(r),
    ], month);
    if (days != null) workDaysByStaff[s.id] = days;
  }

  final me = read(myMemberIdProvider);
  final personNameById = <String, String>{
    for (final m in members)
      m.id: m.id == me
          ? 'You'
          : ((m.firstName != null && m.firstName!.trim().isNotEmpty)
                ? m.firstName!.trim()
                : Names.firstName(m.fullName ?? '')),
    for (final s in staffRows) s.id: Names.firstName(s.name ?? ''),
  };

  final staffSnap = buildStaffWidgetSnapshot(
    hasHome: true,
    homeName: home.name ?? '',
    today: today,
    nowMs: nowMs,
    staff: [
      for (final s in staffRows)
        StaffWidgetInput(
          id: s.id,
          name: s.name ?? '',
          role: s.role ?? '',
          color: s.color ?? '#23503A',
          workDaysCsv: s.workDays,
          expectedTimesCsv: s.expectedTimes,
          usualEndTime: s.usualEndTime,
          workDaysOverride: workDaysByStaff[s.id],
        ),
    ],
    visitsToday: [
      for (final v in visitsToday)
        if (v.staffId != null && v.inAt != null)
          StaffVisitRecord(
            staffId: v.staffId!,
            visit: VisitLite(
              id: v.id,
              date: v.date ?? today,
              inAt: v.inAt!,
              outAt: v.outAt,
            ),
          ),
    ],
    leavesToday: {
      for (final l in leavesToday)
        if (l.staffId != null) l.staffId!,
    },
  );

  final todoSnap = buildTodoWidgetSnapshot(
    hasHome: true,
    homeName: home.name ?? '',
    today: today,
    todos: [
      for (final t in todos)
        TodoWidgetInput(
          id: t.id,
          title: t.title,
          due: t.due,
          assigneeName: personNameById[t.assignee] ?? '',
          done: t.done,
        ),
    ],
    routines: [
      for (final r in routines)
        RoutineWidgetInput(
          id: r.id,
          name: r.name,
          room: r.room,
          lastDone: r.lastDone,
          everyDays: r.everyDays,
          assigneeName: personNameById[r.assignee] ?? '',
        ),
    ],
  );

  await target.updateSnapshots(
    staff: staffSnap.toJson(),
    todos: todoSnap.toJson(),
  );
}
