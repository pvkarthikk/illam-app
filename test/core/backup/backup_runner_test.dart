import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_runner.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';

class FakeDestination extends BackupDestination {
  FakeDestination({this.failWith});

  DestError? failWith;
  final Map<String, Uint8List> files = {};

  @override
  String get kind => 'folder';

  @override
  Future<void> testWrite() async {
    if (failWith != null) throw DestinationException(failWith!);
  }

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    if (failWith != null) throw DestinationException(failWith!);
    files[name] = Uint8List.fromList(bytes);
  }

  @override
  Future<List<RemoteBackupFile>> list() async => [
    for (final e in files.entries)
      if (backupNameRe.hasMatch(e.key))
        RemoteBackupFile(e.key, e.value.length, 0),
  ];

  @override
  Future<Uint8List> download(String name) async {
    final data = files[name];
    if (data == null) throw const DestinationException(DestError.notFound);
    return data;
  }

  @override
  Future<void> delete(String name) async {
    files.remove(name);
  }
}

Future<
  ({
    ProviderContainer container,
    NestDatabase db,
    DevicePrefs prefs,
    FixedClock clock,
    String homeId,
  })
>
_setupEnv() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  final prefs = await DevicePrefs.inMemory();
  final secure = MemorySecureStore();
  final clock = FixedClock(DateTime.utc(2026, 11, 20, 9, 0));
  final container = ProviderContainer(
    overrides: [
      dbProvider.overrideWithValue(db),
      prefsProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(secure),
      clockProvider.overrideWithValue(clock),
    ],
  );
  final keys = await container.read(deviceKeysProvider.future);
  final homeId = await container.read(homeRepoProvider).createHome(
    creatorName: 'Ananya',
    homeName: 'Iyer Home',
    keys: keys,
    createdAt: clock.nowMs,
    nonceB64: 'nonce1',
    model: 'Pixel',
  );
  return (
    container: container,
    db: db,
    prefs: prefs,
    clock: clock,
    homeId: homeId,
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  const fast = KdfParams(memKiB: 16384, t: 1, p: 1);

  test('runs backup lifecycle: ok -> unchanged -> changed -> partial -> manual -> notSetUp', () async {
    final env = await _setupEnv();
    addTearDown(() async {
      env.container.dispose();
      await env.db.close();
    });

    final store = env.container.read(backupConfigStoreProvider);
    final dest1 = DestinationConfig(
      destId: 'd1',
      kind: 'folder',
      label: 'Primary',
      settings: const {'treeUri': 'content://com.android.externalstorage.documents/tree/primary%3ABackups'},
    );
    await store.save(
      env.homeId,
      BackupConfig(destinations: [dest1], password: 'correct horse battery'),
    );

    final fakes = <String, FakeDestination>{'d1': FakeDestination()};
    final runner = BackupRunner(
      env.container.read,
      open: (d) async => fakes[d.destId]!,
      kdfOverride: fast,
    );

    // 1. First run -> ok
    final r1 = await runner.run(env.homeId);
    expect(r1, BackupRunResult.ok);
    expect(fakes['d1']!.files.length, 1);
    expect(fakes['d1']!.files.values.single.sublist(0, 4), [0x4E, 0x4D, 0x42, 0x4B]);

    final statusRow = await (env.db.select(env.db.backupStatus)
          ..where((t) => t.id.equals(env.prefs.deviceId)))
        .getSingle();
    final destsList = jsonDecode(statusRow.destsJson) as List;
    expect(destsList.single['providerKind'], 'folder');
    expect(destsList.single['lastResult'], 'ok');

    // 2. Second run with no changes -> unchanged
    env.clock.advance(const Duration(minutes: 1));
    final r2 = await runner.run(env.homeId);
    expect(r2, BackupRunResult.unchanged);
    expect(fakes['d1']!.files.length, 1);
    expect((await store.load(env.homeId)).lastSkip, 'unchanged');

    // 3. After ChangeWriter write -> ok, 2 files
    env.clock.advance(const Duration(minutes: 1));
    await env.container.read(changesProvider).write('New note', (c) {
      c.create('dev_notes', {'title': 'Groceries', 'taps': 1}, id: 'n1');
    }, homeId: env.homeId);
    final r3 = await runner.run(env.homeId);
    expect(r3, BackupRunResult.ok);
    expect(fakes['d1']!.files.length, 2);

    // 4. Two destinations, first failing with auth -> partial
    env.clock.advance(const Duration(minutes: 1));
    final cfg4 = await store.load(env.homeId);
    cfg4.destinations.first.lastCommittedHeads = 'force-due';
    cfg4.destinations.add(
      DestinationConfig(
        destId: 'd2',
        kind: 'folder',
        label: 'Secondary',
        settings: const {'treeUri': 'content://usb/tree/123'},
      ),
    );
    await store.save(env.homeId, cfg4);
    fakes['d1']!.failWith = DestError.auth;
    fakes['d2'] = FakeDestination();

    final r4 = await runner.run(env.homeId);
    expect(r4, BackupRunResult.partial);
    expect(fakes['d2']!.files.length, 1);
    final after4 = await store.load(env.homeId);
    expect(after4.destinations[0].lastResult, 'auth');
    expect(after4.destinations[0].failures, 1);
    expect(after4.consecutiveFailures, 0);

    // 5. manual: true with no change -> uploads again
    env.clock.advance(const Duration(minutes: 1));
    fakes['d1']!.failWith = null;
    final r5 = await runner.run(env.homeId, manual: true);
    expect(r5, BackupRunResult.ok);
    expect(fakes['d1']!.files.length, 3);
    expect(fakes['d2']!.files.length, 2);

    // 6. No password -> notSetUp
    final cfg6 = await store.load(env.homeId);
    cfg6.password = null;
    await store.save(env.homeId, cfg6);
    expect(await runner.run(env.homeId), BackupRunResult.notSetUp);
  });
}
