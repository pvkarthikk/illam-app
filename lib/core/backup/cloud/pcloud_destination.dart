import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/file_format.dart';

const String _folder = '/Nest Mojo Flat';

/// Backup destination stored in pCloud (`/Nest Mojo Flat`).
class PcloudDestination extends BackupDestination {
  PcloudDestination(this.host, this.token, {Dio? dio})
    : _dio = dio ?? buildServerDio();

  final String host;
  final String token;
  final Dio _dio;

  @override
  String get kind => 'pcloud';

  static DestError? pcloudErrorKind(int result) => switch (result) {
    1000 || 2000 || 2094 || 2095 => DestError.auth,
    2003 => DestError.noPermission,
    2008 => DestError.full,
    2005 || 2009 => null,
    _ => DestError.other,
  };

  static int parseModified(String m) {
    final normalized = m.replaceAll('+0000', 'GMT');
    return HttpDate.parse(normalized).millisecondsSinceEpoch;
  }

  static List<RemoteBackupFile> parseListFolder(
    Map<String, Object?> j, {
    bool parts = false,
  }) {
    final meta = j['metadata'];
    if (meta is! Map) return const [];
    final contents = meta['contents'] as List? ?? const [];
    final out = <RemoteBackupFile>[];
    for (final raw in contents) {
      if (raw is! Map) continue;
      final item = Map<String, Object?>.from(raw);
      if (item['isfolder'] != false) continue;
      final name = item['name'];
      if (name is! String) continue;
      if (parts) {
        if (!name.endsWith('.nmbak.part')) continue;
      } else {
        if (!backupNameRe.hasMatch(name)) continue;
      }
      final size = (item['size'] as num?)?.toInt() ?? 0;
      final modRaw = item['modified'] as String?;
      var modifiedMs = 0;
      if (modRaw != null && modRaw.isNotEmpty) {
        try {
          modifiedMs = parseModified(modRaw);
        } on Object {
          modifiedMs = 0;
        }
      }
      out.add(RemoteBackupFile(name, size, modifiedMs));
    }
    return out;
  }

  Map<String, Object?> _decodeMap(Object? raw) {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is! Map) throw const DestinationException(DestError.other);
    return Map<String, Object?>.from(decoded);
  }

  Future<Map<String, Object?>> _request(
    String method, {
    Map<String, String>? params,
    Object? data,
    bool isPost = false,
    Set<int> allowResults = const {},
  }) async {
    final uri = Uri.https(host, '/$method', params);
    final options = Options(headers: {'Authorization': 'Bearer $token'});
    final Response<dynamic> res;
    try {
      res = isPost
          ? await _dio.postUri<dynamic>(uri, data: data, options: options)
          : await _dio.getUri<dynamic>(uri, options: options);
    } on DioException catch (e) {
      throw mapDioError(e);
    }

    final status = res.statusCode ?? 0;
    final err = statusError(status);
    if (err != null) throw err;

    final map = _decodeMap(res.data);
    final result = (map['result'] as num?)?.toInt() ?? -1;
    if (result == 0 || allowResults.contains(result)) return map;
    debugPrint('pCloud error on $method: result=$result');
    throw DestinationException(pcloudErrorKind(result) ?? DestError.other);
  }

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    await _request('createfolderifnotexists', params: {'path': _folder});
    final partName = '$name.part';
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: partName),
    });
    final up = await _request(
      'uploadfile',
      params: {'path': _folder, 'nopartial': '1'},
      data: form,
      isPost: true,
    );
    final metaList = up['metadata'] as List? ?? const [];
    final first = metaList.isNotEmpty && metaList.first is Map
        ? Map<String, Object?>.from(metaList.first as Map)
        : const <String, Object?>{};
    final uploadedSize = (first['size'] as num?)?.toInt() ?? -1;
    if (uploadedSize != bytes.length) {
      await delete(partName);
      throw const DestinationException(DestError.other);
    }
    await _request(
      'renamefile',
      params: {'path': '$_folder/$partName', 'topath': '$_folder/$name'},
    );
  }

  @override
  Future<List<RemoteBackupFile>> list() async {
    final res = await _request(
      'listfolder',
      params: {'path': _folder},
      allowResults: const {2005},
    );
    if (res['result'] == 2005) return const [];
    return parseListFolder(res);
  }

  @override
  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) async {
    final res = await _request(
      'listfolder',
      params: {'path': _folder},
      allowResults: const {2005},
    );
    if (res['result'] == 2005) return const [];
    final cutoffMs =
        DateTime.now().toUtc().millisecondsSinceEpoch -
        olderThan.inMilliseconds;
    return [
      for (final f in parseListFolder(res, parts: true))
        if (f.modifiedMs == 0 || f.modifiedMs < cutoffMs) f,
    ];
  }

  @override
  Future<Uint8List> download(String name) async {
    final link = await _request(
      'getfilelink',
      params: {'path': '$_folder/$name'},
      allowResults: const {2005, 2009},
    );
    final result = (link['result'] as num?)?.toInt() ?? 0;
    if (result == 2005 || result == 2009) {
      throw const DestinationException(DestError.notFound);
    }
    final hosts = (link['hosts'] as List? ?? const []).cast<String>();
    final path = link['path'] as String?;
    if (hosts.isEmpty || path == null || path.isEmpty) {
      throw const DestinationException(DestError.other);
    }
    final Response<dynamic> res;
    try {
      res = await _dio.getUri<dynamic>(
        Uri.parse('https://${hosts.first}$path'),
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final err = statusError(res.statusCode ?? 0);
    if (err != null) throw err;
    final raw = res.data;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return Uint8List(0);
  }

  @override
  Future<void> delete(String name) async {
    await _request(
      'deletefile',
      params: {'path': '$_folder/$name'},
      allowResults: const {2009},
    );
  }

  @override
  Future<void> testWrite() async {
    final tmp = 'NestMojo_test_${randomHex(4)}.tmp';
    await upload(tmp, Uint8List.fromList(utf8.encode('NMBK test')));
    await delete(tmp);
  }

  static Future<String> accountEmail(
    String host,
    String token, {
    Dio? dio,
  }) async {
    final client = dio ?? buildServerDio();
    final Response<dynamic> res;
    try {
      res = await client.getUri<dynamic>(
        Uri.https(host, '/userinfo'),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final err = statusError(res.statusCode ?? 0);
    if (err != null) throw err;
    final raw = res.data;
    final map = Map<String, Object?>.from(
      (raw is String ? jsonDecode(raw) : raw) as Map,
    );
    final result = (map['result'] as num?)?.toInt() ?? 0;
    if (result != 0) {
      throw DestinationException(pcloudErrorKind(result) ?? DestError.other);
    }
    return (map['email'] as String?) ?? '';
  }
}
