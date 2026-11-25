import 'package:drift/drift.dart';

/// Web stand-in: isolated in-memory backup checks are not available in browsers.
Future<DatabaseConnection> openBackupCheckConnection() async {
  throw UnsupportedError('Backup checks are not available on the web.');
}
