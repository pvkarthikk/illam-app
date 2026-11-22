import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';

const _reportedKey = 'reportedIgnoredOps';

/// Emits ignored reasons once per locally-authored op rejected during replay.
class OpIgnoredNotifier {
  OpIgnoredNotifier(this.prefs);

  final DevicePrefs prefs;
  final StreamController<String> _reasons = StreamController<String>.broadcast();
  Future<void> _serial = Future<void>.value();

  Stream<String> get reasons => _reasons.stream;

  Future<void> check(ReplayResult s, String me) {
    final next = _serial.then((_) => _checkImpl(s, me));
    _serial = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> _checkImpl(ReplayResult s, String me) async {
    final mine = [
      for (final op in s.ignored)
        if (op.authorDeviceId == me) op,
    ];
    if (mine.isEmpty) return;

    final raw = prefs.getText(_reportedKey);
    final reported = <String>{
      if (raw != null && raw.isNotEmpty)
        for (final id in jsonDecode(raw) as List) id as String,
    };

    var added = false;
    for (final op in mine) {
      if (reported.add(op.opId)) {
        added = true;
        if (!_reasons.isClosed) {
          _reasons.add(op.reason);
        }
      }
    }

    if (added) {
      await prefs.setText(_reportedKey, jsonEncode(reported.toList()));
    }
  }

  Future<void> dispose() => _reasons.close();
}

final opIgnoredProvider = Provider<OpIgnoredNotifier>((ref) {
  final n = OpIgnoredNotifier(ref.watch(prefsProvider));
  ref.onDispose(() => unawaited(n.dispose()));
  return n;
});
