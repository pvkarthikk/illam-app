import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/domain/sms/sms_spend_parser.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';

/// UI state for SMS permissions, scanning, and draft accounting.
class SmsImportUiState {
  const SmsImportUiState({
    this.permission,
    this.scanning = false,
    this.requestingPermission = false,
    this.accountingDraftId,
  });

  final SmsPermissionStatus? permission;
  final bool scanning;
  final bool requestingPermission;
  final String? accountingDraftId;

  SmsImportUiState copyWith({
    SmsPermissionStatus? permission,
    bool? scanning,
    bool? requestingPermission,
    String? accountingDraftId,
    bool clearAccounting = false,
  }) =>
      SmsImportUiState(
        permission: permission ?? this.permission,
        scanning: scanning ?? this.scanning,
        requestingPermission: requestingPermission ?? this.requestingPermission,
        accountingDraftId: clearAccounting
            ? null
            : (accountingDraftId ?? this.accountingDraftId),
      );
}

final smsImportControllerProvider =
    NotifierProvider<SmsImportController, SmsImportUiState>(
      SmsImportController.new,
    );

/// Coordinates SMS permissions, native background capture receiver state,
/// inbox scanning, offline SMS parsing, and draft accounting.
class SmsImportController extends Notifier<SmsImportUiState> {
  @override
  SmsImportUiState build() {
    ref.watch(currentHomeIdProvider);
    return const SmsImportUiState();
  }

  String? get _homeId =>
      ref.read(currentHomeIdProvider).value ??
      ref.read(prefsProvider).currentHomeId;

  Future<SmsPermissionStatus> refreshPermission() async {
    final bridge = ref.read(smsPlatformBridgeProvider);
    final perm = await bridge.checkPermissions();
    state = state.copyWith(permission: perm);
    final homeId = _homeId;
    if (homeId != null) {
      final cfg = await ref.read(smsImportStoreProvider).load(homeId);
      await _syncReceiverState(cfg, perm);
    }
    return perm;
  }

  Future<SmsPermissionStatus> requestPermission() async {
    state = state.copyWith(requestingPermission: true);
    try {
      final bridge = ref.read(smsPlatformBridgeProvider);
      final perm = await bridge.requestPermissions();
      state = state.copyWith(permission: perm, requestingPermission: false);
      final homeId = _homeId;
      if (homeId != null) {
        final cfg = await ref.read(smsImportStoreProvider).load(homeId);
        await _syncReceiverState(cfg, perm);
      }
      return perm;
    } on Object {
      state = state.copyWith(requestingPermission: false);
      return state.permission ?? const SmsPermissionStatus.unsupported();
    }
  }

  Future<void> openAppSettings() =>
      ref.read(smsPlatformBridgeProvider).openAppSettings();

