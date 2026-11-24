import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

abstract final class Bootstrap {
  /// Creates the device keys silently on first start; if this phone still
  /// uses the old random deviceId (or the ids differ), wipe the database ONCE
  /// and switch to the key-derived deviceId.
  static Future<DeviceKeys> ensureIdentity({
    required SecureStore secure,
    required DevicePrefs prefs,
    required NestDatabase db,
    Future<DeviceKeys>? keys,
  }) async {
    final resolved = await (keys ?? DeviceKeys.ensure(secure));
    if (prefs.deviceIdKind != 'key' || prefs.deviceId != resolved.deviceId) {
      await db.wipeAll();
      await prefs.resetIdentity();
      await prefs.setDeviceId(resolved.deviceId, kind: 'key');
    }
    return resolved;
  }
}

class CantSecureApp extends StatelessWidget {
  const CantSecureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NestTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: Center(
              child: EmptyState(
                icon: Icons.lock_outline_rounded,
                title: l10n.errCantSecure,
                body: '',
              ),
            ),
          );
        },
      ),
    );
  }
}
