import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/sync_engine.dart';
import 'package:nm_flat/features/debug/sync_lab_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SyncLabScreen extends ConsumerStatefulWidget {
  const SyncLabScreen({super.key});

  @override
  ConsumerState<SyncLabScreen> createState() => _SyncLabScreenState();
}

class _SyncLabScreenState extends ConsumerState<SyncLabScreen> {
  final _portCtrl = TextEditingController();

  @override
  void dispose() {
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ctrl = ref.read(syncLabControllerProvider.notifier);
    final labState = ref.watch(syncLabControllerProvider).value;
    final counts = ref.watch(syncCountsProvider).value ?? const SyncCounts();
    final engineState =
        ref.watch(syncEngineStateProvider).value ?? const SyncEngineState();
    final vector = ref.watch(syncLabVectorProvider).value ?? const <String, int>{};
    final peers = ref.watch(syncPeersProvider).value ?? const <SyncPeerRow>[];
    final memberLog =
        ref.watch(syncMemberLogProvider).value ?? const <MemberLogEntry>[];
    final recentOps =
        ref.watch(syncRecentOpsProvider).value ?? const <RecentOpEntry>[];

    return Scaffold(
      appBar: NestTopBar.sub(title: l.syncLabTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.syncLabCounts(
                    counts.applied,
                    counts.pending,
                    counts.quarantined,
                  ),
                  style: NestText.body15.copyWith(color: c.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l.syncLabMemberLog}: '
                  '${l.syncLabMemberCounts(counts.memApplied, counts.memIgnored, counts.memPending, counts.activeDevices)}',
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NestButton(
                      label: l.syncLabVerify,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.verifyAll(l),
                    ),
                    NestButton(
                      label: l.syncLabExport,
                      kind: NestButtonKind.primary,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.exportBundle(l),
                    ),
                    NestButton(
                      label: l.syncLabShare,
                      kind: NestButtonKind.ghost,
                      size: NestButtonSize.sm,
                      icon: Icons.share_outlined,
                      onPressed: ctrl.shareBundle,
                    ),
                    NestButton(
                      label: l.syncLabImport,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.importFromClipboard(l),
                    ),
                  ],
                ),
                if (labState?.otherBundle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l.syncLabOtherHome,
                    style: NestText.body15.copyWith(color: c.danger),
                  ),
                  const SizedBox(height: 8),
                  NestButton(
                    label: l.syncLabReplace,
                    kind: NestButtonKind.danger,
                    size: NestButtonSize.sm,
                    onPressed: () => ctrl.replaceHomeWithPendingBundle(l),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NestButton(
                      label: l.syncLabTamper,
                      kind: NestButtonKind.dangerGhost,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.tamperTest(l),
                    ),
                    NestButton(
                      label: l.syncLabAsArjunTick,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.asArjunTick(l),
                    ),
                    NestButton(
                      label: l.syncLabAsArjunRename,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.asArjunRename(l),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.syncLabPort(engineState.port ?? 0),
                  style: NestText.cardTitle20.copyWith(color: c.ink),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _portCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          border: const OutlineInputBorder(),
                          labelText: l.syncLabPort(0).replaceAll('0', '').trim(),
                        ),
                      ),
                    ),
                    NestButton(
                      label: l.syncLabConnectLocal,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () {
                        final port = int.tryParse(_portCtrl.text.trim());
                        if (port != null && port > 0 && port <= 65535) {
                          ctrl.connectLocal(port);
                        }
                      },
                    ),
                    NestButton(
                      label: l.syncNow,
                      kind: NestButtonKind.primary,
                      size: NestButtonSize.sm,
                      onPressed: () => ctrl.syncNow(l),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l.syncLabVector,
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
                const SizedBox(height: 6),
                for (final e in vector.entries)
                  Text(
                    '${e.key}: ${e.value}',
                    style: NestText.meta13.copyWith(color: c.ink2),
                  ),
                const SizedBox(height: 16),
                Text(
                  l.syncLabPeers,
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
                const SizedBox(height: 6),
                for (final peer in peers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${peer.deviceId} (${peer.via}) · syncAt=${peer.lastSyncAt} · mops=${peer.ackedMemberOps} · vec=${peer.ackedVectorJson}',
                      style: NestText.meta13.copyWith(color: c.ink2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.syncLabMemberLog,
                  style: NestText.cardTitle20.copyWith(color: c.ink),
                ),
                const SizedBox(height: 8),
                for (final entry in memberLog) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text(
                          entry.op.opType,
                          style: NestText.itemTitle16.copyWith(color: c.ink),
                        ),
                        Text(
                          entry.model,
                          style: NestText.meta13.copyWith(color: c.ink2),
                        ),
                        Text(
                          entry.op.reason == null
                              ? entry.op.effect
                              : '${entry.op.effect}:${entry.op.reason}',
                          style: NestText.meta13.copyWith(
                            color: entry.op.effect == 'applied'
                                ? c.ok
                                : c.accentInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.syncLabRecentOps(recentOps.length),
                  style: NestText.cardTitle20.copyWith(color: c.ink),
                ),
                const SizedBox(height: 8),
                for (final item in recentOps) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text(
                          '${item.row.tbl}.${item.row.field}',
                          style: NestText.itemTitle16.copyWith(color: c.ink),
                        ),
                        Text(
                          item.row.valueJson ?? '${item.row.delta ?? ''}',
                          style: NestText.meta13.copyWith(color: c.ink2),
                        ),
                        Text(
                          item.signed ? l.syncLabSigned : l.syncLabUnsigned,
                          style: NestText.meta13.copyWith(
                            color: item.signed ? c.ok : c.danger,
                          ),
                        ),
                        if (item.row.status != 'applied')
                          Text(
                            item.row.status,
                            style: NestText.meta13.copyWith(color: c.danger),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
