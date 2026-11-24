import 'dart:math';

enum PayType { hourly, monthly }

class PayRulesData {
  const PayRulesData({
    required this.effectiveMonth,
    required this.workDays,
    required this.type,
    this.ratePerHourPaise = 0,
    this.roundingMin = 1,
    this.minHoursPerVisit = 0,
    this.amountPerMonthPaise = 0,
    this.paidLeavesPerMonth = 0,
    this.createdAt = 0,
    this.id = '',
  });

  factory PayRulesData.fromJson(Map<String, Object?> j) => PayRulesData(
    effectiveMonth: j['effectiveMonth'] as String? ?? '',
    workDays: [
      for (final d in (j['workDays'] as List? ?? const <Object?>[]))
        (d as num).toInt(),
    ],
    type: PayType.values.byName(j['type'] as String? ?? 'hourly'),
    ratePerHourPaise: (j['ratePerHourPaise'] as num?)?.toInt() ?? 0,
    roundingMin: (j['roundingMin'] as num?)?.toInt() ?? 1,
    minHoursPerVisit: (j['minHoursPerVisit'] as num?)?.toInt() ?? 0,
    amountPerMonthPaise: (j['amountPerMonthPaise'] as num?)?.toInt() ?? 0,
    paidLeavesPerMonth: (j['paidLeavesPerMonth'] as num?)?.toInt() ?? 0,
    createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
    id: j['id'] as String? ?? '',
  );

  static List<int> parseDays(String s) => [
    for (final part in s.split(','))
      if (part.trim().isNotEmpty) int.parse(part.trim()),
  ];

  final String effectiveMonth;
  final List<int> workDays;
  final PayType type;
  final int ratePerHourPaise;
  final int roundingMin;
  final int minHoursPerVisit;
  final int amountPerMonthPaise;
  final int paidLeavesPerMonth;
  final int createdAt;
  final String id;

  Map<String, Object?> toJson() => {
    'effectiveMonth': effectiveMonth,
    'workDays': workDays,
    'type': type.name,
    'ratePerHourPaise': ratePerHourPaise,
    'roundingMin': roundingMin,
    'minHoursPerVisit': minHoursPerVisit,
    'amountPerMonthPaise': amountPerMonthPaise,
    'paidLeavesPerMonth': paidLeavesPerMonth,
    'createdAt': createdAt,
    'id': id,
  };
}

class PayVisit {
  const PayVisit(this.date, this.inMs, [this.outMs]);

  final String date;
  final int inMs;
  final int? outMs;
}

class PayAdj {
  const PayAdj(this.kind, this.amountPaise, this.note);

  factory PayAdj.fromJson(Map<String, Object?> j) => PayAdj(
    j['kind'] as String? ?? '',
    (j['amountPaise'] as num?)?.toInt() ?? 0,
    j['note'] as String? ?? '',
  );

  final String kind;
  final int amountPaise;
  final String note;

  Map<String, Object?> toJson() => {
    'kind': kind,
    'amountPaise': amountPaise,
    'note': note,
  };
}

class PayrollInput {
  const PayrollInput({
    required this.month,
    required this.today,
    required this.startDate,
    this.endDate,
    required this.rules,
    required this.visits,
    required this.leaveDates,
    required this.adjustments,
  });

  final String month;
  final String today;
  final String startDate;
  final String? endDate;
  final List<PayRulesData> rules;
  final List<PayVisit> visits;
  final Set<String> leaveDates;
  final List<PayAdj> adjustments;
}

int roundHalfUp(int n, int d) => (2 * n + d) ~/ (2 * d);

int roundHalfUpSigned(int n, int d) =>
    n < 0 ? -roundHalfUp(-n, d) : roundHalfUp(n, d);

