import 'dart:convert';
import 'dart:typed_data';

const int maxHeaderLength = 4096;
const int maxBodySize = 200 * 1024 * 1024;

const _magic = [0x4E, 0x4D, 0x42, 0x4B];
const _version = 1;

enum BackupError {
  notABackup,
  newerOrDamaged,
  wrongPassword,
  damaged,
  alreadyHere,
  download,
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.error);

  final BackupError error;

  @override
  String toString() => 'BackupFormatException($error)';
}

/// Argon2id parameters stored in the `.nmbak` header.
class KdfParams {
  const KdfParams({
    required this.memKiB,
    required this.t,
    required this.p,
  });

  final int memKiB;
  final int t;
  final int p;

  Map<String, Object?> toJson() => {
    'alg': 'argon2id',
    'm': memKiB,
    't': t,
    'p': p,
  };
}

/// Plaintext header metadata encoded at the front of every `.nmbak` file.
class BackupHeader {
  const BackupHeader({
    required this.vaultId,
    required this.snapshotId,
    required this.kind,
    required this.createdAt,
    required this.bodySize,
    required this.kdf,
    required this.salt,
    required this.nonce,
    this.keyCheck,
  });

  final String vaultId;
  final String snapshotId;
  final String kind;
  final int createdAt;
  final int bodySize;
  final KdfParams kdf;
  final Uint8List salt;
  final Uint8List nonce;
  final String? keyCheck;

  Map<String, Object?> toJson() => {
    'vaultId': vaultId,
    'snapshotId': snapshotId,
    'createdAt': createdAt,
    'kind': kind,
    'kdf': kdf.toJson(),
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'bodySize': bodySize,
    if (keyCheck != null) 'keyCheck': keyCheck,
  };
}

/// Serializes magic (`NMBK`), version (`1`), 4-byte length, and UTF-8 JSON header.
Uint8List encodePrefix(BackupHeader h) {
  final jsonBytes = utf8.encode(jsonEncode(h.toJson()));
  final len = ByteData(4)..setUint32(0, jsonBytes.length);
  final out = BytesBuilder(copy: false)
    ..add(_magic)
    ..addByte(_version)
    ..add(len.buffer.asUint8List())
    ..add(jsonBytes);
  return out.toBytes();
}

/// Validates and decodes the leading bytes of a `.nmbak` file before running Argon2id.
({BackupHeader header, int bodyOffset, Uint8List aad}) parseHeader(
  Uint8List head, {
  int? fileLength,
}) {
  if (head.length < 4 ||
      head[0] != _magic[0] ||
      head[1] != _magic[1] ||
      head[2] != _magic[2] ||
      head[3] != _magic[3]) {
    throw const BackupFormatException(BackupError.notABackup);
  }
  if (head.length < 9 || head[4] != _version) {
    throw const BackupFormatException(BackupError.newerOrDamaged);
  }

  final len = ByteData.sublistView(head, 5, 9).getUint32(0);
  if (len > maxHeaderLength || 9 + len > head.length) {
    throw const BackupFormatException(BackupError.newerOrDamaged);
  }

  final BackupHeader header;
  try {
    final decoded = jsonDecode(utf8.decode(head.sublist(9, 9 + len)));
    if (decoded is! Map) {
      throw const FormatException('header not object');
    }
    final vaultId = decoded['vaultId'];
    final snapshotId = decoded['snapshotId'];
    final createdAt = decoded['createdAt'];
    final kind = decoded['kind'];
    final kdfRaw = decoded['kdf'];
    final saltB64 = decoded['salt'];
    final nonceB64 = decoded['nonce'];
    final bodySize = decoded['bodySize'];
    final rawKeyCheck = decoded['keyCheck'];

    if (vaultId is! String ||
        snapshotId is! String ||
        createdAt is! int ||
        kind is! String ||
        (kind != 'full' && kind != 'data') ||
        kdfRaw is! Map ||
        saltB64 is! String ||
        nonceB64 is! String ||
        bodySize is! int) {
      throw const FormatException('bad header field');
    }

    final alg = kdfRaw['alg'];
    final m = kdfRaw['m'];
    final t = kdfRaw['t'];
    final p = kdfRaw['p'];
    if (alg != 'argon2id' ||
        m is! int ||
        t is! int ||
        p is! int ||
        m < 16384 ||
        m > 262144 ||
        t < 1 ||
        t > 10 ||
        p < 1 ||
        p > 4) {
      throw const FormatException('bad kdf');
    }

    final salt = base64Decode(saltB64);
    final nonce = base64Decode(nonceB64);
    if (salt.length != 16 || nonce.length != 24) {
      throw const FormatException('bad salt/nonce');
    }
    if (bodySize < 16 || bodySize > maxBodySize) {
      throw const FormatException('bad bodySize');
    }

    header = BackupHeader(
      vaultId: vaultId,
      snapshotId: snapshotId,
      kind: kind,
      createdAt: createdAt,
      bodySize: bodySize,
      kdf: KdfParams(memKiB: m, t: t, p: p),
      salt: salt,
      nonce: nonce,
      keyCheck: rawKeyCheck is String ? rawKeyCheck : null,
    );
  } on Object {
    throw const BackupFormatException(BackupError.newerOrDamaged);
  }

  final bodyOffset = 9 + len;
  if (fileLength != null && bodyOffset + header.bodySize != fileLength) {
    throw const BackupFormatException(BackupError.damaged);
  }

  return (
    header: header,
    bodyOffset: bodyOffset,
    aad: Uint8List.fromList(head.sublist(0, bodyOffset)),
  );
}

String _pad2(int v) => v.toString().padLeft(2, '0');

String backupFileName({
  required String vaultId,
  required String snapshotId,
  required int createdAtMs,
}) {
  final u = DateTime.fromMillisecondsSinceEpoch(createdAtMs, isUtc: true);
  final date = '${u.year.toString().padLeft(4, '0')}${_pad2(u.month)}${_pad2(u.day)}';
  final time = '${_pad2(u.hour)}${_pad2(u.minute)}${_pad2(u.second)}';
  final v8 = vaultId.substring(0, 8);
  final s8 = snapshotId.substring(0, 8);
  return 'Illam_${v8}_$date-${time}Z_$s8.nmbak';
}

final RegExp backupNameRe = RegExp(
  r'^Illam_([0-9a-f]{8})_(\d{8}-\d{6})Z_([0-9a-f]{8})\.nmbak$',
);

String formatBackupSize(int bytes) {
  const oneMb = 1048576;
  if (bytes < oneMb) {
    final kb = (bytes / 1024).ceil();
    return '$kb KB';
  }
  return '${(bytes / oneMb).toStringAsFixed(1)} MB';
}
