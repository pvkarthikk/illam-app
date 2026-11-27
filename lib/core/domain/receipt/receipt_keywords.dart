import 'package:nm_flat/core/domain/invoice/invoice_line_parser.dart';

enum ReceiptLineKind {
  grandTotal,
  looseTotal,
  subtotal,
  taxOrRoundOff,
  paymentOrNoise,
}

bool looksLikeHeaderNoise(String lower) {
  const needles = [
    'tax invoice',
    'retail invoice',
    'cash memo',
    'cash receipt',
    'credit memo',
    'estimate',
    'proforma',
    'bill of supply',
    'original copy',
    'duplicate copy',
    'customer copy',
    'gstin',
    'gst no',
    'fssai',
    'tin no',
    'cin:',
    'cin ',
    'pan:',
    'bill no',
    'inv no',
    'invoice no',
    'receipt no',
    'order no',
    'token no',
    'cashier',
    'waiter',
    'table no',
    'particulars',
    'description',
    'item name',
  ];
  for (final n in needles) {
    if (lower.contains(n)) return true;
  }
  if (lower.startsWith('welcome')) return true;
  return RegExp(r'\bitem\b.*\b(?:qty|amt|amount|rate|price)\b').hasMatch(lower);
}

bool looksLikeAddressOrContact(String lower) {
  if (lower.contains('@') || lower.contains('www.') || lower.contains('http')) {
    return true;
  }
  if (RegExp(r'\b(?:ph|tel|mob|phone|call)\b').hasMatch(lower)) return true;
  if (RegExp(r'\b\d{6}\b').hasMatch(lower)) return true;
  if (RegExp(r'\+?\d[\d\s\-]{8,}\d').hasMatch(lower)) return true;
  if (RegExp(r'^\d+[,\s/]').hasMatch(lower)) return true;
  const addressWords = [
    'road',
    'rd,',
    'street',
    'lane',
    'cross',
    'main ',
    'sector',
    'phase',
    'floor',
    'block',
    'nagar',
    'layout',
    'colony',
    'complex',
    'opp.',
    'near ',
    'bengaluru',
    'bangalore',
    'mumbai',
    'delhi',
    'chennai',
    'hyderabad',
    'pune',
    'kolkata',
    'karnataka',
    'maharashtra',
    'tamil nadu',
    'telangana',
  ];
  for (final w in addressWords) {
    if (lower.contains(w)) return true;
  }
  return false;
}

ReceiptLineKind? classifyReceiptSummary(String line) {
  final lower = line.toLowerCase();
  final base = classifySummaryLine(line);
  if (base != null) {
    return switch (base) {
      SummaryLineKind.grandTotal => ReceiptLineKind.grandTotal,
      SummaryLineKind.subtotal => ReceiptLineKind.subtotal,
      SummaryLineKind.taxOnly => ReceiptLineKind.taxOrRoundOff,
      SummaryLineKind.fee ||
      SummaryLineKind.discount ||
      SummaryLineKind.headerOrNoise =>
        ReceiptLineKind.paymentOrNoise,
    };
  }

  const strongTotals = [
    'grand total',
    'net total',
    'net amt',
    'net amount',
    'bill amt',
    'bill amount',
    'tot amt',
    'total amt',
    'total amount',
    'amt payable',
    'amount due',
    'card/upi',
  ];
  for (final kw in strongTotals) {
    if (lower.contains(kw)) return ReceiptLineKind.grandTotal;
  }

  if (RegExp(
        r'^(?:total|net|payable)\s*[:=\-]?\s*(?:₹|Rs\.?|INR)?\s*\d',
        caseSensitive: false,
      ).hasMatch(lower) ||
      RegExp(
        r'\btotal\b(?!.*\b(?:qty|items?|pcs|saving|savings|discount|tax|mrp)\b)',
      ).hasMatch(lower)) {
    return ReceiptLineKind.looseTotal;
  }

  if (RegExp(
    r'\b(?:cgst|sgst|igst|utgst|vat|cess|service\s*charge|gst)\b',
  ).hasMatch(lower)) {
    return ReceiptLineKind.taxOrRoundOff;
  }
  if (isRoundOffLine(line)) return ReceiptLineKind.taxOrRoundOff;

  const noisePhrases = [
    'cash tendered',
    'cash paid',
    'paid by',
    'paid via',
    'change',
    'balance',
    'total qty',
    'total items',
    'total pcs',
    'no of items',
    'no. of items',
    'you saved',
    'you save',
    'total savings',
    'thank you',
    'thanks for',
    'visit again',
    'goods once sold',
    'e.&o.e',
    'upi ref',
    'rrn',
    'auth code',
    'batch no',
    'hsn summary',
  ];
  for (final kw in noisePhrases) {
    if (lower.contains(kw)) return ReceiptLineKind.paymentOrNoise;
  }
  if (looksLikeHeaderNoise(lower)) {
    return ReceiptLineKind.paymentOrNoise;
  }
  return null;
}

