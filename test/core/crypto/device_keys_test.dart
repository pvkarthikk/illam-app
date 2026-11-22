import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/util/ids.dart';

List<int> _unhex(String h) => [
  for (var i = 0; i < h.length; i += 2) int.parse(h.substring(i, i + 2), radix: 16),
];

void main() {
  test('RFC 8032 test 1 seed derives expected identity', () async {
    final seed = _unhex(
      '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
    );
    final keys = await DeviceKeys.fromSeeds(seed, seed);
    expect(
      Ids.hex(keys.signPub),
      'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
    );
    expect(keys.deviceId, 'eh7ddx5bksrgcytl');
    expect(keys.fingerprint, '21fe 31df a154');
    expect(keys.signPubB64, '11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=');
  });

  test('ensure is stable, deleteAll rotates, load of empty store is null', () async {
    final store = MemorySecureStore();
    final a = await DeviceKeys.ensure(store);
    final b = await DeviceKeys.ensure(store);
    expect(b.deviceId, a.deviceId);
    expect(await store.read('device.sign.seed'), isNotNull);
    expect(await store.read('device.agree.seed'), isNotNull);

    await store.deleteAll();
    final c = await DeviceKeys.ensure(store);
    expect(c.deviceId, isNot(a.deviceId));

    expect(await DeviceKeys.load(MemorySecureStore()), isNull);
  });
}
