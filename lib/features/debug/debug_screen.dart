import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/background_sync.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  Future<void> _confirmAndWipe(BuildContext context) async {
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

  Future<void> _writeDamagedBackup() async {
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId;
    if (homeId == null || homeId.isEmpty) return;

    final config = await ref.read(backupConfigStoreProvider).load(homeId);
    if (config.destinations.isEmpty) return;
    final dest = await destinationFor(
      config.destinations.first,
      ref.read(secureStoreProvider),
    );
    final files = await dest.list();
    final matched = <({String name, String stamp})>[];
    for (final f in files) {
      final m = backupNameRe.firstMatch(f.name);
      if (m != null) matched.add((name: f.name, stamp: m.group(2)!));
    }
    if (matched.isEmpty) return;
    matched.sort((a, b) => b.stamp.compareTo(a.stamp));

    final orig = await dest.download(matched.first.name);
    if (orig.length <= 200) return;
    final parsed = parseHeader(orig);
    final damaged = Uint8List.fromList(orig);
    damaged[200] = damaged[200] ^ 0xFF;

    final nowMs = ref.read(clockProvider).nowMs;
    final newName = backupFileName(
      vaultId: parsed.header.vaultId,
      snapshotId: parsed.header.snapshotId,
      createdAtMs: nowMs,
    );
    await dest.upload(newName, damaged);
    ref.read(snackbarProvider).show(newName);
  }

  Future<void> _add200Items(BuildContext context) async {
    final homeId = ref.read(currentHomeIdProvider).value;
    if (homeId == null || homeId.isEmpty) return;

    final repo = ref.read(listsRepoProvider);
    for (var i = 1; i <= 200; i++) {
      await repo.addItem(
        homeId: homeId,
        list: 'grocery',
        text: 'Test item #$i',
      );
    }
    if (!context.mounted) return;
    ref
        .read(snackbarProvider)
        .show(AppLocalizations.of(context).debugAdd200Items);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final prefs = ref.watch(prefsProvider);
    final folderOffPhone = prefs.getFlag('debugFolderOffPhone');
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
                SettingsRow(
                  label: l10n.syncLabTitle,
                  value: '',
                  onTap: () => context.push(Routes.debugSyncLab),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugBackupLab,
                  value: '',
                  onTap: () => context.push(Routes.debugBackupLab),
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
                  label: l10n.debugAdd200Items,
                  value: '',
                  onTap: () => _add200Items(context),
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugRunJobs,
                  value: '',
                  onTap: () async {
                    await runRemindersNow(ref.read);
                    await runBackgroundSync(ref.read);
                    final hId =
                        ref.read(currentHomeIdProvider).value ??
                        ref.read(prefsProvider).currentHomeId;
                    if (hId != null && hId.isNotEmpty) {
                      await runBackupTask(ref.read, {'homeId': hId});
                    }
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
                  label: l10n.debugDamageBackup,
                  value: '',
                  onTap: _writeDamagedBackup,
                ),
                Divider(height: 1, color: c.line),
                SwitchRow(
                  title: l10n.debugFolderOffPhone,
                  value: folderOffPhone,
                  onChanged: (v) async {
                    await prefs.setFlag('debugFolderOffPhone', v);
                    if (mounted) setState(() {});
                  },
                ),
                Divider(height: 1, color: c.line),
                SettingsRow(
                  label: l10n.debugWipe,
                  value: l10n.debugWipeSub,
                  danger: true,
                  onTap: () => _confirmAndWipe(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
