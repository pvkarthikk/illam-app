import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';

const _mime = 'application/octet-stream';
const _verifyWindow = 1 << 20;

/// Android Storage Access Framework (SAF) directory destination for encrypted backups.
class FolderDestination extends BackupDestination {
  FolderDestination(this.treeUri);

  final String treeUri;
  final SafUtil _util = SafUtil();
  final SafStream _stream = SafStream();

  @override
  String get kind => 'folder';

  static bool isPhoneStorage(String treeUri) {
    final decoded = Uri.decodeComponent(treeUri);
    return decoded.contains('com.android.externalstorage.documents') &&
        decoded.contains('primary:');
  }

  static String labelOf(String treeUri) {
    final decoded = Uri.decodeComponent(treeUri);
    final idx = decoded.lastIndexOf(':');
    if (idx < 0 || idx + 1 >= decoded.length) return decoded;
    return decoded.substring(idx + 1);
  }

  static Future<FolderDestination?> pick() async {
    final dir = await SafUtil().pickDirectory(
      writePermission: true,
      persistablePermission: true,
    );
    return dir == null ? null : FolderDestination(dir.uri);
  }

  Future<T> _saf<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on PlatformException {
      throw const DestinationException(DestError.noPermission);
    }
  }

  Future<void> _access({bool write = true}) async {
    final ok = await _saf(
      () => _util.hasPersistedPermission(
        treeUri,
        checkRead: true,
        checkWrite: write,
      ),
    );
    if (!ok) throw const DestinationException(DestError.noPermission);
  }

  Future<String> _uri(String name) async {
    final child = await _saf(() => _util.child(treeUri, [name]));
    if (child == null) throw const DestinationException(DestError.notFound);
    return child.uri;
  }

  bool _same(List<int> part, Uint8List all, int offset) {
    for (var i = 0; i < part.length; i++) {
      if (part[i] != all[offset + i]) return false;
    }
    return true;
  }

  @override
  Future<void> testWrite() async {
    await _access();
    await _saf(() async {
      final file = await _stream.writeFileBytes(
        treeUri,
        '.illam-test',
        _mime,
        Uint8List.fromList(utf8.encode('ok')),
        overwrite: true,
      );
      final uri = file.uri.toString();
      final back = await _stream.readFileBytes(uri);
      await _util.delete(uri, false);
      if (utf8.decode(back, allowMalformed: true) != 'ok') {
        throw const DestinationException(DestError.noPermission);
      }
    });
  }

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    await _access();
    await _saf(() async {
      final part = await _stream.writeFileBytes(
        treeUri,
        '$name.part',
        _mime,
        bytes,
        overwrite: true,
      );
      final partUri = part.uri.toString();
      final st = await _util.stat(partUri, false);
      if (st == null || st.length != bytes.length) {
        throw const DestinationException(DestError.error);
      }

      if (bytes.isNotEmpty) {
        final headCount = min(_verifyWindow, bytes.length);
        final head = await _stream.readFileBytes(
          partUri,
          start: 0,
          count: headCount,
        );
        if (head.length != headCount || !_same(head, bytes, 0)) {
          throw const DestinationException(DestError.error);
        }

        final tailOffset = max(0, bytes.length - _verifyWindow);
        final tailCount = bytes.length - tailOffset;
        final tail = await _stream.readFileBytes(
          partUri,
          start: tailOffset,
          count: tailCount,
        );
        if (tail.length != tailCount || !_same(tail, bytes, tailOffset)) {
          throw const DestinationException(DestError.error);
        }
      }

      await _util.rename(partUri, false, name);
    });
  }

  @override
  Future<List<RemoteBackupFile>> list() async {
    await _access(write: false);
    final entries = await _saf(() => _util.list(treeUri));
    return [
      for (final f in entries)
        if (!f.isDir && backupNameRe.hasMatch(f.name))
          RemoteBackupFile(f.name, f.length, f.lastModified),
    ];
  }

  @override
  Future<Uint8List> download(String name) async {
    final uri = await _uri(name);
    return _saf(() => _stream.readFileBytes(uri));
  }

  @override
  Future<Uint8List> readHead(String name, int count) async {
    final uri = await _uri(name);
    return _saf(() => _stream.readFileBytes(uri, start: 0, count: count));
  }

  @override
  Future<void> delete(String name) async {
    final uri = await _uri(name);
    await _saf(() => _util.delete(uri, false));
  }

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) async {
    await _access(write: false);
    final cutoff =
        DateTime.now().millisecondsSinceEpoch - olderThan.inMilliseconds;
    final entries = await _saf(() => _util.list(treeUri));
    return [
      for (final f in entries)
        if (!f.isDir &&
            f.name.endsWith('.nmbak.part') &&
            f.lastModified < cutoff)
          RemoteBackupFile(f.name, f.length, f.lastModified),
    ];
  }
}
