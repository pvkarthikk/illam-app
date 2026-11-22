import 'package:nm_flat/core/data/secure/secure_store.dart';

/// Stores per-destination secrets separately from [DestinationConfig.settings].
class DestinationSecrets {
  const DestinationSecrets(this.store);

  final SecureStore store;

  static String keyFor(String destId) => 'backup.secret.$destId';

  Future<String?> read(String destId) => store.read(keyFor(destId));

  Future<void> write(String destId, String v) =>
      store.write(keyFor(destId), v);

  Future<void> delete(String destId) => store.delete(keyFor(destId));
}
