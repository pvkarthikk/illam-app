import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/receipt/receipt_parser.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/receipt/receipt_ocr_bridge.dart';
import 'package:nm_flat/features/money/bill_scan_state.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

export 'package:nm_flat/features/money/bill_scan_state.dart';

final billScanControllerProvider =
    NotifierProvider<BillScanController, BillScanState>(
      BillScanController.new,
    );

class BillScanController extends Notifier<BillScanState> {
  int _nextItemId = 0;

  @override
  BillScanState build() => const BillScanState();

  String _allocId() => 'scan_item_${_nextItemId++}';

  void start({required String today, required String me}) {
    cleanupTempImage();
    state = BillScanState(
      phase: BillScanPhase.chooseSource,
      date: today,
      paidBy: me,
    );
  }

  void openPasteMode() {
    state = state.copyWith(
      phase: BillScanPhase.chooseSource,
      pasteMode: true,
      clearErrorKind: true,
      clearValidation: true,
    );
  }

  void closePasteMode() {
    state = state.copyWith(pasteMode: false, clearErrorKind: true);
  }

  Future<void> scanFrom(ReceiptImageSource source) async {
    final bridge = ref.read(receiptOcrBridgeProvider);
    state = state.copyWith(clearErrorKind: true, pasteMode: false);
    String? path;
    try {
      path = await bridge.pickOrCaptureImage(source);
    } on ReceiptOcrException catch (e) {
      state = state.copyWith(
        phase: BillScanPhase.chooseSource,
        errorKind: e.kind.name,
      );
      return;
    }
    if (path == null || path.isEmpty) return;

    final prevPath = state.imagePath;
    if (prevPath != null && prevPath != path) {
      unawaited(bridge.deleteTempImage(prevPath));
    }

    state = state.copyWith(
      phase: BillScanPhase.scanning,
      imagePath: path,
      rotationDegrees: 0,
      clearErrorKind: true,
      clearValidation: true,
      clearDuplicate: true,
      duplicateConfirmed: false,
    );
    await _runOcrOnPath(path, rotationDegrees: 0);
  }

  Future<void> rotateAndRescan() async {
    final path = state.imagePath;
    if (path == null || path.isEmpty) return;
    final nextRot = (state.rotationDegrees + 90) % 360;
    state = state.copyWith(
      phase: BillScanPhase.scanning,
      rotationDegrees: nextRot,
      clearErrorKind: true,
      clearValidation: true,
      clearDuplicate: true,
      duplicateConfirmed: false,
    );
    await _runOcrOnPath(path, rotationDegrees: nextRot);
  }

  Future<void> _runOcrOnPath(String path, {required int rotationDegrees}) async {
    final bridge = ref.read(receiptOcrBridgeProvider);
    try {
      final ocr = await bridge.recognizeImage(
        path,
        rotationDegrees: rotationDegrees,
      );
      _applyParsedText(
        ocr.text,
        confidence: ocr.confidence,
        imagePath: path,
        rotationDegrees: rotationDegrees,
      );
    } on ReceiptOcrException catch (e) {
      state = state.copyWith(
        phase: BillScanPhase.chooseSource,
        errorKind: e.kind.name,
      );
    }
  }

  void parsePastedText(String rawText) {
    cleanupTempImage();
    _applyParsedText(
      rawText,
      confidence: 100,
      imagePath: null,
      rotationDegrees: 0,
    );
  }

  void _applyParsedText(
    String rawText, {
    required int confidence,
    required String? imagePath,
    required int rotationDegrees,
  }) {
    final fallbackDate =
        state.date.isNotEmpty ? state.date : ref.read(todayDateProvider);
    final rules =
        ref.read(merchantRulesProvider).value ?? const <String, String>{};
    final parsed = parseReceiptText(
      rawText,
      fallbackDate: fallbackDate,
      merchantRules: rules,
    );

    final items = [
      for (final item in parsed.items)
        EditableBillItem(
          id: _allocId(),
          name: item.name,
          amountPaise: item.amountPaise,
          category: item.category,
        ),
    ];

    state = state.copyWith(
      phase: BillScanPhase.review,
      scanGeneration: state.scanGeneration + 1,
      imagePath: imagePath,
      clearImagePath: imagePath == null,
      rotationDegrees: rotationDegrees,
      rawText: rawText,
      confidence: confidence,
      pasteMode: false,
      showRawOcr: false,
      merchant: parsed.merchant,
      date: parsed.date,
      splitByItem: items.isNotEmpty,
      items: items,
      singleTotalPaise: parsed.totalPaise,
      singleCategory: parsed.defaultCategory,
      parsedBillTotalPaise: parsed.totalPaise,
      errorKind: rawText.trim().isEmpty ? 'noText' : null,
      clearErrorKind: rawText.trim().isNotEmpty,
      clearDuplicate: true,
      duplicateConfirmed: false,
      clearValidation: true,
    );
  }

  void toggleRawOcr() => state = state.copyWith(showRawOcr: !state.showRawOcr);

