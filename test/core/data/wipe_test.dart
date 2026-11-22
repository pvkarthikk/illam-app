import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/data/wipe.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('wipeHome clears tables, home keys and currentHomeId while keeping deviceId', () async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final prefs = await DevicePrefs.inMemory();
    final secure = MemorySecureStore();
    final clock = FixedClock(DateTime(2026, 11, 20, 9));
    final writer = ChangeWriter(
      db,
      CollectionRegistry.build(db),
      HlcClock(clock, prefs),
      prefs,
    );

    await prefs.setCurrentHomeId('NM-TEST');
    final deviceId = prefs.deviceId;
    await writer.write('Seed home', (c) {
      c.create('homes', {
        'name': 'Test',
        'home_key_id': 'genesis',
      }, id: 'NM-TEST');
      c.create('members', {'full_name': 'Tester', 'role': 'admin'}, id: 'm1');
    });
    await secure.write(SecureKeys.homeKey('NM-TEST', 'genesis'), 'secret');

    final wiper = PhoneWiper(db, prefs, secure);
    await wiper.wipeHome();

    expect(await db.select(db.homes).get(), isEmpty);
    expect(await db.select(db.members).get(), isEmpty);
    expect(await db.select(db.ops).get(), isEmpty);
    expect(await secure.read(SecureKeys.homeKey('NM-TEST', 'genesis')), isNull);
    expect(prefs.currentHomeId, isNull);
    expect(prefs.deviceId, deviceId);
  });
}
