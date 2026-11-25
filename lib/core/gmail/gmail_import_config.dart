import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/spend_category.dart';

/// One line item inside a staged [DraftExpenseOrder].
class DraftExpenseItem {
  const DraftExpenseItem({
    required this.id,
    required this.name,
    required this.amountPaise,
    required this.category,
    this.quantity = 1,
    this.included = true,
  });

  factory DraftExpenseItem.fromJson(Map<String, Object?> j) {
    final rawCategory = (j['category'] as String?) ?? 'Other';
    final category = spendCategories.contains(rawCategory)
        ? rawCategory
        : 'Other';
    return DraftExpenseItem(
      id: (j['id'] as String?) ?? '0',
      name: (j['name'] as String?) ?? 'Item',
      amountPaise: ((j['amountPaise'] as num?)?.toInt() ?? 0).clamp(0, 100000000),
      category: category,
      quantity: ((j['quantity'] as num?)?.toInt() ?? 1).clamp(1, 999),
      included: (j['included'] as bool?) ?? true,
    );
  }

  final String id;
  final String name;
  final int amountPaise;
  final String category;
  final int quantity;
  final bool included;

  DraftExpenseItem copyWith({
    String? name,
    int? amountPaise,
    String? category,
    int? quantity,
    bool? included,
  }) =>
      DraftExpenseItem(
        id: id,
        name: name ?? this.name,
        amountPaise: amountPaise ?? this.amountPaise,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        included: included ?? this.included,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'amountPaise': amountPaise,
        'category': category,
        'quantity': quantity,
        'included': included,
      };
}

/// Planned ledger expense entry generated when accounting a draft order.
class PlannedDraftSpend {
  const PlannedDraftSpend({
    required this.merchant,
    required this.amountPaise,
    required this.category,
  });

  final String merchant;
  final int amountPaise;
  final String category;
}

/// Unapproved order parsed from Gmail (or pasted test text), awaiting user
/// review and explicit confirmation via **Account it**.
class DraftExpenseOrder {
  const DraftExpenseOrder({
    required this.id,
    required this.channel,
    required this.date,
    required this.totalPaise,
    required this.items,
    required this.importedAtMs,
    this.orderId,
    this.feesPaise = 0,
    this.discountPaise = 0,
    this.splitByItem = true,
    this.method = 'upi',
    this.paidBy,
    this.note,
    this.subject,
    this.fromEmail,
  });

  factory DraftExpenseOrder.fromParsed(
    ParsedInvoice parsed, {
    required String id,
    required int importedAtMs,
    String? subject,
    String? fromEmail,
  }) {
    final draftItems = [
      for (var i = 0; i < parsed.items.length; i++)
        DraftExpenseItem(
          id: '$i',
          name: parsed.items[i].name,
          amountPaise: parsed.items[i].amountPaise,
          category: parsed.items[i].category,
          quantity: parsed.items[i].quantity,
        ),
    ];
    return DraftExpenseOrder(
      id: id,
      channel: parsed.channel,
      orderId: parsed.orderId,
      date: parsed.date,
      totalPaise: parsed.totalPaise,
      items: draftItems,
      importedAtMs: importedAtMs,
      feesPaise: parsed.feesPaise,
      discountPaise: parsed.discountPaise,
      splitByItem: draftItems.isNotEmpty,
      subject: subject,
      fromEmail: fromEmail,
    );
  }

  factory DraftExpenseOrder.fromJson(Map<String, Object?> j) {
    final channel =
        InvoiceChannel.tryParse(j['channel'] as String?) ??
        InvoiceChannel.zepto;
    final rawItems = j['items'] as List? ?? const [];
    final items = [
      for (final raw in rawItems)
        if (raw is Map) DraftExpenseItem.fromJson(Map<String, Object?>.from(raw)),
    ];
    return DraftExpenseOrder(
      id: (j['id'] as String?) ?? '',
      channel: channel,
      orderId: j['orderId'] as String?,
      date: (j['date'] as String?) ?? '',
      totalPaise: ((j['totalPaise'] as num?)?.toInt() ?? 0).clamp(0, 100000000),
      items: items,
      importedAtMs: (j['importedAtMs'] as num?)?.toInt() ?? 0,
      feesPaise: ((j['feesPaise'] as num?)?.toInt() ?? 0).clamp(0, 100000000),
      discountPaise:
          ((j['discountPaise'] as num?)?.toInt() ?? 0).clamp(0, 100000000),
      splitByItem: (j['splitByItem'] as bool?) ?? items.isNotEmpty,
      method: ((j['method'] as String?) ?? 'upi').toLowerCase(),
      paidBy: j['paidBy'] as String?,
      note: j['note'] as String?,
      subject: j['subject'] as String?,
      fromEmail: j['fromEmail'] as String?,
    );
  }

