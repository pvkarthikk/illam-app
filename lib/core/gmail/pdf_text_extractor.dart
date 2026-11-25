import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Extracts plain text from an invoice PDF attachment byte buffer.
abstract class PdfTextExtractor {
  Future<String> extractText(Uint8List bytes);
}

/// Default implementation backed by Android's `PdfTextChannel` (PDFBox).
///
/// Safely returns `''` on platforms without native PDF extraction (web/tests).
class MethodChannelPdfTextExtractor implements PdfTextExtractor {
  const MethodChannelPdfTextExtractor();

  static const _channel = MethodChannel('io.github.pvkarthikk.illam/pdf_text');

  @override
  Future<String> extractText(Uint8List bytes) async {
    if (kIsWeb || bytes.isEmpty) return '';
    try {
      final result = await _channel.invokeMethod<String>(
        'extractText',
        {'bytes': bytes},
      );
      return result ?? '';
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    }
  }
}

/// No-op extractor useful for unit tests or plain-text-only contexts.
class EmptyPdfTextExtractor implements PdfTextExtractor {
  const EmptyPdfTextExtractor();

  @override
  Future<String> extractText(Uint8List bytes) async => '';
}
