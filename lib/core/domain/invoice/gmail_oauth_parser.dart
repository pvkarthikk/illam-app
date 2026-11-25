import 'dart:convert';

/// OAuth 2.0 Desktop App client credentials supplied by the user (BYO Google).
class GmailOAuthCredentials {
  const GmailOAuthCredentials({
    required this.clientId,
    required this.clientSecret,
  });

  final String clientId;
  final String clientSecret;

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientSecret': clientSecret,
      };

  static GmailOAuthCredentials? fromJson(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final id = (raw['clientId'] as String?)?.trim() ?? '';
    final secret = (raw['clientSecret'] as String?)?.trim() ?? '';
    if (id.isEmpty || secret.isEmpty) return null;
    return GmailOAuthCredentials(clientId: id, clientSecret: secret);
  }
}

/// Reason why pasted Gmail OAuth credentials failed validation.
enum GmailOAuthParseError {
  empty,
  malformed,
  webClientNotSupported,
  invalidClientId,
  missingClientSecret,
}

/// Outcome of parsing pasted Google Desktop App OAuth credentials.
class GmailOAuthParseResult {
  const GmailOAuthParseResult._({this.credentials, this.error});

  const GmailOAuthParseResult.ok(GmailOAuthCredentials credentials)
      : this._(credentials: credentials);

  const GmailOAuthParseResult.fail(GmailOAuthParseError error)
      : this._(error: error);

  final GmailOAuthCredentials? credentials;
  final GmailOAuthParseError? error;

  bool get isValid => credentials != null;
}

final _clientIdPattern = RegExp(
  r'^[A-Za-z0-9][A-Za-z0-9._\-]{4,}\.apps\.googleusercontent\.com$',
);

/// Validates an individual client ID and client secret pair.
GmailOAuthParseResult validateGmailOAuthPair(
  String clientIdRaw,
  String clientSecretRaw,
) {
  final clientId = clientIdRaw.trim();
  final clientSecret = clientSecretRaw.trim();
  if (clientId.isEmpty && clientSecret.isEmpty) {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.empty);
  }
  if (!_clientIdPattern.hasMatch(clientId)) {
    return const GmailOAuthParseResult.fail(
      GmailOAuthParseError.invalidClientId,
    );
  }
  if (clientSecret.isEmpty) {
    return const GmailOAuthParseResult.fail(
      GmailOAuthParseError.missingClientSecret,
    );
  }
  return GmailOAuthParseResult.ok(
    GmailOAuthCredentials(clientId: clientId, clientSecret: clientSecret),
  );
}

/// Parses downloaded Google Cloud Desktop OAuth JSON or labeled text lines.
GmailOAuthParseResult parseGmailOAuthInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.empty);
  }
  if (trimmed.startsWith('{')) {
    return _parseJson(trimmed);
  }
  return _parseLines(trimmed);
}

GmailOAuthParseResult _parseJson(String raw) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.malformed);
  }
  if (decoded is! Map<String, dynamic>) {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.malformed);
  }
  final installed = decoded['installed'];
  if (installed is Map<String, dynamic>) {
    return _fromJsonMap(installed);
  }
  if (decoded.containsKey('web') && !decoded.containsKey('client_id')) {
    return const GmailOAuthParseResult.fail(
      GmailOAuthParseError.webClientNotSupported,
    );
  }
  return _fromJsonMap(decoded);
}

GmailOAuthParseResult _fromJsonMap(Map<String, dynamic> map) {
  final clientId =
      (map['client_id'] ?? map['clientId'])?.toString().trim() ?? '';
  final clientSecret =
      (map['client_secret'] ?? map['clientSecret'])?.toString().trim() ?? '';
  if (clientId.isEmpty && clientSecret.isEmpty) {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.malformed);
  }
  return validateGmailOAuthPair(clientId, clientSecret);
}

GmailOAuthParseResult _parseLines(String raw) {
  String? clientId;
  String? clientSecret;
  final bareLines = <String>[];

  for (final line in raw.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final kv = _extractKeyValue(trimmed);
    if (kv != null) {
      final (key, value) = kv;
      if (key == 'client_id' || key == 'clientid') {
        clientId = value;
      } else if (key == 'client_secret' || key == 'clientsecret') {
        clientSecret = value;
      }
      continue;
    }
    bareLines.add(trimmed);
  }

  if (clientId == null && bareLines.isNotEmpty) {
    for (final line in bareLines) {
      if (_clientIdPattern.hasMatch(line)) {
        clientId = line;
      } else {
        clientSecret ??= line;
      }
    }
  }
  if (clientId == null) {
    return const GmailOAuthParseResult.fail(GmailOAuthParseError.malformed);
  }
  return validateGmailOAuthPair(clientId, clientSecret ?? '');
}

(String, String)? _extractKeyValue(String line) {
  final match = RegExp(r'^([A-Za-z0-9_ \-]+?)\s*[:=]\s*(.+)$').firstMatch(line);
  if (match == null) return null;
  final rawKey = match.group(1)!.trim().toLowerCase().replaceAll(
        RegExp(r'[\s\-]+'),
        '_',
      );
  final value = _stripQuotes(match.group(2)!.trim());
  if (rawKey.contains('client') && rawKey.contains('id')) {
    return ('client_id', value);
  }
  if (rawKey.contains('client') && rawKey.contains('secret')) {
    return ('client_secret', value);
  }
  return null;
}

String _stripQuotes(String s) {
  if (s.length >= 2 &&
      ((s.startsWith('"') && s.endsWith('"')) ||
          (s.startsWith("'") && s.endsWith("'")))) {
    return s.substring(1, s.length - 1).trim();
  }
  return s;
}
