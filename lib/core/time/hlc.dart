import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/time/clock.dart';

class Hlc implements Comparable<Hlc> {
  const Hlc(this.wall, this.counter, this.deviceId);
  final int wall;
  final int counter;
  final String deviceId;

  @override
  String toString() =>
      '${wall.toString().padLeft(13, '0')}.${counter.toRadixString(16).padLeft(4, '0')}.$deviceId';

  static Hlc parse(String s) {
    final p = s.split('.');
    return Hlc(int.parse(p[0]), int.parse(p[1], radix: 16), p[2]);
  }

  @override
  int compareTo(Hlc o) => toString().compareTo(o.toString());
}

class HlcClock {
  HlcClock(this._clock, this._prefs);
  final Clock _clock;
  final DevicePrefs _prefs;
  Hlc? _last;
  bool _dirty = false;

  Hlc get _lastOrZero {
    final cached = _last;
    if (cached != null) return cached;
    final saved = _prefs.lastHlc;
    final resolved =
        saved == null ? Hlc(0, 0, _prefs.deviceId) : Hlc.parse(saved);
    _last = resolved;
    return resolved;
  }

  /// Local event: wall = max(now, last.wall); counter +1 if wall didn't move, else 0.
  ///
  /// With [persist] false the new HLC is only held in memory until [flush];
  /// a write path that mints several HLCs in one transaction pays a single
  /// prefs write instead of one per op.
  Future<String> next({bool persist = true}) async {
    final last = _lastOrZero;
    final now = _clock.nowMs;
    var wall = now > last.wall ? now : last.wall;
    var counter = wall == last.wall ? last.counter + 1 : 0;
    if (counter > 0xFFFF) {
      wall += 1;
      counter = 0;
    }
    final h = Hlc(wall, counter, _prefs.deviceId);
    _last = h;
    if (persist) {
      _dirty = false;
      await _prefs.setLastHlc(h.toString());
    } else {
      _dirty = true;
    }
    return h.toString();
  }

  /// Persists the newest in-memory HLC once, if [next] was called with
  /// `persist: false` and nothing has flushed yet.
  Future<void> flush() async {
    if (!_dirty) return;
    final last = _last;
    _dirty = false;
    if (last == null) return;
    await _prefs.setLastHlc(last.toString());
  }

  /// Remote HLC seen (sync, later phases): never go backwards.
  Future<void> observe(String remote) async {
    final r = Hlc.parse(remote);
    final l = _lastOrZero;
    if (r.wall > l.wall || (r.wall == l.wall && r.counter > l.counter)) {
      final h = Hlc(r.wall, r.counter, _prefs.deviceId);
      _last = h;
      _dirty = false; // the newer value below is written to prefs directly
      await _prefs.setLastHlc(h.toString());
    }
  }

  /// P03 switches deviceId: forget the cached HLC so new HLCs carry the new id.
  void reset() {
    _last = null;
    _dirty = false;
  }
}
