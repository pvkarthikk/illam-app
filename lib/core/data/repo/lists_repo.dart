import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/item_category.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/domain/order_handoff.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/domain/usual_store.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/util/hash_id.dart';

enum AddKind { added, merged, incompatible }

class AddOutcome {
  const AddOutcome(this.kind, this.name, this.channel, this.qtyText, this.undo);

  final AddKind kind;
  final String name;
  final String channel;
  final String qtyText;
  final UndoToken? undo;
}

class ListsRepo {
  ListsRepo(this.db, this.changes, this.prefs, this.clock);

  final NestDatabase db;
  final ChangeWriter changes;
  final DevicePrefs prefs;
  final Clock clock;

  String get _me => prefs.memberId ?? prefs.deviceId;
  int get _now => clock.nowMs;

  Stream<List<ItemRow>> watchItems(String homeId, String list) =>
      (db.select(db.items)
            ..where(
              (i) =>
                  i.homeId.equals(homeId) &
                  i.list.equals(list) &
                  i.deleted.equals(false),
            )
            ..orderBy([
              (i) => OrderingTerm.asc(i.createdAt),
              (i) => OrderingTerm.asc(i.id),
            ]))
          .watch();

  Stream<List<ItemRow>> watchOpenItems(String homeId) =>
      (db.select(db.items)
            ..where(
              (i) =>
                  i.homeId.equals(homeId) &
                  i.done.equals(false) &
                  i.deleted.equals(false),
            )
            ..orderBy([
              (i) => OrderingTerm.asc(i.createdAt),
              (i) => OrderingTerm.asc(i.id),
            ]))
          .watch();

  Stream<List<ItemHistoryRow>> watchHistory(String homeId, String list) =>
      (db.select(db.itemHistory)
            ..where(
              (h) =>
                  h.homeId.equals(homeId) &
                  h.list.equals(list) &
                  h.deleted.equals(false) &
                  h.lastBoughtAt.isNotNull(),
            )
            ..orderBy([(h) => OrderingTerm.desc(h.lastBoughtAt)]))
          .watch();

  Stream<List<ItemHistoryRow>> watchUsual(String homeId, String list) =>
      (db.select(db.itemHistory)..where(
            (h) =>
                h.homeId.equals(homeId) &
                h.list.equals(list) &
                h.deleted.equals(false) &
                h.usualChannel.isNotNull(),
          ))
          .watch();

