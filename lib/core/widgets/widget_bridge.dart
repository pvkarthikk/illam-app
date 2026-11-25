import 'dart:convert';

import 'package:flutter/services.dart';

/// Platform channel bridge to native Android AppWidgets.
class WidgetBridge {
  WidgetBridge([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'io.github.pvkarthikk.illam/widgets';
  static final WidgetBridge instance = WidgetBridge();

  final MethodChannel _channel;

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Sends updated JSON snapshots for both Android home-screen widgets.
  Future<void> updateSnapshots({
    required Map<String, Object?> staff,
    required Map<String, Object?> todos,
  }) async {
    await _invoke<void>('updateSnapshots', {
      'staffJson': jsonEncode(staff),
      'todosJson': jsonEncode(todos),
    });
  }

  /// Returns queued offline widget actions waiting to be applied to Drift.
  Future<List<Map<String, Object?>>> takePendingActions() async {
    final raw = await _invoke<List<Object?>>('takePendingActions');
    if (raw == null || raw.isEmpty) return const [];
    final out = <Map<String, Object?>>[];
    for (final item in raw) {
      if (item is Map) {
        out.add({
          for (final entry in item.entries) '${entry.key}': entry.value,
        });
      }
    }
    return out;
  }

  /// Removes processed widget action IDs from the native pending queue.
  Future<void> ackPendingActions(List<String> ids) async {
    if (ids.isEmpty) return;
    await _invoke<void>('ackPendingActions', {'ids': ids});
  }

  /// Consumes a launch route supplied when the user tapped a widget.
  Future<String?> consumeInitialRoute() =>
      _invoke<String>('consumeInitialRoute');

  /// Signals to the native background runner that work and snapshot push finished.
  Future<void> notifyBackgroundDone() => _invoke<void>('backgroundDone');

  /// Registers foreground handlers invoked when a widget action or route arrives.
  void setForegroundHandler({
    required Future<void> Function(Map<String, Object?> action) onAction,
    required void Function(String route) onOpenRoute,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'performAction':
          final args = call.arguments;
          if (args is Map) {
            await onAction({
              for (final entry in args.entries) '${entry.key}': entry.value,
            });
          }
          return null;
        case 'openRoute':
          final route = call.arguments;
          if (route is String && route.isNotEmpty) {
            onOpenRoute(route);
          }
          return null;
        default:
          return null;
      }
    });
  }

  /// Clears foreground widget callbacks during teardown.
  void clearForegroundHandler() {
    _channel.setMethodCallHandler(null);
  }
}
