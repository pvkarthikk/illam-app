import 'dart:io';
import 'dart:typed_data';

import 'package:nm_flat/core/sync/net/byte_link.dart';

/// [ByteLink] backed by a TCP [Socket].
class TcpByteLink implements ByteLink {
  TcpByteLink(this._socket);

  final Socket _socket;

  @override
  Stream<Uint8List> get input => _socket;

  @override
  void send(Uint8List bytes) => _socket.add(bytes);

  @override
  Future<void> close() async {
    try {
      await _socket.flush();
    } on Object {
      // Ignore flush errors on close.
    }
    _socket.destroy();
  }
}
