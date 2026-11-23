import 'package:drift/drift.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TaskPerson {
  const TaskPerson({
    required this.id,
    required this.type,
    required this.firstName,
    required this.color,
    this.isMe = false,
  });

  final String id;
  final String type;
  final String firstName;
  final Color color;
  final bool isMe;
}

String personName(AppLocalizations l10n, TaskPerson p) =>
    p.isMe ? l10n.tasksYou : p.firstName;

class AssignedWork {
  const AssignedWork(this.routineIds, this.todoIds);

  final List<String> routineIds;
  final List<String> todoIds;

  int get routineCount => routineIds.length;
  int get todoCount => todoIds.length;
  bool get isEmpty => routineIds.isEmpty && todoIds.isEmpty;
}

class TasksRepo {
  TasksRepo(this.db, this.changes, this.prefs);

  final NestDatabase db;
  final ChangeWriter changes;
  final DevicePrefs prefs;

  String get _me => prefs.memberId ?? prefs.deviceId;

  Stream<List<RoutineRow>> watchRoutines(String homeId) =>
      (db.select(db.routines)
            ..where((r) => r.homeId.equals(homeId) & r.deleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.name)]))
          .watch();

  /// Only the two columns the "tasks due" badge needs, not whole rows.
  Stream<List<({String lastDone, int everyDays})>> watchRoutineClocks(
    String homeId,
  ) {
    final q = db.selectOnly(db.routines)
      ..addColumns([db.routines.lastDone, db.routines.everyDays])
      ..where(
        db.routines.homeId.equals(homeId) & db.routines.deleted.equals(false),
      );
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            lastDone: r.read(db.routines.lastDone) ?? '',
            everyDays: r.read(db.routines.everyDays) ?? 0,
          ),
      ],
    );
  }

  /// Open dated to-dos only, projected to what the badge counts.
  Stream<List<({String due, bool done})>> watchOpenTodoDues(String homeId) {
    final q = db.selectOnly(db.todos)
      ..addColumns([db.todos.due])
      ..where(
        db.todos.homeId.equals(homeId) &
            db.todos.deleted.equals(false) &
            db.todos.done.equals(false) &
            db.todos.due.equals('').not(),
      );
    return q.watch().map(
      (rows) => [
        for (final r in rows) (due: r.read(db.todos.due) ?? '', done: false),
      ],
    );
  }

  Stream<List<TodoRow>> watchTodos(String homeId) =>
      (db.select(db.todos)
            ..where((t) => t.homeId.equals(homeId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.due)]))
          .watch();

  Future<ChangeResult> markRoutineDone(String id, String today) =>
      changes.write('Routine done', (c) {
        c.set('routines', id, 'last_done', today);
        c.set('routines', id, 'last_done_by', _me);
      });

  Future<ChangeResult> createRoutine({
    required String name,
    required String room,
    required int everyDays,
    required String assigneeType,
    required String assignee,
    required String today,
  }) => changes.write('Routine', (c) {
    c.create('routines', {
      'name': name,
      'room': room,
      'every_days': everyDays,
      'assignee_type': assigneeType,
      'assignee': assignee,
      'last_done': newRoutineLastDone(today, everyDays),
    });
  });

  Future<ChangeResult> updateRoutine(String id, Map<String, Object?> fields) =>
      changes.write('Routine', (c) => c.setAll('routines', id, fields));

  Future<ChangeResult> deleteRoutine(String id) =>
      changes.write('Routine', (c) => c.delete('routines', id));

  Future<ChangeResult> createTodo({
    required String title,
    required String due,
    required String assigneeType,
    required String assignee,
  }) => changes.write('To-do', (c) {
    c.create('todos', {
      'title': title,
      'due': due,
      'assignee_type': assigneeType,
      'assignee': assignee,
      'done': false,
    });
  });

  Future<ChangeResult> updateTodo(String id, Map<String, Object?> fields) =>
      changes.write('To-do', (c) => c.setAll('todos', id, fields));

  Future<ChangeResult> deleteTodo(String id) =>
      changes.write('To-do', (c) => c.delete('todos', id));

  Future<ChangeResult> setTodoDone(String id, bool done) =>
      changes.write('To-do', (c) {
        c.set('todos', id, 'done', done);
        c.set(
          'todos',
          id,
          'done_at',
          done ? DateTime.now().millisecondsSinceEpoch : null,
        );
        c.set('todos', id, 'done_by', done ? _me : null);
      });

  Future<AssignedWork> loadAssigned(String staffId) =>
      loadAssignedTo(staffId, assigneeType: 'staff');

  Future<AssignedWork> loadAssignedTo(
    String assigneeId, {
    required String assigneeType,
  }) async {
    final homeId = prefs.currentHomeId;
    final routines =
        await (db.select(db.routines)..where((r) {
              final match =
                  r.assigneeType.equals(assigneeType) &
                  r.assignee.equals(assigneeId) &
                  r.deleted.equals(false);
              return homeId == null ? match : (match & r.homeId.equals(homeId));
            }))
            .get();
    final todos =
        await (db.select(db.todos)..where((t) {
              final match =
                  t.assigneeType.equals(assigneeType) &
                  t.assignee.equals(assigneeId) &
                  t.deleted.equals(false) &
                  t.done.equals(false);
              return homeId == null ? match : (match & t.homeId.equals(homeId));
            }))
            .get();
    return AssignedWork(
      [for (final r in routines) r.id],
      [for (final t in todos) t.id],
    );
  }

  void buildReassignOps(ChangeBuilder c, AssignedWork w, String toMemberId) {
    for (final id in w.routineIds) {
      c.set('routines', id, 'assignee_type', 'member');
      c.set('routines', id, 'assignee', toMemberId);
    }
    for (final id in w.todoIds) {
      c.set('todos', id, 'assignee_type', 'member');
      c.set('todos', id, 'assignee', toMemberId);
    }
  }
}
