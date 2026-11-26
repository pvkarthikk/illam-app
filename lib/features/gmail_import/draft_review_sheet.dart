import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_controller.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Opens the review & edit bottom sheet for an unapproved [DraftExpenseOrder].
Future<void> showDraftReviewSheet(
  BuildContext context,
  WidgetRef ref,
  DraftExpenseOrder draft,
) async {
  await showNestSheet<void>(
    context,
    (_) => _DraftReviewSheet(draft: draft),
  );
}

class _DraftReviewSheet extends ConsumerStatefulWidget {
  const _DraftReviewSheet({required this.draft});

  final DraftExpenseOrder draft;

  @override
  ConsumerState<_DraftReviewSheet> createState() => _DraftReviewSheetState();
}

class _DraftReviewSheetState extends ConsumerState<_DraftReviewSheet> {
  late DraftExpenseOrder _draft;
  late TextEditingController _totalCtrl;
  late List<TextEditingController> _nameCtrls;
  late List<TextEditingController> _amountCtrls;
  DuplicateHit? _duplicateHit;
  String? _validationError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _totalCtrl = TextEditingController(
      text: _formatRupeeInput(_draft.totalPaise),
    );
    _nameCtrls = [
      for (final item in _draft.items) TextEditingController(text: item.name),
    ];
    _amountCtrls = [
      for (final item in _draft.items)
        TextEditingController(text: _formatRupeeInput(item.amountPaise)),
    ];
    _checkDuplicate();
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    for (final c in _nameCtrls) {
      c.dispose();
    }
    for (final c in _amountCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatRupeeInput(int paise) {
    final rupees = paise ~/ 100;
    final rem = paise % 100;
    if (rem == 0) return '$rupees';
    return '$rupees.${rem.toString().padLeft(2, '0')}';
  }

  Future<void> _checkDuplicate() async {
    final repo = ref.read(moneyRepoProvider);
    final hit = await repo.checkDuplicate(
      amountPaise: _draft.totalPaise,
      merchant: _draft.channel.displayName,
      orderChannel: _draft.channel.id,
      date: _draft.date,
    );
    if (!mounted || hit == null) return;
    setState(() => _duplicateHit = hit);
  }

  DraftExpenseOrder? _buildValidatedDraft(AppLocalizations l10n) {
    if (!_draft.splitByItem || _draft.items.isEmpty) {
      final total = Money.parseRupees(_totalCtrl.text);
      if (total == null || total <= 0 || total > 100000000) {
        setState(() => _validationError = l10n.gmailImportItemAmountInvalid);
        return null;
      }
      setState(() => _validationError = null);
      return _draft.copyWith(totalPaise: total, splitByItem: false);
    }

    final nextItems = <DraftExpenseItem>[];
    for (var i = 0; i < _draft.items.length; i++) {
      final item = _draft.items[i];
      final name = _nameCtrls[i].text.trim().isEmpty
          ? item.name
          : _nameCtrls[i].text.trim();
      final parsedAmount = Money.parseRupees(_amountCtrls[i].text);
      if (item.included &&
          (parsedAmount == null ||
              parsedAmount <= 0 ||
              parsedAmount > 100000000)) {
        setState(() => _validationError = l10n.gmailImportItemAmountInvalid);
        return null;
      }
      if (item.included && item.category.trim().isEmpty) {
        setState(() => _validationError = l10n.moneyErrCategory);
        return null;
      }
      nextItems.add(
        item.copyWith(
          name: name,
          amountPaise: parsedAmount ?? item.amountPaise,
          category: item.included
              ? normalizeSpendCategory(
                  item.category,
                  fallback: _draft.channel.defaultCategory,
                )
              : item.category,
        ),
      );
    }
    final included = nextItems.where((i) => i.included && i.amountPaise > 0);
    if (included.isEmpty) {
      setState(() => _validationError = l10n.gmailImportNothingSelected);
      return null;
    }
    setState(() => _validationError = null);
    return _draft.copyWith(items: nextItems);
  }

  Future<void> _onAccountIt() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final prepared = _buildValidatedDraft(l10n);
    if (prepared == null) return;

    setState(() => _saving = true);
    try {
      final ctrl = ref.read(gmailImportControllerProvider.notifier);
      final res = await ctrl.accountDraft(prepared);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (res != null) {
        ref
            .read(snackbarProvider)
            .show(
              l10n.gmailImportAccountedSnack(
                res.count,
                Money.formatPaise(res.totalPaise),
              ),
            );
      }
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<void> _onDiscard() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref
        .read(gmailImportControllerProvider.notifier)
        .discardDraft(_draft.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final activeMembers = members.where((m) => m.status == 'active').toList();
    final me = ref.watch(myMemberIdProvider);
    final selectedPayer = _draft.paidBy ?? me;
    final categories = ref.watch(customSpendCategoriesProvider);

    final subtitleParts = <String>[
      Formatters.dayLabel(_draft.date, today, l10n),
      if (_draft.orderId != null && _draft.orderId!.isNotEmpty)
        l10n.gmailImportOrderIdLabel(_draft.orderId!),
    ];

    final includedCount = (!_draft.splitByItem || _draft.items.isEmpty)
        ? 1
        : _draft.items.where((i) => i.included).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: NestSheetHeader(
                title: l10n.gmailImportReviewSheetTitle(
                  _draft.channel.displayName,
                ),
                lead: subtitleParts.join(' · '),
              ),
            ),
            NestTag(
              label: l10n.gmailImportDraftBadge,
              kind: NestTagKind.accent,
            ),
          ],
        ),
        if (_duplicateHit != null) ...[
          AlertLine(
            icon: Icons.warning_amber_rounded,
            text: l10n.gmailImportDuplicateWarning(
              Formatters.dayLabel(_duplicateHit!.date, today, l10n),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_draft.feesPaise > 0 || _draft.discountPaise > 0) ...[
          Text(
            l10n.gmailImportFeesDiscountInfo(
              Money.formatPaise(_draft.feesPaise),
              Money.formatPaise(_draft.discountPaise),
            ),
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 12),
        ],
        if (_draft.items.isNotEmpty) ...[
          SwitchRow(
            title: l10n.gmailImportSplitByItemLabel,
            subtitle: l10n.gmailImportSplitByItemSub(_draft.channel.displayName),
            value: _draft.splitByItem,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(splitByItem: v);
              _validationError = null;
            }),
          ),
          const SizedBox(height: 8),
        ],
        if (!_draft.splitByItem || _draft.items.isEmpty) ...[
          TextField(
            controller: _totalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.gmailImportOrderTotalLabel,
              prefixText: '₹ ',
            ),
            onChanged: (text) {
              final parsed = Money.parseRupees(text);
              if (parsed != null && parsed > 0) {
                setState(() {
                  _draft = _draft.copyWith(totalPaise: parsed);
                  _validationError = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
        ] else ...[
          for (var i = 0; i < _draft.items.length; i++)
            _DraftItemRow(
              item: _draft.items[i],
              categories: categories,
              nameCtrl: _nameCtrls[i],
              amountCtrl: _amountCtrls[i],
              onToggle: (v) => setState(() {
                final next = [..._draft.items];
                next[i] = next[i].copyWith(included: v ?? true);
                _draft = _draft.copyWith(items: next);
                _validationError = null;
              }),
              onAmountChanged: (text) {
                final parsed = Money.parseRupees(text);
                if (parsed != null && parsed > 0) {
                  setState(() {
                    final next = [..._draft.items];
                    next[i] = next[i].copyWith(amountPaise: parsed);
                    _draft = _draft.copyWith(items: next);
                    _validationError = null;
                  });
                }
              },
              onCategoryChanged: (cat) => setState(() {
                final next = [..._draft.items];
                next[i] = next[i].copyWith(category: cat);
                _draft = _draft.copyWith(items: next);
                _validationError = null;
              }),
            ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.moneyPaidWith,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final m in const ['upi', 'cash', 'card', 'bank'])
              NestChip(
                label: _methodLabel(l10n, m),
                selected: _draft.method == m,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(method: m);
                }),
              ),
          ],
        ),
        if (activeMembers.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            l10n.moneyPaidBy,
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final member in activeMembers)
                NestChip(
                  label: _memberName(member, me, l10n),
                  selected: selectedPayer == member.id,
                  onTap: () => setState(() {
                    _draft = _draft.copyWith(paidBy: member.id);
                  }),
                ),
            ],
          ),
        ],
        if (_validationError != null) ...[
          const SizedBox(height: 12),
          AlertLine(
            icon: Icons.error_outline,
            text: _validationError!,
            danger: true,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.gmailImportSelectedTotalLabel(includedCount),
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ),
            Text(
              Money.formatPaise(_draft.effectiveTotalPaise),
              style: NestText.itemTitle16.copyWith(color: c.ink),
            ),
          ],
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.gmailImportDiscardBtn,
              kind: NestButtonKind.dangerGhost,
              size: NestButtonSize.block,
              onPressed: _saving ? null : _onDiscard,
            ),
            NestButton(
              label: _saving
                  ? l10n.gmailImportAccountingBtn
                  : l10n.gmailImportAccountItBtn,
              size: NestButtonSize.block,
              onPressed: _saving ? null : _onAccountIt,
            ),
          ],
        ),
      ],
    );
  }

  String _methodLabel(AppLocalizations l10n, String m) => switch (m) {
    'cash' => l10n.moneyMethodCash,
    'card' => l10n.moneyMethodCard,
    'bank' => l10n.moneyMethodBank,
    _ => l10n.moneyMethodUpi,
  };

  String _memberName(Member m, String? me, AppLocalizations l10n) {
    if (m.id == me) return l10n.moneyYou;
    final first = m.firstName;
    final label = (first != null && first.isNotEmpty)
        ? first
        : (m.fullName ?? '');
    return label;
  }
}

class _DraftItemRow extends StatelessWidget {
  const _DraftItemRow({
    required this.item,
    required this.categories,
    required this.nameCtrl,
    required this.amountCtrl,
    required this.onToggle,
    required this.onAmountChanged,
    required this.onCategoryChanged,
  });

  final DraftExpenseItem item;
  final List<String> categories;
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.paper2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(value: item.included, onChanged: onToggle),
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    enabled: item.included,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    style: NestText.body15.copyWith(color: c.ink),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: amountCtrl,
                    enabled: item.included,
                    textAlign: TextAlign.end,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixText: '₹',
                    ),
                    onChanged: onAmountChanged,
                  ),
                ),
              ],
            ),
            if (item.included) ...[
              const SizedBox(height: 6),
              SpendCategoryPicker(
                value: item.category,
                categories: categories,
                showDots: false,
                onChanged: onCategoryChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
