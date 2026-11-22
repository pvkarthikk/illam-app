import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/session/sync_context.dart';
import 'package:nm_flat/core/sync/session/sync_session.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

class FakeSyncContext implements SyncContext {
  FakeSyncContext({
    required this.homeId,
    required this.myDeviceId,
    this.now = 1763600000000,
    this.verifyResult = true,
  });

  @override
  final String homeId;
  @override
  final String myDeviceId;
  final int now;
  bool verifyResult;

  final Map<String, Map<String, Object?>> ops = {};
  VersionVector? lastAck;

  @override
  int nowMs() => now;

  @override
  Future<String> signAuth(List<int> body) async => 'ok';

  @override
  Future<bool> verifyPeer(String deviceId, List<int> body, String sig) async =>
      verifyResult;

  @override
  Future<VersionVector> myVector() async {
    final byDev = <String, List<int>>{};
    for (final op in ops.values) {
      final d = op['deviceId'] as String;
      final s = op['seq'] as int;
      (byDev[d] ??= []).add(s);
    }
    return VersionVector.fromSeqs(byDev);
  }

  @override
  Future<List<String>> memberOpIds() async => const [];

  @override
  Future<List<Map<String, Object?>>> memberOpsWire({
    required Set<String> except,
  }) async => const [];

  @override
  Future<List<Map<String, Object?>>> opsAfter(VersionVector theirs) async {
    final mine = await myVector();
    final out = <Map<String, Object?>>[];
    for (final op in ops.values) {
      final d = op['deviceId'] as String;
      final s = op['seq'] as int;
      if (s > theirs[d] && s <= mine[d]) {
        out.add(op);
      }
    }
    out.sort((a, b) {
      final d = (a['deviceId'] as String).compareTo(b['deviceId'] as String);
      if (d != 0) return d;
      return (a['seq'] as int).compareTo(b['seq'] as int);
    });
    return out;
  }

  @override
  Future<void> ingest({
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  }) async {
    for (final op in ops) {
      this.ops['${op['deviceId']}:${op['seq']}'] = op;
    }
  }

  @override
  Future<void> saveAck(
    String peerDeviceId,
    VersionVector v,
    int memberOps,
    int skewMs,
    int peerVersion,
  ) async {
    lastAck = v;
  }

  @override
  Future<void> noteSeen(String deviceId) async {}

  void addOp(String dev, int seq) {
    ops['$dev:$seq'] = {'deviceId': dev, 'seq': seq, 'opId': '$dev:$seq'};
  }
}

Future<
  ({
    SyncSession a,
    SyncSession b,
    Future<void> runA,
    Future<void> runB,
  })
>
_connect(FakeSyncContext ctxA, FakeSyncContext ctxB) async {
  final (c1, c2) = FramedConnection.memoryPair();
  final chs = await Future.wait([
    SecureChannel.handshake(c1, initiator: true),
    SecureChannel.handshake(c2, initiator: false),
  ]);
  final a = SyncSession(chs[0], ctxA, dialled: true);
  final b = SyncSession(chs[1], ctxB, dialled: false);
  final runA = a.run();
  final runB = b.run();
  return (a: a, b: b, runA: runA, runB: runB);
}

void main() {
  test('exchanges missing ops cleanly and saves mutual final vectors', () async {
    final ctxA = FakeSyncContext(homeId: 'H1', myDeviceId: 'a');
    final ctxB = FakeSyncContext(homeId: 'H1', myDeviceId: 'b');
    ctxA..addOp('a', 1)..addOp('a', 2)..addOp('a', 3);
    ctxB..addOp('b', 1)..addOp('b', 2)..addOp('a', 1);

    final s = await _connect(ctxA, ctxB);
    await Future.wait([s.a.ready.future, s.b.ready.future]).timeout(
      const Duration(seconds: 5),
    );

    expect(ctxA.ops.keys.toSet(), {'a:1', 'a:2', 'a:3', 'b:1', 'b:2'});
    expect(ctxB.ops.keys.toSet(), {'a:1', 'a:2', 'a:3', 'b:1', 'b:2'});
    expect(ctxA.lastAck?.toJson(), (await ctxB.myVector()).toJson());
    expect(ctxB.lastAck?.toJson(), (await ctxA.myVector()).toJson());

    await s.a.close();
    await s.b.close();
    await Future.wait([s.runA, s.runB]);
  });

  test('gossip relays third device ops from B to A', () async {
    final ctxA = FakeSyncContext(homeId: 'H1', myDeviceId: 'a');
    final ctxB = FakeSyncContext(homeId: 'H1', myDeviceId: 'b');
    ctxB.addOp('c', 1);

    final s = await _connect(ctxA, ctxB);
    await Future.wait([s.a.ready.future, s.b.ready.future]).timeout(
      const Duration(seconds: 5),
    );
    expect(ctxA.ops.containsKey('c:1'), isTrue);

    await s.a.close();
    await s.b.close();
    await Future.wait([s.runA, s.runB]);
  });

  test('live push delivers new ops immediately', () async {
    final ctxA = FakeSyncContext(homeId: 'H1', myDeviceId: 'a');
    final ctxB = FakeSyncContext(homeId: 'H1', myDeviceId: 'b');
    final s = await _connect(ctxA, ctxB);
    await Future.wait([s.a.ready.future, s.b.ready.future]).timeout(
      const Duration(seconds: 5),
    );

    ctxA.addOp('a', 1);
    await s.a.push();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(ctxB.ops.containsKey('a:1'), isTrue);

    await s.a.close();
    await s.b.close();
    await Future.wait([s.runA, s.runB]);
  });

  test('rejected auth ends both sessions without completing ready', () async {
    final ctxA = FakeSyncContext(homeId: 'H1', myDeviceId: 'a');
    final ctxB = FakeSyncContext(
      homeId: 'H1',
      myDeviceId: 'b',
      verifyResult: false,
    );
    ctxA.addOp('a', 1);
    final s = await _connect(ctxA, ctxB);
    await Future.wait([s.runA, s.runB]).timeout(const Duration(seconds: 5));
    expect(s.a.ready.isCompleted, isFalse);
    expect(s.b.ready.isCompleted, isFalse);
    expect(ctxB.ops, isEmpty);
  });

  test('mismatched homeId ends both sessions after hello', () async {
    final ctxA = FakeSyncContext(homeId: 'H1', myDeviceId: 'a');
    final ctxB = FakeSyncContext(homeId: 'H2', myDeviceId: 'b');
    ctxA.addOp('a', 1);
    final s = await _connect(ctxA, ctxB);
    await Future.wait([s.runA, s.runB]).timeout(const Duration(seconds: 5));
    expect(s.a.ready.isCompleted, isFalse);
    expect(s.b.ready.isCompleted, isFalse);
    expect(ctxB.ops, isEmpty);
  });
}
