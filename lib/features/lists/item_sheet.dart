import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/channels.dart';
import 'package:nm_flat/core/domain/item_category.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showItemSheet(
  BuildContext context, {
  required ItemGroup group,
  required ItemRow survivor,
}) => showNestSheet<void>(
  context,
  (_) => ItemSheet(group: group, survivor: survivor),
);

class ItemSheet extends ConsumerStatefulWidget {
  const ItemSheet({
    super.key,
    required this.group,
    required this.survivor,
  });

  final ItemGroup group;
  final ItemRow survivor;

  @override
  ConsumerState<ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends ConsumerState<ItemSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late String _unit;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.survivor.name);
    _qtyCtrl = TextEditingController(
      text: (widget.group.totalMilli / 1000)
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), ''),
    );
    _unit = widget.survivor.unit;
    _category = widget.survivor.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    var closed = false;
    try {
      final s = widget.survivor;
      final trimmedName = _nameCtrl.text.trim();
      final newName = trimmedName.isEmpty ? s.name : trimmedName;
      final parsedQty = double.tryParse(_qtyCtrl.text.trim());
      final newMilli = (parsedQty != null && parsedQty > 0)
          ? (parsedQty * 1000).round()
          : widget.group.totalMilli;

      ItemGroup? mergeInto;
      final newKey = itemNameKey(newName);
      if (newKey != s.nameKey) {
        final rows = ref.read(listItemsProvider(s.list)).value ?? const [];
        final openRows = [
          for (final r in rows)
            if (!r.done && !widget.group.ids.contains(r.id)) r,
        ];
        final candidates = [
          for (final g in groupOpenItems(snapsOf(openRows)))
            if (g.survivor.nameKey == newKey) g,
        ];
        if (candidates.isNotEmpty) {
          final target = candidates.first;
          final otherRow = openRows.firstWhere(
            (r) => r.id == target.survivor.id,
          );
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dlgCtx) => AlertDialog(
              content: Text(
                l10n.listsMergeAsk(
                  otherRow.name,
                  formatQty(target.totalMilli, target.survivor.unit),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(false),
                  child: Text(l10n.listsCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(true),
                  child: Text(l10n.listsMerge),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (confirm != true) return;
          if (compatKey(_unit) == compatKey(target.survivor.unit)) {
            mergeInto = target;
          }
        }
      }

      final snack = ref.read(snackbarProvider);
      final repo = ref.read(listsRepoProvider);
      final group = widget.group;
      final unit = _unit;
      final category = _category;
      closed = true;
      Navigator.of(context).pop();
      try {
        final res = await repo.saveGroup(
          group: group,
          survivor: s,
          name: newName,
          qtyMilli: newMilli,
          unit: unit,
          category: category,
          mergeInto: mergeInto,
        );
        snack.show(l10n.listsSaved, undo: res.undo);
      } on Object {
        snack.show(rejectText('other'));
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _moveTo(AppLocalizations l10n, String channel) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final s = widget.survivor;
      final res = await ref
          .read(listsRepoProvider)
          .moveGroup(widget.group.ids, s.list, s.nameKey, s.name, channel);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(
            l10n.listsMoved(s.name, channelName(l10n, channel)),
            undo: res.undo,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final res = await ref
          .read(listsRepoProvider)
          .removeGroup(widget.group.ids);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.listsRemoved, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final s = widget.survivor;
    final otherChannels = [
      for (final ch in (listChannels[s.list] ?? const <String>[]))
        if (ch != s.channel) ch,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: s.name,
          lead: l10n.listsItemLead(
            formatQty(widget.group.totalMilli, s.unit),
            s.category,
            s.list,
          ),
        ),
        if (s.note != null && s.note!.trim().isNotEmpty) ...[
          Text(s.note!, style: NestText.meta13.copyWith(color: c.ink3)),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.listsName),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qtyCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.listsQuantity),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.listsUnit,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final u in groceryUnits)
              NestChip(
                label: u.isEmpty ? '×' : u,
                selected: _unit == u,
                onTap: () => setState(() => _unit = u),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          l10n.listsCategory,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final cat in categoriesFor(s.list))
              NestChip(
                label: cat,
                selected: _category == cat,
                onTap: () => setState(() => _category = cat),
              ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeader(title: l10n.listsMoveTo),
        for (final ch in otherChannels)
          InkWell(
            onTap: _saving ? null : () => _moveTo(l10n, ch),
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    ChannelBadge(channel: ch),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        channelName(l10n, ch),
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontVariations: const [FontVariation.weight(700)],
                          color: c.ink,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.ink3),
                  ],
                ),
              ),
            ),
          ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.listsRemove,
              icon: Icons.delete_outline_rounded,
              kind: NestButtonKind.ghost,
              onPressed: _saving ? null : () => _remove(l10n),
            ),
            NestButton(
              label: l10n.listsSave,
              kind: NestButtonKind.primary,
              onPressed: _saving ? null : () => _save(l10n),
            ),
          ],
        ),
      ],
    );
  }
}
