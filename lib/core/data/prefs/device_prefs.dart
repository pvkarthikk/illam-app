import 'dart:async';

import 'package:nm_flat/core/data/prefs/key_value_store.dart';
import 'package:nm_flat/core/util/ids.dart';

class DevicePrefs {
  DevicePrefs._(this._s);
  final KeyValueStore _s;
  final _home = StreamController<String?>.broadcast();

  static Future<DevicePrefs> open() async =>
      _init(DevicePrefs._(await SharedPrefsStore.create()));

  static Future<DevicePrefs> inMemory() =>
      _init(DevicePrefs._(MemoryStore()));

  static Future<DevicePrefs> _init(DevicePrefs p) async {
    if (p._s.getString('deviceId') == null) {
      await p.setDeviceId(Ids.randomDeviceId(), kind: 'random');
    }
    return p;
  }

  String get deviceId => _s.getString('deviceId') ?? '';

  /// `'random'` (P02) | `'key'` (P03).
  String get deviceIdKind => _s.getString('deviceIdKind') ?? 'random';

  Future<void> setDeviceId(String id, {required String kind}) async {
    await _s.setString('deviceId', id);
    await _s.setString('deviceIdKind', kind);
  }

  String? get currentHomeId => _s.getString('currentHomeId');

  Future<void> setCurrentHomeId(String? id) async {
    if (id == null) {
      await _s.remove('currentHomeId');
    } else {
      await _s.setString('currentHomeId', id);
    }
    _home.add(id);
  }

  Stream<String?> currentHomeIdStream() => Stream.multi((controller) {
    controller.add(currentHomeId);
    final sub = _home.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = sub.cancel;
  });

  String? get memberId => _s.getString('memberId');

  Future<void> setMemberId(String? id) async {
    if (id == null) {
      await _s.remove('memberId');
    } else {
      await _s.setString('memberId', id);
    }
  }

  String? get lastHlc => _s.getString('lastHlc');

  Future<void> setLastHlc(String v) => _s.setString('lastHlc', v);

  int get nextSeq => _s.getInt('nextSeq') ?? 1;

  Future<void> setNextSeq(int v) => _s.setInt('nextSeq', v);

  bool getFlag(String key, {bool fallback = false}) =>
      _s.getBool(key) ?? fallback;

  Future<void> setFlag(String key, bool v) => _s.setBool(key, v);

  String? getText(String key) => _s.getString(key);

  Future<void> setText(String key, String? v) async {
    if (v == null) {
      await _s.remove(key);
    } else {
      await _s.setString(key, v);
    }
  }

  /// Clears everything, then makes a fresh random deviceId (P03 replaces it with the key id).
  Future<void> clearAll() async {
    await _s.clear();
    await setDeviceId(Ids.randomDeviceId(), kind: 'random');
    _home.add(null);
  }
}
