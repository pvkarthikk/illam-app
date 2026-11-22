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
    'agreePub': '',
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
      'signPub': 'p',
      'agreePub': '',
      'model': 'X',
    },
  },
);

Iterable<List<T>> _permutations<T>(List<T> list) sync* {
  if (list.length <= 1) {
    yield list;
    return;
  }
  for (var i = 0; i < list.length; i++) {
    final head = list[i];
    final rest = [...list.sublist(0, i), ...list.sublist(i + 1)];
    for (final perm in _permutations(rest)) {
      yield [head, ...perm];
    }
  }
}

void main() {
  test('genesis creates active admin devA', () {
    final r = replayMembership([_genesis()]);
    final a = r.members['devA'];
    expect(a, isNotNull);
    expect(a!.role, 'admin');
    expect(a.status, 'active');
    expect(a.joinedVia, 'created');
    expect(r.effects['g'], 'applied');
  });

  test('second genesis is ignored', () {
    final r = replayMembership([_genesis(), _genesis(id: 'g2', at: 2)]);
    expect(r.effects['g'], 'applied');
    expect(r.effects['g2'], 'ignored:second genesis');
  });

  test('admin adds B and C, member C cannot add D', () {
    final r = replayMembership([
      _genesis(),
      _add('a1', 'devA', 'B', 'admin', 2, prev: const ['g']),
      _add('a2', 'devA', 'C', 'member', 3, prev: const ['a1']),
      _add('a3', 'devC', 'D', 'member', 4, prev: const ['a2']),
    ]);
    expect(r.effects['a3'], 'ignored:notAdmin');
    expect(r.members['B']?.status, 'active');
    expect(r.members['B']?.role, 'admin');
    expect(r.members['B']?.invitedBy, 'devA');
    expect(r.members['C']?.status, 'active');
    expect(r.members['C']?.role, 'member');
    expect(r.members['D'], isNull);
  });

  test('unknown prev is pending and non-increasing hlc is ignored:clock', () {
    final g = _genesis();
    final a1 = _add('a1', 'devA', 'B', 'member', 5, prev: const ['g']);
    final pendingOp = _add('p1', 'devA', 'C', 'member', 6, prev: const ['zzz']);
    final clockBad = _add('c1', 'devA', 'D', 'member', 5, prev: const ['a1']);
    final r = replayMembership([g, a1, pendingOp, clockBad]);
    expect(r.effects['p1'], 'pending');
    expect(r.effects['c1'], 'ignored:clock');
  });

  test('op authored by unknown device is ignored:notMember', () {
    final r = replayMembership([
      _genesis(),
      _add('x1', 'devUnknown', 'B', 'member', 2),
    ]);
    expect(r.effects['x1'], 'ignored:notMember');
  });

  group('never lose the last admin', () {
    List<MemberOp> baseOps() => [
      _genesis(),
      _add('aB', 'devA', 'B', 'admin', 2, prev: const ['g']),
      _add('aC', 'devA', 'C', 'member', 3, prev: const ['aB']),
    ];

    test('mutual removal converges for every input permutation', () {
      const rB = MemberOp(
        opId: 'rB',
        homeId: 'H',
        type: 'removeMember',
        authorDeviceId: 'devA',
        hlc: '0000000000010.0000.dev',
        prev: ['aC'],
        payload: {'memberId': 'B'},
      );
      const rA = MemberOp(
        opId: 'rA',
        homeId: 'H',
        type: 'removeMember',
        authorDeviceId: 'devB',
        hlc: '0000000000011.0000.dev',
        prev: ['aC'],
        payload: {'memberId': 'devA'},
      );
      final ops = [...baseOps(), rB, rA];
      for (final perm in _permutations(ops)) {
        final r = replayMembership(perm);
        expect(r.members['devA']?.role, 'admin');
        expect(r.members['devA']?.status, 'active');
        expect(r.members['B']?.status, 'removed');
        expect(r.effects['rA'], 'ignored:notMember');
      }
    });

    test('concurrent demotion preserves one admin', () {
      final dB = MemberOp(
        opId: 'dB',
        homeId: 'H',
        type: 'setRole',
        authorDeviceId: 'devA',
        hlc: _h(10),
        prev: const ['aC'],
        payload: const {'memberId': 'B', 'role': 'member'},
      );
      final dA = MemberOp(
        opId: 'dA',
        homeId: 'H',
        type: 'setRole',
        authorDeviceId: 'devB',
        hlc: _h(11),
        prev: const ['aC'],
        payload: const {'memberId': 'devA', 'role': 'member'},
      );
      final r = replayMembership([...baseOps(), dB, dA]);
      expect(r.members['B']?.role, 'member');
      expect(r.members['devA']?.role, 'admin');
      expect(r.effects['dA'], 'ignored:notAdmin');
    });

    test('sole admin cannot step down or leave when others remain, can leave alone', () {
      final withMember = replayMembership([
        _genesis(),
        _add('aC', 'devA', 'C', 'member', 2, prev: const ['g']),
        MemberOp(
          opId: 'sr',
          homeId: 'H',
          type: 'setRole',
          authorDeviceId: 'devA',
          hlc: _h(3),
          prev: const ['aC'],
          payload: const {'memberId': 'devA', 'role': 'member'},
        ),
        MemberOp(
          opId: 'lv',
          homeId: 'H',
          type: 'leave',
          authorDeviceId: 'devA',
          hlc: _h(4),
          prev: const ['aC'],
        ),
      ]);
      expect(withMember.effects['sr'], 'ignored:lastAdmin');
      expect(withMember.effects['lv'], 'ignored:lastAdmin');

      final alone = replayMembership([
        _genesis(),
        MemberOp(
          opId: 'lvAlone',
          homeId: 'H',
          type: 'leave',
          authorDeviceId: 'devA',
          hlc: _h(2),
          prev: const ['g'],
        ),
      ]);
      expect(alone.effects['lvAlone'], 'applied');
      expect(alone.members['devA']?.status, 'left');
    });

    test('self removal ignored, member removal deactivates device, deleteHome blocks later ops', () {
      final r = replayMembership([
        ...baseOps(),
        MemberOp(
          opId: 'self',
          homeId: 'H',
          type: 'removeMember',
          authorDeviceId: 'devA',
          hlc: _h(4),
          prev: const ['aC'],
          payload: const {'memberId': 'devA'},
        ),
        MemberOp(
          opId: 'remC',
          homeId: 'H',
          type: 'removeMember',
          authorDeviceId: 'devA',
          hlc: _h(5),
          prev: const ['aC'],
          payload: const {'memberId': 'C'},
        ),
        MemberOp(
          opId: 'del',
          homeId: 'H',
          type: 'deleteHome',
          authorDeviceId: 'devA',
          hlc: _h(6),
          prev: const ['remC'],
        ),
        _add('afterDel', 'devA', 'D', 'member', 7, prev: const ['del']),
      ]);

      expect(r.effects['self'], 'ignored:self');
      expect(r.devices['devC']?.active, isFalse);
      expect(r.devices['devC']?.endedHlc, _h(5));
      expect(r.deleted, isTrue);
      expect(r.effects['afterDel'], 'ignored:deleted');
    });
  });
}
