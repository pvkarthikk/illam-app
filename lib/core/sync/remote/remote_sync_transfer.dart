import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/messages.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_crypto.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/sync/version_vector.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/util/ids.dart';

const kMaxRemoteOpsPerBatch = 80;
const kMaxRemotePayloadChars = 260000;
const kRemotePageSize = 50;
const kMaxRemotePagesPerChannel = 20;

final _isoUtcRe = RegExp(
  r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.(\d+))?(?:Z|[+-]\d{2}:?\d{2})?$',
);

int compareFirestoreTimestamps(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  if (a == b) return 0;
  final pa = _parseRfc3339(a);
  final pb = _parseRfc3339(b);
  if (pa != null && pb != null) {
    final secCmp = pa.$1.compareTo(pb.$1);
    return secCmp != 0 ? secCmp : pa.$2.compareTo(pb.$2);
  }
  return a.compareTo(b);
}

(int, int)? _parseRfc3339(String raw) {
  final dt = DateTime.tryParse(raw)?.toUtc();
  if (dt == null) return null;
  final sec = dt.millisecondsSinceEpoch ~/ 1000;
  final m = _isoUtcRe.firstMatch(raw.trim());
  final frac = m?.group(2) ?? '';
  final nanos = frac.isEmpty
      ? 0
      : int.parse(frac.padRight(9, '0').substring(0, 9));
  return (sec, nanos);
}

/// Pulls encrypted remote batches for all keys in [HomeKeyRing] of [homeId].
Future<({RemoteSyncConfig config, int pulled})> pullRemoteChannels({
  required NestDatabase db,
  required HomeKeyRing ring,
  required IncomingPipeline incoming,
  required FirebaseRestClient client,
  required RemoteSyncConfigStore configStore,
  required Clock clock,
  required String homeId,
  required String myDeviceId,
  required RemoteSyncConfig initialConfig,
}) async {
  final store = SyncStore(db);
  var cfg = initialConfig;
  var totalPulled = 0;
  final checkedKeyIds = <String>{};

  for (var pass = 0; pass < 2; pass++) {
    final keys = await ring.all(homeId);
    for (final key in keys) {
      if (checkedKeyIds.contains(key.keyId)) continue;
      checkedKeyIds.add(key.keyId);
      final res = await _pullOneChannel(
        db: db,
        incoming: incoming,
        client: client,
        configStore: configStore,
        clock: clock,
        store: store,
        homeId: homeId,
        myDeviceId: myDeviceId,
        key: key,
        initialConfig: cfg,
      );
      cfg = res.config;
      totalPulled += res.pulled;
    }
    final afterKeys = await ring.all(homeId);
    final hasNewKey = afterKeys.any((k) => !checkedKeyIds.contains(k.keyId));
    if (!hasNewKey) break;
  }
  return (config: cfg, pulled: totalPulled);
}

