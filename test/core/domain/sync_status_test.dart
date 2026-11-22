import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 12).millisecondsSinceEpoch;
  const me = DeviceInfo('me', 'm1', 'Meera', 'Pixel');
  const p = DeviceInfo('p', 'm2', 'Priya', 'Galaxy');
  const a = DeviceInfo('a', 'm3', 'Arjun', 'Redmi');
  const myVec = VersionVector({'me': 10});

  group('computeSyncSummary', () {
    test('only my device', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me],
        acks: const {},
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.onlyThisPhone, isTrue);
      expect(s.allInSync, isTrue);
    });

    test('connected peer with exact ack is in sync', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, p],
        acks: {
          'p': PeerAck(
            vector: myVec,
            memberOps: 3,
            lastSyncAt: now - 2 * 60 * 1000,
          ),
        },
        myVector: myVec,
        myMemberOps: 3,
        connected: const {'p'},
        nowMs: now,
      );
      expect(s.rows[1].state, PeerState.connected);
      expect(s.rows[1].behindBy, 0);
      expect(s.allInSync, isTrue);
    });

    test('peer behind by ops shows synced, behindBy 4, notUpToDate 1', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, a],
        acks: {
          'a': PeerAck(
            vector: const VersionVector({'me': 6}),
            memberOps: 3,
            lastSyncAt: now - 190 * 60 * 1000,
          ),
        },
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.rows[1].state, PeerState.synced);
      expect(s.rows[1].behindBy, 4);
      expect(s.notUpToDate, 1);
    });

    test('peer >= 24h ago is stale', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, a],
        acks: {
          'a': PeerAck(
            vector: myVec,
            memberOps: 3,
            lastSyncAt: now - 3 * 24 * 60 * 60 * 1000,
          ),
        },
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.rows[1].state, PeerState.stale);
    });

    test('peer without ack is never, behindBy 13, notUpToDate 1', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, a],
        acks: const {},
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.rows[1].state, PeerState.never);
      expect(s.rows[1].behindBy, 13);
      expect(s.notUpToDate, 1);
    });

    test('clockSkewMs > 5 min triggers clockWarning', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, a],
        acks: {
          'a': PeerAck(
            vector: myVec,
            memberOps: 3,
            lastSyncAt: now - 60000,
            clockSkewMs: 6 * 60 * 1000,
          ),
        },
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.clockWarning, isTrue);
    });

    test('freshest picks most recently synced peer', () {
      final s = computeSyncSummary(
        myDeviceId: 'me',
        devices: const [me, a, p],
        acks: {
          'p': PeerAck(
            vector: myVec,
            memberOps: 3,
            lastSyncAt: now - 2 * 60 * 1000,
          ),
          'a': PeerAck(
            vector: myVec,
            memberOps: 3,
            lastSyncAt: now - 190 * 60 * 1000,
          ),
        },
        myVector: myVec,
        myMemberOps: 3,
        connected: const {},
        nowMs: now,
      );
      expect(s.freshest?.device.name, 'Priya');
    });
  });

  test('agoParts buckets match specification', () {
    expect(agoParts(now, now - 30 * 1000), (AgoUnit.now, 0));
    expect(agoParts(now, now - 5 * 60 * 1000), (AgoUnit.minutes, 5));
    expect(agoParts(now, now - 190 * 60 * 1000), (AgoUnit.hours, 3));
    expect(agoParts(now, now - 3 * 24 * 60 * 60 * 1000), (AgoUnit.days, 3));
  });
}
