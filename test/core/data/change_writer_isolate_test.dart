import 'package:drift/drift.dart' show OrderingTerm, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('stale isolate writer advances seq and HLC past DB ops', () async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final registry = CollectionRegistry.build(db);

    final prefsA = await DevicePrefs.inMemory();
    final now = DateTime(2026, 11, 23, 10, 0);
    final writerA = ChangeWriter(
      db,
      registry,
      HlcClock(FixedClock(now), prefsA),
      prefsA,
    );
    await writerA.write(
      'Staff A',
      (c) => c.create('staff', {'name': 'Lakshmi'}),
      homeId: 'NM-1',
    );

    final prefsB = await DevicePrefs.inMemory();
    await prefsB.setDeviceId(prefsA.deviceId, kind: 'random');
    await prefsB.setNextSeq(1);
    final writerB = ChangeWriter(
      db,
      registry,
      HlcClock(FixedClock(now.subtract(const Duration(seconds: 10))), prefsB),
      prefsB,
    );
    await writerB.write(
      'Staff B',
      (c) => c.create('staff', {'name': 'Selvi'}),
      homeId: 'NM-1',
    );

    final ops = await (db.select(
      db.ops,
    )..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
    final staffCreateOps = ops.where((o) => o.field == 'name').toList();
    expect(staffCreateOps.length, 2);
    expect(ops.map((o) => o.opId).toSet().length, ops.length);
    final seqs = ops.map((o) => o.seq).toList();
    expect(seqs.first, 1);
    expect(seqs.last, ops.length);
    expect(
      staffCreateOps[1].hlc.compareTo(staffCreateOps[0].hlc) > 0,
      isTrue,
    );
  });
}
