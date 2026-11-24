import 'dart:convert';

import 'package:nm_flat/core/data/ops/op_record.dart';

enum Verdict { accept, pending, quarantine }

class Decision {
  const Decision(this.verdict, [this.reason = '']);

  final Verdict verdict;
  final String reason;

  static const ok = Decision(Verdict.accept);
}

class MemberInfo {
  const MemberInfo({
    required this.memberId,
    required this.role,
    required this.status,
    this.endedHlc,
    this.roleLog = const [],
  });

  final String memberId;
  final String role;
  final String status;
  final String? endedHlc;
  final List<(String, String)> roleLog;

  bool get isAdmin => role == 'admin';

  bool adminAt(String hlc) {
    if (roleLog.isEmpty) return isAdmin;
    var r = roleLog.first.$2;
    for (final (entryHlc, entryRole) in roleLog) {
      if (entryHlc.compareTo(hlc) <= 0) {
        r = entryRole;
      } else {
        break;
      }
    }
    return r == 'admin';
  }
}

abstract class ValidationView {
  Future<MemberInfo?> memberForDevice(String deviceId);
  Future<Map<String, Object?>?> row(String tbl, String id);
  Future<String?> creatingChangeId(String tbl, String id);
  Set<String> fieldsOf(String tbl);
}

/// Authoritative per-op validator shared by local writes and incoming sync ops.
class Validator {
  const Validator();

  static const visitIn = 'in_at';
  static const visitOut = 'out_at';
  static const visitStaff = 'staff_id';
  static const leaveDate = 'date';

  static const _min5 = 300000;
  static const _h16 = 57600000;
  static const _h48 = 172800000;
  static const _day = 86400000;

  static const _system = {
    'id',
    'home_id',
    'created_at',
    'created_by',
    'updated_at',
    'updated_by',
  };

  static const _derived = {
    'role',
    'status',
    'joined_at',
    'joined_via',
    'invited_by',
  };

  static const _counters = <String, Set<String>>{
    'items': {'qty_milli'},
    'item_history': {'times_bought'},
    'dev_notes': {'taps'},
  };

  static const _sources = {'manual', 'order', 'store', 'bill', 'salary'};

  static const _expImmutable = {
    'source',
    'added_by',
    'bill_id',
    'order_channel',
    'staff_id',
    'settlement_attempt_id',
    'doc_month',
  };

  static Decision _q(String r) => Decision(Verdict.quarantine, r);

  static bool _len(Object? v, int min, int max) {
    if (v is! String) return false;
    final n = v.trim().length;
    return n >= min && n <= max;
  }

