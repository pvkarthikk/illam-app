import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';

/// Google OAuth 2.0 (authorization code + PKCE) for the Drive `appDataFolder`.
///
/// Uses `flutter_appauth` and a Custom Tab instead of Google Play Services so
/// the app contains no proprietary dependencies.
final OAuthProvider googleOAuth = OAuthProvider(
  name: 'Google Drive',
  clientId: () => CloudIds.googleServerClientId,
  authEndpoint: Uri.parse('https://accounts.google.com/o/oauth2/v2/auth'),
  tokenEndpoint: Uri.parse('https://oauth2.googleapis.com/token'),
  scopes: const ['openid', 'email', drive.DriveApi.driveAppdataScope],
  extraAuthParams: const {'access_type': 'offline'},
  prompt: const ['consent'],
);

/// `http.Client` that attaches a fresh Bearer token from [TokenKeeper].
class KeeperHttpClient extends http.BaseClient {
  KeeperHttpClient(this.keeper, [http.Client? inner])
    : _inner = inner ?? http.Client();

  final TokenKeeper keeper;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer ${await keeper.accessToken()}';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
