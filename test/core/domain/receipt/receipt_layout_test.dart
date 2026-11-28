import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/receipt/receipt_layout.dart';
import 'package:nm_flat/core/domain/receipt/receipt_parser.dart';

void main() {
  test('reconstructReceiptLines pairs skewed left item columns with right-aligned prices', () {
    // Simulates ML Kit delivering left-column descriptions first and right-column
    // prices in a separate block with slight vertical camera tilt (~8px skew).
    const boxes = [
      // Header centered
      OcrTextBox(text: 'NILGIRIS SUPERMARKET', left: 160, top: 20, right: 640, bottom: 52),
      OcrTextBox(text: 'Date: 28/11/2026', left: 220, top: 64, right: 520, bottom: 90),
      // Left column block (items)
      OcrTextBox(text: 'Amul Taaza Milk 1L', left: 40, top: 140, right: 340, bottom: 170),
      OcrTextBox(text: 'Harvest Gold Bread', left: 42, top: 185, right: 330, bottom: 215),
      OcrTextBox(text: 'Total', left: 40, top: 245, right: 140, bottom: 278),
      // Right column block (prices, slightly tilted upward by ~6px)
      OcrTextBox(text: '72.00', left: 620, top: 134, right: 740, bottom: 164),
      OcrTextBox(text: '45.00', left: 625, top: 178, right: 740, bottom: 208),
      OcrTextBox(text: '117.00', left: 605, top: 240, right: 740, bottom: 272),
    ];

    final reconstructed = reconstructReceiptLines(boxes);
    expect(reconstructed.split('\n'), [
      'NILGIRIS SUPERMARKET',
      'Date: 28/11/2026',
      'Amul Taaza Milk 1L  72.00',
      'Harvest Gold Bread  45.00',
      'Total  117.00',
    ]);

    final parsed = parseReceiptText(reconstructed, fallbackDate: '2026-11-28');
    expect(parsed.merchant, 'Nilgiris Supermarket');
    expect(parsed.date, '2026-11-28');
    expect(parsed.totalPaise, 11700);
    expect(parsed.items.length, 2);
    expect(parsed.items[0].name, 'Amul Taaza Milk 1L');
    expect(parsed.items[0].amountPaise, 7200);
    expect(parsed.items[1].name, 'Harvest Gold Bread');
    expect(parsed.items[1].amountPaise, 4500);
  });

  test('does not merge tightly stacked single-column lines that overlap horizontally', () {
    const boxes = [
      OcrTextBox(text: 'Tomatoes 1kg', left: 40, top: 100, right: 260, bottom: 130),
      OcrTextBox(text: 'Onions 2kg', left: 42, top: 122, right: 250, bottom: 152),
      OcrTextBox(text: '60.00', left: 600, top: 101, right: 700, bottom: 129),
      OcrTextBox(text: '90.00', left: 600, top: 123, right: 700, bottom: 151),
    ];

    final reconstructed = reconstructReceiptLines(boxes);
    expect(reconstructed.split('\n'), [
      'Tomatoes 1kg  60.00',
      'Onions 2kg  90.00',
    ]);
  });

  test('ignores blank boxes and preserves unboxed lines at end', () {
    const boxes = [
      OcrTextBox(text: '   ', left: 0, top: 0, right: 100, bottom: 20),
      OcrTextBox(text: 'Cashier: Ravi', left: 0, top: 0, right: 0, bottom: 0),
      OcrTextBox(text: 'Coffee', left: 40, top: 100, right: 140, bottom: 130),
      OcrTextBox(text: '50.00', left: 500, top: 100, right: 590, bottom: 130),
    ];

    expect(reconstructReceiptLines(boxes), 'Coffee  50.00\nCashier: Ravi');
    expect(reconstructReceiptLines(const []), '');
  });
}
