import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
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
                  key: ValueKey(survivor.id),
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
            _BoughtFooter(
              list: list,
              channel: channel,
              names: doneNames.join(', '),
            ),
          ],
        ],
      ),
    );
  }
}

class _BoughtFooter extends ConsumerStatefulWidget {
  const _BoughtFooter({
    required this.list,
    required this.channel,
    required this.names,
  });

  final String list;
  final String channel;
  final String names;

  @override
  ConsumerState<_BoughtFooter> createState() => _BoughtFooterState();
}

class _BoughtFooterState extends ConsumerState<_BoughtFooter> {
  bool _clearing = false;

  @override
  void didUpdateWidget(covariant _BoughtFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.names != widget.names) {
      _clearing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_clearing) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Container(
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
              l10n.listsGotFooter(widget.names),
              style: NestText.meta13.copyWith(color: c.ink2),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              if (_clearing) return;
              final snack = ref.read(snackbarProvider);
              final repo = ref.read(listsRepoProvider);
              final list = widget.list;
              final channel = widget.channel;
              setState(() => _clearing = true);
              try {
                final (res, count) = await repo.clearChannel(list, channel);
                snack.show(l10n.listsCleared(count), undo: res.undo);
                if (res.undo == null && mounted) {
                  setState(() => _clearing = false);
                }
              } on Object {
                if (mounted) setState(() => _clearing = false);
              }
            },
            child: Text(l10n.listsClear),
          ),
        ],
      ),
    );
  }
}

class _GroupItemRow extends ConsumerStatefulWidget {
  const _GroupItemRow({
    super.key,
    required this.group,
    required this.survivor,
    required this.onOpenItem,
  });

  final ItemGroup group;
  final ItemRow survivor;
  final ValueChanged<ItemGroup> onOpenItem;

  @override
  ConsumerState<_GroupItemRow> createState() => _GroupItemRowState();
}

class _GroupItemRowState extends ConsumerState<_GroupItemRow> {
  bool _ticking = false;
  int _pendingMilli = 0;
  int _sentMilli = 0;
  Timer? _timer;
  late final ListsRepo _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(listsRepoProvider);
  }

  @override
  void didUpdateWidget(covariant _GroupItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.totalMilli != widget.group.totalMilli) {
      _sentMilli = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_pendingMilli != 0) {
      _writeDelta(_pendingMilli).ignore();
    }
    super.dispose();
  }

  Future<ChangeResult> _writeDelta(int delta) => delta > 0
      ? _repo.stepQty(widget.survivor.id, delta)
      : _repo.takeFromGroup(widget.group.ids, -delta);

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), _flush);
  }

  void _nudge(int delta) {
    setState(() => _pendingMilli += delta);
    _restartTimer();
  }

  Future<void> _flush() async {
    if (_sentMilli != 0) {
      _restartTimer();
      return;
    }
    if (_pendingMilli == 0) return;
    final delta = _pendingMilli;
    _pendingMilli = 0;
    _sentMilli = delta;
    try {
      final res = await _writeDelta(delta);
      if (res.undo == null && mounted) {
        setState(() => _sentMilli = 0);
      }
    } on Object {
      if (mounted) setState(() => _sentMilli = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final group = widget.group;
    final survivor = widget.survivor;
    final step = stepMilli(survivor.unit);
    final displayedMilli = group.totalMilli + _pendingMilli + _sentMilli;
    final shownMilli =
        group.checkQty && _pendingMilli == 0 && _sentMilli == 0
        ? step
        : displayedMilli;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            NestCheckbox(
              value: _ticking,
              semanticLabel: l10n.listsGotSemantics(survivor.name),
              onChanged: (_) async {
                if (_ticking) return;
                final snack = ref.read(snackbarProvider);
                final repo = ref.read(listsRepoProvider);
                final ids = group.ids;
                final msg = l10n.listsGot(survivor.name);
                setState(() => _ticking = true);
                try {
                  final res = await repo.tickGroup(ids, true);
                  snack.show(msg, undo: res.undo);
                  if (res.undo == null && mounted) {
                    setState(() => _ticking = false);
                  }
                } on Object {
                  if (mounted) setState(() => _ticking = false);
                }
              },
            ),
            Expanded(
              child: InkWell(
                onTap: () => widget.onOpenItem(group),
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
              onMinus: displayedMilli <= step ? null : () => _nudge(-step),
              onPlus: () => _nudge(step),
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
