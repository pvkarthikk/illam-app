import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/sync/version_vector.dart';
import 'package:nm_flat/core/time/clock.dart';

/// Replay-derived active/control status for both endpoints in a session.
class PeerSituation {
  const PeerSituation({
    required this.peerActive,
    required this.meActive,
    this.peerNoticeKind,
    this.peerNoticeOpId,
    this.peerNoticeReason,
    this.peerNoticeAt,
    this.myEraseReason,
    this.myEraseByName,
  });

  final bool peerActive;
  final bool meActive;
  final String? peerNoticeKind;
  final String? peerNoticeOpId;
  final String? peerNoticeReason;
  final int? peerNoticeAt;
  final String? myEraseReason;
  final String? myEraseByName;

  bool get isFull => peerActive && meActive;
}

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

/// Extended control-session & erasure hooks optionally implemented by [SyncContext].
abstract class ControlSyncContext {
  Future<bool> isHomeErased();
  Future<PeerSituation> evaluateSituation(String peerDeviceId);
  Future<bool> onAckMemberOpIds(List<String> ids);
  Future<void> eraseMyHome(String reason, {String? byName});
}

/// Optional restore-awareness hooks for verifying restored devices and updating prefs.
abstract class RestoreSyncContext {
  String get mySignPubB64;
  Future<bool> verifyPeerWithPub(
    String deviceId,
    List<int> body,
    String sig,
    String? signPubB64,
  );
  Future<void> onFullAck();
  Future<void> onRecoverDead(String reason, int at);
}

