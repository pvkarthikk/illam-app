import 'package:nm_flat/core/data/repo/money_repo.dart';

enum BillScanPhase { chooseSource, scanning, review, saving }

class EditableBillItem {
  const EditableBillItem({
    required this.id,
    required this.name,
    required this.amountPaise,
    required this.category,
    this.included = true,
  });

  final String id;
  final String name;
  final int amountPaise;
  final String category;
  final bool included;

  EditableBillItem copyWith({
    String? name,
    int? amountPaise,
    String? category,
    bool? included,
  }) => EditableBillItem(
    id: id,
    name: name ?? this.name,
    amountPaise: amountPaise ?? this.amountPaise,
    category: category ?? this.category,
    included: included ?? this.included,
  );
}

class BillScanState {
  const BillScanState({
    this.phase = BillScanPhase.chooseSource,
    this.scanGeneration = 0,
    this.imagePath,
    this.rotationDegrees = 0,
    this.rawText = '',
    this.confidence = 0,
    this.errorKind,
    this.pasteMode = false,
    this.showRawOcr = false,
    this.merchant = '',
    this.date = '',
    this.method = 'upi',
    this.paidBy = '',
    this.splitByItem = false,
    this.items = const [],
    this.singleTotalPaise = 0,
    this.singleCategory = 'Other',
    this.parsedBillTotalPaise = 0,
    this.duplicateHit,
    this.duplicateConfirmed = false,
    this.validationError,
  });

  final BillScanPhase phase;
  final int scanGeneration;
  final String? imagePath;
  final int rotationDegrees;
  final String rawText;
  final int confidence;
  final String? errorKind;
  final bool pasteMode;
  final bool showRawOcr;
  final String merchant;
  final String date;
  final String method;
  final String paidBy;
  final bool splitByItem;
  final List<EditableBillItem> items;
  final int singleTotalPaise;
  final String singleCategory;
  final int parsedBillTotalPaise;
  final DuplicateHit? duplicateHit;
  final bool duplicateConfirmed;
  final String? validationError;

  List<EditableBillItem> get validIncludedItems => [
    for (final item in items)
      if (item.included &&
          item.name.trim().isNotEmpty &&
          item.amountPaise > 0 &&
          item.amountPaise <= 100000000)
        item,
  ];

  int get selectedItemsTotalPaise => validIncludedItems.fold<int>(
    0,
    (acc, item) => acc + item.amountPaise,
  );

  int get effectiveTotalPaise =>
      splitByItem ? selectedItemsTotalPaise : singleTotalPaise;

  BillScanState copyWith({
    BillScanPhase? phase,
    int? scanGeneration,
    String? imagePath,
    bool clearImagePath = false,
    int? rotationDegrees,
    String? rawText,
    int? confidence,
    String? errorKind,
    bool clearErrorKind = false,
    bool? pasteMode,
    bool? showRawOcr,
    String? merchant,
    String? date,
    String? method,
    String? paidBy,
    bool? splitByItem,
    List<EditableBillItem>? items,
    int? singleTotalPaise,
    String? singleCategory,
    int? parsedBillTotalPaise,
    DuplicateHit? duplicateHit,
    bool clearDuplicate = false,
    bool? duplicateConfirmed,
    String? validationError,
    bool clearValidation = false,
  }) => BillScanState(
    phase: phase ?? this.phase,
    scanGeneration: scanGeneration ?? this.scanGeneration,
    imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    rawText: rawText ?? this.rawText,
    confidence: confidence ?? this.confidence,
    errorKind: clearErrorKind ? null : (errorKind ?? this.errorKind),
    pasteMode: pasteMode ?? this.pasteMode,
    showRawOcr: showRawOcr ?? this.showRawOcr,
    merchant: merchant ?? this.merchant,
    date: date ?? this.date,
    method: method ?? this.method,
    paidBy: paidBy ?? this.paidBy,
    splitByItem: splitByItem ?? this.splitByItem,
    items: items ?? this.items,
    singleTotalPaise: singleTotalPaise ?? this.singleTotalPaise,
    singleCategory: singleCategory ?? this.singleCategory,
    parsedBillTotalPaise: parsedBillTotalPaise ?? this.parsedBillTotalPaise,
    duplicateHit:
        clearDuplicate ? null : (duplicateHit ?? this.duplicateHit),
    duplicateConfirmed: duplicateConfirmed ?? this.duplicateConfirmed,
    validationError:
        clearValidation ? null : (validationError ?? this.validationError),
  );
}
