import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/domain/spend_category.dart';

/// Parses an outgoing Indian bank, UPI, or card SMS into [ParsedSmsSpend], or
/// returns `null` for OTPs, credits, refunds, failed txns, CC bill payments,
/// upcoming mandate notices, and promotional alerts.
ParsedSmsSpend? parseSmsSpend(
  RawSmsMessage msg, {
  Map<String, String> merchantRules = const {},
}) {
  final body = msg.body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (body.isEmpty || isPersonalPhoneSender(msg.sender)) return null;

  final lower = body.toLowerCase();
  if (_isRejectedNonSpend(lower)) return null;
  if (!_hasSettledDebitVerb(lower)) return null;

  final amountPaise = _extractDebitAmountPaise(body);
  if (amountPaise == null || amountPaise <= 0) return null;

  final bankName = detectBankFromSenderOrBody(msg.sender, body);
  final method = _detectMethod(lower);
  final accountLast4 = _extractAccountLast4(body);
  final refNumber = _extractRefNumber(body);
  final date = _extractSmsDate(body) ?? msg.localDateIso;
  final rawMerchant = _extractRawMerchant(body, method: method);
  final merchant = clampMerchantName(
    _normalizeMerchant(rawMerchant, method: method, bankName: bankName),
  );
  final matchedChannel = _detectMatchedOrderChannel(merchant, lower);
  final category = _resolveCategory(merchant, matchedChannel, merchantRules);
  final fingerprint = _buildFingerprint(
    sender: msg.sender,
    date: date,
    compactBody: body,
    refNumber: refNumber,
  );
  final snippet = body.length <= 240 ? body : '${body.substring(0, 239)}…';

  return ParsedSmsSpend(
    fingerprint: fingerprint,
    amountPaise: amountPaise,
    merchant: merchant,
    category: category,
    method: method,
    date: date,
    bankName: bankName,
    accountLast4: accountLast4,
    refNumber: refNumber,
    matchedOrderChannel: matchedChannel,
    rawSnippet: snippet,
    receivedAtMs: msg.receivedAtMs,
  );
}

bool _isRejectedNonSpend(String lower) {
  if (_matchesAny(lower, _otpPatterns)) return true;
  if (_matchesAny(lower, _failedOrPendingPatterns)) return true;
  if (_matchesAny(lower, _ccRepaymentOrDuePatterns)) return true;
  if (_isCardBillRepayment(lower)) return true;
  if (_matchesAny(lower, _promoPatterns)) return true;
  if (_isIncomingCredit(lower)) return true;
  return false;
}

bool _isCardBillRepayment(String lower) =>
    RegExp(
      r'towards\s+(?:your\s+)?(?:[a-z]+\s+){0,3}credit\s+card',
    ).hasMatch(lower) ||
    RegExp(r'payment\s+(?:of\s+.{1,25})?received\s+(?:on|towards|for)').hasMatch(
      lower,
    );

bool _isIncomingCredit(String lower) {
  if (_matchesAny(lower, _strongIncomingPatterns)) return true;
  if (lower.contains('credited') || lower.contains('refund')) {
    // Allow outgoing UPI SMS that mention the *recipient* being credited
    // (`debited ... credited to VPA ...` or `debited ...; SWIGGY credited`).
    final hasDebit = RegExp(
      r'\b(?:debited|sent\s+(?:rs|inr|₹)|transferred)\b',
    ).hasMatch(lower);
    if (!hasDebit) return true;
    final debitIdx = lower.indexOf(RegExp(r'\b(?:debited|sent|transferred)\b'));
    final creditIdx = lower.indexOf('credited');
    if (creditIdx >= 0 && creditIdx < debitIdx) return true;
    if (RegExp(r'(?:a/c|acct|account)\s+\S+\s+is\s+credited').hasMatch(lower)) {
      return true;
    }
  }
  return false;
}

bool _hasSettledDebitVerb(String lower) {
  return RegExp(
    r'\b(?:debited|spent|paid|deducted|charged|withdrawn|transferred|'
    r'autopay|auto-?debit|ecs\s+debit|nach\s+debit|purchase\s+(?:of|at)|'
    r'dr\.?\s+to)\b|\bsent\s+(?:rs\.?|inr|₹)|used\s+(?:at|for)',
  ).hasMatch(lower);
}