/// Live Drift + Ed25519 + [IncomingPipeline] implementation of [SyncContext].
class DbSyncContext
    implements SyncContext, ControlSyncContext, RestoreSyncContext {
  DbSyncContext({
    required this.db,
    required this.homeId,
    required this.keys,
    required this.membership,
    required this.incoming,
    required this.clock,
    this.prefs,
    this.controlStore,
    this.homeEraser,
    this.onIngested,
  }) : _store = SyncStore(db);

  final NestDatabase db;
  @override
  final String homeId;
  final DeviceKeys keys;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final Clock clock;
  final DevicePrefs? prefs;
  final ControlStore? controlStore;
  final HomeEraser? homeEraser;
  final void Function()? onIngested;
  final SyncStore _store;

  @override
  String get myDeviceId => keys.deviceId;

  @override
  String get mySignPubB64 => keys.signPubB64;

  @override
  int nowMs() => clock.nowMs;

  @override
  Future<bool> isHomeErased() async {
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    if (home != null) return false;
    final memOps = await (db.select(
      db.memberOps,
    )..where((m) => m.homeId.equals(homeId))..limit(1)).getSingleOrNull();
    return memOps == null;
  }

  @override
  Future<String> signAuth(List<int> body) async =>
      Signer.sign(await keys.signKeyPair(), SignDomain.auth, body);

  @override
  Future<bool> verifyPeer(String deviceId, List<int> body, String sig) =>
      verifyPeerWithPub(deviceId, body, sig, null);

  @override
  Future<bool> verifyPeerWithPub(
    String deviceId,
    List<int> body,
    String sig,
    String? signPubB64,
  ) async {
    final row = await (db.select(db.memberDevices)
          ..where((d) => d.deviceId.equals(deviceId) & d.homeId.equals(homeId)))
        .getSingleOrNull();
    if (row != null) {
      return Signer.verify(decodeKey(row.signPub), SignDomain.auth, body, sig);
    }
    if (signPubB64 == null || signPubB64.isEmpty) return false;
    try {
      final pubBytes = decodeKey(signPubB64);
      if (await DeviceKeys.deviceIdFor(pubBytes) != deviceId) return false;
      return await Signer.verify(pubBytes, SignDomain.auth, body, sig);
    } on Object {
      return false;
    }
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
    if (await isHomeErased()) return;
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

  Future<String?> _memberName(String? memberId, ReplayResult r) async {
    if (memberId == null || memberId.isEmpty) return null;
    final row = await (db.select(db.members)
          ..where((m) => m.id.equals(memberId) & m.homeId.equals(homeId)))
        .getSingleOrNull();
    if (row != null) {
      if (row.firstName != null && row.firstName!.isNotEmpty) {
        return row.firstName!;
      }
      if (row.fullName != null && row.fullName!.isNotEmpty) {
        return Names.firstName(row.fullName!);
      }
    }
    final fallback = r.members[memberId]?.name ?? '';
    return fallback.isEmpty ? null : Names.firstName(fallback);
  }

  Future<String> _findAppliedOpId(
    String opType, {
    String? targetMemberId,
    String? authorMemberId,
    ReplayResult? replay,
  }) async {
    final rows =
        await (db.select(db.memberOps)
              ..where(
                (t) =>
                    t.homeId.equals(homeId) &
                    t.opType.equals(opType) &
                    t.effect.equals('applied'),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.hlc),
                (t) => OrderingTerm.desc(t.opId),
              ]))
            .get();
    for (final row in rows) {
      if (targetMemberId != null) {
        final payload = jsonDecode(row.payloadJson) as Map<String, Object?>;
        if (payload['memberId'] != targetMemberId) continue;
      }
      if (authorMemberId != null && replay != null) {
        final authorMId = replay.devices[row.authorDeviceId]?.memberId;
        if (authorMId != authorMemberId) continue;
      }
      return row.opId;
    }
    return '';
  }

  @override
  Future<PeerSituation> evaluateSituation(String peerDeviceId) async {
    final r = await membership.replayState(homeId);
    final peerActive = r.isActiveDevice(peerDeviceId);
    final meActive = r.isActiveDevice(myDeviceId);

    String? peerKind;
    String? peerOpId;
    String? peerReason;
    int? peerAt;
    if (!peerActive) {
      final recoverRow =
          await (db.select(db.memberOps)
                ..where(
                  (t) =>
                      t.homeId.equals(homeId) &
                      t.opType.equals('recover') &
                      t.authorDeviceId.equals(peerDeviceId),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.hlc)])
                ..limit(1))
              .getSingleOrNull();
      if (recoverRow != null && recoverRow.effect == 'ignored') {
        final p = jsonDecode(recoverRow.payloadJson) as Map<String, Object?>;
        final kitPub = p['kitPub'] as String?;
        final dead = kitPub == null ? null : r.deadReason(kitPub);
        peerKind = 'recoverDead';
        peerOpId = recoverRow.opId;
        peerReason = dead?.reason ?? 'revoked';
        peerAt = (dead != null && dead.hlc.isNotEmpty)
            ? hlcWall(dead.hlc)
            : nowMs();
      } else {
        final peerMId = r.devices[peerDeviceId]?.memberId;
        final peerStatus = peerMId == null ? null : r.members[peerMId]?.status;
        if (r.deleted) {
          peerKind = 'deleted';
          peerOpId = await _findAppliedOpId('deleteHome');
        } else if (peerStatus == 'left') {
          peerKind = 'left';
          peerOpId = await _findAppliedOpId(
            'leave',
            authorMemberId: peerMId,
            replay: r,
          );
        } else {
          peerKind = 'removed';
          peerOpId = await _findAppliedOpId(
            'removeMember',
            targetMemberId: peerMId,
          );
        }
      }
    }

    String? myReason;
    String? myByName;
    if (!meActive) {
      final myDev = r.devices[myDeviceId];
      final myMId = myDev?.memberId;
      final myStatus = myMId == null ? null : r.members[myMId]?.status;
      if (r.deleted) {
        myReason = 'deleted';
        myByName = await _memberName(r.deletedByMemberId, r);
      } else if (myDev == null) {
        myReason = null;
      } else if (myStatus == 'left') {
        myReason = 'left';
      } else {
        myReason = 'removed';
        final rows =
            await (db.select(db.memberOps)
                  ..where(
                    (t) =>
                        t.homeId.equals(homeId) &
                        t.opType.equals('removeMember') &
                        t.effect.equals('applied'),
                  )
                  ..orderBy([(t) => OrderingTerm.desc(t.hlc)]))
                .get();
        for (final row in rows) {
          final p = jsonDecode(row.payloadJson) as Map<String, Object?>;
          if (p['memberId'] == myMId) {
            final removerMId = r.devices[row.authorDeviceId]?.memberId;
            myByName = await _memberName(removerMId, r);
            break;
          }
        }
      }
    }

    return PeerSituation(
      peerActive: peerActive,
      meActive: meActive,
      peerNoticeKind: peerKind,
      peerNoticeOpId: peerOpId,
      peerNoticeReason: peerReason,
      peerNoticeAt: peerAt,
      myEraseReason: myReason,
      myEraseByName: myByName,
    );
  }

  @override
  Future<void> onFullAck() async {
    final p = prefs;
    if (p == null) return;
    await p.setText('provisionalRestore_$homeId', null);
    await p.setText('provisionalRestoreAt_$homeId', null);
  }

  @override
  Future<void> onRecoverDead(String reason, int at) async {
    final p = prefs;
    if (p == null) return;
    await p.setText(
      'recoverDead_$homeId',
      jsonEncode({'reason': reason, 'at': at}),
    );
  }

  @override
  Future<bool> onAckMemberOpIds(List<String> ids) async {
    final cs = controlStore;
    if (cs == null || ids.isEmpty) return false;
    final idSet = ids.toSet();
    final pending = await cs.pendingOutbox(homeId);
    final matchedPendingLeave = pending.any((e) => idSet.contains(e.opId));
    for (final id in ids) {
      await cs.markAcked(id);
    }
    return matchedPendingLeave;
  }

  @override
  Future<void> eraseMyHome(String reason, {String? byName}) async {
    if (homeEraser == null || await isHomeErased()) return;
    await homeEraser!.eraseWithTombstone(
      homeId,
      reason: reason,
      byName: byName,
      shown: false,
    );
  }
}
