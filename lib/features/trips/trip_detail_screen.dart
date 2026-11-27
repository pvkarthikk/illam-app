import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/trip_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/trips/trip_detail_parts.dart';
import 'package:nm_flat/features/trips/trip_format.dart';
import 'package:nm_flat/features/trips/trip_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  final _addCtrl = TextEditingController();
  final _addFocus = FocusNode();
  bool _checkedOpen = false;
  bool _busy = false;

  @override
  void dispose() {
    _addCtrl.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  Future<void> _addItem(int nextOrder) async {
    final title = _addCtrl.text.trim();
    if (title.isEmpty || _busy) {
      if (title.isEmpty) _addFocus.requestFocus();
      return;
    }
    _addCtrl.clear();
    _addFocus.requestFocus();
    setState(() => _busy = true);
    try {
      final res = await ref
          .read(tripsRepoProvider)
          .addTripItem(widget.tripId, title, sortOrder: nextOrder);
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(AppLocalizations.of(context).tripsItemAdded, undo: res.undo);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleItem(TripItemRow item, bool done) async {
    final l10n = AppLocalizations.of(context);
    final res = await ref.read(tripsRepoProvider).setTripItemDone(item.id, done);
    if (!mounted) return;
    ref
        .read(snackbarProvider)
        .show(
          done
              ? l10n.tripsItemChecked(item.title)
              : l10n.tripsItemUnchecked(item.title),
          undo: res.undo,
        );
  }

  Future<void> _importGeneric(
    List<TripItemRow> existing,
    List<TripTemplateItemRow> templateItems,
  ) async {
    final l10n = AppLocalizations.of(context);
    final snack = ref.read(snackbarProvider);
    final missing = filterMissingTemplateTitles(
      [for (final i in existing) i.title],
      [for (final t in templateItems) t.title],
    );
    if (missing.isEmpty) {
      snack.show(l10n.tripsImportedCount(0));
      return;
    }
    final res = await ref
        .read(tripsRepoProvider)
        .importTemplateItems(
          widget.tripId,
          missing,
          startOrder: existing.length,
        );
    if (!mounted) return;
    snack.show(l10n.tripsImportedCount(missing.length), undo: res.undo);
  }

  Future<void> _resetChecks(List<TripItemRow> items) async {
    final doneIds = [
      for (final i in items)
        if (i.done) i.id,
    ];
    if (doneIds.isEmpty) return;
    final res = await ref.read(tripsRepoProvider).resetTripChecks(doneIds);
    if (!mounted) return;
    ref
        .read(snackbarProvider)
        .show(AppLocalizations.of(context).tripsChecksReset, undo: res.undo);
  }

  Future<void> _deleteTrip(TripRow trip) async {
    final l10n = AppLocalizations.of(context);
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId ??
        '';
    final res = await ref.read(tripsRepoProvider).deleteTrip(homeId, trip.id);
    if (!mounted) return;
    ref.read(snackbarProvider).show(l10n.tripsDeleted, undo: res.undo);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final tripAsync = ref.watch(tripByIdProvider(widget.tripId));
    final trip = tripAsync.value;
    final items =
        ref.watch(tripItemsProvider(widget.tripId)).value ??
        const <TripItemRow>[];
    final templateItems =
        ref.watch(tripTemplateItemsProvider).value ??
        const <TripTemplateItemRow>[];
    final today = ref.watch(todayDateProvider);

    if (trip == null) {
      return Scaffold(
        appBar: NestTopBar.sub(title: l10n.tripsTab),
        body: tripAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: NestCard(
                  child: EmptyState(
                    icon: Icons.luggage_outlined,
                    title: l10n.tripsNotFound,
                    body: l10n.tripsEmptyBody,
                  ),
                ),
              ),
      );
    }

    final status = summarizeTrip(trip, items, today);
    final unchecked = [
      for (final i in items)
        if (!i.done) i,
    ];
    final checked = [
      for (final i in items)
        if (i.done) i,
    ];

    return Scaffold(
      appBar: NestTopBar.sub(
        title: trip.title,
        subtitle: formatTripDateRange(
          trip.startDate,
          trip.endDate,
          l10n.localeName,
        ),
        actions: [
          IconButton(
            tooltip: l10n.tripsEditTrip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showTripSheet(context, existing: trip),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.tripsMoreActions,
            onSelected: (action) {
              if (action == 'import') {
                _importGeneric(items, templateItems);
              } else if (action == 'reset') {
                _resetChecks(items);
              } else if (action == 'delete') {
                _deleteTrip(trip);
              }
            },
            itemBuilder: (_) => [
              if (templateItems.isNotEmpty)
                PopupMenuItem(
                  value: 'import',
                  child: Text(l10n.tripsImportGeneric),
                ),
              if (checked.isNotEmpty)
                PopupMenuItem(
                  value: 'reset',
                  child: Text(l10n.tripsResetChecks),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.tripsDeleteTrip),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            TripReadinessCard(
              trip: trip,
              status: status,
              hasItems: items.isNotEmpty,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addCtrl,
                    focusNode: _addFocus,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addItem(items.length),
                    decoration: InputDecoration(
                      hintText: l10n.tripsAddItemHint,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton.filled(
                    tooltip: l10n.tripsAddItem,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _busy ? null : () => _addItem(items.length),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty) ...[
              NestCard(
                child: EmptyState(
                  icon: Icons.checklist_rtl_rounded,
                  title: l10n.tripsNoItemsYet,
                  body: l10n.tripsGenericLead,
                ),
              ),
              if (templateItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                NestButton(
                  label: l10n.tripsCopyGenericBtn(templateItems.length),
                  icon: Icons.copy_all_rounded,
                  kind: NestButtonKind.tonal,
                  size: NestButtonSize.block,
                  onPressed: () => _importGeneric(items, templateItems),
                ),
              ],
            ] else ...[
              if (unchecked.isNotEmpty)
                NestCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < unchecked.length; i++) ...[
                        if (i > 0) Container(height: 1, color: c.line),
                        TripChecklistRow(
                          item: unchecked[i],
                          onToggle: (done) => _toggleItem(unchecked[i], done),
                          onEdit: () => showTripItemSheet(
                            context,
                            ref,
                            item: unchecked[i],
                            templateItems: templateItems,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (checked.isNotEmpty) ...[
                if (unchecked.isNotEmpty) const SizedBox(height: 16),
                NestCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () =>
                            setState(() => _checkedOpen = !_checkedOpen),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.tripsCheckedSection(checked.length),
                                    style: NestText.itemTitle16.copyWith(
                                      color: c.ink2,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _checkedOpen
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: c.ink3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_checkedOpen)
                        for (final item in checked) ...[
                          Container(height: 1, color: c.line),
                          TripChecklistRow(
                            item: item,
                            onToggle: (done) => _toggleItem(item, done),
                            onEdit: () => showTripItemSheet(
                              context,
                              ref,
                              item: item,
                              templateItems: templateItems,
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
