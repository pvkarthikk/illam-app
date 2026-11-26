import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/domain/sms/sms_spend_parser.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart' show ClockMs;
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';

/// Result of parsing SMS inbox / background queue messages into draft spends.
class SmsScanResult {
  const SmsScanResult({
    required this.newDrafts,
    required this.scannedFingerprints,
    required this.messagesExamined,
    required this.skippedCount,
  });

  final List<SmsDraftSpend> newDrafts;
  final Set<String> scannedFingerprints;
  final int messagesExamined;
  final int skippedCount;
}

/// Reads SMS messages from Android inbox & background receiver queue, parses
/// outgoing payments, and deduplicates against previously staged/processed SMS.
class SmsSpendScanner {
  SmsSpendScanner({required this.bridge, ClockMs? nowMs})
      : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  static const _dayMs = 86400000;

  final SmsPlatformBridge bridge;
  final ClockMs _nowMs;

  /// Drains any background-captured SMS and scans the inbox window.
  Future<SmsScanResult> scanInbox(
    SmsImportConfig config, {
    Map<String, String> merchantRules = const {},
    int limit = 400,
  }) async {
    final queued = await bridge.drainQueuedMessages();
    final sinceMs = _nowMs() - config.scanDays * _dayMs;
    final inbox = await bridge.readInbox(sinceMs: sinceMs, limit: limit);
    final combined = <RawSmsMessage>[...queued, ...inbox];
    return ingestMessages(
      combined,
      config,
      merchantRules: merchantRules,
    );
  }

  /// Parses [messages] into deduplicated [SmsDraftSpend]s against [config].
  SmsScanResult ingestMessages(
    List<RawSmsMessage> messages,
    SmsImportConfig config, {
    Map<String, String> merchantRules = const {},
  }) {
    final knownIds = <String>{
      ...config.processedFingerprints,
      for (final d in config.drafts) d.id,
    };

    final now = _nowMs();
    final newDrafts = <SmsDraftSpend>[];
    final newFingerprints = <String>{};
    var skipped = 0;

    for (final msg in messages) {
      final parsed = parseSmsSpend(msg, merchantRules: merchantRules);
      if (parsed == null) {
        skipped++;
        continue;
      }
      if (knownIds.contains(parsed.fingerprint) ||
          newFingerprints.contains(parsed.fingerprint)) {
        continue;
      }
      newFingerprints.add(parsed.fingerprint);
      newDrafts.add(
        SmsDraftSpend.fromParsed(parsed, importedAtMs: now),
      );
    }

    newDrafts.sort((a, b) => b.receivedAtMs.compareTo(a.receivedAtMs));
    return SmsScanResult(
      newDrafts: newDrafts,
      scannedFingerprints: newFingerprints,
      messagesExamined: messages.length,
      skippedCount: skipped,
    );
  }
}
