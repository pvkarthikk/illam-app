import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';

class ChannelError implements Exception {
  const ChannelError(this.message);

  final String message;

  @override
  String toString() => 'ChannelError($message)';
}

/// Encrypted authenticated JSON channel over a [FramedConnection].
class SecureChannel {
  SecureChannel._(
    this.conn,
    this.transcript,
    this._sendKey,
    this._recvKey,
    this.initiator,
  );

  final FramedConnection conn;
  final Uint8List transcript;
  final bool initiator;

  Uint8List _sendKey;
  Uint8List _recvKey;
  int _sendCtr = 0;
  int _recvCtr = 0;
  Future<void> _tail = Future<void>.value();

  static final _magic = Uint8List.fromList(const [0x4e, 0x4d, 0x76, 0x31]);
  static final _x25519 = X25519();

  static Uint8List _nonce(int n) =>
      concatBytes([const [0, 0, 0, 0], u64be(n)]);

  /// Performs an ephemeral X25519 key exchange and derives directional AEAD keys.
  static Future<SecureChannel> handshake(
    FramedConnection conn, {
    required bool initiator,
  }) async {
    final kp = await _x25519.newKeyPair();
    final myPub = (await kp.extractPublicKey()).bytes;
    final mine = concatBytes([_magic, myPub, randomBytes(16)]);
    conn.sendFrame(mine);

    final Uint8List theirs;
    try {
      theirs = await conn.nextFrame().timeout(const Duration(seconds: 10));
    } on Object {
      throw const ChannelError('hello');
    }

    if (theirs.length != 52 ||
        !constantTimeEquals(theirs.sublist(0, 4), _magic)) {
      throw const ChannelError('hello');
    }

    final t = await sha256Of(
      concatBytes([
        utf8.encode('nestmojo/chan/v1'),
        initiator ? mine : theirs,
        initiator ? theirs : mine,
      ]),
    );
    final shared = await _x25519.sharedSecretKey(
      keyPair: kp,
      remotePublicKey: SimplePublicKey(
        theirs.sublist(4, 36),
        type: KeyPairType.x25519,
      ),
    );
    final k = await hkdfSha256(
      ikm: await shared.extractBytes(),
      salt: t,
      info: utf8.encode('nestmojo/chan/keys'),
      length: 64,
    );
    final i2r = Uint8List.fromList(k.sublist(0, 32));
    final r2i = Uint8List.fromList(k.sublist(32, 64));

    return SecureChannel._(
      conn,
      t,
      initiator ? i2r : r2i,
      initiator ? r2i : i2r,
      initiator,
    );
  }

  /// Seals and sends [msg] in strict per-direction counter order.
  Future<void> send(Map<String, Object?> msg) {
    final op = _tail.then((_) async {
      final sealed = await Aead.chachaSeal(
        _sendKey,
        _nonce(_sendCtr),
        utf8.encode(jsonEncode(msg)),
      );
      _sendCtr++;
      conn.sendFrame(sealed);
    });
    _tail = op.catchError((_) {});
    return op;
  }

  /// Waits for, authenticates, decrypts, and decodes the next JSON message.
  Future<Map<String, Object?>> receive({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final frame = await conn.nextFrame().timeout(timeout);
    final plain = await Aead.chachaOpen(_recvKey, _nonce(_recvCtr), frame);
    _recvCtr++;
    return Map<String, Object?>.from(jsonDecode(utf8.decode(plain)) as Map);
  }

  /// Mixes [secret] (e.g. SPAKE2 `Ke`) into both directional keys and resets counters.
  Future<void> rekey(List<int> secret) async {
    final k = await hkdfSha256(
      ikm: secret,
      salt: transcript,
      info: utf8.encode('nestmojo/chan/rekey'),
      length: 64,
    );
    final i2r = Uint8List.fromList(k.sublist(0, 32));
    final r2i = Uint8List.fromList(k.sublist(32, 64));
    _recvKey = initiator ? r2i : i2r;
    _recvCtr = 0;

    final op = _tail.then((_) {
      _sendKey = initiator ? i2r : r2i;
      _sendCtr = 0;
    });
    _tail = op.catchError((_) {});
    return op;
  }

  /// Flushes pending outbound frames and closes the underlying connection.
  Future<void> close() async {
    await _tail;
    await conn.close();
  }
}
