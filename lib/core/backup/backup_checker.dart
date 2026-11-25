import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/backup/backup_check_db.dart'
    if (dart.library.js_interop) 'package:nm_flat/core/backup/backup_check_db_web.dart';
import 'package:nm_flat/core/backup/backup_codec.dart';
import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/sync_reactions.dart';

class _SilentReactions extends SyncReactions {
  _SilentReactions(super.db, super.prefs);

  @override
  Future<void> flush() async {}

  @override
  Future<void> memberJoined(String memberId, String name) async {}
}

/// Verifies the newest backup file end-to-end in an isolated in-memory database.
class BackupChecker {
  const BackupChecker(this.read, {this.open});

  final Reader read;
  final Future<BackupDestination> Function(DestinationConfig d)? open;

  Future<({int items, int sizeBytes})> checkLatest(String homeId) async {
    try {
      final config = await read(backupConfigStoreProvider).load(homeId);
      final password = config.password;
      if (config.destinations.isEmpty || password == null || password.isEmpty) {
        throw const BackupFormatException(BackupError.damaged);
      }

      final sortedDests = [...config.destinations]
        ..sort((a, b) => (b.lastSuccessAt ?? 0).compareTo(a.lastSuccessAt ?? 0));
      final targetDest = sortedDests.first;

      final db = read(dbProvider);
      final home = await (db.select(
        db.homes,
      )..where((h) => h.id.equals(homeId))).getSingleOrNull();
      final vaultId = home?.vaultId ?? '';
      final vault8 = vaultId.length >= 8 ? vaultId.substring(0, 8) : vaultId;

      final secure = read(secureStoreProvider);
      final dest = open != null
          ? await open!(targetDest)
          : await destinationFor(targetDest, secure);
      final files = await dest.list();
      final matching = <({RemoteBackupFile file, String stamp})>[];
      for (final f in files) {
        final m = backupNameRe.firstMatch(f.name);
        if (m == null) continue;
        if (vault8.isNotEmpty && m.group(1) != vault8) continue;
        matching.add((file: f, stamp: m.group(2)!));
      }
      if (matching.isEmpty) {
        throw const BackupFormatException(BackupError.damaged);
      }
      matching.sort((a, b) => b.stamp.compareTo(a.stamp));
      final newest = matching.first.file;

      final bytes = await dest.download(newest.name);
      final decoded = await BackupCodec.decode(bytes, password);
      final snap = await Snapshot.decode(decoded.json);

      final conn = await openBackupCheckConnection();
      final tempDb = NestDatabase(conn);
      final prefs = read(prefsProvider);
      final tempContainer = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(tempDb),
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          prefsProvider.overrideWithValue(prefs),
          syncReactionsProvider.overrideWithValue(
            _SilentReactions(tempDb, prefs),
          ),
        ],
      );
      try {
        await tempContainer
            .read(snapshotImporterProvider)
            .import(snap, eraseOnFailure: false);
        final tempPending = (await tempDb
                .customSelect(
                  "SELECT COUNT(*) AS n FROM ops WHERE status = 'pending'",
                )
                .getSingle())
            .read<int>('n');
        final dbPending = (await db
                .customSelect(
                  "SELECT COUNT(*) AS n FROM ops WHERE home_id = ? AND status = 'pending'",
                  variables: [Variable.withString(homeId)],
                )
                .getSingle())
            .read<int>('n');
        if (tempPending > dbPending) {
          throw const BackupFormatException(BackupError.damaged);
        }
      } finally {
        tempContainer.dispose();
        await tempDb.close();
      }

      return (items: snap.ops.length, sizeBytes: bytes.length);
    } on DestinationException {
      rethrow;
    } on BackupFormatException {
      throw const BackupFormatException(BackupError.damaged);
    } on Object {
      throw const BackupFormatException(BackupError.damaged);
    }
  }
}
