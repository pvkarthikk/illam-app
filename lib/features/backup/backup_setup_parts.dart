import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/folder_destination.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_password_sheet.dart';
import 'package:nm_flat/features/backup/cloud/cloud_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/nextcloud_sheet.dart';
import 'package:nm_flat/features/backup/servers/s3_sheet.dart';
import 'package:nm_flat/features/backup/servers/sftp_sheet.dart';
import 'package:nm_flat/features/backup/servers/webdav_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

enum ConnectMode { add, restore, reauth }

Future<void> connectFolder(
  BuildContext context,
  WidgetRef ref,
  ConnectMode mode, {
  String? reauthDestId,
  VoidCallback? onPicked,
}) async {
  final dest = await FolderDestination.pick();
  if (dest == null) return;

  final ctrl = ref.read(backupControllerProvider.notifier);
  final localCopy = FolderDestination.isPhoneStorage(dest.treeUri);
  ctrl.setConnectState(
    busy: mode != ConnectMode.restore,
    clearError: true,
    localCopy: mode != ConnectMode.restore && localCopy,
  );

  if (mode != ConnectMode.restore) {
    try {
      await dest.testWrite();
    } on DestinationException catch (e) {
      ctrl.setConnectState(
        busy: false,
        error: e.error == DestError.unreachable
            ? 'backupErrUnreachable'
            : 'backupErrNoPermission',
      );
      return;
    } on Object {
      ctrl.setConnectState(busy: false, error: 'backupErrNoPermission');
      return;
    } finally {
      ctrl.setConnectState(busy: false);
    }
  }

  final next = await ctrl.onConnected(
    DestinationConfig(
      destId: (mode == ConnectMode.reauth && reauthDestId != null)
          ? reauthDestId
          : Ids.newId(),
      kind: 'folder',
      label: FolderDestination.labelOf(dest.treeUri),
      settings: {'treeUri': dest.treeUri},
    ),
    mode,
  );

  if (!context.mounted) return;
  onPicked?.call();
  if (next == ConnectNext.askPassword) {
    await showBackupPasswordSheet(context, ref);
  } else if (next == ConnectNext.restore) {
    context.go(Routes.onboardingStep('restore-pick'));
  }
}

class ProviderList extends ConsumerWidget {
  const ProviderList({
    super.key,
    required this.mode,
    this.reauthDestId,
    this.onPicked,
  });

  final ConnectMode mode;
  final String? reauthDestId;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(backupControllerProvider);
    final cloudUi = ref.watch(cloudConnectControllerProvider);
    final cfg = ref.watch(backupConfigProvider).value;

    DestinationConfig? existing;
    if (mode == ConnectMode.reauth && reauthDestId != null && cfg != null) {
      for (final d in cfg.destinations) {
        if (d.destId == reauthDestId) {
          existing = d;
          break;
        }
      }
    }

    Future<void> connectCloud(String kind) async {
      final nav = Navigator.of(context);
      final router = GoRouter.of(context);
      await ref
          .read(cloudConnectControllerProvider.notifier)
          .connect(kind, mode, reauthDestId: reauthDestId, l10n: l);
      final next = ref.read(cloudConnectControllerProvider).lastNext;
      if (next == null) return;
      onPicked?.call();
      if (next == ConnectNext.askPassword && nav.mounted) {
        await showBackupPasswordSheet(nav.context, ref);
      } else if (next == ConnectNext.restore) {
        router.go(Routes.onboardingStep('restore-pick'));
      }
    }

    final taps = <String, VoidCallback?>{
      'gdrive': () => connectCloud('gdrive'),
      'onedrive': () => connectCloud('onedrive'),
      'dropbox': () => connectCloud('dropbox'),
      'pcloud': () => connectCloud('pcloud'),
      'nextcloud': () => showNextcloudSheet(
        context,
        ref,
        mode,
        existing: existing,
        onPicked: onPicked,
      ),
      'webdav': () => showWebDavSheet(
        context,
        ref,
        mode,
        existing: existing,
        onPicked: onPicked,
      ),
      's3': () => showS3Sheet(
        context,
        ref,
        mode,
        existing: existing,
        onPicked: onPicked,
      ),
      'sftp': () => showSftpSheet(
        context,
        ref,
        mode,
        existing: existing,
        onPicked: onPicked,
      ),
      'folder': () => connectFolder(
        context,
        ref,
        mode,
        reauthDestId: reauthDestId,
        onPicked: onPicked,
      ),
    };

    String? cloudErrorText(String? key, String provider) => switch (key) {
      'bkCloudNotConfigured' => l.bkCloudNotConfigured(provider),
      'bkCloudSignInFailed' => l.bkCloudSignInFailed(provider),
      'bkCloudOrgApproval' => l.bkCloudOrgApproval,
      _ => null,
    };

