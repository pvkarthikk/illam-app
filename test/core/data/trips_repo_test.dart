import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/trips_repo.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

Future<(NestDatabase, TripsRepo, ChangeWriter)> _openRepo() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-TRP1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 27, 9, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
    validator: const Validator(),
    clock: clock,
  );
  await changes.write('Seed home & member', (c) {
    c.create('homes', {'name': 'Home'}, id: 'NM-TRP1');
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
    }, id: 'mem-1');
  }, homeId: 'NM-TRP1');
  final repo = TripsRepo(db, changes, prefs);
  return (db, repo, changes);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('TripsRepo createTrip copies initialItems atomically with undo', () async {
    final (db, repo, _) = await _openRepo();
    addTearDown(db.close);

    final created = await repo.createTrip(
      title: 'Goa family trip',
      startDate: '2026-11-29',
      endDate: '2026-12-02',
      note: 'Morning flight',
      initialItems: const ['Chargers', 'ID cards', '  '],
    );
    expect(created.id, isNotEmpty);

    var trips = await repo.watchTrips('NM-TRP1').first;
    var items = await repo.watchTripItems('NM-TRP1', created.id).first;
    expect(trips.map((t) => t.title), ['Goa family trip']);
    expect(items.map((i) => i.title), ['Chargers', 'ID cards']);
    expect(items.every((i) => !i.done), isTrue);

    await created.result.undo!.run();
    trips = await repo.watchTrips('NM-TRP1').first;
    items = await repo.watchTripItems('NM-TRP1', created.id).first;
    expect(trips, isEmpty);
    expect(items, isEmpty);
  });

  test('TripsRepo toggles checks, resets, imports generic items & deletes trip', () async {
    final (db, repo, _) = await _openRepo();
    addTearDown(db.close);

    await repo.addTemplateItems(const ['Chargers', 'Medicines']);
    final templates = await repo.watchTemplateItems('NM-TRP1').first;
    expect(templates.map((t) => t.title), ['Chargers', 'Medicines']);

    final created = await repo.createTrip(
      title: 'Ooty',
      startDate: '2026-12-10',
      initialItems: const ['Chargers'],
    );
    var items = await repo.watchTripItems('NM-TRP1', created.id).first;
    await repo.setTripItemDone(items.first.id, true);
    items = await repo.watchTripItems('NM-TRP1', created.id).first;
    expect(items.first.done, isTrue);
    expect(items.first.doneBy, 'mem-1');

    await repo.importTemplateItems(created.id, const ['Medicines'], startOrder: 1);
    items = await repo.watchTripItems('NM-TRP1', created.id).first;
    expect(items.map((i) => i.title), ['Chargers', 'Medicines']);

    await repo.resetTripChecks([items.first.id]);
    items = await repo.watchTripItems('NM-TRP1', created.id).first;
    expect(items.every((i) => !i.done), isTrue);

    await repo.deleteTrip('NM-TRP1', created.id);
    expect(await repo.watchTrips('NM-TRP1').first, isEmpty);
    expect(await repo.watchAllTripItems('NM-TRP1').first, isEmpty);
  });
}
