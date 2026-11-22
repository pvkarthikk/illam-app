import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';

String _h(int n) => '${n.toString().padLeft(13, '0')}.0000.dev';

MemberOp _genesis() => MemberOp(
  opId: 'g',
  homeId: 'H',
  type: 'genesis',
  authorDeviceId: 'devA',
  hlc: _h(1),
  payload: {
    'genesisJson': jsonEncode({
      'creatorDeviceId': 'devA',
      'creatorName': 'A',
      'signPub': 'pA',
    }),
    'agreePub': 'aA',
    'model': 'X',
  },
);

MemberOp _add(String id, String memberId, String role, int at) => MemberOp(
  opId: id,
  homeId: 'H',
  type: 'addMember',
  authorDeviceId: 'devA',
  hlc: _h(at),
  prev: const ['g'],
  payload: {
    'memberId': memberId,
    'name': memberId,
    'color': '',
    'role': role,
    'via': 'qr',
    'device': {
      'deviceId': 'dev$memberId',
      'signPub': 'p$memberId',
      'agreePub': 'a$memberId',
      'model': 'X',
    },
  },
);

MemberOp _addKit(String id, String dev, String pub, int at, {List<String> prev = const ['g']}) =>
    MemberOp(
      opId: id,
      homeId: 'H',
      type: 'addRecoveryKey',
      authorDeviceId: dev,
      hlc: _h(at),
      prev: prev,
      payload: {'pub': pub, 'deviceId': dev},
    );

MemberOp _recover(String id, String newDev, String memberId, String kitPub, int at) =>
    MemberOp(
      opId: id,
      homeId: 'H',
      type: 'recover',
      authorDeviceId: newDev,
      hlc: _h(at),
      payload: {
        'memberId': memberId,
        'kitPub': kitPub,
        'device': {
          'deviceId': newDev,
          'signPub': 'pNew',
          'agreePub': 'aNew',
          'model': 'Pixel',
        },
        'recoverySig': 'sig',
      },
    );

List<MemberOp> _base() => [
  _genesis(),
  _add('aB', 'B', 'admin', 2),
  _add('aM', 'M', 'member', 3),
];

void main() {
  test('1. live kit allows recover by new device and preserves admin role', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kA', 'devA', 'pubA', 10),
      _recover('recA', 'devNew', 'devA', 'pubA', 20),
    ]);

    expect(r.effects['recA'], 'applied');
    expect(r.isActiveDevice('devNew'), isTrue);
    expect(r.devices['devNew']?.memberId, 'devA');
    expect(r.members['devA']?.role, 'admin');
    expect(r.liveKits.containsKey('pubA'), isTrue);
  });

  test('2. demoted admin B recovers with demoted member role', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kB', 'devB', 'pubB', 10, prev: const ['aB']),
      MemberOp(
        opId: 'demB',
        homeId: 'H',
        type: 'setRole',
        authorDeviceId: 'devA',
        hlc: _h(15),
        prev: const ['aB'],
        payload: const {'memberId': 'B', 'role': 'member'},
      ),
      _recover('recB', 'devNewB', 'B', 'pubB', 20),
    ]);

    expect(r.effects['recB'], 'applied');
    expect(r.isActiveDevice('devNewB'), isTrue);
    expect(r.devices['devNewB']?.memberId, 'B');
    expect(r.members['B']?.role, 'member');
  });

  test('3. revoked kit blocks recover with deadKit reason revoked', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kA', 'devA', 'pubA', 10),
      MemberOp(
        opId: 'revA',
        homeId: 'H',
        type: 'revokeRecoveryKey',
        authorDeviceId: 'devA',
        hlc: _h(15),
        payload: const {'pub': 'pubA'},
      ),
      _recover('recA', 'devNew', 'devA', 'pubA', 20),
    ]);

    expect(r.effects['revA'], 'applied');
    expect(r.effects['recA'], 'ignored:deadKit');
    expect(r.deadReason('pubA')?.reason, 'revoked');
  });

  test('4. monotonic replacement invalidates earlier recover with reason replaced', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kM1', 'devM', 'pubM1', 10, prev: const ['aM']),
      _recover('recEarly', 'devNew', 'M', 'pubM1', 20),
      _addKit('kM2', 'devM', 'pubM2', 30, prev: const ['aM']),
    ]);

    expect(r.effects['recEarly'], 'ignored:deadKit');
    expect(r.deadReason('pubM1')?.reason, 'replaced');
    expect(r.liveKits.containsKey('pubM2'), isTrue);
  });

  test('5. removing member M marks M kit dead with reason memberGone', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kM', 'devM', 'pubM', 10, prev: const ['aM']),
      MemberOp(
        opId: 'remM',
        homeId: 'H',
        type: 'removeMember',
        authorDeviceId: 'devA',
        hlc: _h(15),
        prev: const ['aM'],
        payload: const {'memberId': 'M'},
      ),
    ]);

    expect(r.effects['remM'], 'applied');
    expect(r.deadReason('pubM')?.reason, 'memberGone');
    expect(r.liveKits.containsKey('pubM'), isFalse);
  });

  test('6. revoke permissions: M cannot revoke A kit, M can revoke own, admin A can revoke M', () {
    final r = replayMembership([
      ..._base(),
      _addKit('kA', 'devA', 'pubA', 10),
      _addKit('kM1', 'devM', 'pubM1', 11, prev: const ['aM']),
      MemberOp(
        opId: 'mRevA',
        homeId: 'H',
        type: 'revokeRecoveryKey',
        authorDeviceId: 'devM',
        hlc: _h(12),
        prev: const ['aM'],
        payload: const {'pub': 'pubA'},
      ),
      MemberOp(
        opId: 'mRevOwn',
        homeId: 'H',
        type: 'revokeRecoveryKey',
        authorDeviceId: 'devM',
        hlc: _h(13),
        prev: const ['aM'],
        payload: const {'pub': 'pubM1'},
      ),
      _addKit('kM2', 'devM', 'pubM2', 14, prev: const ['mRevOwn']),
      MemberOp(
        opId: 'aRevM',
        homeId: 'H',
        type: 'revokeRecoveryKey',
        authorDeviceId: 'devA',
        hlc: _h(15),
        payload: const {'pub': 'pubM2'},
      ),
    ]);

    expect(r.effects['mRevA'], 'ignored:notAdmin');
    expect(r.effects['mRevOwn'], 'applied');
    expect(r.effects['aRevM'], 'applied');
  });

  test('7. verifyRecover checks Ed25519 signature over canonical payload', () async {
    final ed = Ed25519();
    final kp = await ed.newKeyPair();
    final seed = await kp.extractPrivateKeyBytes();
    final pub = (await kp.extractPublicKey()).bytes;

    final payload = <String, Object?>{
      'memberId': 'M',
      'kitPub': b64(pub),
      'device': {
        'deviceId': 'devNew',
        'signPub': 'pNew',
        'agreePub': 'aNew',
        'model': 'Pixel',
      },
    };
    final sig = await signRecover(payload, seed);
    final signed = {...payload, 'recoverySig': sig};

    expect(await verifyRecover(signed), isTrue);
    expect(await verifyRecover({...signed, 'memberId': 'other'}), isFalse);
    expect(
      await verifyRecover({...payload, 'recoverySig': b64(randomBytes(64))}),
      isFalse,
    );
  });
}
