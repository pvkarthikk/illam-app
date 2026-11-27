import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/receipt/receipt_parser.dart';

void main() {
  test('parses Indian supermarket receipt with POS columns, tax flags & total', () {
    const receipt = '''
TAX INVOICE
RELIANCE FRESH SUPERMARKET
GSTIN: 29ABCDE1234F1Z5
45, MG Road, Bengaluru 560001
Bill No: RF-8821   Date: 26/11/2026
Item Name        Qty   Rate    Amount
Amul Taaza Milk   2   33.00    66.00 T
Surf Excel Easy        98.50    98.50 T
Tata Salt 1Kg          28.00    28.00 N
--------------------------------------
Subtotal                      192.50
CGST 2.5%                       2.40
SGST 2.5%                       2.40
Grand Total                   197.30
Cash Tendered                 200.00
Thank You Visit Again
''';

    final parsed = parseReceiptText(receipt, fallbackDate: '2026-11-27');

    expect(parsed.merchant, 'Reliance Fresh Supermarket');
    expect(parsed.date, '2026-11-26');
    expect(parsed.totalPaise, 19730);
    expect(parsed.items.length, 3);
    expect(parsed.items[0].name, 'Amul Taaza Milk');
    expect(parsed.items[0].amountPaise, 6600);
    expect(parsed.items[0].category, 'Groceries');
    expect(parsed.items[1].name, 'Surf Excel Easy');
    expect(parsed.items[1].amountPaise, 9850);
    expect(parsed.items[1].category, 'Home care');
    expect(parsed.items[2].name, 'Tata Salt 1Kg');
    expect(parsed.items[2].amountPaise, 2800);
    expect(parsed.items[2].category, 'Groceries');
  });

  test('parses restaurant bill with GST, Round Off, and Eating out inference', () {
    const receipt = '''
SAGAR RATNA DARSHINI
No 12, Indiranagar 100ft Rd
Date: 25-Nov-2026
Masala Dosa       1    95.00
Filter Coffee          60
Idli Vada         2    80.00
Sub Total             235.00
CGST @2.5%              5.88
SGST @2.5%              5.88
Round Off               0.24
Net Payable        Rs. 247.00
Paid via UPI
''';

    final parsed = parseReceiptText(receipt, fallbackDate: '2026-11-26');

    expect(parsed.merchant, 'Sagar Ratna Darshini');
    expect(parsed.date, '2026-11-25');
    expect(parsed.totalPaise, 24700);
    expect(parsed.defaultCategory, 'Eating out');
    expect(parsed.items.length, 3);
    expect(parsed.items[0].name, 'Masala Dosa');
    expect(parsed.items[0].amountPaise, 9500);
    expect(parsed.items[0].category, 'Eating out');
    expect(parsed.items[1].name, 'Filter Coffee');
    expect(parsed.items[1].amountPaise, 6000);
    expect(parsed.items[2].name, 'Idli Vada');
    expect(parsed.items[2].amountPaise, 8000);
  });

  test('handles pharmacy OCR typos (O->0, comma decimal), two-line items & ignores expiry date', () {
    const receipt = '''
CASH MEMO
APOLLO PHARMACY
Date: 24-11-26
Exp Date: 10/12/2028
Dolo 650 Strip      Rs. 32.OO
Vitamin D3
  2 x 72,75             145,50
Total                   177.50
''';

    final parsed = parseReceiptText(
      receipt,
      fallbackDate: '2026-11-26',
      merchantRules: const {'apollo pharmacy': 'Medical'},
    );

    expect(parsed.merchant, 'Apollo Pharmacy');
    expect(parsed.date, '2026-11-24');
    expect(parsed.totalPaise, 17750);
    expect(parsed.defaultCategory, 'Medical');
    expect(parsed.items.length, 2);
    expect(parsed.items[0].name, 'Dolo 650 Strip');
    expect(parsed.items[0].amountPaise, 3200);
    expect(parsed.items[0].category, 'Medical');
    expect(parsed.items[1].name, 'Vitamin D3');
    expect(parsed.items[1].amountPaise, 14550);
    expect(parsed.items[1].quantity, 2);
  });

  test('supports total-only bills and empty OCR gracefully', () {
    const totalOnly = '''
SRI LAKSHMI FUELS
HP Petrol Pump
Date: 2026-11-20
Bill Amount : Rs. 1,500.00
''';

    final single = parseReceiptText(
      totalOnly,
      fallbackDate: '2026-11-26',
      merchantRules: const {'sri lakshmi fuels': 'Fuel'},
    );
    expect(single.merchant, 'Sri Lakshmi Fuels');
    expect(single.date, '2026-11-20');
    expect(single.items, isEmpty);
    expect(single.totalPaise, 150000);
    expect(single.defaultCategory, 'Fuel');

    final empty = parseReceiptText('  \n --- \n ', fallbackDate: '2026-11-26');
    expect(empty.merchant, '');
    expect(empty.date, '2026-11-26');
    expect(empty.items, isEmpty);
    expect(empty.totalPaise, 0);
  });
}
