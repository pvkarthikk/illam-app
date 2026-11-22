import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/net/byte_link.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/session/sync_context.dart';
import 'package:nm_flat/core/sync/session/sync_session.dart';
import 'package:nm_flat/core/sync/version_vector.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

class _MemoryByteLink implements ByteLink {
  _MemoryByteLink(this._in, this._out);

  final Stream<Uint8List> _in;
  final StreamSink<Uint8List> _out;

  @override
  Stream<Uint8List> get input => _in;

  @override
  void send(Uint8List bytes) => _out.add(Uint8List.fromList(bytes));

  @override
  Future<void> close() => _out.close();
}

(_MemoryByteLink, _MemoryByteLink) _memoryLinkPair() {
  final aToB = StreamController<Uint8List>();
  final bToA = StreamController<Uint8List>();
  return (
    _MemoryByteLink(bToA.stream, aToB.sink),
    _MemoryByteLink(aToB.stream, bToA.sink),
  );
}

class _PeerHarness {
  _PeerHarness._({
    required this.db,
    required this.prefs,
    required this.secure,
    required this.keys,
    required this.clock,
    required this.hlc,
    required this.registry,
    required this.log,
    required this.incoming,
    required this.writer,
    required this.ring,
    required this.controlStore,
    required this.eraser,
  });

  final NestDatabase db;
  final DevicePrefs prefs;
  final MemorySecureStore secure;
  final DeviceKeys keys;
  final FixedClock clock;
  final HlcClock hlc;
  final CollectionRegistry registry;
  final MembershipLog log;
  final IncomingPipeline incoming;
  final ChangeWriter writer;
  final HomeKeyRing ring;
  final ControlStore controlStore;
  final HomeEraser eraser;

  static Future<_PeerHarness> create(String seed, DateTime now) async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    final prefs = await DevicePrefs.inMemory();
    final keys = await MembershipLog.demoKeys(seed);
    await prefs.setDeviceId(keys.deviceId, kind: 'key');
    final secure = MemorySecureStore();
    final clock = FixedClock(now);
    final hlc = HlcClock(clock, prefs);
    final registry = CollectionRegistry.build(db);
    final log = MembershipLog(db, Future.value(keys), hlc, clock);
    final applier = OpApplier(db, registry);
    final incoming = IncomingPipeline(
      db: db,
      registry: registry,
      applier: applier,
      membership: log,
      hlc: hlc,
      clock: clock,
    );
    final writer = ChangeWriter(
      db,
      registry,
      hlc,
      prefs,
      signer: OpSigner(Future.value(keys)),
      clock: clock,
    );
    final ring = HomeKeyRing(secure);
    final cs = ControlStore(secure, now: () => clock.nowMs);
    final eraser = HomeEraser(db, registry, prefs, ring, cs, clock);
    return _PeerHarness._(
      db: db,
      prefs: prefs,
      secure: secure,
      keys: keys,
      clock: clock,
      hlc: hlc,
      registry: registry,
      log: log,
      incoming: incoming,
      writer: writer,
      ring: ring,
      controlStore: cs,
      eraser: eraser,
    );
  }

  DbSyncContext context(String homeId) => DbSyncContext(
    db: db,
    homeId: homeId,
    keys: keys,
    membership: log,
    incoming: incoming,
    clock: clock,
    prefs: prefs,
    controlStore: controlStore,
    homeEraser: eraser,
  );

  Future<void> dispose() async {
    await controlStore.dispose();
    await db.close();
  }
}

