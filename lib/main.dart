import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/app.dart';
import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await DevicePrefs.open();
  final db = NestDatabase.open();
  final secure = FlutterSecureStore();
  try {
    await Bootstrap.ensureIdentity(secure: secure, prefs: prefs, db: db);
  } catch (_) {
    runApp(const CantSecureApp());
    return;
  }
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initTimeZone();
  await initNotifications(onResponse: NotificationRouter.instance.handle);
  final launch = await plugin.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp == true &&
      launch?.notificationResponse?.payload != null) {
    try {
      final data =
          jsonDecode(launch!.notificationResponse!.payload!)
              as Map<String, dynamic>;
      NotificationRouter.instance.pendingRoute = data['route'] as String?;
    } catch (_) {}
  }
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'nm.plan',
    'nm.plan',
    frequency: const Duration(hours: 1),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  await Workmanager().registerPeriodicTask(
    'nm.sync.periodic',
    'nm.sync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(secure),
      ],
      child: const NestApp(),
    ),
  );
}
