import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';
import 'package:nm_flat/core/domain/invoice/store_parsers.dart';

void main() {
  group('store invoice parsers', () {
    test('parses Zepto HTML table with discount and handling fee reconciled', () {
      const html = '''
<html><body>
  <h2>Your Zepto order #ZP-987654 is delivered</h2>
  <p>Order Date: 18 Nov 2026</p>
  <table>
    <tr><th>Item</th><th>Qty</th><th>Price</th></tr>
    <tr><td>Amul Taaza Toned Milk 500ml</td><td>2</td><td>₹56.00</td></tr>
    <tr><td>Vim Liquid Dishwash Gel 500ml</td><td>1</td><td>₹105.00</td></tr>
    <tr><td>Harvest Gold Brown Bread</td><td>1</td><td>₹45.00</td></tr>
  </table>
  <p>Item Total: ₹206.00</p>
  <p>Handling Charge: ₹10.00</p>
  <p>Coupon Discount: ₹20.00</p>
  <p><strong>Grand Total: ₹196.00</strong></p>
</body></html>
''';
      final parsed = parseOrderInvoice(
        fromEmail: 'orders@zeptonow.com',
        subject: 'Your Zepto order #ZP-987654',
        htmlBody: html,
        fallbackDate: '2026-11-18',
      );
      expect(parsed, isNotNull);
      expect(parsed!.channel, InvoiceChannel.zepto);
      expect(parsed.orderId, 'ZP-987654');
      expect(parsed.date, '2026-11-18');
      expect(parsed.totalPaise, 19600);
      expect(parsed.feesPaise, 1000);
      expect(parsed.discountPaise, 2000);
      expect(parsed.items.length, 4);
      expect(parsed.items[0].category, 'Groceries');
      expect(parsed.items[1].category, 'Home care');
      final sum = parsed.items.fold<int>(0, (a, b) => a + b.amountPaise);
      expect(sum, 19600);
    });

    test('parses Blinkit PDF tax invoice text accurately', () {
      const pdfText = '''
Blink Commerce Private Limited
TAX INVOICE
Order ID: BLK-11223344
Invoice Date: 14/11/2026
Sl. No Description HSN Code Qty MRP Total
1. Mother Dairy Classic Curd 400g 04031000 1 35.00 35.00
2. Fortune Sunflower Oil 1L 15121910 2 145.00 290.00
Handling Charge 15.00
Small Cart Charge 20.00
Grand Total ₹360.00
''';
      final parsed = parseOrderInvoice(
        fromEmail: 'no-reply@blinkit.com',
        subject: 'Invoice for your Blinkit order',
        pdfText: pdfText,
        fallbackDate: '2026-11-14',
      );
      expect(parsed, isNotNull);
      expect(parsed!.channel, InvoiceChannel.blinkit);
      expect(parsed.orderId, 'BLK-11223344');
      expect(parsed.date, '2026-11-14');
      expect(parsed.totalPaise, 36000);
      expect(parsed.feesPaise, 3500);
      expect(parsed.items.map((i) => i.name).toList(), [
        'Mother Dairy Classic Curd 400g',
        'Fortune Sunflower Oil 1L',
        'Delivery & fees',
      ]);
      expect(parsed.items[1].quantity, 2);
      expect(parsed.items.fold<int>(0, (a, b) => a + b.amountPaise), 36000);
    });

    test('parses Amazon multi-line product card email', () {
      const plain = '''
Hello Karthik,
Your Amazon.in order #405-1234567-7654321 has shipped.
Order Date: Nov 10, 2026

Presto! Garbage Bags Medium 180 Bags
Sold by: Cloudtail India
Qty: 1
₹299.00

Philips 9W LED Bulb Pack of 4
Sold by: Appario Retail
Qty: 2
₹420.00

Order Total: ₹719.00
''';
      final parsed = parseOrderInvoice(
        fromEmail: 'ship-confirm@amazon.in',
        subject: 'Your Amazon.in order #405-1234567-7654321',
        plainBody: plain,
        fallbackDate: '2026-11-10',
      );
      expect(parsed, isNotNull);
      expect(parsed!.channel, InvoiceChannel.amazon);
      expect(parsed.orderId, '405-1234567-7654321');
      expect(parsed.date, '2026-11-10');
      expect(parsed.totalPaise, 71900);
      expect(parsed.items.length, 2);
      expect(parsed.items[0].name, 'Presto! Garbage Bags Medium 180 Bags');
      expect(parsed.items[0].category, 'Home care');
      expect(parsed.items[1].quantity, 2);
      expect(parsed.items[1].amountPaise, 42000);
    });

    test('parses Amazon wrapped GST PDF invoice text', () {
      const pdfText = '''
Tax Invoice
Amazon Seller Services Pvt. Ltd.
Order Number: 407-9998887-1112223
Order Date: 05.11.2026
1 Apple iPhone 15 Case -
Midnight Black 1 1,499.00 269.82 1,768.82
TOTAL: ₹1,768.82
''';
      final parsed = parseOrderInvoice(
        fromEmail: 'auto-confirm@amazon.in',
        subject: 'Order invoice',
        pdfText: pdfText,
        fallbackDate: '2026-11-05',
      );
      expect(parsed, isNotNull);
      expect(parsed!.channel, InvoiceChannel.amazon);
      expect(parsed.date, '2026-11-05');
      expect(parsed.totalPaise, 176882);
      expect(parsed.items.length, 1);
      expect(
        parsed.items.first.name,
        contains('Apple iPhone 15 Case'),
      );
      expect(parsed.items.first.amountPaise, 176882);
    });

    test('parses Flipkart invoice and ignores marketing promo alerts', () {
      const fkHtml = '''
<div>
  <p>Flipkart Order Confirmation</p>
  <p>Order ID: OD331122334455667788</p>
  <p>Order Date: 2026-11-02</p>
  <table>
    <tr><td>Product</td><td>Qty</td><td>Amount</td></tr>
    <tr><td>Samsung 25W Travel Adapter</td><td>1</td><td>₹1,099.00</td></tr>
  </table>
  <p>Delivery Charges: ₹40.00</p>
  <p>Total Amount: ₹1,139.00</p>
</div>
''';
      final parsed = parseOrderInvoice(
        fromEmail: 'noreply@flipkart.com',
        subject: 'Flipkart order placed',
        htmlBody: fkHtml,
        fallbackDate: '2026-11-02',
      );
      expect(parsed, isNotNull);
      expect(parsed!.channel, InvoiceChannel.flipkart);
      expect(parsed.orderId, 'OD331122334455667788');
      expect(parsed.totalPaise, 113900);
      expect(parsed.items.length, 2);

      final promo = parseOrderInvoice(
        fromEmail: 'promo@zeptonow.com',
        subject: 'Weekend Flash Sale! Flat ₹500 off on Zepto!',
        plainBody: 'Use code ZEPTO500 to get ₹500 cashback on your next cart.',
        fallbackDate: '2026-11-20',
      );
      expect(promo, isNull);
    });

    test('reconcileItemsWithTotal distributes rounding remainders evenly', () {
      const items = [
        ParsedInvoiceItem(
          name: 'A',
          quantity: 1,
          amountPaise: 5000,
          category: 'Groceries',
        ),
        ParsedInvoiceItem(
          name: 'B',
          quantity: 1,
          amountPaise: 5000,
          category: 'Groceries',
        ),
        ParsedInvoiceItem(
          name: 'C',
          quantity: 1,
          amountPaise: 5000,
          category: 'Groceries',
        ),
      ];
      final res = reconcileItemsWithTotal(items, 10000);
      expect(res.fold<int>(0, (a, b) => a + b.amountPaise), 10000);
      expect(res.every((e) => e.amountPaise >= 3333 && e.amountPaise <= 3334), isTrue);
    });
  });
}
