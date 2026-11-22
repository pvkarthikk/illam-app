import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/order_handoff.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/features/store/order_amount_sheet.dart';
import 'package:nm_flat/features/store/order_handoff_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showBackFromStoreSheet(
  BuildContext context,
  PendingHandoff p,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final items = await container.read(listItemsProvider(p.list).future);
  final current = <String, CurrentItem>{
    for (final r in items)
      r.id: CurrentItem(
        qtyMilli: r.qtyMilli,
        unit: r.unit,
        done: r.done,
        deleted: r.deleted,
      ),
  };
  final rows = reviewHandoff(p, current);
  if (rows.isEmpty) {
    await container.read(orderHandoffControllerProvider.notifier).clear();
    return;
  }
  if (!context.mounted) return;

  final result = await showNestSheet<bool>(
    context,
    (_) => _BackFromStoreSheet(p: p, rows: rows),
  );
  await container.read(orderHandoffControllerProvider.notifier).clear();
  if (result == true && context.mounted) {
    await showOrderAmountSheet(context, p.channel, p.list);
  }
}

class _BackFromStoreSheet extends ConsumerStatefulWidget {
  const _BackFromStoreSheet({required this.p, required this.rows});

  final PendingHandoff p;
  final List<HandoffRow> rows;

  @override
  ConsumerState<_BackFromStoreSheet> createState() =>
      _BackFromStoreSheetState();
}

class _BackFromStoreSheetState extends ConsumerState<_BackFromStoreSheet> {
  late final List<bool> _ticked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ticked = List<bool>.filled(widget.rows.length, true);
  }

  Future<void> _submit(AppLocalizations l10n, String store) async {
    if (_saving) return;
    final selected = [
      for (var i = 0; i < widget.rows.length; i++)
        if (_ticked[i]) widget.rows[i],
    ];
    if (selected.isEmpty) return;

    setState(() => _saving = true);
    try {
      final res = await ref
          .read(listsRepoProvider)
          .applyHandoff(
            selected,
            (line) => l10n.storeOrderedNote(
              formatQty(line.qtyMilli, line.unit),
              store,
            ),
          );
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(l10n.storeMarkedOrdered, undo: res.undo);
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final store = channelName(l10n, widget.p.channel);
    final count = _ticked.where((t) => t).length;
    final allTicked = count == widget.rows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.storeBackFrom(store),
          lead: l10n.storeBackLead(store),
        ),
        for (var i = 0; i < widget.rows.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                NestCheckbox(
                  value: _ticked[i],
                  semanticLabel: widget.rows[i].line.name,
                  onChanged: (v) => setState(() => _ticked[i] = v),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.rows[i].line.name,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      if (widget.rows[i].kind == HandoffKind.unitChanged)
                        Text(
                          l10n.storeUnitChanged(
                            formatQty(
                              widget.rows[i].currentMilli,
                              widget.rows[i].currentUnit,
                            ),
                          ),
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatQty(
                    widget.rows[i].line.qtyMilli,
                    widget.rows[i].line.unit,
                  ),
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.storeNotYet,
              kind: NestButtonKind.ghost,
              onPressed:
                  _saving ? null : () => Navigator.of(context).pop(false),
            ),
            NestButton(
              label: allTicked
                  ? l10n.storeOrderedAll
                  : l10n.storeOrderedN(count),
              icon: Icons.check_rounded,
              kind: NestButtonKind.primary,
              onPressed: count == 0 || _saving
                  ? null
                  : () => _submit(l10n, store),
            ),
          ],
        ),
      ],
    );
  }
}
