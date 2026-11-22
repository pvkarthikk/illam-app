import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';

void main() {
  test('OpSigner signs, verifies, detects tampering, and round-trips wire', () async {
    final keys = await DeviceKeys.fromSeeds(
      List.filled(32, 7),
      List.filled(32, 8),
    );
    final op = OpRecord(
      opId: '${keys.deviceId}:1',
      homeId: 'home-1',
      deviceId: keys.deviceId,
      seq: 1,
      hlc: '0000000000001.0000.${keys.deviceId}',
      authorMemberId: keys.deviceId,
      changeId: 'chg-1',
      tbl: 'items',
      entityId: 'item-1',
      kind: 'set',
      field: 'name',
      valueJson: '"Milk"',
    );

    final signed = await OpSigner(Future.value(keys)).sign(op);
    expect(await OpSigner.verify(signed, keys.signPub), isTrue);

    final badValue = OpRecord(
      opId: signed.opId,
      homeId: signed.homeId,
      deviceId: signed.deviceId,
      seq: signed.seq,
      hlc: signed.hlc,
      authorMemberId: signed.authorMemberId,
      changeId: signed.changeId,
      tbl: signed.tbl,
      entityId: signed.entityId,
      kind: signed.kind,
      field: signed.field,
      valueJson: '"Bread"',
      delta: signed.delta,
      sig: signed.sig,
    );
    expect(await OpSigner.verify(badValue, keys.signPub), isFalse);

    final badSeq = OpRecord(
      opId: signed.opId,
      homeId: signed.homeId,
      deviceId: signed.deviceId,
      seq: 2,
      hlc: signed.hlc,
      authorMemberId: signed.authorMemberId,
      changeId: signed.changeId,
      tbl: signed.tbl,
      entityId: signed.entityId,
      kind: signed.kind,
      field: signed.field,
      valueJson: signed.valueJson,
      delta: signed.delta,
      sig: signed.sig,
    );
    expect(await OpSigner.verify(badSeq, keys.signPub), isFalse);

    final badTbl = OpRecord(
      opId: signed.opId,
      homeId: signed.homeId,
      deviceId: signed.deviceId,
      seq: signed.seq,
      hlc: signed.hlc,
      authorMemberId: signed.authorMemberId,
      changeId: signed.changeId,
      tbl: 'homes',
      entityId: signed.entityId,
      kind: signed.kind,
      field: signed.field,
      valueJson: signed.valueJson,
      delta: signed.delta,
      sig: signed.sig,
    );
    expect(await OpSigner.verify(badTbl, keys.signPub), isFalse);

    expect(await OpSigner.verify(op, keys.signPub), isFalse);

    final roundTrip = opFromWire(opToWire(signed));
    expect(roundTrip.toCanonicalJson(), signed.toCanonicalJson());
    expect(roundTrip.sig, signed.sig);
  });
}