int? _extractDebitAmountPaise(String body) {
  // Mask balance/limit clauses up to sentence punctuation so we never pick `Avl Bal`.
  final masked = body.replaceAll(
    RegExp(
      r'\b(?:avl\.?\s*bal(?:ance)?|avbl\.?\s*bal(?:ance)?|'
      r'available\s+bal(?:ance)?|curr(?:ent)?\s+bal(?:ance)?|'
      r'closing\s+bal(?:ance)?|bal(?:ance)?\s*(?::|is)|'
      r'avl\.?\s*lmt|avbl\.?\s*lmt|available\s+(?:credit\s+)?limit|'
      r'credit\s+limit|total\s+(?:amt\.?\s+)?due|min(?:imum)?\s+due|'
      r'outstanding)\b[^.;!\n]*',
      caseSensitive: false,
    ),
    ' ',
  );

  final currencyMatch = RegExp(
    r'(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.\d{1,2})?)',
    caseSensitive: false,
  ).firstMatch(masked);
  if (currencyMatch != null) {
    return parseRupeeAmount(currencyMatch.group(1)!);
  }

  // SBI UPI often writes `debited by 350.0` without currency symbol.
  final bareDebitMatch = RegExp(
    r'\b(?:debited|spent|paid|withdrawn)\s+(?:by|for|of)\s+([0-9][0-9,]*(?:\.\d{1,2})?)\b',
    caseSensitive: false,
  ).firstMatch(masked);
  if (bareDebitMatch != null) {
    return parseRupeeAmount(bareDebitMatch.group(1)!);
  }
  return null;
}

String _detectMethod(String lower) {
  if (lower.contains('atm') || lower.contains('cash withdrawal')) {
    return 'cash';
  }
  if (RegExp(
    r'\b(?:credit\s+card|debit\s+card|amex|onecard|pos\s+txn)\b|'
    r'\bcard\s*(?:ending|no\.?\s*|[x*]{1,4}\d{3,4}|\*{2,}\d{3,4}|\d{4}\b)',
  ).hasMatch(lower)) {
    return 'card';
  }
  if (lower.contains('upi') ||
      lower.contains('vpa') ||
      lower.contains('gpay') ||
      lower.contains('phonepe') ||
      lower.contains('bhim') ||
      RegExp(r'\b[a-z0-9._-]+@[a-z]{3,}\b').hasMatch(lower) ||
      RegExp(r'\bsent\s+(?:rs\.?|inr|₹).*\bto\b.*\bref\b').hasMatch(lower)) {
    return 'upi';
  }
  return 'bank';
}

String? _extractAccountLast4(String body) {
  final labeled = RegExp(
    r'(?:\b(?:a/c|ac|acct|account|onecard|card))\s*(?:no\.?\s*)?(?:ending\s*(?:with\s*)?)?[xX*•\-]*(\d{3,4})\b',
    caseSensitive: false,
  ).firstMatch(body);
  if (labeled != null) return labeled.group(1);

  final masked = RegExp(r'\b[xX*]{2,}(\d{3,4})\b').firstMatch(body);
  return masked?.group(1);
}

String? _extractRefNumber(String body) {
  final m = RegExp(
    r'\b(?:upi\s*ref(?:\s*no\.?)?|ref\s*no\.?|ref\.?|utr|txn\s*id|rrn|upi)'
    r'\s*[:#\-]?\s*([A-Z0-9]{9,22})\b',
    caseSensitive: false,
  ).firstMatch(body);
  if (m == null) return null;
  final ref = m.group(1)!.trim();
  // Ensure the token looks like a real reference (at least 6 digits).
  final digits = RegExp(r'\d').allMatches(ref).length;
  return digits >= 6 ? ref : null;
}

