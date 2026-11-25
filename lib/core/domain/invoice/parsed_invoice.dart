import 'package:nm_flat/core/domain/spend_category.dart';

/// Supported Indian retail / quick-commerce invoice sources.
enum InvoiceChannel {
  zepto('zepto', 'Zepto', 'Groceries'),
  blinkit('blinkit', 'Blinkit', 'Groceries'),
  amazon('amazon', 'Amazon', 'Shopping'),
  flipkart('flipkart', 'Flipkart', 'Shopping');

  const InvoiceChannel(this.id, this.displayName, this.defaultCategory);

  /// Stable key persisted on `expenses.order_channel` and draft storage.
  final String id;

  /// Human-readable brand name used in UI labels and single-order merchants.
  final String displayName;

  /// Default expense category from [spendCategories].
  final String defaultCategory;

  /// Resolves a stored channel id back to [InvoiceChannel], if known.
  static InvoiceChannel? tryParse(String? raw) {
    if (raw == null) return null;
    for (final channel in InvoiceChannel.values) {
      if (channel.id == raw) return channel;
    }
    return null;
  }
}

/// One extracted line item (or fee line) from an order email or PDF invoice.
class ParsedInvoiceItem {
  const ParsedInvoiceItem({
    required this.name,
    required this.quantity,
    required this.amountPaise,
    required this.category,
  });

  final String name;
  final int quantity;
  final int amountPaise;
  final String category;

  ParsedInvoiceItem copyWith({
    String? name,
    int? quantity,
    int? amountPaise,
    String? category,
  }) =>
      ParsedInvoiceItem(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        amountPaise: amountPaise ?? this.amountPaise,
        category: category ?? this.category,
      );
}

/// Structured invoice parsed purely from email text/HTML and optional PDF text.
class ParsedInvoice {
  const ParsedInvoice({
    required this.channel,
    required this.date,
    required this.totalPaise,
    required this.items,
    this.orderId,
    this.feesPaise = 0,
    this.discountPaise = 0,
    this.rawSubtotalPaise = 0,
  });

  final InvoiceChannel channel;
  final String? orderId;
  final String date;
  final int totalPaise;
  final List<ParsedInvoiceItem> items;
  final int feesPaise;
  final int discountPaise;
  final int rawSubtotalPaise;

  /// Builds a valid `1..60` char merchant string for ledger accounting.
  String merchantName([String? itemName]) {
    final trimmed = itemName?.trim() ?? '';
    final full = trimmed.isEmpty
        ? channel.displayName
        : '${channel.displayName} \u00B7 $trimmed';
    return clampMerchantName(full);
  }
}

/// Clamps any merchant label to the ledger's `1..60` character rule.
String clampMerchantName(String raw) {
  final compact = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (compact.isEmpty) return 'Order';
  if (compact.length <= 60) return compact;
  return '${compact.substring(0, 59).trimRight()}\u2026';
}

/// Parses an Indian Rupee string such as `1,234.50` or `₹ 49` into paise.
int? parseRupeeAmount(String raw) {
  var cleaned = raw.trim();
  cleaned = cleaned.replaceAll(
    RegExp(r'^(?:₹|Rs\.?|INR)\s*', caseSensitive: false),
    '',
  );
  cleaned = cleaned.replaceAll(RegExp(r'[₹,\s]'), '');
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(cleaned)) return null;
  final dot = cleaned.indexOf('.');
  if (dot < 0) {
    final rupees = int.tryParse(cleaned);
    if (rupees == null || rupees > 1000000) return null;
    return rupees * 100;
  }
  final rupees = int.tryParse(cleaned.substring(0, dot));
  final frac = int.tryParse(cleaned.substring(dot + 1).padRight(2, '0'));
  if (rupees == null || frac == null || rupees > 1000000) return null;
  return rupees * 100 + frac;
}

const _monthNames = <String, int>{
  'jan': 1,
  'january': 1,
  'feb': 2,
  'february': 2,
  'mar': 3,
  'march': 3,
  'apr': 4,
  'april': 4,
  'may': 5,
  'jun': 6,
  'june': 6,
  'jul': 7,
  'july': 7,
  'aug': 8,
  'august': 8,
  'sep': 9,
  'sept': 9,
  'september': 9,
  'oct': 10,
  'october': 10,
  'nov': 11,
  'november': 11,
  'dec': 12,
  'december': 12,
};

