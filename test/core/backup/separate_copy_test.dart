import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/separate_copy.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('SeparateCopy creates a new home with copied rows, counters, and zero ops for old home', () async {
    final now = DateTime(2026, 11, 20, 9);
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    final prefs = await DevicePrefs.inMemory();
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final keys = await container.read(deviceKeysProvider.future);
    final homeA = await container.read(homeRepoProvider).createHome(
      creatorName: 'Anand',
      homeName: 'Anand Home',
      keys: keys,
      createdAt: now.millisecondsSinceEpoch,
      nonceB64: 'nonce1',
      model: 'Pixel',
    );
    await container.read(changesProvider).write('Seed notes', (c) {
      c.create('dev_notes', {
        'title': 'First',
        'body': 'Body 1',
      }, id: 'n1');
      c.create('dev_notes', {
        'title': 'Second',
        'body': 'Body 2',
      }, id: 'n2');
    }, homeId: homeA);
    await container.read(changesProvider).write('Inc taps', (c) {
      c.inc('dev_notes', 'n1', 'taps', 3);
    }, homeId: homeA);

    final newHomeId = await SeparateCopy(
      container.read,
    ).make(homeA, newHomeName: 'Anand Home (restored 20 Nov 2026)');

    expect(newHomeId, isNot(homeA));
    expect(prefs.currentHomeId, newHomeId);

    final newHome = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(newHomeId))).getSingle();
    expect(newHome.name, 'Anand Home (restored 20 Nov 2026)');

    final copiedNotes = await (db.select(
      db.devNotes,
    )..where((n) => n.homeId.equals(newHomeId))).get();
    expect(copiedNotes.length, 2);
    final byId = {for (final n in copiedNotes) n.id: n};
    expect(byId['n1']?.title, 'First');
    expect(byId['n1']?.taps, 3);
    expect(byId['n2']?.title, 'Second');
    expect(byId['n2']?.taps, 0);

    final oldOps = await (db.select(
      db.ops,
    )..where((o) => o.homeId.equals(homeA))).get();
    expect(oldOps, isEmpty);
  });
}
