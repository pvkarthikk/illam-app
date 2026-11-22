import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';

void main() {
  group('frames', () {
    test('decodes concatenated payloads fed one byte at a time', () {
      final p1 = [1, 2, 3];
      final p2 = List<int>.generate(100, (i) => i);
      final p3 = <int>[];
      final stream = concatBytes([
        FrameCodec.encode(p1),
        FrameCodec.encode(p2),
        FrameCodec.encode(p3),
      ]);

      final decoder = FrameDecoder();
      final out = <Uint8List>[];
      for (final byte in stream) {
        out.addAll(decoder.add([byte]));
      }
      expect(out, [p1, p2, p3]);
    });

    test('header declaring over maxFrame throws FrameTooBig', () {
      final hdr = ByteData(4)..setUint32(0, maxFrame + 1);
      final decoder = FrameDecoder();
      expect(
        () => decoder.add(hdr.buffer.asUint8List()),
        throwsA(isA<FrameTooBig>()),
      );
    });

    test('memoryPair sends frames in order and closes cleanly', () async {
      final (a, b) = FramedConnection.memoryPair();
      a.sendFrame([1, 2]);
      a.sendFrame([3, 4, 5]);
      expect(await b.nextFrame(), [1, 2]);
      expect(await b.nextFrame(), [3, 4, 5]);

      await a.close();
      await expectLater(b.nextFrame(), throwsA(isA<ConnectionClosed>()));
      await b.close();
    });
  });

  group('SecureChannel', () {
    test('handshake derives identical 32-byte transcript and exchanges messages', () async {
      final (a, b) = FramedConnection.memoryPair();
      final channels = await Future.wait([
        SecureChannel.handshake(a, initiator: true),
        SecureChannel.handshake(b, initiator: false),
      ]);
      final chA = channels[0];
      final chB = channels[1];

      expect(chA.transcript.length, 32);
      expect(chA.transcript, chB.transcript);

      for (var i = 0; i < 3; i++) {
        await chA.send({'dir': 'a2b', 'n': i});
        expect(await chB.receive(), {'dir': 'a2b', 'n': i});
        await chB.send({'dir': 'b2a', 'n': i});
        expect(await chA.receive(), {'dir': 'b2a', 'n': i});
      }

      await chA.close();
      await chB.close();
    });

    test('short hello throws ChannelError', () async {
      final (a, b) = FramedConnection.memoryPair();
      a.sendFrame(List.filled(10, 1));
      await expectLater(
        SecureChannel.handshake(b, initiator: false),
        throwsA(isA<ChannelError>()),
      );
      await a.close();
      await b.close();
    });

    test('flipping one byte in sealed frame throws AeadError', () async {
      final aToB = StreamController<List<int>>();
      final bToA = StreamController<List<int>>();
      var corruptNext = false;
      final aToBTampered = aToB.stream.map((chunk) {
        if (!corruptNext) return chunk;
        final copy = Uint8List.fromList(chunk);
        copy[copy.length - 1] ^= 0x01;
        return copy;
      });
      final a = FramedConnection(bToA.stream, aToB.add, aToB.close);
      final b = FramedConnection(aToBTampered, bToA.add, bToA.close);

      final channels = await Future.wait([
        SecureChannel.handshake(a, initiator: true),
        SecureChannel.handshake(b, initiator: false),
      ]);
      corruptNext = true;
      await channels[0].send({'hello': 'world'});
      await expectLater(channels[1].receive(), throwsA(isA<AeadError>()));
      await channels[0].close();
      await channels[1].close();
    });

    test('rekey with matching secret keeps channel open, mismatch fails', () async {
      final (a, b) = FramedConnection.memoryPair();
      final channels = await Future.wait([
        SecureChannel.handshake(a, initiator: true),
        SecureChannel.handshake(b, initiator: false),
      ]);
      final chA = channels[0];
      final chB = channels[1];

      final sharedSecret = randomBytes(16);
      await Future.wait([chA.rekey(sharedSecret), chB.rekey(sharedSecret)]);
      await chA.send({'ok': 1});
      expect(await chB.receive(), {'ok': 1});
      await chB.send({'ok': 2});
      expect(await chA.receive(), {'ok': 2});

      await chA.rekey(randomBytes(16));
      await chA.send({'bad': 3});
      await expectLater(chB.receive(), throwsA(isA<AeadError>()));

      await chA.close();
      await chB.close();
    });
  });
}
