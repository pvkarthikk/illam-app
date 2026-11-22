import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

class Homes extends Table with SyncedColumns {
  TextColumn get name => text().nullable()();
  IntColumn get budgetMonthlyPaise => integer().nullable()();
  TextColumn get vaultId => text().nullable()();
  TextColumn get genesisJson => text().nullable()();
  TextColumn get homeKeyId => text().nullable()();
}