  final String id;
  final InvoiceChannel channel;
  final String? orderId;
  final String date;
  final int totalPaise;
  final List<DraftExpenseItem> items;
  final int importedAtMs;
  final int feesPaise;
  final int discountPaise;
  final bool splitByItem;
  final String method;
  final String? paidBy;
  final String? note;
  final String? subject;
  final String? fromEmail;

  List<DraftExpenseItem> get includedItems =>
      items.where((i) => i.included && i.amountPaise > 0).toList();

  /// Total paise that will be written to the ledger with current selection.
  int get effectiveTotalPaise {
    if (splitByItem && items.isNotEmpty) {
      return includedItems.fold<int>(0, (sum, i) => sum + i.amountPaise);
    }
    return totalPaise;
  }

  /// Concrete ledger expense entries produced when the user taps **Account it**.
  List<PlannedDraftSpend> plannedSpends() {
    if (splitByItem && items.isNotEmpty) {
      return [
        for (final item in includedItems)
          PlannedDraftSpend(
            merchant: clampMerchantName(
              '${channel.displayName} \u00B7 ${item.name}',
            ),
            amountPaise: item.amountPaise,
            category: item.category,
          ),
      ];
    }
    if (totalPaise <= 0) return const [];
    return [
      PlannedDraftSpend(
        merchant: clampMerchantName(channel.displayName),
        amountPaise: totalPaise,
        category: channel.defaultCategory,
      ),
    ];
  }

  /// Concise summary preview shown on compact draft cards.
  String itemsSummaryLine() {
    if (items.isEmpty) return channel.displayName;
    final shown = items.take(2).map((i) => i.name).join(', ');
    if (items.length <= 2) return shown;
    return '$shown +${items.length - 2}';
  }

  DraftExpenseOrder copyWith({
    InvoiceChannel? channel,
    String? orderId,
    String? date,
    int? totalPaise,
    List<DraftExpenseItem>? items,
    bool? splitByItem,
    String? method,
    String? paidBy,
    bool clearPaidBy = false,
    String? note,
    bool clearNote = false,
  }) =>
      DraftExpenseOrder(
        id: id,
        channel: channel ?? this.channel,
        orderId: orderId ?? this.orderId,
        date: date ?? this.date,
        totalPaise: totalPaise ?? this.totalPaise,
        items: items ?? this.items,
        importedAtMs: importedAtMs,
        feesPaise: feesPaise,
        discountPaise: discountPaise,
        splitByItem: splitByItem ?? this.splitByItem,
        method: method ?? this.method,
        paidBy: clearPaidBy ? null : (paidBy ?? this.paidBy),
        note: clearNote ? null : (note ?? this.note),
        subject: subject,
        fromEmail: fromEmail,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'channel': channel.id,
        'orderId': orderId,
        'date': date,
        'totalPaise': totalPaise,
        'items': [for (final item in items) item.toJson()],
        'importedAtMs': importedAtMs,
        'feesPaise': feesPaise,
        'discountPaise': discountPaise,
        'splitByItem': splitByItem,
        'method': method,
        'paidBy': paidBy,
        'note': note,
        'subject': subject,
        'fromEmail': fromEmail,
      };
}

/// Per-home persisted state for the experimental Gmail Invoice Import feature.
class GmailImportConfig {
  const GmailImportConfig({
    required this.enabled,
    this.oauth,
    this.tokens,
    this.connectedEmail,
    this.scanDays = 30,
    this.lastScanAtMs,
    this.lastError,
    this.processedMessageIds = const {},
    this.drafts = const [],
  });

  factory GmailImportConfig.empty() => const GmailImportConfig(enabled: false);

