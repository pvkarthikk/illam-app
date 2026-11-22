import 'package:nm_flat/core/data/ops/merge_rules.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/util/json_util.dart';

class InMemoryReplica {
  final rows = <String, Map<String, Object?>>{};
  final _clocks = <String, String>{};
  final _seen = <String>{};

  void apply(OpRecord op) {
    if (!_seen.add(op.opId)) return;
    final rowKey = '${op.tbl}/${op.entityId}';
    final row = rows.putIfAbsent(rowKey, () => <String, Object?>{});

    if (op.kind == 'inc') {
      final delta = op.delta;
      if (delta == null) return;
      row[op.field] = MergeRules.applyInc(
        (row[op.field] as int?) ?? 0,
        delta,
      );
      return;
    }

    if (op.kind == 'set') {
      final clockKey = '${op.tbl}/${op.entityId}/${op.field}';
      if (MergeRules.shouldApplySet(_clocks[clockKey], op.hlc)) {
        row[op.field] = decodeValue(op.valueJson);
        _clocks[clockKey] = op.hlc;
      }
    }
  }
}
