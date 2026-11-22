import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('en');
  });

  test('DemoSeeder.load is idempotent and seeds 3 notes', () async {
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

    final seeder = container.read(demoSeederProvider);
    await seeder.load();
    await seeder.load();

    final notes = await db.select(db.devNotes).get();
    expect(notes.length, 3);
    final members = await db.select(db.members).get();
    expect(members.length, 3);
    final staff = await db.select(db.staff).get();
    expect(staff.map((s) => s.name).toSet(), {'Lakshmi', 'Selvi'});
    final rules = await db.select(db.payRules).get();
    expect(rules.length, 2);
    final adjustments = await db.select(db.payAdjustments).get();
    expect(adjustments.length, 2);
    final attempts = await db.select(db.settlementAttempts).get();
    expect(attempts.length, 2);
    final expenses = await db.select(db.expenses).get();
    expect(expenses.length, 2);
    final items = await db.select(db.items).get();
    expect(items.length, 15);
    expect(items.where((i) => i.list == 'grocery' && !i.done).length, 9);
    expect(items.where((i) => i.list == 'shopping' && !i.done).length, 5);
    final history = await db.select(db.itemHistory).get();
    expect(history.length, 11);
    final routines = await db.select(db.routines).get();
    expect(routines.length, 8);
    final todos = await db.select(db.todos).get();
    expect(todos.length, 7);
    expect(
      notes.map((n) => n.title).toSet(),
      {'Milk 2L', 'Call plumber', 'Pay rent'},
    );
  });
}
