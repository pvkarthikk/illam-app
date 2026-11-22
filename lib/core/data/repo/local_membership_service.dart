import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/repo/membership_service.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/data/wipe.dart';

class LocalMembershipService implements MembershipService {
  LocalMembershipService(
    this.db,
    this.changes,
    this.tasks,
    this.wiper,
    this.homeId,
    this.myMemberId,
  );

  final NestDatabase db;
  final ChangeWriter changes;
  final TasksRepo tasks;
  final PhoneWiper wiper;
  final String homeId;
  final String myMemberId;

  SimpleSelectStatement<$MembersTable, Member> _activeQuery() =>
      db.select(db.members)..where(
        (m) =>
            m.homeId.equals(homeId) &
            m.deleted.equals(false) &
            m.status.equals('active'),
      );

  Future<List<Member>> _active() => _activeQuery().get();

  bool _isActiveAdmin(List<Member> active) =>
      active.any((m) => m.id == myMemberId && m.role == 'admin');

  int _rank(Member m) {
    if (m.id == myMemberId) return 0;
    if (m.role == 'admin') return 1;
    return 2;
  }

  @override
  Stream<List<Member>> members() => _activeQuery().watch().map((rows) {
    final sorted = rows.toList();
    sorted.sort((a, b) {
      final r = _rank(a).compareTo(_rank(b));
      if (r != 0) return r;
      final an = (a.fullName ?? '').toLowerCase();
      final bn = (b.fullName ?? '').toLowerCase();
      final cmp = an.compareTo(bn);
      if (cmp != 0) return cmp;
      return (a.fullName ?? '').compareTo(b.fullName ?? '');
    });
    return sorted;
  });

  @override
  Stream<bool> isAdmin() =>
      (db.select(db.members)..where(
            (m) =>
                m.homeId.equals(homeId) &
                m.id.equals(myMemberId) &
                m.deleted.equals(false),
          ))
          .watchSingleOrNull()
          .map((m) => m != null && m.role == 'admin' && m.status == 'active');

  @override
  Future<MembershipResult> setRole(String memberId, String role) async {
    final active = await _active();
    final me = active.where((m) => m.id == myMemberId).firstOrNull;
    final amAdmin = me != null && me.role == 'admin';
    final selfStepDown =
        memberId == myMemberId && role == 'member' && me != null;
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

    final res = await changes.write(
      'Role changed',
      (c) => c.set('members', memberId, 'role', role),
    );
    return MembershipResult.ok(res);
  }

  @override
  Future<MembershipResult> renameHome(String name) async {
    final active = await _active();
    if (!_isActiveAdmin(active)) {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40) {
      return const MembershipResult.refused('homeNameLength');
    }
    final res = await changes.write(
      'Home renamed',
      (c) => c.set('homes', homeId, 'name', trimmed),
    );
    return MembershipResult.ok(res);
  }

  @override
  Future<MembershipResult> removeMember(String memberId) async {
    final active = await _active();
    if (!_isActiveAdmin(active) || memberId == myMemberId) {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }
    final work = await tasks.loadAssignedTo(memberId, assigneeType: 'member');
    final res = await changes.write('Member removed', (c) {
      c.set('members', memberId, 'status', 'removed');
      tasks.buildReassignOps(c, work, myMemberId);
    });
    return MembershipResult.ok(res);
  }

  @override
  Future<MembershipResult> leaveHome() async {
    final active = await _active();
    final amAdmin = _isActiveAdmin(active);
    final hasOtherAdmin = active.any(
      (m) => m.id != myMemberId && m.role == 'admin',
    );
    final hasOthers = active.any((m) => m.id != myMemberId);
    if (amAdmin && !hasOtherAdmin && hasOthers) {
      return const MembershipResult.refused('homeChooseAdmin');
    }
    await wiper.wipeHome();
    return const MembershipResult.ok();
  }

  @override
  Future<MembershipResult> deleteHome() async {
    final active = await _active();
    if (!_isActiveAdmin(active)) {
      return const MembershipResult.refused('homeOnlyAdminsRoles');
    }
    await wiper.wipeHome();
    return const MembershipResult.ok();
  }
}
