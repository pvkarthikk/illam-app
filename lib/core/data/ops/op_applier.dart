import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/merge_rules.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/json_util.dart';

Variable<Object> sqlVar(Object? v) => switch (v) {
  null => const Variable<String>(null),
  String s => Variable.withString(s),
  int i => Variable.withInt(i),
  double d => Variable.withReal(d),
  bool b => Variable.withBool(b),
  _ => throw ArgumentError('$v'),
};

class OpApplier {
  OpApplier(this.db, this.registry);
  final NestDatabase db;
  final CollectionRegistry registry;

  /// Deletes an existing `'pending'` row for [op] and applies [op] as `'applied'`.
  Future<void> applyPending(OpRecord op) async {
    await (db.delete(
      db.ops,
    )..where((o) => o.opId.equals(op.opId) & o.status.equals('pending'))).go();
    await applyOne(op);
  }

  Future<bool> applyOne(OpRecord op) async {
    final value = op.kind == 'set' ? decodeValue(op.valueJson) : null;
    registry.check(
      op.tbl,
      op.field,
      op.kind,
      op.kind == 'set' ? value : op.delta,
    );
    final spec = registry.spec(op.tbl);
    final t = spec.table.actualTableName;

    final existing = await (db.select(
      db.ops,
    )..where((o) => o.opId.equals(op.opId))).getSingleOrNull();
    if (existing != null) return false;
    await db.into(db.ops).insert(op.toCompanion());

    final wall = Hlc.parse(op.hlc).wall;
    await db.customInsert(
      'INSERT OR IGNORE INTO $t (id, home_id, created_at, created_by, updated_at, updated_by) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        sqlVar(op.entityId),
        sqlVar(op.homeId),
        sqlVar(wall),
        sqlVar(op.authorMemberId),
        sqlVar(wall),
        sqlVar(op.authorMemberId),
      ],
      updates: {spec.table},
    );

    await db.customUpdate(
      'UPDATE $t SET created_at = ?, created_by = ? WHERE id = ? AND created_at > ?',
      variables: [
        sqlVar(wall),
        sqlVar(op.authorMemberId),
        sqlVar(op.entityId),
        sqlVar(wall),
      ],
      updates: {spec.table},
    );

    if (op.kind == 'inc') {
      await db.customUpdate(
        'UPDATE $t SET ${op.field} = ${op.field} + ? WHERE id = ?',
        variables: [sqlVar(op.delta), sqlVar(op.entityId)],
        updates: {spec.table},
      );
      return true;
    }

    final clock = await (db.select(db.fieldClocks)
          ..where(
            (c) =>
                c.tbl.equals(op.tbl) &
                c.entityId.equals(op.entityId) &
                c.field.equals(op.field),
          ))
        .getSingleOrNull();
    if (!MergeRules.shouldApplySet(clock?.hlc, op.hlc)) {
      return true;
    }

    await db.customUpdate(
      'UPDATE $t SET ${op.field} = ?, '
      'updated_by = CASE WHEN ? >= updated_at THEN ? ELSE updated_by END, '
      'updated_at = MAX(updated_at, ?) WHERE id = ?',
      variables: [
        sqlVar(value),
        sqlVar(wall),
        sqlVar(op.authorMemberId),
        sqlVar(wall),
        sqlVar(op.entityId),
      ],
      updates: {spec.table},
    );
    await db.into(db.fieldClocks).insertOnConflictUpdate(
      FieldClocksCompanion.insert(
        tbl: op.tbl,
        entityId: op.entityId,
        field: op.field,
        hlc: op.hlc,
      ),
    );
    return true;
  }
}
