import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  Future<void> _confirmAndWipe(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showNestSheet<bool>(
      context,
      (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(title: l10n.debugWipeTitle, lead: l10n.debugWipeSub),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.commonCancel,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              NestButton(
                label: l10n.debugWipeConfirm,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok != true) return;
    final db = ref.read(dbProvider);
    final prefs = ref.read(prefsProvider);
    final secure = ref.read(secureStoreProvider);
    await db.wipeAll();
    await prefs.clearAll();
    await secure.deleteAll();
    await Bootstrap.ensureIdentity(secure: secure, prefs: prefs, db: db);
    ref.read(hlcProvider).reset();
    ref.invalidate(dataLabControllerProvider);
    ref.invalidate(deviceKeysProvider);
    ref.invalidate(viewAsMemberProvider);
    if (!context.mounted) return;
    context.go(Routes.onboardingStep('welcome'));
    ref.read(snackbarProvider).show(l10n.debugWiped);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.debugTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NestCard(
            child: Column(
              children: [
                SettingsRow(
                  label: l10n.debugGallery,
                  value: l10n.debugGallerySub,
                  onTap: () => context.push(Routes.debugGallery),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugDataLab,
                  value: l10n.debugDataLabSub,
                  onTap: () => context.push(Routes.debugDataLab),
                ),
                Divider(height: 1, color: c.line),
                SwitchRow(
                  title: l10n.debugViewAsMember,
                  subtitle: l10n.debugViewAsMemberSub,
                  value: ref.watch(viewAsMemberProvider),
                  onChanged: (v) =>
                      ref.read(viewAsMemberProvider.notifier).set(v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    l10n.debugIsAdmin(ref.watch(isAdminProvider) ? 'yes' : 'no'),
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugLoadDemo,
                  value: l10n.debugLoadDemoSub,
                  onTap: () async {
                    await ref.read(demoSeederProvider).load();
                    ref.read(snackbarProvider).show(l10n.debugDemoLoaded);
                  },
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugRunJobs,
                  value: '',
                  onTap: () async {
                    await runRemindersNow(ref.read);
                    ref.read(snackbarProvider).show(l10n.debugRanJobs);
                  },
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugPlanReminders,
                  value: '',
                  onTap: () => planAndEnqueue(ref.read),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugWipe,
                  value: l10n.debugWipeSub,
                  danger: true,
                  onTap: () => _confirmAndWipe(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
