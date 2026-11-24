import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:nm_flat/core/data/db/database.steps.dart';
import 'package:nm_flat/core/data/db/tables/backup_status.dart';
import 'package:nm_flat/core/data/db/tables/bills.dart';
import 'package:nm_flat/core/data/db/tables/dev_notes.dart';
import 'package:nm_flat/core/data/db/tables/expenses.dart';
import 'package:nm_flat/core/data/db/tables/homes.dart';
import 'package:nm_flat/core/data/db/tables/item_history.dart';
import 'package:nm_flat/core/data/db/tables/items.dart';
import 'package:nm_flat/core/data/db/tables/meal_slots.dart';
import 'package:nm_flat/core/data/db/tables/member_devices.dart';
import 'package:nm_flat/core/data/db/tables/member_ops.dart';
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
import 'package:nm_flat/core/data/db/tables/sync_peers.dart';
import 'package:nm_flat/core/data/db/tables/todos.dart';

part 'database.g.dart';

const int kReleaseBaseline = 11;

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
    MemberOps,
    MemberDevices,
    SyncPeers,
    BackupStatus,
  ],
)
class NestDatabase extends _$NestDatabase {
  NestDatabase(super.e);

  factory NestDatabase.open({required String keyHex}) => NestDatabase(
    driftDatabase(
      name: 'nestmojo',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        setup: (db) {
          assert(
            db.select('PRAGMA cipher;').isNotEmpty,
            'sqlite3mc missing: check hooks in pubspec.yaml',
          );
          db.execute("PRAGMA key = '$keyHex';");
          db.execute('PRAGMA journal_mode = WAL;');
        },
      ),
    ),
  );

  NestDatabase.forTesting(QueryExecutor e)
    : super(DatabaseConnection(e, closeStreamsSynchronously: true));

  @override
  int get schemaVersion => 14; // raise by 1 for every table change

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < kReleaseBaseline) {
        for (final t in allTables.toList().reversed) {
          await m.deleteTable(t.actualTableName);
        }
        await m.createAll();
        return;
      }
      await stepByStep(
        from11To12: (m, schema) async {
          await m.createIndex(schema.itemsListDone);
          await m.createIndex(schema.itemsListNameDone);
          await m.createIndex(schema.todosDoneDue);
          await m.createIndex(schema.expensesDateCreated);
          await m.createIndex(schema.expensesSourcePaidBy);
          await m.createIndex(schema.billsActiveDueDay);
          await m.createIndex(schema.visitsStaffDate);
          await m.createIndex(schema.visitsStaffOut);
          await m.createIndex(schema.itemHistoryListLast);
          await m.createIndex(schema.settlementAttemptsStaffMonth);
          await m.createIndex(schema.payAdjustmentsStaffMonth);
        },
        from12To13: (m, schema) async {
          await m.createIndex(schema.itemsHomeListDone);
          await m.createIndex(schema.itemsHomeListNameDone);
        },
        from13To14: (m, schema) async {
          await m.createIndex(schema.opsDeviceSeq);
          await m.createIndex(schema.opsHomeDeviceSeq);
          await m.createIndex(schema.opsTblEntity);
          await m.createIndex(schema.visitsHomeDate);
          await m.createIndex(schema.visitsHomeOut);
          await m.createIndex(schema.leavesHomeDate);
        },
      )(m, from, to);
    },
  );

  /// Developer "Wipe this phone" and P03's one-time switch to real device keys.
  Future<void> wipeAll() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}