  factory GmailImportConfig.fromJson(Map<String, Object?> j) {
    final oauthMap = j['oauth'];
    final tokenMap = j['tokens'];
    final rawProcessed = j['processedMessageIds'] as List? ?? const [];
    final rawDrafts = j['drafts'] as List? ?? const [];
    final rawScanDays = (j['scanDays'] as num?)?.toInt() ?? 30;
    return GmailImportConfig(
      enabled: (j['enabled'] as bool?) ?? false,
      oauth: oauthMap is Map
          ? GmailOAuthCredentials.fromJson(Map<String, Object?>.from(oauthMap))
          : null,
      tokens: tokenMap is Map
          ? OAuthTokens.fromJson(Map<String, Object?>.from(tokenMap))
          : null,
      connectedEmail: j['connectedEmail'] as String?,
      scanDays: const [7, 30, 90].contains(rawScanDays) ? rawScanDays : 30,
      lastScanAtMs: (j['lastScanAtMs'] as num?)?.toInt(),
      lastError: j['lastError'] as String?,
      processedMessageIds: {
        for (final id in rawProcessed)
          if (id is String && id.isNotEmpty) id,
      },
      drafts: [
        for (final d in rawDrafts)
          if (d is Map)
            DraftExpenseOrder.fromJson(Map<String, Object?>.from(d)),
      ],
    );
  }

  final bool enabled;
  final GmailOAuthCredentials? oauth;
  final OAuthTokens? tokens;
  final String? connectedEmail;
  final int scanDays;
  final int? lastScanAtMs;
  final String? lastError;
  final Set<String> processedMessageIds;
  final List<DraftExpenseOrder> drafts;

  bool get hasOAuth => oauth != null;
  bool get isConnected =>
      oauth != null && tokens != null && tokens!.accessToken.isNotEmpty;

  GmailImportConfig copyWith({
    bool? enabled,
    GmailOAuthCredentials? oauth,
    bool clearOAuth = false,
    OAuthTokens? tokens,
    bool clearTokens = false,
    String? connectedEmail,
    bool clearConnectedEmail = false,
    int? scanDays,
    int? lastScanAtMs,
    bool clearLastScanAt = false,
    String? lastError,
    bool clearLastError = false,
    Set<String>? processedMessageIds,
    List<DraftExpenseOrder>? drafts,
  }) =>
      GmailImportConfig(
        enabled: enabled ?? this.enabled,
        oauth: clearOAuth ? null : (oauth ?? this.oauth),
        tokens: clearTokens ? null : (tokens ?? this.tokens),
        connectedEmail: clearConnectedEmail
            ? null
            : (connectedEmail ?? this.connectedEmail),
        scanDays: scanDays ?? this.scanDays,
        lastScanAtMs:
            clearLastScanAt ? null : (lastScanAtMs ?? this.lastScanAtMs),
        lastError: clearLastError ? null : (lastError ?? this.lastError),
        processedMessageIds: processedMessageIds ?? this.processedMessageIds,
        drafts: drafts ?? this.drafts,
      );

  /// Updates OAuth credentials and clears existing session tokens if client changed.
  GmailImportConfig withOAuth(GmailOAuthCredentials next) {
    final changed =
        oauth?.clientId != next.clientId ||
        oauth?.clientSecret != next.clientSecret;
    return copyWith(
      oauth: next,
      clearTokens: changed,
      clearConnectedEmail: changed,
      clearLastError: true,
    );
  }

  /// Keeps only the most recent 500 processed message IDs to bound storage size.
  static List<String> _trimmedIds(Set<String> ids) {
    final list = ids.toList();
    if (list.length <= 500) return list;
    return list.sublist(list.length - 500);
  }

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'oauth': oauth?.toJson(),
        'tokens': tokens?.toJson(),
        'connectedEmail': connectedEmail,
        'scanDays': scanDays,
        'lastScanAtMs': lastScanAtMs,
        'lastError': lastError,
        'processedMessageIds': _trimmedIds(processedMessageIds),
        'drafts': [for (final d in drafts) d.toJson()],
      };
}

/// Persists per-home [GmailImportConfig] and draft orders in [SecureStore].
class GmailImportStore {
  GmailImportStore(this.store);

  final SecureStore store;
  final _changes = StreamController<String>.broadcast();

  Stream<String> get changes => _changes.stream;

  static String _key(String homeId) => 'gmail_import_$homeId';

  Future<GmailImportConfig> load(String homeId) async {
    final raw = await store.read(_key(homeId));
    if (raw == null || raw.isEmpty) return GmailImportConfig.empty();
    try {
      return GmailImportConfig.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      return GmailImportConfig.empty();
    }
  }

  Future<void> save(String homeId, GmailImportConfig config) async {
    await store.write(_key(homeId), jsonEncode(config.toJson()));
    if (!_changes.isClosed) _changes.add(homeId);
  }

  /// Watches [homeId] configuration and drafts reactively.
  Stream<GmailImportConfig> watch(String homeId) async* {
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
