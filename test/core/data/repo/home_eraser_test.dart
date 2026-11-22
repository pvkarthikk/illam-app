import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('erase removes only target home rows, invokes onErase once, and keeps ControlStore', () async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final prefs = await DevicePrefs.inMemory();
    final secure = MemorySecureStore();
    final ring = HomeKeyRing(secure);
    final clock = FixedClock(DateTime(2026, 11, 20, 9));
    final cs = ControlStore(secure, now: () => clock.nowMs);
    addTearDown(cs.dispose);
    final registry = CollectionRegistry.build(db);
    final writer = ChangeWriter(db, registry, HlcClock(clock, prefs), prefs);
    final eraser = HomeEraser(db, registry, prefs, ring, cs, clock);

    await prefs.setCurrentHomeId('NM-A');
    await writer.write('Seed A', (c) {
      c.create('homes', {'name': 'Home A', 'home_key_id': 'genesis'}, id: 'NM-A');
      c.create('dev_notes', {'title': 'Note A', 'taps': 1}, id: 'noteA');
    }, homeId: 'NM-A');

    await writer.write('Seed B', (c) {
      c.create('homes', {'name': 'Home B', 'home_key_id': 'genesis'}, id: 'NM-B');
      c.create('dev_notes', {'title': 'Note B', 'taps': 2}, id: 'noteB');
    }, homeId: 'NM-B');

    await cs.addOutbox(
      OutboxEntry('NM-A', 'op1', '{}', clock.nowMs, false, const DialInfo.empty()),
    );

    final calls = <String>[];
    HomeEraser.onErase.add((id) async => calls.add(id));
    addTearDown(HomeEraser.onErase.clear);

    await eraser.erase('NM-A');

    final notesA = await (db.select(db.devNotes)..where((n) => n.homeId.equals('NM-A'))).get();
    final notesB = await (db.select(db.devNotes)..where((n) => n.homeId.equals('NM-B'))).get();
    final opsA = await (db.select(db.ops)..where((o) => o.homeId.equals('NM-A'))).get();
    final opsB = await (db.select(db.ops)..where((o) => o.homeId.equals('NM-B'))).get();
    final fcA = await (db.select(db.fieldClocks)..where((f) => f.entityId.equals('noteA'))).get();
    final fcB = await (db.select(db.fieldClocks)..where((f) => f.entityId.equals('noteB'))).get();

    expect(notesA, isEmpty);
    expect(opsA, isEmpty);
    expect(fcA, isEmpty);
    expect(notesB.length, 1);
    expect(opsB, isNotEmpty);
    expect(fcB, isNotEmpty);

    expect(calls, ['NM-A']);
    expect(prefs.currentHomeId, isNull);
    expect((await cs.pendingOutbox('NM-A')).length, 1);
  });
}
