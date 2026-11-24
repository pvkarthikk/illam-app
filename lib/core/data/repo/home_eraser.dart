import 'package:drift/drift.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/time/clock.dart';

/// Erases all local database rows and ring keys for a home while keeping device identity and [ControlStore].
class HomeEraser {
  HomeEraser(
    this.db,
    this.registry,
    this.prefs,
    this.keyRing, [
    this.controlStore,
    this.clock,
  ]);

  final NestDatabase db;
  final CollectionRegistry registry;
  final DevicePrefs prefs;
  final HomeKeyRing keyRing;
  final ControlStore? controlStore;
  final Clock? clock;

  static final List<Future<void> Function(String homeId)> onErase = [];

  Future<void> eraseRows(String homeId) async {
    await db.transaction(() async {
      await db.customUpdate(
        'DELETE FROM field_clocks WHERE entity_id IN '
        '(SELECT entity_id FROM ops WHERE home_id = ?)',
        variables: [Variable.withString(homeId)],
        updates: {db.fieldClocks},
        updateKind: UpdateKind.delete,
      );

      final tables = <TableInfo>[
        ...registry.tables,
        db.ops,
        db.memberOps,
        db.memberDevices,
        db.syncPeers,
      ];
      for (final t in tables) {
        await db.customUpdate(
          'DELETE FROM ${t.actualTableName} WHERE home_id = ?',
          variables: [Variable.withString(homeId)],
          updates: {t},
          updateKind: UpdateKind.delete,
        );
      }
    });
  }

  Future<void> eraseRest(String homeId) async {
    await keyRing.clear(homeId);
    await prefs.setText('restoreInProgress_$homeId', null);

    if (prefs.currentHomeId == homeId) {
      await prefs.clearHome();
      try {
        await Workmanager().cancelByTag('nm.show');
        await plugin.cancelAll();
      } catch (_) {}
    }

    for (final hook in [...onErase]) {
      await hook(homeId);
    }
  }

  Future<void> erase(String homeId) async {
    await eraseRows(homeId);
    await eraseRest(homeId);
  }

  /// Records a [Tombstone] in [controlStore] (reading the home's name first), then erases [homeId].
  Future<void> eraseWithTombstone(
    String homeId, {
    required String reason,
    String? byName,
    String? opJson,
    DialInfo? dial,
    bool shown = false,
  }) async {
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    final homeName = home?.name ?? '';
    final cs = controlStore;
    if (cs != null) {
      await cs.addTombstone(
        Tombstone(
          homeId,
          homeName,
          reason,
          byName,
          opJson,
          clock?.nowMs ?? DateTime.now().millisecondsSinceEpoch,
          shown,
          dial ?? const DialInfo.empty(),
        ),
      );
    }
    await erase(homeId);
  }
}
