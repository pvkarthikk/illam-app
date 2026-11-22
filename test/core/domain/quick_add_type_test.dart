import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/quick_add_type.dart';

void main() {
  test('detectQuickAddType matches all P12.1 vectors', () {
    expect(detectQuickAddType('2 kg onions'), QaType.grocery);
    expect(detectQuickAddType('450 swiggy'), QaType.spend);
    expect(detectQuickAddType('Rs 300 milkman'), QaType.spend);
    expect(detectQuickAddType('Pay water bill tomorrow for Priya'), QaType.todo);
    expect(detectQuickAddType('₹450 Swiggy'), QaType.spend);
    expect(detectQuickAddType('phone charger'), QaType.shopping);
    expect(detectQuickAddType('milk 1L'), QaType.grocery);
    expect(detectQuickAddType('paid 1200 electricity bill'), QaType.spend);
    expect(detectQuickAddType('bread x2'), QaType.grocery);
    expect(detectQuickAddType('Call plumber'), QaType.todo);
  });
}
