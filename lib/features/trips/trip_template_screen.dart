import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TripTemplateScreen extends ConsumerStatefulWidget {
  const TripTemplateScreen({super.key});

  @override
  ConsumerState<TripTemplateScreen> createState() => _TripTemplateScreenState();
}

class _TripTemplateScreenState extends ConsumerState<TripTemplateScreen> {
  final _addCtrl = TextEditingController();
  final _addFocus = FocusNode();
  bool _busy = false;

  @override
  void dispose() {
    _addCtrl.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  List<String> _starterTitles(AppLocalizations l10n) => [
    l10n.tripsStarterChargers,
    l10n.tripsStarterIds,
    l10n.tripsStarterMedicines,
    l10n.tripsStarterClothes,
    l10n.tripsStarterWater,
    l10n.tripsStarterKeys,
    l10n.tripsStarterGas,
    l10n.tripsStarterLocks,
  ];

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
          .addTemplateItem(title, sortOrder: nextOrder);
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(AppLocalizations.of(context).tripsItemAdded, undo: res.undo);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadStarters(int nextOrder) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final starters = _starterTitles(l10n);
    setState(() => _busy = true);
    try {
      final res = await ref
          .read(tripsRepoProvider)
          .addTemplateItems(starters, startOrder: nextOrder);
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(l10n.tripsStarterLoaded(starters.length), undo: res.undo);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteItem(TripTemplateItemRow item) async {
    final res = await ref.read(tripsRepoProvider).deleteTemplateItem(item.id);
    if (!mounted) return;
    ref
        .read(snackbarProvider)
        .show(AppLocalizations.of(context).tripsItemDeleted, undo: res.undo);
  }

  Future<void> _editItem(TripTemplateItemRow item) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: item.title);
    try {
      await showNestSheet<void>(
        context,
        (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            NestSheetHeader(title: l10n.tripsEditItemTitle),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.tripsItemLabel,
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),
            NestButton(
              label: l10n.tripsSaveChanges,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: () async {
                final next = ctrl.text.trim();
                if (next.isEmpty) return;
                Navigator.of(ctx).pop();
                if (next != item.title) {
                  await ref
                      .read(tripsRepoProvider)
                      .updateTemplateItem(item.id, next);
                }
              },
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final items =
        ref.watch(tripTemplateItemsProvider).value ??
        const <TripTemplateItemRow>[];

    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.tripsGenericTitle),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            Text(
              l10n.tripsGenericLead,
              style: NestText.body15.copyWith(color: c.ink2),
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
                      hintText: l10n.tripsGenericAddHint,
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
                  icon: Icons.playlist_add_check_rounded,
                  title: l10n.tripsGenericEmptyTitle,
                  body: l10n.tripsGenericEmptyBody,
                ),
              ),
              const SizedBox(height: 12),
              NestButton(
                label: l10n.tripsLoadStarter,
                icon: Icons.auto_awesome_outlined,
                kind: NestButtonKind.tonal,
                size: NestButtonSize.block,
                onPressed: _busy ? null : () => _loadStarters(0),
              ),
            ] else
              NestCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) Container(height: 1, color: c.line),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _editItem(items[i]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    items[i].title,
                                    style: NestText.body16.copyWith(
                                      color: c.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.tripsDeleteItem,
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: c.ink3,
                              ),
                              onPressed: () => _deleteItem(items[i]),
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
      ),
    );
  }
}
