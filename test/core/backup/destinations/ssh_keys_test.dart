import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/sftp/ssh_keys.dart';
import 'package:nm_flat/core/crypto/bytes.dart';

void main() {
  final rfcSeed = fromHex(
    '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
  );

  test('publicFromSeed matches RFC 8032 test vector 1', () async {
    final pub = await SshKeys.publicFromSeed(rfcSeed);
    expect(
      toHex(pub),
      'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
    );
  });

  test('publicLine encodes OpenSSH authorized_keys line', () async {
    final pub = await SshKeys.publicFromSeed(rfcSeed);
    expect(
      SshKeys.publicLine(pub),
      'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdamAGCsQq31Uv+08lkBzoO4XLz2qYjJa8CGmj3B1Ea nestmojo',
    );
  });

  test('keyPair holds 64-byte seed+public private key', () async {
    final pub = await SshKeys.publicFromSeed(rfcSeed);
    final kp = SshKeys.keyPair(rfcSeed, pub);
    expect(kp.privateKey.length, 64);
  });

  test('newSeed generates a 32-byte Ed25519 seed', () async {
    final seed = await SshKeys.newSeed();
    expect(seed.length, 32);
  });
}
