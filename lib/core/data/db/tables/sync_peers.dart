import 'package:drift/drift.dart';

/// Device-local sync peer tracking (never synced or registered in CollectionRegistry).
@DataClassName('SyncPeerRow')
class SyncPeers extends Table {
  TextColumn get deviceId => text()();
  TextColumn get homeId => text()();
  IntColumn get lastSeenAt => integer().withDefault(const Constant(0))();
  IntColumn get lastSyncAt => integer().withDefault(const Constant(0))();
  TextColumn get via => text().withDefault(const Constant('lan'))();
  TextColumn get lastHost => text().nullable()();
  IntColumn get lastPort => integer().nullable()();
  TextColumn get ackedVectorJson =>
      text().withDefault(const Constant('{}'))();
  IntColumn get ackedMemberOps => integer().withDefault(const Constant(0))();
  IntColumn get clockSkewMs => integer().withDefault(const Constant(0))();
  IntColumn get peerVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {deviceId};
}
