import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/sftp/ssh_keys.dart';
import 'package:nm_flat/core/backup/file_format.dart';

/// Backup destination speaking SFTP over SSH with host-key pinning.
class SftpDestination extends BackupDestination {
  SftpDestination({
    required this.host,
    required this.port,
    required this.user,
    required this.folder,
    required this.auth,
    required this.hostKey,
    required this.secret,
  });

  factory SftpDestination.fromSettings(
    Map<String, Object?> s,
    String secret,
  ) {
    return SftpDestination(
      host: s['host'] as String? ?? '',
      port: (s['port'] as num?)?.toInt() ?? 22,
      user: s['user'] as String? ?? '',
      folder: s['folder'] as String? ?? '/backups/illam',
      auth: s['auth'] as String? ?? 'password',
      hostKey: s['hostKey'] as String?,
      secret: secret,
    );
  }

  final String host;
  final int port;
  final String user;
  final String folder;
  final String auth;
  final String? hostKey;
  final String secret;

  @override
  String get kind => 'sftp';

  String get _cleanFolder {
    var f = folder.trim();
    while (f.length > 1 && f.endsWith('/')) {
      f = f.substring(0, f.length - 1);
    }
    return f;
  }

  String _path(String name) =>
      _cleanFolder == '/' ? '/$name' : '$_cleanFolder/$name';

  Never _throwHostKeyError(String? seenHostKey) {
    throw hostKey == null
        ? DestinationException(DestError.untrustedHostKey, seenHostKey)
        : const DestinationException(DestError.hostKeyChanged);
  }

  Future<T> _run<T>(Future<T> Function(SftpClient sftp) job) async {
    SSHClient? client;
    SftpClient? sftp;
    String? seenHostKey;
    var hostKeyRejected = false;
    try {
      final socket = await SSHSocket.connect(
        host,
        port,
        timeout: const Duration(seconds: 15),
      );
      List<SSHIdentity>? identities;
      if (auth == 'key') {
        final seed = base64Decode(secret);
        final pub = await SshKeys.publicFromSeed(seed);
        identities = [SshKeys.keyPair(seed, pub)];
      }
      client = SSHClient(
        socket,
        username: user,
        onPasswordRequest: auth == 'password' ? () => secret : null,
        identities: identities,
        onVerifyHostKey: (type, fingerprint) {
          seenHostKey = utf8.decode(fingerprint, allowMalformed: true);
          final accepted = hostKey != null && hostKey == seenHostKey;
          if (!accepted) hostKeyRejected = true;
          return accepted;
        },
        handshakeTimeout: const Duration(seconds: 15),
        authTimeout: const Duration(seconds: 15),
      );
      await client.authenticated;
      sftp = await client.sftp();
      return await job(sftp);
    } on DestinationException {
      rethrow;
    } on SSHHostkeyError catch (e) {
      debugPrint('SFTP host key error: $e');
      _throwHostKeyError(seenHostKey);
    } on SSHAuthFailError catch (e) {
      debugPrint('SFTP auth failed: $e');
      throw const DestinationException(DestError.auth);
    } on SSHAuthAbortError catch (e) {
      debugPrint('SFTP auth aborted: $e');
      if (hostKeyRejected) _throwHostKeyError(seenHostKey);
      if (e.reason is SocketException ||
          e.reason is TimeoutException ||
          e.reason is SSHSocketError) {
        throw const DestinationException(DestError.unreachable);
      }
      throw const DestinationException(DestError.other);
    } on SSHSocketError catch (e) {
      debugPrint('SFTP socket error: $e');
      throw const DestinationException(DestError.unreachable);
    } on SocketException catch (e) {
      debugPrint('SFTP socket exception: $e');
      throw const DestinationException(DestError.unreachable);
    } on TimeoutException catch (e) {
      debugPrint('SFTP timeout: $e');
      throw const DestinationException(DestError.unreachable);
    } on SftpStatusError catch (e) {
      debugPrint('SFTP status error (${e.code}): ${e.message}');
      if (e.code == 3) {
        throw const DestinationException(DestError.noPermission);
      }
      final msg = e.message.toLowerCase();
      if (msg.contains('quota') || msg.contains('space')) {
        throw const DestinationException(DestError.full);
      }
      throw const DestinationException(DestError.other);
    } on Object catch (e) {
      debugPrint('SFTP error: $e');
      if (hostKeyRejected) _throwHostKeyError(seenHostKey);
      throw const DestinationException(DestError.other);
    } finally {
      try {
        await sftp?.close();
      } on Object {
        // Ignore close errors.
      }
      client?.close();
    }
  }

