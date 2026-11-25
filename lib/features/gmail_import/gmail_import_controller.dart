import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/domain/invoice/store_parsers.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/gmail/gmail_loopback_auth.dart'
    if (dart.library.js_interop) 'package:nm_flat/core/gmail/gmail_loopback_auth_web.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Maps internal error codes from OAuth / Gmail REST / loopback flow to l10n.
String gmailImportErrorText(AppLocalizations l10n, String code) => switch (code) {
  'unauthorized' => l10n.gmailImportErrUnauthorized,
  'forbiddenOrApiDisabled' => l10n.gmailImportErrForbidden,
  'rateLimited' => l10n.gmailImportErrRateLimited,
  'network' => l10n.gmailImportErrNetwork,
  'unsupportedPlatform' => l10n.gmailImportErrAuthUnsupported,
  'couldNotOpenBrowser' => l10n.gmailImportErrAuthBrowser,
  'userDeniedAccess' || 'cancelled' => l10n.gmailImportErrAuthDenied,
  'timedOut' => l10n.gmailImportErrAuthTimeout,
  'stateMismatch' ||
  'missingCode' ||
  'bindFailed' => l10n.gmailImportErrAuthOther,
  _ => l10n.gmailImportErrAuthOther,
};

/// UI state for ongoing Gmail OAuth sign-in, scanning, or accounting actions.
class GmailImportUiState {
  const GmailImportUiState({
    this.connecting = false,
    this.scanning = false,
    this.accountingDraftId,
    this.errorCode,
  });

  final bool connecting;
  final bool scanning;
  final String? accountingDraftId;
  final String? errorCode;

  GmailImportUiState copyWith({
    bool? connecting,
    bool? scanning,
    String? accountingDraftId,
    bool clearAccounting = false,
    String? errorCode,
    bool clearError = false,
  }) =>
      GmailImportUiState(
        connecting: connecting ?? this.connecting,
        scanning: scanning ?? this.scanning,
        accountingDraftId: clearAccounting
            ? null
            : (accountingDraftId ?? this.accountingDraftId),
        errorCode: clearError ? null : (errorCode ?? this.errorCode),
      );
}

final gmailImportControllerProvider =
    NotifierProvider<GmailImportController, GmailImportUiState>(
      GmailImportController.new,
    );

/// Orchestrates Desktop OAuth sign-in, Gmail scanning, and Draft accounting.
class GmailImportController extends Notifier<GmailImportUiState> {
  @override
  GmailImportUiState build() {
    ref.watch(currentHomeIdProvider);
    return const GmailImportUiState();
  }

  String? get _homeId =>
      ref.read(currentHomeIdProvider).value ??
      ref.read(prefsProvider).currentHomeId;

