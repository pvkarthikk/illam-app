import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/sync/version_vector.dart';
import 'package:nm_flat/core/time/clock.dart';

/// Abstract storage/crypto/ingest dependency surface used by [SyncSession].
abstract class SyncContext {
  String get homeId;
  String get myDeviceId;
  int nowMs();
  Future<String> signAuth(List<int> body);
  Future<bool> verifyPeer(String deviceId, List<int> body, String sig);
  Future<VersionVector> myVector();
  Future<List<String>> memberOpIds();
  Future<List<Map<String, Object?>>> memberOpsWire({
    required Set<String> except,
  });
  Future<List<Map<String, Object?>>> opsAfter(VersionVector theirs);
  Future<void> ingest({
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  });
  Future<void> saveAck(
    String peerDeviceId,
    VersionVector v,
    int memberOps,
    int skewMs,
    int peerVersion,
  );
  Future<void> noteSeen(String deviceId);
}

/// Live Drift + Ed25519 + [IncomingPipeline] implementation of [SyncContext].
class DbSyncContext implements SyncContext {
  DbSyncContext({
    required this.db,
    required this.homeId,
    required this.keys,
    required this.membership,
    required this.incoming,
    required this.clock,
    this.onIngested,
  }) : _store = SyncStore(db);

  final NestDatabase db;
  @override
  final String homeId;
  final DeviceKeys keys;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final Clock clock;
  final void Function()? onIngested;
  final SyncStore _store;

  @override
  String get myDeviceId => keys.deviceId;

  @override
  int nowMs() => clock.nowMs;

  @override
  Future<String> signAuth(List<int> body) async =>
      Signer.sign(await keys.signKeyPair(), SignDomain.auth, body);

  @override
  Future<bool> verifyPeer(String deviceId, List<int> body, String sig) async {
    final row = await (db.select(db.memberDevices)
          ..where(
            (d) =>
                d.deviceId.equals(deviceId) &
                d.homeId.equals(homeId) &
                d.active.equals(true),
          ))
        .getSingleOrNull();
    if (row == null) return false;
    return Signer.verify(decodeKey(row.signPub), SignDomain.auth, body, sig);
  }

  @override
  Future<VersionVector> myVector() => _store.myVector(homeId);

  @override
  Future<List<String>> memberOpIds() => _store.memberOpIds(homeId);

  @override
  Future<List<Map<String, Object?>>> memberOpsWire({
    required Set<String> except,
  }) async {
    final all = await membership.allWire(homeId);
    return [
      for (final m in all)
        if (!except.contains(m['opId'] as String?)) m,
    ];
  }

  @override
  Future<List<Map<String, Object?>>> opsAfter(VersionVector theirs) async =>
      _store.opsAfter(homeId, theirs, await myVector());

  @override
  Future<void> ingest({
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  }) async {
    final rep = await incoming.ingest(homeId, memberOps: memberOps, ops: ops);
    if (rep.applied > 0 || memberOps.isNotEmpty) {
      onIngested?.call();
    }
  }

  @override
  Future<void> saveAck(
    String peerDeviceId,
    VersionVector v,
    int memberOps,
    int skewMs,
    int peerVersion,
  ) => _store.saveAck(
    peerDeviceId,
    homeId,
    v,
    memberOps,
    skewMs,
    peerVersion,
    nowMs(),
  );

  @override
  Future<void> noteSeen(String deviceId) =>
      _store.upsertSeen(deviceId, homeId, null, null, nowMs());
}