class _SpySyncContext
    implements SyncContext, ControlSyncContext, RestoreSyncContext {
  _SpySyncContext(this.inner);

  final DbSyncContext inner;
  int opsBatchesReceived = 0;

  @override
  String get homeId => inner.homeId;
  @override
  String get myDeviceId => inner.myDeviceId;
  @override
  int nowMs() => inner.nowMs();
  @override
  Future<String> signAuth(List<int> body) => inner.signAuth(body);
  @override
  Future<bool> verifyPeer(String deviceId, List<int> body, String sig) =>
      inner.verifyPeer(deviceId, body, sig);
  @override
  Future<VersionVector> myVector() => inner.myVector();
  @override
  Future<List<String>> memberOpIds() => inner.memberOpIds();
  @override
  Future<List<Map<String, Object?>>> memberOpsWire({required Set<String> except}) =>
      inner.memberOpsWire(except: except);
  @override
  Future<List<Map<String, Object?>>> opsAfter(VersionVector theirs) =>
      inner.opsAfter(theirs);
  @override
  Future<void> ingest({
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  }) {
    if (ops.isNotEmpty) opsBatchesReceived++;
    return inner.ingest(memberOps: memberOps, ops: ops);
  }

  @override
  Future<void> saveAck(
    String peerDeviceId,
    VersionVector v,
    int memberOps,
    int skewMs,
    int peerVersion,
  ) => inner.saveAck(peerDeviceId, v, memberOps, skewMs, peerVersion);
  @override
  Future<void> noteSeen(String deviceId) => inner.noteSeen(deviceId);
  @override
  Future<bool> isHomeErased() => inner.isHomeErased();
  @override
  Future<PeerSituation> evaluateSituation(String peerDeviceId) =>
      inner.evaluateSituation(peerDeviceId);
  @override
  Future<bool> onAckMemberOpIds(List<String> ids) => inner.onAckMemberOpIds(ids);
  @override
  Future<void> eraseMyHome(String reason, {String? byName}) =>
      inner.eraseMyHome(reason, byName: byName);
  @override
  String get mySignPubB64 => inner.mySignPubB64;
  @override
  Future<bool> verifyPeerWithPub(
    String deviceId,
    List<int> body,
    String sig,
    String? signPubB64,
  ) => inner.verifyPeerWithPub(deviceId, body, sig, signPubB64);
  @override
  Future<void> onFullAck() => inner.onFullAck();
  @override
  Future<void> onRecoverDead(String reason, int at) =>
      inner.onRecoverDead(reason, at);
}