/// Parses common Indian invoice date strings into `YYYY-MM-DD`, or `null`.
String? parseInvoiceDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  final iso = RegExp(r'\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b').firstMatch(
    text,
  );
  if (iso != null) {
    return _validIsoDate(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }

  final dmyNum = RegExp(
    r'\b(\d{1,2})[-/.](\d{1,2})[-/.](20\d{2}|\d{2})\b',
  ).firstMatch(text);
  if (dmyNum != null) {
    final day = int.parse(dmyNum.group(1)!);
    final month = int.parse(dmyNum.group(2)!);
    final rawYear = int.parse(dmyNum.group(3)!);
    final year = rawYear < 100 ? 2000 + rawYear : rawYear;
    return _validIsoDate(year, month, day);
  }

  final dmyWord = RegExp(
    r'\b(\d{1,2})\s+([A-Za-z]{3,9}),?\s+(20\d{2})\b',
  ).firstMatch(text);
  if (dmyWord != null) {
    final month = _monthNames[dmyWord.group(2)!.toLowerCase()];
    if (month != null) {
      return _validIsoDate(
        int.parse(dmyWord.group(3)!),
        month,
        int.parse(dmyWord.group(1)!),
      );
    }
  }

  final mdyWord = RegExp(
    r'\b([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(20\d{2})\b',
  ).firstMatch(text);
  if (mdyWord != null) {
    final month = _monthNames[mdyWord.group(1)!.toLowerCase()];
    if (month != null) {
      return _validIsoDate(
        int.parse(mdyWord.group(3)!),
        month,
        int.parse(mdyWord.group(2)!),
      );
    }
  }
  return null;
}

String? _validIsoDate(int year, int month, int day) {
  if (year < 2015 || year > 2099 || month < 1 || month > 12 || day < 1) {
    return null;
  }
  final d = DateTime(year, month, day);
  if (d.year != year || d.month != month || d.day != day) return null;
  final mm = month.toString().padLeft(2, '0');
  final dd = day.toString().padLeft(2, '0');
  return '$year-$mm-$dd';
}

const _groceryKeywords = [
  'milk',
  'curd',
  'dahi',
  'paneer',
  'butter',
  'ghee',
  'cheese',
  'bread',
  'bun',
  'egg',
  'eggs',
  'rice',
  'atta',
  'flour',
  'dal',
  'oil',
  'sugar',
  'salt',
  'tea',
  'coffee',
  'tomato',
  'onion',
  'potato',
  'banana',
  'apple',
  'mango',
  'coriander',
  'mint',
  'spinach',
  'palak',
  'biscuit',
  'noodle',
  'pasta',
  'oats',
  'yogurt',
  'lassi',
  'buttermilk',
  'masala',
  'spice',
  'turmeric',
  'chilli',
  'juice',
  'snack',
  'chips',
  'chocolate',
  'water',
];

const _homeCareKeywords = [
  'detergent',
  'dishwash',
  'harpic',
  'vim',
  'lizol',
  'surf',
  'ariel',
  'tide',
  'cleaner',
  'bleach',
  'broom',
  'mop',
  'scrubber',
  'tissue',
  'napkin',
  'foil',
  'garbage bag',
  'trash bag',
  'mosquito',
  'good knight',
  'all out',
  'freshener',
  'soap',
  'handwash',
];

const _eatingOutKeywords = [
  'pizza',
  'burger',
  'biryani',
  'dosa',
  'idli',
  'samosa',
  'pastry',
  'cake',
  'ice cream',
  'icecream',
];

/// Guesses the household spend category for an extracted invoice item.
String inferItemCategory(String itemName, InvoiceChannel channel) {
  final lower = itemName.toLowerCase();
  for (final kw in _homeCareKeywords) {
    if (lower.contains(kw)) return 'Home care';
  }
  for (final kw in _eatingOutKeywords) {
    if (lower.contains(kw)) return 'Eating out';
  }
  for (final kw in _groceryKeywords) {
    if (lower.contains(kw)) return 'Groceries';
  }
  return spendCategories.contains(channel.defaultCategory)
      ? channel.defaultCategory
      : 'Other';
}

/// Scales/reconciles positive line items so their exact sum equals [targetTotalPaise].
///
/// If an item would round down to 0 paise or the order has fewer paise than items,
/// falls back to the item list as-is when [targetTotalPaise] is not positive.
List<ParsedInvoiceItem> reconcileItemsWithTotal(
  List<ParsedInvoiceItem> items,
  int targetTotalPaise,
) {
  final positive = items.where((item) => item.amountPaise > 0).toList();
  if (positive.isEmpty || targetTotalPaise <= 0) return positive;

  final rawSum = positive.fold<int>(0, (acc, item) => acc + item.amountPaise);
  if (rawSum == targetTotalPaise) return positive;
  if (targetTotalPaise < positive.length) {
    return positive;
  }

  final scaled = <ParsedInvoiceItem>[];
  var scaledSum = 0;
  for (final item in positive) {
    final part = ((item.amountPaise * targetTotalPaise) ~/ rawSum).clamp(
      1,
      targetTotalPaise,
    );
    scaledSum += part;
    scaled.add(item.copyWith(amountPaise: part));
  }

  var diff = targetTotalPaise - scaledSum;
  if (diff != 0) {
    final indices = List<int>.generate(scaled.length, (i) => i)
      ..sort((a, b) => scaled[b].amountPaise.compareTo(scaled[a].amountPaise));
    var cursor = 0;
    while (diff != 0 && cursor < indices.length * 4) {
      final idx = indices[cursor % indices.length];
      final current = scaled[idx].amountPaise;
      if (diff > 0) {
        scaled[idx] = scaled[idx].copyWith(amountPaise: current + 1);
        diff--;
      } else if (current > 1) {
        scaled[idx] = scaled[idx].copyWith(amountPaise: current - 1);
        diff++;
      }
      cursor++;
    }
  }
  return scaled;
}
