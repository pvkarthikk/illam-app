import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nm_flat/core/providers.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => switch (ref.read(prefsProvider).themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> set(ThemeMode m) async {
    state = m;
    final stored = switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await ref.read(prefsProvider).setThemeMode(stored);
  }
}

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final myFingerprintProvider = FutureProvider<String>((ref) async {
  final keys = await ref.watch(deviceKeysProvider.future);
  return keys.fingerprint;
});
