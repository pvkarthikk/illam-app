/// OAuth access/refresh tokens persisted as JSON in [DestinationSecrets].
class OAuthTokens {
  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAtMs,
  });

  factory OAuthTokens.fromJson(Map<String, Object?> j) => OAuthTokens(
    accessToken: (j['accessToken'] as String?) ?? '',
    refreshToken: j['refreshToken'] as String?,
    expiresAtMs: (j['expiresAtMs'] as num?)?.toInt() ?? 0,
  );

  final String accessToken;
  final String? refreshToken;
  final int expiresAtMs;

  bool expiresSoon(int nowMs) => expiresAtMs - nowMs < 300000;

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAtMs': expiresAtMs,
  };

  OAuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresAtMs,
  }) => OAuthTokens(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    expiresAtMs: expiresAtMs ?? this.expiresAtMs,
  );
}

/// Static OAuth 2.0 endpoint configuration for an AppAuth provider.
class OAuthProvider {
  const OAuthProvider({
    required this.name,
    required this.clientId,
    required this.authEndpoint,
    required this.tokenEndpoint,
    required this.scopes,
    this.extraAuthParams = const {},
    this.prompt,
    this.scopeOnRefresh = false,
  });

  final String name;
  final String Function() clientId;
  final Uri authEndpoint;
  final Uri tokenEndpoint;
  final List<String> scopes;
  final Map<String, String> extraAuthParams;
  final List<String>? prompt;
  final bool scopeOnRefresh;
}
