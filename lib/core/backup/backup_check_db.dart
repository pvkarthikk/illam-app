import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';

/// Opens a throwaway in-memory database connection on a background isolate
/// for backup verification.
Future<DatabaseConnection> openBackupCheckConnection() async {
  final isolate = await DriftIsolate.spawn(NativeDatabase.memory);
  return isolate.connect(singleClientMode: true);
}
