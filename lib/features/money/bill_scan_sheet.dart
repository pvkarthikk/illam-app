import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/receipt/receipt_ocr_bridge.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/money/bill_scan_controller.dart';
import 'package:nm_flat/features/money/bill_scan_parts.dart';
import 'package:nm_flat/features/money/bill_scan_source_views.dart';
import 'package:nm_flat/features/money/widgets/duplicate_hint_box.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Opens the offline camera/gallery/paste bill scanner and itemized review sheet.
Future<void> showBillScanSheet(BuildContext context, WidgetRef ref) async {
  final today = ref.read(todayDateProvider);
  final me = ref.read(myMemberIdProvider);
  final ctrl = ref.read(billScanControllerProvider.notifier);
  ctrl.start(today: today, me: me);
  try {
    await showNestSheet<void>(context, (_) => const BillScanSheet());
  } finally {
    ctrl.cleanupTempImage();
  }
}

class BillScanSheet extends ConsumerStatefulWidget {
  const BillScanSheet({super.key});

  @override
  ConsumerState<BillScanSheet> createState() => _BillScanSheetState();
}

class _BillScanSheetState extends ConsumerState<BillScanSheet> {
  final _merchantCtrl = TextEditingController();
  final _singleAmountCtrl = TextEditingController();
  final _pasteCtrl = TextEditingController();
  final _nameCtrls = <String, TextEditingController>{};
  final _amountCtrls = <String, TextEditingController>{};

