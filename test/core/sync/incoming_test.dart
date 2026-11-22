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
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

String _hlcAt(int ms, String dev, [int counter = 0]) =>
    '${ms.toString().padLeft(13, '0')}.${counter.toRadixString(16).padLeft(4, '0')}.$dev';

Future<
  ({
    NestDatabase db,
    IncomingPipeline pipe,
    DeviceKeys keysA,
    DeviceKeys keysB,
    String homeId,
    String genOpId,
    FixedClock clock,
  })
>
_setup() async {
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
  final keysB = await DeviceKeys.fromSeeds(
    List.filled(32, 3),
    List.filled(32, 4),
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

  final genesisJson = HomeIds.genesisJson(
    homeName: 'T',
    creatorName: 'A',
    creatorDeviceId: keysA.deviceId,
    signPubB64: keysA.signPubB64,
    createdAt: 1,
    nonceB64: 'AAAA',
  );
  final homeId = await HomeIds.fromGenesis(genesisJson);

  final signedGen = await MemberOpCodec.sign(
    MemberOp(
      homeId: homeId,
      type: 'genesis',
      authorDeviceId: keysA.deviceId,
      hlc: _hlcAt(clock.nowMs - 60000, keysA.deviceId),
      payload: {
        'genesisJson': genesisJson,
        'agreePub': b64(keysA.agreePub),
        'model': 'T',
      },
    ),
    await keysA.signKeyPair(),
  );

  await pipe.ingest(homeId, memberOps: [MemberOpCodec.toWire(signedGen)]);

  return (
    db: db,
    pipe: pipe,
    keysA: keysA,
    keysB: keysB,
    homeId: homeId,
    genOpId: signedGen.opId,
    clock: clock,
  );
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('applies valid ops from A and counts duplicates as already', () async {
    final s = await _setup();
    final signerA = OpSigner(Future.value(s.keysA));
    final hlc = _hlcAt(s.clock.nowMs, s.keysA.deviceId);
    final op1 = await signerA.sign(
      OpRecord(
        opId: '${s.keysA.deviceId}:1',
        homeId: s.homeId,
        deviceId: s.keysA.deviceId,
        seq: 1,
        hlc: hlc,
        authorMemberId: s.keysA.deviceId,
        changeId: 'chg-1',
        tbl: 'items',
        entityId: 'item-1',
        kind: 'set',
        field: 'deleted',
        valueJson: 'false',
      ),
    );
    final op2 = await signerA.sign(
      OpRecord(
        opId: '${s.keysA.deviceId}:2',
        homeId: s.homeId,
        deviceId: s.keysA.deviceId,
        seq: 2,
        hlc: _hlcAt(s.clock.nowMs, s.keysA.deviceId, 1),
        authorMemberId: s.keysA.deviceId,
        changeId: 'chg-1',
        tbl: 'items',
        entityId: 'item-1',
        kind: 'set',
        field: 'name',
        valueJson: '"Milk"',
      ),
    );

    final wire = [opToWire(op1), opToWire(op2)];
    final r1 = await s.pipe.ingest(s.homeId, ops: wire);
    expect(r1.applied, 2);
    expect(r1.already, 0);
    final items = await s.db.select(s.db.items).get();
    expect(items.single.name, 'Milk');

    final r2 = await s.pipe.ingest(s.homeId, ops: wire);
    expect(r2.already, 2);
    expect(r2.applied, 0);
  });

  test('quarantines tampered op without changing items', () async {
    final s = await _setup();
    final signerA = OpSigner(Future.value(s.keysA));
    final signed = await signerA.sign(
      OpRecord(
        opId: '${s.keysA.deviceId}:1',
        homeId: s.homeId,
        deviceId: s.keysA.deviceId,
        seq: 1,
        hlc: _hlcAt(s.clock.nowMs, s.keysA.deviceId),
        authorMemberId: s.keysA.deviceId,
        changeId: 'chg-t',
        tbl: 'items',
        entityId: 'item-t',
        kind: 'set',
        field: 'name',
        valueJson: '"Milk"',
      ),
    );
    final tamperedWire = opToWire(signed)..['value'] = '"Eggs"';

    final r = await s.pipe.ingest(s.homeId, ops: [tamperedWire]);
    expect(r.quarantined, 1);
    expect(await s.db.select(s.db.items).get(), isEmpty);
    final opRow = await (s.db.select(
      s.db.ops,
    )..where((o) => o.opId.equals(signed.opId))).getSingle();
    expect(opRow.status, 'quarantined');
  });

  test('holds unknown device op pending then applies when addMember arrives', () async {
    final s = await _setup();
    final signerB = OpSigner(Future.value(s.keysB));
    final opB1 = await signerB.sign(
      OpRecord(
        opId: '${s.keysB.deviceId}:1',
        homeId: s.homeId,
        deviceId: s.keysB.deviceId,
        seq: 1,
        hlc: _hlcAt(s.clock.nowMs, s.keysB.deviceId),
        authorMemberId: s.keysB.deviceId,
        changeId: 'chg-b',
        tbl: 'items',
        entityId: 'item-b',
        kind: 'set',
        field: 'deleted',
        valueJson: 'false',
      ),
    );
    final opB2 = await signerB.sign(
      OpRecord(
        opId: '${s.keysB.deviceId}:2',
        homeId: s.homeId,
        deviceId: s.keysB.deviceId,
        seq: 2,
        hlc: _hlcAt(s.clock.nowMs, s.keysB.deviceId, 1),
        authorMemberId: s.keysB.deviceId,
        changeId: 'chg-b',
        tbl: 'items',
        entityId: 'item-b',
        kind: 'set',
        field: 'name',
        valueJson: '"Bread"',
      ),
    );

    final rPending = await s.pipe.ingest(
      s.homeId,
      ops: [opToWire(opB1), opToWire(opB2)],
    );
    expect(rPending.pending, 2);
    expect(await s.db.select(s.db.items).get(), isEmpty);

    final addB = await MemberOpCodec.sign(
      MemberOp(
        homeId: s.homeId,
        type: 'addMember',
        authorDeviceId: s.keysA.deviceId,
        hlc: _hlcAt(s.clock.nowMs - 30000, s.keysA.deviceId),
        prev: [s.genOpId],
        payload: {
          'memberId': s.keysB.deviceId,
          'name': 'B',
          'color': '',
          'role': 'member',
          'via': 'qr',
          'device': {
            'deviceId': s.keysB.deviceId,
            'signPub': s.keysB.signPubB64,
            'agreePub': b64(s.keysB.agreePub),
            'model': 'T',
          },
        },
      ),
      await s.keysA.signKeyPair(),
    );

    final rUnblocked = await s.pipe.ingest(
      s.homeId,
      memberOps: [MemberOpCodec.toWire(addB)],
    );
    expect(rUnblocked.applied, 2);
    final items = await s.db.select(s.db.items).get();
    expect(items.single.name, 'Bread');
  });

  test('quarantines member rename of home with adminOnly note', () async {
    final s = await _setup();
    final addB = await MemberOpCodec.sign(
      MemberOp(
        homeId: s.homeId,
        type: 'addMember',
        authorDeviceId: s.keysA.deviceId,
        hlc: _hlcAt(s.clock.nowMs - 30000, s.keysA.deviceId),
        prev: [s.genOpId],
        payload: {
          'memberId': s.keysB.deviceId,
          'name': 'B',
          'color': '',
          'role': 'member',
          'via': 'qr',
          'device': {
            'deviceId': s.keysB.deviceId,
            'signPub': s.keysB.signPubB64,
            'agreePub': b64(s.keysB.agreePub),
            'model': 'T',
          },
        },
      ),
      await s.keysA.signKeyPair(),
    );
    await s.pipe.ingest(s.homeId, memberOps: [MemberOpCodec.toWire(addB)]);

    final renameOp = await OpSigner(Future.value(s.keysB)).sign(
      OpRecord(
        opId: '${s.keysB.deviceId}:1',
        homeId: s.homeId,
        deviceId: s.keysB.deviceId,
        seq: 1,
        hlc: _hlcAt(s.clock.nowMs, s.keysB.deviceId),
        authorMemberId: s.keysB.deviceId,
        changeId: 'chg-ren',
        tbl: 'homes',
        entityId: s.homeId,
        kind: 'set',
        field: 'name',
        valueJson: '"B Home"',
      ),
    );
    final r = await s.pipe.ingest(s.homeId, ops: [opToWire(renameOp)]);
    expect(r.quarantined, 1);
    expect(r.notes.single, contains('adminOnly'));
  });
}
