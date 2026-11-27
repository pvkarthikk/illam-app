import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Locale;

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/notify/notifications.dart' show stableId;
import 'package:nm_flat/core/sync/sync_reactions.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

typedef _Shown = ({
  int id,
  String title,
  String body,
  String channelId,
  String channelName,
  String payload,
});

OpRecord _op({
  required String id,
  required String author,
  required String tbl,
  required String entityId,
  required String field,
  required Object? value,
  int seq = 1,
}) => OpRecord(
  opId: '$author:$seq:$id',
  homeId: 'H1',
  deviceId: author,
  seq: seq,
  hlc: '0000000000001.0000.$author',
  authorMemberId: author,
  changeId: 'chg-$id',
  tbl: tbl,
  entityId: entityId,
  kind: 'set',
  field: field,
  valueJson: jsonEncode(value),
);

Future<
  ({
    NestDatabase db,
    DevicePrefs prefs,
    ChangeWriter changes,
    SyncReactions reactions,
    List<_Shown> shown,
  })
>
_setup() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('H1');
  await prefs.setMemberId('m1');
  await prefs.setAppLanguage('en');

  final clock = FixedClock(DateTime(2026, 11, 27, 10));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  await changes.write('Seed home', (c) {
    c.create('homes', {'name': 'Our Home'}, id: 'H1');
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
    }, id: 'm1');
    c.create('members', {
      'full_name': 'Priya Karthik',
      'first_name': 'Priya',
      'role': 'member',
      'status': 'active',
    }, id: 'm2');
    c.create('staff', {
      'name': 'Lakshmi',
      'role': 'Cook',
      'active': true,
    }, id: 's1');
  });

  final shown = <_Shown>[];
  final reactions = SyncReactions(
    db,
    prefs,
    notify: ({
      required int id,
      required String title,
      required String body,
      required String channelId,
      required String channelName,
      required String payload,
    }) async {
      shown.add((
        id: id,
        title: title,
        body: body,
        channelId: channelId,
        channelName: channelName,
        payload: payload,
      ));
    },
  );

  return (
    db: db,
    prefs: prefs,
    changes: changes,
    reactions: reactions,
    shown: shown,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  final en = lookupAppLocalizations(const Locale('en'));

  test('notifies task owner when another family member marks their to-do done', () async {
    final s = await _setup();
    await s.changes.write('My todo', (c) {
      c.create('todos', {
        'title': 'Pay electricity bill',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': true,
        'done_by': 'm2',
      }, id: 't1');
    });

    // Repeated `done = true` op in same batch must still only notify once.
    s.reactions.onApplied(
      _op(
        id: 'done-1',
        author: 'm2',
        tbl: 'todos',
        entityId: 't1',
        field: 'done',
        value: true,
        seq: 1,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'done-2',
        author: 'm2',
        tbl: 'todos',
        entityId: 't1',
        field: 'done',
        value: true,
        seq: 2,
      ),
    );
    await s.reactions.flush();

    expect(s.shown.length, 1);
    final notice = s.shown.single;
    expect(notice.id, stableId('todo_done.t1'));
    expect(notice.channelId, 'tasks');
    expect(notice.title, en.notifTodoDoneTitle);
    expect(notice.body, en.notifTodoDoneBody('Pay electricity bill', 'Priya'));
    expect(notice.payload, '{"route":"/tasks"}');
  });

  test('does not notify for self-completion, others tasks, unchecked, deleted, or initial setup', () async {
    final s = await _setup();
    await s.changes.write('Todos', (c) {
      c.create('todos', {
        'title': 'Self done',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': true,
        'done_by': 'm1',
      }, id: 't_self');
      c.create('todos', {
        'title': 'Priya own todo',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm2',
        'done': true,
        'done_by': 'm2',
      }, id: 't_other');
      c.create('todos', {
        'title': 'Kitchen deep clean',
        'due': '2026-11-27',
        'assignee_type': 'staff',
        'assignee': 's1',
        'done': true,
        'done_by': 'm2',
      }, id: 't_staff');
      c.create('todos', {
        'title': 'Reopened todo',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': false,
      }, id: 't_reopened');
      c.create('todos', {
        'title': 'Deleted todo',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': true,
        'done_by': 'm2',
      }, id: 't_deleted');
      c.delete('todos', 't_deleted');
      c.create('todos', {
        'title': 'Setup todo',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': true,
        'done_by': 'm2',
      }, id: 't_setup');
    });

    s.reactions.onApplied(
      _op(
        id: 'self',
        author: 'm1',
        tbl: 'todos',
        entityId: 't_self',
        field: 'done',
        value: true,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'other',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_other',
        field: 'done',
        value: true,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'staff',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_staff',
        field: 'done',
        value: true,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'reopened',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_reopened',
        field: 'done',
        value: true,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'deleted',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_deleted',
        field: 'done',
        value: true,
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'false-val',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_setup',
        field: 'done',
        value: false,
      ),
    );
    await s.reactions.flush();
    expect(s.shown, isEmpty);

    // During initial onboarding/join import, setupIncompleteHomeId suppresses notices.
    await s.prefs.setSetupIncompleteHomeId('H1');
    s.reactions.onApplied(
      _op(
        id: 'during-setup',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_setup',
        field: 'done',
        value: true,
      ),
    );
    await s.reactions.flush();
    expect(s.shown, isEmpty);
  });

  test('notifies assignee only when open to-do is assigned by another member', () async {
    final s = await _setup();
    await s.changes.write('Assigned todos', (c) {
      c.create('todos', {
        'title': 'Buy filters',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': false,
      }, id: 't_open');
      c.create('todos', {
        'title': 'Already done task',
        'due': '2026-11-27',
        'assignee_type': 'member',
        'assignee': 'm1',
        'done': true,
        'done_by': 'm2',
      }, id: 't_done');
    });

    s.reactions.onApplied(
      _op(
        id: 'a-open',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_open',
        field: 'assignee',
        value: 'm1',
      ),
    );
    s.reactions.onApplied(
      _op(
        id: 'a-done',
        author: 'm2',
        tbl: 'todos',
        entityId: 't_done',
        field: 'assignee',
        value: 'm1',
      ),
    );
    await s.reactions.flush();

    expect(s.shown.length, 1);
    expect(s.shown.single.id, stableId('todo.t_open'));
    expect(s.shown.single.title, en.notifTodoAssignedTitle);
    expect(s.shown.single.body, en.notifTodoAssignedBody('Buy filters', 'Priya'));
  });
}
