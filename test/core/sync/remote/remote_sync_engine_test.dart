import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_repo.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/key_rotation.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_engine.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

class _FakeFirebaseServerAdapter implements HttpClientAdapter {
  final Map<String, List<Map<String, Object?>>> channels = {};
  int requestCount = 0;
  int _tick = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final bb = BytesBuilder(copy: false);
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bb.add(chunk);
      }
    }
    final raw = utf8.decode(bb.takeBytes(), allowMalformed: true);
    final url = options.uri.toString();

    if (url.contains('identitytoolkit.googleapis.com')) {
      return _json(200, {
        'idToken': 'id-tok',
        'refreshToken': 'ref-tok',
        'localId': 'anon-uid',
        'expiresIn': '3600',
      });
    }

    if (url.endsWith(':commit')) {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      final writes = decoded['writes'] as List;
      String? lastTs;
      for (final w in writes) {
        final write = w as Map<String, Object?>;
        final upd = write['update'] as Map<String, Object?>;
        final name = upd['name'] as String;
        final parts = name.split('/');
        final channelId = parts[parts.length - 3];
        final fields = Map<String, Object?>.from(upd['fields'] as Map);
        _tick++;
        final ts = DateTime.utc(2026, 11, 25, 10, 0, 0, _tick).toIso8601String();
        lastTs = ts;
        fields['createdAt'] = {'timestampValue': ts};
        (channels[channelId] ??= []).add({'name': name, 'fields': fields});
      }
      return _json(200, {
        'writeResults': [
          {
            'updateTime': lastTs,
            'transformResults': [
              {'timestampValue': lastTs},
            ],
          },
        ],
      });
    }

    if (url.endsWith(':runQuery')) {
      final segs = options.uri.pathSegments;
      final channelId = segs[segs.length - 1].split(':').first;
      final body = jsonDecode(raw) as Map<String, Object?>;
      final sq = body['structuredQuery'] as Map<String, Object?>;
      final limit = (sq['limit'] as num?)?.toInt() ?? 50;
      String? sinceTs;
      final where = sq['where'] as Map?;
      if (where != null) {
        final ff = where['fieldFilter'] as Map?;
        sinceTs = (ff?['value'] as Map?)?['timestampValue'] as String?;
      }
      final docs = [...(channels[channelId] ?? const <Map<String, Object?>>[])];
      final filtered = [
        for (final d in docs)
          if (sinceTs == null ||
              _tsOf(d).compareTo(sinceTs) >= 0)
            {'document': d},
      ];
      if (filtered.isEmpty) {
        return _json(200, [
          {'readTime': '2026-11-25T10:00:00Z'},
        ]);
      }
      return _json(200, filtered.take(limit).toList());
    }

    return _json(404, {'error': {'status': 'NOT_FOUND'}});
  }

  static String _tsOf(Map<String, Object?> doc) {
    final fields = doc['fields'] as Map;
    return (fields['createdAt'] as Map)['timestampValue'] as String;
  }

  static ResponseBody _json(int status, Object body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: const {
          Headers.contentTypeHeader: ['application/json'],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _TestPhone {
  _TestPhone._({
    required this.db,
    required this.prefs,
    required this.secure,
    required this.keys,
    required this.clock,
    required this.writer,
    required this.membership,
    required this.incoming,
    required this.configStore,
    required this.engine,
    required this.homeRepo,
  });

  final NestDatabase db;
  final DevicePrefs prefs;
  final MemorySecureStore secure;
  final DeviceKeys keys;
  final FixedClock clock;
  final ChangeWriter writer;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final RemoteSyncConfigStore configStore;
  final RemoteSyncEngine engine;
  final HomeRepo homeRepo;

  Future<void> dispose() async {
    await engine.dispose();
    await configStore.dispose();
    await db.close();
  }
}

Future<_TestPhone> _createPhone({
  required int seedByte,
  required _FakeFirebaseServerAdapter server,
  String? homeId,
}) async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  final prefs = await DevicePrefs.inMemory();
  final secure = MemorySecureStore();
  final keys = await DeviceKeys.fromSeeds(
    List.filled(32, seedByte),
    List.filled(32, seedByte + 1),
  );
  await prefs.setDeviceId(keys.deviceId, kind: 'key');
  final clock = FixedClock(DateTime.utc(2026, 11, 25, 10, 0));
  final hlc = HlcClock(clock, prefs);
  final registry = CollectionRegistry.build(db);
  final writer = ChangeWriter(
    db,
    registry,
    hlc,
    prefs,
    signer: OpSigner(Future.value(keys)),
    clock: clock,
  );
  final membership = MembershipLog(
    db,
    Future.value(keys),
    hlc,
    clock,
    modelOf: () async => 'Pixel',
  );
  final incoming = IncomingPipeline(
    db: db,
    registry: registry,
    applier: OpApplier(db, registry),
    membership: membership,
    hlc: hlc,
    clock: clock,
  );
  final configStore = RemoteSyncConfigStore(secure);
  final dio = Dio(BaseOptions(validateStatus: (_) => true))
    ..httpClientAdapter = server;
  final engine = RemoteSyncEngine(
    db: db,
    prefs: prefs,
    secure: secure,
    keys: Future.value(keys),
    membership: membership,
    incoming: incoming,
    clock: clock,
    homeId: homeId,
    configStore: configStore,
    client: FirebaseRestClient(dio: dio),
    pollInterval: const Duration(milliseconds: 50),
    pushDebounce: const Duration(milliseconds: 10),
  );
  final homeRepo = HomeRepo(
    db,
    writer,
    prefs,
    secure,
    clock,
    membershipLog: membership,
  );

  return _TestPhone._(
    db: db,
    prefs: prefs,
    secure: secure,
    keys: keys,
    clock: clock,
    writer: writer,
    membership: membership,
    incoming: incoming,
    configStore: configStore,
    engine: engine,
    homeRepo: homeRepo,
  );
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('RemoteSyncEngine', () {
    test('does nothing and makes zero network requests when toggle is OFF', () async {
      final server = _FakeFirebaseServerAdapter();
      final phoneA = await _createPhone(seedByte: 10, server: server);
      final homeId = await phoneA.homeRepo.createHome(
        creatorName: 'Asha',
        homeName: 'Illam',
        keys: phoneA.keys,
        createdAt: phoneA.clock.nowMs,
        nonceB64: 'AAAA',
        model: 'Pixel',
      );
      await phoneA.dispose();

      final phoneAWithHome = await _createPhone(
        seedByte: 10,
        server: server,
        homeId: homeId,
      );
      addTearDown(phoneAWithHome.dispose);
      await HomeKeyRing(phoneAWithHome.secure).add(
        homeId,
        'genesis',
        List<int>.filled(32, 9),
      );
      await phoneAWithHome.configStore.save(
        homeId,
        RemoteSyncConfig(
          enabled: false,
          projectId: 'my-proj',
          apiKey: 'AIzaSy1234567890abcd',
        ),
      );

      final out = await phoneAWithHome.engine.syncNow();
      expect(out.ran, isFalse);
      expect(server.requestCount, 0);
    });

    test('syncs ops bidirectionally through encrypted Firebase channel with key rotation', () async {
      final server = _FakeFirebaseServerAdapter();

      // Bootstrap home on Phone A
      final setupA = await _createPhone(seedByte: 20, server: server);
      final homeId = await setupA.homeRepo.createHome(
        creatorName: 'Asha',
        homeName: 'Our Home',
        keys: setupA.keys,
        createdAt: setupA.clock.nowMs,
        nonceB64: 'BBBB',
        model: 'Pixel',
      );
      final genesisKey = (await HomeKeyRing(setupA.secure).current(homeId))!;
      final memberAWire = await setupA.membership.allWire(homeId);
      final dataAWire = await SyncStore(setupA.db).allOpsWire(homeId);
      await setupA.dispose();

      // Now open paired engines on Phone A & Phone B sharing genesis key + joined member B
      final dbA = NestDatabase.forTesting(NativeDatabase.memory());
      final dbB = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(dbA.close);
      addTearDown(dbB.close);

      Future<RemoteSyncEngine> makePaired(
        NestDatabase db,
        int seed,
        MemorySecureStore secure,
        DevicePrefs prefs,
        ChangeWriter writer,
        MembershipLog mLog,
        IncomingPipeline inc,
        FixedClock clock,
        RemoteSyncConfigStore cs,
        DeviceKeys dk,
      ) async {
        final dio = Dio(BaseOptions(validateStatus: (_) => true))
          ..httpClientAdapter = server;
        final rot = KeyRotation(HomeKeyRing(secure), mLog, Future.value(dk));
        mLog.onReplayed = (s) => rot.afterReplay(s, me: dk.deviceId, homeId: homeId);
        return RemoteSyncEngine(
          db: db,
          prefs: prefs,
          secure: secure,
          keys: Future.value(dk),
          membership: mLog,
          incoming: inc,
          clock: clock,
          homeId: homeId,
          configStore: cs,
          client: FirebaseRestClient(dio: dio),
        );
      }

      // Build Phone A
      final prefsA = await DevicePrefs.inMemory();
      final secA = MemorySecureStore();
      final keysA = await DeviceKeys.fromSeeds(List.filled(32, 20), List.filled(32, 21));
      await prefsA.setDeviceId(keysA.deviceId, kind: 'key');
      await prefsA.setCurrentHomeId(homeId);
      await HomeKeyRing(secA).add(homeId, 'genesis', genesisKey.bytes);
      final clockA = FixedClock(DateTime.utc(2026, 11, 25, 10, 0));
      final hlcA = HlcClock(clockA, prefsA);
      final regA = CollectionRegistry.build(dbA);
      final writerA = ChangeWriter(
        dbA,
        regA,
        hlcA,
        prefsA,
        signer: OpSigner(Future.value(keysA)),
        clock: clockA,
      );
      final mLogA = MembershipLog(
        dbA,
        Future.value(keysA),
        hlcA,
        clockA,
        modelOf: () async => 'PixelA',
      );
      final incA = IncomingPipeline(
        db: dbA,
        registry: regA,
        applier: OpApplier(dbA, regA),
        membership: mLogA,
        hlc: hlcA,
        clock: clockA,
      );
      final csA = RemoteSyncConfigStore(secA);
      final engA = await makePaired(
        dbA,
        20,
        secA,
        prefsA,
        writerA,
        mLogA,
        incA,
        clockA,
        csA,
        keysA,
      );
      addTearDown(engA.dispose);
      addTearDown(csA.dispose);

      // Build Phone B
      final prefsB = await DevicePrefs.inMemory();
      final secB = MemorySecureStore();
      final keysB = await DeviceKeys.fromSeeds(List.filled(32, 30), List.filled(32, 31));
      await prefsB.setDeviceId(keysB.deviceId, kind: 'key');
      await prefsB.setCurrentHomeId(homeId);
      await HomeKeyRing(secB).add(homeId, 'genesis', genesisKey.bytes);
      final clockB = FixedClock(DateTime.utc(2026, 11, 25, 10, 0));
      final hlcB = HlcClock(clockB, prefsB);
      final regB = CollectionRegistry.build(dbB);
      final writerB = ChangeWriter(
        dbB,
        regB,
        hlcB,
        prefsB,
        signer: OpSigner(Future.value(keysB)),
        clock: clockB,
      );
      final mLogB = MembershipLog(
        dbB,
        Future.value(keysB),
        hlcB,
        clockB,
        modelOf: () async => 'PixelB',
      );
      final incB = IncomingPipeline(
        db: dbB,
        registry: regB,
        applier: OpApplier(dbB, regB),
        membership: mLogB,
        hlc: hlcB,
        clock: clockB,
      );
      final csB = RemoteSyncConfigStore(secB);
      final engB = await makePaired(
        dbB,
        30,
        secB,
        prefsB,
        writerB,
        mLogB,
        incB,
        clockB,
        csB,
        keysB,
      );
      addTearDown(engB.dispose);
      addTearDown(csB.dispose);

      // Seed genesis + addMember B on Phone A and share initial genesis state to Phone B
      await incA.ingest(homeId, memberOps: memberAWire, ops: dataAWire);
      await mLogA.append(homeId, 'addMember', {
        'memberId': keysB.deviceId,
        'name': 'Ravi',
        'role': 'member',
        'via': 'qr',
        'keyId': 'genesis',
        'device': {
          'deviceId': keysB.deviceId,
          'signPub': keysB.signPubB64,
          'agreePub': b64(keysB.agreePub),
          'model': 'PixelB',
        },
      });
      await incB.ingest(
        homeId,
        memberOps: await mLogA.allWire(homeId),
        ops: await SyncStore(dbA).allOpsWire(homeId),
      );

      // Turn on Remote Sync on both phones pointing at same Firebase project
      final remoteCfg = RemoteSyncConfig(
        enabled: true,
        projectId: 'our-home-fb',
        apiKey: 'AIzaSy1234567890abcd',
      );
      await csA.save(homeId, remoteCfg);
      await csB.save(homeId, remoteCfg);
      // Let initial background sync triggered by config activation settle.
      await engA.syncNow();
      await engB.syncNow();

      // Phone A creates > 80 todos (tests chunked push across batches!)
      for (var i = 1; i <= 85; i++) {
        await writerA.write('Add todo $i', (c) {
          c.create('todos', {
            'title': 'Task $i',
            'due': '2026-11-25',
            'done': false,
          }, id: 't$i');
        });
      }

      final pushA = await engA.syncNow();
      expect(pushA.ran, isTrue);
      expect(pushA.error, isNull);
      expect(pushA.pushed, greaterThanOrEqualTo(85));

      // Verify Firestore docs contain opaque encrypted payload, never plaintext "Task 1"
      final chId = server.channels.keys.single;
      final storedJson = jsonEncode(server.channels[chId]);
      expect(storedJson.contains('Task 1'), isFalse);
      expect(storedJson.contains(homeId), isFalse);
      expect(server.channels[chId]!.length, greaterThanOrEqualTo(2));

      // Phone B pulls from Firebase and sees all 85 todos
      final pullB = await engB.syncNow();
      expect(pullB.ran, isTrue);
      expect(pullB.error, isNull);
      expect(pullB.pulled, greaterThanOrEqualTo(85));

      final todosB = await dbB
          .customSelect(
            'SELECT COUNT(*) AS n FROM todos WHERE home_id = ? AND deleted = 0',
            variables: [Variable.withString(homeId)],
          )
          .getSingle();
      expect(todosB.data['n'], 85);

      // Phone B should NOT re-upload the ops it just pulled from A
      final noopB = await engB.syncNow();
      expect(noopB.pushed, 0);
      expect(noopB.pulled, 0);

      // Verify peer ack recorded for Phone A on Phone B
      final ackRow = await (dbB.select(
        dbB.syncPeers,
      )..where((p) => p.deviceId.equals(keysA.deviceId))).getSingleOrNull();
      expect(ackRow, isNotNull);

      // Phone B writes a new item and pushes; Phone A pulls it
      await writerB.write('Add from B', (c) {
        c.create('items', {
          'list': 'groceries',
          'name': 'Cardamom',
          'done': false,
        }, id: 'itemB1');
      });
      final pushB = await engB.syncNow();
      expect(pushB.pushed, greaterThanOrEqualTo(1));

      final pullA = await engA.syncNow();
      expect(pullA.pulled, greaterThanOrEqualTo(1));
      final itemA = await dbA
          .customSelect(
            "SELECT name FROM items WHERE id = 'itemB1'",
          )
          .getSingleOrNull();
      expect(itemA?.data['name'], 'Cardamom');

      // Rotate key on Phone A -> Phone A posts rotation to old channel & switches -> Phone B receives rotation & new data!
      final newKey = Uint8List.fromList(List<int>.filled(32, 77));
      final rotPayload = await KeyRotation(
        HomeKeyRing(secA),
        mLogA,
        Future.value(keysA),
      ).buildRotatePayload(await mLogA.replayState(homeId), newKey);
      final rotRes = await mLogA.append(homeId, 'rotateKey', rotPayload);
      await HomeKeyRing(secA).add(homeId, rotRes.opId, newKey);

      await writerA.write('Post rotation', (c) {
        c.create('todos', {
          'title': 'Rotated secret task',
          'due': '2026-11-26',
          'done': false,
        }, id: 'tRot');
      });
      final rotPush = await engA.syncNow();
      expect(rotPush.error, isNull);
      expect(server.channels.keys.length, 2);

      final rotPull = await engB.syncNow();
      expect(rotPull.error, isNull);
      final rotTodoB = await dbB
          .customSelect(
            "SELECT title FROM todos WHERE id = 'tRot'",
          )
          .getSingleOrNull();
      expect(rotTodoB?.data['title'], 'Rotated secret task');
    });
  });
}
