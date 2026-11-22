import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/settlement_state.dart';

void main() {
  test('one settle yields paid; two settles keep first and mark second duplicate', () {
    const s1 = AttemptData(
      id: 's1',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 100,
    );
    const s2 = AttemptData(
      id: 's2',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 200,
    );

    final one = computeSettlement(const [s1]);
    expect(one.status, SettlementStatus.paid);
    expect(one.effective?.id, 's1');
    expect(one.duplicates, isEmpty);

    final two = computeSettlement(const [s2, s1]);
    expect(two.status, SettlementStatus.paid);
    expect(two.effective?.id, 's1');
    expect(two.duplicates.map((d) => d.id), ['s2']);
  });

  test('reverse cancels effective settle and amount 0 yields closedZero', () {
    const s1 = AttemptData(
      id: 's1',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 100,
    );
    const r1 = AttemptData(
      id: 'r1',
      kind: 'reverse',
      refAttemptId: 's1',
      createdAt: 200,
    );
    const s2 = AttemptData(
      id: 's2',
      kind: 'settle',
      amountPaise: 0,
      netPaise: -800,
      createdAt: 300,
    );

    final reversed = computeSettlement(const [s1, r1]);
    expect(reversed.status, SettlementStatus.unsettled);
    expect(reversed.effective, isNull);

    final reSettled = computeSettlement(const [s1, r1, s2]);
    expect(reSettled.status, SettlementStatus.closedZero);
    expect(reSettled.effective?.id, 's2');
  });

  test('transfer chaining sums chained transfers and treats concurrent duplicate as duplicate', () {
    const s1 = AttemptData(
      id: 's1',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 100,
    );
    const t1 = AttemptData(
      id: 't1',
      kind: 'transfer',
      deltaPaise: 500,
      prevTransferIds: [],
      createdAt: 200,
    );
    const t2Chained = AttemptData(
      id: 't2',
      kind: 'transfer',
      deltaPaise: 200,
      prevTransferIds: ['t1'],
      createdAt: 300,
    );
    const t2Concurrent = AttemptData(
      id: 't2b',
      kind: 'transfer',
      deltaPaise: 200,
      prevTransferIds: [],
      createdAt: 300,
    );

    final chained = computeSettlement(const [s1, t1, t2Chained]);
    expect(chained.effectiveTransfers.map((t) => t.id), ['t1', 't2']);
    expect(chained.transferredDeltaPaise, 700);
    expect(chained.duplicates, isEmpty);

    final dup = computeSettlement(const [s1, t1, t2Concurrent]);
    expect(dup.effectiveTransfers.map((t) => t.id), ['t1']);
    expect(dup.transferredDeltaPaise, 500);
    expect(dup.duplicates.map((d) => d.id), ['t2b']);
  });

  test('reversing duplicate settle clears duplicate and differencePaise computes delta', () {
    const s1 = AttemptData(
      id: 's1',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 100,
    );
    const s2 = AttemptData(
      id: 's2',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 200,
    );
    const revDup = AttemptData(
      id: 'r2',
      kind: 'reverse',
      refAttemptId: 's2',
      createdAt: 300,
    );

    final afterRevDup = computeSettlement(const [s1, s2, revDup]);
    expect(afterRevDup.effective?.id, 's1');
    expect(afterRevDup.duplicates, isEmpty);
    expect(afterRevDup.differencePaise(300), 700);
  });
}
