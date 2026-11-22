import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:url_launcher/url_launcher.dart';

/// Captures pCloud OAuth redirect URIs before `go_router` can handle them.
class PcloudRedirectCatcher with WidgetsBindingObserver {
  static Completer<Uri>? pending;

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    if (!uri.scheme.endsWith('.pcloud')) return false;
    final completer = pending;
    pending = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(uri);
    }
    return true;
  }
}

/// pCloud browser-based OAuth implicit-flow helper.
class PcloudAuth {
  PcloudAuth._();

  static Uri authorizeUrl(String clientId, String redirect, String state) =>
      Uri.https('my.pcloud.com', '/oauth2/authorize', {
        'client_id': clientId,
        'response_type': 'token',
        'redirect_uri': redirect,
        'state': state,
      });

  static ({String token, String host}) parseRedirect(
    Uri u,
    String expectedState,
  ) {
    final raw = u.fragment.isNotEmpty ? u.fragment : u.query;
    final params = Uri.splitQueryString(raw);
    if (params['state'] != expectedState) {
      throw const DestinationException(DestError.other);
    }
    final token = params['access_token'];
    if (token == null || token.isEmpty) {
      throw const DestinationException(DestError.auth);
    }
    var host = params['hostname'];
    if (host == null || host.isEmpty) {
      host = params['locationid'] == '2' ? 'eapi.pcloud.com' : 'api.pcloud.com';
    }
    if (host != 'api.pcloud.com' && host != 'eapi.pcloud.com') {
      throw const DestinationException(DestError.other);
    }
    return (token: token, host: host);
  }

  static Future<({String token, String host})?> signIn() async {
    final state = randomHex(16);
    final completer = Completer<Uri>();
    PcloudRedirectCatcher.pending = completer;

    final url = authorizeUrl(
      CloudIds.pcloudClientId,
      await pcloudRedirect(),
      state,
    );
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      PcloudRedirectCatcher.pending = null;
      return null;
    }
    try {
      final uri = await completer.future.timeout(const Duration(minutes: 10));
      return parseRedirect(uri, state);
    } on TimeoutException {
      if (identical(PcloudRedirectCatcher.pending, completer)) {
        PcloudRedirectCatcher.pending = null;
      }
      return null;
    }
  }
}
