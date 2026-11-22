class AttemptData {
  const AttemptData({
    required this.id,
    required this.kind,
    this.refAttemptId,
    this.amountPaise = 0,
    this.method,
    this.netPaise = 0,
    this.deltaPaise = 0,
    this.prevTransferIds = const [],
    this.createdAt = 0,
    this.byMember = '',
    this.expenseId,
  });

  final String id;
  final String kind;
  final String? refAttemptId;
  final int amountPaise;
  final String? method;
  final int netPaise;
  final int deltaPaise;
  final List<String> prevTransferIds;
  final int createdAt;
  final String byMember;
  final String? expenseId;
}

enum SettlementStatus { unsettled, paid, closedZero }

class SettlementState {
  const SettlementState({
    required this.status,
    required this.effective,
    required this.duplicates,
    required this.effectiveTransfers,
    required this.transferredDeltaPaise,
  });

  final SettlementStatus status;
  final AttemptData? effective;
  final List<AttemptData> duplicates;
  final List<AttemptData> effectiveTransfers;
  final int transferredDeltaPaise;

  int differencePaise(int recalculatedNetRupees) {
    final eff = effective;
    if (eff == null) return 0;
    return recalculatedNetRupees * 100 - (eff.netPaise + transferredDeltaPaise);
  }
}

SettlementState computeSettlement(List<AttemptData> attempts) {
  final sorted = [...attempts]
    ..sort((a, b) {
      final c = a.createdAt.compareTo(b.createdAt);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

  AttemptData? effective;
  final duplicates = <AttemptData>[];
  var effectiveTransfers = <AttemptData>[];

  for (final a in sorted) {
    switch (a.kind) {
      case 'settle':
        if (effective == null) {
          effective = a;
          effectiveTransfers = [];
        } else {
          duplicates.add(a);
        }
      case 'reverse':
        if (effective != null && a.refAttemptId == effective.id) {
          effective = null;
          effectiveTransfers = [];
        } else if (a.refAttemptId != null) {
          duplicates.removeWhere((d) => d.id == a.refAttemptId);
        }
      case 'transfer':
        if (effective != null) {
          final currentIds = {for (final t in effectiveTransfers) t.id};
          final prevIds = a.prevTransferIds.toSet();
          if (currentIds.length == prevIds.length &&
              currentIds.containsAll(prevIds)) {
            effectiveTransfers.add(a);
          } else {
            duplicates.add(a);
          }
        }
    }
  }

  final SettlementStatus status;
  if (effective == null) {
    status = SettlementStatus.unsettled;
  } else if (effective.amountPaise > 0) {
    status = SettlementStatus.paid;
  } else {
    status = SettlementStatus.closedZero;
  }

  var transferredDelta = 0;
  for (final t in effectiveTransfers) {
    transferredDelta += t.deltaPaise;
  }

  return SettlementState(
    status: status,
    effective: effective,
    duplicates: duplicates,
    effectiveTransfers: effectiveTransfers,
    transferredDeltaPaise: transferredDelta,
  );
}
