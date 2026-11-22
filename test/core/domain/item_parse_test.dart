import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/item_parse.dart';

void main() {
  test('parseItem handles quantities, units, and casing', () {
    final cases = <(String input, String name, double qty, String unit)>[
      ('eggs 12 pcs', 'Eggs', 12, 'pcs'),
      ('Milk 2L', 'Milk', 2, 'L'),
      ('2 kg onions', 'Onions', 2, 'kg'),
      ('Rice 5kg', 'Rice', 5, 'kg'),
      ('Phone charger', 'Phone charger', 1, ''),
      ('Coriander, 1 bunch', 'Coriander', 1, 'bunch'),
      ('bread x2', 'Bread', 2, ''),
      ('milk 500 ML', 'Milk', 500, 'ml'),
      ('Atta 5 packets', 'Atta', 5, 'pkt'),
      ('LED bulbs 9W', 'LED bulbs 9W', 1, ''),
      ('Sugar 0', 'Sugar', 1, ''),
    ];

    for (final (input, name, qty, unit) in cases) {
      final parsed = parseItem(input);
      expect(parsed.name, name, reason: input);
      expect(parsed.qty, qty, reason: input);
      expect(parsed.unit, unit, reason: input);
    }
  });
}
