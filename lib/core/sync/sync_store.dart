import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

/// Reads stored sync operations and manages sync peer state in Drift.
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

  /// Highest contiguous sequence numbers per device across all stored ops of [homeId].
  Future<VersionVector> myVector(String homeId) async {
    final rows = await db
        .customSelect(
          'SELECT device_id, MAX(seq) AS mx, COUNT(*) AS n '
          'FROM ops WHERE home_id = ? GROUP BY device_id',
          variables: [Variable.withString(homeId)],
        )
        .get();

    final out = <String, int>{};
    for (final r in rows) {
      final dev = r.data['device_id'] as String;
      final mx = r.data['mx'] as int;
      final n = r.data['n'] as int;
      if (mx == n) {
        out[dev] = mx;
      } else {
        final seqRows = await db
            .customSelect(
              'SELECT seq FROM ops WHERE home_id = ? AND device_id = ?',
              variables: [Variable.withString(homeId), Variable.withString(dev)],
            )
            .get();
        final v = VersionVector.fromSeqs({
          dev: [for (final s in seqRows) s.data['seq'] as int],
        });
        out[dev] = v[dev];
      }
    }
    return VersionVector(out);
  }

  /// Returns applied or quarantined ops of [homeId] present in [mine] beyond [theirs].
  Future<List<Map<String, Object?>>> opsAfter(
    String homeId,
    VersionVector theirs,
    VersionVector mine,
  ) async {
    final out = <Map<String, Object?>>[];
    for (final entry in mine.map.entries) {
      final dev = entry.key;
      final hi = entry.value;
      final lo = theirs[dev];
      if (hi <= lo) continue;

      final rows =
          await (db.select(db.ops)
                ..where(
                  (o) =>
                      o.homeId.equals(homeId) &
                      o.deviceId.equals(dev) &
                      o.seq.isBiggerThanValue(lo) &
                      o.seq.isSmallerOrEqualValue(hi) &
                      o.status.isIn(const ['applied', 'quarantined']),
                )
                ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
              .get();
      for (final r in rows) {
        out.add(opToWire(OpRecord.fromRow(r)));
      }
    }
    return out;
  }

  Future<int> memberOpCount(String homeId) async {
    final r = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM member_ops WHERE home_id = ?',
          variables: [Variable.withString(homeId)],
        )
        .getSingle();
    return r.data['n'] as int;
  }

  Future<List<String>> memberOpIds(String homeId) async {
    final rows =
        await (db.selectOnly(db.memberOps)
              ..addColumns([db.memberOps.opId])
              ..where(db.memberOps.homeId.equals(homeId)))
            .get();
    return [for (final r in rows) r.read(db.memberOps.opId)!];
  }

  Stream<List<SyncPeerRow>> watchPeers(String homeId) =>
      (db.select(db.syncPeers)..where((t) => t.homeId.equals(homeId))).watch();

  Future<List<SyncPeerRow>> peers(String homeId) =>
      (db.select(db.syncPeers)..where((t) => t.homeId.equals(homeId))).get();

  Future<void> upsertSeen(
    String deviceId,
    String homeId,
    String? host,
    int? port,
    int nowMs,
  ) => db.transaction(() async {
    final existing = await (db.select(
      db.syncPeers,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.syncPeers)
          .insert(
            SyncPeersCompanion.insert(
              deviceId: deviceId,
              homeId: homeId,
              lastSeenAt: Value(nowMs),
              lastHost: Value(host),
              lastPort: Value(port),
            ),
          );
    } else {
      await (db.update(
        db.syncPeers,
      )..where((t) => t.deviceId.equals(deviceId))).write(
        SyncPeersCompanion(
          homeId: Value(homeId),
          lastSeenAt: Value(nowMs),
          lastHost: host != null ? Value(host) : const Value.absent(),
          lastPort: port != null ? Value(port) : const Value.absent(),
        ),
      );
    }
  });

  Future<void> saveAck(
    String deviceId,
    String homeId,
    VersionVector v,
    int memberOps,
    int skew,
    int version,
    int nowMs,
  ) => db.transaction(() async {
    final existing = await (db.select(
      db.syncPeers,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    final vecJson = jsonEncode(v.toJson());
    if (existing == null) {
      await db
          .into(db.syncPeers)
          .insert(
            SyncPeersCompanion.insert(
              deviceId: deviceId,
              homeId: homeId,
              lastSeenAt: Value(nowMs),
              lastSyncAt: Value(nowMs),
              ackedVectorJson: Value(vecJson),
              ackedMemberOps: Value(memberOps),
              clockSkewMs: Value(skew),
              peerVersion: Value(version),
            ),
          );
    } else {
      await (db.update(
        db.syncPeers,
      )..where((t) => t.deviceId.equals(deviceId))).write(
        SyncPeersCompanion(
          homeId: Value(homeId),
          lastSeenAt: Value(nowMs),
          lastSyncAt: Value(nowMs),
          ackedVectorJson: Value(vecJson),
          ackedMemberOps: Value(memberOps),
          clockSkewMs: Value(skew),
          peerVersion: Value(version),
        ),
      );
    }
  });
}
