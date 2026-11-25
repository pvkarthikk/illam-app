import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';

void main() {
  group('remote_sync_config_parser', () {
    test('parses Firebase Console JavaScript firebaseConfig snippet', () {
      const snippet = '''
const firebaseConfig = {
  apiKey: "AIzaSyTestKey1234567890",
  authDomain: "family-illam.firebaseapp.com",
  projectId: "family-illam",
  storageBucket: "family-illam.appspot.com",
  messagingSenderId: "123456",
  appId: "1:123456:web:abc"
};
''';
      final parsed = parseFirebaseConfigSnippet(snippet);
      expect(
        parsed,
        const ParsedFirebaseConfig(
          projectId: 'family-illam',
          apiKey: 'AIzaSyTestKey1234567890',
          databaseId: '(default)',
        ),
      );
    });

    test('parses JSON config including custom databaseId', () {
      const raw =
          '{"projectId":"my-home-12","apiKey":"AIzaSyAbCdEfGhIjKlMn","databaseId":"eu-db"}';
      final parsed = parseFirebaseConfigSnippet(raw);
      expect(
        parsed,
        const ParsedFirebaseConfig(
          projectId: 'my-home-12',
          apiKey: 'AIzaSyAbCdEfGhIjKlMn',
          databaseId: 'eu-db',
        ),
      );
    });

    test('round-trips illam-remote://v1 share URI with and without custom db', () {
      const def = ParsedFirebaseConfig(
        projectId: 'illam-home',
        apiKey: 'AIzaSy1234567890abcd',
      );
      final uriDef = encodeRemoteShareUri(def);
      expect(uriDef.contains('&d='), isFalse);
      expect(parseRemoteShareUri(uriDef), def);
      expect(parseFirebaseConfigSnippet(uriDef), def);

      const custom = ParsedFirebaseConfig(
        projectId: 'illam-home',
        apiKey: 'AIzaSy1234567890abcd',
        databaseId: 'home-eu',
      );
      final uriCustom = encodeRemoteShareUri(custom);
      expect(uriCustom.contains('&d=home-eu'), isTrue);
      expect(parseRemoteShareUri(uriCustom), custom);
    });

    test('returns null when projectId or apiKey is missing', () {
      expect(parseFirebaseConfigSnippet('just random text'), isNull);
      expect(parseFirebaseConfigSnippet('{"projectId": "only-id"}'), isNull);
      expect(parseRemoteShareUri('https://example.com?p=a&k=b'), isNull);
    });

    test('validates projectId, apiKey, and databaseId rules', () {
      expect(
        validateFirebaseConfig(
          projectId: 'family-illam-1',
          apiKey: 'AIzaSy1234567890abcd',
          databaseId: '',
        ),
        isEmpty,
      );

      final bad = validateFirebaseConfig(
        projectId: 'Bad Project!',
        apiKey: 'short',
        databaseId: 'Invalid DB!',
      );
      expect(bad['projectId'], FirebaseConfigFieldError.projectIdInvalid);
      expect(bad['apiKey'], FirebaseConfigFieldError.apiKeyInvalid);
      expect(bad['databaseId'], FirebaseConfigFieldError.databaseIdInvalid);

      final empty = validateFirebaseConfig(projectId: '', apiKey: '');
      expect(empty['projectId'], FirebaseConfigFieldError.projectIdEmpty);
      expect(empty['apiKey'], FirebaseConfigFieldError.apiKeyEmpty);
    });

    test('kRemoteSyncFirestoreRules restricts root and validates server timestamp', () {
      expect(kRemoteSyncFirestoreRules, contains('request.auth != null'));
      expect(kRemoteSyncFirestoreRules, contains('request.time'));
      expect(kRemoteSyncFirestoreRules, contains('illam_channels/{channelId}/batches/{batchId}'));
      expect(kRemoteSyncFirestoreRules, contains('illam_channels/{channelId}/probes/{uid}'));
      expect(kRemoteSyncFirestoreRules, contains('allow update, delete: if false'));
    });
  });
}
