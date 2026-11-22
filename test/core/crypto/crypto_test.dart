import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/canonical_json.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/crypto/sign.dart';

void main() {
  group('bytes', () {
    test('hex round trip', () {
      expect(toHex(fromHex('00ff10')), '00ff10');
    });

    test('b64url round trip without padding', () {
      final encoded = b64url(const [251, 255]);
      expect(encoded.contains('='), isFalse);
      expect(unb64url(encoded), const [251, 255]);
    });

    test('u64be encodes big-endian unsigned 64-bit integer', () {
      expect(u64be(1), const [0, 0, 0, 0, 0, 0, 0, 1]);
    });

    test('constantTimeEquals checks lengths and contents', () {
      expect(constantTimeEquals(const [1, 2], const [1, 2]), isTrue);
      expect(constantTimeEquals(const [1, 2], const [1, 3]), isFalse);
      expect(constantTimeEquals(const [1], const [1, 2]), isFalse);
    });

    test('decodeKey handles 64-char hex', () {
      final k = decodeKey('00' * 32);
      expect(k.length, 32);
      expect(k.every((b) => b == 0), isTrue);
    });
  });

  group('kdf', () {
    test('RFC 5869 HKDF test case 1', () async {
      final out = await hkdfSha256(
        ikm: List.filled(22, 0x0b),
        salt: fromHex('000102030405060708090a0b0c'),
        info: fromHex('f0f1f2f3f4f5f6f7f8f9'),
        length: 42,
      );
      expect(
        toHex(out),
        '3cb25f25faacd57a90434f64d0362f2a'
        '2d2d0a90cf1a5a4c5db02d56ecc4c5bf'
        '34007208d5b887185865',
      );
    });

    test('RFC 4231 HMAC-SHA-256 test case 2', () async {
      final mac = await hmacSha256(
        utf8.encode('Jefe'),
        utf8.encode('what do ya want for nothing?'),
      );
      expect(
        toHex(mac),
        '5bdcc146bf60754e6a042426089575c7'
        '5a003f089d2739839dec58b964ec3843',
      );
    });

    test('SHA-256 of abc', () async {
      final digest = await sha256Of(utf8.encode('abc'));
      expect(
        toHex(digest),
        'ba7816bf8f01cfea414140de5dae2223'
        'b00361a396177a9cb410ff61f20015ad',
      );
    });
  });

  group('aead', () {
    test('RFC 8439 section 2.8.2 ChaCha20-Poly1305', () async {
      final key = Uint8List.fromList(List.generate(32, (i) => 0x80 + i));
      final nonce = fromHex('070000004041424344454647');
      final aad = fromHex('50515253c0c1c2c3c4c5c6c7');
      final plain = utf8.encode(
        "Ladies and Gentlemen of the class of '99: "
        'If I could offer you only one tip for the future, '
        'sunscreen would be it.',
      );

      final sealed = await Aead.chachaSeal(key, nonce, plain, aad: aad);
      expect(
        toHex(sealed.sublist(sealed.length - 16)),
        '1ae10b594f09e26a7e902ecbd0600691',
      );
      final opened = await Aead.chachaOpen(key, nonce, sealed, aad: aad);
      expect(opened, plain);
    });

    test('xSeal/xOpen round trip and tamper detection', () async {
      final key = randomBytes(32);
      final plain = utf8.encode('hello nest mojo');
      final sealed = await Aead.xSeal(key, plain);
      expect(await Aead.xOpen(key, sealed), plain);

      final tampered = Uint8List.fromList(sealed);
      tampered[sealed.length - 1] ^= 0x01;
      await expectLater(
        () => Aead.xOpen(key, tampered),
        throwsA(isA<AeadError>()),
      );
    });
  });

  group('sealed box', () {
    test('seal to recipient and reject wrong recipient', () async {
      final x = X25519();
      final pair1 = await x.newKeyPair();
      final pair2 = await x.newKeyPair();
      final pub1 = (await pair1.extractPublicKey()).bytes;
      final plain = utf8.encode('secret home key');

      final sealed = await SealedBox.seal(pub1, plain);
      expect(await SealedBox.open(pair1, sealed), plain);
      await expectLater(
        () => SealedBox.open(pair2, sealed),
        throwsA(isA<AeadError>()),
      );
    });
  });

  group('canonical json', () {
    test('sorts keys and removes whitespace', () {
      expect(
        canonicalJson({
          'b': 1,
          'a': [true, null, 'x'],
        }),
        '{"a":[true,null,"x"],"b":1}',
      );
      expect(
        canonicalJson({
          'z': {'y': 2, 'x': 1},
        }),
        '{"z":{"x":1,"y":2}}',
      );
    });

    test('rejects doubles and unsupported types', () {
      expect(() => canonicalJson(1.5), throwsArgumentError);
      expect(() => canonicalJson({'a': DateTime(2020)}), throwsArgumentError);
    });
  });

  group('ed25519', () {
    test('RFC 8032 test vector 1', () async {
      final ed = Ed25519();
      final seed = fromHex(
        '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
      );
      final kp = await ed.newKeyPairFromSeed(seed);
      final pub = await kp.extractPublicKey();
      expect(
        toHex(pub.bytes),
        'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      );
      final sig = await ed.sign(const [], keyPair: kp);
      expect(
        toHex(sig.bytes),
        'e5564300c360ac729086e2cc806e828a'
        '84877f1eb8e5d974d873e06522490155'
        '5fb8821590a33bacc61e39701cf9b46b'
        'd25bf5f0595bbe24655141438e7a100b',
      );
    });

    test('Signer enforces domain and body', () async {
      final kp = await Ed25519().newKeyPair();
      final pub = (await kp.extractPublicKey()).bytes;
      final sig = await Signer.sign(kp, SignDomain.op, const [1, 2]);

      expect(await Signer.verify(pub, SignDomain.op, const [1, 2], sig), isTrue);
      expect(
        await Signer.verify(pub, SignDomain.env, const [1, 2], sig),
        isFalse,
      );
      expect(
        await Signer.verify(pub, SignDomain.op, const [1, 3], sig),
        isFalse,
      );
      expect(await Signer.verify(pub, SignDomain.op, const [1, 2], ''), isFalse);
    });
  });

  group('x25519', () {
    test('RFC 7748 section 6.1 shared secret', () async {
      final x = X25519();
      final alice = await x.newKeyPairFromSeed(
        fromHex(
          '77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a',
        ),
      );
      final bobPub = SimplePublicKey(
        fromHex(
          'de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f',
        ),
        type: KeyPairType.x25519,
      );
      final shared = await x.sharedSecretKey(
        keyPair: alice,
        remotePublicKey: bobPub,
      );
      expect(
        toHex(await shared.extractBytes()),
        '4a5d9d5ba4ce2de1728e3bf480350f25e07e21c947d19e3376f09b3c1e161742',
      );
    });

    test('DeviceKeys signKeyPair matches signPub', () async {
      final k = await DeviceKeys.fromSeeds(
        List.filled(32, 1),
        List.filled(32, 2),
      );
      final kp = await k.signKeyPair();
      final pub = await kp.extractPublicKey();
      expect(pub.bytes, k.signPub);
    });
  });
}
