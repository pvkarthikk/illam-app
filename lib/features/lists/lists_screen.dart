import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/channels.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/domain/usual_store.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/item_sheet.dart';
import 'package:nm_flat/features/lists/lists_controller.dart';
import 'package:nm_flat/features/lists/lists_parts.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/features/lists/store_picker_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) {
      _focus.requestFocus();
      return;
    }
    final text = _ctrl.text;
    _ctrl.clear();
    _focus.requestFocus();
    final outcome = await ref
        .read(listsControllerProvider.notifier)
        .add(text);
    if (!mounted) return;
    if (outcome == null) {
      if (_ctrl.text.isEmpty) _ctrl.text = text;
      return;
    }
    _showOutcome(outcome);
  }

  Future<void> _pickStore(String list) async {
    final ch = await showStorePicker(context, list);
    if (ch != null) {
      await ref.read(listsControllerProvider.notifier).pickChannel(ch);
    }
    if (mounted) _focus.requestFocus();
  }

  void _showOutcome(AddOutcome o) {
    final l10n = AppLocalizations.of(context);
    final sb = ref.read(snackbarProvider);
    switch (o.kind) {
      case AddKind.added:
        sb.show(
          l10n.listsAdded(o.name, channelName(l10n, o.channel)),
          undo: o.undo,
        );
      case AddKind.merged:
        sb.show(l10n.listsMerged(o.name, o.qtyText), undo: o.undo);
      case AddKind.incompatible:
        sb.show(l10n.listsAlready(o.name, o.qtyText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(listsControllerProvider);
    final list = ui.listType;
    final ctrl = ref.read(listsControllerProvider.notifier);

    final rows = ref.watch(listItemsProvider(list)).value ?? const <ItemRow>[];
    final openGroups = groupOpenItems(
      snapsOf([
        for (final r in rows)
          if (!r.done) r,
      ]),
    );
    final byId = {for (final r in rows) r.id: r};

    final rowsByChannel = <String, List<ItemRow>>{};
    for (final r in rows) {
      (rowsByChannel[r.channel] ??= []).add(r);
    }
    final openByChannel = <String, List<ItemGroup>>{};
    for (final g in openGroups) {
      final s = byId[g.survivor.id];
      if (s != null) {
        (openByChannel[s.channel] ??= []).add(g);
      }
    }
    final hasOfflineOpen = (openByChannel['offline'] ?? const []).isNotEmpty;

    final channelsOrder = listChannels[list] ?? const <String>[];
    final presentChannels = [
      for (final ch in channelsOrder)
        if ((rowsByChannel[ch] ?? const []).isNotEmpty) ch,
    ];
    final effectiveFilter =
        ui.filter != null && (rowsByChannel[ui.filter!] ?? const []).isNotEmpty
        ? ui.filter
        : null;
    final visibleChannels = effectiveFilter == null
        ? presentChannels
        : [effectiveFilter];

    final historyRows =
        ref.watch(listHistoryProvider(list)).value ?? const <ItemHistoryRow>[];
    final openKeys = {
      for (final r in rows)
        if (!r.done) r.nameKey,
    };
    final buyAgainRows = [
      for (final h in historyRows)
        if (!openKeys.contains(h.nameKey)) h,
    ].take(8).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller:
              ref.watch(tabScrollControllersProvider)[NestTab.lists.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            NestTopBar.tab(
              eyebrow: l10n.listsEyebrow,
              title: l10n.listsTitle,
              actions: [
                if (hasOfflineOpen)
                  NestButton(
                    label: l10n.listsStoreMode,
                    icon: Icons.storefront_outlined,
                    kind: NestButtonKind.ghost,
                    size: NestButtonSize.sm,
                    onPressed: () => context.push(Routes.listsStore),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SegmentedTabs<String>(
                segments: [
                  (
                    'grocery',
                    l10n.listsGrocery,
                    ref.watch(openGroupCountProvider('grocery')),
                  ),
                  (
                    'shopping',
                    l10n.listsShopping,
                    ref.watch(openGroupCountProvider('shopping')),
                  ),
                ],
                selected: list,
                onChanged: ctrl.setListType,
              ),
            ),
            _AddSection(
              controller: _ctrl,
              focusNode: _focus,
              list: list,
              onPickStore: () => _pickStore(list),
              onSubmit: _submit,
            ),
            if (presentChannels.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    NestChip(
                      label: l10n.listsAll,
                      selected: effectiveFilter == null,
                      onTap: () => ctrl.setFilter(null),
                    ),
                    for (final ch in presentChannels) ...[
                      const SizedBox(width: 8),
                      NestChip(
                        label: channelName(l10n, ch),
                        selected: effectiveFilter == ch,
                        dotColor: ch == 'offline'
                            ? null
                            : NestPalette.channels[ch]?.bg,
                        leading: ch == 'offline'
                            ? Icon(
                                Icons.storefront_outlined,
                                size: 15,
                                color: effectiveFilter == ch ? c.paper : c.ink2,
                              )
                            : null,
                        count: (openByChannel[ch] ?? const []).length,
                        onTap: () => ctrl.setFilter(ch),
                      ),
                    ],
                  ],
                ),
              ),
            for (final ch in visibleChannels)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: ChannelGroupCard(
                  list: list,
                  channel: ch,
                  rows: rowsByChannel[ch] ?? const [],
                  groups: openByChannel[ch] ?? const [],
                  onOpenItem: (g) {
                    final s = byId[g.survivor.id];
                    if (s != null) {
                      showItemSheet(context, group: g, survivor: s);
                    }
                  },
                ),
              ),
            BuyAgainSection(
              rows: buyAgainRows,
              onAdd: (text) async {
                final outcome = await ctrl.add(text, source: 'buyAgain');
                if (mounted && outcome != null) _showOutcome(outcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSection extends ConsumerWidget {
  const _AddSection({
    required this.controller,
    required this.focusNode,
    required this.list,
    required this.onPickStore,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String list;
  final VoidCallback onPickStore;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(listsControllerProvider);
    final usualMap = ref.watch(usualMapProvider(list));
    final prefs = ref.watch(prefsProvider);

    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final trimmed = controller.text.trim();
        final String store;
        final String hint;
        if (trimmed.isEmpty) {
          store =
              ui.pickedChannel ??
              prefs.lastStore(list) ??
              listChannels[list]!.first;
          hint = l10n.listsHintIdle;
        } else {
          final p = parseItem(controller.text);
          final u = usualStore(
            list: list,
            nameKey: itemNameKey(p.name),
            usualByKey: usualMap,
            lastChosen: prefs.lastStore(list),
          );
          store = ui.pickedChannel ?? u.channel;
          final itemText = (p.qty != 1 || p.unit.isNotEmpty)
              ? l10n.listsHintItemQty(p.name, formatQty(p.qtyMilli, p.unit))
              : p.name;
          final learnedUsual =
              u.learned &&
              (ui.pickedChannel == null || ui.pickedChannel == u.channel);
          hint = l10n.listsHint(
            itemText,
            channelName(l10n, store),
            learnedUsual ? l10n.listsHintUsual : '',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AddBar(
                controller: controller,
                focusNode: focusNode,
                focused: focusNode.hasFocus,
                hintText: list == 'grocery'
                    ? l10n.listsPlaceholderGrocery
                    : l10n.listsPlaceholderShopping,
                store: store,
                onPickStore: onPickStore,
                onSubmit: onSubmit,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  hint,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.hintText,
    required this.store,
    required this.onPickStore,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final String hintText;
  final String store;
  final VoidCallback onPickStore;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final storeName = channelName(l10n, store);
    final chColor = NestPalette.channels[store]?.bg;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused ? c.primary : c.line2,
          width: 1.5,
        ),
        boxShadow: focused
            ? [BoxShadow(color: c.primarySoft, spreadRadius: 3)]
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            label: l10n.listsStoreButton(storeName),
            excludeSemantics: true,
            child: Material(
              color: c.paper2,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onPickStore,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (store == 'offline' || chColor == null)
                          Icon(
                            Icons.storefront_outlined,
                            size: 16,
                            color: c.ink,
                          )
                        else
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: chColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          storeName,
                          style: NestText.small12.copyWith(color: c.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: l10n.listsAddTooltip,
              icon: const Icon(Icons.add_rounded),
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
