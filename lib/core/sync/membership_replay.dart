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

class IgnoredOp {
  const IgnoredOp(this.opId, this.authorDeviceId, this.reason);

  final String opId;
  final String authorDeviceId;
  final String reason;
}

class KitRec {
  KitRec(this.pub, this.memberId, this.deviceId, this.addedHlc);

  final String pub;
  final String memberId;
  final String deviceId;
  final String addedHlc;
}

class DeadKit {
  const DeadKit(this.reason, this.hlc);

  final String reason;
  final String hlc;
}

class ReplayResult {
  final Map<String, MemberRec> members = {};
  final Map<String, DeviceRec> devices = {};
  final Map<String, String> effects = {};
  final Map<String, Set<String>> keyHolders = {};
  final Map<String, Map<String, String>> wraps = {};
  final List<IgnoredOp> ignored = [];
  final Map<String, KitRec> kits = {};
  final Map<String, DeadKit> dead = {};
  String? currentKeyId;
  bool deleted = false;
  String? deletedByMemberId;

  int get activeAdmins =>
      members.values.where((m) => m.status == 'active' && m.role == 'admin').length;

  Map<String, KitRec> get liveKits => {
    for (final e in kits.entries)
      if (!dead.containsKey(e.key)) e.key: e.value,
  };

  DeadKit? deadReason(String pub) => dead[pub];

  bool isActiveDevice(String deviceId) {
    if (deleted) return false;
    final d = devices[deviceId];
    if (d == null || !d.active) return false;
    return members[d.memberId]?.status == 'active';
  }

  Set<String> activeDeviceIds() => {
    for (final id in devices.keys)
      if (isActiveDevice(id)) id,
  };

  bool activeAt(String memberId, String hlc) {
    final end = members[memberId]?.endedHlc;
    return end == null || hlc.compareTo(end) < 0;
  }

  String? wrapFor(String keyId, String deviceId) => wraps[keyId]?[deviceId];
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
  for (final k in r.kits.values) {
    if (k.memberId == m.memberId) {
      r.dead.putIfAbsent(k.pub, () => DeadKit('memberGone', hlc));
    }
  }
}

/// Replays [input] with monotonic recovery-kit invalidation across all ops.
ReplayResult replayMembership(List<MemberOp> input) {
  final first = _replayOnce(input, const {});
  final dead = Map<String, DeadKit>.from(first.dead);

  final byDevice = <String, List<MemberOp>>{};
  for (final op in input) {
    if (op.type != 'addRecoveryKey' || first.effects[op.opId] != 'applied') {
      continue;
    }
    final devId = op.payload['deviceId'];
    if (devId is String) {
      (byDevice[devId] ??= []).add(op);
    }
  }
  for (final group in byDevice.values) {
    if (group.length <= 1) continue;
    group.sort(compareMemberOps);
    for (var i = 0; i < group.length - 1; i++) {
      final pub = group[i].payload['pub'];
      if (pub is String) {
        dead.putIfAbsent(pub, () => DeadKit('replaced', group[i + 1].hlc));
      }
    }
  }

  for (final k in first.kits.values) {
    final m = first.members[k.memberId];
    if (m == null || m.status != 'active') {
      dead.putIfAbsent(k.pub, () => DeadKit('memberGone', m?.endedHlc ?? ''));
    }
  }

  return _replayOnce(input, dead);
}

ReplayResult _replayOnce(List<MemberOp> input, Map<String, DeadKit> preDead) {
  final r = ReplayResult();
  r.dead.addAll(preDead);
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
      r.ignored.add(IgnoredOp(op.opId, op.authorDeviceId, 'clock'));
      continue;
    }

    final why = _apply(op, r);
    if (why == null) {
      r.effects[op.opId] = 'applied';
    } else {
      r.effects[op.opId] = 'ignored:$why';
      r.ignored.add(IgnoredOp(op.opId, op.authorDeviceId, why));
    }
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
    r.keyHolders['genesis'] = {creatorDeviceId};
    return null;
  }

  if (op.type == 'recover') {
    final kitPub = op.payload['kitPub'] as String?;
    final memberId = op.payload['memberId'] as String?;
    final kit = kitPub == null ? null : r.kits[kitPub];
    if (kit == null ||
        r.dead.containsKey(kitPub) ||
        memberId == null ||
        kit.memberId != memberId) {
      return 'deadKit';
    }
    final targetMember = r.members[memberId];
    if (targetMember == null || targetMember.status != 'active') {
      return 'notMember';
    }
    final device = Map<String, Object?>.from(op.payload['device'] as Map);
    final devId = device['deviceId'] as String;
    if (devId != op.authorDeviceId) return 'notOwnDevice';
    final wall = hlcWall(op.hlc);
    final devModel = (device['model'] as String?) ?? '';
    r.devices[devId] = DeviceRec(
      devId,
      memberId,
      (device['signPub'] as String?) ?? '',
      (device['agreePub'] as String?) ?? '',
      devModel,
      wall,
    );
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
      final keyId = (op.payload['keyId'] as String?) ?? r.currentKeyId;
      if (keyId != null) {
        (r.keyHolders[keyId] ??= <String>{}).add(devId);
      }
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
      final wrapped = <String, String>{};
      final rawWrapped = op.payload['wrapped'];
      if (rawWrapped is Map) {
        for (final e in rawWrapped.entries) {
          if (e.key is String && e.value is String) {
            wrapped[e.key as String] = e.value as String;
          }
        }
      }
      r.wraps[op.opId] = wrapped;
      r.keyHolders[op.opId] = wrapped.keys.toSet();
      return null;

    case 'deleteHome':
      if (author.role != 'admin') return 'notAdmin';
      r.deleted = true;
      r.deletedByMemberId = dev.memberId;
      return null;

    case 'addRecoveryKey':
      final pub = op.payload['pub'] as String;
      final devId = op.payload['deviceId'] as String;
      if (devId != op.authorDeviceId) return 'notOwnDevice';
      r.kits[pub] = KitRec(pub, author.memberId, devId, op.hlc);
      return null;

    case 'revokeRecoveryKey':
      final pub = op.payload['pub'] as String;
      final kit = r.kits[pub];
      if (kit == null) return 'unknownKit';
      if (author.memberId != kit.memberId && author.role != 'admin') {
        return 'notAdmin';
      }
      r.dead.putIfAbsent(pub, () => DeadKit('revoked', op.hlc));
      return null;

    default:
      return 'unsupported';
  }
}
