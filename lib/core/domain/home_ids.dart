import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/util/base32.dart';

abstract final class HomeIds {
  /// Compact JSON of the home's founding facts. A later phase signs this as
  /// the first op.
  static String genesisJson({
    required String homeName,
    required String creatorName,
    required String creatorDeviceId,
    required String signPubB64,
    required int createdAt,
    required String nonceB64,
  }) => jsonEncode({
    'type': 'genesis',
    'homeName': homeName,
    'creatorName': creatorName,
    'creatorDeviceId': creatorDeviceId,
    'signPub': signPubB64,
    'createdAt': createdAt,
    'nonce': nonceB64,
  });

  static Future<String> fromGenesis(String genesisJson) async {
    final h = await Sha256().hash(utf8.encode(genesisJson));
    return 'NM-${Base32.encode(h.bytes).substring(0, 8)}';
  }

  static String display(String homeId) => homeId.length == 11
      ? '${homeId.substring(0, 7)}-${homeId.substring(7)}'
      : homeId;
}
