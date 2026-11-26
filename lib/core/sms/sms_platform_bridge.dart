import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';

/// Current SMS permission & platform capability state.
class SmsPermissionStatus {
  const SmsPermissionStatus({
    required this.supported,
    required this.readGranted,
    required this.receiveGranted,
    required this.permanentlyDenied,
  });

  const SmsPermissionStatus.unsupported()
      : supported = false,
        readGranted = false,
        receiveGranted = false,
        permanentlyDenied = false;

  factory SmsPermissionStatus.fromMap(Map<Object?, Object?>? map) {
    if (map == null) return const SmsPermissionStatus.unsupported();
    return SmsPermissionStatus(
      supported: (map['supported'] as bool?) ?? false,
      readGranted: (map['readGranted'] as bool?) ?? false,
      receiveGranted: (map['receiveGranted'] as bool?) ?? false,
      permanentlyDenied: (map['permanentlyDenied'] as bool?) ?? false,
    );
  }

  final bool supported;
  final bool readGranted;
  final bool receiveGranted;
  final bool permanentlyDenied;

  bool get canScanInbox => supported && readGranted;
  bool get allGranted => supported && readGranted && receiveGranted;
}

/// Platform interface for reading Android SMS inbox & background capture queue.
abstract class SmsPlatformBridge {
  Future<SmsPermissionStatus> checkPermissions();
  Future<SmsPermissionStatus> requestPermissions();
  Future<void> openAppSettings();
  Future<void> setBackgroundCaptureEnabled(bool enabled);
  Future<List<RawSmsMessage>> readInbox({required int sinceMs, int limit = 400});
  Future<List<RawSmsMessage>> drainQueuedMessages();
  void setIncomingHandler(Future<void> Function(RawSmsMessage msg)? onIncoming);
}

/// MethodChannel-backed Android SMS bridge with safe fallback on web/tests.
class MethodChannelSmsPlatformBridge implements SmsPlatformBridge {
  MethodChannelSmsPlatformBridge([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'io.github.pvkarthikk.illam/sms';
  static final MethodChannelSmsPlatformBridge instance =
      MethodChannelSmsPlatformBridge();

  final MethodChannel _channel;

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    if (kIsWeb) return null;
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<SmsPermissionStatus> checkPermissions() async {
    final map = await _invoke<Map<Object?, Object?>>('checkPermissions');
    return SmsPermissionStatus.fromMap(map);
  }

  @override
  Future<SmsPermissionStatus> requestPermissions() async {
    final map = await _invoke<Map<Object?, Object?>>('requestPermissions');
    return SmsPermissionStatus.fromMap(map);
  }

  @override
  Future<void> openAppSettings() async {
    await _invoke<void>('openAppSettings');
  }

  @override
  Future<void> setBackgroundCaptureEnabled(bool enabled) async {
    await _invoke<void>('setBackgroundCaptureEnabled', {'enabled': enabled});
  }

  @override
  Future<List<RawSmsMessage>> readInbox({
    required int sinceMs,
    int limit = 400,
  }) async {
    final raw = await _invoke<List<Object?>>('readInbox', {
      'sinceMs': sinceMs,
      'limit': limit,
    });
    return _decodeMessages(raw);
  }

  @override
  Future<List<RawSmsMessage>> drainQueuedMessages() async {
    final raw = await _invoke<List<Object?>>('drainQueuedMessages');
    return _decodeMessages(raw);
  }

  @override
  void setIncomingHandler(
    Future<void> Function(RawSmsMessage msg)? onIncoming,
  ) {
    if (kIsWeb) return;
    if (onIncoming == null) {
      _channel.setMethodCallHandler(null);
      return;
    }
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIncomingSms' && call.arguments is Map) {
        final msg = RawSmsMessage.fromMap(call.arguments as Map);
        await onIncoming(msg);
      }
      return null;
    });
  }

  List<RawSmsMessage> _decodeMessages(List<Object?>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final out = <RawSmsMessage>[];
    for (final entry in raw) {
      if (entry is Map) {
        out.add(RawSmsMessage.fromMap(entry));
      }
    }
    return out;
  }
}

/// No-op SMS bridge useful for isolated widget tests.
class UnsupportedSmsPlatformBridge implements SmsPlatformBridge {
  const UnsupportedSmsPlatformBridge();

  @override
  Future<SmsPermissionStatus> checkPermissions() async =>
      const SmsPermissionStatus.unsupported();

  @override
  Future<SmsPermissionStatus> requestPermissions() async =>
      const SmsPermissionStatus.unsupported();

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> setBackgroundCaptureEnabled(bool enabled) async {}

  @override
  Future<List<RawSmsMessage>> readInbox({
    required int sinceMs,
    int limit = 400,
  }) async =>
      const [];

  @override
  Future<List<RawSmsMessage>> drainQueuedMessages() async => const [];

  @override
  void setIncomingHandler(
    Future<void> Function(RawSmsMessage msg)? onIncoming,
  ) {}
}
