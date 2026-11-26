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

    test('parses real ICICI Credit Card formats ignoring Avl Limit and BLOCK tail', () {
      final cases =
          <(String body, int paise, String merchant, String cat, String date, String? channel)>[
            (
              'INR 387.22 spent using ICICI Bank Card XX1234 on 18-Nov-26 on ZOMATO. '
                  'Avl Limit: INR 1,51,107.58. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              38722,
              'Zomato',
              'Eating out',
              '2026-11-18',
              null,
            ),
            (
              'INR 489.00 spent using ICICI Bank Card XX1234 on 21-Nov-26 on GOOGLE PLAY. '
                  'Avl Limit: INR 1,50,618.58. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              48900,
              'Google Play',
              'Other',
              '2026-11-21',
              null,
            ),
            (
              'INR 547.00 spent using ICICI Bank Card XX1234 on 22-Nov-26 on AMAZON PAY IN E. '
                  'Avl Limit: INR 1,50,071.58. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              54700,
              'Amazon',
              'Shopping',
              '2026-11-22',
              'amazon',
            ),
            (
              'INR 339.00 spent using ICICI Bank Card XX1234 on 25-Nov-26 on ZEPTO MARKETPLA. '
                  'Avl Limit: INR 1,49,350.04. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              33900,
              'Zepto',
              'Groceries',
              '2026-11-25',
              'zepto',
            ),
            (
              'INR 436.00 spent using ICICI Bank Card XX1234 on 25-Nov-26 on FLIPKART INTERN. '
                  'Avl Limit: INR 1,48,914.04. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              43600,
              'Flipkart',
              'Shopping',
              '2026-11-25',
              'flipkart',
            ),
            (
              'INR 791.76 spent using ICICI Bank Card XX1234 on 25-Nov-26 on ORBGEN TECHNOLO. '
                  'Avl Limit: INR 1,48,122.28. If not you, call 1800 2662/SMS BLOCK 1234 to 9215676766.',
              79176,
              'Orbgen Technolo',
              'Other',
              '2026-11-25',
              null,
            ),
          ];

      for (final (body, paise, merchant, cat, date, channel) in cases) {
        final parsed = parseSmsSpend(sms('BP-ICICIT-S', body));
        expect(parsed, isNotNull, reason: body);
        expect(parsed!.amountPaise, paise, reason: body);
        expect(parsed.merchant, merchant, reason: body);
        expect(parsed.category, cat, reason: body);
        expect(parsed.method, 'card', reason: body);
        expect(parsed.bankName, 'ICICI Bank', reason: body);
        expect(parsed.accountLast4, '1234', reason: body);
        expect(parsed.date, date, reason: body);
        expect(parsed.matchedOrderChannel, channel, reason: body);
      }
    });

    test('parses ICICI Prepaid Card debit cleanly', () {
      final parsed = parseSmsSpend(
        sms(
          'BP-ICICIT-S',
          'Your ICICI Bank Prepaid Card XX7788 has been debited with Rs 29.50 '
          'on 19-Nov-2026 towards Card Debit. The Available Balance is Rs 46.50 .',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 2950);
      expect(parsed.merchant, 'ICICI Bank Prepaid Card');
      expect(parsed.method, 'card');
      expect(parsed.bankName, 'ICICI Bank');
      expect(parsed.accountLast4, '7788');
      expect(parsed.date, '2026-11-19');
    });

    test('parses ICICI Account InfoBIL*BPAY*0000 debit without dispute noise', () {
      final parsed = parseSmsSpend(
        sms(
          'BP-ICICIT-S',
          'ICICI Bank Acc XX123 debited Rs. 1,240.18 on 25-Nov-26 '
          'InfoBIL*BPAY*0000.Avl Bal Rs. 161.43.To dispute call 18002662 or SMS BLOCK 123 to 9215676766',
        ),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 124018);
      expect(parsed.merchant, 'Bill Pay');
      expect(parsed.category, 'Utilities');
      expect(parsed.method, 'bank');
      expect(parsed.bankName, 'ICICI Bank');
      expect(parsed.accountLast4, '123');
      expect(parsed.date, '2026-11-25');
    });

    test('parses ICICI UPI formats with 15-char truncated, lowercase & leading-zero refs', () {
      final mishkat = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 452.00 on 16-Nov-26; '
          'MISHKAT RESTAUR credited. UPI:600011112222. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(mishkat?.merchant, 'Mishkat Restaur');
      expect(mishkat?.category, 'Eating out');
      expect(mishkat?.method, 'upi');
      expect(mishkat?.bankName, 'ICICI Bank');
      expect(mishkat?.accountLast4, '123');

      final apollo = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 120.25 on 16-Nov-26; '
          'APOLLO PHARMACY credited. UPI:600011112223. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(apollo?.merchant, 'Apollo Pharmacy');
      expect(apollo?.category, 'Home care');

      final hathway = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 606.52 on 18-Nov-26; '
          'Hathway credited. UPI:600011112224. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(hathway?.merchant, 'Hathway');
      expect(hathway?.category, 'Utilities');

      final rice = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 1595.00 on 22-Nov-26; '
          'MALRAJA RICE MA credited. UPI:600011112225. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(rice?.merchant, 'Malraja Rice Ma');
      expect(rice?.category, 'Groceries');

      final zepto = parseSmsSpend(
        sms(
          'AD-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 246.00 on 16-Nov-26; '
          'ZEPTO MARKETPLA credited. UPI:075300112233. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(zepto?.merchant, 'Zepto');
      expect(zepto?.category, 'Groceries');
      expect(zepto?.refNumber, '075300112233');
      expect(zepto?.fingerprint, 'sms_ref_075300112233');

      final lowerShop = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 1000.00 on 22-Nov-26; '
          'fush shop credited. UPI:600011112226. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(lowerShop?.merchant, 'Fush Shop');
      expect(lowerShop?.category, 'Other');

      final googleAsia = parseSmsSpend(
        sms(
          'AX-ICICIT-S',
          'ICICI Bank Acct XX123 debited for Rs 40.90 on 18-Nov-26; '
          'Google Asia Pac credited. UPI:600011112227. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        ),
      );
      expect(googleAsia?.merchant, 'Google Asia Pac');
      expect(googleAsia?.category, 'Other');
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

    test('rejects real-world ICICI upcoming mandates, Airtel/Hathway reminders, receipts & promos', () {
      final ignored = <RawSmsMessage>[
        sms(
          'BP-ICICIT-S',
          'AIRTEL POSTPAID bill of Rs 1240.18 for 9876543210 due on 2026-11-28, '
          'will be auto-debited on 2026-11-25-ICICI Bank.',
        ),
        sms(
          'BP-ICICIT-S',
          'AIRTEL POSTPAID bill of Rs 1240.18 for 9876543210 will auto-deduct on 25-11-2026. '
          'Ensure funds in Acc. Visit icici.co/ICICIT/k/sample to modify-ICICI Bank.',
        ),
        sms(
          'BP-ICICIT-S',
          'We have activated Standing Instruction on ICICI Bank Credit Card 1234. '
          'Merchant: Google Play, Maximum Amount: INR 1950.00, Frequency: monthly, '
          'Start Date: 21/11/2026, End Date: 31/12/2036, Mandate ID: MND12345.',
        ),
        sms(
          'BP-ICICIT-S',
          'Payment of Airtel Postpaid (Fetch and Pay) bill of Rs 1240.18 was unsuccessful. '
          'Amount debited will be refunded within 7 working days. To pay, visit icici.co/sample -ICICI Bank.',
        ),
        sms(
          'BP-ICICIT-S',
          'ICICI Bank Credit Card XX1234 Statement is sent to ab********12@example.com. '
          'Total of Rs 959.94 or minimum of Rs 100.00 is due by 06-DEC-26.',
        ),
        sms(
          'BP-ICICIT-S',
          'ICICI Bank Account XX123 credited:Rs. 164.00 on 19-Nov-26. '
          'Info ACH*SAMPLE CORP*1234. Available Balance is Rs. 6,033.17.',
        ),
        sms(
          'AD-ICICIO-T',
          '727304 is One-Time Password for INR 436.00 transaction towards FLIPKART IN '
          'using ICICI Bank Credit Card XX1234. OTPs are SECRET. DO NOT disclose',
        ),
        sms(
          'AD-AIRBIL-S',
          'Airtel Mobile bill reminder: Bill of Rs. 1240 for your Airtel Mobile 9876543210 '
          'is due on 28-NOV-26. Pay on Airtel app now: i.airtel.in/PPpayBills . '
          'Never miss a bill - set up AutoPay and pay on time, every time https://i.airtel.in/Auto-Pay . '
          'Please ignore if already paid.',
        ),
        sms(
          'JD-HATHWY-S',
          'Your Hathway Ac 1234567890 is due for renewal on 17thNov.Pls pay Rs.607to enjoy uninterrupted services.',
        ),
        sms(
          'JD-HATHWY-S',
          'Your Hathway A/c-1234567890 is due for deactivation tonight pay Rs-607/-*For queries pls call 9000000000',
        ),
        sms(
          'JD-HATHWY-S',
          'Hi! Set up UPI AutoPay in 1 click & enjoy uninterrupted internet. AC No 1234567890.',
        ),
        sms(
          'JD-HATHWY-S',
          'We have received payment of Rs606.52 for A/c no:1234567890 by receipt no: R-123456. '
          'Amt would be credited in next 2 hours.Team Hathway.',
        ),
        sms(
          'CP-APLPHR-S',
          'Dear CUSTOMER NAME ,Thank you for your purchase @ Apollo Pharmacy. '
          'Click here http://example.com/bill to download your bill for Rs.120.25 APLPHR',
        ),
        sms(
          'VA-BATAIn-S',
          'Hi Member, Thank you for being a Bata\'s valuable customer. '
          'Use 300 bonus points on Rs. 1500 bill till 24 Nov. at store. T&C',
        ),
        sms(
          'JX-DTTHPL-S',
          'Dear Customer, You\'ve earned 39.87 rewards points on your recent order. '
          'Your current balance is 97.92 coins.',
        ),
        sms(
          'JX-620020-P',
          'JioHome Special Offer! Pay bill now and get 1 month extra Free on your JioHome number 4000012345.',
        ),
        sms(
          'AT-AIRMCA-S',
          'The person you were calling at 20:09 is now available for calls. You can call again now.',
        ),
        sms(
          'BP-LPUREC-S',
          'Dear Customer Our service engineer (Tech A) is at your door step for call ID JS-1234 '
          'and call closure code is 2253.',
        ),
        sms(
          'AD-UNITAS-S',
          'Mr/Ms CUSTOMER A, Please Do Not miss your Follow-up at Hospital on 20/11/2026.',
        ),
        sms(
          'VA-CDSLEV-S',
          'Dear Investor, e-Voting for SAMPLE CO begins from 18-11-2026 09:00 and ends at 17-12-2026 17:00.-CDSL',
        ),
        sms(
          'AD-TRAIND-G',
          'ஸ்பேம் அழைப்புகளால் சோர்வடைந்துவிட்டீர்களா? TRAI DND செயலியில் புகாரளிக்கவும்.',
        ),
        sms('+919000012345', "Can't talk now. Call me back later."),
      ];

      for (final msg in ignored) {
        expect(parseSmsSpend(msg), isNull, reason: 'Should ignore: ${msg.body}');
      }
    });
  });
}
