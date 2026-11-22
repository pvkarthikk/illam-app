import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';

class PhoneWiper {
  const PhoneWiper(this.db, this.prefs, this.secureStore);

  final NestDatabase db;
  final DevicePrefs prefs;
  final SecureStore secureStore;

  /// Erases this home's synced tables, home keys, and current-home prefs
  /// while keeping device identity keys and settings intact.
  Future<void> wipeHome() async {
    final homeId = prefs.currentHomeId;
    String? homeKeyId;
    if (homeId != null) {
      final row = await (db.select(
        db.homes,
      )..where((h) => h.id.equals(homeId))).getSingleOrNull();
      homeKeyId = row?.homeKeyId;
    }

    await db.transaction(() async {
      for (final t in db.allTables) {
        await db.delete(t).go();
      }
    });

    if (homeId != null) {
      await secureStore.delete(SecureKeys.homeKey(homeId, 'genesis'));
      if (homeKeyId != null && homeKeyId != 'genesis') {
        await secureStore.delete(SecureKeys.homeKey(homeId, homeKeyId));
      }
    }

    await prefs.clearHome();

    try {
      await Workmanager().cancelByTag('nm.show');
      await plugin.cancelAll();
    } catch (_) {}
  }
}

final phoneWiperProvider = Provider<PhoneWiper>(
  (ref) => PhoneWiper(
    ref.watch(dbProvider),
    ref.watch(prefsProvider),
    ref.watch(secureStoreProvider),
  ),
);
