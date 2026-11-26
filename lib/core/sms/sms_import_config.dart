import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/domain/spend_category.dart';

const _validMethods = {'upi', 'cash', 'card', 'bank'};

/// Unapproved outgoing payment parsed from an SMS, awaiting user review and
/// explicit **Account it** confirmation.
class SmsDraftSpend {
  const SmsDraftSpend({
    required this.id,
    required this.amountPaise,
    required this.merchant,
    required this.category,
    required this.method,
    required this.date,
    required this.rawSnippet,
    required this.receivedAtMs,
    required this.importedAtMs,
    this.bankName,
    this.accountLast4,
    this.refNumber,
    this.matchedOrderChannel,
    this.paidBy,
    this.note,
  });

  factory SmsDraftSpend.fromParsed(
    ParsedSmsSpend parsed, {
    required int importedAtMs,
  }) =>
      SmsDraftSpend(
        id: parsed.fingerprint,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        category: parsed.category,
        method: parsed.method,
        date: parsed.date,
        bankName: parsed.bankName,
        accountLast4: parsed.accountLast4,
        refNumber: parsed.refNumber,
        matchedOrderChannel: parsed.matchedOrderChannel,
        note: defaultNoteFor(
          bankName: parsed.bankName,
          accountLast4: parsed.accountLast4,
          refNumber: parsed.refNumber,
        ),
        rawSnippet: parsed.rawSnippet,
        receivedAtMs: parsed.receivedAtMs,
        importedAtMs: importedAtMs,
      );

