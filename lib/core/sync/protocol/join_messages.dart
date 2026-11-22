import 'dart:convert';

const int kProtocolVersion = 1;

final List<int> idJoiner = utf8.encode('nestmojo/joiner');
final List<int> idInviter = utf8.encode('nestmojo/inviter');

/// Join protocol message exchange order (every message is JSON with `t`, bytes as base64):
/// - J -> I: `hello{v, mode: 'phrase'|'qr'}`
/// - I -> J: `hello{v}` or `error{code: 'expired'|'version'|'busy'}`
/// - J -> I: `pake1{pA}` -> I -> J: `pake2{pB, cB}` -> J -> I: `pake3{cA}` (both `rekey(Ke)`)
/// - I -> J: `inviter{homeId, homeName, inviterName}`
/// - J -> I: `commit{c: sha256(nJ)}` -> I -> J: `nonceI{n}` -> J -> I: `reveal{n: nJ}`
/// - J -> I: `request{name, model, deviceId, signPub, agreePub}`
/// - I -> J: `approved{role}` or `denied{}`
/// - I -> J: `admit{homeId, memberOps, total}` -> `ops{batch}` x n -> `done{}` -> J -> I: `ack{}`
class JoinRequest {
  const JoinRequest({
    required this.name,
    required this.model,
    required this.deviceId,
    required this.signPub,
    required this.agreePub,
  });

  factory JoinRequest.fromJson(Map<String, Object?> j) => JoinRequest(
    name: (j['name'] as String?) ?? '',
    model: (j['model'] as String?) ?? '',
    deviceId: (j['deviceId'] as String?) ?? '',
    signPub: (j['signPub'] as String?) ?? '',
    agreePub: (j['agreePub'] as String?) ?? '',
  );

  final String name;
  final String model;
  final String deviceId;
  final String signPub;
  final String agreePub;

  Map<String, Object?> toJson() => {
    'name': name,
    'model': model,
    'deviceId': deviceId,
    'signPub': signPub,
    'agreePub': agreePub,
  };
}