class PayrollResult {
  const PayrollResult({
    this.noRules = false,
    this.notWorking = false,
    this.rules,
    this.presentDays = 0,
    this.absentDays = 0,
    this.leaveDays = 0,
    this.unpaidDays = 0,
    this.visitCount = 0,
    this.actualMinutes = 0,
    this.billedMinutes = 0,
    this.workDaysInMonth = 0,
    this.eligibleWorkDays = 0,
    this.perDayPaise = 0,
    this.grossPaise = 0,
    this.leaveDeductionPaise = 0,
    this.netPaise = 0,
    this.netRupees = 0,
    this.toPayRupees = 0,
    this.carryRupees = 0,
    this.extras = const [],
    this.advances = const [],
    this.deductions = const [],
  });

  factory PayrollResult.fromJson(Map<String, Object?> j) {
    final rawRules = j['rules'];
    return PayrollResult(
      noRules: j['noRules'] as bool? ?? false,
      notWorking: j['notWorking'] as bool? ?? false,
      rules: rawRules is Map
          ? PayRulesData.fromJson(Map<String, Object?>.from(rawRules))
          : null,
      presentDays: (j['presentDays'] as num?)?.toInt() ?? 0,
      absentDays: (j['absentDays'] as num?)?.toInt() ?? 0,
      leaveDays: (j['leaveDays'] as num?)?.toInt() ?? 0,
      unpaidDays: (j['unpaidDays'] as num?)?.toInt() ?? 0,
      visitCount: (j['visitCount'] as num?)?.toInt() ?? 0,
      actualMinutes: (j['actualMinutes'] as num?)?.toInt() ?? 0,
      billedMinutes: (j['billedMinutes'] as num?)?.toInt() ?? 0,
      workDaysInMonth: (j['workDaysInMonth'] as num?)?.toInt() ?? 0,
      eligibleWorkDays: (j['eligibleWorkDays'] as num?)?.toInt() ?? 0,
      perDayPaise: (j['perDayPaise'] as num?)?.toInt() ?? 0,
      grossPaise: (j['grossPaise'] as num?)?.toInt() ?? 0,
      leaveDeductionPaise: (j['leaveDeductionPaise'] as num?)?.toInt() ?? 0,
      netPaise: (j['netPaise'] as num?)?.toInt() ?? 0,
      netRupees: (j['netRupees'] as num?)?.toInt() ?? 0,
      toPayRupees: (j['toPayRupees'] as num?)?.toInt() ?? 0,
      carryRupees: (j['carryRupees'] as num?)?.toInt() ?? 0,
      extras: _decodeAdjList(j['extras']),
      advances: _decodeAdjList(j['advances']),
      deductions: _decodeAdjList(j['deductions']),
    );
  }

  static List<PayAdj> _decodeAdjList(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) PayAdj.fromJson(Map<String, Object?>.from(item)),
    ];
  }

  final bool noRules;
  final bool notWorking;
  final PayRulesData? rules;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final int unpaidDays;
  final int visitCount;
  final int actualMinutes;
  final int billedMinutes;
  final int workDaysInMonth;
  final int eligibleWorkDays;
  final int perDayPaise;
  final int grossPaise;
  final int leaveDeductionPaise;
  final int netPaise;
  final int netRupees;
  final int toPayRupees;
  final int carryRupees;
  final List<PayAdj> extras;
  final List<PayAdj> advances;
  final List<PayAdj> deductions;

  Map<String, Object?> toJson() => {
    'noRules': noRules,
    'notWorking': notWorking,
    'rules': rules?.toJson(),
    'presentDays': presentDays,
    'absentDays': absentDays,
    'leaveDays': leaveDays,
    'unpaidDays': unpaidDays,
    'visitCount': visitCount,
    'actualMinutes': actualMinutes,
    'billedMinutes': billedMinutes,
    'workDaysInMonth': workDaysInMonth,
    'eligibleWorkDays': eligibleWorkDays,
    'perDayPaise': perDayPaise,
    'grossPaise': grossPaise,
    'leaveDeductionPaise': leaveDeductionPaise,
    'netPaise': netPaise,
    'netRupees': netRupees,
    'toPayRupees': toPayRupees,
    'carryRupees': carryRupees,
    'extras': [for (final e in extras) e.toJson()],
    'advances': [for (final a in advances) a.toJson()],
    'deductions': [for (final d in deductions) d.toJson()],
  };
}

