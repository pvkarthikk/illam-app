import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/sync/validator.dart';

/// Reads current member, row, and op-history state directly from Drift for validation.
class DriftValidationView implements ValidationView {
  DriftValidationView(this.db, this.registry, {this.local = false});

  final NestDatabase db;
  final CollectionRegistry registry;
  final bool local;
  final Map<String, MemberInfo?> _members = {};
  final Map<(String, String), Map<String, Object?>?> _rows = {};
  final Map<String, Map<String, List<(String, String)>>> _roleLogs = {};

  Future<Map<String, List<(String, String)>>> _rolesForHome(
    String homeId,
  ) async {
    final cached = _roleLogs[homeId];
    if (cached != null) return cached;
    final rows =
        await (db.select(db.memberOps)
              ..where(
                (o) =>
                    o.homeId.equals(homeId) &
                    o.effect.equals('applied') &
                    o.opType.isIn(const ['genesis', 'addMember', 'setRole']),
              )
              ..orderBy([
                (o) => OrderingTerm.asc(o.hlc),
                (o) => OrderingTerm.asc(o.opId),
              ]))
            .get();
    final byMember = <String, List<(String, String)>>{};
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row.payloadJson);
        if (decoded is! Map) continue;
        if (row.opType == 'genesis') {
          final genRaw = decoded['genesisJson'];
          if (genRaw is! String) continue;
          final gen = jsonDecode(genRaw);
          if (gen is! Map) continue;
          final creator = gen['creatorDeviceId'];
          if (creator is String && creator.isNotEmpty) {
            (byMember[creator] ??= []).add((row.hlc, 'admin'));
          }
        } else {
          final memberId = decoded['memberId'];
          final role = decoded['role'];
          if (memberId is String &&
              memberId.isNotEmpty &&
              role is String &&
              role.isNotEmpty) {
            (byMember[memberId] ??= []).add((row.hlc, role));
          }
        }
      } on Object {
        // Ignore malformed member_ops payload.
      }
    }
    _roleLogs[homeId] = byMember;
    return byMember;
  }

  @override
  Future<MemberInfo?> memberForDevice(String deviceId) async {
    if (local && _members.containsKey(deviceId)) {
      return _members[deviceId];
    }
    final r = await db
        .customSelect(
          'SELECT d.home_id AS home_id, d.member_id AS member_id, '
          'd.ended_hlc AS ended_hlc, m.role AS role, m.status AS status '
          'FROM member_devices d '
          'LEFT JOIN members m ON m.id = d.member_id AND m.home_id = d.home_id '
          'WHERE d.device_id = ?',
          variables: [Variable.withString(deviceId)],
          readsFrom: {db.memberDevices, db.members},
        )
        .getSingleOrNull();
    final MemberInfo? result;
    if (r == null) {
      result = null;
    } else {
      final homeId = r.data['home_id'] as String?;
      final memberId = r.data['member_id'] as String;
      final roleLog = homeId == null
          ? const <(String, String)>[]
          : (await _rolesForHome(homeId))[memberId] ??
                const <(String, String)>[];
      result = MemberInfo(
        memberId: memberId,
        role: (r.data['role'] as String?) ?? 'member',
        status: (r.data['status'] as String?) ?? 'active',
        endedHlc: r.data['ended_hlc'] as String?,
        roleLog: roleLog,
      );
    }
    if (local) {
      _members[deviceId] = result;
    }
    return result;
  }

  @override
  Future<Map<String, Object?>?> row(String tbl, String id) async {
    final key = (tbl, id);
    if (local && _rows.containsKey(key)) {
      return _rows[key];
    }
    final Map<String, Object?>? result;
    if (!registry.has(tbl)) {
      result = null;
    } else {
      final spec = registry.spec(tbl);
      final t = spec.table.actualTableName;
      final r = await db
          .customSelect(
            'SELECT * FROM $t WHERE id = ?',
            variables: [Variable.withString(id)],
            readsFrom: {spec.table},
          )
          .getSingleOrNull();
      result = r == null
          ? null
          : {
              for (final e in r.data.entries)
                e.key: spec.columns.containsKey(e.key)
                    ? registry.fromSql(tbl, e.key, e.value)
                    : e.value,
            };
    }
    if (local) {
      _rows[key] = result;
    }
    return result;
  }

  @override
  Future<String?> creatingChangeId(String tbl, String id) async {
    if (local) return null;
    final r = await db
        .customSelect(
          'SELECT change_id FROM ops WHERE tbl = ? AND entity_id = ? '
          "AND status = 'applied' ORDER BY hlc ASC, op_id ASC LIMIT 1",
          variables: [Variable.withString(tbl), Variable.withString(id)],
          readsFrom: {db.ops},
        )
        .getSingleOrNull();
    return r?.data['change_id'] as String?;
  }

  @override
  Set<String> fieldsOf(String tbl) {
    if (!registry.has(tbl)) return const <String>{};
    return registry.spec(tbl).columns.keys.toSet();
  }
}
