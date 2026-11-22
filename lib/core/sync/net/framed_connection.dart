import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:nm_flat/core/crypto/bytes.dart';

const maxFrame = 1 << 20;

class FrameTooBig implements Exception {
  const FrameTooBig();
}

class ConnectionClosed implements Exception {
  const ConnectionClosed();
}

/// 4-byte big-endian length prefix encoder.
abstract final class FrameCodec {
  static Uint8List encode(List<int> payload) {
    final hdr = ByteData(4)..setUint32(0, payload.length);
    return concatBytes([hdr.buffer.asUint8List(), payload]);
  }
}

/// Streaming decoder splitting incoming byte chunks into complete length-prefixed frames.
class FrameDecoder {
  List<int> _pending = const <int>[];

  List<Uint8List> add(List<int> bytes) {
    final data = _pending.isEmpty
        ? Uint8List.fromList(bytes)
        : concatBytes([_pending, bytes]);
    final out = <Uint8List>[];
    var offset = 0;

    while (offset + 4 <= data.length) {
      final len = ByteData.sublistView(data, offset, offset + 4).getUint32(0);
      if (len > maxFrame) {
        throw const FrameTooBig();
      }
      if (offset + 4 + len > data.length) break;
      out.add(Uint8List.fromList(data.sublist(offset + 4, offset + 4 + len)));
      offset += 4 + len;
    }

    _pending = offset < data.length
        ? Uint8List.fromList(data.sublist(offset))
        : const <int>[];
    return out;
  }
}

/// Single-listener bidirectional length-prefixed frame stream over a transport.
class FramedConnection {
  FramedConnection(
    Stream<List<int>> input,
    this._write,
    this._close,
  ) {
    _sub = input.listen(
      (chunk) {
        try {
          for (final frame in _decoder.add(chunk)) {
            if (_waiters.isNotEmpty) {
              _waiters.removeFirst().complete(frame);
            } else {
              _frames.addLast(frame);
            }
          }
        } on Object catch (e) {
          _failAll(e is FrameTooBig ? e : const ConnectionClosed());
          unawaited(close());
        }
      },
      onError: (_) => _failAll(const ConnectionClosed()),
      onDone: () => _failAll(const ConnectionClosed()),
    );
  }

  factory FramedConnection.socket(Socket s) => FramedConnection(
    s,
    s.add,
    () async {
      try {
        await s.flush();
      } on Object {
        // Ignore flush failures while closing.
      }
      s.destroy();
    },
  );

  /// In-memory connected pair for unit tests.
  static (FramedConnection, FramedConnection) memoryPair() {
    final aToB = StreamController<List<int>>();
    final bToA = StreamController<List<int>>();
    final a = FramedConnection(bToA.stream, aToB.add, aToB.close);
    final b = FramedConnection(aToB.stream, bToA.add, bToA.close);
    return (a, b);
  }

  final void Function(List<int>) _write;
  final Future<void> Function() _close;
  final _decoder = FrameDecoder();
  final _frames = Queue<Uint8List>();
  final _waiters = Queue<Completer<Uint8List>>();
  late final StreamSubscription<List<int>> _sub;
  bool _closed = false;
  Future<void>? _closeFuture;

  void sendFrame(List<int> payload) {
    if (_closed) throw const ConnectionClosed();
    _write(FrameCodec.encode(payload));
  }

  Future<Uint8List> nextFrame() {
    if (_frames.isNotEmpty) return Future.value(_frames.removeFirst());
    if (_closed) return Future.error(const ConnectionClosed());
    final c = Completer<Uint8List>();
    _waiters.addLast(c);
    return c.future;
  }

  void _failAll(Object err) {
    _closed = true;
    while (_waiters.isNotEmpty) {
      final w = _waiters.removeFirst();
      if (!w.isCompleted) w.completeError(err);
    }
  }

  Future<void> close() {
    return _closeFuture ??= () async {
      _failAll(const ConnectionClosed());
      await _sub.cancel();
      await _close();
    }();
  }
}
