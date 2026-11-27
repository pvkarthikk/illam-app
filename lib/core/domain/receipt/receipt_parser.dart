import 'package:nm_flat/core/domain/invoice/invoice_line_parser.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/receipt/receipt_keywords.dart';
import 'package:nm_flat/core/domain/spend_category.dart';

/// One line item extracted from OCR or pasted paper receipt text.
class ParsedReceiptItem {
  const ParsedReceiptItem({
    required this.name,
    required this.amountPaise,
    required this.category,
    this.quantity = 1,
  });

  final String name;
  final int amountPaise;
  final String category;
  final int quantity;
}

/// Structured summary extracted offline from receipt OCR text.
class ParsedReceipt {
  const ParsedReceipt({
    required this.merchant,
    required this.date,
    required this.items,
    required this.totalPaise,
    required this.rawText,
    this.subtotalPaise = 0,
    this.taxPaise = 0,
    this.defaultCategory = 'Other',
  });

  final String merchant;
  final String date;
  final List<ParsedReceiptItem> items;
  final int totalPaise;
  final int subtotalPaise;
  final int taxPaise;
  final String defaultCategory;
  final String rawText;
}

/// Parses offline OCR or pasted paper bill text into merchant, date, items,
/// and total amount.
ParsedReceipt parseReceiptText(
  String rawText, {
  required String fallbackDate,
  Map<String, String> merchantRules = const {},
}) {
  final normalizedLines = _prepareReceiptLines(rawText);
  if (normalizedLines.isEmpty) {
    return ParsedReceipt(
      merchant: '',
      date: fallbackDate,
      items: const [],
      totalPaise: 0,
      rawText: rawText,
    );
  }

  final merchant = _extractMerchant(normalizedLines);
  final date = _extractReceiptDate(normalizedLines) ?? fallbackDate;
  final merchantDefault = guessSpendCategory(merchant, merchantRules);
  final fallbackCategory = merchantDefault == 'Other'
      ? inferWholeReceiptCategory(normalizedLines)
      : merchantDefault;

  final items = <ParsedReceiptItem>[];
  int? grandTotal;
  int? looseTotal;
  int? subtotal;
  var taxPaise = 0;
  var pendingDescription = '';

  for (final line in normalizedLines) {
    final summary = classifyReceiptSummary(line);
    if (summary != null) {
      pendingDescription = '';
      final amt = _extractSummaryAmountPaise(line);
      switch (summary) {
        case ReceiptLineKind.grandTotal:
          if (amt != null && amt > 0) grandTotal = amt;
        case ReceiptLineKind.looseTotal:
          if (amt != null && amt > 0) looseTotal = amt;
        case ReceiptLineKind.subtotal:
          if (amt != null && amt > 0) subtotal = amt;
        case ReceiptLineKind.taxOrRoundOff:
          if (amt != null && amt > 0 && !isRoundOffLine(line)) {
            taxPaise += amt;
          }
        case ReceiptLineKind.paymentOrNoise:
          break;
      }
      continue;
    }

    final qtyPriceMatch = _qtyMultiplierLineRegex.firstMatch(line);
    if (qtyPriceMatch != null && pendingDescription.isNotEmpty) {
      final qty = int.tryParse(qtyPriceMatch.group(1)!) ?? 1;
      final amt = parseRupeeAmount(
        qtyPriceMatch.group(3) ?? qtyPriceMatch.group(2)!,
      );
      if (amt != null && amt > 0 && amt <= _maxReceiptPaise) {
        items.add(
          ParsedReceiptItem(
            name: _cleanItemName(pendingDescription),
            amountPaise: amt,
            quantity: qty.clamp(1, 99),
            category: inferReceiptItemCategory(
              pendingDescription,
              fallbackCategory,
            ),
          ),
        );
      }
      pendingDescription = '';
      continue;
    }

    final rowAmt = _extractReceiptRowAmountPaise(line);
    if (rowAmt != null && rowAmt > 0 && rowAmt <= _maxReceiptPaise) {
      var name = _cleanItemName(line);
      if (name.isEmpty && pendingDescription.isNotEmpty) {
        name = _cleanItemName(pendingDescription);
      }
      pendingDescription = '';
      if (_isPlausibleItemName(name)) {
        final qty = extractLineQuantity(line);
        items.add(
          ParsedReceiptItem(
            name: name,
            amountPaise: rowAmt,
            quantity: qty,
            category: inferReceiptItemCategory(name, fallbackCategory),
          ),
        );
      }
      continue;
    }

    pendingDescription = _looksLikeItemTextOnlyLine(line) ? line : '';
  }

  final itemsSum = items.fold<int>(0, (acc, e) => acc + e.amountPaise);
  final resolvedTotal = grandTotal ??
      looseTotal ??
      (itemsSum > 0
          ? itemsSum
          : ((subtotal ?? 0) > 0 ? (subtotal ?? 0) + taxPaise : 0));

  var resolvedDefaultCategory = fallbackCategory;
  if (resolvedDefaultCategory == 'Other' && items.isNotEmpty) {
    resolvedDefaultCategory = _dominantCategory(items);
  }

  return ParsedReceipt(
    merchant: merchant,
    date: date,
    items: items,
    totalPaise: resolvedTotal,
    subtotalPaise: subtotal ?? itemsSum,
    taxPaise: taxPaise,
    defaultCategory: normalizeSpendCategory(resolvedDefaultCategory),
    rawText: rawText,
  );
}

