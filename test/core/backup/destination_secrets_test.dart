import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';

void main() {
  test('DestinationSecrets writes, reads, and deletes by destId', () async {
    final store = MemorySecureStore();
    final secrets = DestinationSecrets(store);

    await secrets.write('d1', 'pw');
    expect(await store.read('backup.secret.d1'), 'pw');
    expect(await secrets.read('d1'), 'pw');

    await secrets.delete('d1');
    expect(await secrets.read('d1'), isNull);
  });
}
