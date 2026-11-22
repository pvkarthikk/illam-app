import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/order_handoff.dart';

void main() {
  const line = HandoffLine(
    itemId: 'm1',
    name: 'Milk',
    qtyMilli: 2000,
    unit: 'L',
  );
  const startMs = 1795000000000;
  const handoff = PendingHandoff(
    channel: 'zepto',
    list: 'grocery',
    startedAtMs: startMs,
    lines: [line],
  );

  test('buildOrderText joins name and formatted quantity per line', () {
    expect(
      buildOrderText(const [
        (name: 'Milk', qtyMilli: 2000, unit: 'L'),
        (name: 'Dishwash liquid', qtyMilli: 1000, unit: ''),
      ]),
      'Milk 2 L\nDishwash liquid ×1',
    );
  });

  test('reviewHandoff classifies unchanged, decreased, increased, unitChanged, and omitted items', () {
    final same = reviewHandoff(handoff, const {
      'm1': CurrentItem(qtyMilli: 2000, unit: 'L', done: false, deleted: false),
    });
    expect(same.single.kind, HandoffKind.markDone);

    final smaller = reviewHandoff(handoff, const {
      'm1': CurrentItem(qtyMilli: 1000, unit: 'L', done: false, deleted: false),
    });
    expect(smaller.single.kind, HandoffKind.markDone);

    final larger = reviewHandoff(handoff, const {
      'm1': CurrentItem(qtyMilli: 3000, unit: 'L', done: false, deleted: false),
    });
    expect(larger.single.kind, HandoffKind.keepRemainder);
    expect(larger.single.currentMilli, 3000);

    final unitChanged = reviewHandoff(handoff, const {
      'm1': CurrentItem(qtyMilli: 1000, unit: 'pkt', done: false, deleted: false),
    });
    expect(unitChanged.single.kind, HandoffKind.unitChanged);

    expect(
      reviewHandoff(handoff, const {
        'm1': CurrentItem(qtyMilli: 2000, unit: 'L', done: false, deleted: true),
      }),
      isEmpty,
    );
    expect(reviewHandoff(handoff, const {}), isEmpty);
    expect(
      reviewHandoff(handoff, const {
        'm1': CurrentItem(qtyMilli: 2000, unit: 'L', done: true, deleted: false),
      }),
      isEmpty,
    );

    final extraIgnored = reviewHandoff(handoff, const {
      'm1': CurrentItem(qtyMilli: 2000, unit: 'L', done: false, deleted: false),
      'x9': CurrentItem(qtyMilli: 1000, unit: 'kg', done: false, deleted: false),
    });
    expect(extraIgnored.map((r) => r.line.itemId), ['m1']);
  });

  test('PendingHandoff JSON round trip and freshness threshold', () {
    final encoded = jsonEncode(handoff.toJson());
    final decoded = PendingHandoff.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );
    expect(decoded.toJson(), handoff.toJson());

    expect(
      isHandoffFresh(
        handoff,
        startMs + const Duration(hours: 1, minutes: 59).inMilliseconds,
      ),
      isTrue,
    );
    expect(
      isHandoffFresh(
        handoff,
        startMs + const Duration(hours: 2, minutes: 1).inMilliseconds,
      ),
      isFalse,
    );
  });
}
