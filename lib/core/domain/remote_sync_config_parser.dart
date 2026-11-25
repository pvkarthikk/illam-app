import 'dart:convert';

const String kDefaultFirestoreDatabaseId = '(default)';

/// Recommended Firestore security rules for Bring Your Own Firebase remote sync.
const String kRemoteSyncFirestoreRules = '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /illam_channels/{channelId}/batches/{batchId} {
      allow get, list: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.keys().hasOnly([
             'v', 'sender', 'keyId', 'payload', 'createdAt', 'expiresAt'
           ])
        && request.resource.data.v == 1
        && request.resource.data.sender is string
        && request.resource.data.sender.size() >= 8
        && request.resource.data.sender.size() <= 64
        && request.resource.data.keyId is string
        && request.resource.data.keyId.size() >= 1
        && request.resource.data.keyId.size() <= 128
        && request.resource.data.payload is string
        && request.resource.data.payload.size() >= 1
        && request.resource.data.payload.size() <= 393216
        && request.resource.data.createdAt == request.time
        && request.resource.data.expiresAt is timestamp;
      allow update, delete: if false;
    }

    match /illam_channels/{channelId}/probes/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}''';

enum FirebaseConfigFieldError {
  projectIdEmpty,
  projectIdInvalid,
  apiKeyEmpty,
  apiKeyInvalid,
  databaseIdInvalid,
}

class ParsedFirebaseConfig {
  const ParsedFirebaseConfig({
    required this.projectId,
    required this.apiKey,
    this.databaseId = kDefaultFirestoreDatabaseId,
  });

  final String projectId;
  final String apiKey;
  final String databaseId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedFirebaseConfig &&
          other.projectId == projectId &&
          other.apiKey == apiKey &&
          other.databaseId == databaseId;

  @override
  int get hashCode => Object.hash(projectId, apiKey, databaseId);
}

final _projectIdRe = RegExp(r'^[a-z0-9][a-z0-9-]{2,62}$');
final _databaseIdRe = RegExp(r'^[a-z0-9][a-z0-9-]{0,62}$');
final _whitespaceRe = RegExp(r'\s');

/// Normalizes [raw] database ID, mapping empty input to `(default)`.
String normalizeDatabaseId(String raw) {
  final trimmed = raw.trim();
  return trimmed.isEmpty ? kDefaultFirestoreDatabaseId : trimmed;
}

/// Validates Firebase project ID, Web API key, and optional Firestore database ID.
Map<String, FirebaseConfigFieldError> validateFirebaseConfig({
  required String projectId,
  required String apiKey,
  String databaseId = kDefaultFirestoreDatabaseId,
}) {
  final errors = <String, FirebaseConfigFieldError>{};
  final pid = projectId.trim();
  final key = apiKey.trim();
  final db = normalizeDatabaseId(databaseId);

  if (pid.isEmpty) {
    errors['projectId'] = FirebaseConfigFieldError.projectIdEmpty;
  } else if (!_projectIdRe.hasMatch(pid)) {
    errors['projectId'] = FirebaseConfigFieldError.projectIdInvalid;
  }

  if (key.isEmpty) {
    errors['apiKey'] = FirebaseConfigFieldError.apiKeyEmpty;
  } else if (key.length < 16 || _whitespaceRe.hasMatch(key)) {
    errors['apiKey'] = FirebaseConfigFieldError.apiKeyInvalid;
  }

  if (db != kDefaultFirestoreDatabaseId && !_databaseIdRe.hasMatch(db)) {
    errors['databaseId'] = FirebaseConfigFieldError.databaseIdInvalid;
  }

  return errors;
}

/// Encodes [cfg] into a compact URI suitable for QR codes and family sharing.
String encodeRemoteShareUri(ParsedFirebaseConfig cfg) {
  final params = <String, String>{
    'p': cfg.projectId.trim(),
    'k': cfg.apiKey.trim(),
  };
  final db = normalizeDatabaseId(cfg.databaseId);
  if (db != kDefaultFirestoreDatabaseId) {
    params['d'] = db;
  }
  return Uri(
    scheme: 'illam-remote',
    host: 'v1',
    queryParameters: params,
  ).toString();
}

/// Parses an `illam-remote://v1?p=...&k=...` share URI, or `null` if invalid.
ParsedFirebaseConfig? parseRemoteShareUri(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('illam-remote://')) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.scheme != 'illam-remote' || uri.host != 'v1') {
    return null;
  }
  final pid = uri.queryParameters['p']?.trim() ?? '';
  final key = uri.queryParameters['k']?.trim() ?? '';
  if (pid.isEmpty || key.isEmpty) return null;
  final db = normalizeDatabaseId(uri.queryParameters['d'] ?? '');
  return ParsedFirebaseConfig(projectId: pid, apiKey: key, databaseId: db);
}

String? _readString(Map<Object?, Object?> map, List<String> keys) {
  for (final k in keys) {
    final v = map[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}

String? _matchJsField(String input, List<String> keys) {
  for (final key in keys) {
    final re = RegExp(
      '(?:["\']?)$key(?:["\']?)\\s*:\\s*["\']([^"\'\\s]+)["\']',
    );
    final m = re.firstMatch(input);
    if (m != null) {
      final val = m.group(1)?.trim() ?? '';
      if (val.isNotEmpty) return val;
    }
  }
  return null;
}

/// Extracts Firebase credentials from a share URI, JSON object, or Firebase Console JS snippet.
ParsedFirebaseConfig? parseFirebaseConfigSnippet(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final fromUri = parseRemoteShareUri(trimmed);
  if (fromUri != null) return fromUri;

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      final pid = _readString(decoded, const ['projectId', 'project_id', 'p']);
      final key = _readString(decoded, const ['apiKey', 'api_key', 'k']);
      if (pid != null && key != null) {
        final db = normalizeDatabaseId(
          _readString(decoded, const ['databaseId', 'database_id', 'd']) ?? '',
        );
        return ParsedFirebaseConfig(projectId: pid, apiKey: key, databaseId: db);
      }
    }
  } on Object {
    // Fall through to JS/text field extraction.
  }

  final pid = _matchJsField(trimmed, const ['projectId', 'project_id']);
  final key = _matchJsField(trimmed, const ['apiKey', 'api_key']);
  if (pid == null || key == null) return null;
  final db = normalizeDatabaseId(
    _matchJsField(trimmed, const ['databaseId', 'database_id']) ?? '',
  );
  return ParsedFirebaseConfig(projectId: pid, apiKey: key, databaseId: db);
}
