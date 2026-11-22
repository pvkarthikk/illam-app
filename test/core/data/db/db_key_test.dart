import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/db_key.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';

void main() {
  test('DbKey generates, caches, and repairs invalid database keys', () async {
    final store = MemorySecureStore();

    final first = await DbKey.loadOrCreate(store);
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(first), isTrue);
    expect(await store.read('db.key.v1'), first);

    final second = await DbKey.loadOrCreate(store);
    expect(second, first);

    await store.write('db.key.v1', 'abc');
    final repaired = await DbKey.loadOrCreate(store);
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(repaired), isTrue);
    expect(repaired, isNot('abc'));
    expect(await store.read('db.key.v1'), repaired);
  });
}
