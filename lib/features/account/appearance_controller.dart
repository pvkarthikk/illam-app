import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/app_locale.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

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

class LanguageController extends Notifier<String> {
  @override
  String build() => ref.read(prefsProvider).appLanguage;

  Future<void> set(String code) async {
    final normalized = normalizeStoredLanguage(code);
    state = normalized;
    await ref.read(prefsProvider).setAppLanguage(normalized);
  }
}

/// Resolves the effective [Locale] from persisted preference and system locales,
/// falling back to `'en'` when the system locale is not supported.
Locale resolveUserLocale(DevicePrefs prefs) {
  final code = resolveLanguageCode(prefs.appLanguage, [
    for (final l in PlatformDispatcher.instance.locales) l.languageCode,
  ]);
  return Locale(code);
}

/// Loads [AppLocalizations] for the active user or system-resolved language.
AppLocalizations lookupUserLocalizations(DevicePrefs prefs) =>
    lookupAppLocalizations(resolveUserLocale(prefs));

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final appVersionNameProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final myFingerprintProvider = FutureProvider<String>((ref) async {
  final keys = await ref.watch(deviceKeysProvider.future);
  return keys.fingerprint;
});
