import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/money/spend_sheet_controller.dart';
import 'package:nm_flat/features/money/widgets/duplicate_hint_box.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showSpendSheet(
  BuildContext context,
  WidgetRef ref, {
  ExpenseRow? existing,
}) async {
  final today = ref.read(todayDateProvider);
  final me = ref.read(myMemberIdProvider);

  if (existing != null && existing.source == 'salary') {
    await showNestSheet<void>(
      context,
      (_) => _LockedSpendSheet.salary(existing: existing, today: today),
    );
    return;
  }

  if (existing != null &&
      existing.addedBy != me &&
      !ref.read(isAdminProvider)) {
    await showNestSheet<void>(
      context,
      (_) => _LockedSpendSheet.readOnly(existing: existing, today: today),
    );
    return;
  }

  ref
      .read(spendSheetControllerProvider.notifier)
      .start(existing: existing, today: today, me: me);
  await showNestSheet<void>(context, (_) => SpendSheet(existing: existing));
}

class _LockedSpendSheet extends ConsumerWidget {
  const _LockedSpendSheet.salary({
    required this.existing,
    required this.today,
  }) : _isSalary = true;

  const _LockedSpendSheet.readOnly({
    required this.existing,
    required this.today,
  }) : _isSalary = false;

  final ExpenseRow existing;
  final String today;
  final bool _isSalary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final summary = [
      Money.format(existing.amountPaise),
      Formatters.dayLabel(existing.date, today, l10n),
      methodLabel(l10n, existing.method),
    ].join(' · ');

    if (_isSalary) {
      final active = ref.watch(activeStaffProvider).value ?? const [];
      final former = ref.watch(formerStaffProvider).value ?? const [];
      final staffId = existing.staffId ?? '';
      var staffName = existing.merchant;
      for (final s in [...active, ...former]) {
        if (s.id == staffId) {
          staffName = s.name ?? staffName;
          break;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(title: existing.merchant, lead: summary),
          Text(
            l10n.moneySalaryManaged(staffName),
            style: NestText.body15.copyWith(color: c.ink2),
          ),
          if (staffId.isNotEmpty) ...[
            const SizedBox(height: 16),
            NestButton(
              label: l10n.moneyOpenSalary,
              kind: NestButtonKind.tonal,
              size: NestButtonSize.block,
              onPressed: () {
                Navigator.of(context).pop();
                context.push(Routes.staffSalary(staffId));
              },
            ),
          ],
        ],
      );
    }

