import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/data/prefs/notification_prefs.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notification_permission.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const kPrivacyUrl = 'https://nestmojo.app/privacy';
const kHelpUrl = 'https://nestmojo.app/help';

class ProfileNotificationsSection extends ConsumerStatefulWidget {
  const ProfileNotificationsSection({super.key});

  @override
  ConsumerState<ProfileNotificationsSection> createState() =>
      _ProfileNotificationsSectionState();
}

class _ProfileNotificationsSectionState
    extends ConsumerState<ProfileNotificationsSection> {
  late final AppLifecycleListener _lifecycle;
  bool _osEnabled = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_refreshOsStatus()),
    );
    unawaited(_refreshOsStatus());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refreshOsStatus() async {
    final android = androidNotificationsPlugin();
    if (android == null) return;
    bool enabled = true;
    try {
      enabled = (await android.areNotificationsEnabled()) ?? true;
    } on MissingPluginException {
      enabled = true;
    }
    if (mounted && _osEnabled != enabled) {
      setState(() => _osEnabled = enabled);
    }
  }

  Future<void> _openOsSettings() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {'android.provider.extra.APP_PACKAGE': info.packageName},
      );
      await intent.launch();
    } catch (_) {}
  }

  Future<void> _toggle(String kind, bool value) async {
    if (value) {
      await ensureNotificationPermission(context, ref);
      if (!mounted) return;
    }
    await ref.read(notificationPrefsProvider.notifier).set(kind, value);
    if (value) {
      try {
        await planAndEnqueue(ref.read);
      } catch (_) {}
    }
    await _refreshOsStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final prefs = ref.watch(notificationPrefsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(title: l10n.profileNotifications),
        const SizedBox(height: 8),
        if (!_osEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InfoBanner(
              icon: Icons.notifications_off_outlined,
              title: l10n.notifOffBanner,
              subtitle: l10n.notifTurnOn,
              onTap: _openOsSettings,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NestCard(
            child: Column(
              children: [
                SwitchRow(
                  title: l10n.notifArrival,
                  subtitle: l10n.notifArrivalSub,
                  value: prefs.arrival,
                  onChanged: (v) => _toggle('notifArrival', v),
                ),
                Divider(height: 1, color: c.line),
                SwitchRow(
                  title: l10n.notifDigest,
                  subtitle: l10n.notifDigestSub,
                  value: prefs.digest,
                  onChanged: (v) => _toggle('notifDigest', v),
                ),
                Divider(height: 1, color: c.line),
                SwitchRow(
                  title: l10n.notifBillDue,
                  subtitle: l10n.notifBillDueSub,
                  value: prefs.billDue,
                  onChanged: (v) => _toggle('notifBillDue', v),
                ),
                Divider(height: 1, color: c.line),
                SwitchRow(
                  title: l10n.notifEvening,
                  subtitle: l10n.notifEveningSub,
                  value: prefs.evening,
                  onChanged: (v) => _toggle('notifEvening', v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileOnThisPhoneSection extends ConsumerWidget {
  const ProfileOnThisPhoneSection({super.key});

  Future<void> _pickAppearance(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);
    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(title: l10n.profileAppearance),
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (m) {
              if (m == null) return;
              ref.read(themeModeProvider.notifier).set(m);
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.themeSystem),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final mode = ref.watch(themeModeProvider);
    final modeLabel = switch (mode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(title: l10n.profileOnThisPhone),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NestCard(
            child: Column(
              children: [
                SettingsRow(
                  label: l10n.profileBackup,
                  value: l10n.profileBackupNotSetUp,
                  onTap: () => ref
                      .read(snackbarProvider)
                      .show(l10n.profileBackupArrives),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.profileLanguage,
                  value: l10n.profileEnglish,
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.profileAppearance,
                  value: modeLabel,
                  onTap: () => _pickAppearance(context, ref),
                ),
                if (kDebugMode) ...[
                  Divider(height: 1, color: c.line),
                  SettingsRow(
                    label: l10n.profileDevTools,
                    value: '',
                    onTap: () => context.push(Routes.debug),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileFooter extends ConsumerWidget {
  const ProfileFooter({super.key});

  Future<void> _openUrl(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final version = ref.watch(appVersionProvider).value ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.profileFinePrint,
              textAlign: TextAlign.center,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
          ),
          const SizedBox(height: 16),
          NestCard(
            child: Column(
              children: [
                SettingsRow(
                  label: l10n.profilePrivacy,
                  value: '',
                  onTap: () => _openUrl(kPrivacyUrl),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.profileHelp,
                  value: '',
                  onTap: () => _openUrl(kHelpUrl),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(label: l10n.profileVersion, value: version),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
