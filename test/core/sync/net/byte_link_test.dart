import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/net/byte_link.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';

class MemoryByteLink implements ByteLink {
  MemoryByteLink(this._in, this._out);

  final Stream<Uint8List> _in;
  final StreamSink<Uint8List> _out;

  @override
  Stream<Uint8List> get input => _in;

  @override
  void send(Uint8List bytes) => _out.add(Uint8List.fromList(bytes));

  @override
  Future<void> close() => _out.close();
}

(MemoryByteLink, MemoryByteLink) memoryLinkPair() {
  final aToB = StreamController<Uint8List>();
  final bToA = StreamController<Uint8List>();
  return (
    MemoryByteLink(bToA.stream, aToB.sink),
    MemoryByteLink(aToB.stream, bToA.sink),
  );
}

void main() {
  test('MemoryByteLink sends raw bytes in both directions', () async {
    final (a, b) = memoryLinkPair();
    addTearDown(() async {
      await a.close();
      await b.close();
    });

    final bFirst = b.input.first;
    a.send(Uint8List.fromList([1, 2, 3]));
    expect(await bFirst, [1, 2, 3]);

    final aFirst = a.input.first;
    b.send(Uint8List.fromList([9]));
    expect(await aFirst, [9]);
  });

  test('FramedConnection.link transmits small and large frames in order', () async {
    final (linkA, linkB) = memoryLinkPair();
    final a = FramedConnection.link(linkA);
    final b = FramedConnection.link(linkB);
    addTearDown(() async {
      await a.close();
      await b.close();
    });

    final small = Uint8List.fromList([10, 20, 30, 40, 50]);
    final large = Uint8List.fromList(List<int>.generate(70000, (i) => i & 0xff));

    a.sendFrame(small);
    a.sendFrame(large);

    expect(await b.nextFrame(), small);
    expect(await b.nextFrame(), large);
  });

  test('SecureChannel.handshake works over FramedConnection.link', () async {
    final (linkA, linkB) = memoryLinkPair();
    final connA = FramedConnection.link(linkA);
    final connB = FramedConnection.link(linkB);
    addTearDown(() async {
      await connA.close();
      await connB.close();
    });

    final channels = await Future.wait([
      SecureChannel.handshake(connA, initiator: true),
      SecureChannel.handshake(connB, initiator: false),
    ]);
    final chA = channels[0];
    final chB = channels[1];

    await chA.send({'hello': 'world', 'n': 42});
    expect(await chB.receive(), {'hello': 'world', 'n': 42});
  });
}
