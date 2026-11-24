import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saf_util/saf_util.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/folder_destination.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/features/backup/cloud/cloud_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/nextcloud_sheet.dart';
import 'package:nm_flat/features/backup/servers/s3_sheet.dart';
import 'package:nm_flat/features/backup/servers/sftp_sheet.dart';
import 'package:nm_flat/features/backup/servers/webdav_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const int _dayMs = 24 * 60 * 60 * 1000;

String _failureReason(AppLocalizations l, DestinationConfig d) {
  final res = d.lastResult;
  if (res == 'unreachable') return l.backupErrUnreachable;
  if (res == 'full') return l.backupReasonFull(providerShort(l, d.kind));
  if (res == 'auth' && d.kind != 'folder') {
    return l.backupReasonAuth(providerShort(l, d.kind));
  }
  if (d.kind != 'folder') return l.bkSrvErrOther;
  return l.backupErrNoPermission;
}

bool _isCloud(String kind) =>
    kind == 'gdrive' ||
    kind == 'onedrive' ||
    kind == 'dropbox' ||
    kind == 'pcloud';

String? _cloudWhere(AppLocalizations l, String kind) => switch (kind) {
  'gdrive' => l.bkCloudGdriveWhere,
  'dropbox' || 'onedrive' => l.bkCloudAppsFolder,
  'pcloud' => l.bkCloudPcloudWhere,
  _ => null,
};

String? _cloudAccess(AppLocalizations l, String kind) => switch (kind) {
  'gdrive' => l.bkCloudGdriveAccess,
  'dropbox' => l.bkCloudDropboxAccess,
  'onedrive' => l.bkCloudOnedriveAccess,
  'pcloud' => l.bkCloudPcloudAccess,
  _ => null,
};

IconData _provIcon(String kind) => switch (kind) {
  'gdrive' || 'onedrive' || 'dropbox' || 'pcloud' => Icons.cloud_outlined,
  'nextcloud' || 'webdav' => Icons.dns_outlined,
  's3' => Icons.storage_outlined,
  'sftp' => Icons.terminal_outlined,
  _ => Icons.folder_outlined,
};

void _openReauthSheet(
  BuildContext context,
  WidgetRef ref,
  DestinationConfig dest,
) {
  switch (dest.kind) {
    case 'nextcloud':
      showNextcloudSheet(context, ref, ConnectMode.reauth, existing: dest);
    case 'webdav':
      showWebDavSheet(context, ref, ConnectMode.reauth, existing: dest);
    case 's3':
      showS3Sheet(context, ref, ConnectMode.reauth, existing: dest);
    case 'sftp':
      showSftpSheet(context, ref, ConnectMode.reauth, existing: dest);
  }
}

class BackupStatusCard extends ConsumerWidget {
  const BackupStatusCard({super.key, required this.config});

  final BackupConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(backupControllerProvider);
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;

    final sorted = [...config.destinations]
      ..sort((a, b) => (b.lastSuccessAt ?? 0).compareTo(a.lastSuccessAt ?? 0));
    final newestDest = sorted.firstOrNull;
    final newestSuccess = newestDest?.lastSuccessAt;
    final intervalMs = backupIntervalMs(config.frequency);
    final isStale =
        newestSuccess != null && nowMs - newestSuccess > 2 * intervalMs;

    final String title;
    final Color titleColor;
    if (ui.running) {
      title = l.backupStatusRunning(ui.pct);
      titleColor = c.ink;
    } else if (newestDest != null &&
        newestDest.lastResult != null &&
        newestDest.lastResult != 'ok') {
      title = l.backupStatusFailed(_failureReason(l, newestDest));
      titleColor = c.danger;
    } else if (isStale) {
      final days = max(0, (nowMs - newestSuccess) ~/ _dayMs);
      title = l.backupStatusStale(days);
      titleColor = c.accentInk;
    } else if (config.lastSkip == 'unchanged') {
      title = l.backupStatusUnchanged;
      titleColor = c.ink;
    } else {
      final ago = newestSuccess == null
          ? '—'
          : backupAgo(l, nowMs, newestSuccess);
      title = l.backupStatusOk(ago);
      titleColor = c.ink;
    }

