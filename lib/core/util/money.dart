import 'package:intl/intl.dart';

abstract final class Money {
  static final _in = NumberFormat.decimalPattern('en_IN');
  static const _minus = '\u2212';

  static String format(int paise) {
    final rupees = (paise.abs() + 50) ~/ 100;
    final prefix = paise < 0 && rupees > 0 ? _minus : '';
    return '$prefix₹${_in.format(rupees)}';
  }

  static String formatPaise(int paise) {
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final rem = (abs % 100).toString().padLeft(2, '0');
    final prefix = paise < 0 ? _minus : '';
    return '$prefix₹${_in.format(rupees)}.$rem';
  }

  static int? parseRupees(String text) {
    final cleaned = text.replaceAll(RegExp(r'[₹,\s]'), '');
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;
    final parts = cleaned.split('.');
    final rupees = int.tryParse(parts[0]);
    if (rupees == null) return null;
    final frac =
        parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;
    return rupees * 100 + frac;
  }
}
