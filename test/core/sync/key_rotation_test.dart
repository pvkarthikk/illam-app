import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/data/wipe.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/sync/key_rotation.dart';
import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('HomeKeyRing', () {
    test('keeps at most 3 newest keys and deletes older keys', () async {
      final secure = MemorySecureStore();
      final ring = HomeKeyRing(secure);
      const h = 'NM-RING1';

      for (var i = 1; i <= 4; i++) {
        await ring.add(h, 'k$i', List<int>.filled(32, i));
      }

      final all = await ring.all(h);
      expect(all.map((k) => k.keyId).toList(), ['k4', 'k3', 'k2']);
      expect(await secure.read(SecureKeys.homeKey(h, 'k1')), isNull);
    });

    test('migrates legacy genesis-only entry into current()', () async {
      final secure = MemorySecureStore();
      final ring = HomeKeyRing(secure);
      const h = 'NM-RING2';
      final keyBytes = List<int>.generate(32, (i) => i + 10);
      await secure.write(SecureKeys.homeKey(h, 'genesis'), base64Encode(keyBytes));

      final cur = await ring.current(h);
      expect(cur?.keyId, 'genesis');
      expect(cur?.bytes, Uint8List.fromList(keyBytes));
    });

    test('clear removes all keys and id list for the home', () async {
      final secure = MemorySecureStore();
      final ring = HomeKeyRing(secure);
      const h = 'NM-RING3';
      await ring.add(h, 'genesis', List<int>.filled(32, 1));
      await ring.add(h, 'k2', List<int>.filled(32, 2));

      await ring.clear(h);
      expect(await ring.all(h), isEmpty);
      expect(await secure.read(SecureKeys.homeKey(h, 'genesis')), isNull);
      expect(await secure.read(SecureKeys.homeKey(h, 'k2')), isNull);
      expect(await secure.read(SecureKeys.homeKeyIds(h)), isNull);
    });

    test('PhoneWiper.wipeHome clears rotated ring keys too', () async {
      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await DevicePrefs.inMemory();
      final secure = MemorySecureStore();
      final ring = HomeKeyRing(secure);
      final clock = FixedClock(DateTime(2026, 11, 20, 9));
      final writer = ChangeWriter(
        db,
        CollectionRegistry.build(db),
        HlcClock(clock, prefs),
        prefs,
      );

      await prefs.setCurrentHomeId('NM-WIPE');
      await writer.write('Seed home', (c) {
        c.create('homes', {'name': 'Flat', 'home_key_id': 'genesis'}, id: 'NM-WIPE');
      });
      await ring.add('NM-WIPE', 'genesis', List<int>.filled(32, 1));
      await ring.add('NM-WIPE', 'k2', List<int>.filled(32, 2));

      await PhoneWiper(db, prefs, secure).wipeHome();
      expect(await ring.all('NM-WIPE'), isEmpty);
      expect(await secure.read(SecureKeys.homeKey('NM-WIPE', 'k2')), isNull);
      expect(await secure.read(SecureKeys.homeKeyIds('NM-WIPE')), isNull);
    });
  });

  group('KeyRotation', () {
    test('tracks keyHolders across genesis, addMember, and rotateKey', () async {
      final creator = await MembershipLog.demoKeys('creator');
      final guestD = await MembershipLog.demoKeys('device-d');
      final gJson = HomeIds.genesisJson(
        homeName: 'Flat',
        creatorName: 'Ananya',
        creatorDeviceId: creator.deviceId,
        signPubB64: creator.signPubB64,
        createdAt: 1763600000000,
        nonceB64: 'n1',
      );
      final hId = await HomeIds.fromGenesis(gJson);

      final gen = MemberOp(
        opId: 'g1',
        homeId: hId,
        type: 'genesis',
        authorDeviceId: creator.deviceId,
        hlc: '0000000000001.0000.a',
        payload: {'genesisJson': gJson, 'agreePub': b64(creator.agreePub)},
      );
      final addD = MemberOp(
        opId: 'aD',
        homeId: hId,
        type: 'addMember',
        authorDeviceId: creator.deviceId,
        hlc: '0000000000002.0000.a',
        prev: const ['g1'],
        payload: {
          'memberId': guestD.deviceId,
          'name': 'D',
          'role': 'member',
          'via': 'qr',
          'keyId': 'genesis',
          'device': {
            'deviceId': guestD.deviceId,
            'signPub': guestD.signPubB64,
            'agreePub': b64(guestD.agreePub),
            'model': 'Pixel',
          },
        },
      );
      final rot = MemberOp(
        opId: 'r1',
        homeId: hId,
        type: 'rotateKey',
        authorDeviceId: creator.deviceId,
        hlc: '0000000000003.0000.a',
        prev: const ['aD'],
        payload: {
          'wrapped': {creator.deviceId: 'wC', guestD.deviceId: 'wD'},
        },
      );

      final r1 = replayMembership([gen]);
      expect(r1.keyHolders['genesis'], {creator.deviceId});

      final r2 = replayMembership([gen, addD]);
      expect(r2.keyHolders['genesis'], {creator.deviceId, guestD.deviceId});

      final r3 = replayMembership([gen, addD, rot]);
      expect(r3.currentKeyId, 'r1');
      expect(r3.keyHolders['r1'], {creator.deviceId, guestD.deviceId});
    });

    test('guard rotates new key covering missing active D and excluding removed C', () async {
      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await DevicePrefs.inMemory();
      final secure = MemorySecureStore();
      final ring = HomeKeyRing(secure);
      final admin = await MembershipLog.demoKeys('admin');
      final cKeys = await MembershipLog.demoKeys('member-c');
      final dKeys = await MembershipLog.demoKeys('member-d');
      final clock = FixedClock(DateTime(2026, 11, 20, 9));
      final hlc = HlcClock(clock, prefs);
      final log = MembershipLog(db, Future.value(admin), hlc, clock);
      final rotation = KeyRotation(ring, log, Future.value(admin));

      final gJson = HomeIds.genesisJson(
        homeName: 'Flat',
        creatorName: 'Admin',
        creatorDeviceId: admin.deviceId,
        signPubB64: admin.signPubB64,
        createdAt: 1763600000000,
        nonceB64: 'n1',
      );
      final hId = await HomeIds.fromGenesis(gJson);
      await ring.add(hId, 'genesis', List<int>.filled(32, 7));

      final genSigned = await MemberOpCodec.sign(
        MemberOp(
          homeId: hId,
          type: 'genesis',
          authorDeviceId: admin.deviceId,
          hlc: await hlc.next(),
          payload: {'genesisJson': gJson, 'agreePub': b64(admin.agreePub)},
        ),
        await admin.signKeyPair(),
      );
      final addC = await MemberOpCodec.sign(
        MemberOp(
          homeId: hId,
          type: 'addMember',
          authorDeviceId: admin.deviceId,
          hlc: await hlc.next(),
          prev: [genSigned.opId],
          payload: {
            'memberId': cKeys.deviceId,
            'name': 'C',
            'role': 'member',
            'via': 'qr',
            'keyId': 'genesis',
            'device': {
              'deviceId': cKeys.deviceId,
              'signPub': cKeys.signPubB64,
              'agreePub': b64(cKeys.agreePub),
              'model': 'CPhone',
            },
          },
        ),
        await admin.signKeyPair(),
      );
      final remC = await MemberOpCodec.sign(
        MemberOp(
          homeId: hId,
          type: 'removeMember',
          authorDeviceId: admin.deviceId,
          hlc: await hlc.next(),
          prev: [addC.opId],
          payload: {'memberId': cKeys.deviceId},
        ),
        await admin.signKeyPair(),
      );
      final addD = await MemberOpCodec.sign(
        MemberOp(
          homeId: hId,
          type: 'addMember',
          authorDeviceId: admin.deviceId,
          hlc: await hlc.next(),
          prev: [remC.opId],
          payload: {
            'memberId': dKeys.deviceId,
            'name': 'D',
            'role': 'member',
            'via': 'qr',
            'keyId': 'genesis',
            'device': {
              'deviceId': dKeys.deviceId,
              'signPub': dKeys.signPubB64,
              'agreePub': b64(dKeys.agreePub),
              'model': 'DPhone',
            },
          },
        ),
        await admin.signKeyPair(),
      );
      // Concurrent rotateKey that wraps only admin and lacks D:
      final staleRot = await MemberOpCodec.sign(
        MemberOp(
          homeId: hId,
          type: 'rotateKey',
          authorDeviceId: admin.deviceId,
          hlc: await hlc.next(),
          prev: [remC.opId],
          payload: {
            'wrapped': {
              admin.deviceId: b64(
                await SealedBox.seal(admin.agreePub, List<int>.filled(32, 9)),
              ),
            },
          },
        ),
        await admin.signKeyPair(),
      );

      await log.addWireOps(hId, [
        for (final o in [genSigned, addC, remC, addD, staleRot])
          MemberOpCodec.toWire(o),
      ]);
      final replay = await log.replayAndProject(hId);
      expect(
        replay.activeDeviceIds().difference(
          replay.keyHolders[replay.currentKeyId!] ?? const {},
        ),
        {dKeys.deviceId},
      );

      await rotation.afterReplay(replay, me: admin.deviceId, homeId: hId);
      final updated = await log.replayState(hId);
      final cur = await ring.current(hId);
      expect(cur?.keyId, updated.currentKeyId);
      expect(cur?.keyId, isNot(staleRot.opId));
      expect(updated.keyHolders[cur!.keyId], {admin.deviceId, dKeys.deviceId});
      expect(updated.wrapFor(cur.keyId, cKeys.deviceId), isNull);
    });

    test('SealedBox seal then open round trip returns identical 32 bytes', () async {
      final recipient = await MembershipLog.demoKeys('seal-recipient');
      final plain = randomBytes(32);
      final sealed = await SealedBox.seal(recipient.agreePub, plain);
      final opened = await SealedBox.open(await recipient.agreeKeyPair(), sealed);
      expect(opened, plain);
    });
  });
}
