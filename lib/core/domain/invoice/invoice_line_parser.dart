import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';

/// Shared pure helpers for extracting money, dates, order IDs, and rows
/// from retail email lines and PDFBox invoice text.
final currencyAmountRegex = RegExp(
  r'(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final trailingNumberRegex = RegExp(
  r'(?:^|\s)([0-9]{1,3}(?:,[0-9]{2,3})*\.\d{2}|[0-9]+\.\d{2})(?=\s|$)',
);

final _hsnPercentRegex = RegExp(r'%$');

/// Extracts all candidate positive paise amounts appearing on [line].
List<int> extractAmountsOnLine(String line) {
  final out = <int>[];
  for (final m in currencyAmountRegex.allMatches(line)) {
    final p = parseRupeeAmount(m.group(1)!);
    if (p != null && p > 0) out.add(p);
  }
  if (out.isNotEmpty) return out;

  // PDF tax invoices often omit currency symbols in numeric columns (`145.00`).
  for (final token in line.split(RegExp(r'\s+|\|'))) {
    final clean = token.trim();
    if (clean.isEmpty || _hsnPercentRegex.hasMatch(clean)) continue;
    if (RegExp(r'^[0-9][0-9,]*\.\d{2}$').hasMatch(clean)) {
      final p = parseRupeeAmount(clean);
      if (p != null && p > 0) out.add(p);
    }
  }
  return out;
}

/// Extracts the final positive amount on a pipe-separated or numeric row.
int? extractRowTotalPaise(String line) {
  if (line.contains('|')) {
    final cells = line.split('|').map((c) => c.trim()).toList();
    for (var i = cells.length - 1; i >= 0; i--) {
      final cell = cells[i];
      if (cell.contains('%')) continue;
      final explicit = currencyAmountRegex.allMatches(cell).toList();
      if (explicit.isNotEmpty) {
        final p = parseRupeeAmount(explicit.last.group(1)!);
        if (p != null && p > 0) return p;
      }
      if (RegExp(r'^[0-9][0-9,]*(\.\d{1,2})?$').hasMatch(cell)) {
        final p = parseRupeeAmount(cell);
        if (p != null && p > 0) return p;
      }
    }
  }

  final explicit = currencyAmountRegex.allMatches(line).toList();
  if (explicit.isNotEmpty) {
    return parseRupeeAmount(explicit.last.group(1)!);
  }

  final decimalMatches = trailingNumberRegex.allMatches(line).toList();
  if (decimalMatches.isNotEmpty) {
    return parseRupeeAmount(decimalMatches.last.group(1)!);
  }
  return null;
}

