const int kSyncProtocolVersion = 1;

class HelloMsg {
  const HelloMsg({
    required this.v,
    required this.homeId,
    required this.deviceId,
    required this.now,
  });

  factory HelloMsg.fromJson(Map<String, Object?> m) => HelloMsg(
    v: (m['v'] as num).toInt(),
    homeId: m['homeId'] as String,
    deviceId: m['deviceId'] as String,
    now: (m['now'] as num).toInt(),
  );

  final int v;
  final String homeId;
  final String deviceId;
  final int now;

  Map<String, Object?> toJson() => {
    't': 'hello',
    'v': v,
    'homeId': homeId,
    'deviceId': deviceId,
    'now': now,
  };
}

class AuthMsg {
  const AuthMsg({required this.deviceId, required this.sig});

  factory AuthMsg.fromJson(Map<String, Object?> m) => AuthMsg(
    deviceId: m['deviceId'] as String,
    sig: m['sig'] as String,
  );

  final String deviceId;
  final String sig;

  Map<String, Object?> toJson() => {
    't': 'auth',
    'deviceId': deviceId,
    'sig': sig,
  };
}

class HaveMsg {
  const HaveMsg({required this.vector, required this.memberOpIds});

  factory HaveMsg.fromJson(Map<String, Object?> m) => HaveMsg(
    vector: {
      for (final e in (m['vector'] as Map).entries)
        e.key as String: (e.value as num).toInt(),
    },
    memberOpIds: [for (final x in m['memberOpIds'] as List) x as String],
  );

  final Map<String, int> vector;
  final List<String> memberOpIds;

  Map<String, Object?> toJson() => {
    't': 'have',
    'vector': vector,
    'memberOpIds': memberOpIds,
  };
}

class MemberOpsMsg {
  const MemberOpsMsg({required this.ops});

  factory MemberOpsMsg.fromJson(Map<String, Object?> m) => MemberOpsMsg(
    ops: [
      for (final x in m['ops'] as List) Map<String, Object?>.from(x as Map),
    ],
  );

  final List<Map<String, Object?>> ops;

  Map<String, Object?> toJson() => {'t': 'memberOps', 'ops': ops};
}

class OpsMsg {
  const OpsMsg({required this.batch});

  factory OpsMsg.fromJson(Map<String, Object?> m) => OpsMsg(
    batch: [
      for (final x in m['batch'] as List) Map<String, Object?>.from(x as Map),
    ],
  );

  final List<Map<String, Object?>> batch;

  Map<String, Object?> toJson() => {'t': 'ops', 'batch': batch};
}

class OpsDoneMsg {
  const OpsDoneMsg();

  factory OpsDoneMsg.fromJson(Map<String, Object?> m) => const OpsDoneMsg();

  Map<String, Object?> toJson() => const {'t': 'opsDone'};
}

class AckMsg {
  const AckMsg({required this.vector, required this.memberOps});

  factory AckMsg.fromJson(Map<String, Object?> m) => AckMsg(
    vector: {
      for (final e in (m['vector'] as Map).entries)
        e.key as String: (e.value as num).toInt(),
    },
    memberOps: (m['memberOps'] as num).toInt(),
  );

  final Map<String, int> vector;
  final int memberOps;

  Map<String, Object?> toJson() => {
    't': 'ack',
    'vector': vector,
    'memberOps': memberOps,
  };
}

class NoticeMsg {
  const NoticeMsg({required this.kind, required this.opId});

  factory NoticeMsg.fromJson(Map<String, Object?> m) => NoticeMsg(
    kind: m['kind'] as String,
    opId: m['opId'] as String,
  );

  final String kind;
  final String opId;

  Map<String, Object?> toJson() => {
    't': 'notice',
    'kind': kind,
    'opId': opId,
  };
}

class ByeMsg {
  const ByeMsg({required this.reason});

  factory ByeMsg.fromJson(Map<String, Object?> m) =>
      ByeMsg(reason: (m['reason'] as String?) ?? '');

  final String reason;

  Map<String, Object?> toJson() => {'t': 'bye', 'reason': reason};
}
