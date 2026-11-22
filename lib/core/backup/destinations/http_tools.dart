import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';

/// Base64 SHA-256 certificate/key fingerprint matching OpenSSH (`SHA256:...`).
String sha256Fingerprint(List<int> bytes) {
  final encoded = base64Encode(sha256.convert(bytes).bytes).replaceAll('=', '');
  return 'SHA256:$encoded';
}

/// Cryptographically random lowercase hex string with length `2 * bytes`.
String randomHex(int bytes) {
  final rng = Random.secure();
  final buf = StringBuffer();
  for (var i = 0; i < bytes; i++) {
    buf.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buf.toString();
}

/// Shared Dio instance for server backup destinations, optionally pinning a
/// self-signed certificate by its SHA-256 DER fingerprint.
Dio buildServerDio({String? tlsPin}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 2),
      validateStatus: (_) => true,
      headers: const {'User-Agent': 'Nest Mojo : Flat (Android)'},
    ),
  );
  if (tlsPin != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()
        ..badCertificateCallback =
            (cert, _, _) => sha256Fingerprint(cert.der) == tlsPin,
    );
  }
  return dio;
}

/// Connects to [host]:[port] over TLS and returns the leaf certificate's
/// `SHA256:...` fingerprint, even when the OS does not trust the certificate.
Future<String?> fetchTlsFingerprint(String host, int port) async {
  X509Certificate? seen;
  SecureSocket? socket;
  try {
    socket = await SecureSocket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
      onBadCertificate: (cert) {
        seen = cert;
        return false;
      },
    );
    seen ??= socket.peerCertificate;
  } on Object {
    // Connection fails cleanly when [onBadCertificate] rejects the cert.
  } finally {
    try {
      await socket?.close();
    } on Object {
      // Ignore socket close errors.
    }
  }
  final cert = seen;
  return cert == null ? null : sha256Fingerprint(cert.der);
}

/// Maps transport/TLS [DioException]s to [DestinationException].
DestinationException mapDioError(DioException e) {
  if (e.type == DioExceptionType.badCertificate ||
      e.error is HandshakeException) {
    return const DestinationException(DestError.untrustedCert);
  }
  return const DestinationException(DestError.unreachable);
}

/// Maps HTTP status codes to [DestinationException], returning `null` for 2xx.
DestinationException? statusError(int status) {
  if (status >= 200 && status <= 299) return null;
  if (status == 401) return const DestinationException(DestError.auth);
  if (status == 403) return const DestinationException(DestError.noPermission);
  if (status == 507 || status == 413) {
    return const DestinationException(DestError.full);
  }
  if (status >= 500) return const DestinationException(DestError.unreachable);
  return const DestinationException(DestError.other);
}

/// Ensures [url] uses HTTPS unless [allowHttp] permits plain HTTP (debug only).
void requireHttps(Uri url, {required bool allowHttp}) {
  final scheme = url.scheme.toLowerCase();
  if (scheme == 'https') return;
  if (allowHttp && scheme == 'http') return;
  throw const DestinationException(DestError.httpsRequired);
}