Future<({RemoteSyncConfig config, int pulled})> _pullOneChannel({
  required NestDatabase db,
  required IncomingPipeline incoming,
  required FirebaseRestClient client,
  required RemoteSyncConfigStore configStore,
  required Clock clock,
  required SyncStore store,
  required String homeId,
  required String myDeviceId,
  required HomeKey key,
  required RemoteSyncConfig initialConfig,
}) async {
  var cfg = initialConfig;
  final channelId = await deriveRemoteChannelId(key.bytes, homeId);
  var pulled = 0;

  for (var page = 0; page < kMaxRemotePagesPerChannel; page++) {
    final cursor = cfg.channelCursors[channelId] ?? ChannelCursor();
    final token =
        cfg.token ?? await client.ensureAuthToken(cfg, nowMs: clock.nowMs);
    final q = await client.queryBatches(
      config: cfg,
      token: token,
      channelId: channelId,
      sinceTimestamp: cursor.lastPulledAt,
      limit: kRemotePageSize,
      nowMs: clock.nowMs,
    );
    cfg = cfg.copyWith(token: q.token);
    if (q.docs.isEmpty) break;

    var curTs = cursor.lastPulledAt;
    var curSeen = Set<String>.from(cursor.seenIds);
    var anyUnseen = false;

    for (final doc in q.docs) {
      final ts = doc.createdAt;
      if (ts != null) {
        final cmp = compareFirestoreTimestamps(ts, curTs);
        if (curTs == null || cmp > 0) {
          curTs = ts;
          curSeen = {doc.docId};
          anyUnseen = true;
        } else {
          if (curSeen.contains(doc.docId)) continue;
          curSeen.add(doc.docId);
          anyUnseen = true;
        }
      } else {
        if (curSeen.contains(doc.docId)) continue;
        curSeen.add(doc.docId);
        anyUnseen = true;
      }

      if (doc.sender == myDeviceId) continue;

      final RemoteBatchPayload batch;
      try {
        batch = await openRemoteBatch(
          homeKeyBytes: key.bytes,
          homeId: homeId,
          channelId: channelId,
          keyId: doc.keyId,
          sender: doc.sender,
          payloadB64: doc.payloadB64,
        );
      } on Object {
        continue;
      }

      final beforeVec = await store.myVector(homeId);
      final beforeM = await store.memberOpCount(homeId);
      final rep = await incoming.ingest(
        homeId,
        memberOps: batch.memberOps,
        ops: batch.ops,
      );
      final afterVec = await store.myVector(homeId);
      final afterM = await store.memberOpCount(homeId);
      pulled += rep.applied + max<int>(0, afterM - beforeM);

      final uploadedVec = Map<String, int>.from(cfg.uploadedVector);
      for (final entry in afterVec.map.entries) {
        if (entry.value > beforeVec[entry.key]) {
          uploadedVec[entry.key] = max(uploadedVec[entry.key] ?? 0, entry.value);
        }
      }
      final uploadedM = Set<String>.from(cfg.uploadedMemberOpIds);
      for (final m in batch.memberOps) {
        final opId = m['opId'];
        if (opId is String && opId.isNotEmpty) uploadedM.add(opId);
      }

      await _savePeerAckIfMember(db, store, clock, homeId, myDeviceId, batch);
      cfg = cfg.copyWith(
        uploadedVector: uploadedVec,
        uploadedMemberOpIds: uploadedM,
      );
    }

    final nextCursors = Map<String, ChannelCursor>.from(cfg.channelCursors);
    nextCursors[channelId] = ChannelCursor(
      lastPulledAt: curTs,
      seenIds: curSeen.toList(),
    );
    cfg = cfg.copyWith(channelCursors: nextCursors);
    await configStore.save(homeId, cfg);

    if (q.docs.length < kRemotePageSize || !anyUnseen) break;
  }
  return (config: cfg, pulled: pulled);
}

Future<void> _savePeerAckIfMember(
  NestDatabase db,
  SyncStore store,
  Clock clock,
  String homeId,
  String myDeviceId,
  RemoteBatchPayload batch,
) async {
  if (batch.sender == myDeviceId) return;
  final devRow =
      await (db.select(db.memberDevices)..where(
            (d) =>
                d.homeId.equals(homeId) &
                d.deviceId.equals(batch.sender) &
                d.active.equals(true),
          ))
          .getSingleOrNull();
  if (devRow == null) return;

  final existing = await (db.select(
    db.syncPeers,
  )..where((p) => p.deviceId.equals(batch.sender))).getSingleOrNull();
  var mergedVec = batch.vector;
  var maxMemberOps = batch.memberOpCount;
  var skew = 0;
  if (existing != null && existing.homeId == homeId) {
    final decoded = jsonDecode(existing.ackedVectorJson) as Map<String, Object?>;
    mergedVec = VersionVector.fromJson(decoded).merge(batch.vector);
    maxMemberOps = max(existing.ackedMemberOps, batch.memberOpCount);
    skew = existing.clockSkewMs;
  }
  await store.saveAck(
    batch.sender,
    homeId,
    mergedVec,
    maxMemberOps,
    skew,
    kSyncProtocolVersion,
    clock.nowMs,
  );
}

