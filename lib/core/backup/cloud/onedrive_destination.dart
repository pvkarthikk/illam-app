import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/file_format.dart';

final OAuthProvider microsoftOAuth = OAuthProvider(
  name: 'OneDrive',
  clientId: () => CloudIds.microsoftClientId,
  authEndpoint: Uri.parse(
    'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
  ),
  tokenEndpoint: Uri.parse(
    'https://login.microsoftonline.com/common/oauth2/v2.0/token',
  ),
  scopes: const ['offline_access', 'User.Read', 'Files.ReadWrite.AppFolder'],
  prompt: const ['select_account'],
  scopeOnRefresh: true,
);

const _root = 'https://graph.microsoft.com/v1.0/me/drive/special/approot';

/// Backup destination stored in OneDrive's app folder (`Apps/Nest Mojo Flat`).
class OneDriveDestination extends BackupDestination {
  OneDriveDestination(this.keeper);

  final TokenKeeper keeper;

  @override
  String get kind => 'onedrive';

  static ({List<Map<String, Object?>> files, String? nextLink}) parseChildren(
    Map<String, Object?> j,
  ) {
    final files = <Map<String, Object?>>[];
    for (final raw in j['value'] as List? ?? const []) {
      if (raw is! Map) continue;
      final item = Map<String, Object?>.from(raw);
      if (item.containsKey('folder')) continue;
      files.add({
        'id': item['id'],
        'name': item['name'],
        'size': item['size'],
        'lastModifiedDateTime': item['lastModifiedDateTime'],
      });
    }
    return (files: files, nextLink: j['@odata.nextLink'] as String?);
  }

  static DestError? graphErrorKind(int status, String? code) {
    if (status >= 200 && status <= 299) return null;
    if (status == 401) return DestError.auth;
    if (status == 507 || code == 'quotaLimitReached') return DestError.full;
    if (status == 403 || code == 'accessDenied') {
      return DestError.noPermission;
    }
    if (status == 404) return null;
    if (status == 429 || status >= 500) return DestError.unreachable;
    return DestError.other;
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

  String? _graphCode(Object? raw) {
    try {
      final err = _decodeMap(raw)['error'];
      if (err is Map) return err['code'] as String?;
    } on Object {
      // Ignore malformed error body.
    }
    return null;
  }

  void _throwIfError(Response<dynamic> res) {
    final status = res.statusCode ?? 0;
    if (status >= 200 && status <= 299) return;
    debugPrint('OneDrive Graph error $status: ${res.data}');
    final err = graphErrorKind(status, _graphCode(res.data));
    throw DestinationException(err ?? DestError.other);
  }

  Uri _fileUri(String name) =>
      Uri.parse('$_root:/${Uri.encodeComponent(name)}:/content');

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    final part = '$name.part';
    final res = await keeper.authed<dynamic>(
      (tok) => keeper.dio.putUri<dynamic>(
        _fileUri(part),
        data: Stream<Uint8List>.value(bytes),
        options: Options(
          headers: {
            'Authorization': 'Bearer $tok',
            Headers.contentTypeHeader: 'application/octet-stream',
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      ),
    );
    _throwIfError(res);
    final uploaded = _decodeMap(res.data);
    final id = uploaded['id'] as String?;
    final size = (uploaded['size'] as num?)?.toInt() ?? -1;
    if (id == null || id.isEmpty || size != bytes.length) {
      await delete(part);
      throw const DestinationException(DestError.other);
    }

    final patch = await keeper.authed<dynamic>(
      (tok) => keeper.dio.patchUri<dynamic>(
        Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id'),
        data: {'name': name},
        options: Options(headers: {'Authorization': 'Bearer $tok'}),
      ),
    );
    _throwIfError(patch);
  }

  Future<List<Map<String, Object?>>> _listAll() async {
    final all = <Map<String, Object?>>[];
    Uri? url = Uri.parse('$_root/children').replace(
      queryParameters: const {
        r'$select': 'id,name,size,lastModifiedDateTime,folder',
        r'$top': '200',
      },
    );
    while (url != null) {
      final current = url;
      final res = await keeper.authed<dynamic>(
        (tok) => keeper.dio.getUri<dynamic>(
          current,
          options: Options(headers: {'Authorization': 'Bearer $tok'}),
        ),
      );
      if (res.statusCode == 404) return const [];
      _throwIfError(res);
      final page = parseChildren(_decodeMap(res.data));
      all.addAll(page.files);
      url = page.nextLink == null || page.nextLink!.isEmpty
          ? null
          : Uri.parse(page.nextLink!);
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
            _parseMs(e['lastModifiedDateTime']),
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
      final ms = _parseMs(e['lastModifiedDateTime']);
      if (ms == 0 || ms < cutoffMs) {
        out.add(RemoteBackupFile(name, (e['size'] as num?)?.toInt() ?? 0, ms));
      }
    }
    return out;
  }

  @override
  Future<Uint8List> download(String name) async {
    final res = await keeper.authed<dynamic>(
      (tok) => keeper.dio.getUri<dynamic>(
        _fileUri(name),
        options: Options(
          headers: {'Authorization': 'Bearer $tok'},
          responseType: ResponseType.bytes,
        ),
      ),
    );
    if (res.statusCode == 404) {
      throw const DestinationException(DestError.notFound);
    }
    _throwIfError(res);
    final raw = res.data;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return Uint8List(0);
  }

  @override
  Future<void> delete(String name) async {
    final res = await keeper.authed<dynamic>(
      (tok) => keeper.dio.deleteUri<dynamic>(
        Uri.parse('$_root:/${Uri.encodeComponent(name)}'),
        options: Options(headers: {'Authorization': 'Bearer $tok'}),
      ),
    );
    if (res.statusCode == 404) return;
    _throwIfError(res);
  }

  @override
  Future<void> testWrite() async {
    final tmp = 'NestMojo_test_${randomHex(4)}.tmp';
    final data = Uint8List.fromList(utf8.encode('NMBK test'));
    final res = await keeper.authed<dynamic>(
      (tok) => keeper.dio.putUri<dynamic>(
        _fileUri(tmp),
        data: Stream<Uint8List>.value(data),
        options: Options(
          headers: {
            'Authorization': 'Bearer $tok',
            Headers.contentTypeHeader: 'application/octet-stream',
            Headers.contentLengthHeader: data.length,
          },
        ),
      ),
    );
    _throwIfError(res);
    await delete(tmp);
  }

  static Future<String> accountEmail(TokenKeeper k) async {
    final res = await k.authed<dynamic>(
      (tok) => k.dio.getUri<dynamic>(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me',
        ).replace(queryParameters: const {r'$select': 'mail,userPrincipalName'}),
        options: Options(headers: {'Authorization': 'Bearer $tok'}),
      ),
    );
    final status = res.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw DestinationException(
        graphErrorKind(status, null) ?? DestError.other,
      );
    }
    final raw = res.data;
    final map = Map<String, Object?>.from(
      (raw is String ? jsonDecode(raw) : raw) as Map,
    );
    final mail = map['mail'] as String?;
    if (mail != null && mail.isNotEmpty) return mail;
    return (map['userPrincipalName'] as String?) ?? '';
  }
}
