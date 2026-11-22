import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/undo.dart';

class MembershipResult {
  const MembershipResult.ok([this.change])
    : applied = true,
      reasonKey = null;

  const MembershipResult.refused(this.reasonKey)
    : applied = false,
      change = null;

  final bool applied;
  final String? reasonKey;
  final ChangeResult? change;
}

abstract class MembershipService {
  Stream<List<Member>> members();
  Stream<bool> isAdmin();
  Future<MembershipResult> setRole(String memberId, String role);
  Future<MembershipResult> removeMember(String memberId);
  Future<MembershipResult> leaveHome();
  Future<MembershipResult> deleteHome();
  Future<MembershipResult> renameHome(String name);
}