const int _maxReceiptPaise = 100000000;

final _qtyMultiplierLineRegex = RegExp(
  r'^(?:qty\s*[:=]?\s*)?(\d{1,2})\s*[xX*×]\s*(?:₹|Rs\.?|INR)?\s*([0-9][0-9,]*(?:\.\d{1,2})?)(?:\s+(?:₹|Rs\.?|INR)?\s*([0-9][0-9,]*(?:\.\d{1,2})?))?\s*[A-Za-z*#]?$',
  caseSensitive: false,
);

List<String> _prepareReceiptLines(String rawText) {
  final out = <String>[];
  for (final rawLine in rawText.split(RegExp(r'\r?\n'))) {
    var line = rawLine.trim();
    if (line.isEmpty) continue;
    line = line.replaceAll('\t', '  ');
    line = line.replaceAll(RegExp(r'^[•·▪►▸\-–—]+\s+'), '');
    if (RegExp(r'^[-=_*#~.\s]{3,}$').hasMatch(line)) continue;
    line = _normalizeOcrPriceGlitches(line);
    if (line.trim().isNotEmpty) out.add(line.trim());
  }
  return out;
}

String _normalizeOcrPriceGlitches(String line) {
  var s = line.replaceAll(RegExp(r'\bR[sS$][.,:]?\s*(?=\d)'), 'Rs.');
  s = s.replaceAllMapped(
    RegExp(r'(\d*)[Oo](\.[0-9Oo]{2})(?=[\sA-Za-z*#]|$)'),
    (m) => '${m.group(1)}0${m.group(2)}',
  );
  s = s.replaceAllMapped(
    RegExp(r'(\d+)\.([0-9Oo]{2})(?=[\sA-Za-z*#]|$)'),
    (m) => '${m.group(1)}.${m.group(2)!.replaceAll(RegExp('[Oo]'), '0')}',
  );
  // Convert OCR comma decimals (`145,50` or `72,75`) while leaving 3-digit Indian thousands (`1,250`) alone.
  s = s.replaceAllMapped(
    RegExp(r'(^|\s)(\d{1,4}),(\d{2})(?=[\s*#]|$)'),
    (m) => '${m.group(1)}${m.group(2)}.${m.group(3)}',
  );
  return s;
}

