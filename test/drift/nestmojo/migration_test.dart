// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v11.dart' as v11;
import 'generated/schema_v12.dart' as v12;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = NestDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v11 to v12 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldOpsData = <v11.OpsData>[];
    final expectedNewOpsData = <v12.OpsData>[];

    final oldFieldClocksData = <v11.FieldClocksData>[];
    final expectedNewFieldClocksData = <v12.FieldClocksData>[];

    final oldDevNotesData = <v11.DevNotesData>[];
    final expectedNewDevNotesData = <v12.DevNotesData>[];

    final oldHomesData = <v11.HomesData>[];
    final expectedNewHomesData = <v12.HomesData>[];

    final oldMembersData = <v11.MembersData>[];
    final expectedNewMembersData = <v12.MembersData>[];

    final oldStaffData = <v11.StaffData>[];
    final expectedNewStaffData = <v12.StaffData>[];

    final oldVisitsData = <v11.VisitsData>[];
    final expectedNewVisitsData = <v12.VisitsData>[];

    final oldLeavesData = <v11.LeavesData>[];
    final expectedNewLeavesData = <v12.LeavesData>[];

    final oldPayRulesData = <v11.PayRulesData>[];
    final expectedNewPayRulesData = <v12.PayRulesData>[];

    final oldPayAdjustmentsData = <v11.PayAdjustmentsData>[];
    final expectedNewPayAdjustmentsData = <v12.PayAdjustmentsData>[];

    final oldSettlementAttemptsData = <v11.SettlementAttemptsData>[];
    final expectedNewSettlementAttemptsData = <v12.SettlementAttemptsData>[];

    final oldExpensesData = <v11.ExpensesData>[];
    final expectedNewExpensesData = <v12.ExpensesData>[];

    final oldBillsData = <v11.BillsData>[];
    final expectedNewBillsData = <v12.BillsData>[];

    final oldMerchantRulesData = <v11.MerchantRulesData>[];
    final expectedNewMerchantRulesData = <v12.MerchantRulesData>[];

    final oldItemsData = <v11.ItemsData>[];
    final expectedNewItemsData = <v12.ItemsData>[];

    final oldItemHistoryData = <v11.ItemHistoryData>[];
    final expectedNewItemHistoryData = <v12.ItemHistoryData>[];

    final oldRecipesData = <v11.RecipesData>[];
    final expectedNewRecipesData = <v12.RecipesData>[];

    final oldMealSlotsData = <v11.MealSlotsData>[];
    final expectedNewMealSlotsData = <v12.MealSlotsData>[];

    final oldPantryData = <v11.PantryData>[];
    final expectedNewPantryData = <v12.PantryData>[];

    final oldRoutinesData = <v11.RoutinesData>[];
    final expectedNewRoutinesData = <v12.RoutinesData>[];

    final oldTodosData = <v11.TodosData>[];
    final expectedNewTodosData = <v12.TodosData>[];

    final oldMemberOpsData = <v11.MemberOpsData>[];
    final expectedNewMemberOpsData = <v12.MemberOpsData>[];

    final oldMemberDevicesData = <v11.MemberDevicesData>[];
    final expectedNewMemberDevicesData = <v12.MemberDevicesData>[];

    final oldSyncPeersData = <v11.SyncPeersData>[];
    final expectedNewSyncPeersData = <v12.SyncPeersData>[];

    final oldBackupStatusData = <v11.BackupStatusData>[];
    final expectedNewBackupStatusData = <v12.BackupStatusData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 11,
      newVersion: 12,
      createOld: v11.DatabaseAtV11.new,
      createNew: v12.DatabaseAtV12.new,
      openTestedDatabase: NestDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.ops, oldOpsData);
        batch.insertAll(oldDb.fieldClocks, oldFieldClocksData);
        batch.insertAll(oldDb.devNotes, oldDevNotesData);
        batch.insertAll(oldDb.homes, oldHomesData);
        batch.insertAll(oldDb.members, oldMembersData);
        batch.insertAll(oldDb.staff, oldStaffData);
        batch.insertAll(oldDb.visits, oldVisitsData);
        batch.insertAll(oldDb.leaves, oldLeavesData);
        batch.insertAll(oldDb.payRules, oldPayRulesData);
        batch.insertAll(oldDb.payAdjustments, oldPayAdjustmentsData);
        batch.insertAll(oldDb.settlementAttempts, oldSettlementAttemptsData);
        batch.insertAll(oldDb.expenses, oldExpensesData);
        batch.insertAll(oldDb.bills, oldBillsData);
        batch.insertAll(oldDb.merchantRules, oldMerchantRulesData);
        batch.insertAll(oldDb.items, oldItemsData);
        batch.insertAll(oldDb.itemHistory, oldItemHistoryData);
        batch.insertAll(oldDb.recipes, oldRecipesData);
        batch.insertAll(oldDb.mealSlots, oldMealSlotsData);
        batch.insertAll(oldDb.pantry, oldPantryData);
        batch.insertAll(oldDb.routines, oldRoutinesData);
        batch.insertAll(oldDb.todos, oldTodosData);
        batch.insertAll(oldDb.memberOps, oldMemberOpsData);
        batch.insertAll(oldDb.memberDevices, oldMemberDevicesData);
        batch.insertAll(oldDb.syncPeers, oldSyncPeersData);
        batch.insertAll(oldDb.backupStatus, oldBackupStatusData);
      },
      validateItems: (newDb) async {
        expect(expectedNewOpsData, await newDb.select(newDb.ops).get());
        expect(
          expectedNewFieldClocksData,
          await newDb.select(newDb.fieldClocks).get(),
        );
        expect(
          expectedNewDevNotesData,
          await newDb.select(newDb.devNotes).get(),
        );
        expect(expectedNewHomesData, await newDb.select(newDb.homes).get());
        expect(expectedNewMembersData, await newDb.select(newDb.members).get());
        expect(expectedNewStaffData, await newDb.select(newDb.staff).get());
        expect(expectedNewVisitsData, await newDb.select(newDb.visits).get());
        expect(expectedNewLeavesData, await newDb.select(newDb.leaves).get());
        expect(
          expectedNewPayRulesData,
          await newDb.select(newDb.payRules).get(),
        );
        expect(
          expectedNewPayAdjustmentsData,
          await newDb.select(newDb.payAdjustments).get(),
        );
        expect(
          expectedNewSettlementAttemptsData,
          await newDb.select(newDb.settlementAttempts).get(),
        );
        expect(
          expectedNewExpensesData,
          await newDb.select(newDb.expenses).get(),
        );
        expect(expectedNewBillsData, await newDb.select(newDb.bills).get());
        expect(
          expectedNewMerchantRulesData,
          await newDb.select(newDb.merchantRules).get(),
        );
        expect(expectedNewItemsData, await newDb.select(newDb.items).get());
        expect(
          expectedNewItemHistoryData,
          await newDb.select(newDb.itemHistory).get(),
        );
        expect(expectedNewRecipesData, await newDb.select(newDb.recipes).get());
        expect(
          expectedNewMealSlotsData,
          await newDb.select(newDb.mealSlots).get(),
        );
        expect(expectedNewPantryData, await newDb.select(newDb.pantry).get());
        expect(
          expectedNewRoutinesData,
          await newDb.select(newDb.routines).get(),
        );
        expect(expectedNewTodosData, await newDb.select(newDb.todos).get());
        expect(
          expectedNewMemberOpsData,
          await newDb.select(newDb.memberOps).get(),
        );
        expect(
          expectedNewMemberDevicesData,
          await newDb.select(newDb.memberDevices).get(),
        );
        expect(
          expectedNewSyncPeersData,
          await newDb.select(newDb.syncPeers).get(),
        );
        expect(
          expectedNewBackupStatusData,
          await newDb.select(newDb.backupStatus).get(),
        );
      },
    );
  });
}