    final baseMs = newestSuccess ?? config.passwordSetAt ?? nowMs;
    var nextMs = baseMs + intervalMs;
    while (nextMs <= nowMs) {
      nextMs += intervalMs;
    }
    final nextDt = DateTime.fromMillisecondsSinceEpoch(nextMs);
    final whenStr = DateFormat(
      (nextMs - nowMs <= 7 * _dayMs) ? 'EEE' : 'd MMM',
      'en',
    ).format(nextDt);
    final conditions = [
      if (config.wifiOnly) l.backupOnWifi,
      if (config.chargingOnly) l.backupWhileCharging,
    ].join(', ');

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: NestText.title22.copyWith(color: titleColor)),
          if (ui.running) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: ui.pct / 100),
          ],
          const SizedBox(height: 6),
          Text(
            l.backupNext(whenStr, conditions),
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 14),
          NestButton(
            label: l.backupNow,
            kind: NestButtonKind.tonal,
            size: NestButtonSize.block,
            onPressed: ui.running
                ? null
                : () => ref.read(backupControllerProvider.notifier).runNow(),
          ),
        ],
      ),
    );
  }
}

class BackupPlacesSection extends ConsumerWidget {
  const BackupPlacesSection({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.config,
  });

  final String homeId;
  final String homeName;
  final BackupConfig config;

