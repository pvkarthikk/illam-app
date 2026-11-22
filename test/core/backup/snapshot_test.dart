import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';

Future<({ProviderContainer container, NestDatabase db, DevicePrefs prefs})>
_makeNode(DateTime now) async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  final prefs = await DevicePrefs.inMemory();
  final secure = MemorySecureStore();
  final clock = FixedClock(now);
  final container = ProviderContainer(
    overrides: [
      dbProvider.overrideWithValue(db),
      prefsProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(secure),
      clockProvider.overrideWithValue(clock),
    ],
  );
  return (container: container, db: db, prefs: prefs);
}

Future<String> _seedHomeA(ProviderContainer container, DateTime now) async {
  final keys = await container.read(deviceKeysProvider.future);
  final homeId = await container.read(homeRepoProvider).createHome(
    creatorName: 'Ananya',
    homeName: 'Iyer Home',
    keys: keys,
    createdAt: now.millisecondsSinceEpoch,
    nonceB64: 'nonce1',
    model: 'Pixel',
  );
  await container.read(changesProvider).write('Add notes', (c) {
    c.create('dev_notes', {
      'title': 'Milk',
      'body': '2 litres',
      'taps': 1,
    }, id: 'n1');
    c.create('dev_notes', {
      'title': 'Rent',
      'body': 'Due Friday',
      'taps': 3,
    }, id: 'n2');
  }, homeId: homeId);
  return homeId;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('1. build -> toBytes -> fromBytes -> import preserves notes and home keys', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _makeNode(now);
    final b = await _makeNode(now);
    addTearDown(() async {
      a.container.dispose();
      b.container.dispose();
      await a.db.close();
      await b.db.close();
    });

    final homeId = await _seedHomeA(a.container, now);
    final snap = await a.container
        .read(snapshotBuilderProvider)
        .build(homeId, createdAt: now.millisecondsSinceEpoch, includeKit: false);
    final decoded = Snapshot.fromBytes(snap.toBytes());

    await b.container.read(snapshotImporterProvider).import(decoded);

    final notesA = await (a.db.select(a.db.devNotes)).get();
    final notesB = await (b.db.select(b.db.devNotes)).get();
    expect(
      {for (final n in notesB) n.id: (n.title, n.body, n.taps)},
      {for (final n in notesA) n.id: (n.title, n.body, n.taps)},
    );

    final keysA = await a.container.read(homeKeyRingProvider).all(homeId);
    final keysB = await b.container.read(homeKeyRingProvider).all(homeId);
    expect(keysB.map((k) => k.keyId).toList(), keysA.map((k) => k.keyId).toList());
    expect(keysB.map((k) => k.bytes).toList(), keysA.map((k) => k.bytes).toList());
  });

  test('2. flipped op sig is quarantined while valid ops still apply', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _makeNode(now);
    final b = await _makeNode(now);
    addTearDown(() async {
      a.container.dispose();
      b.container.dispose();
      await a.db.close();
      await b.db.close();
    });

    final homeId = await _seedHomeA(a.container, now);
    final snap = await a.container
        .read(snapshotBuilderProvider)
        .build(homeId, createdAt: now.millisecondsSinceEpoch, includeKit: false);

    final ops = [for (final o in snap.ops) Map<String, Object?>.from(o)];
    final idx = ops.indexWhere((o) => o['tbl'] == 'dev_notes');
    final badOpId = ops[idx]['opId'] as String;
    final origSig = ops[idx]['sig'] as String;
    final flipped = '${origSig.startsWith('A') ? 'B' : 'A'}${origSig.substring(1)}';
    ops[idx]['sig'] = flipped;

    final modified = Snapshot(
      homeId: snap.homeId,
      homeName: snap.homeName,
      vaultId: snap.vaultId,
      createdAt: snap.createdAt,
      by: snap.by,
      ops: ops,
      memberOps: snap.memberOps,
      homeKeys: snap.homeKeys,
      recoveryKit: snap.recoveryKit,
    );

    await b.container.read(snapshotImporterProvider).import(modified);

    final badRow = await (b.db.select(b.db.ops)
          ..where((o) => o.opId.equals(badOpId)))
        .getSingle();
    final otherRows = await (b.db.select(b.db.ops)
          ..where((o) => o.opId.equals(badOpId).not()))
        .get();
    expect(badRow.status, 'quarantined');
    expect(otherRows, isNotEmpty);
    expect(otherRows.every((o) => o.status == 'applied'), isTrue);
  });

  test('3. mismatched homeId throws damaged and leaves database clean', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _makeNode(now);
    final b = await _makeNode(now);
    addTearDown(() async {
      a.container.dispose();
      b.container.dispose();
      await a.db.close();
      await b.db.close();
    });

    final homeId = await _seedHomeA(a.container, now);
    final snap = await a.container
        .read(snapshotBuilderProvider)
        .build(homeId, createdAt: now.millisecondsSinceEpoch, includeKit: false);
    final badSnap = Snapshot(
      homeId: 'NM-OTHER',
      homeName: snap.homeName,
      vaultId: snap.vaultId,
      createdAt: snap.createdAt,
      by: snap.by,
      ops: snap.ops,
      memberOps: snap.memberOps,
      homeKeys: snap.homeKeys,
      recoveryKit: snap.recoveryKit,
    );

    await expectLater(
      () => b.container.read(snapshotImporterProvider).import(badSnap),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.error,
          'error',
          BackupError.damaged,
        ),
      ),
    );

    expect(await b.db.select(b.db.devNotes).get(), isEmpty);
    expect(await b.db.select(b.db.ops).get(), isEmpty);
    expect(await b.db.select(b.db.memberOps).get(), isEmpty);
  });

  test('4. SnapshotHeads ignores backup_status writes and changes on dev_notes writes', () async {
    final now = DateTime(2026, 11, 20, 9);
    final a = await _makeNode(now);
    addTearDown(() async {
      a.container.dispose();
      await a.db.close();
    });

    final homeId = await _seedHomeA(a.container, now);
    final h1 = await SnapshotHeads.compute(a.db, homeId);

    await a.container.read(changesProvider).write('Backup status', (c) {
      c.create('backup_status', {
        'member_id': a.prefs.deviceId,
        'frequency': 'weekly',
        'recovery_capable': true,
        'off_phone': false,
        'dests_json': '[]',
      }, id: a.prefs.deviceId);
    }, homeId: homeId);
    final h2 = await SnapshotHeads.compute(a.db, homeId);
    expect(h2, h1);

    await a.container.read(changesProvider).write('Note edit', (c) {
      c.set('dev_notes', 'n1', 'title', 'Bread');
    }, homeId: homeId);
    final h3 = await SnapshotHeads.compute(a.db, homeId);
    expect(h3, isNot(h1));
  });
}
