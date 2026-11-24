import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/file_format.dart';

const int _maxUploadBytes = 140 * 1024 * 1024;

/// Backup destination stored in the app's Dropbox App Folder (`Apps/Nest Mojo Flat`).
class DropboxDestination extends BackupDestination {
  DropboxDestination(this.keeper);

  final TokenKeeper keeper;

  @override
  String get kind => 'dropbox';

  static String argHeader(Map<String, Object?> m) {
    final encoded = jsonEncode(m);
    final out = StringBuffer();
    for (final unit in encoded.codeUnits) {
      if (unit < 0x80) {
        out.writeCharCode(unit);
      } else {
        out.write(r'\u');
        out.write(unit.toRadixString(16).padLeft(4, '0'));
      }
    }
    return out.toString();
  }

  static DestError? dropboxErrorKind(int status, String? errorSummary) {
    if (status >= 200 && status <= 299) return null;
    if (status == 401) return DestError.auth;
    if (status == 409) {
      final s = errorSummary ?? '';
      if (s.contains('insufficient_space')) return DestError.full;
      if (s.contains('not_found')) return null;
      return DestError.other;
    }
    if (status == 403) return DestError.noPermission;
    if (status == 429 || status >= 500) return DestError.unreachable;
    return statusError(status)?.error ?? DestError.other;
  }

  static ({List<Map<String, Object?>> files, bool hasMore, String? cursor})
  parseListFolder(Map<String, Object?> j) {
    final files = <Map<String, Object?>>[];
    for (final raw in j['entries'] as List? ?? const []) {
      if (raw is! Map) continue;
      final entry = Map<String, Object?>.from(raw);
      if (entry['.tag'] != 'file') continue;
      files.add({
        'name': entry['name'],
        'size': entry['size'],
        'server_modified': entry['server_modified'],
      });
    }
    return (
      files: files,
      hasMore: (j['has_more'] as bool?) ?? false,
      cursor: j['cursor'] as String?,
    );
  }

  Map<String, Object?> _decodeMap(Object? raw) {
    final decoded = switch (raw) {
      String s when s.isNotEmpty => jsonDecode(s),
      List<int> b when b.isNotEmpty => jsonDecode(
        utf8.decode(b, allowMalformed: true),
      ),
      Map m => m,
      _ => const <String, Object?>{},
    };
    if (decoded is! Map) return const <String, Object?>{};
    return Map<String, Object?>.from(decoded);
  }

  String? _summaryFrom(Object? raw) {
    try {
      return _decodeMap(raw)['error_summary'] as String?;
    } on Object {
      return null;
    }
  }

  void _throwIfError(Response<dynamic> res) {
    final status = res.statusCode ?? 0;
    if (status >= 200 && status <= 299) return;
    final err = dropboxErrorKind(status, _summaryFrom(res.data));
    throw DestinationException(err ?? DestError.other);
  }

  Future<Response<T>> _authedJson<T>(
    Uri uri, {
    Object? data,
    Object? Function()? body,
    Map<String, Object?>? headers,
    ResponseType? responseType,
  }) => keeper.authed<T>(
    (tok) => keeper.dio.postUri<T>(
      uri,
      data: body != null ? body() : data,
      options: Options(
        headers: <String, Object?>{'Authorization': 'Bearer $tok', ...?headers},
        responseType: responseType,
      ),
    ),
  );

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    if (bytes.length > _maxUploadBytes) {
      throw const DestinationException(DestError.other);
    }
    final partPath = '/$name.part';
    final res = await _authedJson<dynamic>(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      body: () => Stream<Uint8List>.value(bytes),
      headers: {
        'Dropbox-API-Arg': argHeader({
          'path': partPath,
          'mode': 'overwrite',
          'mute': true,
        }),
        Headers.contentTypeHeader: 'application/octet-stream',
        Headers.contentLengthHeader: bytes.length,
      },
    );
    _throwIfError(res);
    final uploaded = _decodeMap(res.data);
    final uploadedSize = (uploaded['size'] as num?)?.toInt() ?? -1;
    if (uploadedSize != bytes.length) {
      await _deletePath(partPath);
      throw const DestinationException(DestError.other);
    }