const _compactMonths = <String, int>{
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'sept': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

String? _extractSmsDate(String body) {
  final standard = parseInvoiceDate(body);
  if (standard != null) return standard;

  // Matches SBI-style compact dates like `25Nov26` or `25Nov2026`.
  final compact = RegExp(
    r'\b(\d{1,2})[-/\s]?([A-Za-z]{3,4})[-/\s]?(\d{2,4})\b',
  ).firstMatch(body);
  if (compact == null) return null;
  final day = int.tryParse(compact.group(1)!);
  final month = _compactMonths[compact.group(2)!.toLowerCase()];
  final rawYear = int.tryParse(compact.group(3)!);
  if (day == null || month == null || rawYear == null) return null;
  final year = rawYear < 100 ? 2000 + rawYear : rawYear;
  final d = DateTime(year, month, day);
  if (d.year != year || d.month != month || d.day != day) return null;
  return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

String? _extractRawMerchant(String body, {required String method}) {
  if (method == 'cash') return 'ATM Withdrawal';

  // 1. ICICI semicolon form: `debited for Rs 520; BLINKIT credited.`
  final semiCredited = RegExp(
    r';\s*([A-Za-z0-9][A-Za-z0-9 &._\-/@]{1,50}?)\s+credited\b',
    caseSensitive: false,
  ).firstMatch(body);
  if (semiCredited != null) return semiCredited.group(1);

  // 2. Axis/HDFC Info UPI slash segment: `Info: UPI/P2M/123456/BIGBASKET`
  final infoSlash = RegExp(
    r'\bInfo\s*:\s*UPI/(?:P2[MA]/)?(?:\d+/)?([A-Za-z0-9@._\- ]{2,45}?)(?=[.;!\n]|\s+(?:Avl|Bal|Ref|If\s+not)|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (infoSlash != null) return infoSlash.group(1);

  // 3. Explicit destination phrases (`trf to`, `to VPA`, `paid to`, `towards`, `at`, `to`).
  final patterns = [
    RegExp(
      r'\b(?:trf\s+to|transfer\s+to|to\s+vpa|paid\s+to|credited\s+to\s+(?:vpa\s+)?)\s*'
      r'([A-Za-z0-9][A-Za-z0-9 &._\-/@]{1,50}?)'
      r'(?=\s+(?:on\s+\d|on\s+ref|ref\b|refno|upi\b|avl|avbl|bal|not\s+u|not\s+you|if\s+not|call)|[.;!\n]|$)',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:at|towards)\s+([A-Za-z0-9][A-Za-z0-9 &._\-/@]{1,50}?)'
      r'(?=\s+(?:on\s+\d|on\s+your|on\s+ref|for\s+txn|ref\b|avl|avbl|bal|autopay|not\s+you|if\s+not|call)|[.;!\n]|$)',
      caseSensitive: false,
    ),
    RegExp(
      r'\bto\s+([A-Za-z0-9][A-Za-z0-9 &._\-/@]{1,45}?)'
      r'(?=\s+(?:on\s+\d|on\s+ref|ref\b|refno|upi\b|avl|avbl|bal|not\s+you|if\s+not|call)|[.;!\n]|$)',
      caseSensitive: false,
    ),
  ];

  for (final pattern in patterns) {
    final m = pattern.firstMatch(body);
    if (m != null) {
      final candidate = m.group(1)!.trim();
      if (!_isNoiseDestination(candidate)) return candidate;
    }
  }

  // 4. Card fallback after date (`spent on ICICI Card XX123 on 25-Nov-26 on AMAZON PAY INDIA`).
  final onMerchant = RegExp(
    r'\bon\s+\d{1,2}[-/A-Za-z0-9]+\s+on\s+([A-Za-z][A-Za-z0-9 &._\-]{2,45}?)'
    r'(?=\s+(?:avl|avbl|available|if\s+not)|[.;!\n]|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (onMerchant != null && !_isNoiseDestination(onMerchant.group(1)!)) {
    return onMerchant.group(1);
  }
  return null;
}

bool _isNoiseDestination(String candidate) {
  final lower = candidate.trim().toLowerCase();
  return lower.isEmpty ||
      lower.startsWith('your ') ||
      lower.startsWith('a/c') ||
      lower.startsWith('acct') ||
      RegExp(r'^\d{1,2}[-/]').hasMatch(lower);
}

const _knownBrands = <(String, String)>[
  ('zepto', 'Zepto'),
  ('blinkit', 'Blinkit'),
  ('amazon', 'Amazon'),
  ('flipkart', 'Flipkart'),
  ('swiggy', 'Swiggy'),
  ('zomato', 'Zomato'),
  ('bigbasket', 'BigBasket'),
  ('instamart', 'Swiggy Instamart'),
  ('dmart', 'DMart'),
  ('uber', 'Uber'),
  ('ola', 'Ola'),
  ('rapido', 'Rapido'),
  ('airtel', 'Airtel'),
  ('jio', 'Jio'),
  ('bescom', 'BESCOM'),
  ('bwssb', 'BWSSB'),
  ('myntra', 'Myntra'),
  ('nykaa', 'Nykaa'),
  ('bookmyshow', 'BookMyShow'),
  ('netflix', 'Netflix'),
  ('spotify', 'Spotify'),
  ('urban company', 'Urban Company'),
];

String _normalizeMerchant(
  String? raw, {
  required String method,
  String? bankName,
}) {
  if (raw == null || raw.trim().isEmpty) {
    final fallbackSuffix = switch (method) {
      'upi' => 'UPI payment',
      'card' => 'Card spend',
      'cash' => 'ATM Withdrawal',
      _ => 'Bank payment',
    };
    return bankName != null ? '$bankName $fallbackSuffix' : fallbackSuffix;
  }

  var s = raw.trim();
  if (s.contains('@')) {
    s = s.split('@').first;
  }
  s = s.replaceAll(RegExp(r'[_/]+'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  final lower = s.toLowerCase();
  for (final (needle, canonical) in _knownBrands) {
    if (lower == needle ||
        lower.contains('${needle}pay') ||
        lower.startsWith('$needle ') ||
        lower == '${needle}in') {
      return canonical;
    }
  }

  // Convert noisy ALL-CAPS merchant tags to readable Title Case.
  if (s == s.toUpperCase() && RegExp(r'[A-Z]{3,}').hasMatch(s)) {
    s = s
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map(
          (w) => w.length == 1
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
  return s.isEmpty ? 'Payment' : s;
}

String? _detectMatchedOrderChannel(String merchant, String bodyLower) {
  final combined = '${merchant.toLowerCase()} $bodyLower';
  if (combined.contains('zepto')) return 'zepto';
  if (combined.contains('blinkit')) return 'blinkit';
  if (combined.contains('amazon')) return 'amazon';
  if (combined.contains('flipkart')) return 'flipkart';
  return null;
}

String _resolveCategory(
  String merchant,
  String? matchedOrderChannel,
  Map<String, String> merchantRules,
) {
  final learned = guessSpendCategory(merchant, merchantRules);
  if (learned != 'Other' && spendCategories.contains(learned)) {
    return learned;
  }
  if (matchedOrderChannel == 'zepto' || matchedOrderChannel == 'blinkit') {
    return 'Groceries';
  }
  if (matchedOrderChannel == 'amazon' || matchedOrderChannel == 'flipkart') {
    return 'Shopping';
  }
  final m = merchant.toLowerCase();
  if (_matchesAny(m, const [
    'bigbasket',
    'dmart',
    'instamart',
    'supermarket',
    'mart',
    'milk',
    'kirana',
    'fresh',
  ])) {
    return 'Groceries';
  }
  if (_matchesAny(m, const [
    'swiggy',
    'zomato',
    'cafe',
    'coffee',
    'restaurant',
    'bakery',
    'pizza',
    'biryani',
    'hotel',
  ])) {
    return 'Eating out';
  }
  if (_matchesAny(m, const [
    'airtel',
    'jio',
    'vi ',
    'vodafone',
    'bescom',
    'bwssb',
    'tneb',
    'electricity',
    'water',
    'broadband',
    'fiber',
    'fastag',
    'gas',
    'indane',
    'hpcl',
    'bpcl',
    'petrol',
    'uber',
    'ola',
    'rapido',
    'metro',
    'irctc',
  ])) {
    return 'Utilities';
  }
  if (_matchesAny(m, const ['urban company', 'pharmacy', 'medplus', 'apollo'])) {
    return 'Home care';
  }
  if (_matchesAny(m, const ['myntra', 'nykaa', 'ajio', 'decathlon', 'croma'])) {
    return 'Shopping';
  }
  return 'Other';
}

String _buildFingerprint({
  required String sender,
  required String date,
  required String compactBody,
  String? refNumber,
}) {
  if (refNumber != null && refNumber.length >= 9) {
    return 'sms_ref_${refNumber.toLowerCase()}';
  }
  final digest = sha256
      .convert(utf8.encode('${sender.trim().toLowerCase()}|$date|$compactBody'))
      .toString()
      .substring(0, 16);
  return 'sms_$digest';
}

bool _matchesAny(String lower, List<String> patterns) {
  for (final p in patterns) {
    if (lower.contains(p)) return true;
  }
  return false;
}

const _otpPatterns = [
  'otp',
  'one time password',
  'one-time password',
  'verification code',
  'security code',
  'do not share',
  'never share',
];

const _failedOrPendingPatterns = [
  'has failed',
  'txn failed',
  'transaction failed',
  'payment failed',
  'was declined',
  'has been declined',
  'declined',
  'unsuccessful',
  'could not be processed',
  'not debited',
  'reversed',
  'reversal',
  'cancelled',
  'canceled',
  'insufficient bal',
  'insufficient funds',
  'transaction blocked',
  'collect request',
  'has requested',
  'requested rs',
  'requested inr',
  'pre-debit',
  'will be debited',
  'scheduled to be debited',
  'upcoming auto-debit',
  'mandate created',
  'mandate registered',
];

const _ccRepaymentOrDuePatterns = [
  'towards your credit card',
  'towards credit card',
  'credit card payment',
  'credit card bill payment',
  'payment received towards',
  'payment has been received',
  'thank you for your card payment',
  'thank you for payment of',
  'total amount due',
  'minimum amount due',
  'min amount due',
  'min due',
  'statement generated',
  'bill is due',
];

const _promoPatterns = [
  'pre-approved',
  'get up to',
  'loan up to',
  'win up to',
  'apply now',
  'credit limit increased',
  'special offer',
  'upgrade your card',
];

const _strongIncomingPatterns = [
  'credited to your',
  'credited into your',
  'credited with rs',
  'credited with inr',
  'credited by rs',
  'credited by inr',
  'received rs',
  'received inr',
  'received ₹',
  'has sent you',
  'salary credited',
  'cashback credited',
  'cashback of',
  'refund of',
  'refunded',
  'deposited in',
];
