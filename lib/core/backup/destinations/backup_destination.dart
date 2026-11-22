import 'dart:typed_data';

/// Metadata for one backup or stale `.part` file stored at a destination.
class RemoteBackupFile {
  const RemoteBackupFile(this.name, this.size, this.modifiedMs);

  final String name;
  final int size;
  final int modifiedMs;
}

enum DestError {
  auth,
  full,
  unreachable,
  noPermission,
  notFound,
  error,
  bucketNotFound,
  untrustedCert,
  untrustedHostKey,
  hostKeyChanged,
  httpsRequired,
  other,
}

class DestinationException implements Exception {
  const DestinationException(this.error, [this.detail]);

  final DestError error;
  final String? detail;

  @override
  String toString() => detail == null
      ? 'DestinationException($error)'
      : 'DestinationException($error, $detail)';
}

extension DestErrorResult on DestError {
  String get lastResult => switch (this) {
    DestError.auth || DestError.noPermission => 'auth',
    DestError.full => 'full',
    DestError.unreachable || DestError.untrustedCert => 'unreachable',
    _ => 'error',
  };
}

String destErrorToResult(DestError e) => e.lastResult;

/// Abstract storage backend for encrypted `.nmbak` archives.
abstract class BackupDestination {
  String get kind;

  Future<void> testWrite();
  Future<void> upload(String name, Uint8List bytes);
  Future<List<RemoteBackupFile>> list();
  Future<Uint8List> download(String name);
  Future<void> delete(String name);

  /// Called once when the user taps Disconnect, before the config is deleted;
  /// default: nothing to revoke.
  Future<void> revokeAccess() async {}

  Future<Uint8List> readHead(String name, int count) async {
    final all = await download(name);
    if (all.length <= count) return all;
    return Uint8List.sublistView(all, 0, count);
  }

  Future<List<RemoteBackupFile>> staleParts(Duration olderThan) async =>
      const [];
}