    final members = ref.watch(membersProvider).value ?? const <Member>[];
    var ownerName = existing.addedBy;
    for (final m in members) {
      if (m.id == existing.addedBy) {
        final first = m.firstName;
        ownerName = (first != null && first.isNotEmpty)
            ? first
            : (m.fullName ?? ownerName);
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: existing.merchant, lead: summary),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 20, color: c.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.moneyReadOnly(ownerName),
                style: NestText.body15.copyWith(color: c.ink2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpendSheet extends ConsumerStatefulWidget {
  const SpendSheet({super.key, this.existing});

  final ExpenseRow? existing;

  @override
  ConsumerState<SpendSheet> createState() => _SpendSheetState();
}

class _SpendSheetState extends ConsumerState<SpendSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _noteCtrl;
  final _amountFocus = FocusNode();
  final _merchantFocus = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(
      text: e == null || e.amountPaise <= 0
          ? ''
          : (e.amountPaise % 100 == 0
                ? '${e.amountPaise ~/ 100}'
                : (e.amountPaise / 100).toStringAsFixed(2)),
    );
    _merchantCtrl = TextEditingController(text: e?.merchant ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    _merchantFocus.dispose();
    super.dispose();
  }

  Future<void> _save(
    AppLocalizations l10n,
    Map<String, String> rules,
  ) async {
    if (_saving) return;
    setState(() => _saving = true);
    var closed = false;
    try {
      final ctrl = ref.read(spendSheetControllerProvider.notifier);
      final amountText = _amountCtrl.text;
      final merchantText = _merchantCtrl.text;
      final noteText = _noteCtrl.text;
      final kind = await ctrl.check(
        amountText: amountText,
        merchant: merchantText,
        rules: rules,
      );
      if (!mounted) return;
      final state = ref.read(spendSheetControllerProvider);

      switch (kind) {
        case SpendSaveKind.invalid:
          if (state.amountError != null) {
            _amountFocus.requestFocus();
          } else if (state.merchantError != null) {
            _merchantFocus.requestFocus();
          }
          return;
        case SpendSaveKind.duplicate:
          FocusScope.of(context).unfocus();
          return;
        case SpendSaveKind.added:
        case SpendSaveKind.addedBill:
        case SpendSaveKind.learned:
        case SpendSaveKind.updated:
          final paise = Money.parseRupees(amountText) ?? 0;
          final merchant = merchantText.trim();
          final msg = switch (kind) {
            SpendSaveKind.added => l10n.moneyAdded(Money.format(paise)),
            SpendSaveKind.addedBill => l10n.moneyAddedBill(
              Money.format(paise),
              merchant,
            ),
            SpendSaveKind.learned => l10n.moneyLearned(
              merchant,
              normalizeSpendCategory(state.category),
            ),
            SpendSaveKind.updated => l10n.moneySpendUpdated,
            _ => '',
          };
          final snack = ref.read(snackbarProvider);
          closed = true;
          Navigator.of(context).pop();
          try {
            final res = await ctrl.write(
              amountText: amountText,
              merchant: merchantText,
              rules: rules,
              note: noteText,
            );
            snack.show(msg, undo: res.undo);
          } on Object {
            snack.show(rejectText('other'));
          }
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AppLocalizations l10n, ExpenseRow existing) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final res = await ref
          .read(moneyRepoProvider)
          .deleteSpend(existing.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(l10n.moneySpendDeleted, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final state = ref.watch(spendSheetControllerProvider);
    final ctrl = ref.read(spendSheetControllerProvider.notifier);
    final rules = ref.watch(merchantRulesProvider).value ?? const {};
    final today = ref.watch(todayDateProvider);
    final yesterday = Dates.addDays(today, -1);
    final minDate = Dates.monthStart(
      Dates.addMonths(Dates.month(today), -13),
    );
    final isNew = widget.existing == null;

    final recentRows =
        ref.watch(recentSpendsProvider).value ?? const <ExpenseRow>[];
    final suggestions = isNew
        ? ref.watch(spendSuggestionsProvider)
        : const <String>[];

    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final activeMembers = [
      for (final m in members)
        if (m.status == 'active') m,
    ];
    final me = ref.watch(myMemberIdProvider);

    final amtError = state.amountError == 'moneyErrAmount'
        ? l10n.moneyErrAmount
        : null;
    final merchError = state.merchantError == 'moneyErrMerchant'
        ? l10n.moneyErrMerchant
        : null;
    final catError = state.categoryError == 'moneyErrCategory'
        ? l10n.moneyErrCategory
        : null;
    final isOtherDay = state.date != today && state.date != yesterday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: isNew ? l10n.moneyAddSpendTitle : l10n.moneyEditSpendTitle,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, right: 8),
              child: Text(
                '₹',
                style: NestText.display30.copyWith(color: c.ink2),
              ),
            ),
            Expanded(
              child: Semantics(
                label: l10n.moneyAmountLabel,
                child: TextField(
                  controller: _amountCtrl,
                  focusNode: _amountFocus,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: NestText.bigNumber54.copyWith(
                    fontSize: 40,
                    color: c.ink,
                  ),
                  onChanged: (_) => ctrl.clearAmountError(),
                  decoration: InputDecoration(
                    hintText: '0',
                    errorText: amtError,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _merchantCtrl,
          focusNode: _merchantFocus,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (text) => ctrl.merchantTyped(text, rules),
          decoration: InputDecoration(
            labelText: l10n.moneyPaidTo,
            counterText: '',
            errorText: merchError,
          ),
        ),
        if (isNew && suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final name in suggestions)
                NestChip(
                  label: name,
                  selected: state.merchant.isNotEmpty &&
                      merchantKey(state.merchant) == merchantKey(name),
                  onTap: () {
                    String? lastMethod;
                    final targetKey = merchantKey(name);
                    for (final r in recentRows) {
                      if (r.merchantKey == targetKey) {
                        lastMethod = r.method;
                        break;
                      }
                    }
                    _merchantCtrl.text = name;
                    _merchantCtrl.selection = TextSelection.collapsed(
                      offset: name.length,
                    );
                    ctrl.pickMerchant(name, rules, lastMethod);
                    if (_amountCtrl.text.trim().isEmpty) {
                      _amountFocus.requestFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.moneyCategory,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        SpendCategoryPicker(
          value: state.category,
          categories: ref.watch(customSpendCategoriesProvider),
          errorText: catError,
          onChanged: ctrl.pickCategory,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.moneyPaidWith,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final m in const ['upi', 'cash', 'card', 'bank'])
              NestChip(
                label: methodLabel(l10n, m),
                selected: state.method == m,
                onTap: () => ctrl.setMethod(m),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.moneyWhen,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: l10n.moneyToday,
              selected: state.date == today,
              onTap: () => ctrl.setDate(today),
            ),
            NestChip(
              label: l10n.moneyYesterday,
              selected: state.date == yesterday,
              onTap: () => ctrl.setDate(yesterday),
            ),
            NestChip(
              label: isOtherDay
                  ? Formatters.dayLabel(state.date, today, l10n)
                  : l10n.moneyOtherDay,
              selected: isOtherDay,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: Dates.parse(state.date),
                  firstDate: Dates.parse(minDate),
                  lastDate: Dates.parse(today),
                );
                if (!context.mounted || picked == null) return;
                ctrl.setDate(Dates.iso(picked));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Text(
            l10n.moneyMore,
            style: NestText.meta13.copyWith(color: c.ink2),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.moneyPaidBy,
                style: NestText.small12.copyWith(color: c.ink2),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final m in activeMembers)
                    NestChip(
                      label: m.id == me
                          ? l10n.moneyYou
                          : (m.firstName ?? m.fullName ?? ''),
                      selected: state.paidBy == m.id,
                      onTap: () => ctrl.setPaidBy(m.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.moneyNote,
                counterText: '',
              ),
            ),
            if (isNew) ...[
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: ctrl.toggleRepeat,
                child: Row(
                  children: [
                    NestCheckbox(
                      value: state.repeat,
                      semanticLabel: l10n.moneyRepeat,
                      onChanged: (_) => ctrl.toggleRepeat(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.moneyRepeat,
                        style: NestText.body15.copyWith(color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (state.dup != null) ...[
          const SizedBox(height: 12),
          DuplicateHintBox(
            hit: state.dup!,
            onDontAdd: () => Navigator.of(context).pop(),
            onAddAnyway: () {
              ctrl.confirmDuplicate();
              _save(l10n, rules);
            },
          ),
        ],
        NestSheetActions(
          children: [
            if (!isNew)
              NestButton(
                label: l10n.moneyDelete,
                kind: NestButtonKind.dangerGhost,
                onPressed: _saving
                    ? null
                    : () => _delete(l10n, widget.existing!),
              ),
            NestButton(
              label: isNew ? l10n.moneySave : l10n.moneySaveChanges,
              kind: NestButtonKind.primary,
              onPressed: _saving ? null : () => _save(l10n, rules),
            ),
          ],
        ),
      ],
    );
  }
}