PayrollResult computePayroll(PayrollInput input) {
  if (input.rules.isEmpty) {
    return const PayrollResult(noRules: true);
  }

  final rule = _pickRule(input.rules, input.month);
  final monthDays = _utcMonthDays(input.month);
  final workDaySet = rule.workDays.toSet();
  final lastDayOfM = monthDays.last.$1;
  final asOf = input.today.compareTo(lastDayOfM) <= 0 ? input.today : lastDayOfM;

  final extras = <PayAdj>[];
  final advances = <PayAdj>[];
  final deductions = <PayAdj>[];
  var extraSum = 0;
  var advanceSum = 0;
  var deductionSum = 0;
  for (final a in input.adjustments) {
    switch (a.kind) {
      case 'extra':
        extras.add(a);
        extraSum += a.amountPaise;
      case 'advance':
        advances.add(a);
        advanceSum += a.amountPaise;
      case 'deduction':
        deductions.add(a);
        deductionSum += a.amountPaise;
    }
  }
  final adjNetPaise = extraSum - advanceSum - deductionSum;

  final eligibleDays = <(String date, int weekday)>[
    for (final day in monthDays)
      if (day.$1.compareTo(input.startDate) >= 0 &&
          (input.endDate == null || day.$1.compareTo(input.endDate!) <= 0))
        day,
  ];

  if (eligibleDays.isEmpty) {
    final netNum = adjNetPaise;
    const den = 1;
    final netPaise = roundHalfUpSigned(netNum, den);
    final netRupees = roundHalfUpSigned(netNum, den * 100);
    return PayrollResult(
      notWorking: true,
      rules: rule,
      netPaise: netPaise,
      netRupees: netRupees,
      toPayRupees: max(0, netRupees),
      carryRupees: netRupees < 0 ? -netRupees : 0,
      extras: extras,
      advances: advances,
      deductions: deductions,
    );
  }

  final eligibleDateSet = {for (final d in eligibleDays) d.$1};
  final billable = [
    for (final v in input.visits)
      if (v.outMs != null &&
          eligibleDateSet.contains(v.date) &&
          v.date.compareTo(asOf) <= 0)
        (inMs: v.inMs, outMs: v.outMs!),
  ]..sort((a, b) => a.inMs.compareTo(b.inMs));

  final merged = <({int inMs, int outMs})>[];
  for (final v in billable) {
    if (merged.isEmpty || v.inMs >= merged.last.outMs) {
      merged.add(v);
    } else {
      final last = merged.removeLast();
      merged.add((inMs: last.inMs, outMs: max(last.outMs, v.outMs)));
    }
  }

  final rounding = rule.roundingMin > 0 ? rule.roundingMin : 1;
  var actualMinutes = 0;
  var billedMinutes = 0;
  for (final iv in merged) {
    final m = max(0, iv.outMs - iv.inMs) ~/ 60000;
    actualMinutes += m;
    if (rule.type == PayType.hourly) {
      final rounded = roundHalfUp(m, rounding) * rounding;
      billedMinutes += max(rounded, rule.minHoursPerVisit * 60);
    }
  }

  final visitDates = {
    for (final v in input.visits)
      if (eligibleDateSet.contains(v.date) && v.date.compareTo(asOf) <= 0)
        v.date,
  };

  var presentDays = 0;
  var leaveDays = 0;
  var absentDays = 0;
  for (final (date, weekday) in eligibleDays) {
    if (date.compareTo(asOf) > 0) continue;
    final isWorkDay = workDaySet.contains(weekday);
    if (visitDates.contains(date)) {
      presentDays++;
    } else if (isWorkDay && input.leaveDates.contains(date)) {
      leaveDays++;
    } else if (isWorkDay && date.compareTo(input.today) < 0) {
      absentDays++;
    }
  }

  var workDaysInMonth = 0;
  for (final (_, weekday) in monthDays) {
    if (workDaySet.contains(weekday)) workDaysInMonth++;
  }
  var eligibleWorkDays = 0;
  for (final (_, weekday) in eligibleDays) {
    if (workDaySet.contains(weekday)) eligibleWorkDays++;
  }

  var unpaidDays = 0;
  var perDayPaise = 0;
  var leaveDeductionPaise = 0;
  late final int grossNum;
  late final int den;

  if (rule.type == PayType.hourly) {
    grossNum = billedMinutes * rule.ratePerHourPaise;
    den = 60;
  } else {
    final wdm = workDaysInMonth;
    final el = eligibleWorkDays;
    if (wdm == 0) {
      grossNum = 0;
      den = 1;
    } else {
      final paidLeavesEff = (rule.paidLeavesPerMonth * el) ~/ wdm;
      unpaidDays = max(0, absentDays + leaveDays - paidLeavesEff);
      grossNum = max(0, rule.amountPerMonthPaise * (el - unpaidDays));
      den = wdm;
      perDayPaise = roundHalfUp(rule.amountPerMonthPaise, wdm);
      leaveDeductionPaise = roundHalfUp(
        rule.amountPerMonthPaise * unpaidDays,
        wdm,
      );
    }
  }

  final netNum = grossNum + adjNetPaise * den;
  final grossPaise = roundHalfUpSigned(grossNum, den);
  final netPaise = roundHalfUpSigned(netNum, den);
  final netRupees = roundHalfUpSigned(netNum, den * 100);
  final toPayRupees = max(0, netRupees);
  final carryRupees = netRupees < 0 ? -netRupees : 0;

  return PayrollResult(
    rules: rule,
    presentDays: presentDays,
    absentDays: absentDays,
    leaveDays: leaveDays,
    unpaidDays: unpaidDays,
    visitCount: merged.length,
    actualMinutes: actualMinutes,
    billedMinutes: billedMinutes,
    workDaysInMonth: workDaysInMonth,
    eligibleWorkDays: eligibleWorkDays,
    perDayPaise: perDayPaise,
    grossPaise: grossPaise,
    leaveDeductionPaise: leaveDeductionPaise,
    netPaise: netPaise,
    netRupees: netRupees,
    toPayRupees: toPayRupees,
    carryRupees: carryRupees,
    extras: extras,
    advances: advances,
    deductions: deductions,
  );
}