  Future<void> setEnabled(bool enabled) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    final next = current.copyWith(enabled: enabled, clearLastError: !enabled);
    await store.save(homeId, next);
    final perm =
        state.permission ??
        await ref.read(smsPlatformBridgeProvider).checkPermissions();
    state = state.copyWith(permission: perm);
    await _syncReceiverState(next, perm);
  }

  Future<void> setAutoCapture(bool autoCapture) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    final next = current.copyWith(autoCapture: autoCapture);
    await store.save(homeId, next);
    final perm =
        state.permission ??
        await ref.read(smsPlatformBridgeProvider).checkPermissions();
    state = state.copyWith(permission: perm);
    await _syncReceiverState(next, perm);
  }

  Future<void> setScanDays(int days) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(homeId, current.copyWith(scanDays: days));
  }

  Future<int?> scanNow() async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    if (!current.enabled) return null;

    state = state.copyWith(scanning: true);
    try {
      final scanner = ref.read(smsSpendScannerProvider);
      final rules = _readMerchantRules();
      final result = await scanner.scanInbox(current, merchantRules: rules);
      final latest = await store.load(homeId);
      await _mergeScanResult(store, homeId, latest, result, updateTimestamp: true);
      state = state.copyWith(scanning: false);
      return result.newDrafts.length;
    } on Object {
      state = state.copyWith(scanning: false);
      return null;
    }
  }

  /// Drains background-captured SMS notifications into Drafts on startup/resume.
  Future<int> drainBackgroundQueue() async {
    final homeId = _homeId;
    if (homeId == null) return 0;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    final bridge = ref.read(smsPlatformBridgeProvider);
    if (!current.enabled) {
      await bridge.setBackgroundCaptureEnabled(false);
      return 0;
    }

    final queued = await bridge.drainQueuedMessages();
    if (queued.isEmpty) return 0;

    final scanner = ref.read(smsSpendScannerProvider);
    final rules = _readMerchantRules();
    final result = scanner.ingestMessages(
      queued,
      current,
      merchantRules: rules,
    );
    await _mergeScanResult(store, homeId, current, result);
    return result.newDrafts.length;
  }

  /// Handles an incoming live SMS while Illam is foregrounded.
  Future<void> handleIncomingSms(RawSmsMessage msg) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    if (!current.enabled) return;

    final scanner = ref.read(smsSpendScannerProvider);
    final rules = _readMerchantRules();
    final result = scanner.ingestMessages([msg], current, merchantRules: rules);
    await _mergeScanResult(store, homeId, current, result);
  }

  /// Parses an offline pasted bank/UPI SMS snippet into a draft spend.
  Future<SmsDraftSpend?> importPastedSms(String rawText) async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final nowMs = ref.read(clockProvider).nowMs;
    final rules = _readMerchantRules();
    final parsed = parseSmsSpend(
      RawSmsMessage(sender: '', body: rawText, receivedAtMs: nowMs),
      merchantRules: rules,
    );
    if (parsed == null) return null;

    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    final uniqueId = current.drafts.any((d) => d.id == parsed.fingerprint)
        ? '${parsed.fingerprint}_$nowMs'
        : parsed.fingerprint;
    final draft = SmsDraftSpend.fromParsed(
      parsed,
      importedAtMs: nowMs,
    );
    final stored = SmsDraftSpend(
      id: uniqueId,
      amountPaise: draft.amountPaise,
      merchant: draft.merchant,
      category: draft.category,
      method: draft.method,
      date: draft.date,
      bankName: draft.bankName,
      accountLast4: draft.accountLast4,
      refNumber: draft.refNumber,
      matchedOrderChannel: draft.matchedOrderChannel,
      note: draft.note,
      rawSnippet: draft.rawSnippet,
      receivedAtMs: draft.receivedAtMs,
      importedAtMs: draft.importedAtMs,
    );
    await store.save(
      homeId,
      current.copyWith(drafts: [stored, ...current.drafts]),
    );
    return stored;
  }

  Future<void> discardDraft(String draftId) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(smsImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(
      homeId,
      current.copyWith(
        drafts: [
          for (final d in current.drafts)
            if (d.id != draftId) d,
        ],
        processedFingerprints: {...current.processedFingerprints, draftId},
      ),
    );
  }

  Future<void> clearAll() async {
    final homeId = _homeId;
    if (homeId == null) return;
    await ref
        .read(smsPlatformBridgeProvider)
        .setBackgroundCaptureEnabled(false);
    await ref.read(smsPlatformBridgeProvider).drainQueuedMessages();
    await ref.read(smsImportStoreProvider).delete(homeId);
    final perm = state.permission;
    state = SmsImportUiState(permission: perm);
  }

  /// Writes an approved SMS draft into Drift via [ChangeWriter] and clears it
  /// from pending local drafts.
  Future<({String merchant, int amountPaise})?> accountDraft(
    SmsDraftSpend draft, {
    bool learnCategory = false,
  }) async {
    final homeId = _homeId;
    if (homeId == null || draft.amountPaise <= 0) return null;

    state = state.copyWith(accountingDraftId: draft.id);
    try {
      final moneyRepo = ref.read(moneyRepoProvider);
      final me = ref.read(myMemberIdProvider);
      final merchant = clampMerchantName(draft.merchant);
      final category = normalizeSpendCategory(draft.category);
      final note = draft.note?.trim();

      await moneyRepo.addSpend(
        NewExpense(
          amountPaise: draft.amountPaise,
          merchant: merchant,
          category: category,
          method: draft.method,
          date: draft.date,
          source: 'manual',
          paidBy: draft.paidBy ?? me,
          note: note == null || note.isEmpty ? null : note,
        ),
        learn: learnCategory,
      );

      final store = ref.read(smsImportStoreProvider);
      final current = await store.load(homeId);
      await store.save(
        homeId,
        current.copyWith(
          drafts: [
            for (final d in current.drafts)
              if (d.id != draft.id) d,
          ],
          processedFingerprints: {...current.processedFingerprints, draft.id},
        ),
      );
      state = state.copyWith(clearAccounting: true);
      return (merchant: merchant, amountPaise: draft.amountPaise);
    } on Object {
      state = state.copyWith(clearAccounting: true);
      rethrow;
    }
  }

  Future<void> _mergeScanResult(
    SmsImportStore store,
    String homeId,
    SmsImportConfig base,
    dynamic result, {
    bool updateTimestamp = false,
  }) async {
    final existingIds = {for (final d in base.drafts) d.id};
    final newDrafts = (result.newDrafts as List<SmsDraftSpend>);
    final fingerprints = (result.scannedFingerprints as Set<String>);
    final mergedDrafts = [
      for (final d in newDrafts)
        if (!existingIds.contains(d.id)) d,
      ...base.drafts,
    ];
    await store.save(
      homeId,
      base.copyWith(
        drafts: mergedDrafts,
        processedFingerprints: {
          ...base.processedFingerprints,
          ...fingerprints,
        },
        lastScanAtMs:
            updateTimestamp ? ref.read(clockProvider).nowMs : base.lastScanAtMs,
        clearLastError: true,
      ),
    );
  }

  Map<String, String> _readMerchantRules() {
    try {
      return ref.read(merchantRulesProvider).value ?? const {};
    } on Object {
      return const {};
    }
  }

  Future<void> _syncReceiverState(
    SmsImportConfig cfg,
    SmsPermissionStatus perm,
  ) async {
    await ref
        .read(smsPlatformBridgeProvider)
        .setBackgroundCaptureEnabled(
          cfg.enabled && cfg.autoCapture && perm.allGranted,
        );
  }
}
