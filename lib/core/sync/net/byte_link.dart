import 'dart:typed_data';

/// Ordered bidirectional byte pipe used underneath [FramedConnection].
abstract class ByteLink {
  Stream<Uint8List> get input;
  void send(Uint8List bytes);
  Future<void> close();
}
