import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart';

import '../backup/cloud/fake_token_adapter.dart';

void main() {
  const creds = GmailOAuthCredentials(
    clientId: '123456-test.apps.googleusercontent.com',
    clientSecret: 'GOCSPX-secret',
  );

  GmailRestClient makeClient(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(validateStatus: (_) => true))
      ..httpClientAdapter = adapter;
    return GmailRestClient(dio: dio, nowMs: () => 1700000000000);
  }

  group('GmailRestClient', () {
    test('exchanges auth code and refreshes tokens preserving refresh token', () async {
      final adapter = FakeAdapter()
        ..replies.add((
          200,
          jsonEncode({
            'access_token': 'acc-1',
            'refresh_token': 'ref-1',
            'expires_in': 3600,
          }),
        ))
        ..replies.add((
          200,
          jsonEncode({
            'access_token': 'acc-2',
            'expires_in': 1800,
          }),
        ));

      final client = makeClient(adapter);
      final initial = await client.exchangeAuthCode(
        credentials: creds,
        code: 'auth-code-123',
        codeVerifier: 'verifier-xyz',
        redirectUri: 'http://127.0.0.1:43210/oauth2redirect',
      );
      expect(initial.accessToken, 'acc-1');
      expect(initial.refreshToken, 'ref-1');
      expect(initial.expiresAtMs, 1700000000000 + 3600000);

      final refreshed = await client.refreshTokens(
        credentials: creds,
        current: initial,
      );
      expect(refreshed.accessToken, 'acc-2');
      expect(refreshed.refreshToken, 'ref-1');
      expect(adapter.requests.length, 2);
      expect(adapter.requests[0].options.path, 'https://oauth2.googleapis.com/token');
    });

    test('walks nested MIME payload and decodes HTML, plain, and PDF refs', () async {
      final adapter = FakeAdapter()
        ..replies.add((
          200,
          jsonEncode({
            'emailAddress': 'karthik@example.com',
          }),
        ))
        ..replies.add((
          200,
          jsonEncode({
            'messages': [
              {'id': 'msg-1', 'threadId': 'thr-1'},
            ],
            'nextPageToken': 'page-2',
          }),
        ))
        ..replies.add((
          200,
          jsonEncode({
            'id': 'msg-1',
            'internalDate': '${DateTime(2026, 11, 20, 14, 30).millisecondsSinceEpoch}',
            'payload': {
              'mimeType': 'multipart/mixed',
              'headers': [
                {'name': 'From', 'value': 'Zepto <orders@zeptonow.com>'},
                {'name': 'Subject', 'value': 'Your Zepto order #ZP-111'},
              ],
              'parts': [
                {
                  'mimeType': 'multipart/alternative',
                  'parts': [
                    {
                      'mimeType': 'text/plain',
                      'body': {'data': b64url(utf8.encode('Plain total ₹199'))},
                    },
                    {
                      'mimeType': 'text/html',
                      'body': {'data': b64url(utf8.encode('<p>Grand Total ₹199</p>'))},
                    },
                  ],
                },
                {
                  'mimeType': 'application/pdf',
                  'filename': 'zepto_invoice.pdf',
                  'body': {'attachmentId': 'att-99', 'size': 1234},
                },
              ],
            },
          }),
        ))
        ..replies.add((
          200,
          jsonEncode({
            'data': b64url(Uint8List.fromList([0x25, 0x50, 0x44, 0x46])),
          }),
        ));

      final client = makeClient(adapter);
      expect(await client.fetchProfileEmail('acc'), 'karthik@example.com');

      final list = await client.listMessageIds('acc', query: 'zepto');
      expect(list.ids, ['msg-1']);
      expect(list.nextPageToken, 'page-2');

      final msg = await client.fetchMessage('acc', 'msg-1');
      expect(msg.fromEmail, 'Zepto <orders@zeptonow.com>');
      expect(msg.subject, 'Your Zepto order #ZP-111');
      expect(msg.localDateIso, '2026-11-20');
      expect(msg.plainBody, 'Plain total ₹199');
      expect(msg.htmlBody, '<p>Grand Total ₹199</p>');
      expect(msg.pdfAttachments.length, 1);
      expect(msg.pdfAttachments.first.attachmentId, 'att-99');

      final pdfBytes = await client.fetchAttachmentBytes(
        'acc',
        'msg-1',
        msg.pdfAttachments.first,
      );
      expect(pdfBytes, [0x25, 0x50, 0x44, 0x46]);
    });

    test('maps HTTP 401, 403, and 429 to structured GmailApiException', () async {
      final adapter = FakeAdapter()
        ..replies.add((401, '{"error":{"message":"Invalid Credentials"}}'))
        ..replies.add((403, '{"error":{"message":"Gmail API has not been used"}}'))
        ..replies.add((429, '{"error":{"message":"Rate Limit Exceeded"}}'));

      final client = makeClient(adapter);
      await expectLater(
        client.fetchProfileEmail('bad'),
        throwsA(
          isA<GmailApiException>().having(
            (e) => e.kind,
            'kind',
            GmailApiErrorKind.unauthorized,
          ),
        ),
      );
      await expectLater(
        client.fetchProfileEmail('bad'),
        throwsA(
          isA<GmailApiException>().having(
            (e) => e.kind,
            'kind',
            GmailApiErrorKind.forbiddenOrApiDisabled,
          ),
        ),
      );
      await expectLater(
        client.fetchProfileEmail('bad'),
        throwsA(
          isA<GmailApiException>().having(
            (e) => e.kind,
            'kind',
            GmailApiErrorKind.rateLimited,
          ),
        ),
      );
    });
  });
}