  Future<AddOutcome> addItem({
    required String homeId,
    required String list,
    required String text,
    String? pickedChannel,
    String source = 'manual',
  }) async {
    final parsed = parseItem(text);
    final name = parsed.name;
    final nameKey = itemNameKey(name);

    // Only rows that can matter for this one item: the same name among open
    // items, and the usual store for the name (or its pre-digit prefix).
    final openRows =
        await (db.select(db.items)
              ..where(
                (i) =>
                    i.homeId.equals(homeId) &
                    i.list.equals(list) &
                    i.nameKey.equals(nameKey) &
                    i.done.equals(false) &
                    i.deleted.equals(false),
              )
              ..orderBy([
                (i) => OrderingTerm.asc(i.createdAt),
                (i) => OrderingTerm.asc(i.id),
              ]))
            .get();

    final usualKeys = {nameKey, ?_digitPrefix(nameKey)};
    final usualRows =
        await (db.select(db.itemHistory)..where(
              (h) =>
                  h.homeId.equals(homeId) &
                  h.list.equals(list) &
                  h.deleted.equals(false) &
                  h.usualChannel.isNotNull() &
                  h.nameKey.isIn(usualKeys),
            ))
            .get();

    final usualByKey = <String, String>{
      for (final h in usualRows)
        if (h.usualChannel != null) h.nameKey: h.usualChannel!,
    };

    final snaps = [
      for (final r in openRows)
        ItemSnap(
          id: r.id,
          nameKey: r.nameKey,
          unit: r.unit,
          qtyMilli: r.qtyMilli,
          createdAt: r.createdAt,
        ),
    ];

    final decision = decideAdd(snaps, nameKey, parsed.unit, parsed.qtyMilli);
    switch (decision) {
      case AddNew():
        final channel =
            pickedChannel ??
            usualStore(
              list: list,
              nameKey: nameKey,
              usualByKey: usualByKey,
              lastChosen: prefs.lastStore(list),
            ).channel;
        final res = await changes.write('Added $name', (c) {
          final id = c.create('items', {
            'list': list,
            'name': name,
            'name_key': nameKey,
            'unit': parsed.unit,
            'channel': channel,
            'category': guessCategory(name),
            'source': source,
          });
          c.inc('items', id, 'qty_milli', parsed.qtyMilli);
        });
        return AddOutcome(
          AddKind.added,
          name,
          channel,
          formatQty(parsed.qtyMilli, parsed.unit),
          res.undo,
        );
      case MergeInto(:final group, :final incMilli):
        final survivor = openRows.firstWhere((r) => r.id == group.survivor.id);
        final res = await changes.write('Added ${survivor.name}', (c) {
          c.inc('items', survivor.id, 'qty_milli', incMilli);
        });
        return AddOutcome(
          AddKind.merged,
          survivor.name,
          survivor.channel,
          formatQty(group.totalMilli + incMilli, survivor.unit),
          res.undo,
        );
      case Incompatible(:final group):
        final survivor = openRows.firstWhere((r) => r.id == group.survivor.id);
        return AddOutcome(
          AddKind.incompatible,
          survivor.name,
          survivor.channel,
          formatQty(group.totalMilli, survivor.unit),
          null,
        );
    }
  }

  void _applyRename(ChangeBuilder c, List<String> ids, String newName) {
    final key = itemNameKey(newName);
    for (final id in ids) {
      c.set('items', id, 'name', newName);
      c.set('items', id, 'name_key', key);
    }
  }

  void _applyCategory(ChangeBuilder c, List<String> ids, String cat) {
    for (final id in ids) {
      c.set('items', id, 'category', cat);
    }
  }

  void _applyQtyAndUnit(
    ChangeBuilder c,
    String survivorId,
    int deltaMilli,
    String? newUnit,
  ) {
    if (deltaMilli != 0) {
      c.inc('items', survivorId, 'qty_milli', deltaMilli);
    }
    if (newUnit != null) {
      c.set('items', survivorId, 'unit', newUnit);
    }
  }

  Future<ChangeResult> tickGroup(List<String> ids, bool done) =>
      changes.write('Ticked', (c) {
        final ts = done ? _now : null;
        final by = done ? _me : null;
        for (final id in ids) {
          c.setAll('items', id, {'done': done, 'done_at': ts, 'done_by': by});
        }
      });

  Future<ChangeResult> stepQty(String survivorId, int deltaMilli) =>
      changes.write(
        'Quantity',
        (c) => c.inc('items', survivorId, 'qty_milli', deltaMilli),
      );

  Future<ChangeResult> setQtyAndUnit(
    ItemRow survivor,
    int newMilli,
    String newUnit,
  ) => changes.write(
    'Quantity',
    (c) => _applyQtyAndUnit(
      c,
      survivor.id,
      newMilli - survivor.qtyMilli,
      newUnit != survivor.unit ? newUnit : null,
    ),
  );

  Future<ChangeResult> renameGroup(List<String> ids, String newName) =>
      changes.write('Renamed', (c) => _applyRename(c, ids, newName));

  Future<ChangeResult> setCategory(List<String> ids, String cat) =>
      changes.write('Category', (c) => _applyCategory(c, ids, cat));

  Future<ChangeResult> removeGroup(List<String> ids) =>
      changes.write('Removed', (c) {
        for (final id in ids) {
          c.delete('items', id);
        }
      });

