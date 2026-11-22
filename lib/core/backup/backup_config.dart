import 'dart:convert';

import 'package:nm_flat/core/backup/cloud/appauth_sign_in.dart';
import 'package:nm_flat/core/backup/cloud/dropbox_destination.dart';
import 'package:nm_flat/core/backup/cloud/gdrive_destination.dart';
import 'package:nm_flat/core/backup/cloud/onedrive_destination.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_destination.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/folder_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_destination.dart';
import 'package:nm_flat/core/backup/destinations/sftp/sftp_destination.dart';
import 'package:nm_flat/core/backup/destinations/webdav/webdav_client.dart';
import 'package:nm_flat/core/backup/destinations/webdav/webdav_destination.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/util/ids.dart';

/// Device-only configuration and last-run state for one backup destination.
class DestinationConfig {
  DestinationConfig({
    String? destId,
    required this.kind,
    required this.label,
    Map<String, Object?>? settings,
    this.lastSuccessAt,
    this.lastResult,
    this.keptCount = 0,
    this.failures = 0,
    this.lastCommittedHeads,
    this.lastFullName,
  }) : destId = destId ?? Ids.newId(),
       settings = settings ?? {};

  factory DestinationConfig.fromJson(Map<String, Object?> j) =>
      DestinationConfig(
        destId: j['destId'] as String?,
        kind: (j['kind'] as String?) ?? 'folder',
        label: (j['label'] as String?) ?? '',
        settings: Map<String, Object?>.from(
          j['settings'] as Map? ?? const {},
        ),
        lastSuccessAt: (j['lastSuccessAt'] as num?)?.toInt(),
        lastResult: j['lastResult'] as String?,
        keptCount: (j['keptCount'] as num?)?.toInt() ?? 0,
        failures: (j['failures'] as num?)?.toInt() ?? 0,
        lastCommittedHeads: j['lastCommittedHeads'] as String?,
        lastFullName: j['lastFullName'] as String?,
      );

  final String destId;
  final String kind;
  final String label;
  final Map<String, Object?> settings;
  int? lastSuccessAt;
  String? lastResult;
  int keptCount;
  int failures;
  String? lastCommittedHeads;
  String? lastFullName;

  DestinationConfig copyWith({
    String? label,
    Map<String, Object?>? settings,
  }) => DestinationConfig(
    destId: destId,
    kind: kind,
    label: label ?? this.label,
    settings: settings ?? Map<String, Object?>.from(this.settings),
    lastSuccessAt: lastSuccessAt,
    lastResult: lastResult,
    keptCount: keptCount,
    failures: failures,
    lastCommittedHeads: lastCommittedHeads,
    lastFullName: lastFullName,
  );

  Map<String, Object?> toJson() => {
    'destId': destId,
    'kind': kind,
    'label': label,
    'settings': settings,
    'lastSuccessAt': lastSuccessAt,
    'lastResult': lastResult,
    'keptCount': keptCount,
    'failures': failures,
    'lastCommittedHeads': lastCommittedHeads,
    'lastFullName': lastFullName,
  };
}

/// Device-only per-home backup preferences, destinations, password, and kit seed.
class BackupConfig {
  BackupConfig({
    List<DestinationConfig>? destinations,
    this.password,
    this.passwordSetAt,
    this.frequency = 'weekly',
    this.wifiOnly = true,
    this.chargingOnly = true,
    this.keep = 10,
    this.consecutiveFailures = 0,
    List<Map<String, Object?>>? history,
    this.kit,
    this.lastSkip,
    this.lastAttentionAt,
  }) : destinations = destinations ?? [],
       history = history ?? [];

  factory BackupConfig.fromJson(Map<String, Object?> j) => BackupConfig(
    destinations: [
      for (final d in j['destinations'] as List? ?? const [])
        DestinationConfig.fromJson(Map<String, Object?>.from(d as Map)),
    ],
    password: j['password'] as String?,
    passwordSetAt: (j['passwordSetAt'] as num?)?.toInt(),
    frequency: (j['frequency'] as String?) ?? 'weekly',
    wifiOnly: (j['wifiOnly'] as bool?) ?? true,
    chargingOnly: (j['chargingOnly'] as bool?) ?? true,
    keep: (j['keep'] as num?)?.toInt() ?? 10,
    consecutiveFailures: (j['consecutiveFailures'] as num?)?.toInt() ?? 0,
    history: [
      for (final h in j['history'] as List? ?? const [])
        Map<String, Object?>.from(h as Map),
    ],
    kit: j['kit'] is Map
        ? Map<String, Object?>.from(j['kit'] as Map)
        : null,
    lastSkip: j['lastSkip'] as String?,
    lastAttentionAt: (j['lastAttentionAt'] as num?)?.toInt(),
  );

