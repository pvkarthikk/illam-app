import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as c;
import 'package:pointycastle/export.dart';

import 'package:nm_flat/core/crypto/bytes.dart';

/// Thrown when a SPAKE2 message is invalid or points fail validation.
class Spake2Error implements Exception {
  const Spake2Error(this.message);

  final String message;

  @override
  String toString() => 'Spake2Error($message)';
}

/// Keys derived from a completed SPAKE2 exchange.
class Spake2Keys {
  const Spake2Keys(
    this.ke,
    this.ka,
    this.kcA,
    this.kcB,
    this.cA,
    this.cB,
    this.isA,
  );

  final Uint8List ke;
  final Uint8List ka;
  final Uint8List kcA;
  final Uint8List kcB;
  final Uint8List cA;
  final Uint8List cB;
  final bool isA;

  Uint8List get myConfirm => isA ? cA : cB;
  Uint8List get peerConfirm => isA ? cB : cA;
}

/// Synchronous HKDF-SHA-256 (RFC 5869) backed by `package:crypto`.
Uint8List hkdfSync({
  required List<int> ikm,
  List<int> salt = const [],
  List<int> info = const [],
  int length = 32,
}) {
  final actualSalt = salt.isEmpty ? Uint8List(32) : salt;
  final prk = c.Hmac(c.sha256, actualSalt).convert(ikm).bytes;
  final hmacPrk = c.Hmac(c.sha256, prk);
  final out = BytesBuilder(copy: false);
  var prev = const <int>[];
  var counter = 1;
  while (out.length < length) {
    final t = hmacPrk.convert([...prev, ...info, counter]).bytes;
    out.add(t);
    prev = t;
    counter++;
  }
  return Uint8List.fromList(out.toBytes().sublist(0, length));
}

/// SPAKE2 over NIST P-256 (RFC 9382 ciphersuite SPAKE2-P256-SHA256-HKDF-HMAC).
class Spake2 {
  Spake2._(this.isA, this.w, this._s, this.idA, this.idB, this.aad);

  factory Spake2.a({
    required BigInt w,
    BigInt? x,
    List<int> idA = const [],
    List<int> idB = const [],
    List<int> aad = const [],
  }) => Spake2._(true, w % _dom.n, x ?? randomScalar(), idA, idB, aad);

  factory Spake2.b({
    required BigInt w,
    BigInt? y,
    List<int> idA = const [],
    List<int> idB = const [],
    List<int> aad = const [],
  }) => Spake2._(false, w % _dom.n, y ?? randomScalar(), idA, idB, aad);

  static final _dom = ECCurve_secp256r1();
  static final _p = BigInt.parse(
    'ffffffff00000001000000000000000000000000ffffffffffffffffffffffff',
    radix: 16,
  );
  static final _b = BigInt.parse(
    '5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b',
    radix: 16,
  );
  static final _m = _dom.curve.decodePoint(
    fromHex(
      '02886e2f97ace46e55ba9dd7242579f2993b64e16ef3dcab95afd497333d8fa12f',
    ),
  )!;
  static final _n = _dom.curve.decodePoint(
    fromHex(
      '03d8bbd6c639c62937b04d997f38c3770719c629d7014d49a24b4f98baa1292b49',
    ),
  )!;

  final bool isA;
  final BigInt w;
  final BigInt _s;
  final List<int> idA;
  final List<int> idB;
  final List<int> aad;
  Uint8List? _mine;

  static BigInt _int(List<int> b) =>
      b.isEmpty ? BigInt.zero : BigInt.parse(toHex(b), radix: 16);

  /// Uniform random non-zero scalar `0 < v < n`.
  static BigInt randomScalar() {
    while (true) {
      final v = _int(randomBytes(32));
      if (v > BigInt.zero && v < _dom.n) return v;
    }
  }

  /// Derives SPAKE2 scalar [w] from password and protocol [context].
  static BigInt passwordToW(List<int> password, String context) {
    final okm = hkdfSync(
      ikm: password,
      salt: utf8.encode(context),
      info: utf8.encode('nestmojo/spake2/w'),
      length: 40,
    );
    return _int(okm) % _dom.n;
  }

  static Uint8List _len(List<int> b) {
    final d = ByteData(8)..setUint64(0, b.length, Endian.little);
    return d.buffer.asUint8List();
  }

  static ECPoint _decodeChecked(List<int> b) {
    if (b.length != 65 || b[0] != 4) {
      throw const Spake2Error('bad point');
    }
    final x = _int(b.sublist(1, 33));
    final y = _int(b.sublist(33, 65));
    if (x >= _p ||
        y >= _p ||
        (y * y) % _p != (x * x * x - BigInt.from(3) * x + _b) % _p) {
      throw const Spake2Error('not on curve');
    }
    final pt = _dom.curve.decodePoint(b);
    if (pt == null || pt.isInfinity) {
      throw const Spake2Error('not on curve');
    }
    return pt;
  }

  /// Generates and stores our 65-byte uncompressed ephemeral SPAKE2 message.
  Uint8List start() {
    final base = isA ? _m : _n;
    final pt = ((base * w)! + (_dom.G * _s)!)!;
    final enc = Uint8List.fromList(pt.getEncoded(false));
    _mine = enc;
    return enc;
  }

  /// Processes the peer's 65-byte SPAKE2 message and derives session & confirm keys.
  Spake2Keys finish(List<int> peerMsg) {
    final mine = _mine;
    if (mine == null) {
      throw const Spake2Error('start() first');
    }
    final p = _decodeChecked(peerMsg);
    final blinded = ((isA ? _n : _m) * w)!;
    final k = ((p - blinded)! * _s);
    if (k == null || k.isInfinity) {
      throw const Spake2Error('bad K');
    }

    final pA = isA ? mine : peerMsg;
    final pB = isA ? peerMsg : mine;
    final kBytes = k.getEncoded(false);
    final wBytes = fromHex(w.toRadixString(16).padLeft(64, '0'));

    final tt = concatBytes([
      for (final item in [idA, idB, pA, pB, kBytes, wBytes]) ...[
        _len(item),
        item,
      ],
    ]);

    final h = c.sha256.convert(tt).bytes;
    final ke = Uint8List.fromList(h.sublist(0, 16));
    final ka = Uint8List.fromList(h.sublist(16, 32));

    final kc = hkdfSync(
      ikm: ka,
      info: concatBytes([utf8.encode('ConfirmationKeys'), aad]),
      length: 32,
    );
    final kcA = Uint8List.fromList(kc.sublist(0, 16));
    final kcB = Uint8List.fromList(kc.sublist(16, 32));

    final cA = Uint8List.fromList(c.Hmac(c.sha256, kcA).convert(tt).bytes);
    final cB = Uint8List.fromList(c.Hmac(c.sha256, kcB).convert(tt).bytes);

    return Spake2Keys(ke, ka, kcA, kcB, cA, cB, isA);
  }
}
