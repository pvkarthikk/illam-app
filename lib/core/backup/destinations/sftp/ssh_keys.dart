import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dartssh2/dartssh2.dart';

/// Ed25519 key generation and OpenSSH public-key formatting helpers.
class SshKeys {
  SshKeys._();

  static Future<Uint8List> newSeed() async {
    final pair = await Ed25519().newKeyPair();
    final seed = await pair.extractPrivateKeyBytes();
    return Uint8List.fromList(seed);
  }

  static Future<Uint8List> publicFromSeed(Uint8List seed) async {
    final pair = await Ed25519().newKeyPairFromSeed(seed);
    final pub = await pair.extractPublicKey();
    return Uint8List.fromList(pub.bytes);
  }

  static OpenSSHEd25519KeyPair keyPair(Uint8List seed, Uint8List pub) {
    final priv = Uint8List(seed.length + pub.length)
      ..setAll(0, seed)
      ..setAll(seed.length, pub);
    return OpenSSHEd25519KeyPair(pub, priv, 'illam');
  }

  static String publicLine(Uint8List pub) {
    final blob = BytesBuilder(copy: false)
      ..add(_sshString(utf8.encode('ssh-ed25519')))
      ..add(_sshString(pub));
    return 'ssh-ed25519 ${base64Encode(blob.takeBytes())} illam';
  }

  static Uint8List _sshString(List<int> data) {
    final out = Uint8List(4 + data.length);
    ByteData.sublistView(out).setUint32(0, data.length, Endian.big);
    out.setAll(4, data);
    return out;
  }
}
