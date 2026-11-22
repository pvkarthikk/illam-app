import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/units.dart';

void main() {
  test('starter_recipes.json contains 9 valid unique recipes', () {
    final raw = File('assets/data/starter_recipes.json').readAsStringSync();
    final list = (jsonDecode(raw) as List)
        .map((e) => Map<String, Object?>.from(e as Map))
        .toList();

    expect(list.length, 9);

    final names = <String>{};
    for (final r in list) {
      final name = r['name'] as String;
      expect(names.add(name), isTrue, reason: 'Duplicate recipe name: $name');

      final tags = (r['tags'] as List).cast<String>();
      expect(tags, isNotEmpty);
      expect(
        tags.first,
        anyOf('Breakfast', 'Lunch', 'Dinner'),
        reason: 'Invalid meal type for $name',
      );

      final ings = r['ing'] as List;
      expect(ings, isNotEmpty, reason: 'No ingredients for $name');
      for (final ing in ings) {
        final row = ing as List;
        final unit = row[2] as String;
        expect(
          allUnits,
          contains(unit),
          reason: 'Invalid unit "$unit" in $name',
        );
      }

      final steps = r['steps'] as List;
      expect(steps, isNotEmpty, reason: 'No steps for $name');
    }
  });
}