  int _syncedGeneration = -1;
  bool _emptyPasteError = false;

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _singleAmountCtrl.dispose();
    _pasteCtrl.dispose();
    for (final ctrl in _nameCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _amountCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String _formatPaiseInput(int paise) {
    if (paise <= 0) return '';
    final rupees = paise ~/ 100;
    final rem = paise % 100;
    return rem == 0 ? '$rupees' : '$rupees.${rem.toString().padLeft(2, '0')}';
  }

  void _syncControllersForState(BillScanState state) {
    if (_syncedGeneration != state.scanGeneration) {
      _syncedGeneration = state.scanGeneration;
      _merchantCtrl.text = state.merchant;
      _singleAmountCtrl.text = _formatPaiseInput(state.singleTotalPaise);
      for (final c in _nameCtrls.values) {
        c.dispose();
      }
      for (final c in _amountCtrls.values) {
        c.dispose();
      }
      _nameCtrls.clear();
      _amountCtrls.clear();
    }

    final liveIds = {for (final item in state.items) item.id};
    final staleIds = [
      for (final id in _nameCtrls.keys)
        if (!liveIds.contains(id)) id,
    ];
    for (final id in staleIds) {
      _nameCtrls.remove(id)?.dispose();
      _amountCtrls.remove(id)?.dispose();
    }
    for (final item in state.items) {
      _nameCtrls.putIfAbsent(
        item.id,
        () => TextEditingController(text: item.name),
      );
      _amountCtrls.putIfAbsent(
        item.id,
        () => TextEditingController(text: _formatPaiseInput(item.amountPaise)),
      );
    }
  }

  Future<void> _saveBill(AppLocalizations l10n) async {
    final ctrl = ref.read(billScanControllerProvider.notifier);
    try {
      final saved = await ctrl.save();
      if (!mounted || saved == null) return;
      final snack = ref.read(snackbarProvider);
      Navigator.of(context).pop();
      snack.show(
        l10n.billScanSavedCount(
          saved.count,
          Money.format(saved.totalPaise),
        ),
        undo: saved.result.undo,
      );
    } on Object {
      if (mounted) {
        ref.read(snackbarProvider).show(rejectText('other'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final state = ref.watch(billScanControllerProvider);
    final ctrl = ref.read(billScanControllerProvider.notifier);
    _syncControllersForState(state);

    if (state.phase == BillScanPhase.chooseSource) {
      final chooserState = _emptyPasteError && state.pasteMode
          ? state.copyWith(errorKind: 'emptyPaste')
          : state;
      return BillScanSourceChooser(
        state: chooserState,
        pasteCtrl: _pasteCtrl,
        onCamera: () => ctrl.scanFrom(ReceiptImageSource.camera),
        onGallery: () => ctrl.scanFrom(ReceiptImageSource.gallery),
        onOpenPaste: () {
          setState(() => _emptyPasteError = false);
          ctrl.openPasteMode();
        },
        onCancelPaste: () {
          setState(() => _emptyPasteError = false);
          ctrl.closePasteMode();
        },
        onExtractPaste: () {
          final raw = _pasteCtrl.text;
          if (raw.trim().isEmpty) {
            setState(() => _emptyPasteError = true);
            return;
          }
          setState(() => _emptyPasteError = false);
          ctrl.parsePastedText(raw);
        },
      );
    }

    if (state.phase == BillScanPhase.scanning) {
      return const BillScanProgressView();
    }

    final today = ref.watch(todayDateProvider);
    final minDate = Dates.monthStart(
      Dates.addMonths(Dates.month(today), -13),
    );
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final activeMembers = [
      for (final m in members)
        if (m.status == 'active') m,
    ];
    final me = ref.watch(myMemberIdProvider);
    final customCategories = ref.watch(customSpendCategoriesProvider);

    final validationMsg = switch (state.validationError) {
      'merchant' => l10n.billScanErrMerchant,
      'noItems' => l10n.billScanErrNoItems,
      'amount' => l10n.billScanErrAmount,
      _ => null,
    };

    final saving = state.phase == BillScanPhase.saving;
    final selectedCount = state.validIncludedItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.billScanReviewTitle),
        if (state.errorKind == 'noText') ...[
          BillScanNoticeBanner(message: l10n.billScanNoTextFound),
          const SizedBox(height: 12),
        ],
        if (state.imagePath != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: NestButton(
              label: l10n.billScanRotateRescan,
              icon: Icons.rotate_right_rounded,
              kind: NestButtonKind.tonal,
              onPressed: saving ? null : ctrl.rotateAndRescan,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _merchantCtrl,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          onChanged: ctrl.setMerchant,
          decoration: InputDecoration(
            labelText: l10n.billScanMerchantLabel,
            hintText: l10n.billScanMerchantHint,
            counterText: '',
            errorText: state.validationError == 'merchant'
                ? l10n.billScanErrMerchant
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            NestChip(
              label: Formatters.dayLabel(state.date, today, l10n),
              selected: true,
              onTap: () async {
                final firstDt = Dates.parse(minDate);
                final lastDt = Dates.parse(today);
                final parsedDt = state.date.isEmpty
                    ? lastDt
                    : Dates.parse(state.date);
                final initialDt = parsedDt.isBefore(firstDt)
                    ? firstDt
                    : (parsedDt.isAfter(lastDt) ? lastDt : parsedDt);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDt,
                  firstDate: firstDt,
                  lastDate: lastDt,
                );
                if (!context.mounted || picked == null) return;
                ctrl.setDate(Dates.iso(picked));
              },
            ),
            for (final m in const ['upi', 'cash', 'card', 'bank'])
              NestChip(
                label: methodLabel(l10n, m),
                selected: state.method == m,
                onTap: () => ctrl.setMethod(m),
              ),
          ],
        ),
        if (activeMembers.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            l10n.moneyPaidBy,
            style: NestText.small12.copyWith(color: c.ink2),
          ),
          const SizedBox(height: 6),
          Wrap(
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
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            NestChip(
              label: l10n.billScanModeSplit(state.items.length),
              selected: state.splitByItem,
              onTap: () => ctrl.setSplitByItem(true),
            ),
            NestChip(
              label: l10n.billScanModeSingle,
              selected: !state.splitByItem,
              onTap: () => ctrl.setSplitByItem(false),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (state.splitByItem) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.billScanItemsTitle,
                  style: NestText.small12.copyWith(color: c.ink2),
                ),
              ),
              TextButton(
                onPressed: saving ? null : ctrl.addEmptyItem,
                child: Text(
                  l10n.billScanAddItem,
                  style: NestText.small12.copyWith(color: c.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in state.items)
            BillScanItemRow(
              key: ValueKey(item.id),
              item: item,
              nameCtrl: _nameCtrls[item.id]!,
              amountCtrl: _amountCtrls[item.id]!,
              onToggleIncluded: () => ctrl.toggleItemIncluded(item.id),
              onNameChanged: (val) => ctrl.updateItemName(item.id, val),
              onAmountChanged: (paise) => ctrl.updateItemAmount(item.id, paise),
              onPickCategory: () async {
                final picked = await pickBillItemCategory(
                  context,
                  currentCategory: item.category,
                  allCategories: customCategories,
                );
                if (!mounted || picked == null) return;
                ctrl.updateItemCategory(item.id, picked);
              },
              onRemove: () => ctrl.removeItem(item.id),
            ),
          if (state.parsedBillTotalPaise > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text(
                l10n.billScanSummaryCompare(
                  Money.format(state.selectedItemsTotalPaise),
                  Money.format(state.parsedBillTotalPaise),
                ),
                style: NestText.small12.copyWith(color: c.ink3),
              ),
            ),
        ] else ...[
          TextField(
            controller: _singleAmountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (raw) =>
                ctrl.setSingleTotalPaise(Money.parseRupees(raw) ?? 0),
            decoration: InputDecoration(
              labelText: l10n.billScanSingleAmountLabel,
              prefixText: '₹ ',
              errorText: state.validationError == 'amount'
                  ? l10n.billScanErrAmount
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.moneyCategory,
            style: NestText.small12.copyWith(color: c.ink2),
          ),
          const SizedBox(height: 6),
          SpendCategoryPicker(
            value: state.singleCategory,
            categories: customCategories,
            onChanged: ctrl.setSingleCategory,
          ),
        ],
        if (validationMsg != null && state.validationError == 'noItems') ...[
          const SizedBox(height: 8),
          Text(
            validationMsg,
            style: NestText.small12.copyWith(color: c.danger),
          ),
        ],
        const SizedBox(height: 8),
        BillScanRawOcrBox(
          rawText: state.rawText,
          confidence: state.confidence,
          expanded: state.showRawOcr,
          onToggle: ctrl.toggleRawOcr,
        ),
        if (state.duplicateHit != null) ...[
          const SizedBox(height: 12),
          DuplicateHintBox(
            hit: state.duplicateHit!,
            onDontAdd: () => Navigator.of(context).pop(),
            onAddAnyway: () {
              ctrl.confirmDuplicate();
              _saveBill(l10n);
            },
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: state.splitByItem
                  ? l10n.billScanSaveCount(selectedCount)
                  : l10n.billScanSaveSingle,
              onPressed: saving ? null : () => _saveBill(l10n),
            ),
          ],
        ),
      ],
    );
  }
}
