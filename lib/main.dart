import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/app.dart';
import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
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
