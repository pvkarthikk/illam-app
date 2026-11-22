import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('devNotesProvider and opStatsProvider stream updates from writes', () async {
    final prefs = await DevicePrefs.inMemory();
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(changesProvider).write(
      't',
      (c) => c.create('dev_notes', {'title': 'Milk'}),
      homeId: labHomeId,
    );

    final subNotes = container.listen(devNotesProvider, (_, _) {});
    final subStats = container.listen(opStatsProvider, (_, _) {});
    addTearDown(subNotes.close);
    addTearDown(subStats.close);

    final notes = await container.read(devNotesProvider.future);
    final stats = await container.read(opStatsProvider.future);
    expect(notes.length, 1);
    expect(notes.single.title, 'Milk');
    expect(stats.total, 2);
  });
}
