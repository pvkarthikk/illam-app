import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';

/// Reads stored sync operations for a home in wire form.
class SyncStore {
  SyncStore(this.db);

  final NestDatabase db;

  /// Returns every applied or quarantined op for [homeId], ordered by `(device_id, seq)`.
  Future<List<Map<String, Object?>>> allOpsWire(String homeId) async {
    final rows =
        await (db.select(db.ops)
              ..where(
                (o) =>
                    o.homeId.equals(homeId) &
                    o.status.isIn(const ['applied', 'quarantined']),
              )
              ..orderBy([
                (o) => OrderingTerm.asc(o.deviceId),
                (o) => OrderingTerm.asc(o.seq),
              ]))
            .get();
    return [for (final r in rows) opToWire(OpRecord.fromRow(r))];
  }
}