    String? cloudWhere(String kind) => switch (kind) {
      'gdrive' => l.bkCloudGdriveWhere,
      'dropbox' || 'onedrive' => l.bkCloudAppsFolder,
      'pcloud' => l.bkCloudPcloudWhere,
      _ => null,
    };

    (IconData, String, String, String?) metaOf(String kind) => switch (kind) {
      'gdrive' => (
        Icons.cloud_outlined,
        l.backupProvGdrive,
        l.backupProvGdriveSub,
        l.backupArrivesP20,
      ),
      'onedrive' => (
        Icons.cloud_outlined,
        l.backupProvOnedrive,
        l.backupProvOnedriveSub,
        l.backupArrivesP20,
      ),
      'dropbox' => (
        Icons.cloud_outlined,
        l.backupProvDropbox,
        l.backupProvDropboxSub,
        l.backupArrivesP20,
      ),
      'pcloud' => (
        Icons.cloud_outlined,
        l.backupProvPcloud,
        l.backupProvPcloudSub,
        l.backupArrivesP20,
      ),
      'nextcloud' => (
        Icons.dns_outlined,
        l.backupProvNextcloud,
        l.backupProvNextcloudSub,
        l.backupArrivesP19,
      ),
      'webdav' => (
        Icons.dns_outlined,
        l.backupProvWebdav,
        l.backupProvWebdavSub,
        l.backupArrivesP19,
      ),
      's3' => (
        Icons.storage_outlined,
        l.backupProvS3,
        l.backupProvS3Sub,
        l.backupArrivesP19,
      ),
      'sftp' => (
        Icons.terminal_outlined,
        l.backupProvSftp,
        l.backupProvSftpSub,
        l.backupArrivesP19,
      ),
      _ => (
        Icons.folder_outlined,
        l.backupProvFolder,
        l.backupProvFolderSub,
        null,
      ),
    };

    String? errorText(String? key) => switch (key) {
      'backupErrUnreachable' => l.backupErrUnreachable,
      'backupErrNoPermission' => l.backupErrNoPermission,
      _ => null,
    };

    Widget buildRow(String kind) {
      final (icon, title, sub, arrivesTag) = metaOf(kind);
      final onTap = taps[kind];
      final enabled = onTap != null;
      final isFolder = kind == 'folder';
      final where = cloudWhere(kind);

      final row = InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Opacity(
              opacity: enabled ? 1.0 : 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: enabled ? c.ink2 : c.ink3),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: NestText.itemTitle16.copyWith(color: c.ink),
                            ),
                            if (isFolder &&
                                mode != ConnectMode.restore &&
                                ui.connectBusy) ...[
                              const SizedBox(height: 2),
                              Text(
                                l.backupChecking,
                                style: NestText.meta13.copyWith(
                                  color: c.primary,
                                ),
                              ),
                            ],
                            if (isFolder &&
                                mode != ConnectMode.restore &&
                                ui.localCopy) ...[
                              const SizedBox(height: 2),
                              Text(
                                l.backupLocalCopy,
                                style: NestText.meta13.copyWith(
                                  color: c.accentInk,
                                ),
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              sub,
                              style: NestText.meta13.copyWith(color: c.ink3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (cloudUi.busy == kind)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (!enabled && arrivesTag != null)
                        NestTag(label: arrivesTag)
                      else
                        Icon(Icons.chevron_right_rounded, color: c.ink3),
                    ],
                  ),
                  if (isFolder && errorText(ui.connectError) != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          errorText(ui.connectError)!,
                          style: NestText.meta13.copyWith(color: c.danger),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      if (where != null) {
        return Semantics(button: true, label: '$title, $where', child: row);
      }
      return row;
    }

    Widget group(String header, List<String> kinds) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        SectionHeader(title: header),
        const SizedBox(height: 6),
        NestCard(
          child: Column(
            children: [
              for (var i = 0; i < kinds.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.line),
                buildRow(kinds[i]),
              ],
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group(l.backupGroupSignIn, const [
          'gdrive',
          'onedrive',
          'dropbox',
          'pcloud',
        ]),
        group(l.backupGroupServer, const [
          'nextcloud',
          'webdav',
          's3',
          'sftp',
        ]),
        group(l.backupGroupDevice, const ['folder']),
        if (cloudErrorText(cloudUi.errorKey, cloudUi.errorProvider ?? '') !=
            null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                cloudErrorText(cloudUi.errorKey, cloudUi.errorProvider ?? '')!,
                style: NestText.meta13.copyWith(color: c.danger),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
