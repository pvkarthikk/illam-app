import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/providers.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('DemoSeeder.load is idempotent and seeds 3 notes', () async {
    final prefs = await DevicePrefs.inMemory();
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    final seeder = container.read(demoSeederProvider);
    await seeder.load();
    await seeder.load();

    final notes = await db.select(db.devNotes).get();
    expect(notes.length, 3);
    expect(
      notes.map((n) => n.title).toSet(),
      {'Milk 2L', 'Call plumber', 'Pay rent'},
    );
  });
}
