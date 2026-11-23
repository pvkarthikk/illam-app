import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/spake2.dart';

void main() {
  test('hkdfSync matches RFC 5869 case 1 and default zero salt', () {
    final out = hkdfSync(
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

    final x = utf8.encode('input key material');
    expect(hkdfSync(ikm: x), hkdfSync(ikm: x, salt: Uint8List(32)));
  });

  group('SPAKE2 RFC 9382 Appendix B P-256 vectors', () {
    final vectors = [
      (
        a: 'server',
        b: 'client',
        w: '2ee57912099d31560b3a44b1184b9b4866e904c49d12ac5042c97dca461b1a5f',
        x: '43dd0fd7215bdcb482879fca3220c6a968e66d70b1356cac18bb26c84a78d729',
        y: 'dcb60106f276b02606d8ef0a328c02e4b629f84f89786af5befb0bc75b6e66be',
        ke: '0e0672dc86f8e45565d338b0540abe69',
        cA: '58ad4aa88e0b60d5061eb6b5dd93e80d9c4f00d127c65b3b35b1b5281fee38f0',
        cB: 'd3e2e547f1ae04f2dbdbf0fc4b79f8ecff2dff314b5d32fe9fcef2fb26dc459b',
      ),
      (
        a: '',
        b: 'client',
        w: '0548d8729f730589e579b0475a582c1608138ddf7054b73b5381c7e883e2efae',
        x: '403abbe3b1b4b9ba17e3032849759d723939a27a27b9d921c500edde18ed654b',
        y: '903023b6598908936ea7c929bd761af6039577a9c3f9581064187c3049d87065',
        ke: '642f05c473c2cd79909f9a841e2f30a7',
        cA: '47d29e6666af1b7dd450d571233085d7a9866e4d49d2645e2df975489521232b',
        cB: '3313c5cefc361d27fb16847a91c2a73b766ffa90a4839122a9b70a2f6bd1d6df',
      ),
      (
        a: 'server',
        b: '',
        w: '626e0cdc7b14c9db3e52a0b1b3a768c98e37852d5db30febe0497b14eae8c254',
        x: '07adb3db6bc623d3399726bfdbfd3d15a58ea776ab8a308b00392621291f9633',
        y: 'b6a4fc8dbb629d4ba51d6f91ed1532cf87adec98f25dd153a75accafafedec16',
        ke: '005184ff460da2ce59062c87733c299c',
        cA: 'bc9f9bbe99f26d0b2260e6456e05a86196a3307ec6663a18bf6ac825736533b2',
        cB: 'c2370e1bf813b086dff0d834e74425a06e6390f48f5411900276dcccc5a297ec',
      ),
      (
        a: '',
        b: '',
        w: '7bf46c454b4c1b25799527d896508afd5fc62ef4ec59db1efb49113063d70cca',
        x: '8cef65df64bb2d0f83540c53632de911b5b24b3eab6cc74a97609fd659e95473',
        y: 'd7a66f64074a84652d8d623a92e20c9675c61cb5b4f6a0063e4648a2fdc02d53',
        ke: 'fc6374762ba5cf11f4b2caa08b2cd1b9',
        cA: 'dfb4db8d48ae5a675963ea5e6c19d98d4ea028d8e898dad96ea19a80ade95dca',
        cB: 'd0f0609d1613138d354f7e95f19fb556bf52d751947241e8c7118df5ef0ae175',
      ),
    ];

    test('vector 1 specific values pA, pB, kcA, kcB', () {
      final v = vectors.first;
      final a = Spake2.a(
        w: BigInt.parse(v.w, radix: 16),
        x: BigInt.parse(v.x, radix: 16),
        idA: utf8.encode(v.a),
        idB: utf8.encode(v.b),
      );
      final b = Spake2.b(
        w: BigInt.parse(v.w, radix: 16),
        y: BigInt.parse(v.y, radix: 16),
        idA: utf8.encode(v.a),
        idB: utf8.encode(v.b),
      );
      final pA = a.start();
      final pB = b.start();
      expect(
        toHex(pA),
        '04a56fa807caaa53a4d28dbb9853b9815c61a411118a6fe516a8798434751470f9010153ac33d0d5f2047ffdb1a3e42c9b4e6be662766e1eeb4116988ede5f912c',
      );
      expect(
        toHex(pB),
        '0406557e482bd03097ad0cbaa5df82115460d951e3451962f1eaf4367a420676d09857ccbc522686c83d1852abfa8ed6e4a1155cf8f1543ceca528afb591a1e0b7',
      );
      final ka = a.finish(pB);
      final kb = b.finish(pA);
      expect(toHex(ka.ke), '0e0672dc86f8e45565d338b0540abe69');
      expect(toHex(ka.kcA), '00c12546835755c86d8c0db7851ae86f');
      expect(toHex(ka.kcB), 'a9fa3406c3b781b93d804485430ca27a');
      expect(toHex(kb.ke), toHex(ka.ke));
    });

    test('startAsync/finishAsync match the synchronous results', () async {
      final v = vectors.first;
      Spake2 side(bool isA) => isA
          ? Spake2.a(
              w: BigInt.parse(v.w, radix: 16),
              x: BigInt.parse(v.x, radix: 16),
              idA: utf8.encode(v.a),
              idB: utf8.encode(v.b),
            )
          : Spake2.b(
              w: BigInt.parse(v.w, radix: 16),
              y: BigInt.parse(v.y, radix: 16),
              idA: utf8.encode(v.a),
              idB: utf8.encode(v.b),
            );
      final a = side(true);
      final b = side(false);
      final pA = await a.startAsync();
      final pB = await b.startAsync();
      expect(toHex(pA), toHex(side(true).start()));
      final ka = await a.finishAsync(pB);
      final kb = await b.finishAsync(pA);
      expect(toHex(ka.ke), '0e0672dc86f8e45565d338b0540abe69');
      expect(toHex(kb.ke), toHex(ka.ke));
    });

    test('all 4 RFC 9382 Appendix B vectors match Ke, cA, cB on both sides', () {
      for (final v in vectors) {
        final a = Spake2.a(
          w: BigInt.parse(v.w, radix: 16),
          x: BigInt.parse(v.x, radix: 16),
          idA: utf8.encode(v.a),
          idB: utf8.encode(v.b),
        );
        final b = Spake2.b(
          w: BigInt.parse(v.w, radix: 16),
          y: BigInt.parse(v.y, radix: 16),
          idA: utf8.encode(v.a),
          idB: utf8.encode(v.b),
        );
        final pA = a.start();
        final pB = b.start();
        final ka = a.finish(pB);
        final kb = b.finish(pA);
        expect(toHex(ka.ke), v.ke);
        expect(toHex(kb.ke), v.ke);
        expect(toHex(ka.cA), v.cA);
        expect(toHex(kb.cA), v.cA);
        expect(toHex(ka.cB), v.cB);
        expect(toHex(kb.cB), v.cB);
      }
    });

    test('password mismatch vs match and bad point checks', () {
      final w1 = Spake2.passwordToW(utf8.encode('a b c'), 'ctx');
      final w2 = Spake2.passwordToW(utf8.encode('a b d'), 'ctx');

      final a1 = Spake2.a(w: w1);
      final b1 = Spake2.b(w: w1);
      final mA1 = a1.start();
      final mB1 = b1.start();
      expect(a1.finish(mB1).ke, b1.finish(mA1).ke);
      expect(a1.finish(mB1).ke.length, 16);

      final aDiff = Spake2.a(w: w1);
      final bDiff = Spake2.b(w: w2);
      final mAD = aDiff.start();
      final mBD = bDiff.start();
      expect(aDiff.finish(mBD).peerConfirm, isNot(bDiff.finish(mAD).myConfirm));

      final fresh = Spake2.a(w: w1);
      expect(() => fresh.finish(mBD), throwsA(isA<Spake2Error>()));

      final badPt = Uint8List(65)
        ..[0] = 4
        ..[64] = 1;
      expect(() => a1.finish(badPt), throwsA(isA<Spake2Error>()));
    });
  });
}