  factory SmsDraftSpend.fromJson(Map<String, Object?> j) {
    final rawCat = (j['category'] as String?) ?? 'Other';
    final category = normalizeSpendCategory(rawCat);
    final rawMethod = ((j['method'] as String?) ?? 'upi').toLowerCase();
    final method = _validMethods.contains(rawMethod) ? rawMethod : 'upi';
    return SmsDraftSpend(
      id: (j['id'] as String?) ?? '',
      amountPaise: ((j['amountPaise'] as num?)?.toInt() ?? 0).clamp(0, 100000000),
      merchant: (j['merchant'] as String?) ?? 'Payment',
      category: category,
      method: method,
      date: (j['date'] as String?) ?? '',
      bankName: j['bankName'] as String?,
      accountLast4: j['accountLast4'] as String?,
      refNumber: j['refNumber'] as String?,
      matchedOrderChannel: j['matchedOrderChannel'] as String?,
      paidBy: j['paidBy'] as String?,
      note: j['note'] as String?,
      rawSnippet: (j['rawSnippet'] as String?) ?? '',
      receivedAtMs: (j['receivedAtMs'] as num?)?.toInt() ?? 0,
      importedAtMs: (j['importedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final int amountPaise;
  final String merchant;
  final String category;
  final String method;
  final String date;
  final String? bankName;
  final String? accountLast4;
  final String? refNumber;
  final String? matchedOrderChannel;
  final String? paidBy;
  final String? note;
  final String rawSnippet;
  final int receivedAtMs;
  final int importedAtMs;

  static String? defaultNoteFor({
    String? bankName,
    String? accountLast4,
    String? refNumber,
  }) {
    final parts = <String>[];
    if (bankName != null && bankName.isNotEmpty) {
      parts.add(
        accountLast4 != null && accountLast4.isNotEmpty
            ? '$bankName *$accountLast4'
            : bankName,
      );
    } else if (accountLast4 != null && accountLast4.isNotEmpty) {
      parts.add('*$accountLast4');
    }
    if (refNumber != null && refNumber.isNotEmpty) {
      parts.add('Ref $refNumber');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Concise bank + card/account tag displayed below merchant on draft cards.
  String? accountLabel() {
    if (bankName != null && accountLast4 != null) {
      return '$bankName *$accountLast4';
    }
    if (bankName != null) return bankName;
    if (accountLast4 != null) return '*$accountLast4';
    return null;
  }

  SmsDraftSpend copyWith({
    int? amountPaise,
    String? merchant,
    String? category,
    String? method,
    String? date,
    String? paidBy,
    bool clearPaidBy = false,
    String? note,
    bool clearNote = false,
  }) =>
      SmsDraftSpend(
        id: id,
        amountPaise: amountPaise ?? this.amountPaise,
        merchant: merchant ?? this.merchant,
        category: category ?? this.category,
        method: method ?? this.method,
        date: date ?? this.date,
        bankName: bankName,
        accountLast4: accountLast4,
        refNumber: refNumber,
        matchedOrderChannel: matchedOrderChannel,
        paidBy: clearPaidBy ? null : (paidBy ?? this.paidBy),
        note: clearNote ? null : (note ?? this.note),
        rawSnippet: rawSnippet,
        receivedAtMs: receivedAtMs,
        importedAtMs: importedAtMs,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'amountPaise': amountPaise,
    'merchant': merchant,
    'category': category,
    'method': method,
    'date': date,
    'bankName': bankName,
    'accountLast4': accountLast4,
    'refNumber': refNumber,
    'matchedOrderChannel': matchedOrderChannel,
    'paidBy': paidBy,
    'note': note,
    'rawSnippet': rawSnippet,
    'receivedAtMs': receivedAtMs,
    'importedAtMs': importedAtMs,
  };
}

/// Per-home persisted state for experimental SMS Spend Import.
class SmsImportConfig {
  const SmsImportConfig({
    required this.enabled,
    this.autoCapture = true,
    this.scanDays = 30,
    this.lastScanAtMs,
    this.lastError,
    this.processedFingerprints = const {},
    this.drafts = const [],
  });

  factory SmsImportConfig.empty() => const SmsImportConfig(enabled: false);

  factory SmsImportConfig.fromJson(Map<String, Object?> j) {
    final rawProcessed = j['processedFingerprints'] as List? ?? const [];
    final rawDrafts = j['drafts'] as List? ?? const [];
    final rawDays = (j['scanDays'] as num?)?.toInt() ?? 30;
    return SmsImportConfig(
      enabled: (j['enabled'] as bool?) ?? false,
      autoCapture: (j['autoCapture'] as bool?) ?? true,
      scanDays: const [7, 30, 90].contains(rawDays) ? rawDays : 30,
      lastScanAtMs: (j['lastScanAtMs'] as num?)?.toInt(),
      lastError: j['lastError'] as String?,
      processedFingerprints: {
        for (final id in rawProcessed)
          if (id is String && id.isNotEmpty) id,
      },
      drafts: [
        for (final d in rawDrafts)
          if (d is Map)
            SmsDraftSpend.fromJson(Map<String, Object?>.from(d)),
      ],
    );
  }

  final bool enabled;
  final bool autoCapture;
  final int scanDays;
  final int? lastScanAtMs;
  final String? lastError;
  final Set<String> processedFingerprints;
  final List<SmsDraftSpend> drafts;

  SmsImportConfig copyWith({
    bool? enabled,
    bool? autoCapture,
    int? scanDays,
    int? lastScanAtMs,
    bool clearLastScanAt = false,
    String? lastError,
    bool clearLastError = false,
    Set<String>? processedFingerprints,
    List<SmsDraftSpend>? drafts,
  }) =>
      SmsImportConfig(
        enabled: enabled ?? this.enabled,
        autoCapture: autoCapture ?? this.autoCapture,
        scanDays: scanDays ?? this.scanDays,
        lastScanAtMs:
            clearLastScanAt ? null : (lastScanAtMs ?? this.lastScanAtMs),
        lastError: clearLastError ? null : (lastError ?? this.lastError),
        processedFingerprints:
            processedFingerprints ?? this.processedFingerprints,
        drafts: drafts ?? this.drafts,
      );

  static List<String> _trimmedIds(Set<String> ids) {
    final list = ids.toList();
    if (list.length <= 1000) return list;
    return list.sublist(list.length - 1000);
  }

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'autoCapture': autoCapture,
    'scanDays': scanDays,
    'lastScanAtMs': lastScanAtMs,
    'lastError': lastError,
    'processedFingerprints': _trimmedIds(processedFingerprints),
    'drafts': [for (final d in drafts) d.toJson()],
  };
}

/// Encrypts and persists per-home [SmsImportConfig] and draft spends in [SecureStore].
class SmsImportStore {
  SmsImportStore(this.store);

  final SecureStore store;
  final _changes = StreamController<String>.broadcast();

  Stream<String> get changes => _changes.stream;

  static String _key(String homeId) => 'sms_import_$homeId';

  Future<SmsImportConfig> load(String homeId) async {
    final raw = await store.read(_key(homeId));
    if (raw == null || raw.isEmpty) return SmsImportConfig.empty();
    try {
      return SmsImportConfig.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      return SmsImportConfig.empty();
    }
  }

  Future<void> save(String homeId, SmsImportConfig config) async {
    await store.write(_key(homeId), jsonEncode(config.toJson()));
    if (!_changes.isClosed) _changes.add(homeId);
  }

  Stream<SmsImportConfig> watch(String homeId) async* {
    yield await load(homeId);
    await for (final changedId in changes) {
      if (changedId == homeId) {
        yield await load(homeId);
      }
    }
  }

  Future<void> delete(String homeId) async {
    await store.delete(_key(homeId));
    if (!_changes.isClosed) _changes.add(homeId);
  }

  Future<void> dispose() => _changes.close();
}
