import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

import 'package:nm_flat/core/crypto/bytes.dart';

/// Advertises a temporary mDNS join endpoint (`_nmjoin._tcp`) over local Wi-Fi.
class LanJoinServer {
  LanJoinServer._(this._server, this._broadcast);

  final ServerSocket _server;
  final BonsoirBroadcast _broadcast;

  int get port => _server.port;

  static Future<LanJoinServer> start({
    required String nameplate,
    required void Function(Socket) onClient,
  }) async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    server.listen(onClient);
    final service = BonsoirService(
      name: 'nmjoin-${toHex(randomBytes(3))}',
      type: '_nmjoin._tcp',
      port: server.port,
      attributes: {'n': nameplate, 'v': '1'},
    );
    final broadcast = BonsoirBroadcast(service: service);
    try {
      await broadcast.initialize();
      await broadcast.start();
    } on Object {
      // Ignore mDNS advertising failures; direct QR/IP join still works.
    }
    return LanJoinServer._(server, broadcast);
  }

  Future<void> stop() async {
    try {
      await _broadcast.stop();
    } on Object {
      // Ignore stop errors during teardown.
    }
    try {
      await _server.close();
    } on Object {
      // Ignore socket close errors.
    }
  }
}

/// Discovers and connects to a peer's LAN join server via mDNS or direct host:port.
abstract final class LanJoinFinder {
  static Future<Socket?> find(
    String nameplate, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final discovery = BonsoirDiscovery(type: '_nmjoin._tcp');
    await discovery.initialize();
    final found = Completer<Socket?>();
    late final StreamSubscription<BonsoirDiscoveryEvent> sub;

    sub = discovery.eventStream!.listen((event) async {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        await event.service.resolve(discovery.serviceResolver);
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        final svc = event.service;
        if (svc.attributes['n'] != nameplate || found.isCompleted) return;
        for (final host in svc.hostAddresses) {
          try {
            final sock = await Socket.connect(
              host,
              svc.port,
              timeout: const Duration(seconds: 5),
            );
            if (found.isCompleted) {
              sock.destroy();
            } else {
              found.complete(sock);
            }
            return;
          } on Object {
            continue;
          }
        }
      }
    });

    await discovery.start();
    try {
      return await found.future.timeout(timeout);
    } on TimeoutException {
      return null;
    } finally {
      if (!found.isCompleted) found.complete(null);
      await sub.cancel();
      await discovery.stop();
    }
  }

  static Future<Socket?> dial(String host, int port) async {
    try {
      return await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
    } on Object {
      return null;
    }
  }
}