  Future<void> setEnabled(bool enabled) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    state = const GmailImportUiState();
    await store.save(
      homeId,
      current.copyWith(enabled: enabled, clearLastError: !enabled),
    );
  }

  Future<void> setScanDays(int days) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(homeId, current.copyWith(scanDays: days));
  }

  Future<void> saveOAuth(GmailOAuthCredentials credentials) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    state = state.copyWith(clearError: true);
    await store.save(homeId, current.withOAuth(credentials));
  }

  /// Launches browser PKCE OAuth with loopback listener, exchanges the code for
  /// tokens, fetches the Gmail address, and saves the connected session.
  Future<String?> connectGmail() async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    final oauth = current.oauth;
    if (oauth == null) return null;

    state = state.copyWith(connecting: true, clearError: true);
    try {
      final auth = ref.read(gmailLoopbackAuthProvider);
      final client = ref.read(gmailRestClientProvider);
      final authCode = await auth.authorize(oauth);
      final tokens = await client.exchangeAuthCode(
        credentials: oauth,
        code: authCode.code,
        codeVerifier: authCode.codeVerifier,
        redirectUri: authCode.redirectUri,
      );
      final email = await client.fetchProfileEmail(tokens.accessToken);
      await store.save(
        homeId,
        current.copyWith(
          tokens: tokens,
          connectedEmail: email,
          clearLastError: true,
        ),
      );
      state = state.copyWith(connecting: false, clearError: true);
      return email;
    } on GmailLoopbackException catch (e) {
      await _recordError(homeId, e.kind.name);
      return null;
    } on GmailApiException catch (e) {
      await _recordError(homeId, e.kind.name);
      return null;
    } on Object {
      await _recordError(homeId, 'other');
      return null;
    }
  }

  Future<void> cancelConnect() async {
    await ref.read(gmailLoopbackAuthProvider).cancel();
    state = state.copyWith(connecting: false);
  }

  Future<void> disconnectGmail() async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    final tokenToRevoke =
        current.tokens?.refreshToken ?? current.tokens?.accessToken;
    if (tokenToRevoke != null && tokenToRevoke.isNotEmpty) {
      unawaited(ref.read(gmailRestClientProvider).revokeToken(tokenToRevoke));
    }
    await store.save(
      homeId,
      current.copyWith(
        clearTokens: true,
        clearConnectedEmail: true,
        clearLastError: true,
      ),
    );
    state = state.copyWith(connecting: false, clearError: true);
  }

  Future<void> clearAll() async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    final tokenToRevoke =
        current.tokens?.refreshToken ?? current.tokens?.accessToken;
    if (tokenToRevoke != null && tokenToRevoke.isNotEmpty) {
      unawaited(ref.read(gmailRestClientProvider).revokeToken(tokenToRevoke));
    }
    await store.delete(homeId);
    state = const GmailImportUiState();
  }

  /// Scans matching Gmail store messages into pending [DraftExpenseOrder]s.
  Future<int?> scanNow() async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    if (!current.isConnected) return null;

    state = state.copyWith(scanning: true, clearError: true);
    try {
      final scanner = ref.read(gmailInvoiceScannerProvider);
      final result = await scanner.scan(current);
      final latest = await store.load(homeId);
      final existingIds = {for (final d in latest.drafts) d.id};
      final mergedDrafts = [
        for (final d in result.newDrafts)
          if (!existingIds.contains(d.id)) d,
        ...latest.drafts,
      ];
      await store.save(
        homeId,
        latest.copyWith(
          tokens: result.updatedTokens,
          connectedEmail: result.email ?? latest.connectedEmail,
          lastScanAtMs: ref.read(clockProvider).nowMs,
          clearLastError: true,
          processedMessageIds: {
            ...latest.processedMessageIds,
            ...result.scannedMessageIds,
          },
          drafts: mergedDrafts,
        ),
      );
      state = state.copyWith(scanning: false, clearError: true);
      return result.newDrafts.length;
    } on GmailApiException catch (e) {
      await _recordError(homeId, e.kind.name);
      return null;
    } on Object {
      await _recordError(homeId, 'other');
      return null;
    }
  }

  /// Parses pasted email or PDF invoice text offline and saves it as a draft.
  Future<DraftExpenseOrder?> importPastedText(String rawText) async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final fallbackDate = ref.read(todayDateProvider);
    final parsed = parseOrderInvoice(
      plainBody: rawText,
      fallbackDate: fallbackDate,
    );
    if (parsed == null) return null;

    final nowMs = ref.read(clockProvider).nowMs;
    final draft = DraftExpenseOrder.fromParsed(
      parsed,
      id: 'pasted_${nowMs}_${parsed.totalPaise}',
      importedAtMs: nowMs,
    );
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(
      homeId,
      current.copyWith(drafts: [draft, ...current.drafts], clearLastError: true),
    );
    return draft;
  }

  Future<void> updateDraft(DraftExpenseOrder updated) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    final nextDrafts = [
      for (final d in current.drafts)
        if (d.id == updated.id) updated else d,
    ];
    await store.save(homeId, current.copyWith(drafts: nextDrafts));
  }

  Future<void> discardDraft(String draftId) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(
      homeId,
      current.copyWith(
        drafts: [
          for (final d in current.drafts)
            if (d.id != draftId) d,
        ],
        processedMessageIds: {...current.processedMessageIds, draftId},
      ),
    );
  }

  /// Writes the approved draft entries to the household ledger (`ChangeWriter`)
  /// and removes the draft from local pending drafts.
  Future<({int count, int totalPaise})?> accountDraft(
    DraftExpenseOrder draft,
  ) async {
    final homeId = _homeId;
    if (homeId == null) return null;
    final spends = draft.plannedSpends();
    if (spends.isEmpty) return null;

    state = state.copyWith(accountingDraftId: draft.id, clearError: true);
    try {
      final moneyRepo = ref.read(moneyRepoProvider);
      final me = ref.read(myMemberIdProvider);
      final payer = draft.paidBy ?? me;
      final noteText = _composeOrderNote(draft);
      var total = 0;

      for (final entry in spends) {
        final cat = spendCategories.contains(entry.category)
            ? entry.category
            : draft.channel.defaultCategory;
        await moneyRepo.addSpend(
          NewExpense(
            amountPaise: entry.amountPaise,
            merchant: entry.merchant,
            category: cat,
            method: draft.method,
            date: draft.date,
            source: 'order',
            orderChannel: draft.channel.id,
            paidBy: payer,
            note: noteText,
          ),
        );
        total += entry.amountPaise;
      }

      final store = ref.read(gmailImportStoreProvider);
      final current = await store.load(homeId);
      await store.save(
        homeId,
        current.copyWith(
          drafts: [
            for (final d in current.drafts)
              if (d.id != draft.id) d,
          ],
          processedMessageIds: {...current.processedMessageIds, draft.id},
        ),
      );
      state = state.copyWith(clearAccounting: true);
      return (count: spends.length, totalPaise: total);
    } on Object {
      state = state.copyWith(clearAccounting: true);
      rethrow;
    }
  }

  String? _composeOrderNote(DraftExpenseOrder draft) {
    final note = draft.note?.trim() ?? '';
    final oid = draft.orderId?.trim() ?? '';
    if (note.isNotEmpty && oid.isNotEmpty) return '$note (Order $oid)';
    if (note.isNotEmpty) return note;
    if (oid.isNotEmpty) return 'Order $oid';
    return null;
  }

  Future<void> _recordError(String homeId, String code) async {
    final store = ref.read(gmailImportStoreProvider);
    final current = await store.load(homeId);
    await store.save(homeId, current.copyWith(lastError: code));
    state = state.copyWith(
      connecting: false,
      scanning: false,
      errorCode: code,
    );
  }
}
