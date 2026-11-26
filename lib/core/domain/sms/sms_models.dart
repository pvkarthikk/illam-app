/// Normalized raw SMS payload received from Android Inbox, `SMS_RECEIVED`, or pasted text.
class RawSmsMessage {
  const RawSmsMessage({
    required this.sender,
    required this.body,
    required this.receivedAtMs,
    this.nativeId,
  });

  factory RawSmsMessage.fromMap(Map<Object?, Object?> map) => RawSmsMessage(
    sender: (map['sender'] as String?)?.trim() ?? '',
    body: (map['body'] as String?) ?? '',
    receivedAtMs: (map['receivedAtMs'] as num?)?.toInt() ?? 0,
    nativeId: map['id']?.toString(),
  );

  final String sender;
  final String body;
  final int receivedAtMs;
  final String? nativeId;

  /// Local calendar date (`YYYY-MM-DD`) derived from [receivedAtMs].
  String get localDateIso {
    final dt = DateTime.fromMillisecondsSinceEpoch(receivedAtMs);
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  Map<String, Object?> toMap() => {
    'sender': sender,
    'body': body,
    'receivedAtMs': receivedAtMs,
    if (nativeId != null) 'id': nativeId,
  };
}

/// Extracted outgoing payment parsed purely on-device from an SMS.
class ParsedSmsSpend {
  const ParsedSmsSpend({
    required this.fingerprint,
    required this.amountPaise,
    required this.merchant,
    required this.category,
    required this.method,
    required this.date,
    required this.rawSnippet,
    required this.receivedAtMs,
    this.bankName,
    this.accountLast4,
    this.refNumber,
    this.matchedOrderChannel,
  });

  final String fingerprint;
  final int amountPaise;
  final String merchant;
  final String category;
  final String method;
  final String date;
  final String? bankName;
  final String? accountLast4;
  final String? refNumber;
  final String? matchedOrderChannel;
  final String rawSnippet;
  final int receivedAtMs;
}

/// Returns `true` when [sender] looks like a personal 10+ digit mobile number
/// rather than an alphanumeric bank/business DLT header.
bool isPersonalPhoneSender(String sender) {
  final compact = sender.trim().replaceAll(RegExp(r'[\s\-()]'), '');
  if (compact.isEmpty) return false;
  return RegExp(r'^\+?\d{10,15}$').hasMatch(compact);
}

const _dltBankMap = <String, String>{
  'HDFCBK': 'HDFC Bank',
  'HDFCCC': 'HDFC Bank',
  'ICICIB': 'ICICI Bank',
  'ICICIC': 'ICICI Bank',
  'ICICIT': 'ICICI Bank',
  'SBIINB': 'SBI',
  'SBIUPI': 'SBI',
  'SBIPSG': 'SBI',
  'SBICRD': 'SBI Card',
  'CBSSBI': 'SBI',
  'ATMSBI': 'SBI',
  'AXISBK': 'Axis Bank',
  'AXISCC': 'Axis Bank',
  'KOTAKB': 'Kotak Bank',
  'IDFCFB': 'IDFC First',
  'IDFCBK': 'IDFC First',
  'INDUSB': 'IndusInd Bank',
  'INDUSL': 'IndusInd Bank',
  'FEDBNK': 'Federal Bank',
  'YESBNK': 'Yes Bank',
  'AMEXIN': 'Amex',
  'ONECAR': 'OneCard',
  'RBLBNK': 'RBL Bank',
  'RBLCRD': 'RBL Bank',
  'PNBSMS': 'PNB',
  'CANBNK': 'Canara Bank',
  'BOBTXN': 'Bank of Baroda',
  'BARODA': 'Bank of Baroda',
  'UNIONB': 'Union Bank',
  'IOBCHN': 'IOB',
  'SCBANK': 'Standard Chartered',
  'CITIBK': 'Citibank',
  'HSBCIN': 'HSBC',
  'PAYTMB': 'Paytm Bank',
  'AIRTEL': 'Airtel Bank',
  'JIOPAY': 'JioPay',
  'SLICEI': 'Slice',
  'JUPITR': 'Jupiter',
  'FIMONY': 'Fi Money',
};

const _bodyBankPatterns = <(String, String)>[
  ('hdfc', 'HDFC Bank'),
  ('icici', 'ICICI Bank'),
  ('sbi card', 'SBI Card'),
  ('-sbi', 'SBI'),
  ('state bank', 'SBI'),
  ('axis bank', 'Axis Bank'),
  ('kotak', 'Kotak Bank'),
  ('idfc', 'IDFC First'),
  ('indusind', 'IndusInd Bank'),
  ('federal bank', 'Federal Bank'),
  ('yes bank', 'Yes Bank'),
  ('amex', 'Amex'),
  ('american express', 'Amex'),
  ('onecard', 'OneCard'),
  ('rbl bank', 'RBL Bank'),
  ('punjab national', 'PNB'),
  ('canara bank', 'Canara Bank'),
  ('bank of baroda', 'Bank of Baroda'),
  ('union bank', 'Union Bank'),
  ('standard chartered', 'Standard Chartered'),
  ('hsbc', 'HSBC'),
];

/// Resolves the issuing bank/card name from a TRAI DLT [sender] or [body].
String? detectBankFromSenderOrBody(String sender, String body) {
  var code = sender.trim().toUpperCase();
  if (code.contains('-')) {
    final parts = code.split('-');
    // Handles both `VM-HDFCBK` and newer TRAI suffix `VM-HDFCBK-S`.
    if (parts.length >= 2 && parts[0].length == 2) {
      code = parts[1];
    } else {
      code = parts.last;
    }
  }
  final direct = _dltBankMap[code];
  if (direct != null) return direct;
  for (final entry in _dltBankMap.entries) {
    if (code.contains(entry.key)) return entry.value;
  }

  final lower = body.toLowerCase();
  for (final (needle, label) in _bodyBankPatterns) {
    if (lower.contains(needle)) return label;
  }
  return null;
}
