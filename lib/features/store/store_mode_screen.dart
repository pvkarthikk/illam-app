import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/domain/store_aisles.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/lists_controller.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/features/store/log_bill_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class StoreModeScreen extends ConsumerStatefulWidget {
  const StoreModeScreen({super.key});

  @override
  ConsumerState<StoreModeScreen> createState() => _StoreModeScreenState();
}

class _StoreModeScreenState extends ConsumerState<StoreModeScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _logBill(String list, List<ItemRow> picked) async {
    final logged = await showLogBillSheet(context, list: list, picked: picked);
    if (logged == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(listsControllerProvider).listType;
    final itemsAsync = ref.watch(listItemsProvider(list));

    final allItems = itemsAsync.value ?? const <ItemRow>[];
    final offlineItems = [
      for (final r in allItems)
        if (r.channel == 'offline') r,
    ];
    final byId = {for (final r in offlineItems) r.id: r};
    final openOffline = [
      for (final r in offlineItems)
        if (!r.done) r,
    ];
    final doneOffline = [
      for (final r in offlineItems)
        if (r.done) r,
    ];

    final openGroups = groupOpenItems(snapsOf(openOffline));
    final doneGroups = groupOpenItems(snapsOf(doneOffline));
    final rows = <_StoreRowEntry>[
      for (final g in openGroups)
        if (byId[g.survivor.id] case final s?)
          _StoreRowEntry(group: g, survivor: s, picked: false),
      for (final g in doneGroups)
        if (byId[g.survivor.id] case final s?)
          _StoreRowEntry(group: g, survivor: s, picked: true),
    ];

    final doneCount = rows.where((r) => r.picked).length;
    final totalCount = rows.length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;
    final aisles = sortAisles([for (final r in rows) r.survivor.category]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: NestPalette.immersiveBg,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                NestPalette.immersiveBg.withValues(alpha: 0),
                NestPalette.immersiveBg,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: NestButton(
              label: l10n.storeDoneLogBill,
              icon: Icons.check_rounded,
              kind: NestButtonKind.accent,
              size: NestButtonSize.block,
              onPressed: doneCount >= 1
                  ? () => _logBill(list, doneOffline)
                  : null,
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: l10n.storeBack,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: NestPalette.immersiveText,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.storeTitle,
                            style: NestText.title28.copyWith(
                              color: NestPalette.immersiveText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.storeProgress(doneCount, totalCount),
                            style: NestText.meta13.copyWith(
                              color: NestPalette.immersiveMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          NestProgressBar(
                            value: progress,
                            height: 12,
                            color: NestPalette.immersiveAccent,
                            track: NestPalette.immersiveRow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: itemsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: NestPalette.immersiveAccent,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '$e',
                        style: NestText.body15.copyWith(
                          color: NestPalette.immersiveMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (_) {
                    if (rows.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.storeEmptyTitle,
                                style: const TextStyle(
                                  fontFamily: NestText.sans,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontVariations: [FontVariation.weight(700)],
                                  color: NestPalette.immersiveText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.storeEmptyBody,
                                style: NestText.body15.copyWith(
                                  color: NestPalette.immersiveMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      children: [
                        for (final aisle in aisles) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                            child: Text(
                              aisle.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: NestText.sans,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontVariations: [FontVariation.weight(800)],
                                letterSpacing: 1.3,
                                color: NestPalette.immersiveMuted,
                              ),
                            ),
                          ),
                          for (final entry in [
                            for (final r in rows)
                              if (r.survivor.category == aisle && !r.picked) r,
                            for (final r in rows)
                              if (r.survivor.category == aisle && r.picked) r,
                          ]) ...[
                            _StoreItemTile(
                              entry: entry,
                              onTap: () async {
                                final repo = ref.read(listsRepoProvider);
                                try {
                                  final res = await repo.tickGroup(
                                    entry.group.ids,
                                    !entry.picked,
                                  );
                                  return res.undo != null;
                                } on Object {
                                  return false;
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreRowEntry {
  const _StoreRowEntry({
    required this.group,
    required this.survivor,
    required this.picked,
  });

  final ItemGroup group;
  final ItemRow survivor;
  final bool picked;
}

class _StoreItemTile extends StatefulWidget {
  const _StoreItemTile({required this.entry, required this.onTap});

  final _StoreRowEntry entry;
  final Future<bool> Function() onTap;

  @override
  State<_StoreItemTile> createState() => _StoreItemTileState();
}

class _StoreItemTileState extends State<_StoreItemTile> {
  bool _busy = false;

  @override
  void didUpdateWidget(covariant _StoreItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.survivor.id != widget.entry.survivor.id ||
        oldWidget.entry.picked != widget.entry.picked) {
      _busy = false;
    }
  }

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.onTap();
    if (!ok && mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final qtyText = formatQty(entry.group.totalMilli, entry.survivor.unit);
    final name = entry.survivor.name;
    final picked = entry.picked != _busy;

    return Semantics(
      checked: picked,
      label: '$name, $qtyText',
      excludeSemantics: true,
      onTap: _handleTap,
      child: Opacity(
        opacity: picked ? 0.5 : 1.0,
        child: Material(
          color: NestPalette.immersiveRow,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _handleTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: picked
                            ? NestPalette.immersiveChecked
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: picked
                            ? null
                            : Border.all(
                                color: NestPalette.immersiveBox,
                                width: 2.5,
                              ),
                      ),
                      child: picked
                          ? const Icon(
                              Icons.check_rounded,
                              size: 22,
                              color: NestPalette.immersiveBg,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontVariations: const [FontVariation.weight(700)],
                          color: NestPalette.immersiveText,
                          decoration: picked
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: NestPalette.immersiveText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      qtyText,
                      style: const TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontVariations: [FontVariation.weight(600)],
                        color: NestPalette.immersiveMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
