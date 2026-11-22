import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  String? getString(String k);
  int? getInt(String k);
  bool? getBool(String k);
  Future<void> setString(String k, String v);
  Future<void> setInt(String k, int v);
  Future<void> setBool(String k, bool v);
  Future<void> remove(String k);
  Future<void> clear();
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferencesWithCache _prefs;

  static Future<SharedPrefsStore> create() async => SharedPrefsStore(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    ),
  );

  @override
  String? getString(String k) => _prefs.getString(k);

  @override
  int? getInt(String k) => _prefs.getInt(k);

  @override
  bool? getBool(String k) => _prefs.getBool(k);

  @override
  Future<void> setString(String k, String v) => _prefs.setString(k, v);

  @override
  Future<void> setInt(String k, int v) => _prefs.setInt(k, v);

  @override
  Future<void> setBool(String k, bool v) => _prefs.setBool(k, v);

  @override
  Future<void> remove(String k) => _prefs.remove(k);

  @override
  Future<void> clear() => _prefs.clear();
}

class MemoryStore implements KeyValueStore {
  final Map<String, Object> _map = {};

  @override
  String? getString(String k) => _map[k] as String?;

  @override
  int? getInt(String k) => _map[k] as int?;

  @override
  bool? getBool(String k) => _map[k] as bool?;

  @override
  Future<void> setString(String k, String v) async {
    _map[k] = v;
  }

  @override
  Future<void> setInt(String k, int v) async {
    _map[k] = v;
  }

  @override
  Future<void> setBool(String k, bool v) async {
    _map[k] = v;
  }

  @override
  Future<void> remove(String k) async {
    _map.remove(k);
  }

  @override
  Future<void> clear() async {
    _map.clear();
  }
}
