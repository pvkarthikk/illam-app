import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

Future<({NestDatabase db, DevicePrefs prefs, ChangeWriter writer})> _setup() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  final clock = FixedClock(DateTime(2026, 11, 20, 9));
  final writer = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  return (db: db, prefs: prefs, writer: writer);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('create writes seq 1..3 with shared changeId and next write continues at 4', () async {
    final env = await _setup();
    late String noteId;
    final res1 = await env.writer.write('Add', (c) {
      noteId = c.create('dev_notes', {'title': 'A', 'body': 'x'});
    }, homeId: 'devlab');

    final ops1 = await env.db.select(env.db.ops).get();
    expect(ops1.length, 3);
    expect(ops1.map((o) => o.seq).toList(), [1, 2, 3]);
    expect(
      ops1.map((o) => o.opId).toList(),
      ['${env.prefs.deviceId}:1', '${env.prefs.deviceId}:2', '${env.prefs.deviceId}:3'],
    );
    expect(ops1.map((o) => o.changeId).toSet(), {res1.changeId});

    await env.writer.write(
      'Rename',
      (c) => c.set('dev_notes', noteId, 'title', 'B'),
      homeId: 'devlab',
    );
    final ops2 = await env.db.select(env.db.ops).get();
    expect(ops2.map((o) => o.seq).toList(), [1, 2, 3, 4]);
  });

  test('undo of create marks row deleted', () async {
    final env = await _setup();
    late String noteId;
    final res = await env.writer.write('Add', (c) {
      noteId = c.create('dev_notes', {'title': 'A'});
    }, homeId: 'devlab');

    expect(await res.undo!.run(), isA<UndoDone>());
    final note = await env.db.select(env.db.devNotes).getSingle();
    expect(note.id, noteId);
    expect(note.deleted, isTrue);
  });

  test('set title A -> B and undo restores A', () async {
    final env = await _setup();
    late String id;
    await env.writer.write('Add', (c) {
      id = c.create('dev_notes', {'title': 'A'});
    }, homeId: 'devlab');

    final rename = await env.writer.write(
      'Rename',
      (c) => c.set('dev_notes', id, 'title', 'B'),
      homeId: 'devlab',
    );
    expect((await env.db.select(env.db.devNotes).getSingle()).title, 'B');

    expect(await rename.undo!.run(), isA<UndoDone>());
    expect((await env.db.select(env.db.devNotes).getSingle()).title, 'A');
  });

  test('undo conflict returns byMe: true when same user overwrote field', () async {
    final env = await _setup();
    late String id;
    await env.writer.write('Add', (c) {
      id = c.create('dev_notes', {'title': 'A'});
    }, homeId: 'devlab');

    final r1 = await env.writer.write(
      'To B',
      (c) => c.set('dev_notes', id, 'title', 'B'),
      homeId: 'devlab',
    );
    await env.writer.write(
      'To C',
      (c) => c.set('dev_notes', id, 'title', 'C'),
      homeId: 'devlab',
    );

    final outcome = await r1.undo!.run();
    expect(outcome, isA<UndoConflict>());
    expect((outcome as UndoConflict).byMe, isTrue);
    expect((await env.db.select(env.db.devNotes).getSingle()).title, 'C');
  });

  test('inc taps 3 and undo restores 0; running same token twice is no-op', () async {
    final env = await _setup();
    late String id;
    await env.writer.write('Add', (c) {
      id = c.create('dev_notes', {'title': 'A'});
    }, homeId: 'devlab');

    final tap = await env.writer.write(
      'Tap',
      (c) => c.inc('dev_notes', id, 'taps', 3),
      homeId: 'devlab',
    );
    expect((await env.db.select(env.db.devNotes).getSingle()).taps, 3);

    expect(await tap.undo!.run(), isA<UndoDone>());
    expect((await env.db.select(env.db.devNotes).getSingle()).taps, 0);

    final opsBefore = (await env.db.select(env.db.ops).get()).length;
    expect(await tap.undo!.run(), isA<UndoDone>());
    final opsAfter = (await env.db.select(env.db.ops).get()).length;
    expect(opsAfter, opsBefore);
  });

  test('empty write returns null undo and writes no ops', () async {
    final env = await _setup();
    final res = await env.writer.write('x', (c) {}, homeId: 'devlab');
    expect(res.undo, isNull);
    expect(await env.db.select(env.db.ops).get(), isEmpty);
  });

  test('undoing delete of note with taps preserves taps == 2', () async {
    final env = await _setup();
    late String id;
    await env.writer.write('Add', (c) {
      id = c.create('dev_notes', {'title': 'A'});
      c.inc('dev_notes', id, 'taps', 2);
    }, homeId: 'devlab');

    final del = await env.writer.write(
      'Delete',
      (c) => c.delete('dev_notes', id),
      homeId: 'devlab',
    );
    expect((await env.db.select(env.db.devNotes).getSingle()).deleted, isTrue);

    expect(await del.undo!.run(), isA<UndoDone>());
    final restored = await env.db.select(env.db.devNotes).getSingle();
    expect(restored.deleted, isFalse);
    expect(restored.taps, 2);
  });

  test('write without homeId and no currentHomeId throws StateError', () async {
    final env = await _setup();
    await expectLater(
      env.writer.write('Add', (c) => c.create('dev_notes', {'title': 'A'})),
      throwsStateError,
    );
  });
}