  Future<void> _showDestSheet(
    BuildContext context,
    WidgetRef ref,
    DestinationConfig dest,
  ) async {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final isCloud = _isCloud(dest.kind);
    final where = _cloudWhere(l, dest.kind);
    final access = _cloudAccess(l, dest.kind);
    final showReauth =
        isCloud ||
        dest.kind == 'nextcloud' ||
        ((dest.kind == 'webdav' || dest.kind == 's3' || dest.kind == 'sftp') &&
            dest.lastResult == 'auth');
    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: providerTitle(l, dest.kind),
            lead: where != null ? '${dest.label} · $where' : dest.label,
          ),
          if (access != null) ...[
            Text(access, style: NestText.meta13.copyWith(color: c.ink3)),
            const SizedBox(height: 16),
          ],
          NestButton(
            label: l.backupNow,
            kind: NestButtonKind.tonal,
            size: NestButtonSize.block,
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(backupControllerProvider.notifier).runNow();
            },
          ),
          if (showReauth) ...[
            const SizedBox(height: 8),
            NestButton(
              label: l.bkSrvSignInAgain,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () {
                Navigator.of(ctx).pop();
                if (isCloud) {
                  ref
                      .read(cloudConnectControllerProvider.notifier)
                      .connect(
                        dest.kind,
                        ConnectMode.reauth,
                        reauthDestId: dest.destId,
                        l10n: l,
                      );
                } else if (context.mounted) {
                  _openReauthSheet(context, ref, dest);
                }
              },
            ),
            if (isCloud) ...[
              const SizedBox(height: 4),
              Text(
                l.bkCloudSignInAgainSub,
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ],
          ],
          const SizedBox(height: 16),
          Text(
            l.backupStayThere,
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 8),
          NestButton(
            label: l.backupDisconnect,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () async {
              final secure = ref.read(secureStoreProvider);
              try {
                final remote = await destinationFor(dest, secure);
                await remote.revokeAccess();
              } on Object {
                // Ignore revocation or destination construction errors.
              }
              final uri = dest.settings['treeUri'] as String?;
              if (dest.kind == 'folder' && uri != null && uri.isNotEmpty) {
                try {
                  await SafUtil().releasePersistedPermission(
                    uri,
                    read: true,
                    write: true,
                  );
                } on Object {
                  // Ignore release failure.
                }
              }
              final store = ref.read(backupConfigStoreProvider);
              final latest = await store.load(homeId);
              latest.destinations.removeWhere((d) => d.destId == dest.destId);
              await store.save(homeId, latest);
              if (latest.destinations.isEmpty) {
                await cancelBackup(homeId);
              }
              await DestinationSecrets(secure).delete(dest.destId);
              ref.invalidate(backupConfigProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) {
    ref.read(backupControllerProvider.notifier).setConnectState(clearError: true);
    return showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(title: AppLocalizations.of(ctx).backupWhere),
          ProviderList(
            mode: ConnectMode.add,
            onPicked: () {
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;
    final health = ref.watch(backupHealthProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            children: [
              Expanded(child: SectionHeader(title: l.backupWhereGo)),
              Text(
                l.backupPlacesCount(config.destinations.length),
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        NestCard(
          child: Column(
            children: [
              for (var i = 0; i < config.destinations.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.line),
                _DestRow(
                  dest: config.destinations[i],
                  nowMs: nowMs,
                  onTap: () =>
                      _showDestSheet(context, ref, config.destinations[i]),
                ),
              ],
              if (config.destinations.length < BackupConfig.maxDestinations) ...[
                if (config.destinations.isNotEmpty)
                  Divider(height: 1, color: c.line),
                InkWell(
                  onTap: () => _showAddSheet(context, ref),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l.backupAddPlace,
                          style: NestText.button15.copyWith(color: c.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (health != null && health.others.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final o in health.others)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l.backupAlsoIn(
                  homeName,
                  o.name,
                  providerShort(l, o.providerKind),
                  backupAgo(l, nowMs, o.lastSuccessAt),
                ),
                style: NestText.meta13.copyWith(color: c.ink2),
              ),
            ),
        ],
      ],
    );
  }
}

class _DestRow extends StatelessWidget {
  const _DestRow({
    required this.dest,
    required this.nowMs,
    required this.onTap,
  });

  final DestinationConfig dest;
  final int nowMs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final hasErr = dest.lastResult != null && dest.lastResult != 'ok';
    final ago = dest.lastSuccessAt == null
        ? '—'
        : backupAgo(l, nowMs, dest.lastSuccessAt!);
    final sub = hasErr
        ? (_isCloud(dest.kind) && dest.lastResult == 'auth'
              ? l.bkCloudExpiredRow
              : _failureReason(l, dest))
        : l.backupDestLast(ago, dest.keptCount);
    final isLocal =
        dest.kind == 'folder' &&
        FolderDestination.isPhoneStorage(
          (dest.settings['treeUri'] as String?) ?? '',
        );

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(_provIcon(dest.kind), color: c.ink2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          providerTitle(l, dest.kind),
                          style: NestText.itemTitle16.copyWith(color: c.ink),
                        ),
                        if (isLocal) NestTag(label: l.backupLocalTag),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dest.label,
                      style: NestText.body15.copyWith(color: c.ink2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: NestText.meta13.copyWith(
                        color: hasErr ? c.danger : c.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}

class BackupScheduleSection extends ConsumerWidget {
  const BackupScheduleSection({
    super.key,
    required this.homeId,
    required this.config,
  });

  final String homeId;
  final BackupConfig config;

  Future<void> _update(
    WidgetRef ref,
    void Function(BackupConfig c) mutate,
  ) async {
    final store = ref.read(backupConfigStoreProvider);
    final latest = await store.load(homeId);
    mutate(latest);
    await store.save(homeId, latest);
    await scheduleBackup(homeId, latest);
    ref.invalidate(backupConfigProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l.backupSchedule),
        const SizedBox(height: 8),
        NestCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.backupHowOften,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final (k, lbl) in [
                          ('daily', l.backupDaily),
                          ('weekly', l.backupWeekly),
                          ('monthly', l.backupMonthly),
                        ])
                          NestChip(
                            label: lbl,
                            selected: config.frequency == k,
                            onTap: () => _update(ref, (cfg) => cfg.frequency = k),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: c.line),
              SwitchRow(
                title: l.backupWifiOnly,
                subtitle: l.backupWifiOnlySub,
                value: config.wifiOnly,
                onChanged: (v) => _update(ref, (cfg) => cfg.wifiOnly = v),
              ),
              Divider(height: 1, color: c.line),
              SwitchRow(
                title: l.backupCharging,
                subtitle: l.backupChargingSub,
                value: config.chargingOnly,
                onChanged: (v) => _update(ref, (cfg) => cfg.chargingOnly = v),
              ),
              Divider(height: 1, color: c.line),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.backupKeep,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final n in const [5, 10, 30])
                          NestChip(
                            label: l.backupKeepN(n),
                            selected: config.keep == n,
                            onTap: () => _update(ref, (cfg) => cfg.keep = n),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.backupKeepSub,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
