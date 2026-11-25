import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

/// Derives an unguessable Firestore channel ID for [homeId] under [homeKeyBytes].
Future<String> deriveRemoteChannelId(
  List<int> homeKeyBytes,
  String homeId,
) async {
  final mac = await hmacSha256(
    homeKeyBytes,
    utf8.encode('illam/remote/v1/channel/$homeId'),
  );
  return toHex(mac.sublist(0, 16));
}

/// Derives the 32-byte symmetric encryption key for remote op batches of [homeId].
Future<Uint8List> deriveRemoteEncKey(
  List<int> homeKeyBytes,
  String homeId,
) => hkdfSha256(
  ikm: homeKeyBytes,
  info: utf8.encode('illam/remote/v1/enc/$homeId'),
);

/// Plaintext structure sealed inside a remote Firestore batch document.
class RemoteBatchPayload {
  const RemoteBatchPayload({
    required this.homeId,
    required this.sender,
    required this.sentAt,
    required this.vector,
    required this.memberOpCount,
    this.memberOps = const [],
    this.ops = const [],
  });

  factory RemoteBatchPayload.fromJson(Map<String, Object?> j) {
    final v = (j['v'] as num?)?.toInt();
    if (v != 1) throw const FormatException('Unsupported remote batch version');
    final homeId = j['homeId'] as String?;
    final sender = j['sender'] as String?;
    if (homeId == null || homeId.isEmpty || sender == null || sender.isEmpty) {
      throw const FormatException('Missing remote batch identity');
    }
    return RemoteBatchPayload(
      homeId: homeId,
      sender: sender,
      sentAt: (j['sentAt'] as num?)?.toInt() ?? 0,
      vector: VersionVector.fromJson(
        Map<String, Object?>.from(j['vector'] as Map? ?? const {}),
      ),
      memberOpCount: (j['memberOpCount'] as num?)?.toInt() ?? 0,
      memberOps: [
        for (final m in j['memberOps'] as List? ?? const [])
          Map<String, Object?>.from(m as Map),
      ],
      ops: [
        for (final o in j['ops'] as List? ?? const [])
          Map<String, Object?>.from(o as Map),
      ],
    );
  }

  final String homeId;
  final String sender;
  final int sentAt;
  final VersionVector vector;
  final int memberOpCount;
  final List<Map<String, Object?>> memberOps;
  final List<Map<String, Object?>> ops;

  Map<String, Object?> toJson() => {
    'v': 1,
    'homeId': homeId,
    'sender': sender,
    'sentAt': sentAt,
    'vector': vector.toJson(),
    'memberOpCount': memberOpCount,
    'memberOps': memberOps,
    'ops': ops,
  };
}

List<int> _batchAad(String channelId, String keyId, String sender) =>
    utf8.encode('illam/remote/v1/$channelId/$keyId/$sender');

/// Compresses and XChaCha20-Poly1305 seals [payload] for [keyId] and [homeKeyBytes].
Future<({String channelId, String payloadB64})> sealRemoteBatch({
  required List<int> homeKeyBytes,
  required String keyId,
  required RemoteBatchPayload payload,
}) async {
  final channelId = await deriveRemoteChannelId(homeKeyBytes, payload.homeId);
  final encKey = await deriveRemoteEncKey(homeKeyBytes, payload.homeId);
  final jsonBytes = utf8.encode(jsonEncode(payload.toJson()));
  final compressed = const GZipEncoder().encode(jsonBytes);
  final sealed = await Aead.xSeal(
    encKey,
    compressed,
    aad: _batchAad(channelId, keyId, payload.sender),
  );
  return (channelId: channelId, payloadB64: b64(sealed));
}

/// Decrypts and decompresses a sealed batch payload, verifying channel, AAD, and metadata.
Future<RemoteBatchPayload> openRemoteBatch({
  required List<int> homeKeyBytes,
  required String homeId,
  required String channelId,
  required String keyId,
  required String sender,
  required String payloadB64,
}) async {
  final encKey = await deriveRemoteEncKey(homeKeyBytes, homeId);
  final sealed = unb64(payloadB64);
  final compressed = await Aead.xOpen(
    encKey,
    sealed,
    aad: _batchAad(channelId, keyId, sender),
  );
  final plain = const GZipDecoder().decodeBytes(compressed);
  final decoded = jsonDecode(utf8.decode(plain));
  if (decoded is! Map) {
    throw const FormatException('Invalid remote batch payload');
  }
  final payload = RemoteBatchPayload.fromJson(
    Map<String, Object?>.from(decoded),
  );
  if (payload.homeId != homeId || payload.sender != sender) {
    throw const FormatException('Mismatched remote batch header');
  }
  return payload;
}
