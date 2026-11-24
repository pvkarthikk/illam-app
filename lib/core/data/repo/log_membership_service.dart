import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/repo/local_membership_service.dart';
import 'package:nm_flat/core/data/repo/membership_service.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/key_rotation.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/time/clock.dart';

/// MembershipService backed by the signed [MembershipLog].
class LogMembershipService implements MembershipService {
  LogMembershipService(
    this._local,
    this._log,
    this._changes,
    this._tasks,
    this._homeId,
    this._myMemberId, {
    this.keyRotation,
    this.keyRing,
    this.controlStore,
    this.homeEraser,
    this.closeSessionsWith,
    this.clock,
  });

  final LocalMembershipService _local;
  final MembershipLog _log;
  final ChangeWriter _changes;
  final TasksRepo _tasks;
  final String _homeId;
  final String _myMemberId;
  final KeyRotation? keyRotation;
  final HomeKeyRing? keyRing;
  final ControlStore? controlStore;
  final HomeEraser? homeEraser;
  final void Function(Set<String> deviceIds)? closeSessionsWith;
  final Clock? clock;

  int get _nowMs => clock?.nowMs ?? DateTime.now().millisecondsSinceEpoch;

  @override
  Stream<List<Member>> members() => _local.members();

  @override
  Stream<bool> isAdmin() => _local.isAdmin();

  @override
  Future<MembershipResult> setRole(String memberId, String role) async {
    final active = await _local.members().first;
    final me = active.where((m) => m.id == _myMemberId).firstOrNull;
    final amAdmin = me != null && me.role == 'admin';
    final selfStepDown =
        memberId == _myMemberId && role == 'member' && me != null;
    if (!amAdmin && !selfStepDown) {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }

    final adminsAfter = active.where((m) {
      final effective = m.id == memberId ? role : m.role;
      return effective == 'admin';
    }).length;
    if (adminsAfter == 0) {
      return const MembershipResult.refused('homeLastAdmin');
    }

    final target = active.where((m) => m.id == memberId).firstOrNull;
    final previous = target?.role ?? 'member';
    final r = await _log.append(_homeId, 'setRole', {
      'memberId': memberId,
      'role': role,
    });
    if (r.effect != 'applied') {
      return MembershipResult.refused(
        r.reason == 'lastAdmin' ? 'homeLastAdmin' : 'homeOnlyAdminsRoles',
      );
    }

    if (selfStepDown) {
      return const MembershipResult.ok();
    }

    return MembershipResult.ok(
      ChangeResult(
        r.opId,
        UndoToken(
          label: 'Role',
          homeId: _homeId,
          entries: const [],
          runner: (_) async {
            final currentList = await _local.members().first;
            final current = currentList
                .where((m) => m.id == memberId)
                .firstOrNull;
            if (current == null || current.role != role) {
              final rawName =
                  current?.firstName ??
                  Names.firstName(
                    current?.fullName ?? target?.fullName ?? '',
                  );
              return UndoConflict(byMe: false, name: rawName);
            }
            await setRole(memberId, previous);
            return const UndoDone();
          },
        ),
      ),
    );
  }

  @override
  Future<MembershipResult> removeMember(String memberId) async {
    final active = await _local.members().first;
    final amAdmin = active.any((m) => m.id == _myMemberId && m.role == 'admin');
    if (!amAdmin || memberId == _myMemberId) {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }

    final w = await _tasks.loadAssignedTo(memberId, assigneeType: 'member');
    final r = await _log.append(_homeId, 'removeMember', {
      'memberId': memberId,
    });
    if (r.effect != 'applied') {
      return MembershipResult.refused(
        r.reason == 'lastAdmin' ? 'homeLastAdmin' : 'homeOnlyAdminsRoles',
      );
    }

    await _changes.write(
      'Removed member',
      (c) => _tasks.buildReassignOps(c, w, _myMemberId),
    );

    if (keyRotation != null) {
      final replayAfterRemoval = await _log.replayState(_homeId);
      final newKey = randomBytes(32);
      final payload = await keyRotation!.buildRotatePayload(
        replayAfterRemoval,
        newKey,
      );
      final rot = await _log.append(_homeId, 'rotateKey', payload);
      if (rot.effect == 'applied' && keyRing != null) {
        await keyRing!.add(_homeId, rot.opId, newKey);
      }
    }

    final devs = await (_local.db.select(_local.db.memberDevices)
          ..where((d) => d.homeId.equals(_homeId) & d.memberId.equals(memberId)))
        .get();
    closeSessionsWith?.call({for (final d in devs) d.deviceId});

    return const MembershipResult.ok();
  }

