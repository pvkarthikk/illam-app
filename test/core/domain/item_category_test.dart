import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/item_category.dart';

void main() {
  test('guessCategory classifies common household items', () {
    expect(guessCategory('Milk'), 'Dairy');
    expect(guessCategory('Green chillies'), 'Vegetables');
    expect(guessCategory('Bananas'), 'Fruits');
    expect(guessCategory('Toor dal'), 'Staples');
    expect(guessCategory('Dishwash liquid'), 'Cleaning');
    expect(guessCategory('Eggs'), 'Breakfast');
    expect(guessCategory('Phone charger'), 'Electronics');
    expect(guessCategory('Cotton bedsheet set'), 'Other');
  });
}
