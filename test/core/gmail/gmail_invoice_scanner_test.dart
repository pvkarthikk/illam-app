import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/gmail/gmail_invoice_scanner.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart';
import 'package:nm_flat/core/gmail/pdf_text_extractor.dart';

import '../backup/cloud/fake_token_adapter.dart';

class _FakePdfExtractor implements PdfTextExtractor {
  _FakePdfExtractor(this.text);

  final String text;
  int calls = 0;

  @override
  Future<String> extractText(Uint8List bytes) async {
    calls++;
    return text;
  }
}

void main() {
  const oauth = GmailOAuthCredentials(
    clientId: '123456-scan.apps.googleusercontent.com',
    clientSecret: 'GOCSPX-scan',
  );

  group('GmailInvoiceScanner', () {
    test(
      'refreshes near-expiry token, skips known IDs, extracts PDF invoice into draft',
      () async {
        final adapter = FakeAdapter()
          ..replies.add((
            200,
            jsonEncode({'access_token': 'fresh-tok', 'expires_in': 3600}),
          ))
          ..replies.add((
            200,
            jsonEncode({
              'messages': [
                {'id': 'already-seen'},
                {'id': 'msg-pdf'},
                {'id': 'msg-promo'},
              ],
            }),
          ))
          ..replies.add((
            200,
            jsonEncode({
              'id': 'msg-pdf',
              'internalDate':
                  '${DateTime(2026, 11, 22, 11, 0).millisecondsSinceEpoch}',
              'payload': {
                'mimeType': 'multipart/mixed',
                'headers': [
                  {'name': 'From', 'value': 'Blinkit <orders@blinkit.com>'},
                  {'name': 'Subject', 'value': 'Invoice for order BLK-42'},
                ],
                'parts': [
                  {
                    'mimeType': 'text/plain',
                    'body': {
                      'data': b64url(utf8.encode('Your invoice is attached.')),
                    },
                  },
                  {
                    'mimeType': 'application/pdf',
                    'filename': 'blinkit_tax_invoice.pdf',
                    'body': {'attachmentId': 'att-pdf', 'size': 400},
                  },
                ],
              },
            }),
          ))
          ..replies.add((
            200,
            jsonEncode({
              'data': b64url(Uint8List.fromList([1, 2, 3, 4])),
            }),
          ))
          ..replies.add((
            200,
            jsonEncode({
              'id': 'msg-promo',
              'internalDate':
                  '${DateTime(2026, 11, 22, 12, 0).millisecondsSinceEpoch}',
              'payload': {
                'mimeType': 'text/plain',
                'headers': [
                  {'name': 'From', 'value': 'offers@blinkit.com'},
                  {'name': 'Subject', 'value': 'Up to ₹300 off today!'},
                ],
                'body': {
                  'data': b64url(
                    utf8.encode('Shop now and get ₹300 off with code BLINK'),
                  ),
                },
              },
            }),
          ));

        const nowMs = 1700000000000;
        final dio = Dio(BaseOptions(validateStatus: (_) => true))
          ..httpClientAdapter = adapter;
        final client = GmailRestClient(dio: dio, nowMs: () => nowMs);
        final pdf = _FakePdfExtractor('''
Blink Commerce Private Limited
Order ID: BLK-42
Invoice Date: 22/11/2026
1. Amul Butter 100g 1 58.00 58.00
2. Harvest Gold Bread 1 42.00 42.00
Grand Total: ₹100.00
''');
        final scanner = GmailInvoiceScanner(
          client: client,
          pdfExtractor: pdf,
          nowMs: () => nowMs,
        );

        const cfg = GmailImportConfig(
          enabled: true,
          oauth: oauth,
          tokens: OAuthTokens(
            accessToken: 'stale-tok',
            refreshToken: 'ref-tok',
            expiresAtMs: nowMs + 60000, // within 5 min window -> triggers refresh
          ),
          connectedEmail: 'karthik@example.com',
          scanDays: 30,
          processedMessageIds: {'already-seen'},
        );

        final result = await scanner.scan(cfg);
        expect(result.updatedTokens.accessToken, 'fresh-tok');
        expect(result.messagesExamined, 2);
        expect(result.skippedCount, 1);
        expect(result.scannedMessageIds, {'msg-pdf', 'msg-promo'});
        expect(pdf.calls, 1);
        expect(result.newDrafts.length, 1);
        final draft = result.newDrafts.first;
        expect(draft.channel, InvoiceChannel.blinkit);
        expect(draft.totalPaise, 10000);
        expect(draft.items.length, 2);
        expect(draft.items[0].name, 'Amul Butter 100g');
        expect(draft.items[1].amountPaise, 4200);
      },
    );
  });
}
