import 'dart:convert';

import 'package:nm_flat/core/sync/member_op.dart';

class MemberRec {
  MemberRec(
    this.memberId,
    this.role,
    this.joinedAt,
    this.joinedVia, {
    this.invitedBy,
    this.name = '',
    this.color = '',
    this.model = '',
  });

  final String memberId;
  String role;
  final int joinedAt;
  final String joinedVia;
  final String? invitedBy;
  final String name;
  final String color;
  final String model;
  String status = 'active';
  String? endedHlc;
}

class DeviceRec {
  DeviceRec(
    this.deviceId,
    this.memberId,
    this.signPub,
    this.agreePub,
    this.model,
    this.addedAt,
  );

  final String deviceId;
  final String memberId;
  final String signPub;
  final String agreePub;
  final String model;
  final int addedAt;
  bool active = true;
  String? endedHlc;
}

class ReplayResult {
  final Map<String, MemberRec> members = {};
  final Map<String, DeviceRec> devices = {};
  final Map<String, String> effects = {};
  String? currentKeyId;
  bool deleted = false;

  int get activeAdmins =>
      members.values.where((m) => m.status == 'active' && m.role == 'admin').length;
}

/// Extracts the 13-digit epoch-ms wall clock prefix from an HLC string.
int hlcWall(String hlc) =>
    int.tryParse(hlc.length >= 13 ? hlc.substring(0, 13) : hlc) ?? 0;

/// Orders `genesis` before all other ops, then sorts by `(hlc, opId)`.
int compareMemberOps(MemberOp a, MemberOp b) {
  final aGen = a.type == 'genesis';
  final bGen = b.type == 'genesis';
  if (aGen != bGen) return aGen ? -1 : 1;
  final cmp = a.hlc.compareTo(b.hlc);
  if (cmp != 0) return cmp;
  return a.opId.compareTo(b.opId);
}

void _end(ReplayResult r, MemberRec m, String status, String hlc) {
  m.status = status;
  m.endedHlc = hlc;
  for (final d in r.devices.values) {
    if (d.memberId == m.memberId) {
      d.active = false;
      d.endedHlc = hlc;
    }
  }
}

/// Replays [input] deterministically to derive member/device state and per-op effects.
ReplayResult replayMembership(List<MemberOp> input) {
  final r = ReplayResult();
  final known = <String, MemberOp>{for (final op in input) op.opId: op};
  final sorted = [...input]..sort(compareMemberOps);

  for (final op in sorted) {
    var hasPendingPrev = false;
    var hasClockViolation = false;

    for (final p in op.prev) {
      final prevOp = known[p];
      if (prevOp == null || r.effects[p] == 'pending') {
        hasPendingPrev = true;
        break;
      }
      if (prevOp.hlc.compareTo(op.hlc) >= 0) {
        hasClockViolation = true;
      }
    }

    if (hasPendingPrev) {
      r.effects[op.opId] = 'pending';
      continue;
    }
    if (hasClockViolation) {
      r.effects[op.opId] = 'ignored:clock';
      continue;
    }

    final why = _apply(op, r);
    r.effects[op.opId] = why == null ? 'applied' : 'ignored:$why';
  }

  return r;
}

String? _apply(MemberOp op, ReplayResult r) {
  if (r.deleted) return 'deleted';

  if (op.type == 'genesis') {
    if (r.members.isNotEmpty) return 'second genesis';
    final g = jsonDecode(op.payload['genesisJson'] as String) as Map<String, Object?>;
    final creatorDeviceId = g['creatorDeviceId'] as String;
    if (op.authorDeviceId != creatorDeviceId) return 'notCreator';
    final wall = hlcWall(op.hlc);
    final model = (op.payload['model'] as String?) ?? '';
    r.members[creatorDeviceId] = MemberRec(
      creatorDeviceId,
      'admin',
      wall,
      'created',
      name: (g['creatorName'] as String?) ?? '',
      model: model,
    );
    r.devices[op.authorDeviceId] = DeviceRec(
      op.authorDeviceId,
      creatorDeviceId,
      (g['signPub'] as String?) ?? '',
      (op.payload['agreePub'] as String?) ?? '',
      model,
      wall,
    );
    r.currentKeyId = 'genesis';
    return null;
  }

  final dev = r.devices[op.authorDeviceId];
  if (dev == null || !dev.active) return 'notMember';
  final author = r.members[dev.memberId];
  if (author == null || author.status != 'active') return 'notMember';

  switch (op.type) {
    case 'addMember':
      if (author.role != 'admin') return 'notAdmin';
      final memberId = op.payload['memberId'] as String;
      final existing = r.members[memberId];
      if (existing != null && existing.status == 'active') {
        return 'alreadyMember';
      }
      final role = op.payload['role'] as String;
      if (role != 'admin' && role != 'member') return 'badRole';
      final device = Map<String, Object?>.from(op.payload['device'] as Map);
      final wall = hlcWall(op.hlc);
      final devModel = (device['model'] as String?) ?? '';
      r.members[memberId] = MemberRec(
        memberId,
        role,
        wall,
        (op.payload['via'] as String?) ?? '',
        invitedBy: author.memberId,
        name: (op.payload['name'] as String?) ?? '',
        color: (op.payload['color'] as String?) ?? '',
        model: devModel,
      );
      final devId = device['deviceId'] as String;
      r.devices[devId] = DeviceRec(
        devId,
        memberId,
        (device['signPub'] as String?) ?? '',
        (device['agreePub'] as String?) ?? '',
        devModel,
        wall,
      );
      return null;

    case 'setRole':
      if (author.role != 'admin') return 'notAdmin';
      final memberId = op.payload['memberId'] as String;
      final target = r.members[memberId];
      if (target == null || target.status != 'active') return 'noTarget';
      final role = op.payload['role'] as String;
      if (role != 'admin' && role != 'member') return 'badRole';
      if (target.role == 'admin' && role == 'member' && r.activeAdmins <= 1) {
        return 'lastAdmin';
      }
      target.role = role;
      return null;

    case 'removeMember':
      if (author.role != 'admin') return 'notAdmin';
      final memberId = op.payload['memberId'] as String;
      final target = r.members[memberId];
      if (target == null || target.status != 'active') return 'noTarget';
      if (target.memberId == author.memberId) return 'self';
      if (target.role == 'admin' && r.activeAdmins <= 1) {
        return 'lastAdmin';
      }
      _end(r, target, 'removed', op.hlc);
      return null;

    case 'leave':
      final hasOtherActive = r.members.values.any(
        (m) => m.status == 'active' && m.memberId != author.memberId,
      );
      if (author.role == 'admin' && r.activeAdmins <= 1 && hasOtherActive) {
        return 'lastAdmin';
      }
      _end(r, author, 'left', op.hlc);
      return null;

    case 'rotateKey':
      if (author.role != 'admin') return 'notAdmin';
      r.currentKeyId = op.opId;
      return null;

    case 'deleteHome':
      if (author.role != 'admin') return 'notAdmin';
      r.deleted = true;
      return null;

    default:
      return 'unsupported';
  }
}
