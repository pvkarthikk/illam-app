import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';

String _h(int n) => '${n.toString().padLeft(13, '0')}.0000.dev';

MemberOp _genesis({String id = 'g', int at = 1}) => MemberOp(
  opId: id,
  homeId: 'H',
  type: 'genesis',
  authorDeviceId: 'devA',
  hlc: _h(at),
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

MemberOp _add(
  String id,
  String byDev,
  String memberId,
  String role,
  int at, {
  List<String> prev = const [],
  String? keyId,
}) => MemberOp(
  opId: id,
  homeId: 'H',
  type: 'addMember',
  authorDeviceId: byDev,
  hlc: _h(at),
  prev: prev,
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
    'keyId': ?keyId,
  },
);

MemberOp op(
  String id,
  String type,
  String author,
  int at, {
  List<String> prev = const [],
  Map<String, Object?> payload = const {},
}) => MemberOp(
  opId: id,
  homeId: 'H',
  type: type,
  authorDeviceId: author,
  hlc: _h(at),
  prev: prev,
  payload: payload,
);

void main() {
  test('1. Admin A removes C -> C removed, A and B active, C device inactive', () {
    final r = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      _add('aC', 'devA', 'C', 'member', 3, prev: const ['aB']),
      op('remC', 'removeMember', 'devA', 4, prev: const ['aC'], payload: {'memberId': 'C'}),
    ]);

    expect(r.members['C']?.status, 'removed');
    expect(r.members['devA']?.status, 'active');
    expect(r.members['B']?.status, 'active');
    expect(r.activeDeviceIds(), {'devA', 'devB'});
    expect(r.isActiveDevice('devC'), isFalse);
  });

  test('2. A removes A -> effect ignored:self', () {
    final r = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      op('self', 'removeMember', 'devA', 3, prev: const ['aB'], payload: {'memberId': 'devA'}),
    ]);

    expect(r.effects['self'], 'ignored:self');
    expect(r.ignored.single.opId, 'self');
    expect(r.ignored.single.authorDeviceId, 'devA');
    expect(r.ignored.single.reason, 'self');
  });

  test('3. Sole admin A leave ignored:lastAdmin, applied after promoting B', () {
    final blocked = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      op('lv', 'leave', 'devA', 4, prev: const ['aB']),
    ]);
    expect(blocked.effects['lv'], 'ignored:lastAdmin');
    expect(blocked.ignored.single.reason, 'lastAdmin');

    final ok = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      op('promB', 'setRole', 'devA', 3, prev: const ['aB'], payload: {'memberId': 'B', 'role': 'admin'}),
      op('lv', 'leave', 'devA', 4, prev: const ['aB']),
    ]);
    expect(ok.effects['lv'], 'applied');
    expect(ok.members['devA']?.status, 'left');
  });

  test('4. Mutual removal converges across 3 shuffled orders', () {
    final base = [
      _genesis(),
      _add('aB', 'devA', 'B', 'admin', 2, prev: const ['g']),
      op('rB', 'removeMember', 'devA', 10, prev: const ['aB'], payload: {'memberId': 'B'}),
      op('rA', 'removeMember', 'devB', 11, prev: const ['aB'], payload: {'memberId': 'devA'}),
    ];
    final orders = [
      base,
      [base[3], base[1], base[0], base[2]],
      [base[2], base[3], base[1], base[0]],
    ];

    ReplayResult? first;
    for (final list in orders) {
      final r = replayMembership(list);
      expect(r.members['B']?.status, 'removed');
      expect(r.members['devA']?.status, 'active');
      expect(r.ignored.any((i) => i.opId == 'rA' && i.reason == 'notMember'), isTrue);
      if (first != null) {
        expect(
          {for (final e in r.members.entries) e.key: e.value.status},
          {for (final e in first.members.entries) e.key: e.value.status},
        );
        expect(r.effects, first.effects);
        expect(r.currentKeyId, first.currentKeyId);
      }
      first = r;
    }
  });

  test('5. rotateKey requires admin and populates currentKeyId and keyHolders', () {
    final r = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      op(
        'rotBad',
        'rotateKey',
        'devB',
        3,
        prev: const ['aB'],
        payload: {'wrapped': {'devA': 'wA'}},
      ),
      op(
        'rotOk',
        'rotateKey',
        'devA',
        4,
        prev: const ['aB'],
        payload: {'wrapped': {'devA': 'wA', 'devB': 'wB'}},
      ),
    ]);

    expect(r.effects['rotBad'], 'ignored:notAdmin');
    expect(r.effects['rotOk'], 'applied');
    expect(r.currentKeyId, 'rotOk');
    expect(r.keyHolders['rotOk'], {'devA', 'devB'});
    expect(r.wrapFor('rotOk', 'devB'), 'wB');
  });

  test('6. deleteHome requires admin and records deletedByMemberId', () {
    final r = replayMembership([
      _genesis(),
      _add('aB', 'devA', 'B', 'member', 2, prev: const ['g']),
      op('delBad', 'deleteHome', 'devB', 3, prev: const ['aB']),
      op('delOk', 'deleteHome', 'devA', 4, prev: const ['aB']),
    ]);

    expect(r.effects['delBad'], 'ignored:notAdmin');
    expect(r.effects['delOk'], 'applied');
    expect(r.deleted, isTrue);
    expect(r.deletedByMemberId, 'devA');
  });

  test('7. activeAt compares HLC against endedHlc', () {
    final r = replayMembership([
      _genesis(),
      _add('aC', 'devA', 'C', 'member', 2, prev: const ['g']),
      op('remC', 'removeMember', 'devA', 5, prev: const ['aC'], payload: {'memberId': 'C'}),
    ]);

    expect(r.activeAt('C', _h(4)), isTrue);
    expect(r.activeAt('C', _h(5)), isFalse);
    expect(r.activeAt('C', _h(6)), isFalse);
    expect(r.activeAt('devA', _h(99)), isTrue);
  });
}
