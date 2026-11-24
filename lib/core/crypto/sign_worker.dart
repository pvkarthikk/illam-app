import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';

/// Entry point for the long-lived Ed25519 signing isolate.
@pragma('vm:entry-point')
Future<void> signWorkerMain((SendPort, List<int>) init) async {
  final (replyPort, seed) = init;
  final kp = await Ed25519().newKeyPairFromSeed(seed);
  final inbox = ReceivePort();
  replyPort.send(inbox.sendPort);

  await for (final msg in inbox) {
    final (id, domain, bodies) = msg as (int, String, List<List<int>>);
    try {
      final sigs = <String>[
        for (final body in bodies) await Signer.sign(kp, domain, body),
      ];
      replyPort.send((id, sigs, null));
    } on Object catch (e) {
      replyPort.send((id, null, '$e'));
    }
  }
}

/// Signs op batches on a dedicated background isolate using the device signing key.
class SignWorker {
  SignWorker(this._keys);

  final Future<DeviceKeys> _keys;

  bool _disposed = false;
  Isolate? _isolate;
  ReceivePort? _inbox;
  Future<SendPort>? _starting;
  Completer<SendPort>? _portCompleter;
  int _nextId = 0;
  final Map<int, Completer<List<String>>> _pending = {};

  Future<List<String>> signAll(String domain, List<List<int>> bodies) async {
    if (_disposed) throw StateError('SignWorker disposed');
    if (bodies.isEmpty) return const <String>[];

    final port = await (_starting ??= _start());
    if (_disposed) throw StateError('SignWorker disposed');

    final id = ++_nextId;
    final completer = Completer<List<String>>();
    _pending[id] = completer;
    port.send((id, domain, bodies));
    return completer.future;
  }

  Future<SendPort> _start() async {
    ReceivePort? inbox;
    Isolate? isolate;
    try {
      final keys = await _keys;
      if (_disposed) throw StateError('SignWorker disposed');

      final portCompleter = Completer<SendPort>();
      unawaited(portCompleter.future.then((_) {}, onError: (_) {}));
      _portCompleter = portCompleter;

      inbox = ReceivePort();
      _inbox = inbox;
      inbox.listen((msg) {
        if (msg is SendPort) {
          if (!portCompleter.isCompleted) {
            portCompleter.complete(msg);
          }
          return;
        }
        final (id, sigs, error) = msg as (int, List<String>?, String?);
        final completer = _pending.remove(id);
        if (completer == null || completer.isCompleted) return;
        if (error != null || sigs == null) {
          completer.completeError(StateError(error ?? 'Sign failed'));
        } else {
          completer.complete(sigs);
        }
      });

      isolate = await Isolate.spawn<(SendPort, List<int>)>(
        signWorkerMain,
        (inbox.sendPort, Uint8List.fromList(keys.signSeed)),
        debugName: 'SignWorker',
      );
      if (_disposed) {
        isolate.kill(priority: Isolate.immediate);
        throw StateError('SignWorker disposed');
      }
      _isolate = isolate;
      return await portCompleter.future;
    } on Object {
      _starting = null;
      _portCompleter = null;
      isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      inbox?.close();
      if (identical(_inbox, inbox)) _inbox = null;
      rethrow;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _inbox?.close();
    _inbox = null;

    final portCompleter = _portCompleter;
    _portCompleter = null;
    if (portCompleter != null && !portCompleter.isCompleted) {
      portCompleter.completeError(StateError('SignWorker disposed'));
    }

    final waiting = List<Completer<List<String>>>.of(_pending.values);
    _pending.clear();
    for (final c in waiting) {
      if (!c.isCompleted) {
        c.completeError(StateError('SignWorker disposed'));
      }
    }
  }
}