/// Pushes un-uploaded local ops and membership ops in chunked E2EE Firestore batches.
Future<({RemoteSyncConfig config, int pushed})> pushRemotePending({
  required NestDatabase db,
  required HomeKeyRing ring,
  required MembershipLog membership,
  required FirebaseRestClient client,
  required RemoteSyncConfigStore configStore,
  required Clock clock,
  required String homeId,
  required String myDeviceId,
  required RemoteSyncConfig initialConfig,
}) async {
  final keys = await ring.all(homeId);
  if (keys.isEmpty) return (config: initialConfig, pushed: 0);

  var cfg = initialConfig;
  final currentKey = keys.first;
  final store = SyncStore(db);
  final myVec = await store.myVector(homeId);
  final opsToPush = await store.opsAfter(
    homeId,
    VersionVector(cfg.uploadedVector),
    myVec,
  );
  final allMemberWire = await membership.allWire(homeId);
  final memberOpsToPush = [
    for (final m in allMemberWire)
      if (!cfg.uploadedMemberOpIds.contains(m['opId'] as String?)) m,
  ];
  if (opsToPush.isEmpty && memberOpsToPush.isEmpty) {
    return (config: cfg, pushed: 0);
  }

  final hasRotation = memberOpsToPush.any((m) => m['type'] == 'rotateKey');
  if (hasRotation && keys.length > 1) {
    final rotSealed = await _sealBatch(
      homeId,
      keys[1],
      myDeviceId,
      clock.nowMs,
      myVec,
      allMemberWire.length,
      memberOpsToPush,
      const [],
    );
    cfg = await _commitSealed(
      client: client,
      clock: clock,
      config: cfg,
      channelId: rotSealed.channelId,
      sender: myDeviceId,
      keyId: keys[1].keyId,
      payloadB64: rotSealed.payloadB64,
    );
  }

  var pushed = 0;
  var idx = 0;
  var firstBatch = true;
  do {
    final remaining = opsToPush.length - idx;
    var take = min(kMaxRemoteOpsPerBatch, remaining);
    final batchMemberOps = firstBatch
        ? memberOpsToPush
        : const <Map<String, Object?>>[];
    firstBatch = false;

    var chunk = opsToPush.sublist(idx, idx + take);
    var sealed = await _sealBatch(
      homeId,
      currentKey,
      myDeviceId,
      clock.nowMs,
      myVec,
      allMemberWire.length,
      batchMemberOps,
      chunk,
    );
    while (sealed.payloadB64.length > kMaxRemotePayloadChars && take > 1) {
      take = max(1, take ~/ 2);
      chunk = opsToPush.sublist(idx, idx + take);
      sealed = await _sealBatch(
        homeId,
        currentKey,
        myDeviceId,
        clock.nowMs,
        myVec,
        allMemberWire.length,
        batchMemberOps,
        chunk,
      );
    }

    cfg = await _commitSealed(
      client: client,
      clock: clock,
      config: cfg,
      channelId: sealed.channelId,
      sender: myDeviceId,
      keyId: currentKey.keyId,
      payloadB64: sealed.payloadB64,
    );

    final uploadedVec = Map<String, int>.from(cfg.uploadedVector);
    for (final op in chunk) {
      final dev = op['deviceId'] as String?;
      final seq = (op['seq'] as num?)?.toInt();
      if (dev != null && seq != null) {
        uploadedVec[dev] = max(uploadedVec[dev] ?? 0, seq);
      }
    }
    final uploadedM = Set<String>.from(cfg.uploadedMemberOpIds);
    for (final m in batchMemberOps) {
      final id = m['opId'] as String?;
      if (id != null && id.isNotEmpty) uploadedM.add(id);
    }

    cfg = cfg.copyWith(
      uploadedVector: uploadedVec,
      uploadedMemberOpIds: uploadedM,
    );
    await configStore.save(homeId, cfg);
    pushed += chunk.length + batchMemberOps.length;
    idx += take;
  } while (idx < opsToPush.length);

  return (config: cfg, pushed: pushed);
}

Future<RemoteSyncConfig> _commitSealed({
  required FirebaseRestClient client,
  required Clock clock,
  required RemoteSyncConfig config,
  required String channelId,
  required String sender,
  required String keyId,
  required String payloadB64,
}) async {
  final token =
      config.token ?? await client.ensureAuthToken(config, nowMs: clock.nowMs);
  final res = await client.commitBatch(
    config: config,
    token: token,
    channelId: channelId,
    batchId: Ids.newId(),
    sender: sender,
    keyId: keyId,
    payloadB64: payloadB64,
    expiresAtUtc: clock.now().toUtc().add(const Duration(days: 30)),
    nowMs: clock.nowMs,
  );
  return config.copyWith(token: res.token);
}

Future<({String channelId, String payloadB64})> _sealBatch(
  String homeId,
  HomeKey key,
  String sender,
  int sentAt,
  VersionVector vector,
  int memberOpCount,
  List<Map<String, Object?>> memberOps,
  List<Map<String, Object?>> ops,
) => sealRemoteBatch(
  homeKeyBytes: key.bytes,
  keyId: key.keyId,
  payload: RemoteBatchPayload(
    homeId: homeId,
    sender: sender,
    sentAt: sentAt,
    vector: vector,
    memberOpCount: memberOpCount,
    memberOps: memberOps,
    ops: ops,
  ),
);
