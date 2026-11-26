import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/domain/sms/sms_spend_parser.dart';

void main() {
  final defaultTs = DateTime(2026, 11, 26, 10, 30).millisecondsSinceEpoch;

  RawSmsMessage sms(String sender, String body) => RawSmsMessage(
    sender: sender,
    body: body,
    receivedAtMs: defaultTs,
  );

  group('parseSmsSpend — Indian banks, UPI & cards', () {
    test('parses HDFC Bank UPI debit and ignores Avl Bal trap', () {
      final parsed = parseSmsSpend(
        sms(
          'VM-HDFCBK-S',
          'Sent Rs.249.00 From HDFC Bank A/C *1234 On 26/11/26 To ZEPTO '
          'On Ref 633012345678. Avl Bal Rs.45,120.00. Not You? Call 18002586161',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 24900);
      expect(parsed.merchant, 'Zepto');
      expect(parsed.category, 'Groceries');
      expect(parsed.method, 'upi');
      expect(parsed.bankName, 'HDFC Bank');
      expect(parsed.accountLast4, '1234');
      expect(parsed.refNumber, '633012345678');
      expect(parsed.date, '2026-11-26');
      expect(parsed.matchedOrderChannel, 'zepto');
      expect(parsed.fingerprint, 'sms_ref_633012345678');
    });

    test('parses HDFC Credit Card spend ignoring Avl Lmt', () {
      final parsed = parseSmsSpend(
        sms(
          'AD-HDFCBK',
          'Spent Rs.1,450.50 On HDFC Bank Card 4321 At SWIGGY BANGALORE '
          'On 2026-11-26:12:15:00. Avl Lmt Rs.85,000.00. Not You?',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 145050);
      expect(parsed.merchant, 'Swiggy');
      expect(parsed.category, 'Eating out');
      expect(parsed.method, 'card');
      expect(parsed.accountLast4, '4321');
    });

    test('parses ICICI UPI with recipient credited clause', () {
      final parsed = parseSmsSpend(
        sms(
          'VM-ICICIB',
          'ICICI Bank Acct XX123 debited for Rs 520.00 on 26-Nov-26; '
          'BLINKIT credited. UPI:633099887766. Call 18002662 for dispute.',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 52000);
      expect(parsed.merchant, 'Blinkit');
      expect(parsed.category, 'Groceries');
      expect(parsed.method, 'upi');
      expect(parsed.bankName, 'ICICI Bank');
      expect(parsed.accountLast4, '123');
      expect(parsed.refNumber, '633099887766');
      expect(parsed.matchedOrderChannel, 'blinkit');
    });

    test('parses ICICI Credit Card double-on merchant format', () {
      final parsed = parseSmsSpend(
        sms(
          'AX-ICICIB',
          'INR 1,299.00 spent using ICICI Bank Card XX9876 on 25-Nov-26 '
          'on AMAZON PAY INDIA. Avl Limit: INR 1,45,000.00',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 129900);
      expect(parsed.merchant, 'Amazon');
      expect(parsed.category, 'Shopping');
      expect(parsed.method, 'card');
      expect(parsed.matchedOrderChannel, 'amazon');
    });

    test('parses SBI UPI bare amount without currency symbol and compact date', () {
      final parsed = parseSmsSpend(
        sms(
          'VD-SBIUPI',
          'Dear UPI user A/C X1234 debited by 350.0 on date 25Nov26 '
          'trf to ZOMATO Refno 633055443322. If not u? call 1800111109. -SBI',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 35000);
      expect(parsed.merchant, 'Zomato');
      expect(parsed.category, 'Eating out');
      expect(parsed.method, 'upi');
      expect(parsed.bankName, 'SBI');
      expect(parsed.date, '2026-11-25');
      expect(parsed.refNumber, '633055443322');
    });

    test('parses Axis Bank UPI/P2M Info slash format', () {
      final parsed = parseSmsSpend(
        sms(
          'VK-AXISBK',
          'INR 899.00 debited from A/c no. XX4567 on 26-11-2026 '
          'Info: UPI/P2M/633011223344/BIGBASKET. Avl Bal: INR 12,340.50',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 89900);
      expect(parsed.merchant, 'BigBasket');
      expect(parsed.category, 'Groceries');
      expect(parsed.method, 'upi');
      expect(parsed.bankName, 'Axis Bank');
      expect(parsed.accountLast4, '4567');
    });

    test('parses Kotak VPA, OneCard, AutoPay, and ATM withdrawal', () {
      final kotak = parseSmsSpend(
        sms(
          'JD-KOTAKB',
          'Sent Rs.199 from Kotak Bank AC X8899 to dmart@okaxis on 26-11-26. '
          'UPI Ref 633077889900.',
        ),
      );
      expect(kotak?.merchant, 'DMart');
      expect(kotak?.category, 'Groceries');
      expect(kotak?.method, 'upi');

      final oneCard = parseSmsSpend(
        sms(
          'VM-ONECAR',
          'You have spent Rs.650.00 at UBER INDIA on your OneCard ending 7788. '
          'Available limit Rs.49,350.00.',
        ),
      );
      expect(oneCard?.merchant, 'Uber');
      expect(oneCard?.method, 'card');
      expect(oneCard?.accountLast4, '7788');

      final autopay = parseSmsSpend(
        sms(
          'TM-IDFCFB',
          'Rs.799.00 debited from A/c XX3344 towards AIRTEL POSTPAID AutoPay. '
          'Ref 998877665544.',
        ),
      );
      expect(autopay?.merchant, 'Airtel');
      expect(autopay?.category, 'Utilities');
      expect(autopay?.method, 'bank');

      final atm = parseSmsSpend(
        sms(
          'VM-HDFCBK',
          'Rs.5,000.00 withdrawn from HDFC Bank A/C *1234 at ATM INDRANAGAR '
          'on 26-11-26. Avl Bal Rs.20,000.',
        ),
      );
      expect(atm?.amountPaise, 500000);
      expect(atm?.method, 'cash');
      expect(atm?.merchant, 'ATM Withdrawal');
    });

    test('respects learned household merchantRules override', () {
      final parsed = parseSmsSpend(
        sms(
          'VM-HDFCBK',
          'Sent Rs.1,200.00 From HDFC Bank A/C *1234 On 26/11/26 '
          'To RAMESH MILK Ref 123456789012',
        ),
        merchantRules: const {'ramesh milk': 'Groceries'},
      );
      expect(parsed, isNotNull);
      expect(parsed!.category, 'Groceries');
    });
  });

  group('parseSmsSpend — non-spend filtering', () {
    test('rejects OTPs, credits, refunds, failures, CC bill payments & promos', () {
      final ignored = <RawSmsMessage>[
        sms(
          'VM-HDFCBK',
          '123456 is your OTP for txn of Rs.2,500.00 at Amazon. Do not share OTP.',
        ),
        sms(
          'VM-ICICIB',
          'Your A/c XX1234 is credited with Rs.85,000.00 on 26-11-26 towards SALARY.',
        ),
        sms(
          'AD-SBIINB',
          'Refund of Rs.420.00 has been credited to your A/c XX9911.',
        ),
        sms(
          'VM-KOTAKB',
          'Transaction of Rs.499.00 on Kotak Card *8899 at Swiggy failed due to wrong PIN.',
        ),
        sms(
          'AX-HDFCBK',
          'Payment of Rs.15,400.00 received towards your HDFC Bank Credit Card ending 4321.',
        ),
        sms(
          'AX-HDFCBK',
          'HDFC Bank Card 4321 Statement generated. Total Amount Due Rs.15,400. Min Due Rs.770.',
        ),
        sms(
          'TM-AIRTEL',
          'Google Pay has requested Rs.500.00 from you. Approve in app.',
        ),
        sms(
          'TM-SBIUPI',
          'Pre-debit notification: Rs.1,500.00 will be debited from A/c XX1234 on 28-Nov-26.',
        ),
        sms(
          'AD-AXISBK',
          'Pre-approved personal loan up to Rs.5,00,000! Apply now.',
        ),
        sms(
          '+919876543210',
          'Sent Rs.500.00 to Ramesh via UPI Ref 123456789012.',
        ),
      ];

      for (final msg in ignored) {
        expect(parseSmsSpend(msg), isNull, reason: 'Should ignore: ${msg.body}');
      }
    });
  });
}