    final move = await _authedJson<dynamic>(
      Uri.parse('https://api.dropboxapi.com/2/files/move_v2'),
      data: {'from_path': partPath, 'to_path': '/$name', 'autorename': false},
    );
    _throwIfError(move);
  }

  Future<List<Map<String, Object?>>> _listAll() async {
    final all = <Map<String, Object?>>[];
    var res = await _authedJson<dynamic>(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder'),
      data: const {'path': ''},
    );
    final status = res.statusCode ?? 0;
    if (status == 409 &&
        (_summaryFrom(res.data)?.contains('not_found') ?? false)) {
      return const [];
    }
    _throwIfError(res);
    var page = parseListFolder(_decodeMap(res.data));
    all.addAll(page.files);
    while (page.hasMore && page.cursor != null) {
      res = await _authedJson<dynamic>(
        Uri.parse('https://api.dropboxapi.com/2/files/list_folder/continue'),
        data: {'cursor': page.cursor},
      );
      _throwIfError(res);
      page = parseListFolder(_decodeMap(res.data));
      all.addAll(page.files);
    }
    return all;
  }

  int _parseMs(Object? raw) {
    if (raw is! String || raw.isEmpty) return 0;
    try {
      return DateTime.parse(raw).millisecondsSinceEpoch;
    } on FormatException {
      return 0;
    }
  }

  @override
  Future<List<RemoteBackupFile>> list() async {
    final entries = await _listAll();
    return [
      for (final e in entries)
        if (e['name'] is String && backupNameRe.hasMatch(e['name'] as String))
          RemoteBackupFile(
            e['name'] as String,
            (e['size'] as num?)?.toInt() ?? 0,
            _parseMs(e['server_modified']),
          ),
    ];
  }

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) async {
    final cutoffMs =
        DateTime.now().toUtc().millisecondsSinceEpoch -
        olderThan.inMilliseconds;
    final entries = await _listAll();
    final out = <RemoteBackupFile>[];
    for (final e in entries) {
      final name = e['name'];
      if (name is! String || !name.endsWith('.nmbak.part')) continue;
      final ms = _parseMs(e['server_modified']);
      if (ms == 0 || ms < cutoffMs) {
        out.add(RemoteBackupFile(name, (e['size'] as num?)?.toInt() ?? 0, ms));
      }
    }
    return out;
  }

  @override
  Future<Uint8List> download(String name) async {
    final res = await _authedJson<dynamic>(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: {'Dropbox-API-Arg': argHeader({'path': '/$name'})},
      responseType: ResponseType.bytes,
    );
    final status = res.statusCode ?? 0;
    if (status == 409 &&
        (_summaryFrom(res.data)?.contains('not_found') ?? false)) {
      throw const DestinationException(DestError.notFound);
    }
    _throwIfError(res);
    final raw = res.data;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return Uint8List(0);
  }

  Future<void> _deletePath(String path) async {
    final res = await _authedJson<dynamic>(
      Uri.parse('https://api.dropboxapi.com/2/files/delete_v2'),
      data: {'path': path},
    );
    final status = res.statusCode ?? 0;
    if (status == 409 &&
        (_summaryFrom(res.data)?.contains('not_found') ?? false)) {
      return;
    }
    _throwIfError(res);
  }

  @override
  Future<void> delete(String name) => _deletePath('/$name');

  @override
  Future<void> testWrite() async {
    final tmp = '/NestMojo_test_${randomHex(4)}.tmp';
    final data = Uint8List.fromList(utf8.encode('NMBK test'));
    final res = await _authedJson<dynamic>(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      body: () => Stream<Uint8List>.value(data),
      headers: {
        'Dropbox-API-Arg': argHeader({
          'path': tmp,
          'mode': 'overwrite',
          'mute': true,
        }),
        Headers.contentTypeHeader: 'application/octet-stream',
        Headers.contentLengthHeader: data.length,
      },
    );
    _throwIfError(res);
    await _deletePath(tmp);
  }

  static Future<String> accountEmail(TokenKeeper k) async {
    final res = await k.authed<dynamic>(
      (tok) => k.dio.postUri<dynamic>(
        Uri.parse('https://api.dropboxapi.com/2/users/get_current_account'),
        options: Options(headers: {'Authorization': 'Bearer $tok'}),
      ),
    );
    final status = res.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw DestinationException(
        dropboxErrorKind(status, null) ?? DestError.other,
      );
    }
    final raw = res.data;
    final map = Map<String, Object?>.from(
      (raw is String ? jsonDecode(raw) : raw) as Map,
    );
    return (map['email'] as String?) ?? '';
  }

  @override
  Future<void> revokeAccess() async {
    try {
      final tok = await keeper.accessToken();
      await keeper.dio.postUri<dynamic>(
        Uri.parse('https://api.dropboxapi.com/2/auth/token/revoke'),
        options: Options(headers: {'Authorization': 'Bearer $tok'}),
      );
    } on Object catch (e) {
      debugPrint('Dropbox revokeAccess ignored: $e');
    }
  }
}