  void setMerchant(String value) => state = state.copyWith(
    merchant: value,
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void setDate(String isoDate) => state = state.copyWith(
    date: isoDate,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void setMethod(String method) => state = state.copyWith(method: method);

  void setPaidBy(String memberId) => state = state.copyWith(paidBy: memberId);

  void setSplitByItem(bool split) => state = state.copyWith(
    splitByItem: split,
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void setSingleTotalPaise(int paise) => state = state.copyWith(
    singleTotalPaise: paise,
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void setSingleCategory(String category) =>
      state = state.copyWith(singleCategory: category, clearValidation: true);

  void toggleItemIncluded(String id) => state = state.copyWith(
    items: [
      for (final item in state.items)
        if (item.id == id)
          item.copyWith(included: !item.included)
        else
          item,
    ],
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void updateItemName(String id, String name) => state = state.copyWith(
    items: [
      for (final item in state.items)
        if (item.id == id) item.copyWith(name: name) else item,
    ],
    clearValidation: true,
  );

  void updateItemAmount(String id, int paise) => state = state.copyWith(
    items: [
      for (final item in state.items)
        if (item.id == id) item.copyWith(amountPaise: paise) else item,
    ],
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void updateItemCategory(String id, String category) => state = state.copyWith(
    items: [
      for (final item in state.items)
        if (item.id == id) item.copyWith(category: category) else item,
    ],
    clearValidation: true,
  );

  String addEmptyItem() {
    final newId = _allocId();
    final fallbackCat = state.singleCategory.isNotEmpty
        ? state.singleCategory
        : 'Other';
    state = state.copyWith(
      splitByItem: true,
      items: [
        ...state.items,
        EditableBillItem(
          id: newId,
          name: '',
          amountPaise: 0,
          category: fallbackCat,
        ),
      ],
      clearValidation: true,
    );
    return newId;
  }

  void removeItem(String id) => state = state.copyWith(
    items: [
      for (final item in state.items)
        if (item.id != id) item,
    ],
    clearValidation: true,
    clearDuplicate: true,
    duplicateConfirmed: false,
  );

  void confirmDuplicate() =>
      state = state.copyWith(clearDuplicate: true, duplicateConfirmed: true);

  void dismissDuplicate() => state = state.copyWith(clearDuplicate: true);

  void cleanupTempImage() {
    final path = state.imagePath;
    if (path != null && path.isNotEmpty) {
      unawaited(ref.read(receiptOcrBridgeProvider).deleteTempImage(path));
      state = state.copyWith(clearImagePath: true);
    }
  }

  Future<({ChangeResult result, int count, int totalPaise})?> save() async {
    final merchant = state.merchant.trim();
    if (merchant.isEmpty) {
      state = state.copyWith(validationError: 'merchant');
      return null;
    }

    final me = ref.read(myMemberIdProvider);
    final payer = state.paidBy.isEmpty ? me : state.paidBy;
    final entries = <NewExpense>[];
    String? singleLearnCat;

    if (state.splitByItem) {
      final included = state.items.where((e) => e.included).toList();
      if (included.isEmpty) {
        state = state.copyWith(validationError: 'noItems');
        return null;
      }
      for (final item in included) {
        final name = item.name.trim();
        if (name.isEmpty ||
            item.amountPaise <= 0 ||
            item.amountPaise > 100000000) {
          state = state.copyWith(validationError: 'noItems');
          return null;
        }
        entries.add(
          NewExpense(
            amountPaise: item.amountPaise,
            merchant: clampMerchantName('$merchant · $name'),
            category: normalizeSpendCategory(item.category),
            method: state.method,
            date: state.date,
            source: 'manual',
            paidBy: payer,
          ),
        );
      }
    } else {
      if (state.singleTotalPaise <= 0 || state.singleTotalPaise > 100000000) {
        state = state.copyWith(validationError: 'amount');
        return null;
      }
      singleLearnCat = normalizeSpendCategory(state.singleCategory);
      entries.add(
        NewExpense(
          amountPaise: state.singleTotalPaise,
          merchant: clampMerchantName(merchant),
          category: singleLearnCat,
          method: state.method,
          date: state.date,
          source: 'manual',
          paidBy: payer,
        ),
      );
    }

    final totalPaise = entries.fold<int>(0, (acc, e) => acc + e.amountPaise);
    final repo = ref.read(moneyRepoProvider);
    if (!state.duplicateConfirmed) {
      final checkMerchant = entries.length == 1
          ? entries.first.merchant
          : clampMerchantName(merchant);
      final hit = await repo.checkDuplicate(
        amountPaise: totalPaise,
        merchant: checkMerchant,
        date: state.date,
      );
      if (hit != null) {
        state = state.copyWith(duplicateHit: hit, clearValidation: true);
        return null;
      }
    }

    state = state.copyWith(phase: BillScanPhase.saving, clearValidation: true);
    try {
      final res = await repo.addSpendsBatch(
        entries,
        learnMerchant: singleLearnCat != null ? merchant : null,
        learnCategory: singleLearnCat,
      );
      cleanupTempImage();
      return (result: res, count: entries.length, totalPaise: totalPaise);
    } on Object {
      state = state.copyWith(phase: BillScanPhase.review);
      rethrow;
    }
  }
}