String _extractMerchant(List<String> lines) {
  for (final line in lines.take(10)) {
    final lower = line.toLowerCase();
    if (looksLikeHeaderNoise(lower) || looksLikeAddressOrContact(lower)) {
      continue;
    }
    if (parseInvoiceDate(line) != null && lower.contains('date')) continue;
    if (_extractReceiptRowAmountPaise(line) != null) continue;
    if (classifyReceiptSummary(line) != null) continue;

    final letters = RegExp(r'[A-Za-z]').allMatches(line).length;
    if (letters < 3) continue;

    var cleaned = line.replaceAll(RegExp(r'[*#=]+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length < 3) continue;
    if (cleaned == cleaned.toUpperCase() && cleaned.length > 4) {
      cleaned = _toTitleCase(cleaned);
    }
    return clampMerchantName(cleaned);
  }
  return '';
}

String _toTitleCase(String text) => text
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map(
      (w) => w.length == 1
          ? w.toUpperCase()
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    )
    .join(' ');

String? _parseFlexibleDate(String line) {
  final normalized = line.replaceAllMapped(
    RegExp(r'(\d{1,2})[-/]([A-Za-z]{3,9})[-/](20\d{2}|\d{2})'),
    (m) {
      final rawY = m.group(3)!;
      final year = rawY.length == 2 ? '20$rawY' : rawY;
      return '${m.group(1)} ${m.group(2)} $year';
    },
  );
  return parseInvoiceDate(normalized);
}

String? _extractReceiptDate(List<String> lines) {
  for (final line in lines.take(18)) {
    final lower = line.toLowerCase();
    if (_looksLikeExpiryDateLine(lower)) continue;
    if (lower.contains('date') ||
        lower.contains('dt:') ||
        lower.contains('dated')) {
      final parsed = _parseFlexibleDate(line);
      if (parsed != null) return parsed;
    }
  }
  for (final line in lines) {
    if (_looksLikeExpiryDateLine(line.toLowerCase())) continue;
    final parsed = _parseFlexibleDate(line);
    if (parsed != null) return parsed;
  }
  return null;
}

bool _looksLikeExpiryDateLine(String lower) =>
    lower.contains('exp') ||
    lower.contains('mfg') ||
    lower.contains('best before') ||
    lower.contains('dob');

int? _extractSummaryAmountPaise(String line) {
  final cleaned = _stripTrailingTaxFlag(line);
  final explicit = currencyAmountRegex.allMatches(cleaned).toList();
  if (explicit.isNotEmpty) return parseRupeeAmount(explicit.last.group(1)!);
  final dec = RegExp(r'(\d[\d,]*\.\d{2})\s*$').firstMatch(cleaned);
  if (dec != null) return parseRupeeAmount(dec.group(1)!);
  final intEnd = RegExp(r'(?:[:=]|\s{2,}|\s)(\d{1,6})\s*$').firstMatch(cleaned);
  if (intEnd != null) return parseRupeeAmount(intEnd.group(1)!);
  return extractRowTotalPaise(cleaned);
}

int? _extractReceiptRowAmountPaise(String line) {
  final trimmed = _stripTrailingTaxFlag(line);
  final explicit = currencyAmountRegex.allMatches(trimmed).toList();
  if (explicit.isNotEmpty && explicit.last.start > 1) {
    return parseRupeeAmount(explicit.last.group(1)!);
  }
  final decimalEnd = RegExp(r'\s([0-9][0-9,]*\.\d{2})$').firstMatch(trimmed);
  if (decimalEnd != null) return parseRupeeAmount(decimalEnd.group(1)!);
  final columnIntEnd = RegExp(r'\s{2,}(\d{1,5})$').firstMatch(trimmed);
  if (columnIntEnd != null) {
    final val = int.tryParse(columnIntEnd.group(1)!);
    if (val != null && val >= 5) return val * 100;
  }
  return null;
}

String _stripTrailingTaxFlag(String line) =>
    line.replaceFirst(RegExp(r'\s*(?:[*#]|[TNAGtnag])\s*$'), '').trim();

String _cleanItemName(String line) {
  var s = _stripTrailingTaxFlag(line);
  s = cleanProductDescription(s);
  s = s.replaceAll(RegExp(r'\s+\d{1,3}\s*$'), '').trim();
  if (s.length > 60) s = '${s.substring(0, 59).trimRight()}\u2026';
  return s;
}

bool _isPlausibleItemName(String name) {
  if (name.length < 2) return false;
  if (RegExp(r'[A-Za-z]').allMatches(name).length < 2) return false;
  final lower = name.toLowerCase();
  return !looksLikeHeaderNoise(lower) && !looksLikeAddressOrContact(lower);
}

bool _looksLikeItemTextOnlyLine(String line) {
  final lower = line.toLowerCase();
  if (looksLikeHeaderNoise(lower) || looksLikeAddressOrContact(lower)) {
    return false;
  }
  if (parseInvoiceDate(line) != null) return false;
  return RegExp(r'[A-Za-z]').allMatches(line).length >= 3 && line.length <= 55;
}

String _dominantCategory(List<ParsedReceiptItem> items) {
  final totals = <String, int>{};
  for (final item in items) {
    totals[item.category] = (totals[item.category] ?? 0) + item.amountPaise;
  }
  var bestCat = items.first.category;
  var bestTotal = -1;
  totals.forEach((cat, total) {
    if (total > bestTotal) {
      bestTotal = total;
      bestCat = cat;
    }
  });
  return bestCat;
}