Future<String> _seedHome(_PeerHarness admin, _PeerHarness other, DateTime now) async {
  final gJson = HomeIds.genesisJson(
    homeName: 'Flat',
    creatorName: 'Ananya',
    creatorDeviceId: admin.keys.deviceId,
    signPubB64: admin.keys.signPubB64,
    createdAt: now.millisecondsSinceEpoch,
    nonceB64: 'n1',
  );
  final hId = await HomeIds.fromGenesis(gJson);
  await admin.prefs.setCurrentHomeId(hId);
  await admin.prefs.setMemberId(admin.keys.deviceId);
  await admin.ring.add(hId, 'genesis', randomBytes(32));
  await admin.log.ensureGenesis(hId, gJson);
  await admin.writer.write('Home', (c) {
    c.create('homes', {
      'name': 'Flat',
      'genesis_json': gJson,
      'home_key_id': 'genesis',
    }, id: hId);
    c.create('members', {
      'full_name': 'Ananya',
      'first_name': 'Ananya',
    }, id: admin.keys.deviceId);
    c.create('dev_notes', {'title': 'Seed', 'taps': 1}, id: 'note1');
  }, homeId: hId);

  await admin.log.append(hId, 'addMember', {
    'memberId': other.keys.deviceId,
    'name': 'Meera',
    'color': '',
    'role': 'member',
    'via': 'qr',
    'keyId': 'genesis',
    'device': {
      'deviceId': other.keys.deviceId,
      'signPub': other.keys.signPubB64,
      'agreePub': b64(other.keys.agreePub),
      'model': 'Pixel',
    },
  });

  // Replicate initial state onto other before removal/leave happens:
  await other.prefs.setCurrentHomeId(hId);
  await other.prefs.setMemberId(other.keys.deviceId);
  await other.ring.add(hId, 'genesis', (await admin.ring.current(hId))!.bytes);
  await other.log.addWireOps(hId, await admin.log.allWire(hId));
  final initOps = await (admin.db.select(admin.db.ops)).get();
  await other.incoming.ingest(
    hId,
    ops: [for (final o in initOps) opToWire(OpRecord.fromRow(o))],
  );
  return hId;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('1. removed device C connects to A -> receives notice removed, zero ops frames, and erases C home', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _PeerHarness.create('admin-a', now);
    final c = await _PeerHarness.create('member-c', now);
    addTearDown(a.dispose);
    addTearDown(c.dispose);

    final hId = await _seedHome(a, c, now);
    a.clock.advance(const Duration(seconds: 5));
    await a.log.append(hId, 'removeMember', {'memberId': c.keys.deviceId});
    await a.writer.write('Post-removal note', (cb) {
      cb.create('dev_notes', {'title': 'Secret', 'taps': 1}, id: 'noteSecret');
    }, homeId: hId);

    final (linkA, linkC) = _memoryLinkPair();
    final connA = FramedConnection.link(linkA);
    final connC = FramedConnection.link(linkC);
    addTearDown(() async {
      await connA.close();
      await connC.close();
    });

    final chs = await Future.wait([
      SecureChannel.handshake(connC, initiator: true),
      SecureChannel.handshake(connA, initiator: false),
    ]);
    final spyC = _SpySyncContext(c.context(hId));
    final sessC = SyncSession(chs[0], spyC, dialled: true);
    final sessA = SyncSession(chs[1], a.context(hId), dialled: false);

    await Future.wait([
      sessC.run(),
      sessA.run(),
    ]).timeout(const Duration(seconds: 10));

    expect(sessC.receivedNotice?.kind, 'removed');
    expect(spyC.opsBatchesReceived, 0);
    expect(await c.db.select(c.db.homes).get(), isEmpty);
    expect(await c.db.select(c.db.devNotes).get(), isEmpty);
    final tombs = await c.controlStore.unshownTombstones();
    expect(tombs.single.reason, 'removed');
  });

  test('2. B queued leave -> session with A acks memberOpIds, marks outbox acked, and erases B with left tombstone', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _PeerHarness.create('admin-a', now);
    final b = await _PeerHarness.create('member-b', now);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    final hId = await _seedHome(a, b, now);
    b.clock.advance(const Duration(seconds: 5));
    final leaveRes = await b.log.append(hId, 'leave', const {});
    expect(leaveRes.effect, 'applied');
    final leaveWire = await b.log.wireForOp(leaveRes.opId);
    await b.controlStore.addOutbox(
      OutboxEntry(
        hId,
        leaveRes.opId,
        jsonEncode(leaveWire),
        b.clock.nowMs,
        false,
        const DialInfo.empty(),
      ),
    );

    final (linkA, linkB) = _memoryLinkPair();
    final connA = FramedConnection.link(linkA);
    final connB = FramedConnection.link(linkB);
    addTearDown(() async {
      await connA.close();
      await connB.close();
    });

    final chs = await Future.wait([
      SecureChannel.handshake(connB, initiator: true),
      SecureChannel.handshake(connA, initiator: false),
    ]);
    final sessB = SyncSession(chs[0], b.context(hId), dialled: true);
    final sessA = SyncSession(chs[1], a.context(hId), dialled: false);

    await Future.wait([
      sessB.run(),
      sessA.run(),
    ]).timeout(const Duration(seconds: 10));

    expect(await b.controlStore.allPendingOutbox(), isEmpty);
    expect(await b.db.select(b.db.homes).get(), isEmpty);
    expect(await b.db.select(b.db.devNotes).get(), isEmpty);
    final tombs = await b.controlStore.unshownTombstones();
    expect(tombs.single.reason, 'left');
    final aReplay = await a.log.replayState(hId);
    expect(aReplay.members[b.keys.deviceId]?.status, 'left');
  });

  test('3. quarantine: ops after C endedHlc are quarantined on A while earlier ops apply', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _PeerHarness.create('admin-a', now);
    final c = await _PeerHarness.create('member-c', now);
    addTearDown(a.dispose);
    addTearDown(c.dispose);

    final hId = await _seedHome(a, c, now);

    // Pre-removal op at +2s
    c.clock.current = now.add(const Duration(seconds: 2));
    final beforeHlc = await c.hlc.next();
    final beforeOp = OpRecord(
      opId: '${c.keys.deviceId}:1',
      homeId: hId,
      deviceId: c.keys.deviceId,
      seq: 1,
      hlc: beforeHlc,
      authorMemberId: c.keys.deviceId,
      changeId: 'chg1',
      tbl: 'dev_notes',
      entityId: 'noteBefore',
      kind: 'set',
      field: 'title',
      valueJson: jsonEncode('Before removal'),
    );
    final sigBefore = await Signer.sign(
      await c.keys.signKeyPair(),
      SignDomain.env,
      opSigningBytes(beforeOp),
    );

    // Remove C at +5s
    a.clock.current = now.add(const Duration(seconds: 5));
    await a.log.append(hId, 'removeMember', {'memberId': c.keys.deviceId});

    // Post-removal op at +8s
    c.clock.current = now.add(const Duration(seconds: 8));
    final afterHlc = await c.hlc.next();
    final afterOp = OpRecord(
      opId: '${c.keys.deviceId}:2',
      homeId: hId,
      deviceId: c.keys.deviceId,
      seq: 2,
      hlc: afterHlc,
      authorMemberId: c.keys.deviceId,
      changeId: 'chg2',
      tbl: 'dev_notes',
      entityId: 'noteAfter',
      kind: 'set',
      field: 'title',
      valueJson: jsonEncode('After removal'),
    );
    final sigAfter = await Signer.sign(
      await c.keys.signKeyPair(),
      SignDomain.env,
      opSigningBytes(afterOp),
    );

    await a.incoming.ingest(
      hId,
      ops: [
        opToWire(beforeOp.copyWith(sig: sigBefore)),
        opToWire(afterOp.copyWith(sig: sigAfter)),
      ],
    );

    final noteBefore = await (a.db.select(a.db.devNotes)
          ..where((n) => n.id.equals('noteBefore')))
        .getSingleOrNull();
    final noteAfter = await (a.db.select(a.db.devNotes)
          ..where((n) => n.id.equals('noteAfter')))
        .getSingleOrNull();
    final afterRow = await (a.db.select(a.db.ops)
          ..where((o) => o.opId.equals(afterOp.opId)))
        .getSingle();

    expect(noteBefore?.title, 'Before removal');
    expect(noteAfter, isNull);
    expect(afterRow.status, 'quarantined');
  });

  test('4. restored new phone with live kit receives new ops and clears provisionalRestore prefs', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _PeerHarness.create('admin-a', now);
    final oldB = await _PeerHarness.create('member-b-old', now);
    final newB = await _PeerHarness.create('member-b-new', now);
    addTearDown(a.dispose);
    addTearDown(oldB.dispose);
    addTearDown(newB.dispose);

    final hId = await _seedHome(a, oldB, now);

    // oldB creates a recovery kit & snapshot state (before new notes arrive on A).
    oldB.clock.advance(const Duration(seconds: 2));
    final ed = Ed25519();
    final kitKp = await ed.newKeyPair();
    final kitSeed = await kitKp.extractPrivateKeyBytes();
    final kitPub = b64((await kitKp.extractPublicKey()).bytes);
    final kitRes = await oldB.log.append(hId, 'addRecoveryKey', {
      'pub': kitPub,
      'deviceId': oldB.keys.deviceId,
    });
    expect(kitRes.effect, 'applied');

    // Sync addRecoveryKey to A before A creates a new note.
    await a.log.addWireOps(hId, await oldB.log.allWire(hId));
    await a.writer.write('Post-snapshot note', (cb) {
      cb.create('dev_notes', {'title': 'FreshNote', 'taps': 1}, id: 'noteFresh');
    }, homeId: hId);

    // newB restores from oldB's snapshot and appends signed `recover`.
    await newB.prefs.setCurrentHomeId(hId);
    await newB.prefs.setMemberId(oldB.keys.deviceId);
    await newB.prefs.setText('provisionalRestore_$hId', '${now.millisecondsSinceEpoch}');
    await newB.prefs.setText('provisionalRestoreAt_$hId', '${now.millisecondsSinceEpoch}');
    await newB.ring.add(hId, 'genesis', (await oldB.ring.current(hId))!.bytes);
    await newB.log.addWireOps(hId, await oldB.log.allWire(hId));
    final oldOps = await (oldB.db.select(oldB.db.ops)).get();
    await newB.incoming.ingest(
      hId,
      ops: [for (final o in oldOps) opToWire(OpRecord.fromRow(o))],
    );
    newB.clock.advance(const Duration(seconds: 4));
    final recoverPayload = <String, Object?>{
      'memberId': oldB.keys.deviceId,
      'device': <String, Object?>{
        'deviceId': newB.keys.deviceId,
        'signPub': newB.keys.signPubB64,
        'agreePub': b64(newB.keys.agreePub),
        'model': 'Pixel 9',
      },
      'kitPub': kitPub,
    };
    recoverPayload['recoverySig'] = await signRecover(recoverPayload, kitSeed);
    final recRes = await newB.log.append(hId, 'recover', recoverPayload);
    expect(recRes.effect, 'applied');

    final (linkA, linkNewB) = _memoryLinkPair();
    final connA = FramedConnection.link(linkA);
    final connNewB = FramedConnection.link(linkNewB);
    addTearDown(() async {
      await connA.close();
      await connNewB.close();
    });

    final chs = await Future.wait([
      SecureChannel.handshake(connNewB, initiator: true),
      SecureChannel.handshake(connA, initiator: false),
    ]);
    final sessNewB = SyncSession(chs[0], newB.context(hId), dialled: true);
    final sessA = SyncSession(chs[1], a.context(hId), dialled: false);
    final runNewB = sessNewB.run();
    final runA = sessA.run();

    await Future.wait([
      sessNewB.ready.future,
      sessA.ready.future,
    ]).timeout(const Duration(seconds: 10));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final fresh = await (newB.db.select(newB.db.devNotes)
          ..where((n) => n.id.equals('noteFresh')))
        .getSingleOrNull();
    expect(fresh?.title, 'FreshNote');
    expect(newB.prefs.getText('provisionalRestore_$hId'), isNull);
    expect(newB.prefs.getText('provisionalRestoreAt_$hId'), isNull);

    await sessNewB.close();
    await sessA.close();
    await Future.wait([runNewB, runA]);
  });

  test('5. restored new phone with revoked kit receives notice recoverDead, zero ops, and keeps local data', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _PeerHarness.create('admin-a', now);
    final oldB = await _PeerHarness.create('member-b-old', now);
    final newB = await _PeerHarness.create('member-b-new', now);
    addTearDown(a.dispose);
    addTearDown(oldB.dispose);
    addTearDown(newB.dispose);

    final hId = await _seedHome(a, oldB, now);

    // oldB creates a recovery kit and syncs addRecoveryKey to A.
    oldB.clock.advance(const Duration(seconds: 2));
    final ed = Ed25519();
    final kitKp = await ed.newKeyPair();
    final kitSeed = await kitKp.extractPrivateKeyBytes();
    final kitPub = b64((await kitKp.extractPublicKey()).bytes);
    await oldB.log.append(hId, 'addRecoveryKey', {
      'pub': kitPub,
      'deviceId': oldB.keys.deviceId,
    });
    await a.log.addWireOps(hId, await oldB.log.allWire(hId));

    // snapshot taken BEFORE revocation -> newB restores from it and sends recover.
    await newB.prefs.setCurrentHomeId(hId);
    await newB.prefs.setMemberId(oldB.keys.deviceId);
    await newB.ring.add(hId, 'genesis', (await oldB.ring.current(hId))!.bytes);
    await newB.log.addWireOps(hId, await oldB.log.allWire(hId));
    final oldOps = await (oldB.db.select(oldB.db.ops)).get();
    await newB.incoming.ingest(
      hId,
      ops: [for (final o in oldOps) opToWire(OpRecord.fromRow(o))],
    );
    newB.clock.advance(const Duration(seconds: 4));
    final recoverPayload = <String, Object?>{
      'memberId': oldB.keys.deviceId,
      'device': <String, Object?>{
        'deviceId': newB.keys.deviceId,
        'signPub': newB.keys.signPubB64,
        'agreePub': b64(newB.keys.agreePub),
        'model': 'Pixel 9',
      },
      'kitPub': kitPub,
    };
    recoverPayload['recoverySig'] = await signRecover(recoverPayload, kitSeed);
    await newB.log.append(hId, 'recover', recoverPayload);

    // Meanwhile A revokes oldB's recovery key and writes a post-revoke secret note.
    a.clock.advance(const Duration(seconds: 6));
    await a.log.append(hId, 'revokeRecoveryKey', {'pub': kitPub});
    await a.writer.write('Secret after revoke', (cb) {
      cb.create('dev_notes', {'title': 'SecretNote', 'taps': 1}, id: 'noteSec');
    }, homeId: hId);

    final (linkA, linkNewB) = _memoryLinkPair();
    final connA = FramedConnection.link(linkA);
    final connNewB = FramedConnection.link(linkNewB);
    addTearDown(() async {
      await connA.close();
      await connNewB.close();
    });

    final chs = await Future.wait([
      SecureChannel.handshake(connNewB, initiator: true),
      SecureChannel.handshake(connA, initiator: false),
    ]);
    final spyNewB = _SpySyncContext(newB.context(hId));
    final sessNewB = SyncSession(chs[0], spyNewB, dialled: true);
    final sessA = SyncSession(chs[1], a.context(hId), dialled: false);

    await Future.wait([
      sessNewB.run(),
      sessA.run(),
    ]).timeout(const Duration(seconds: 10));

    expect(sessNewB.receivedNotice?.kind, 'recoverDead');
    expect(spyNewB.opsBatchesReceived, 0);
    expect(newB.prefs.getText('recoverDead_$hId'), isNotNull);
    // Home data is preserved for SeparateCopy rather than auto-erased:
    expect(await newB.db.select(newB.db.homes).get(), isNotEmpty);
    expect(await newB.db.select(newB.db.devNotes).get(), isNotEmpty);
  });
}
