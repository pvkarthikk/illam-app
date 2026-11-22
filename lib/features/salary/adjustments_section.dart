import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class AdjustmentsSection extends ConsumerStatefulWidget {
  const AdjustmentsSection({
    super.key,
    required this.staffId,
    required this.month,
  });

  final String staffId;
  final String month;

  @override
  ConsumerState<AdjustmentsSection> createState() => _AdjustmentsSectionState();
}

class _AdjustmentsSectionState extends ConsumerState<AdjustmentsSection> {
  final _noteCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _addingKind;
  String? _amountError;
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _openForm(String kind) {
    setState(() {
      _addingKind = kind;
      _noteCtrl.clear();
      _amountCtrl.clear();
      _amountError = null;
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving || _addingKind == null) return;
    final paise = Money.parseRupees(_amountCtrl.text);
    if (paise == null || paise <= 0) {
      setState(() => _amountError = l10n.salaryCheckAmount);
      return;
    }
    setState(() {
      _saving = true;
      _amountError = null;
    });
    try {
      final res = await ref
          .read(salaryRepoProvider)
          .addAdjustment(
            widget.staffId,
            widget.month,
            _addingKind!,
            paise,
            _noteCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _addingKind = null;
        _noteCtrl.clear();
        _amountCtrl.clear();
      });
      ref
          .read(snackbarProvider)
          .show(l10n.salaryAdjAdded, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove(AppLocalizations l10n, PayAdjustmentRow a) async {
    final res = await ref.read(salaryRepoProvider).removeAdjustment(a.id);
    if (!mounted) return;
    ref.read(snackbarProvider).show(l10n.salaryAdjRemoved, undo: res.undo);
  }

  (String, NestTagKind) _tagMeta(AppLocalizations l10n, String kind) =>
      switch (kind) {
        'extra' => (l10n.salaryKindExtra, NestTagKind.ok),
        'advance' => (l10n.salaryKindAdvance, NestTagKind.danger),
        _ => (l10n.salaryKindDeduction, NestTagKind.danger),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final monthName = Formatters.monthName(widget.month);
    final settled =
        ref.watch(settledMonthsProvider(widget.staffId)).value?.contains(
              widget.month,
            ) ??
        false;
    final allAdjustments =
        ref.watch(salaryAdjustmentsProvider(widget.staffId)).value ?? const [];
    final rows = [
      for (final a in allAdjustments)
        if (a.month == widget.month) a,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Divider(color: c.line, height: 1),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.salaryAdjustmentsFor(monthName).toUpperCase(),
            style: NestText.section13.copyWith(color: c.ink2),
          ),
        ),
        for (final a in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${a.note} · ${Money.format(a.amountPaise)}',
                    style: NestText.body15.copyWith(color: c.ink),
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (_) {
                    final (tagLabel, tagKind) = _tagMeta(l10n, a.kind);
                    return NestTag(label: tagLabel, kind: tagKind);
                  },
                ),
                if (!settled)
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: c.ink3),
                    tooltip: l10n.salaryAdjRemove,
                    onPressed: () => _remove(l10n, a),
                  ),
              ],
            ),
          ),
        if (settled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.salaryAdjLocked(monthName),
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
          )
        else ...[
          if (_addingKind != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.card2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      NestTag(
                        label: _tagMeta(l10n, _addingKind!).$1,
                        kind: _tagMeta(l10n, _addingKind!).$2,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: l10n.commonClose,
                        onPressed: () => setState(() => _addingKind = null),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _noteCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l10n.salaryAdjNote),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: l10n.salaryAdjAmount,
                      errorText: _amountError,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NestButton(
                    label: l10n.salaryAdjSave,
                    kind: NestButtonKind.primary,
                    size: NestButtonSize.sm,
                    onPressed: _saving ? null : () => _save(l10n),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              NestButton(
                label: l10n.salaryAddExtra,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => _openForm('extra'),
              ),
              NestButton(
                label: l10n.salaryAddAdvance,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => _openForm('advance'),
              ),
              NestButton(
                label: l10n.salaryAddDeduction,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => _openForm('deduction'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
