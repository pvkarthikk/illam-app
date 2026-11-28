import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:nm_flat/core/domain/receipt/receipt_layout.dart';

/// Input source for scanning a paper or saved bill.
enum ReceiptImageSource { camera, gallery }

/// OCR text output from on-device Google ML Kit recognition.
class ReceiptOcrResult {
  const ReceiptOcrResult({
    required this.text,
    this.confidence = 0,
  });

  final String text;
  final int confidence;
}

/// Failure category surfaced by [ReceiptOcrBridge].
enum ReceiptOcrErrorKind { unsupported, permissionDenied, noCameraApp, failed }

/// Structured exception for camera/gallery/OCR bridge errors.
class ReceiptOcrException implements Exception {
  const ReceiptOcrException(this.kind, [this.message]);

  final ReceiptOcrErrorKind kind;
  final String? message;

  @override
  String toString() => 'ReceiptOcrException($kind, $message)';
}

/// Platform interface for capturing/picking receipt images and running OCR.
abstract class ReceiptOcrBridge {
  Future<bool> isSupported();
  Future<String?> pickOrCaptureImage(ReceiptImageSource source);
  Future<ReceiptOcrResult> recognizeImage(
    String path, {
    int rotationDegrees = 0,
  });
  Future<void> deleteTempImage(String path);
}

/// MethodChannel-backed Android ML Kit OCR bridge with safe fallback on
/// unsupported platforms (web/tests).
class MethodChannelReceiptOcrBridge implements ReceiptOcrBridge {
  const MethodChannelReceiptOcrBridge([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'io.github.pvkarthikk.illam/receipt_ocr';

  final MethodChannel _channel;

  @override
  Future<bool> isSupported() async {
    if (kIsWeb) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String?> pickOrCaptureImage(ReceiptImageSource source) async {
    if (kIsWeb) {
      throw const ReceiptOcrException(ReceiptOcrErrorKind.unsupported);
    }
    try {
      return await _channel.invokeMethod<String>('pickOrCaptureImage', {
        'source': source.name,
      });
    } on MissingPluginException {
      throw const ReceiptOcrException(ReceiptOcrErrorKind.unsupported);
    } on PlatformException catch (e) {
      throw ReceiptOcrException(_mapErrorCode(e.code), e.message);
    }
  }

  @override
  Future<ReceiptOcrResult> recognizeImage(
    String path, {
    int rotationDegrees = 0,
  }) async {
    if (kIsWeb) {
      throw const ReceiptOcrException(ReceiptOcrErrorKind.unsupported);
    }
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'recognizeImage',
        {'path': path, 'rotationDegrees': rotationDegrees},
      );
      if (map == null) return const ReceiptOcrResult(text: '');
      final rawText = (map['text'] as String?) ?? '';
      final conf = (map['confidence'] as num?)?.toInt() ?? 0;
      var text = rawText;
      final rawLines = map['lines'];
      if (rawLines is List && rawLines.isNotEmpty) {
        final boxes = <OcrTextBox>[];
        for (final entry in rawLines) {
          if (entry is! Map) continue;
          final lineText = entry['text'] as String?;
          if (lineText == null || lineText.trim().isEmpty) continue;
          boxes.add(
            OcrTextBox(
              text: lineText,
              left: (entry['left'] as num?)?.toDouble() ?? 0,
              top: (entry['top'] as num?)?.toDouble() ?? 0,
              right: (entry['right'] as num?)?.toDouble() ?? 0,
              bottom: (entry['bottom'] as num?)?.toDouble() ?? 0,
            ),
          );
        }
        final reconstructed = reconstructReceiptLines(boxes);
        if (reconstructed.isNotEmpty) {
          text = reconstructed;
        }
      }
      return ReceiptOcrResult(text: text, confidence: conf);
    } on MissingPluginException {
      throw const ReceiptOcrException(ReceiptOcrErrorKind.unsupported);
    } on PlatformException catch (e) {
      throw ReceiptOcrException(_mapErrorCode(e.code), e.message);
    }
  }

  @override
  Future<void> deleteTempImage(String path) async {
    if (kIsWeb || path.isEmpty) return;
    try {
      await _channel.invokeMethod<void>('deleteTempImage', {'path': path});
    } on MissingPluginException {
      // No-op on platforms without native bridge.
    } on PlatformException {
      // Best-effort cache cleanup.
    }
  }

  ReceiptOcrErrorKind _mapErrorCode(String code) => switch (code) {
    'permission_denied' => ReceiptOcrErrorKind.permissionDenied,
    'no_camera_app' => ReceiptOcrErrorKind.noCameraApp,
    'unsupported' => ReceiptOcrErrorKind.unsupported,
    _ => ReceiptOcrErrorKind.failed,
  };
}
