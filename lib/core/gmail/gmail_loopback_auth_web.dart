import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';

/// Failure modes matching the native loopback authenticator interface.
enum GmailLoopbackErrorKind {
  unsupportedPlatform,
  couldNotOpenBrowser,
  userDeniedAccess,
  timedOut,
  cancelled,
  stateMismatch,
  missingCode,
  bindFailed,
}

class GmailLoopbackException implements Exception {
  const GmailLoopbackException(this.kind, [this.detail]);

  final GmailLoopbackErrorKind kind;
  final String? detail;

  @override
  String toString() => 'GmailLoopbackException($kind, $detail)';
}

/// Authorization code + PKCE verifier returned by the loopback redirect.
class GmailAuthCodeResult {
  const GmailAuthCodeResult({
    required this.code,
    required this.codeVerifier,
    required this.redirectUri,
  });

  final String code;
  final String codeVerifier;
  final String redirectUri;
}

typedef ExternalUrlLauncher = Future<bool> Function(Uri url);

/// Web stub: browsers cannot bind a localhost HTTP loopback server.
class GmailLoopbackAuthenticator {
  GmailLoopbackAuthenticator({ExternalUrlLauncher? launcher});

  Future<void> cancel() async {}

  Future<GmailAuthCodeResult> authorize(
    GmailOAuthCredentials credentials, {
    Duration timeout = const Duration(minutes: 3),
  }) async {
    throw const GmailLoopbackException(
      GmailLoopbackErrorKind.unsupportedPlatform,
    );
  }
}