  /// Validates [op] in the context of its full [change] and state [v] at [nowMs].
  Future<Decision> check(
    OpRecord op,
    List<OpRecord> change,
    ValidationView v, {
    required int nowMs,
    bool incoming = false,
  }) async {
    if (op.opId != '${op.deviceId}:${op.seq}') return _q('badId');

    final m = await v.memberForDevice(op.deviceId);
    if (m == null) return const Decision(Verdict.pending, 'unknownDevice');

    if (m.memberId != op.authorMemberId) return _q('authorMismatch');

    if (m.status != 'active' &&
        (m.endedHlc == null || op.hlc.compareTo(m.endedHlc!) >= 0)) {
      return _q('notMember');
    }

    final wall =
        int.tryParse(op.hlc.length >= 13 ? op.hlc.substring(0, 13) : '') ?? 0;
    if (wall > nowMs + _min5) {
      return const Decision(Verdict.pending, 'clockAhead');
    }

    final fields = v.fieldsOf(op.tbl);
    if (!fields.contains(op.field) || _system.contains(op.field)) {
      return _q('unknownField');
    }

    final row = await v.row(op.tbl, op.entityId);
    final creating =
        row == null ||
        (await v.creatingChangeId(op.tbl, op.entityId)) == op.changeId;

    final counters = _counters[op.tbl] ?? const <String>{};
    if (op.kind == 'inc') {
      if (!counters.contains(op.field) || op.delta == null) {
        return _q('notCounter');
      }
    } else if (op.kind == 'set') {
      if (counters.contains(op.field) && !creating) {
        return _q('counterSet');
      }
    } else {
      return _q('badKind');
    }

    final Object? value = (op.kind == 'set' && op.valueJson != null)
        ? jsonDecode(op.valueJson!)
        : null;

    Object? after(String f, {bool fromRow = true}) {
      var res = fromRow && row != null ? row[f] : null;
      for (final cOp in change) {
        if (cOp.kind == 'set' &&
            cOp.tbl == op.tbl &&
            cOp.entityId == op.entityId &&
            cOp.field == f) {
          res = cOp.valueJson != null ? jsonDecode(cOp.valueJson!) : null;
        }
      }
      return res;
    }

    bool changesImmutable(Set<String> f) =>
        f.contains(op.field) && !creating && row[op.field] != value;

    final admin = m.adminAt(op.hlc);

    switch (op.tbl) {
      case 'homes':
        if (changesImmutable(const {'vault_id', 'genesis_json', 'home_key_id'})) {
          return _q('immutable');
        }
        if (!admin) return _q('adminOnly');
        if (op.field == 'name' && !_len(value, 1, 40)) return _q('range');

      case 'members':
        if (_derived.contains(op.field)) return _q('membershipField');
        if (op.entityId != m.memberId) return _q('ownOnly');

      case 'staff':
      case 'pay_rules':
      case 'pay_adjustments':
      case 'settlement_attempts':
        if (!admin) return _q('adminOnly');

      case 'visits':
        if (changesImmutable(const {visitStaff})) return _q('immutable');
        if (!admin) {
          final oldIn = row?[visitIn];
          if (oldIn is int && (wall - oldIn).abs() > _h48) {
            return _q('tooOld');
          }
          final newIn = after(visitIn);
          if (newIn is int && (wall - newIn).abs() > _h48) {
            return _q('tooOld');
          }
        }
        final i = after(visitIn, fromRow: !incoming);
        final o = after(visitOut, fromRow: !incoming);
        if (i is int && o is int && (o <= i || o - i > _h16)) {
          return _q('range');
        }

      case 'leaves':
        final d = after(leaveDate);
        if (!admin && d is String) {
          final parsed = DateTime.tryParse(d);
          if (parsed != null) {
            final start = DateTime(parsed.year, parsed.month, parsed.day)
                .millisecondsSinceEpoch;
            if (start < wall - _h48 - _day || start > wall + _day) {
              return _q('tooOld');
            }
          }
        }

      case 'expenses':
        if (op.field == 'amount_paise' && (value is! int || value <= 0)) {
          return _q('range');
        }
        if (op.field == 'source' && (value is! String || !_sources.contains(value))) {
          return _q('range');
        }
        if (changesImmutable(_expImmutable)) return _q('immutable');
        if (after('source') == 'salary' && !admin) return _q('adminOnly');
        final addedBy = creating ? after('added_by') : row['added_by'];
        if (!admin && addedBy != null && addedBy != m.memberId) {
          return _q('ownOnly');
        }

      case 'bills':
        if (op.field == 'name' && !_len(value, 1, 40)) return _q('range');
        if (op.field == 'usual_amount_paise' &&
            (value is! int || value <= 0)) {
          return _q('range');
        }
        if (op.field == 'due_day' &&
            (value is! int || value < 1 || value > 31)) {
          return _q('range');
        }
        if (op.field == 'deleted' &&
            value == true &&
            !admin &&
            row?['created_by'] != m.memberId) {
          return _q('adminOnly');
        }

      case 'routines':
        if (op.field == 'every_days' &&
            (value is! int || value < 1 || value > 365)) {
          return _q('range');
        }

      case 'backup_status':
        if (op.entityId != op.deviceId) return _q('ownOnly');
    }

    return Decision.ok;
  }
}
