import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/net/lan_sync.dart';

void main() {
  test('lanTag and lanTagsFor rotate by UTC date and key', () async {
    final key1 = List.filled(32, 1);
    final key2 = List.filled(32, 2);

    final day1 = await lanTag(key1, DateTime.utc(2026, 11, 20));
    final day1Late = await lanTag(key1, DateTime.utc(2026, 11, 20, 23, 59));
    final day2 = await lanTag(key1, DateTime.utc(2026, 11, 21));
    final otherKey = await lanTag(key2, DateTime.utc(2026, 11, 20));

    expect(RegExp(r'^[0-9a-f]{8}$').hasMatch(day1), isTrue);
    expect(day1Late, day1);
    expect(day2, isNot(day1));
    expect(otherKey, isNot(day1));

    final tags = await lanTagsFor(key1, DateTime.utc(2026, 11, 20, 12));
    expect(tags.length, 2);
  });
}