List<int>? workDaysForMonth(List<PayRulesData> rules, String month) =>
    rules.isEmpty ? null : _pickRule(rules, month).workDays;

PayRulesData _pickRule(List<PayRulesData> rules, String month) {
  final eligible = [
    for (final r in rules)
      if (r.effectiveMonth.compareTo(month) <= 0) r,
  ];
  if (eligible.isNotEmpty) {
    var best = eligible.first;
    for (final r in eligible.skip(1)) {
      if (_compareRuleTieDesc(r, best) > 0) best = r;
    }
    return best;
  }
  var earliest = rules.first;
  for (final r in rules.skip(1)) {
    final cm = r.effectiveMonth.compareTo(earliest.effectiveMonth);
    if (cm < 0 || (cm == 0 && _compareTieOnly(r, earliest) > 0)) {
      earliest = r;
    }
  }
  return earliest;
}

int _compareRuleTieDesc(PayRulesData a, PayRulesData b) {
  final cm = a.effectiveMonth.compareTo(b.effectiveMonth);
  if (cm != 0) return cm;
  return _compareTieOnly(a, b);
}

int _compareTieOnly(PayRulesData a, PayRulesData b) {
  final cc = a.createdAt.compareTo(b.createdAt);
  if (cc != 0) return cc;
  return a.id.compareTo(b.id);
}

List<(String, int)> _utcMonthDays(String yyyyMm) {
  final parts = yyyyMm.split('-');
  final y = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final out = <(String, int)>[];
  for (var d = DateTime.utc(y, m, 1); d.month == m; d = d.add(const Duration(days: 1))) {
    final iso =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    out.add((iso, d.weekday));
  }
  return out;
}
