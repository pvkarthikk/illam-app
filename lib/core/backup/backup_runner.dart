import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/backup/backup_codec.dart';
import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/folder_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/retention.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';

enum BackupRunResult { notSetUp, unchanged, ok, partial, failed }

/// Orchestrates encrypted snapshot backups across configured destinations and updates `backup_status`.
class BackupRunner {
  BackupRunner(
    this.read, {
    this.open,
    this.kdfOverride,
  });

  final Reader read;
  final Future<BackupDestination> Function(DestinationConfig d)? open;
  final KdfParams? kdfOverride;

  Future<BackupRunResult> run(
    String homeId, {
    bool manual = false,
    void Function(int pct)? onProgress,
  }) async {
    final configStore = read(backupConfigStoreProvider);
    final config = await configStore.load(homeId);
    final password = config.password;
    if (config.destinations.isEmpty || password == null || password.isEmpty) {
      return BackupRunResult.notSetUp;
    }

    final db = read(dbProvider);
    final prefs = read(prefsProvider);
    final now = read(clockProvider).nowMs;
    final heads = await SnapshotHeads.compute(db, homeId);

    final due = [
      for (final d in config.destinations)
        if (manual ||
            d.lastCommittedHeads != heads ||
            d.lastSuccessAt == null ||
            d.lastResult != 'ok')
          d,
    ];
    if (due.isEmpty) {
      config.lastSkip = 'unchanged';
      await configStore.save(homeId, config);
      return BackupRunResult.unchanged;
    }

    config.lastSkip = null;
    onProgress?.call(10);

    final kitLive = await read(recoveryKitsProvider).ensureLive(homeId);
    final committedHeads = await SnapshotHeads.compute(db, homeId);
    final kind = kitLive ? 'full' : 'data';
    final snap = await read(snapshotBuilderProvider).build(
      homeId,
      createdAt: now,
      includeKit: kitLive,
    );
    final snapBytes = await snap.encode();

    final useLight = prefs.getFlag('backupKdfLight');
    var kdf = kdfOverride ?? (useLight ? BackupCodec.light : BackupCodec.strong);
    Uint8List file;
    try {
      final sw = Stopwatch()..start();
      file = await BackupCodec.encode(
        snapshotJson: snapBytes,
        password: password,
        vaultId: snap.vaultId,
        kind: kind,
        kdf: kdf,
        createdAt: now,
      );
      sw.stop();
      if (kdfOverride == null && !useLight && sw.elapsed.inSeconds > 20) {
        await prefs.setFlag('backupKdfLight', true);
      }
    } on Object catch (e) {
      if (kdfOverride == null &&
          !useLight &&
          (e is OutOfMemoryError || e.toString().contains('OutOfMemory'))) {
        await prefs.setFlag('backupKdfLight', true);
        kdf = BackupCodec.light;
        file = await BackupCodec.encode(
          snapshotJson: snapBytes,
          password: password,
          vaultId: snap.vaultId,
          kind: kind,
          kdf: kdf,
          createdAt: now,
        );
      } else {
        rethrow;
      }
    }

    onProgress?.call(40);
    final snapshotId = parseHeader(file).header.snapshotId;
    final name = backupFileName(
      vaultId: snap.vaultId,
      snapshotId: snapshotId,
      createdAtMs: now,
    );

    final secure = read(secureStoreProvider);
    final vault8 = snap.vaultId.length >= 8
        ? snap.vaultId.substring(0, 8)
        : snap.vaultId;
    var successes = 0;

    for (var i = 0; i < due.length; i++) {
      final d = due[i];
      try {
        final dest = open != null
            ? await open!(d)
            : await destinationFor(d, secure);
        await dest.upload(name, file);
        if (kind == 'full') {
          d.lastFullName = name;
        }
        final listBefore = await dest.list();
        for (final oldName in namesToDelete(
          listBefore,
          vault8: vault8,
          keep: config.keep,
          protect: d.lastFullName,
        )) {
          await dest.delete(oldName);
        }
        for (final stale in await dest.staleParts(const Duration(hours: 24))) {
          await dest.delete(stale.name);
        }
        final listAfter = await dest.list();
        final kept = listAfter.where((f) {
          final m = backupNameRe.firstMatch(f.name);
          return m != null && m.group(1) == vault8;
        }).length;

        d.lastSuccessAt = now;
        d.lastResult = 'ok';
        d.failures = 0;
        d.lastCommittedHeads = committedHeads;
        d.keptCount = kept;

        config.history.insert(0, {
          'at': now,
          'sizeBytes': file.length,
          'destId': d.destId,
        });
        if (config.history.length > 5) {
          config.history = config.history.sublist(0, 5);
        }
        successes++;
      } on DestinationException catch (e) {
        d.lastResult = e.error.lastResult;
        d.failures++;
      } on Object {
        d.lastResult = 'error';
        d.failures++;
      }
      onProgress?.call(40 + ((i + 1) * 60 ~/ due.length));
    }

    config.consecutiveFailures = successes > 0
        ? 0
        : config.consecutiveFailures + 1;
    await configStore.save(homeId, config);

    await _syncBackupStatus(
      homeId: homeId,
      config: config,
      committedFull: successes > 0 && kind == 'full' && kitLive,
    );

    if (successes == due.length) return BackupRunResult.ok;
    if (successes > 0) return BackupRunResult.partial;
    return BackupRunResult.failed;
  }

  Future<void> _syncBackupStatus({
    required String homeId,
    required BackupConfig config,
    required bool committedFull,
  }) async {
    final db = read(dbProvider);
    final prefs = read(prefsProvider);
    final deviceId = prefs.deviceId;
    final existing =
        await (db.select(db.backupStatus)
              ..where((t) => t.id.equals(deviceId) & t.homeId.equals(homeId)))
            .getSingleOrNull();

    final memberId = prefs.memberId ?? '';
    final frequency = config.frequency;
    final recoveryCapable = committedFull
        ? true
        : (existing?.recoveryCapable ?? false);
    final offPhone =
        config.destinations.any(
          (d) =>
              d.lastSuccessAt != null &&
              (d.kind != 'folder' ||
                  !FolderDestination.isPhoneStorage(
                    (d.settings['treeUri'] as String?) ?? '',
                  )),
        ) ||
        prefs.getFlag('debugFolderOffPhone');
    final destsJson = jsonEncode([
      for (final d in config.destinations)
        {
          'providerKind': d.kind,
          'lastSuccessAt': d.lastSuccessAt,
          'lastResult': d.lastResult,
        },
    ]);

    if (existing == null) {
      await read(changesProvider).write('Backup status', (c) {
        c.create('backup_status', {
          'member_id': memberId,
          'frequency': frequency,
          'recovery_capable': recoveryCapable,
          'off_phone': offPhone,
          'dests_json': destsJson,
        }, id: deviceId);
      }, homeId: homeId);
      return;
    }

    final updates = <String, Object?>{};
    if (existing.memberId != memberId) updates['member_id'] = memberId;
    if (existing.frequency != frequency) updates['frequency'] = frequency;
    if (existing.recoveryCapable != recoveryCapable) {
      updates['recovery_capable'] = recoveryCapable;
    }
    if (existing.offPhone != offPhone) updates['off_phone'] = offPhone;
    if (existing.destsJson != destsJson) updates['dests_json'] = destsJson;

    if (updates.isEmpty) return;

    await read(changesProvider).write('Backup status', (c) {
      for (final e in updates.entries) {
        c.set('backup_status', deviceId, e.key, e.value);
      }
    }, homeId: homeId);
  }
}
