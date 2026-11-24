import 'dart:convert';
import 'dart:typed_data';

import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/webdav/nextcloud_login.dart';
import 'package:nm_flat/core/backup/destinations/webdav/propfind_parser.dart';
import 'package:nm_flat/core/backup/destinations/webdav/webdav_client.dart';
import 'package:nm_flat/core/backup/file_format.dart';

/// Backup destination over WebDAV, reused by Nextcloud.
class WebDavDestination extends BackupDestination {
  WebDavDestination({
    required this.kind,
    required this._dav,
    this.nextcloudServer,
  });

  @override
  final String kind;

  final WebDavClient _dav;
  final Uri? nextcloudServer;

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    await _dav.mkcol(_dav.folderUrl);
    final part = '$name.part';
    await _dav.put(part, bytes);
    final entries = await _dav.propfind();
    DavEntry? uploaded;
    for (final e in entries) {
      if (!e.isFolder && e.name == part) {
        uploaded = e;
        break;
      }
    }
    if (uploaded == null || uploaded.size != bytes.length) {
      await _dav.delete(part);
      throw const DestinationException(DestError.other);
    }
    await _dav.move(part, name);
  }

  @override
  Future<void> testWrite() async {
    await _dav.mkcol(_dav.folderUrl);
    final tmp = 'Illam_test_${randomHex(4)}.tmp';
    await _dav.put(tmp, Uint8List.fromList(utf8.encode('NMBK test')));
    await _dav.delete(tmp);
  }

  @override
  Future<List<RemoteBackupFile>> list() async {
    final entries = await _dav.propfind();
    return [
      for (final e in entries)
        if (!e.isFolder && backupNameRe.hasMatch(e.name))
          RemoteBackupFile(
            e.name,
            e.size,
            e.modified?.millisecondsSinceEpoch ?? 0,
          ),
    ];
  }

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) async {
    final cutoff = DateTime.now().toUtc().subtract(olderThan);
    final entries = await _dav.propfind();
    return [
      for (final e in entries)
        if (!e.isFolder &&
            e.name.endsWith('.nmbak.part') &&
            (e.modified == null || e.modified!.isBefore(cutoff)))
          RemoteBackupFile(
            e.name,
            e.size,
            e.modified?.millisecondsSinceEpoch ?? 0,
          ),
    ];
  }

  @override
  Future<Uint8List> download(String name) => _dav.get(name);

  @override
  Future<void> delete(String name) => _dav.delete(name);

  @override
  Future<void> revokeAccess() async {
    final server = nextcloudServer;
    if (kind == 'nextcloud' && server != null) {
      await NextcloudLogin(_dav.dio).revoke(server, _dav.user, _dav.password);
    }
  }
}
