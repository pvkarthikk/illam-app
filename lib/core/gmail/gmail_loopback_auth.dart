import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:url_launcher/url_launcher.dart';

const _gmailReadonlyScope = 'https://www.googleapis.com/auth/gmail.readonly';

/// Failure modes for the interactive browser + localhost loopback sign-in.
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

Future<bool> _defaultLaunch(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// Runs RFC 8252 loopback OAuth 2.0 + PKCE (`S256`) using a Desktop OAuth client.
class GmailLoopbackAuthenticator {
  GmailLoopbackAuthenticator({ExternalUrlLauncher? launcher})
      : _launcher = launcher ?? _defaultLaunch;

  final ExternalUrlLauncher _launcher;
  HttpServer? _activeServer;
  Completer<void>? _cancelCompleter;

  /// Cancels an in-flight OAuth browser wait, if any.
  Future<void> cancel() async {
    final c = _cancelCompleter;
    if (c != null && !c.isCompleted) {
      c.completeError(
        const GmailLoopbackException(GmailLoopbackErrorKind.cancelled),
      );
    }
    await _closeServer();
  }

  /// Opens the user's browser for Google consent and waits for the loopback code.
  Future<GmailAuthCodeResult> authorize(
    GmailOAuthCredentials credentials, {
    Duration timeout = const Duration(minutes: 3),
  }) async {
    await cancel();

    final HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } on SocketException catch (e) {
      throw GmailLoopbackException(
        GmailLoopbackErrorKind.bindFailed,
        e.message,
      );
    }
    _activeServer = server;
    final cancelCompleter = Completer<void>();
    _cancelCompleter = cancelCompleter;

    final codeVerifier = b64url(randomBytes(48));
    final challengeBytes = await sha256Of(ascii.encode(codeVerifier));
    final codeChallenge = b64url(challengeBytes);
    final expectedState = b64url(randomBytes(24));
    final redirectUri = 'http://127.0.0.1:${server.port}/oauth2redirect';

    final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': credentials.clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': _gmailReadonlyScope,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'access_type': 'offline',
      'prompt': 'consent',
      'state': expectedState,
    });

    final resultCompleter = Completer<GmailAuthCodeResult>();
    final subscription = server.listen(
      (HttpRequest req) async {
        if (req.uri.path == '/favicon.ico') {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
          return;
        }
        final params = req.uri.queryParameters;
        final error = params['error'];
        final state = params['state'];
        final code = params['code'];

        if (error != null && error.isNotEmpty) {
          await _respondHtml(
            req.response,
            ok: false,
            message: 'Sign-in did not complete ($error). Return to Illam.',
          );
          if (!resultCompleter.isCompleted) {
            resultCompleter.completeError(
              GmailLoopbackException(
                error == 'access_denied'
                    ? GmailLoopbackErrorKind.userDeniedAccess
                    : GmailLoopbackErrorKind.missingCode,
                error,
              ),
            );
          }
          return;
        }
        if (state != expectedState) {
          await _respondHtml(
            req.response,
            ok: false,
            message: 'OAuth state mismatch. Return to Illam and try again.',
          );
          if (!resultCompleter.isCompleted) {
            resultCompleter.completeError(
              const GmailLoopbackException(GmailLoopbackErrorKind.stateMismatch),
            );
          }
          return;
        }
        if (code == null || code.isEmpty) {
          await _respondHtml(
            req.response,
            ok: false,
            message: 'Missing authorization code. Return to Illam.',
          );
          if (!resultCompleter.isCompleted) {
            resultCompleter.completeError(
              const GmailLoopbackException(GmailLoopbackErrorKind.missingCode),
            );
          }
          return;
        }

        await _respondHtml(
          req.response,
          ok: true,
          message: 'Gmail connected to Illam. You can close this tab now.',
        );
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(
            GmailAuthCodeResult(
              code: code,
              codeVerifier: codeVerifier,
              redirectUri: redirectUri,
            ),
          );
        }
      },
      onError: (Object err) {
        if (!resultCompleter.isCompleted) {
          resultCompleter.completeError(err);
        }
      },
    );

    try {
      final launched = await _launcher(authUri);
      if (!launched) {
        throw const GmailLoopbackException(
          GmailLoopbackErrorKind.couldNotOpenBrowser,
        );
      }

      return await Future.any([
        resultCompleter.future,
        cancelCompleter.future.then<GmailAuthCodeResult>(
          (_) => throw const GmailLoopbackException(
            GmailLoopbackErrorKind.cancelled,
          ),
        ),
      ]).timeout(
        timeout,
        onTimeout: () => throw const GmailLoopbackException(
          GmailLoopbackErrorKind.timedOut,
        ),
      );
    } finally {
      await subscription.cancel();
      await _closeServer();
      if (_cancelCompleter == cancelCompleter) {
        _cancelCompleter = null;
      }
    }
  }

  Future<void> _closeServer() async {
    final s = _activeServer;
    _activeServer = null;
    if (s != null) {
      await s.close(force: true);
    }
  }

  Future<void> _respondHtml(
    HttpResponse res, {
    required bool ok,
    required String message,
  }) async {
    res.statusCode = ok ? HttpStatus.ok : HttpStatus.badRequest;
    res.headers.contentType = ContentType.html;
    final safe = const HtmlEscape().convert(message);
    res.write(
      '<!doctype html><html><head><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width,initial-scale=1">'
      '<title>Illam Gmail Import</title>'
      '<style>body{font-family:sans-serif;max-width:440px;margin:64px auto;'
      'padding:0 20px;color:#1f2421;line-height:1.5}'
      'h1{font-size:18px;margin-bottom:8px}</style></head>'
      '<body><h1>${ok ? "Connected" : "Sign-in paused"}</h1>'
      '<p>$safe</p></body></html>',
    );
    await res.close();
  }
}
