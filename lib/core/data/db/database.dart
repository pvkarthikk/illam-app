import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:nm_flat/core/data/db/tables/bills.dart';
import 'package:nm_flat/core/data/db/tables/dev_notes.dart';
import 'package:nm_flat/core/data/db/tables/expenses.dart';
import 'package:nm_flat/core/data/db/tables/homes.dart';
import 'package:nm_flat/core/data/db/tables/item_history.dart';
import 'package:nm_flat/core/data/db/tables/items.dart';
import 'package:nm_flat/core/data/db/tables/meal_slots.dart';
import 'package:nm_flat/core/data/db/tables/members.dart';
import 'package:nm_flat/core/data/db/tables/merchant_rules.dart';
import 'package:nm_flat/core/data/db/tables/ops.dart';
import 'package:nm_flat/core/data/db/tables/pantry.dart';
import 'package:nm_flat/core/data/db/tables/pay_adjustments.dart';
import 'package:nm_flat/core/data/db/tables/pay_rules.dart';
import 'package:nm_flat/core/data/db/tables/recipes.dart';
import 'package:nm_flat/core/data/db/tables/routines.dart';
import 'package:nm_flat/core/data/db/tables/settlement_attempts.dart';
import 'package:nm_flat/core/data/db/tables/staff.dart';
import 'package:nm_flat/core/data/db/tables/todos.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Ops,
    FieldClocks,
    DevNotes,
    Homes,
    Members,
    Staff,
    Visits,
    Leaves,
    PayRules,
    PayAdjustments,
    SettlementAttempts,
    Expenses,
    Bills,
    MerchantRules,
    Items,
    ItemHistory,
    Recipes,
    MealSlots,
    Pantry,
    Routines,
    Todos,
  ],
)
class NestDatabase extends _$NestDatabase {
  NestDatabase(super.e);

  factory NestDatabase.open() =>
      NestDatabase(driftDatabase(name: 'nestmojo'));

  NestDatabase.forTesting(QueryExecutor e)
    : super(DatabaseConnection(e, closeStreamsSynchronously: true));

  @override
  int get schemaVersion => 8; // raise by 1 for every table change

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // DEV ONLY: start fresh on schema change (until release)
      for (final t in allTables.toList().reversed) {
        await m.deleteTable(t.actualTableName);
      }
      await m.createAll();
    },
  );

  /// Developer "Wipe this phone" and P03's one-time switch to real device keys.
  Future<void> wipeAll() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}
