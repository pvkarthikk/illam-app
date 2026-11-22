import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/store_aisles.dart';

void main() {
  test('sortAisles orders known aisles then sorts unknown A-Z without duplicates', () {
    expect(
      sortAisles(const ['Other', 'Dairy', 'Snacks', 'Vegetables', 'Apples']),
      ['Vegetables', 'Dairy', 'Other', 'Apples', 'Snacks'],
    );
    expect(sortAisles(const ['Dairy', 'Dairy']), ['Dairy']);
  });
}
