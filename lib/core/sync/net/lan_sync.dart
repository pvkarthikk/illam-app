import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';

String _utcDay(DateTime utc) {
  final u = utc.toUtc();
  final y = u.year.toString().padLeft(4, '0');
  final m = u.month.toString().padLeft(2, '0');
  final d = u.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// First 8 lowercase hex chars of HMAC-SHA-256(`homeKey`, `'lan' + YYYY-MM-DD`).
Future<String> lanTag(List<int> homeKey, DateTime utc) async {
  final mac = await hmacSha256(
    homeKey,
    utf8.encode('lan${_utcDay(utc)}'),
  );
  return toHex(mac).substring(0, 8);
}

/// UTC today and yesterday LAN discovery tags so peers find each other across midnight.
Future<Set<String>> lanTagsFor(List<int> homeKey, DateTime nowUtc) async {
  final u = nowUtc.toUtc();
  return {
    await lanTag(homeKey, u),
    await lanTag(homeKey, u.subtract(const Duration(days: 1))),
  };
}

/// Advertises and discovers sync endpoints on the local Wi-Fi network via mDNS.
class LanSyncService {
  ServerSocket? _server;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;

  int? get port => _server?.port;

  Future<int> startServer(void Function(Socket) onClient) async {
    if (_server != null) return _server!.port;
    ServerSocket s;
    try {
      s = await ServerSocket.bind(InternetAddress.anyIPv4, 47811);
    } on SocketException {
      s = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    }
    _server = s;
    s.listen(onClient);
    return s.port;
  }

  Future<void> advertise(String tag, int port) async {
    try {
      await _broadcast?.stop();
    } on Object {
      // Ignore teardown errors when restarting advertisement.
    }
    final service = BonsoirService(
      name: 'nm-${toHex(randomBytes(3))}',
      type: '_illam._tcp',
      port: port,
      attributes: {'h': tag, 'v': '1'},
    );
    final b = BonsoirBroadcast(service: service);
    _broadcast = b;
    await b.initialize();
    await b.start();
  }

  Future<void> discover(
    Set<String> tags,
    void Function(String host, int port) onPeer,
  ) async {
    await _stopDiscovery();
    final d = BonsoirDiscovery(type: '_illam._tcp');
    _discovery = d;
    await d.initialize();
    _discoverySub = d.eventStream!.listen((event) {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        event.service.resolve(d.serviceResolver);
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        final svc = event.service;
        final tag = svc.attributes['h'];
        if (tag == null || !tags.contains(tag)) return;
        for (final host in svc.hostAddresses) {
          onPeer(host, svc.port);
        }
      }
    });
    await d.start();
  }

  Future<void> _stopDiscovery() async {
    await _discoverySub?.cancel();
    _discoverySub = null;
    try {
      await _discovery?.stop();
    } on Object {
      // Ignore discovery stop errors.
    }
    _discovery = null;
  }

  Future<void> stop() async {
    await _stopDiscovery();
    try {
      await _broadcast?.stop();
    } on Object {
      // Ignore broadcast stop errors.
    }
    _broadcast = null;
    try {
      await _server?.close();
    } on Object {
      // Ignore server close errors.
    }
    _server = null;
  }
}