bool isRoundOffLine(String line) {
  final lower = line.toLowerCase();
  return lower.contains('round off') ||
      lower.contains('roundoff') ||
      lower.contains('rounding');
}

const _groceryWords = [
  'milk', 'curd', 'dahi', 'paneer', 'butter', 'ghee', 'cheese', 'bread',
  'egg', 'rice', 'atta', 'dal', 'oil', 'sugar', 'salt', 'tea', 'coffee',
  'tomato', 'onion', 'potato', 'banana', 'apple', 'fruit', 'veg', 'biscuit',
  'masala', 'kirana', 'noodle', 'oats', 'water',
];

const _eatingOutWords = [
  'dosa', 'idli', 'vada', 'paratha', 'roti', 'naan', 'biryani', 'thali',
  'curry', 'pizza', 'burger', 'sandwich', 'pastry', 'cake', 'chai', 'lassi',
  'soup', 'noodles', 'fried rice', 'cafe', 'restaurant', 'hotel', 'kitchen',
  'bistro', 'dhaba', 'bakery',
];

const _homeCareWords = [
  'detergent', 'dishwash', 'harpic', 'vim', 'lizol', 'surf', 'ariel',
  'cleaner', 'broom', 'mop', 'tissue', 'garbage bag', 'mosquito',
  'freshener', 'soap', 'shampoo', 'toothpaste', 'phenyl',
];

const _pharmacyOrShoppingWords = [
  'pharmacy', 'chemist', 'medical', 'medplus', 'apollo', 'tablet',
  'capsule', 'syrup', 'strip', 'stationery', 'notebook', 'pen ',
];

String inferWholeReceiptCategory(List<String> lines) {
  final sample = lines.take(12).join(' ').toLowerCase();
  if (_containsAnyWord(sample, _eatingOutWords)) return 'Eating out';
  if (_containsAnyWord(sample, _groceryWords)) return 'Groceries';
  if (_containsAnyWord(sample, _homeCareWords)) return 'Home care';
  if (_containsAnyWord(sample, _pharmacyOrShoppingWords)) return 'Shopping';
  return 'Other';
}

String inferReceiptItemCategory(String itemName, String fallback) {
  final lower = itemName.toLowerCase();
  if (fallback != 'Eating out' && _containsAnyWord(lower, _homeCareWords)) {
    return 'Home care';
  }
  if (_containsAnyWord(lower, _eatingOutWords) && fallback == 'Eating out') {
    return 'Eating out';
  }
  if (_containsAnyWord(lower, _groceryWords) && fallback != 'Eating out') {
    return 'Groceries';
  }
  if (fallback == 'Other' && _containsAnyWord(lower, _pharmacyOrShoppingWords)) {
    return 'Shopping';
  }
  return fallback.isEmpty ? 'Other' : fallback;
}

bool _containsAnyWord(String text, List<String> words) {
  for (final w in words) {
    if (text.contains(w)) return true;
  }
  return false;
}
