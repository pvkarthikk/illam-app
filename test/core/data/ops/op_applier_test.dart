import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/json_util.dart';

OpRecord _op({
  required String opId,
  String tbl = 'dev_notes',
  String entityId = 'n1',
  String deviceId = 'aaaa',
  int seq = 1,
  required int wall,
  int counter = 0,
  String kind = 'set',
  required String field,
  Object? value,
  int? delta,
}) {
  return OpRecord(
    opId: opId,
    homeId: 'devlab',
    deviceId: deviceId,
    seq: seq,
    hlc: Hlc(wall, counter, deviceId).toString(),
    authorMemberId: deviceId,
    changeId: 'chg-$opId',
    tbl: tbl,
    entityId: entityId,
    kind: kind,
    field: field,
    valueJson: kind == 'set' ? encodeValue(value) : null,
    delta: kind == 'inc' ? delta : null,
  );
}

Future<(NestDatabase, OpApplier)> _openDb() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return (db, OpApplier(db, CollectionRegistry.build(db)));
}

Future<List<Map<String, Object?>>> _snapshot(NestDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT id, title, pinned, taps, deleted FROM dev_notes ORDER BY id',
      )
      .get();
  return [for (final r in rows) r.data];
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('applies mixed ops in any order with identical outcome', () async {
    final ops = [
      _op(opId: 'aaaa:1', entityId: 'n1', deviceId: 'aaaa', seq: 1, wall: 1000, field: 'title', value: 'First'),
      _op(opId: 'bbbb:1', entityId: 'n1', deviceId: 'bbbb', seq: 1, wall: 1500, field: 'title', value: 'Second'),
      _op(opId: 'aaaa:2', entityId: 'n1', deviceId: 'aaaa', seq: 2, wall: 1200, field: 'pinned', value: true),
      _op(opId: 'bbbb:2', entityId: 'n1', deviceId: 'bbbb', seq: 2, wall: 1600, field: 'pinned', value: false),
      _op(opId: 'aaaa:3', entityId: 'n1', deviceId: 'aaaa', seq: 3, wall: 1300, kind: 'inc', field: 'taps', delta: 2),
      _op(opId: 'bbbb:3', entityId: 'n1', deviceId: 'bbbb', seq: 3, wall: 1400, kind: 'inc', field: 'taps', delta: 3),
      _op(opId: 'aaaa:4', entityId: 'n2', deviceId: 'aaaa', seq: 4, wall: 2000, field: 'title', value: 'Two-Old'),
      _op(opId: 'bbbb:4', entityId: 'n2', deviceId: 'bbbb', seq: 4, wall: 2500, field: 'title', value: 'Two-New'),
      _op(opId: 'bbbb:5', entityId: 'n2', deviceId: 'bbbb', seq: 5, wall: 2600, field: 'deleted', value: true),
      _op(opId: 'aaaa:5', entityId: 'n2', deviceId: 'aaaa', seq: 5, wall: 2100, kind: 'inc', field: 'taps', delta: 4),
    ];

    final (db1, app1) = await _openDb();
    final (db2, app2) = await _openDb();
    final (db3, app3) = await _openDb();

    for (final op in ops) {
      await db1.transaction(() => app1.applyOne(op));
    }
    for (final op in ops.reversed) {
      await db2.transaction(() => app2.applyOne(op));
    }
    final shuffled = [...ops]..shuffle(Random(42));
    for (final op in shuffled) {
      await db3.transaction(() => app3.applyOne(op));
    }

    final snap1 = await _snapshot(db1);
    final snap2 = await _snapshot(db2);
    final snap3 = await _snapshot(db3);
    expect(snap2, snap1);
    expect(snap3, snap1);
    expect(snap1[0]['title'], 'Second');
    expect(snap1[0]['pinned'], 0);
    expect(snap1[0]['taps'], 5);
    expect(snap1[1]['title'], 'Two-New');
    expect(snap1[1]['deleted'], 1);
    expect(snap1[1]['taps'], 4);
  });

  test('duplicate opId is idempotent and does not double-count inc', () async {
    final (db, applier) = await _openDb();
    final op = _op(
      opId: 'dev:1',
      wall: 1000,
      kind: 'inc',
      field: 'taps',
      delta: 2,
    );

    expect(await db.transaction(() => applier.applyOne(op)), isTrue);
    expect(await db.transaction(() => applier.applyOne(op)), isFalse);

    final allOps = await db.select(db.ops).get();
    final notes = await db.select(db.devNotes).get();
    expect(allOps.length, 1);
    expect(notes.single.taps, 2);
  });

  test('unknown table and unknown field throw ArgumentError', () async {
    final (db, applier) = await _openDb();
    final badTable = _op(
      opId: 'dev:1',
      tbl: 'nope',
      wall: 1000,
      field: 'title',
      value: 'x',
    );
    final badField = _op(
      opId: 'dev:2',
      wall: 1000,
      field: 'colour',
      value: 'red',
    );

    await expectLater(
      db.transaction(() => applier.applyOne(badTable)),
      throwsArgumentError,
    );
    await expectLater(
      db.transaction(() => applier.applyOne(badField)),
      throwsArgumentError,
    );
  });

  test('inc adds deltas cumulatively', () async {
    final (db, applier) = await _openDb();
    await db.transaction(
      () => applier.applyOne(
        _op(opId: 'dev:1', wall: 1000, kind: 'inc', field: 'taps', delta: 2),
      ),
    );
    await db.transaction(
      () => applier.applyOne(
        _op(opId: 'dev:2', wall: 1001, kind: 'inc', field: 'taps', delta: 3),
      ),
    );
    final note = await (db.select(db.devNotes)).getSingle();
    expect(note.taps, 5);
  });

  test('older set loses while both ops remain stored, and earliest wall wins createdAt', () async {
    final (db, applier) = await _openDb();
    await db.transaction(
      () => applier.applyOne(
        _op(opId: 'dev:1', wall: 2000, field: 'title', value: 'New'),
      ),
    );
    await db.transaction(
      () => applier.applyOne(
        _op(opId: 'dev:2', wall: 1000, field: 'title', value: 'Old'),
      ),
    );

    final note = await db.select(db.devNotes).getSingle();
    final storedOps = await db.select(db.ops).get();
    expect(note.title, 'New');
    expect(note.createdAt, 1000);
    expect(storedOps.length, 2);
  });
}
