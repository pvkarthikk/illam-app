import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/domain/invoice/store_parsers.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart';
import 'package:nm_flat/core/gmail/pdf_text_extractor.dart';

/// Result of one Gmail scan pass across matching store emails.
class GmailScanResult {
  const GmailScanResult({
    required this.updatedTokens,
    this.email,
    required this.newDrafts,
    required this.scannedMessageIds,
    required this.messagesExamined,
    required this.skippedCount,
  });

  final OAuthTokens updatedTokens;
  final String? email;
  final List<DraftExpenseOrder> newDrafts;
  final Set<String> scannedMessageIds;
  final int messagesExamined;
  final int skippedCount;
}

/// Searches Gmail for Zepto/Blinkit/Amazon/Flipkart orders, parses HTML/PDF
/// invoices, and produces unapproved [DraftExpenseOrder]s.
class GmailInvoiceScanner {
  GmailInvoiceScanner({
    required this.client,
    required this.pdfExtractor,
    ClockMs? nowMs,
  }) : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  static const _maxAttachmentBytes = 5 * 1024 * 1024;
  static const _maxPdfPerMessage = 2;

  final GmailRestClient client;
  final PdfTextExtractor pdfExtractor;
  final ClockMs _nowMs;

  /// Builds the Gmail search query covering the four supported retailers.
  static String buildQuery(int scanDays) =>
      '(from:(zepto OR zeptonow OR blinkit OR grofers OR amazon.in OR flipkart) '
      'OR subject:(Zepto OR Blinkit OR Amazon OR Flipkart)) '
      '(order OR invoice OR receipt OR delivered OR bill OR total) '
      'newer_than:${scanDays}d';

  /// Refreshes tokens if needed, scans unread/read matching emails not yet
  /// processed, and returns newly parsed drafts + updated processed message IDs.
  Future<GmailScanResult> scan(
    GmailImportConfig config, {
    int maxMessages = 40,
  }) async {
    final oauth = config.oauth;
    final initialTokens = config.tokens;
    if (oauth == null || initialTokens == null) {
      throw const GmailApiException(
        GmailApiErrorKind.unauthorized,
        'Gmail is not connected',
      );
    }

    final now = _nowMs();
    var tokens = initialTokens;
    var refreshed = false;
    if (tokens.expiresSoon(now)) {
      tokens = await client.refreshTokens(credentials: oauth, current: tokens);
      refreshed = true;
    }

    try {
      return await _runScan(
        config: config,
        oauth: oauth,
        tokens: tokens,
        maxMessages: maxMessages,
      );
    } on GmailApiException catch (e) {
      final hasRefresh =
          tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty;
      if (e.kind == GmailApiErrorKind.unauthorized &&
          !refreshed &&
          hasRefresh) {
        final fresh = await client.refreshTokens(
          credentials: oauth,
          current: tokens,
        );
        return _runScan(
          config: config,
          oauth: oauth,
          tokens: fresh,
          maxMessages: maxMessages,
        );
      }
      rethrow;
    }
  }

  Future<GmailScanResult> _runScan({
    required GmailImportConfig config,
    required GmailOAuthCredentials oauth,
    required OAuthTokens tokens,
    required int maxMessages,
  }) async {
    var email = config.connectedEmail;
    if (email == null || email.isEmpty) {
      email = await client.fetchProfileEmail(tokens.accessToken);
    }

    final knownIds = <String>{
      ...config.processedMessageIds,
      for (final d in config.drafts) d.id,
    };

    final candidateIds = <String>[];
    String? pageToken;
    while (candidateIds.length < maxMessages) {
      final remaining = maxMessages - candidateIds.length;
      final page = await client.listMessageIds(
        tokens.accessToken,
        query: buildQuery(config.scanDays),
        maxResults: remaining > 25 ? 25 : remaining,
        pageToken: pageToken,
      );
      for (final id in page.ids) {
        if (!knownIds.contains(id) && !candidateIds.contains(id)) {
          candidateIds.add(id);
        }
      }
      if (page.nextPageToken == null ||
          page.nextPageToken!.isEmpty ||
          page.ids.isEmpty) {
        break;
      }
      pageToken = page.nextPageToken;
    }

    final newDrafts = <DraftExpenseOrder>[];
    final newlyScannedIds = <String>{};
    var skipped = 0;

    for (final msgId in candidateIds) {
      final msg = await client.fetchMessage(tokens.accessToken, msgId);
      final pdfText = await _extractBestPdfText(tokens.accessToken, msg);
      final parsed = parseOrderInvoice(
        fromEmail: msg.fromEmail,
        subject: msg.subject,
        htmlBody: msg.htmlBody,
        plainBody: msg.plainBody,
        pdfText: pdfText,
        fallbackDate: msg.localDateIso,
      );
      newlyScannedIds.add(msgId);
      if (parsed == null) {
        skipped++;
        continue;
      }
      newDrafts.add(
        DraftExpenseOrder.fromParsed(
          parsed,
          id: msgId,
          importedAtMs: _nowMs(),
          subject: msg.subject,
          fromEmail: msg.fromEmail,
        ),
      );
    }

    return GmailScanResult(
      updatedTokens: tokens,
      email: email,
      newDrafts: newDrafts,
      scannedMessageIds: newlyScannedIds,
      messagesExamined: candidateIds.length,
      skippedCount: skipped,
    );
  }

  Future<String?> _extractBestPdfText(
    String accessToken,
    GmailFetchedMessage msg,
  ) async {
    if (msg.pdfAttachments.isEmpty) return null;

    // Prioritize invoice/receipt-named PDFs first, up to [_maxPdfPerMessage].
    final prioritized = [...msg.pdfAttachments]
      ..sort(
        (a, b) => _pdfPriority(b.filename).compareTo(_pdfPriority(a.filename)),
      );

    final chunks = <String>[];
    var count = 0;
    for (final att in prioritized) {
      if (count >= _maxPdfPerMessage) break;
      if (att.sizeBytes > _maxAttachmentBytes) continue;
      count++;
      final bytes = await client.fetchAttachmentBytes(accessToken, msg.id, att);
      if (bytes.isEmpty || bytes.lengthInBytes > _maxAttachmentBytes) continue;
      final text = await pdfExtractor.extractText(bytes);
      if (text.trim().isNotEmpty) {
        chunks.add(text);
      }
    }
    return chunks.isEmpty ? null : chunks.join('\n');
  }

  int _pdfPriority(String filename) {
    final lower = filename.toLowerCase();
    var score = 0;
    if (lower.contains('invoice')) score += 4;
    if (lower.contains('tax')) score += 3;
    if (lower.contains('receipt') || lower.contains('bill')) score += 2;
    if (lower.contains('order')) score += 1;
    return score;
  }
}
