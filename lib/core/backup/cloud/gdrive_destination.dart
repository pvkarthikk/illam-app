import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:nm_flat/core/backup/cloud/google_auth.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/file_format.dart';

/// Backup destination stored in Google Drive's hidden `appDataFolder`.
class GdriveDestination extends BackupDestination {
  @override
  String get kind => 'gdrive';

  static String nameQuery(String name) {
    final escaped = name.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "name = '$escaped' and trashed = false";
  }

  Future<drive.DriveApi> _api() async {
    final authz = await GoogleAuth.silent();
    if (authz == null) {
      throw const DestinationException(DestError.auth);
    }
    return drive.DriveApi(authz.authClient(scopes: GoogleAuth.scopes));
  }

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DestinationException {
      rethrow;
    } on drive.DetailedApiRequestError catch (e) {
      debugPrint('Drive API error (${e.status}): ${e.message}');
      final status = e.status ?? 0;
      if (status == 401) throw const DestinationException(DestError.auth);
      if (status == 403) {
        final detail =
            '${e.message ?? ''} ${e.errors.map((d) => d.reason ?? '').join(' ')}'
                .toLowerCase();
        if (detail.contains('storagequotaexceeded') ||
            detail.contains('quota')) {
          throw const DestinationException(DestError.full);
        }
        throw const DestinationException(DestError.noPermission);
      }
      throw statusError(status) ?? const DestinationException(DestError.other);
    } on SocketException catch (e) {
      debugPrint('Drive network error: $e');
      throw const DestinationException(DestError.unreachable);
    } on TimeoutException catch (e) {
      debugPrint('Drive timeout: $e');
      throw const DestinationException(DestError.unreachable);
    } on Object catch (e) {
      debugPrint('Drive error: $e');
      throw const DestinationException(DestError.other);
    }
  }

  Future<List<drive.File>> _all(drive.DriveApi api) async {
    final out = <drive.File>[];
    String? pageToken;
    do {
      final res = await api.files.list(
        spaces: 'appDataFolder',
        q: 'trashed = false',
        pageSize: 100,
        pageToken: pageToken,
        $fields: 'nextPageToken, files(id,name,size,modifiedTime)',
      );
      if (res.files != null) out.addAll(res.files!);
      pageToken = res.nextPageToken;
    } while (pageToken != null && pageToken.isNotEmpty);
    return out;
  }

  Future<String?> _idOf(drive.DriveApi api, String name) async {
    final res = await api.files.list(
      spaces: 'appDataFolder',
      q: nameQuery(name),
      pageSize: 1,
      $fields: 'files(id)',
    );
    return res.files?.firstOrNull?.id;
  }

  @override
  Future<void> upload(String name, Uint8List bytes) => _guard(() async {
    final api = await _api();
    final created = await api.files.create(
      drive.File(name: '$name.part', parents: const ['appDataFolder']),
      uploadMedia: drive.Media(
        Stream<List<int>>.value(bytes),
        bytes.length,
      ),
      $fields: 'id,size',
    );
    final uploadedSize = int.tryParse(created.size ?? '') ?? -1;
    if (created.id == null || uploadedSize != bytes.length) {
      if (created.id != null) {
        try {
          await api.files.delete(created.id!);
        } on Object {
          // Best-effort partial cleanup.
        }
      }
      throw const DestinationException(DestError.other);
    }
    await api.files.update(drive.File(name: name), created.id!);
  });

  @override
  Future<List<RemoteBackupFile>> list() => _guard(() async {
    final api = await _api();
    final files = await _all(api);
    return [
      for (final f in files)
        if (f.name != null && backupNameRe.hasMatch(f.name!))
          RemoteBackupFile(
            f.name!,
            int.tryParse(f.size ?? '') ?? 0,
            f.modifiedTime?.millisecondsSinceEpoch ?? 0,
          ),
    ];
  });

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) =>
      _guard(() async {
        final api = await _api();
        final cutoff = DateTime.now().toUtc().subtract(olderThan);
        final files = await _all(api);
        return [
          for (final f in files)
            if (f.name != null &&
                f.name!.endsWith('.nmbak.part') &&
                (f.modifiedTime == null || f.modifiedTime!.isBefore(cutoff)))
              RemoteBackupFile(
                f.name!,
                int.tryParse(f.size ?? '') ?? 0,
                f.modifiedTime?.millisecondsSinceEpoch ?? 0,
              ),
        ];
      });

  @override
  Future<Uint8List> download(String name) => _guard(() async {
    final api = await _api();
    final id = await _idOf(api, name);
    if (id == null) {
      throw const DestinationException(DestError.notFound);
    }
    final obj = await api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (obj is! drive.Media) {
      throw const DestinationException(DestError.other);
    }
    final bb = BytesBuilder(copy: false);
    await for (final chunk in obj.stream) {
      bb.add(chunk);
    }
    return bb.takeBytes();
  });

  @override
  Future<void> delete(String name) => _guard(() async {
    final api = await _api();
    final id = await _idOf(api, name);
    if (id == null) return;
    try {
      await api.files.delete(id);
    } on drive.DetailedApiRequestError catch (e) {
      if (e.status == 404) return;
      rethrow;
    }
  });

  @override
  Future<void> testWrite() => _guard(() async {
    final api = await _api();
    final data = utf8.encode('NMBK test');
    final created = await api.files.create(
      drive.File(
        name: 'NestMojo_test_${randomHex(4)}.tmp',
        parents: const ['appDataFolder'],
      ),
      uploadMedia: drive.Media(
        Stream<List<int>>.value(data),
        data.length,
      ),
      $fields: 'id',
    );
    if (created.id != null) {
      await api.files.delete(created.id!);
    }
  });

  @override
  Future<void> revokeAccess() async {
    await GoogleAuth.ensureInitialized();
    await GoogleSignIn.instance.disconnect();
  }
}