/// Removes trailing prices, HSN codes, tax rates, and leading serial numbers.
String cleanProductDescription(String raw) {
  var s = raw.trim();
  if (RegExp(
    r'^(?:₹|Rs\.?|INR)?\s*[0-9][0-9,]*(?:\.\d{1,2})?$',
    caseSensitive: false,
  ).hasMatch(s)) {
    return '';
  }
  // Take leftmost descriptive segment when parsed from `|` table cells.
  if (s.contains('|')) {
    final cells = s
        .split('|')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    s = _pickDescriptionCell(cells);
  } else {
    // Strip trailing tabular numbers (`1  140.00  5%  147.00` / `Qty: 1  ₹299`).
    s = s.replaceAll(
      RegExp(
        r'\s+(?:Qty\s*[:=]?\s*\d+|x\s*\d+)\s*.*$',
        caseSensitive: false,
      ),
      '',
    );
    s = s.replaceAll(
      RegExp(
        r'(?:\s+(?:₹|Rs\.?|INR)?\s*[0-9][0-9,]*(?:\.\d{1,2})?%?(?:\s+(?:IGST|CGST|SGST))?)+\s*$',
        caseSensitive: false,
      ),
      '',
    );
  }

  // Strip leading serial index (`1.`, `1)`, `01 `).
  s = s.replaceFirst(RegExp(r'^\d{1,2}[.)]\s+'), '');
  if (RegExp(r'^\d{1,2}\s+[A-Za-z]').hasMatch(s)) {
    s = s.replaceFirst(RegExp(r'^\d{1,2}\s+'), '');
  }
  // Strip trailing HSN code (`HSN: 123456` or bare 6-8 digit code).
  s = s.replaceAll(
    RegExp(r'\(?\bHSN\s*[:#-]?\s*\d{4,8}\)?', caseSensitive: false),
    '',
  );
  s = s.replaceAll(RegExp(r'\s+\b\d{6,8}\b\s*$'), '');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

String _pickDescriptionCell(List<String> cells) {
  for (final cell in cells) {
    if (RegExp(r'^\d{1,3}[.)]?$').hasMatch(cell)) continue;
    if (RegExp(r'^\d{4,8}$').hasMatch(cell)) continue;
    if (currencyAmountRegex.hasMatch(cell) &&
        cell.replaceAll(currencyAmountRegex, '').trim().isEmpty) {
      continue;
    }
    if (RegExp(r'^[0-9.,%\s]+$').hasMatch(cell)) continue;
    if (RegExp(r'^(?:Qty|Quantity)\b', caseSensitive: false).hasMatch(cell)) {
      continue;
    }
    return cell;
  }
  return cells.isEmpty ? '' : cells.first;
}

/// Extracts an integer item quantity from [line], defaulting to `1`.
int extractLineQuantity(String line) {
  final qtyLabeled = RegExp(
    r'\b(?:qty|quantity)\s*[:=\-]?\s*(\d{1,3})\b',
    caseSensitive: false,
  ).firstMatch(line);
  if (qtyLabeled != null) {
    final q = int.tryParse(qtyLabeled.group(1)!);
    if (q != null && q >= 1 && q <= 99) return q;
  }

  final timesLeft = RegExp(
    r'\b(\d{1,2})\s*[xX×]\s*(?:₹|Rs\.?|INR)?\s*\d',
  ).firstMatch(line);
  if (timesLeft != null) {
    final q = int.tryParse(timesLeft.group(1)!);
    if (q != null && q >= 1 && q <= 99) return q;
  }

  final timesRight = RegExp(
    r'\s[xX×]\s*(\d{1,2})\b',
  ).firstMatch(line);
  if (timesRight != null) {
    final q = int.tryParse(timesRight.group(1)!);
    if (q != null && q >= 1 && q <= 99) return q;
  }

  if (line.contains('|')) {
    for (final cell in line.split('|').map((c) => c.trim())) {
      if (RegExp(r'^\d{1,2}$').hasMatch(cell)) {
        final q = int.tryParse(cell);
        if (q != null && q >= 1 && q <= 99) return q;
      }
    }
  }

  final colQty = RegExp(
    r'\s(\d{1,2})\s+(?:₹|Rs\.?|INR)?\s*[0-9][0-9,]*\.\d{2}',
  ).firstMatch(line);
  if (colQty != null) {
    final q = int.tryParse(colQty.group(1)!);
    if (q != null && q >= 1 && q <= 99) return q;
  }
  return 1;
}

/// Classifies summary/metadata lines so they are never treated as items.
enum SummaryLineKind {
  grandTotal,
  subtotal,
  fee,
  discount,
  taxOnly,
  headerOrNoise,
}

SummaryLineKind? classifySummaryLine(String line) {
  final lower = line.toLowerCase();
  if (_matchesAny(lower, _grandTotalLabels)) return SummaryLineKind.grandTotal;
  if (_matchesAny(lower, _subtotalLabels)) return SummaryLineKind.subtotal;
  if (_matchesAny(lower, _feeLabels)) return SummaryLineKind.fee;
  if (_matchesAny(lower, _discountLabels)) return SummaryLineKind.discount;
  if (_matchesAny(lower, _taxOnlyLabels)) return SummaryLineKind.taxOnly;
  if (_matchesAny(lower, _noiseLineLabels)) return SummaryLineKind.headerOrNoise;
  return null;
}

bool _matchesAny(String lower, List<String> needles) {
  for (final needle in needles) {
    if (lower.contains(needle)) return true;
  }
  return false;
}

const _grandTotalLabels = [
  'grand total',
  'order total',
  'total paid',
  'amount paid',
  'bill total',
  'net payable',
  'total payable',
  'to pay',
  'you paid',
  'total amount payable',
  'invoice total',
  'invoice value',
  'total invoice value',
  'final total',
  'total amount:',
  'total amount |',
  'total rs.',
];

const _subtotalLabels = [
  'item total',
  'items total',
  'item subtotal',
  'items subtotal',
  'subtotal',
  'sub total',
  'sub-total',
  'gross total',
  'mrp total',
  'taxable total',
  'total mrp',
  'total price',
  'total value',
];

const _feeLabels = [
  'delivery fee',
  'delivery charge',
  'delivery charges',
  'handling fee',
  'handling charge',
  'handling charges',
  'platform fee',
  'small cart fee',
  'small cart charge',
  'rain fee',
  'surge fee',
  'late night fee',
  'packaging fee',
  'packing charge',
  'shipping & handling',
  'shipping and handling',
  'shipping fee',
  'shipping charge',
  'shipping charges',
  'convenience fee',
  'cod fee',
  'payment handling fee',
  'marketplace fee',
  'offer handling',
];

const _discountLabels = [
  'discount',
  'coupon',
  'promo',
  'promotion applied',
  'instant savings',
  'total savings',
  'you saved',
  'zepto cash',
  'wallet applied',
  'supercash',
  'gift card',
  'voucher',
  'cashback',
  'bank offer',
  'freebie',
];

const _taxOnlyLabels = [
  'total tax',
  'cgst',
  'sgst',
  'igst',
  'gst total',
  'round off',
  'rounding off',
];

const _noiseLineLabels = [
  'billed to',
  'billing address',
  'shipping address',
  'delivery address',
  'ship to',
  'bill to',
  'tax invoice',
  'order id',
  'order number',
  'order #',
  'invoice number',
  'invoice no',
  'invoice date',
  'order date',
  'pan:',
  'gstin',
  'cin:',
  'fssai',
  'hsn code',
  'description |',
  'particulars |',
  'item |',
  'product |',
  'product name |',
  'qty |',
  'sl. no',
  'sl no',
  'sr. no',
  'sr no',
  'unit price',
  'tax rate',
  'tax type',
  'tax amount',
  'net amount',
  'place of supply',
  'state/ut code',
  'payment method',
  'payment mode',
  'transaction id',
  'paid via',
  'powered by',
  'authorised signatory',
  'authorized signatory',
  'whether tax is payable',
  'reverse charge',
  'terms and conditions',
  'customer care',
  'helpline',
  'arriving ',
  'delivered on',
  'estimated delivery',
];
