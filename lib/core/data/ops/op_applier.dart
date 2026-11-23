import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/json_util.dart';

/// sqlite3 binds `int`, `double`, `String`, `null` and bytes only, so Dart
/// `bool` values in a batched statement must be written as `0` / `1`.
Object? _bound(Object? v) => switch (v) {
  null => null,
  bool b => b ? 1 : 0,
  int i => i,
  double d => d,
  String s => s,
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

  /// Applies one op and returns `false` when its [OpRecord.opId] is already stored.
  Future<bool> applyOne(OpRecord op) async {
    final value = _decodeAndCheck(op);
    final existing = await (db.select(
      db.ops,
    )..where((o) => o.opId.equals(op.opId))).getSingleOrNull();
    if (existing != null) return false;
    await db.into(db.ops).insert(op.toCompanion());
    await _applyEffects([(op, value)]);
    return true;
  }

  /// Applies a whole local change in a single round trip: op rows and their
  /// effects go into one batch. Only safe when the op ids are known to be fresh
  /// — [ChangeWriter] allocates them from `MAX(seq) + 1` inside the same
  /// transaction, so they cannot collide with stored rows.
  Future<void> applyLocal(List<OpRecord> recs) async {
    if (recs.isEmpty) return;
    final decoded = [for (final rec in recs) _decodeAndCheck(rec)];
    await db.batch((b) {
      for (var i = 0; i < recs.length; i++) {
        b.insert(db.ops, recs[i].toCompanion());
        _addEffects(b, recs[i], decoded[i]);
      }
    });
  }

  Object? _decodeAndCheck(OpRecord op) {
    final value = op.kind == 'set' ? decodeValue(op.valueJson) : null;
    registry.check(
      op.tbl,
      op.field,
      op.kind,
      op.kind == 'set' ? value : op.delta,
    );
    return value;
  }

  Future<void> _applyEffects(List<(OpRecord, Object?)> applied) =>
      db.batch((b) {
        for (final (op, value) in applied) {
          _addEffects(b, op, value);
        }
      });

  /// Everything one op changes, as statements of a single batch (one message
  /// to the database isolate instead of one per statement).
  void _addEffects(Batch b, OpRecord op, Object? value) {
    final spec = registry.spec(op.tbl);
    final t = spec.table.actualTableName;
    final clocks = db.fieldClocks.actualTableName;
    final wall = Hlc.parse(op.hlc).wall;
    final onTable = TableUpdate.onTable(spec.table, kind: UpdateKind.update);

    b.customStatement(
      'INSERT OR IGNORE INTO $t (id, home_id, created_at, created_by, updated_at, updated_by) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [
        _bound(op.entityId),
        _bound(op.homeId),
        wall,
        _bound(op.authorMemberId),
        wall,
        _bound(op.authorMemberId),
      ],
      [TableUpdate.onTable(spec.table, kind: UpdateKind.insert)],
    );

    // The earliest op seen for a row also owns its creation stamp.
    b.customStatement(
      'UPDATE $t SET created_at = ?, created_by = ? WHERE id = ? AND created_at > ?',
      [wall, _bound(op.authorMemberId), _bound(op.entityId), wall],
      [onTable],
    );

    if (op.kind == 'inc') {
      b.customStatement(
        'UPDATE $t SET ${op.field} = ${op.field} + ? WHERE id = ?',
        [op.delta, _bound(op.entityId)],
        [onTable],
      );
      return;
    }

    // Last writer wins per field (MergeRules.shouldApplySet, evaluated in SQL):
    // skip when a clock for this field is at or newer than the op.
    b.customStatement(
      'UPDATE $t SET ${op.field} = ?, '
      'updated_by = CASE WHEN ? >= updated_at THEN ? ELSE updated_by END, '
      'updated_at = MAX(updated_at, ?) WHERE id = ? '
      'AND NOT EXISTS (SELECT 1 FROM $clocks c '
      'WHERE c.tbl = ? AND c.entity_id = ? AND c.field = ? AND c.hlc >= ?)',
      [
        _bound(value),
        wall,
        _bound(op.authorMemberId),
        wall,
        _bound(op.entityId),
        _bound(op.tbl),
        _bound(op.entityId),
        _bound(op.field),
        op.hlc,
      ],
      [onTable],
    );

    // Storing the newest clock keeps this safe even when the update above did
    // not run because the op lost: the clock never moves backwards.
    b.customStatement(
      'INSERT INTO $clocks (tbl, entity_id, field, hlc) VALUES (?, ?, ?, ?) '
      'ON CONFLICT(tbl, entity_id, field) DO UPDATE SET hlc = excluded.hlc '
      'WHERE excluded.hlc > hlc',
      [_bound(op.tbl), _bound(op.entityId), _bound(op.field), op.hlc],
      [TableUpdate.onTable(db.fieldClocks, kind: UpdateKind.insert)],
    );
  }
}
