import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/protocol/messages.dart';
import 'package:nm_flat/core/sync/sync_engine.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/sync_tag.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Card on Home & members showing per-phone sync status, tips, and manual sync.
class HomeSyncCard extends ConsumerWidget {
  const HomeSyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(minuteTickProvider);
    final summary = ref.watch(syncSummaryProvider).value;
    if (summary == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final engineState =
        ref.watch(syncEngineStateProvider).value ?? const SyncEngineState();
    final peers = ref.watch(syncPeersProvider).value ?? const [];
    final nowMs = ref.read(clockProvider).nowMs;

    final title = summary.onlyThisPhone
        ? l10n.homeSyncPlaceholderTitle
        : (summary.allInSync
              ? l10n.syncCardAllInSync
              : l10n.syncCardBehind(summary.notUpToDate));
    final subtitle = summary.onlyThisPhone
        ? l10n.homeSyncPlaceholderSub
        : (summary.lastSyncAt == 0
              ? l10n.syncNotYet
              : l10n.syncCardLastSynced(agoText(l10n, nowMs, summary.lastSyncAt)));

    final updateNames = <String>[
      for (final p in peers)
        if (p.peerVersion > kSyncProtocolVersion)
          summary.rows
                  .where((r) => r.device.deviceId == p.deviceId)
                  .firstOrNull
                  ?.device
                  .name ??
              '',
    ];

    final sections = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.sync_rounded, color: c.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: NestText.itemTitle16.copyWith(color: c.ink)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
            if (!summary.onlyThisPhone) ...[
              const SizedBox(width: 8),
              NestButton(
                label: engineState.syncing ? l10n.syncing : l10n.syncNow,
                kind: NestButtonKind.tonal,
                size: NestButtonSize.sm,
                onPressed: engineState.syncing
                    ? null
                    : () async {
                        final n = await ref.read(syncEngineProvider).syncNow();
                        if (!context.mounted) return;
                        ref
                            .read(snackbarProvider)
                            .show(n > 0 ? l10n.syncedSnack : l10n.syncNoPeers);
                      },
              ),
            ],
          ],
        ),
      ),
      for (final row in summary.rows) _PeerStatusRow(row: row, nowMs: nowMs),
      if (summary.clockWarning || engineState.wifiTip || updateNames.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (summary.clockWarning)
                AlertLine(
                  icon: Icons.schedule_rounded,
                  text: l10n.syncClockWrong,
                ),
              if (engineState.wifiTip) ...[
                if (summary.clockWarning) const SizedBox(height: 8),
                AlertLine(
                  icon: Icons.wifi_find_rounded,
                  text: l10n.syncWifiBlocked,
                ),
              ],
              for (var i = 0; i < updateNames.length; i++) ...[
                if (summary.clockWarning || engineState.wifiTip || i > 0)
                  const SizedBox(height: 8),
                AlertLine(
                  icon: Icons.system_update_rounded,
                  text: l10n.syncUpdateNeeded(updateNames[i]),
                ),
              ],
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Text(
          l10n.homeSyncFootnote,
          style: NestText.small12.copyWith(color: c.ink3),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NestCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) Divider(height: 1, color: c.line),
              sections[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _PeerStatusRow extends StatelessWidget {
  const _PeerStatusRow({required this.row, required this.nowMs});

  final PeerRow row;
  final int nowMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    final Color dotColor = switch (row.state) {
      PeerState.thisPhone => c.primary,
      PeerState.connected ||
      PeerState.synced when row.behindBy == 0 => c.ok,
      PeerState.connected ||
      PeerState.synced ||
      PeerState.stale ||
      PeerState.never => c.accent,
    };

    final label = row.state == PeerState.thisPhone
        ? l10n.homeYourPhone(row.device.model)
        : l10n.syncRowTheirs(row.device.name, row.device.model);

    final missing = row.behindBy > 0 ? l10n.syncMissing(row.behindBy) : '';
    final status = switch (row.state) {
      PeerState.thisPhone => l10n.homeThisPhone,
      PeerState.connected => '${l10n.syncOnWifiNow}$missing',
      PeerState.synced =>
        '${l10n.syncSyncedAgo(agoText(l10n, nowMs, row.lastSyncAt))}$missing',
      PeerState.stale =>
        '${l10n.syncNotForDays(agoParts(nowMs, row.lastSyncAt).$2)}$missing',
      PeerState.never => '${l10n.syncNotYet}$missing',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(label, style: NestText.body15.copyWith(color: c.ink)),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              status,
              textAlign: TextAlign.end,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
          ),
        ],
      ),
    );
  }
}
