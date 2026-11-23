import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('ItemRow')
@TableIndex(name: 'items_list_done', columns: {#list, #done})
@TableIndex(name: 'items_list_name_done', columns: {#list, #nameKey, #done})
@TableIndex(
  name: 'items_home_list_done',
  columns: {#homeId, #list, #deleted, #done},
)
@TableIndex(
  name: 'items_home_list_name_done',
  columns: {#homeId, #list, #nameKey, #deleted, #done},
)
class Items extends Table with SyncedColumns {
  TextColumn get list => text().withDefault(const Constant('grocery'))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get nameKey => text().withDefault(const Constant(''))();
  IntColumn get qtyMilli => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant(''))();
  TextColumn get channel => text().withDefault(const Constant('zepto'))();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get note => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get doneAt => integer().nullable()();
  TextColumn get doneBy => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
}
