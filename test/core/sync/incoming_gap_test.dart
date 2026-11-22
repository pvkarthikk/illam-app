import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

String _hlc(int ms, String dev, int seq) =>
    '${ms.toString().padLeft(13, '0')}.${seq.toRadixString(16).padLeft(4, '0')}.$dev';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('gap rule holds seq 4 pending until seq 3 fills the gap', () async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final prefs = await DevicePrefs.inMemory();
    final clock = FixedClock(DateTime(2026, 11, 20, 9));
    final hlc = HlcClock(clock, prefs);
    final registry = CollectionRegistry.build(db);

    final keysA = await DeviceKeys.fromSeeds(
      List.filled(32, 1),
      List.filled(32, 2),
    );
    final localKeys = await DeviceKeys.fromSeeds(
      List.filled(32, 5),
      List.filled(32, 6),
    );

    final membership = MembershipLog(
      db,
      Future.value(localKeys),
      hlc,
      clock,
      modelOf: () async => 'T',
    );
    final pipe = IncomingPipeline(
      db: db,
      registry: registry,
      applier: OpApplier(db, registry),
      membership: membership,
      hlc: hlc,
      clock: clock,
    );

    final gj = HomeIds.genesisJson(
      homeName: 'T',
      creatorName: 'A',
      creatorDeviceId: keysA.deviceId,
      signPubB64: keysA.signPubB64,
      createdAt: 1,
      nonceB64: 'AAAA',
    );
    final homeId = await HomeIds.fromGenesis(gj);
    final signedGen = await MemberOpCodec.sign(
      MemberOp(
        homeId: homeId,
        type: 'genesis',
        authorDeviceId: keysA.deviceId,
        hlc: _hlc(clock.nowMs - 60000, keysA.deviceId, 0),
        payload: {
          'genesisJson': gj,
          'agreePub': b64(keysA.agreePub),
          'model': 'T',
        },
      ),
      await keysA.signKeyPair(),
    );
    await pipe.ingest(homeId, memberOps: [MemberOpCodec.toWire(signedGen)]);

    final signerA = OpSigner(Future.value(keysA));
    Future<Map<String, Object?>> mkOp(int seq, String tbl, String id, String field, String valJson) async {
      final signed = await signerA.sign(
        OpRecord(
          opId: '${keysA.deviceId}:$seq',
          homeId: homeId,
          deviceId: keysA.deviceId,
          seq: seq,
          hlc: _hlc(clock.nowMs, keysA.deviceId, seq),
          authorMemberId: keysA.deviceId,
          changeId: 'chg-$id',
          tbl: tbl,
          entityId: id,
          kind: 'set',
          field: field,
          valueJson: valJson,
        ),
      );
      return opToWire(signed);
    }

    final op1 = await mkOp(1, 'items', 'i1', 'deleted', 'false');
    final op2 = await mkOp(2, 'items', 'i1', 'name', '"Milk"');
    final op3 = await mkOp(3, 'items', 'i2', 'deleted', 'false');
    final op4 = await mkOp(4, 'items', 'i2', 'name', '"Bread"');

    final store = SyncStore(db);

    final r1 = await pipe.ingest(homeId, ops: [op1, op2, op4]);
    expect(r1.applied, 2);
    expect(r1.pending, 1);
    expect((await store.myVector(homeId))[keysA.deviceId], 2);

    final op4Row = await (db.select(
      db.ops,
    )..where((o) => o.opId.equals('${keysA.deviceId}:4'))).getSingle();
    expect(op4Row.status, 'pending');

    final r2 = await pipe.ingest(homeId, ops: [op3]);
    expect(r2.applied, 2);
    expect((await store.myVector(homeId))[keysA.deviceId], 4);
    final items = await db.select(db.items).get();
    expect(items.map((i) => i.name).toSet(), {'Milk', 'Bread'});

    final r3 = await pipe.ingest(homeId, ops: [op1, op2, op3, op4]);
    expect(r3.already, 4);
    expect(r3.applied, 0);
  });
}
