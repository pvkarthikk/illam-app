import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/features/sms_import/sms_import_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Opens a one-by-one review bottom sheet for an unapproved [SmsDraftSpend].
Future<void> showSmsDraftReviewSheet(
  BuildContext context,
  WidgetRef ref,
  SmsDraftSpend draft,
) async {
  await showNestSheet<void>(
    context,
    (_) => _SmsDraftReviewSheet(draft: draft),
  );
}

class _SmsDraftReviewSheet extends ConsumerStatefulWidget {
  const _SmsDraftReviewSheet({required this.draft});

  final SmsDraftSpend draft;

  @override
  ConsumerState<_SmsDraftReviewSheet> createState() =>
      _SmsDraftReviewSheetState();
}

class _SmsDraftReviewSheetState extends ConsumerState<_SmsDraftReviewSheet> {
  late TextEditingController _amountCtrl;
  late TextEditingController _merchantCtrl;
  late TextEditingController _noteCtrl;
  late String _category;
  late String _method;
  String? _paidBy;
  DuplicateHit? _ledgerDuplicate;
  DraftExpenseOrder? _gmailOverlap;
  String? _validationError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: _formatRupeeInput(widget.draft.amountPaise),
    );
    _merchantCtrl = TextEditingController(text: widget.draft.merchant);
    _noteCtrl = TextEditingController(text: widget.draft.note ?? '');
    _category = normalizeSpendCategory(widget.draft.category);
    _method = widget.draft.method;
    _paidBy = widget.draft.paidBy;
    _checkOverlaps();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatRupeeInput(int paise) {
    final rupees = paise ~/ 100;
    final rem = paise % 100;
    if (rem == 0) return '$rupees';
    return '$rupees.${rem.toString().padLeft(2, '0')}';
  }

  Future<void> _checkOverlaps() async {
    final hit = await ref
        .read(moneyRepoProvider)
        .checkDuplicate(
          amountPaise: widget.draft.amountPaise,
          merchant: widget.draft.merchant,
          orderChannel: widget.draft.matchedOrderChannel,
          date: widget.draft.date,
        );
    final gmailDrafts = ref.read(gmailDraftOrdersProvider);
    DraftExpenseOrder? overlap;
    for (final gd in gmailDrafts) {
      if (gd.totalPaise != widget.draft.amountPaise) continue;
      if (Dates.daysBetween(widget.draft.date, gd.date).abs() <= 1) {
        overlap = gd;
        break;
      }
    }
    if (!mounted) return;
    if (hit != null || overlap != null) {
      setState(() {
        _ledgerDuplicate = hit;
        _gmailOverlap = overlap;
      });
    }
  }

  Future<void> _onAccountIt() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final parsedPaise = Money.parseRupees(_amountCtrl.text);
    if (parsedPaise == null || parsedPaise <= 0 || parsedPaise > 100000000) {
      setState(() => _validationError = l10n.smsImportErrAmount);
      return;
    }
    final merchant = _merchantCtrl.text.trim();
    if (merchant.isEmpty) {
      setState(() => _validationError = l10n.smsImportErrMerchant);
      return;
    }
    if (_category.trim().isEmpty) {
      setState(() => _validationError = l10n.moneyErrCategory);
      return;
    }

    setState(() {
      _validationError = null;
      _saving = true;
    });

    final note = _noteCtrl.text.trim();
    final category = normalizeSpendCategory(_category);
    final updated = widget.draft.copyWith(
      amountPaise: parsedPaise,
      merchant: clampMerchantName(merchant),
      category: category,
      method: _method,
      paidBy: _paidBy ?? ref.read(myMemberIdProvider),
      note: note,
      clearNote: note.isEmpty,
    );

    try {
      final res = await ref
          .read(smsImportControllerProvider.notifier)
          .accountDraft(
            updated,
            learnCategory: category != widget.draft.category,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (res != null) {
        ref
            .read(snackbarProvider)
            .show(
              l10n.smsImportAccountedSnack(
                res.merchant,
                Money.formatPaise(res.amountPaise),
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
        .read(smsImportControllerProvider.notifier)
        .discardDraft(widget.draft.id);
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
    final selectedPayer = _paidBy ?? me;

    final whenLabel = Formatters.dayLabel(widget.draft.date, today, l10n);
    final accountLabel = widget.draft.accountLabel();
    final lead = accountLabel == null
        ? whenLabel
        : l10n.smsImportAccountMeta(accountLabel, whenLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NestSheetHeader(
                title: l10n.smsImportReviewTitle,
                lead: lead,
              ),
            ),
            Wrap(
              spacing: 6,
              children: [
                NestTag(
                  label: l10n.gmailImportDraftBadge,
                  kind: NestTagKind.accent,
                ),
                NestTag(
                  label: l10n.smsImportTagLabel,
                  kind: NestTagKind.info,
                ),
              ],
            ),
          ],
        ),
        if (_ledgerDuplicate != null) ...[
          AlertLine(
            icon: Icons.warning_amber_rounded,
            text: l10n.gmailImportDuplicateWarning(
              Formatters.dayLabel(_ledgerDuplicate!.date, today, l10n),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (_gmailOverlap != null) ...[
          AlertLine(
            icon: Icons.receipt_long_outlined,
            text: l10n.smsImportGmailOverlapWarning(
              _gmailOverlap!.channel.displayName,
              Formatters.dayLabel(_gmailOverlap!.date, today, l10n),
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            labelText: l10n.moneyAmountLabel,
            prefixText: '₹ ',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _merchantCtrl,
          maxLength: 60,
          decoration: InputDecoration(
            labelText: l10n.moneyPaidTo,
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.moneyCategory,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        const SizedBox(height: 6),
        SpendCategoryPicker(
          value: _category,
          categories: ref.watch(customSpendCategoriesProvider),
          onChanged: (cat) => setState(() {
            _category = cat;
            _validationError = null;
          }),
        ),
        const SizedBox(height: 12),
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
                selected: _method == m,
                onTap: () => setState(() => _method = m),
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
                  onTap: () => setState(() => _paidBy = member.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(labelText: l10n.moneyNote),
        ),
        if (widget.draft.rawSnippet.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.paper2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.smsImportRawLabel,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.draft.rawSnippet,
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
        ],
        if (_validationError != null) ...[
          const SizedBox(height: 10),
          AlertLine(
            icon: Icons.error_outline,
            text: _validationError!,
            danger: true,
          ),
        ],
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
    return (first != null && first.isNotEmpty) ? first : (m.fullName ?? '');
  }
}
