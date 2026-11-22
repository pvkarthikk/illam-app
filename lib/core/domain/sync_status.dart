import 'dart:math';

import 'package:nm_flat/core/sync/version_vector.dart';

enum PeerState { thisPhone, connected, synced, stale, never }

enum AgoUnit { now, minutes, hours, days }

class DeviceInfo {
  const DeviceInfo(this.deviceId, this.memberId, this.name, this.model);

  final String deviceId;
  final String memberId;
  final String name;
  final String model;
}

class PeerAck {
  const PeerAck({
    required this.vector,
    required this.memberOps,
    required this.lastSyncAt,
    this.clockSkewMs = 0,
  });

  final VersionVector vector;
  final int memberOps;
  final int lastSyncAt;
  final int clockSkewMs;
}

class PeerRow {
  const PeerRow(this.device, this.state, this.behindBy, this.lastSyncAt);

  final DeviceInfo device;
  final PeerState state;
  final int behindBy;
  final int lastSyncAt;
}

class SyncSummary {
  const SyncSummary(
    this.rows,
    this.notUpToDate,
    this.lastSyncAt,
    this.freshest,
    this.clockWarning,
  );

  final List<PeerRow> rows;
  final int notUpToDate;
  final int lastSyncAt;
  final PeerRow? freshest;
  final bool clockWarning;

  bool get onlyThisPhone => rows.length <= 1;
  bool get allInSync => notUpToDate == 0;
}

const _min5Ms = 5 * 60 * 1000;
const _min60Ms = 60 * 60 * 1000;
const _dayMs = 24 * 60 * 60 * 1000;

/// Computes elapsed time bucket and whole unit count between [thenMs] and [nowMs].
(AgoUnit, int) agoParts(int nowMs, int thenMs) {
  final diff = max(0, nowMs - thenMs);
  if (diff < 60 * 1000) return (AgoUnit.now, 0);
  if (diff < _min60Ms) return (AgoUnit.minutes, diff ~/ (60 * 1000));
  if (diff < _dayMs) return (AgoUnit.hours, diff ~/ _min60Ms);
  return (AgoUnit.days, diff ~/ _dayMs);
}

/// Computes the per-device sync summary for UI badges and cards.
SyncSummary computeSyncSummary({
  required String myDeviceId,
  required List<DeviceInfo> devices,
  required Map<String, PeerAck> acks,
  required VersionVector myVector,
  required int myMemberOps,
  required Set<String> connected,
  required int nowMs,
}) {
  final myDevice = devices.where((d) => d.deviceId == myDeviceId).firstOrNull;
  final rows = <PeerRow>[
    if (myDevice != null) PeerRow(myDevice, PeerState.thisPhone, 0, 0),
  ];

  final myTotal =
      myVector.map.values.fold<int>(0, (sum, v) => sum + v) + myMemberOps;
  final otherRows = <PeerRow>[];

  for (final d in devices) {
    if (d.deviceId == myDeviceId) continue;
    final ack = acks[d.deviceId];
    if (ack == null) {
      otherRows.add(PeerRow(d, PeerState.never, myTotal, 0));
      continue;
    }

    final behindBy =
        myVector.missingIn(ack.vector) + max<int>(0, myMemberOps - ack.memberOps);
    final PeerState st;
    if (connected.contains(d.deviceId)) {
      st = PeerState.connected;
    } else if (ack.lastSyncAt == 0) {
      st = PeerState.never;
    } else if (nowMs - ack.lastSyncAt >= _dayMs) {
      st = PeerState.stale;
    } else {
      st = PeerState.synced;
    }
    otherRows.add(PeerRow(d, st, behindBy, ack.lastSyncAt));
  }

  rows.addAll(otherRows);

  final notUpToDate = otherRows
      .where((r) => r.behindBy > 0 || r.state == PeerState.never)
      .length;
  var lastSyncAt = 0;
  PeerRow? freshest;
  for (final r in otherRows) {
    if (r.lastSyncAt > lastSyncAt) {
      lastSyncAt = r.lastSyncAt;
      freshest = r;
    }
  }
  final clockWarning = acks.values.any((a) => a.clockSkewMs.abs() > _min5Ms);

  return SyncSummary(rows, notUpToDate, lastSyncAt, freshest, clockWarning);
}
