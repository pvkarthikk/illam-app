import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';

void main() {
  group('parseGmailOAuthInput', () {
    test('parses downloaded Google Cloud Desktop app JSON', () {
      const json = '''
{
  "installed": {
    "client_id": "1234567890-abcdef.apps.googleusercontent.com",
    "project_id": "illam-mail-sync",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "client_secret": "GOCSPX-secretValue123",
    "redirect_uris": ["http://localhost"]
  }
}
''';
      final res = parseGmailOAuthInput(json);
      expect(res.isValid, isTrue);
      expect(
        res.credentials!.clientId,
        '1234567890-abcdef.apps.googleusercontent.com',
      );
      expect(res.credentials!.clientSecret, 'GOCSPX-secretValue123');
    });

    test('rejects Web application OAuth JSON with guidance error', () {
      const webJson = '''
{
  "web": {
    "client_id": "1234567890-web.apps.googleusercontent.com",
    "client_secret": "GOCSPX-websecret"
  }
}
''';
      final res = parseGmailOAuthInput(webJson);
      expect(res.isValid, isFalse);
      expect(res.error, GmailOAuthParseError.webClientNotSupported);
    });

    test('parses labeled key/value lines and flat bare lines', () {
      const text = '''
Client ID: "99999-testapp.apps.googleusercontent.com"
Client secret: GOCSPX-lineSecret
''';
      final res = parseGmailOAuthInput(text);
      expect(res.isValid, isTrue);
      expect(
        res.credentials!.clientId,
        '99999-testapp.apps.googleusercontent.com',
      );
      expect(res.credentials!.clientSecret, 'GOCSPX-lineSecret');
    });

    test('rejects empty, malformed, bad clientId, and missing secret', () {
      expect(parseGmailOAuthInput('   ').error, GmailOAuthParseError.empty);
      expect(
        parseGmailOAuthInput('{bad json').error,
        GmailOAuthParseError.malformed,
      );
      expect(
        validateGmailOAuthPair('not-a-google-id', 'secret').error,
        GmailOAuthParseError.invalidClientId,
      );
      expect(
        validateGmailOAuthPair(
          '123456-valid.apps.googleusercontent.com',
          '  ',
        ).error,
        GmailOAuthParseError.missingClientSecret,
      );
    });
  });
}
