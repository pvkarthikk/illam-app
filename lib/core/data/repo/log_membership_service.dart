import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/local_membership_service.dart';
import 'package:nm_flat/core/data/repo/membership_service.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/sync/membership_log.dart';

/// MembershipService backed by the signed [MembershipLog].
class LogMembershipService implements MembershipService {
  LogMembershipService(
    this._local,
    this._log,
    this._changes,
    this._tasks,
    this._homeId,
    this._myMemberId,
  );

  final LocalMembershipService _local;
  final MembershipLog _log;
  final ChangeWriter _changes;
  final TasksRepo _tasks;
  final String _homeId;
  final String _myMemberId;

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

    return MembershipResult.ok(
      ChangeResult(
        r.opId,
        UndoToken(
          label: 'Role',
          homeId: _homeId,
          entries: const [],
          runner: (_) async {
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

    final res = await _changes.write(
      'Removed member',
      (c) => _tasks.buildReassignOps(c, w, _myMemberId),
    );
    return MembershipResult.ok(res);
  }

  @override
  Future<MembershipResult> renameHome(String name) => _local.renameHome(name);

  @override
  Future<MembershipResult> leaveHome() => _local.leaveHome();

  @override
  Future<MembershipResult> deleteHome() => _local.deleteHome();
}
