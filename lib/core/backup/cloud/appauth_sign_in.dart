import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';

final OAuthProvider dropboxOAuth = OAuthProvider(
  name: 'Dropbox',
  clientId: () => CloudIds.dropboxAppKey,
  authEndpoint: Uri.parse('https://www.dropbox.com/oauth2/authorize'),
  tokenEndpoint: Uri.parse('https://api.dropboxapi.com/oauth2/token'),
  scopes: const [
    'account_info.read',
    'files.metadata.read',
    'files.content.read',
    'files.content.write',
  ],
  extraAuthParams: const {'token_access_type': 'offline'},
  scopeOnRefresh: false,
);

/// Runs authorization code + PKCE sign-in in a Custom Tab; `null` on cancel.
Future<OAuthTokens?> appAuthSignIn(OAuthProvider p) async {
  try {
    final redirect = await appAuthRedirect();
    final res = await const FlutterAppAuth().authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        p.clientId(),
        redirect,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: p.authEndpoint.toString(),
          tokenEndpoint: p.tokenEndpoint.toString(),
        ),
        scopes: p.scopes,
        additionalParameters:
            p.extraAuthParams.isEmpty ? null : p.extraAuthParams,
        promptValues: p.prompt,
      ),
    );
    final accessToken = res.accessToken;
    if (accessToken == null || accessToken.isEmpty) return null;
    final expiresAtMs =
        res.accessTokenExpirationDateTime?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch + 3600000;
    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: res.refreshToken,
      expiresAtMs: expiresAtMs,
    );
  } on FlutterAppAuthUserCancelledException {
    return null;
  }
}
