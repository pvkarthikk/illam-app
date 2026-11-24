import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/app.dart';
import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_auth.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/db/db_key.dart';
import 'package:nm_flat/core/data/db/encrypt_existing.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(PcloudRedirectCatcher());
  // Paint a light shell immediately; the heavy start-up below runs behind it.
  runApp(const _BootShell());
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  final secure = FlutterSecureStore();
  final keysFuture = DeviceKeys.ensure(secure)..ignore();
  final DevicePrefs prefs;
  NestDatabase db;
  try {
    final (loadedPrefs, keyHex) = await (
      DevicePrefs.open(),
      DbKey.loadOrCreate(secure),
    ).wait;
    prefs = loadedPrefs;
    if (!prefs.getFlag('dbEncrypted')) {
      await encryptExistingDatabase(keyHex);
      await prefs.setFlag('dbEncrypted', true);
    }
    db = NestDatabase.open(keyHex: keyHex);
    try {
      await db.customSelect('SELECT COUNT(*) FROM sqlite_master').get();
    } on Object catch (e) {
      if (!e.toString().contains('file is not a database')) rethrow;
      try {
        await db.close();
      } on Object {
        // Ignore close error on unreadable database file.
      }
      final docs = await getApplicationDocumentsDirectory();
      for (final name in const [
        'illam.sqlite',
        'illam.sqlite-wal',
        'illam.sqlite-shm',
      ]) {
        final f = File('${docs.path}${Platform.pathSeparator}$name');
        if (await f.exists()) await f.delete();
      }
      await prefs.clearAll();
      db = NestDatabase.open(keyHex: keyHex);
    }
  } catch (_) {
    runApp(const CantSecureApp());
    return;
  }
  HomeEraser.onErase.add((homeId) async {
    final cfg = await BackupConfigStore(secure).load(homeId);
    final secrets = DestinationSecrets(secure);
    for (final d in cfg.destinations) {
      await secrets.delete(d.destId);
    }
  });
  HomeEraser.onErase.add((homeId) async {
    await cancelBackup(homeId);
    await BackupConfigStore(secure).delete(homeId);
  });
  DeviceKeys? bootKeys;
  try {
    bootKeys = await Bootstrap.ensureIdentity(
      secure: secure,
      prefs: prefs,
      db: db,
      keys: keysFuture,
    );
  } catch (_) {
    runApp(const CantSecureApp());
    return;
  }
  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(secure),
        deviceKeysProvider.overrideWith((_) {
          final k = bootKeys;
          bootKeys = null;
          if (k != null) return k;
          return DeviceKeys.ensure(secure);
        }),
      ],
      child: const NestApp(),
    ),
  );
  unawaited(_initBackground());
}

/// Notifications and background work are not needed for the first frame, so
/// they start after the app is on screen.
Future<void> _initBackground() async {
  try {
    await initNotifications(onResponse: NotificationRouter.instance.handle);
    final launch = await plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true && payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final route = data['route'] as String?;
        final nav = NotificationRouter.instance;
        if (route != null) {
          if (nav.router != null) {
            nav.router!.go(route);
          } else {
            nav.pendingRoute = route;
          }
        }
      } catch (_) {}
    }
  } catch (_) {
    // Reminders are best-effort; the app works without.
  }
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Future.wait([
      Workmanager().registerPeriodicTask(
        'nm.plan',
        'nm.plan',
        frequency: const Duration(hours: 1),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      ),
      Workmanager().registerPeriodicTask(
        'nm.sync.periodic',
        'nm.sync',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      ),
    ]);
  } catch (_) {
    // Background sync and reminders are best-effort; the app works without.
  }
}

/// Minimal first frame shown while the database and keys open.
class _BootShell extends StatelessWidget {
  const _BootShell();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: Center(child: CircularProgressIndicator())),
  );
}