  static const int maxDestinations = 3;

  static BackupConfig empty() => BackupConfig();

  List<DestinationConfig> destinations;
  String? password;
  int? passwordSetAt;
  String frequency;
  bool wifiOnly;
  bool chargingOnly;
  int keep;
  int consecutiveFailures;
  List<Map<String, Object?>> history;
  Map<String, Object?>? kit;
  String? lastSkip;
  int? lastAttentionAt;

  Map<String, Object?> toJson() => {
    'destinations': [for (final d in destinations) d.toJson()],
    'password': password,
    'passwordSetAt': passwordSetAt,
    'frequency': frequency,
    'wifiOnly': wifiOnly,
    'chargingOnly': chargingOnly,
    'keep': keep,
    'consecutiveFailures': consecutiveFailures,
    'history': history,
    'kit': kit,
    'lastSkip': lastSkip,
    'lastAttentionAt': lastAttentionAt,
  };
}

/// Reads and writes per-home [BackupConfig] entries in [SecureStore].
class BackupConfigStore {
  const BackupConfigStore(this.store);

  final SecureStore store;

  static String _key(String homeId) => 'backup_$homeId';

  Future<BackupConfig> load(String homeId) async {
    final raw = await store.read(_key(homeId));
    if (raw == null || raw.isEmpty) return BackupConfig.empty();
    return BackupConfig.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> save(String homeId, BackupConfig c) =>
      store.write(_key(homeId), jsonEncode(c.toJson()));

  Future<void> delete(String homeId) => store.delete(_key(homeId));
}

/// Builds a [BackupDestination] using an already-loaded destination [secret].
BackupDestination destinationWithSecret(DestinationConfig d, String secret) {
  switch (d.kind) {
    case 'folder':
      final uri = d.settings['treeUri'];
      if (uri is! String || uri.isEmpty) {
        throw const DestinationException(DestError.error);
      }
      return FolderDestination(uri);
    case 'webdav':
      final url = d.settings['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const DestinationException(DestError.other);
      }
      return WebDavDestination(
        kind: 'webdav',
        dav: WebDavClient(
          buildServerDio(tlsPin: d.settings['tlsPin'] as String?),
          Uri.parse(url),
          (d.settings['user'] as String?) ?? '',
          secret,
        ),
      );
    case 'nextcloud':
      final url = d.settings['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const DestinationException(DestError.other);
      }
      final serverRaw = d.settings['server'] as String?;
      final server = serverRaw == null || serverRaw.isEmpty
          ? null
          : Uri.parse(serverRaw.endsWith('/') ? serverRaw : '$serverRaw/');
      final user =
          (d.settings['loginName'] as String?) ??
          (d.settings['user'] as String?) ??
          '';
      return WebDavDestination(
        kind: 'nextcloud',
        nextcloudServer: server,
        dav: WebDavClient(
          buildServerDio(tlsPin: d.settings['tlsPin'] as String?),
          Uri.parse(url),
          user,
          secret,
        ),
      );
    case 's3':
      return S3Destination.fromSettings(d.settings, secret);
    case 'sftp':
      return SftpDestination.fromSettings(d.settings, secret);
    default:
      throw const DestinationException(DestError.error);
  }
}

Future<BackupDestination> destinationFor(
  DestinationConfig d,
  SecureStore secure,
) async {
  switch (d.kind) {
    case 'folder':
      return destinationWithSecret(d, '');
    case 'gdrive':
      return GdriveDestination();
    case 'dropbox':
      return DropboxDestination(
        TokenKeeper(
          buildServerDio(),
          DestinationSecrets(secure),
          d.destId,
          dropboxOAuth,
        ),
      );
    case 'onedrive':
      return OneDriveDestination(
        TokenKeeper(
          buildServerDio(),
          DestinationSecrets(secure),
          d.destId,
          microsoftOAuth,
        ),
      );
    case 'pcloud':
      final token = await DestinationSecrets(secure).read(d.destId) ?? '';
      return PcloudDestination(
        (d.settings['host'] as String?) ?? 'api.pcloud.com',
        token,
      );
    default:
      final secret = await DestinationSecrets(secure).read(d.destId) ?? '';
      return destinationWithSecret(d, secret);
  }
}
