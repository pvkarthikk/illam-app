import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';

class DemoSeeder {
  DemoSeeder(this.ref);
  final Ref ref;

  /// Each phase adds ONE private method and ONE line here, in this order. Every method is idempotent.
  Future<void> load() async {
    // P03: await _seedHomeAndMembers();   ← must stay first (creates the home if missing)
    // P04: await _seedStaff();
    // P05: await _seedPay();
    // P06: await _seedItems();
    // P08: await _seedTasks();
    // P09: await _seedMeals();
    // P10: await _seedMoney();
    await _seedDevNotes();
  }

  Future<void> _seedDevNotes() async {
    final prefs = ref.read(prefsProvider);
    final home = prefs.currentHomeId ?? labHomeId;
    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.devNotes)
              ..where((n) => n.homeId.equals(home) & n.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('dev_notes', {'title': 'Milk 2L'});
      c.create('dev_notes', {'title': 'Call plumber'});
      c.create('dev_notes', {'title': 'Pay rent'});
    }, homeId: home);
  }
}
