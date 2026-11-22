import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';

/// Nextcloud Login Flow v2 and OCS account/app-password client.
class NextcloudLogin {
  const NextcloudLogin(this.dio);

  final Dio dio;

  String _basic(String login, String pass) =>
      'Basic ${base64Encode(utf8.encode('$login:$pass'))}';

  Map<String, Object?> _decodeMap(Object? raw) {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is! Map) {
      throw const DestinationException(DestError.other);
    }
    return Map<String, Object?>.from(decoded);
  }

  Future<({Uri login, String token, Uri endpoint})> start(Uri server) async {
    final Response<dynamic> res;
    try {
      res = await dio.postUri<dynamic>(server.resolve('index.php/login/v2'));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final status = res.statusCode ?? 0;
    if (status != 200) {
      throw statusError(status) ?? const DestinationException(DestError.other);
    }
    final map = _decodeMap(res.data);
    final poll = map['poll'];
    final loginRaw = map['login'];
    if (poll is! Map || loginRaw is! String) {
      throw const DestinationException(DestError.other);
    }
    final pollMap = Map<String, Object?>.from(poll);
    return (
      login: Uri.parse(loginRaw),
      token: pollMap['token'] as String,
      endpoint: Uri.parse(pollMap['endpoint'] as String),
    );
  }

  Future<({String server, String loginName, String appPassword})?> pollOnce(
    Uri endpoint,
    String token,
  ) async {
    final Response<dynamic> res;
    try {
      res = await dio.postUri<dynamic>(
        endpoint,
        data: 'token=${Uri.encodeQueryComponent(token)}',
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final status = res.statusCode ?? 0;
    if (status == 404) return null;
    final err = statusError(status);
    if (err != null) throw err;
    final map = _decodeMap(res.data);
    return (
      server: map['server'] as String,
      loginName: map['loginName'] as String,
      appPassword: map['appPassword'] as String,
    );
  }

  static Uri davFolder(Uri server, String userId) => server.resolve(
    'remote.php/dav/files/${Uri.encodeComponent(userId)}/Nest%20Mojo%20Flat/',
  );

  Future<String> userId(Uri server, String login, String pass) async {
    final Response<dynamic> res;
    try {
      res = await dio.getUri<dynamic>(
        server.resolve('ocs/v1.php/cloud/user?format=json'),
        options: Options(
          headers: <String, Object?>{
            'Authorization': _basic(login, pass),
            'OCS-APIRequest': 'true',
          },
        ),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final err = statusError(res.statusCode ?? 0);
    if (err != null) throw err;
    final map = _decodeMap(res.data);
    final ocs = Map<String, Object?>.from(map['ocs'] as Map);
    final data = Map<String, Object?>.from(ocs['data'] as Map);
    return data['id'] as String;
  }

  Future<void> revoke(Uri server, String login, String pass) async {
    final Response<dynamic> res;
    try {
      res = await dio.deleteUri<dynamic>(
        server.resolve('ocs/v2.php/core/apppassword'),
        options: Options(
          headers: <String, Object?>{
            'Authorization': _basic(login, pass),
            'OCS-APIRequest': 'true',
          },
        ),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    final err = statusError(res.statusCode ?? 0);
    if (err != null) throw err;
  }
}
