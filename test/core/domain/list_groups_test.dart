import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/list_groups.dart';

void main() {
  group('groupOpenItems', () {
    test('merges compatible items under earliest survivor and sums quantities', () {
      const a = ItemSnap(
        id: 'a',
        nameKey: 'milk',
        unit: 'L',
        qtyMilli: 1000,
        createdAt: 3,
      );
      const b = ItemSnap(
        id: 'b',
        nameKey: 'milk',
        unit: 'L',
        qtyMilli: 2000,
        createdAt: 5,
      );
      final groups = groupOpenItems(const [b, a]);
      expect(groups.length, 1);
      expect(groups.single.survivor.id, 'a');
      expect(groups.single.totalMilli, 3000);
      expect(groups.single.ids, ['a', 'b']);
    });

    test('converts ml into L under L survivor', () {
      const a = ItemSnap(
        id: 'a',
        nameKey: 'milk',
        unit: 'L',
        qtyMilli: 2000,
        createdAt: 1,
      );
      const b = ItemSnap(
        id: 'b',
        nameKey: 'milk',
        unit: 'ml',
        qtyMilli: 500000,
        createdAt: 2,
      );
      final groups = groupOpenItems(const [a, b]);
      expect(groups.length, 1);
      expect(groups.single.totalMilli, 2500);
      expect(groups.single.survivor.unit, 'L');
    });

    test('keeps L and pkt in separate groups', () {
      const a = ItemSnap(
        id: 'a',
        nameKey: 'milk',
        unit: 'L',
        qtyMilli: 2000,
        createdAt: 1,
      );
      const b = ItemSnap(
        id: 'b',
        nameKey: 'milk',
        unit: 'pkt',
        qtyMilli: 1000,
        createdAt: 2,
      );
      final groups = groupOpenItems(const [a, b]);
      expect(groups.length, 2);
    });

    test('sets checkQty when total is smaller than unit step', () {
      const small = ItemSnap(
        id: 'c1',
        nameKey: 'curd',
        unit: 'g',
        qtyMilli: 50000,
        createdAt: 1,
      );
      const normal = ItemSnap(
        id: 'c2',
        nameKey: 'curd',
        unit: 'g',
        qtyMilli: 400000,
        createdAt: 1,
      );
      expect(groupOpenItems(const [small]).single.checkQty, isTrue);
      expect(groupOpenItems(const [normal]).single.checkQty, isFalse);
    });
  });

  group('decideAdd', () {
    const milk2L = ItemSnap(
      id: 'm1',
      nameKey: 'milk',
      unit: 'L',
      qtyMilli: 2000,
      createdAt: 1,
    );

    test('merges same and convertible units into open survivor', () {
      final d1 = decideAdd(const [milk2L], 'milk', 'L', 1000);
      expect(d1, isA<MergeInto>());
      expect((d1 as MergeInto).incMilli, 1000);

      final d2 = decideAdd(const [milk2L], 'milk', 'ml', 500000);
      expect(d2, isA<MergeInto>());
      expect((d2 as MergeInto).incMilli, 500);
    });

    test('flags incompatible unit on existing item and returns AddNew for new item', () {
      final d3 = decideAdd(const [milk2L], 'milk', 'pkt', 1000);
      expect(d3, isA<Incompatible>());
      expect((d3 as Incompatible).group.survivor.id, 'm1');

      final d4 = decideAdd(const [milk2L], 'bread', '', 1000);
      expect(d4, isA<AddNew>());
    });
  });
}