  @override
  Future<MembershipResult> renameHome(String name) => _local.renameHome(name);

  @override
  Future<MembershipResult> leaveHome() async {
    final pending = await controlStore?.pendingOutbox(_homeId) ?? const [];
    if (pending.isNotEmpty) return const MembershipResult.ok();

    final active = await _local.members().first;
    final amAdmin = active.any((m) => m.id == _myMemberId && m.role == 'admin');
    final otherAdmins = [
      for (final m in active)
        if (m.id != _myMemberId && m.role == 'admin') m,
    ]..sort((a, b) => (a.fullName ?? '').toLowerCase().compareTo(
        (b.fullName ?? '').toLowerCase(),
      ));
    final hasOthers = active.any((m) => m.id != _myMemberId);
    if (amAdmin && otherAdmins.isEmpty && hasOthers) {
      return const MembershipResult.refused('homeChooseAdmin');
    }

    final heir = otherAdmins.firstOrNull;
    if (heir != null) {
      final w = await _tasks.loadAssignedTo(_myMemberId, assigneeType: 'member');
      if (w.routineCount > 0 || w.todoCount > 0) {
        await _changes.write(
          'Reassigned before leaving',
          (c) => _tasks.buildReassignOps(c, w, heir.id),
        );
      }
    }

    final r = await _log.append(_homeId, 'leave', const {});
    if (r.effect != 'applied') {
      return MembershipResult.refused(
        r.reason == 'lastAdmin' ? 'homeChooseAdmin' : 'homeOnlyAdminsRoles',
      );
    }

    final replay = await _log.replayState(_homeId);
    final myDevId = (await _log.keys).deviceId;
    final dial = keyRotation == null
        ? const DialInfo.empty()
        : await keyRotation!.dialInfoFor(_homeId, replay, myDevId);
    final wire = await _log.wireForOp(r.opId);
    if (wire != null) {
      await controlStore?.addOutbox(
        OutboxEntry(_homeId, r.opId, jsonEncode(wire), _nowMs, false, dial),
      );
    }
    return const MembershipResult.ok();
  }

  @override
  Future<MembershipResult> removeFromThisPhoneNow() async {
    var pending = await controlStore?.pendingOutbox(_homeId) ?? const [];
    if (pending.isEmpty) {
      final leaveRes = await leaveHome();
      if (!leaveRes.applied) return leaveRes;
      pending = await controlStore?.pendingOutbox(_homeId) ?? const [];
    }
    final entry = pending.lastOrNull;
    await homeEraser?.eraseWithTombstone(
      _homeId,
      reason: 'left',
      opJson: entry?.opJson,
      dial: entry?.dial,
      shown: true,
    );
    return const MembershipResult.ok();
  }

  @override
  Future<MembershipResult> deleteHome() async {
    final active = await _local.members().first;
    final me = active.where((m) => m.id == _myMemberId).firstOrNull;
    if (me == null || me.role != 'admin') {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }

    final preDeleteReplay = await _log.replayState(_homeId);
    final myDevId = (await _log.keys).deviceId;
    final dial = keyRotation == null
        ? const DialInfo.empty()
        : await keyRotation!.dialInfoFor(_homeId, preDeleteReplay, myDevId);

    final r = await _log.append(_homeId, 'deleteHome', const {});
    if (r.effect != 'applied') {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }

    final wire = await _log.wireForOp(r.opId);
    final opJson = wire == null ? '' : jsonEncode(wire);
    if (opJson.isNotEmpty) {
      await controlStore?.addOutbox(
        OutboxEntry(_homeId, r.opId, opJson, _nowMs, false, dial),
      );
    }

    final myName = (me.firstName != null && me.firstName!.isNotEmpty)
        ? me.firstName!
        : Names.firstName(me.fullName ?? '');
    await homeEraser?.eraseWithTombstone(
      _homeId,
      reason: 'deleted',
      byName: myName,
      opJson: opJson.isEmpty ? null : opJson,
      dial: dial,
      shown: true,
    );
    return const MembershipResult.ok();
  }
}
