import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';

class TripsRepo {
  TripsRepo(this.db, this.changes, this.prefs);

  final NestDatabase db;
  final ChangeWriter changes;
  final DevicePrefs prefs;

  String get _me => prefs.memberId ?? prefs.deviceId;

  Stream<List<TripRow>> watchTrips(String homeId) =>
      (db.select(db.trips)
            ..where((t) => t.homeId.equals(homeId) & t.deleted.equals(false))
            ..orderBy([
              (t) => OrderingTerm.asc(t.startDate),
              (t) => OrderingTerm.asc(t.title),
            ]))
          .watch();

  Stream<TripRow?> watchTrip(String homeId, String id) =>
      (db.select(db.trips)
            ..where(
              (t) =>
                  t.homeId.equals(homeId) &
                  t.id.equals(id) &
                  t.deleted.equals(false),
            ))
          .watchSingleOrNull();

  Stream<List<TripItemRow>> watchTripItems(String homeId, String tripId) =>
      (db.select(db.tripItems)
            ..where(
              (i) =>
                  i.homeId.equals(homeId) &
                  i.tripId.equals(tripId) &
                  i.deleted.equals(false),
            )
            ..orderBy([
              (i) => OrderingTerm.asc(i.sortOrder),
              (i) => OrderingTerm.asc(i.createdAt),
            ]))
          .watch();

  Stream<List<TripItemRow>> watchAllTripItems(String homeId) =>
      (db.select(db.tripItems)
            ..where((i) => i.homeId.equals(homeId) & i.deleted.equals(false)))
          .watch();

  Stream<List<TripTemplateItemRow>> watchTemplateItems(String homeId) =>
      (db.select(db.tripTemplateItems)
            ..where((t) => t.homeId.equals(homeId) & t.deleted.equals(false))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Future<({String id, ChangeResult result})> createTrip({
    required String title,
    required String startDate,
    String? endDate,
    String? note,
    List<String> initialItems = const [],
  }) async {
    var tripId = '';
    final cleanTitle = title.trim();
    final cleanNote = note?.trim();
    final result = await changes.write('Trip', (c) {
      tripId = c.create('trips', {
        'title': cleanTitle,
        'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (cleanNote != null && cleanNote.isNotEmpty) 'note': cleanNote,
      });
      for (var i = 0; i < initialItems.length; i++) {
        final itemTitle = initialItems[i].trim();
        if (itemTitle.isEmpty) continue;
        c.create('trip_items', {
          'trip_id': tripId,
          'title': itemTitle,
          'done': false,
          'sort_order': i,
        });
      }
    });
    return (id: tripId, result: result);
  }

  Future<ChangeResult> updateTrip(String id, Map<String, Object?> fields) =>
      changes.write('Trip', (c) => c.setAll('trips', id, fields));

  Future<ChangeResult> deleteTrip(String homeId, String tripId) async {
    final items =
        await (db.select(db.tripItems)..where(
              (i) =>
                  i.homeId.equals(homeId) &
                  i.tripId.equals(tripId) &
                  i.deleted.equals(false),
            ))
            .get();
    return changes.write('Trip deleted', (c) {
      c.delete('trips', tripId);
      for (final item in items) {
        c.delete('trip_items', item.id);
      }
    });
  }

  Future<ChangeResult> addTripItem(
    String tripId,
    String title, {
    int sortOrder = 0,
  }) => changes.write('Trip item', (c) {
    c.create('trip_items', {
      'trip_id': tripId,
      'title': title.trim(),
      'done': false,
      'sort_order': sortOrder,
    });
  });

  Future<ChangeResult> updateTripItem(String id, String title) =>
      changes.write('Trip item', (c) => c.set('trip_items', id, 'title', title.trim()));

  Future<ChangeResult> setTripItemDone(String id, bool done) =>
      changes.write(done ? 'Item checked' : 'Item unchecked', (c) {
        c.set('trip_items', id, 'done', done);
        c.set(
          'trip_items',
          id,
          'done_at',
          done ? DateTime.now().millisecondsSinceEpoch : null,
        );
        c.set('trip_items', id, 'done_by', done ? _me : null);
      });

  Future<ChangeResult> deleteTripItem(String id) =>
      changes.write('Item deleted', (c) => c.delete('trip_items', id));

  Future<ChangeResult> importTemplateItems(
    String tripId,
    List<String> titles, {
    int startOrder = 0,
  }) => changes.write('Generic checklist imported', (c) {
    for (var i = 0; i < titles.length; i++) {
      final clean = titles[i].trim();
      if (clean.isEmpty) continue;
      c.create('trip_items', {
        'trip_id': tripId,
        'title': clean,
        'done': false,
        'sort_order': startOrder + i,
      });
    }
  });

  Future<ChangeResult> resetTripChecks(List<String> doneItemIds) =>
      changes.write('Checklist reset', (c) {
        for (final id in doneItemIds) {
          c.set('trip_items', id, 'done', false);
          c.set('trip_items', id, 'done_at', null);
          c.set('trip_items', id, 'done_by', null);
        }
      });

  Future<ChangeResult> addTemplateItem(String title, {int sortOrder = 0}) =>
      changes.write('Generic item', (c) {
        c.create('trip_template_items', {
          'title': title.trim(),
          'sort_order': sortOrder,
        });
      });

  Future<ChangeResult> addTemplateItems(
    List<String> titles, {
    int startOrder = 0,
  }) => changes.write('Starter checklist', (c) {
    for (var i = 0; i < titles.length; i++) {
      final clean = titles[i].trim();
      if (clean.isEmpty) continue;
      c.create('trip_template_items', {
        'title': clean,
        'sort_order': startOrder + i,
      });
    }
  });

  Future<ChangeResult> updateTemplateItem(String id, String title) =>
      changes.write(
        'Generic item',
        (c) => c.set('trip_template_items', id, 'title', title.trim()),
      );

  Future<ChangeResult> deleteTemplateItem(String id) =>
      changes.write('Generic item deleted', (c) {
        c.delete('trip_template_items', id);
      });
}
