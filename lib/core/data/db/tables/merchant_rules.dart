import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('MerchantRule')
class MerchantRules extends Table with SyncedColumns {
  TextColumn get merchantKey => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
}
