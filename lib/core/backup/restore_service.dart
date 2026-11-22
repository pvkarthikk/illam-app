import 'package:drift/drift.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/device_model.dart';

enum RestoreOutcome { alreadyHere, separateCopy, deadKit, restored }

/// Imports a verified [Snapshot] and appends the device's signed `recover` op if a kit is present.
class RestoreService {
  const RestoreService(this.read);

  final Reader read;

  Future<RestoreOutcome> restore(
    Snapshot snapshot,
    String password,
    DestinationConfig dest, {
    void Function(int step)? onStep,
  }) async {
    final db = read(dbProvider);
    final existing = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(snapshot.homeId) & h.deleted.equals(false)))
        .getSingleOrNull();
    if (existing != null) return RestoreOutcome.alreadyHere;

    onStep?.call(2);
    await read(snapshotImporterProvider).import(snapshot);

    final kit = snapshot.recoveryKit;
    if (kit == null) return RestoreOutcome.separateCopy;

    onStep?.call(3);
    final k = await read(deviceKeysProvider.future);
    final payload = <String, Object?>{
      'memberId': kit['memberId'],
      'device': <String, Object?>{
        'deviceId': k.deviceId,
        'signPub': k.signPubB64,
        'agreePub': b64(k.agreePub),
        'model': await deviceModel(),
      },
      'kitPub': kit['pub'],
    };
    payload['recoverySig'] = await signRecover(
      payload,
      unb64(kit['seed'] as String),
    );
    final res = await read(
      membershipLogProvider,
    ).append(snapshot.homeId, 'recover', payload);
    if (res.effect != 'applied') return RestoreOutcome.deadKit;

    final prefs = read(prefsProvider);
    await prefs.setMemberId(kit['memberId'] as String);
    await prefs.setText(
      'provisionalRestore_${snapshot.homeId}',
      '${snapshot.createdAt}',
    );
    await prefs.setText(
      'provisionalRestoreAt_${snapshot.homeId}',
      '${read(clockProvider).nowMs}',
    );
    return RestoreOutcome.restored;
  }
}