  Future<ChangeResult> moveGroup(
    List<String> ids,
    String list,
    String nameKey,
    String name,
    String channel,
  ) => changes.write('Moved $name', (c) {
    for (final id in ids) {
      c.set('items', id, 'channel', channel);
    }
    final histId = itemHistoryId(list, nameKey);
    c.setAll('item_history', histId, {
      'deleted': false,
      'list': list,
      'name': name,
      'name_key': nameKey,
      'usual_channel': channel,
    });
  });

  void buildClearOps(ChangeBuilder c, List<ItemRow> doneItems, int nowMs) {
    for (final item in doneItems) {
      c.delete('items', item.id);
      final histId = itemHistoryId(item.list, item.nameKey);
      c.setAll('item_history', histId, {
        'deleted': false,
        'list': item.list,
        'name': item.name,
        'name_key': item.nameKey,
        'usual_channel': item.channel,
        'last_bought_at': nowMs,
        'last_qty_milli': item.qtyMilli,
        'last_unit': item.unit,
      });
      c.inc('item_history', histId, 'times_bought', 1);
      if (item.list == 'grocery') {
        c.setAll('pantry', sha1Hex(item.nameKey), {
          'deleted': false,
          'name': item.name,
          'name_key': item.nameKey,
          'in_stock': true,
        });
      }
    }
  }

  Future<(ChangeResult, int)> clearChannel(String list, String channel) async {
    final homeId = prefs.currentHomeId;
    if (homeId == null) {
      return (await changes.write('Cleared', (_) {}), 0);
    }
    final doneItems =
        await (db.select(db.items)..where(
              (i) =>
                  i.homeId.equals(homeId) &
                  i.list.equals(list) &
                  i.channel.equals(channel) &
                  i.done.equals(true) &
                  i.deleted.equals(false),
            ))
            .get();
    final res = await changes.write('Cleared $channel', (c) {
      buildClearOps(c, doneItems, _now);
    });
    return (res, doneItems.length);
  }

  Future<ChangeResult> saveGroup({
    required ItemGroup group,
    required ItemRow survivor,
    required String name,
    required int qtyMilli,
    required String unit,
    required String category,
    ItemGroup? mergeInto,
  }) => changes.write('Edited $name', (c) {
    if (mergeInto != null) {
      final inc = convertMilli(qtyMilli, unit, mergeInto.survivor.unit) ?? 0;
      if (inc != 0) {
        c.inc('items', mergeInto.survivor.id, 'qty_milli', inc);
      }
      for (final id in group.ids) {
        c.delete('items', id);
      }
      return;
    }

    if (name != survivor.name) {
      _applyRename(c, group.ids, name);
    }
    final delta = qtyMilli - group.totalMilli;
    final unitChanged = unit != survivor.unit ? unit : null;
    if (delta != 0 || unitChanged != null) {
      _applyQtyAndUnit(c, survivor.id, delta, unitChanged);
    }
    if (category != survivor.category) {
      _applyCategory(c, group.ids, category);
    }
  });

  Future<ChangeResult> applyHandoff(
    List<HandoffRow> ticked,
    String Function(HandoffLine) noteText,
  ) => changes.write('Marked ordered', (c) {
    final now = _now;
    final me = _me;
    for (final row in ticked) {
      final id = row.line.itemId;
      switch (row.kind) {
        case HandoffKind.markDone || HandoffKind.unitChanged:
          c.setAll('items', id, {'done': true, 'done_at': now, 'done_by': me});
        case HandoffKind.keepRemainder:
          c.inc('items', id, 'qty_milli', -row.line.qtyMilli);
          c.set('items', id, 'note', noteText(row.line));
      }
    }
  });
}

/// The part of [nameKey] before its first digit, as `usualStore` looks it up.
String? _digitPrefix(String nameKey) {
  final digitIdx = nameKey.indexOf(RegExp(r'\d'));
  if (digitIdx <= 0) return null;
  final cut = nameKey.substring(0, digitIdx).trim();
  return cut.isEmpty ? null : cut;
}