  Future<void> _ensureFolder(SftpClient sftp) async {
    final clean = _cleanFolder;
    if (clean.isEmpty || clean == '.' || clean == '/') return;
    final leadingSlash = clean.startsWith('/');
    final parts = clean.split('/').where((s) => s.isNotEmpty).toList();
    var cur = '';
    for (var i = 0; i < parts.length; i++) {
      cur = i == 0 && !leadingSlash ? parts[0] : '$cur/${parts[i]}';
      try {
        await sftp.stat(cur);
      } on Object {
        await sftp.mkdir(cur);
      }
    }
  }

  Future<void> _writeAll(
    SftpClient sftp,
    String remotePath,
    Uint8List bytes,
  ) async {
    final file = await sftp.open(
      remotePath,
      mode:
          SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write,
    );
    try {
      await file.write(Stream<Uint8List>.value(bytes)).done;
    } finally {
      await file.close();
    }
  }

  @override
  Future<void> upload(String name, Uint8List bytes) => _run((sftp) async {
    await _ensureFolder(sftp);
    final part = _path('$name.part');
    final target = _path(name);
    await _writeAll(sftp, part, bytes);
    final stat = await sftp.stat(part);
    if (stat.size != bytes.length) {
      try {
        await sftp.remove(part);
      } on Object {
        // Best-effort cleanup of incomplete partial upload.
      }
      throw const DestinationException(DestError.other);
    }
    try {
      await sftp.stat(target);
      await sftp.remove(target);
    } on SftpStatusError {
      // Final file does not exist yet.
    }
    await sftp.rename(part, target);
  });

  Future<List<SftpName>> _safeListdir(SftpClient sftp) async {
    try {
      return await sftp.listdir(_cleanFolder);
    } on SftpStatusError catch (e) {
      if (e.code == 2) return const [];
      rethrow;
    }
  }

  @override
  Future<List<RemoteBackupFile>> list() => _run((sftp) async {
    final entries = await _safeListdir(sftp);
    return [
      for (final n in entries)
        if (n.filename != '.' &&
            n.filename != '..' &&
            !n.attr.isDirectory &&
            backupNameRe.hasMatch(n.filename))
          RemoteBackupFile(
            n.filename,
            n.attr.size ?? 0,
            (n.attr.modifyTime ?? 0) * 1000,
          ),
    ];
  });

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) =>
      _run((sftp) async {
        final cutoffMs =
            DateTime.now().toUtc().millisecondsSinceEpoch -
            olderThan.inMilliseconds;
        final entries = await _safeListdir(sftp);
        return [
          for (final n in entries)
            if (n.filename != '.' &&
                n.filename != '..' &&
                !n.attr.isDirectory &&
                n.filename.endsWith('.nmbak.part') &&
                (n.attr.modifyTime == null ||
                    n.attr.modifyTime! * 1000 < cutoffMs))
              RemoteBackupFile(
                n.filename,
                n.attr.size ?? 0,
                (n.attr.modifyTime ?? 0) * 1000,
              ),
        ];
      });

  @override
  Future<Uint8List> download(String name) => _run((sftp) async {
    final file = await sftp.open(_path(name));
    try {
      return await file.readBytes();
    } finally {
      await file.close();
    }
  });

  @override
  Future<void> delete(String name) => _run((sftp) async {
    try {
      await sftp.remove(_path(name));
    } on SftpStatusError catch (e) {
      if (e.code != 2) rethrow;
    }
  });

  @override
  Future<void> testWrite() => _run((sftp) async {
    await _ensureFolder(sftp);
    final p = _path('Illam_test_${randomHex(4)}.tmp');
    await _writeAll(sftp, p, Uint8List.fromList(utf8.encode('NMBK test')));
    await sftp.remove(p);
  });
}
