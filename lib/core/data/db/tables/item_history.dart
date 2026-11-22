import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('ItemHistoryRow')
@TableIndex(name: 'item_history_list_last', columns: {#list, #lastBoughtAt})
class ItemHistory extends Table with SyncedColumns {
  TextColumn get list => text().withDefault(const Constant('grocery'))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get nameKey => text().withDefault(const Constant(''))();
  TextColumn get usualChannel => text().nullable()();
  IntColumn get lastBoughtAt => integer().nullable()();
  IntColumn get timesBought => integer().withDefault(const Constant(0))();
  IntColumn get lastQtyMilli => integer().nullable()();
  TextColumn get lastUnit => text().nullable()();
}
