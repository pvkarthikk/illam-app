import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/ops/merge_rules.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  test('MergeRules.shouldApplySet and applyInc follow LWW and addition', () {
    final a = const Hlc(1000, 0, 'aaaa').toString();
    final b = const Hlc(1000, 1, 'aaaa').toString();

    expect(MergeRules.shouldApplySet(null, a), isTrue);
    expect(MergeRules.shouldApplySet(a, b), isTrue);
    expect(MergeRules.shouldApplySet(a, a), isFalse);
    expect(MergeRules.shouldApplySet(b, a), isFalse);
    expect(MergeRules.applyInc(2, 3), 5);
    expect(MergeRules.applyInc(5, -5), 0);
  });
}
