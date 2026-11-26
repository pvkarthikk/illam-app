import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';
import 'package:nm_flat/core/sms/sms_spend_scanner.dart';

class _FakeSmsBridge implements SmsPlatformBridge {
  List<RawSmsMessage> inboxMessages = const [];
  List<RawSmsMessage> queuedMessages = const [];

  @override
  Future<SmsPermissionStatus> checkPermissions() async =>
      const SmsPermissionStatus(
        supported: true,
        readGranted: true,
        receiveGranted: true,
        permanentlyDenied: false,
      );

  @override
  Future<SmsPermissionStatus> requestPermissions() => checkPermissions();

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> setBackgroundCaptureEnabled(bool enabled) async {}

  @override
  Future<List<RawSmsMessage>> readInbox({
    required int sinceMs,
    int limit = 400,
  }) async =>
      inboxMessages;

  @override
  Future<List<RawSmsMessage>> drainQueuedMessages() async {
    final copy = [...queuedMessages];
    queuedMessages = const [];
    return copy;
  }

  @override
  void setIncomingHandler(
    Future<void> Function(RawSmsMessage msg)? onIncoming,
  ) {}
}

void main() {
  test('SmsSpendScanner deduplicates background queue + inbox + processed', () async {
    final bridge = _FakeSmsBridge();
    final nowMs = DateTime(2026, 11, 26, 14, 0).millisecondsSinceEpoch;
    final sharedSms = RawSmsMessage(
      sender: 'VM-HDFCBK',
      body:
          'Sent Rs.320.00 From HDFC Bank A/C *1234 On 26/11/26 '
          'To ZEPTO On Ref 900112233445',
      receivedAtMs: nowMs - 1000,
    );
    final newSms = RawSmsMessage(
      sender: 'VK-AXISBK',
      body:
          'INR 180.00 debited from A/c XX4567 on 26-11-2026 '
          'at THIRD WAVE COFFEE. Ref 900998877665',
      receivedAtMs: nowMs - 500,
    );
    final promoSms = RawSmsMessage(
      sender: 'AD-HDFCBK',
      body: 'Get up to Rs.2,000 cashback on flights! Apply now.',
      receivedAtMs: nowMs - 200,
    );
    final discardedSms = RawSmsMessage(
      sender: 'VD-SBIUPI',
      body:
          'Dear UPI user A/C X1234 debited by 99.0 on date 26Nov26 '
          'trf to TEA SHOP Refno 777666555444.',
      receivedAtMs: nowMs - 100,
    );

    // Same SMS present in BOTH background queue AND inbox should yield only 1 draft.
    bridge.queuedMessages = [sharedSms];
    bridge.inboxMessages = [sharedSms, newSms, promoSms, discardedSms];

    final scanner = SmsSpendScanner(bridge: bridge, nowMs: () => nowMs);
    const config = SmsImportConfig(
      enabled: true,
      processedFingerprints: {'sms_ref_777666555444'},
    );

    final result = await scanner.scanInbox(
      config,
      merchantRules: const {'third wave coffee': 'Eating out'},
    );

    expect(result.messagesExamined, 5);
    expect(result.skippedCount, 1);
    expect(result.newDrafts.length, 2);
    expect(result.newDrafts.map((d) => d.merchant).toSet(), {
      'Third Wave Coffee',
      'Zepto',
    });
    expect(
      result.scannedFingerprints,
      {'sms_ref_900112233445', 'sms_ref_900998877665'},
    );
  });

  test('SmsImportStore round-trips config and drafts cleanly', () async {
    final secure = MemorySecureStore();
    final store = SmsImportStore(secure);
    addTearDown(store.dispose);

    const draft = SmsDraftSpend(
      id: 'sms_ref_123456789',
      amountPaise: 45000,
      merchant: 'Swiggy',
      category: 'Eating out',
      method: 'upi',
      date: '2026-11-26',
      bankName: 'HDFC Bank',
      accountLast4: '1234',
      refNumber: '123456789',
      rawSnippet: 'Sent Rs.450...',
      receivedAtMs: 1700000000000,
      importedAtMs: 1700000001000,
    );

    await store.save(
      'home-1',
      const SmsImportConfig(
        enabled: true,
        autoCapture: false,
        scanDays: 7,
        drafts: [draft],
        processedFingerprints: {'sms_ref_123456789'},
      ),
    );

    final loaded = await store.load('home-1');
    expect(loaded.enabled, isTrue);
    expect(loaded.autoCapture, isFalse);
    expect(loaded.scanDays, 7);
    expect(loaded.drafts.length, 1);
    expect(loaded.drafts.first.merchant, 'Swiggy');
    expect(loaded.drafts.first.amountPaise, 45000);
    expect(loaded.processedFingerprints, {'sms_ref_123456789'});
  });

  test(
    'SmsSpendScanner deduplicates duplicate ICICI UPI deliveries and ignores merchant receipts',
    () {
      final nowMs = DateTime(2026, 11, 23, 12, 15).millisecondsSinceEpoch;
      final messages = [
        RawSmsMessage(
          sender: 'AD-ICICIT-S',
          body:
              'ICICI Bank Acct XX123 debited for Rs 200.00 on 23-Nov-26; '
              'Test Vendor A credited. UPI:600099887766. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
          receivedAtMs: nowMs - 120000,
        ),
        RawSmsMessage(
          sender: 'AD-ICICIT-S',
          body:
              'ICICI Bank Acct XX123 debited for Rs 200.00 on 23-Nov-26; '
              'Test Vendor A credited. UPI:600099887766. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
          receivedAtMs: nowMs,
        ),
        RawSmsMessage(
          sender: 'AX-ICICIT-S',
          body:
              'ICICI Bank Acct XX123 debited for Rs 606.52 on 18-Nov-26; '
              'Hathway credited. UPI:600099887767. Call 18002662 for dispute.',
          receivedAtMs: nowMs - 400000,
        ),
        RawSmsMessage(
          sender: 'JD-HATHWY-S',
          body:
              'We have received payment of Rs606.52 for A/c no:1234567890 by receipt no: R-123456. '
              'Amt would be credited in next 2 hours.Team Hathway.',
          receivedAtMs: nowMs - 395000,
        ),
        RawSmsMessage(
          sender: 'AX-ICICIT-S',
          body:
              'ICICI Bank Acct XX123 debited for Rs 120.25 on 16-Nov-26; '
              'APOLLO PHARMACY credited. UPI:600099887768. Call 18002662 for dispute.',
          receivedAtMs: nowMs - 600000,
        ),
        RawSmsMessage(
          sender: 'CP-APLPHR-S',
          body:
              'Dear CUSTOMER NAME ,Thank you for your purchase @ Apollo Pharmacy. '
              'Click here http://example.com/bill to download your bill for Rs.120.25 APLPHR',
          receivedAtMs: nowMs - 595000,
        ),
      ];

      final scanner = SmsSpendScanner(
        bridge: _FakeSmsBridge(),
        nowMs: () => nowMs,
      );
      final result = scanner.ingestMessages(
        messages,
        const SmsImportConfig(enabled: true),
      );

      expect(result.messagesExamined, 6);
      expect(result.skippedCount, 2);
      expect(result.newDrafts.length, 3);
      expect(
        result.newDrafts.map((d) => (d.merchant, d.amountPaise)).toList(),
        [
          ('Test Vendor A', 20000),
          ('Hathway', 60652),
          ('Apollo Pharmacy', 12025),
        ],
      );
    },
  );
}
