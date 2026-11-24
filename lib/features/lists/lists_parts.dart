import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/channels.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/features/store/order_handoff_controller.dart';
import 'package:nm_flat/features/store/store_launcher.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ChannelGroupCard extends ConsumerWidget {
  const ChannelGroupCard({
    super.key,
    required this.list,
    required this.channel,
    required this.rows,
    required this.groups,
    required this.onOpenItem,
  });

  final String list;
  final String channel;
  final List<ItemRow> rows;
  final List<ItemGroup> groups;
  final ValueChanged<ItemGroup> onOpenItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final online = storeChannels[channel]?.online ?? false;
    final byId = {for (final r in rows) r.id: r};
    final doneRows = [
      for (final r in rows)
        if (r.done) r,
    ];
    final seenDone = <String>{};
    final doneNames = <String>[];
    for (final r in doneRows) {
      if (seenDone.add(r.nameKey)) {
        doneNames.add(r.name);
      }
    }

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ChannelBadge(channel: channel, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelName(l10n, channel),
                      style: TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontVariations: const [FontVariation.weight(800)],
                        color: c.ink,
                      ),
                    ),
                    Text(
                      l10n.listsToBuy(groups.length, channelEta(l10n, channel)),
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (online)
                NestButton(
                  label: l10n.listsOrder,
                  icon: Icons.north_east_rounded,
                  kind: NestButtonKind.tonal,
                  size: NestButtonSize.sm,
                  onPressed: groups.isEmpty
                      ? null
                      : () async {
                          final orderGroups = <OrderGroupView>[
                            for (final g in groups)
                              if (byId[g.survivor.id] case final survivor?)
                                OrderGroupView(
                                  name: survivor.name,
                                  totalMilli: g.totalMilli,
                                  unit: survivor.unit,
                                  items: [
                                    for (final id in g.ids) ?byId[id],
                                  ],
                                ),
                          ];
                          final opened = await ref
                              .read(orderHandoffControllerProvider.notifier)
                              .start(list, channel, orderGroups);
                          if (opened == StoreOpened.none && context.mounted) {
                            ref
                                .read(snackbarProvider)
                                .show(
                                  l10n.storeOpenFailed(
                                    channelName(l10n, channel),
                                  ),
                                );
                          }
                        },
                )
              else
                NestButton(
                  label: l10n.listsShop,
                  icon: Icons.shopping_cart_outlined,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.sm,
                  onPressed: groups.isEmpty
                      ? null
                      : () => context.push(Routes.listsStore),
                ),
            ],
          ),
          if (groups.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final g in groups)
              if (byId[g.survivor.id] case final survivor?)
                _GroupItemRow(
                  group: g,
                  survivor: survivor,
                  onOpenItem: onOpenItem,
                ),
          ] else if (doneRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.listsAllBought(channelName(l10n, channel)),
              style: NestText.body15.copyWith(color: c.ink2),
            ),
          ],
          if (doneRows.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 18, color: c.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.listsGotFooter(doneNames.join(', ')),
                      style: NestText.meta13.copyWith(color: c.ink2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final (res, count) = await ref
                          .read(listsRepoProvider)
                          .clearChannel(list, channel);
                      ref
                          .read(snackbarProvider)
                          .show(l10n.listsCleared(count), undo: res.undo);
                    },
                    child: Text(l10n.listsClear),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupItemRow extends ConsumerWidget {
  const _GroupItemRow({
    required this.group,
    required this.survivor,
    required this.onOpenItem,
  });

  final ItemGroup group;
  final ItemRow survivor;
  final ValueChanged<ItemGroup> onOpenItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final step = stepMilli(survivor.unit);
    final shownMilli = group.checkQty ? step : group.totalMilli;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            NestCheckbox(
              value: false,
              semanticLabel: l10n.listsGotSemantics(survivor.name),
              onChanged: (_) async {
                final res = await ref
                    .read(listsRepoProvider)
                    .tickGroup(group.ids, true);
                ref
                    .read(snackbarProvider)
                    .show(l10n.listsGot(survivor.name), undo: res.undo);
              },
            ),
            Expanded(
              child: InkWell(
                onTap: () => onOpenItem(group),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survivor.name,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      Text(
                        survivor.category,
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      if (group.checkQty) ...[
                        const SizedBox(height: 4),
                        NestTag(
                          label: l10n.listsCheckQty,
                          kind: NestTagKind.accent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            QtyStepper(
              valueText: formatQty(shownMilli, survivor.unit),
              semanticLabel: survivor.name,
              minusTooltip: l10n.listsLess,
              plusTooltip: l10n.listsMore,
              onMinus: group.totalMilli <= step
                  ? null
                  : () => ref
                        .read(listsRepoProvider)
                        .takeFromGroup(group.ids, step),
              onPlus: () =>
                  ref.read(listsRepoProvider).stepQty(survivor.id, step),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyAgainSection extends StatelessWidget {
  const BuyAgainSection({
    super.key,
    required this.rows,
    required this.onAdd,
  });

  final List<ItemHistoryRow> rows;
  final ValueChanged<String> onAdd;

  String _textFor(ItemHistoryRow r) {
    final unit = r.lastUnit;
    final qty = r.lastQtyMilli;
    if (qty != null && unit != null && unit.isNotEmpty) {
      return '${r.name} ${formatQty(qty, unit)}';
    }
    return r.name;
  }

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        SectionHeader(title: l10n.listsBuyAgain),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final r in rows)
                NestChip(
                  label: l10n.listsBuyAgainChip(r.name),
                  onTap: () => onAdd(_textFor(r)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
