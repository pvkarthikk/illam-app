import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/usual_store.dart';

void main() {
  test('usualStore resolves learned stores, digit prefixes, and fallbacks', () {
    final c1 = usualStore(
      list: 'grocery',
      nameKey: 'eggs',
      usualByKey: const {'eggs': 'zepto'},
    );
    expect(c1.channel, 'zepto');
    expect(c1.learned, isTrue);

    final c2 = usualStore(
      list: 'grocery',
      nameKey: 'atta 5kg',
      usualByKey: const {'atta': 'bigbasket'},
    );
    expect(c2.channel, 'bigbasket');
    expect(c2.learned, isTrue);

    final c3 = usualStore(
      list: 'shopping',
      nameKey: 'usb hub',
      usualByKey: const {'charger': 'amazon'},
      lastChosen: 'flipkart',
    );
    expect(c3.channel, 'flipkart');
    expect(c3.learned, isFalse);

    final c4 = usualStore(
      list: 'grocery',
      nameKey: 'bedsheet',
      usualByKey: const {'bedsheet': 'meesho'},
    );
    expect(c4.channel, 'zepto');
    expect(c4.learned, isFalse);

    final c5 = usualStore(
      list: 'grocery',
      nameKey: 'dishwash liquid',
      usualByKey: const {'dishwash liquid': 'zepto'},
    );
    expect(c5.channel, 'zepto');
    expect(c5.learned, isTrue);
  });
}
