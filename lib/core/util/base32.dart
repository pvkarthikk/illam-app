abstract final class Base32 {
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static String encode(List<int> bytes) {
    var buffer = 0;
    var bitsLeft = 0;
    final out = StringBuffer();

    for (final b in bytes) {
      buffer = (buffer << 8) | (b & 0xff);
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        out.write(_alphabet[(buffer >> bitsLeft) & 0x1f]);
      }
      buffer &= (1 << bitsLeft) - 1;
    }

    if (bitsLeft > 0) {
      out.write(_alphabet[(buffer << (5 - bitsLeft)) & 0x1f]);
    }
    return out.toString();
  }

  static List<int> decode(String s) {
    var buffer = 0;
    var bitsLeft = 0;
    final out = <int>[];

    for (var i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      if (c == 61) continue; // '='

      final int val;
      if (c >= 65 && c <= 90) {
        val = c - 65;
      } else if (c >= 97 && c <= 122) {
        val = c - 97;
      } else if (c >= 50 && c <= 55) {
        val = c - 50 + 26;
      } else {
        throw FormatException('Invalid Base32 character', s, i);
      }

      buffer = (buffer << 5) | val;
      bitsLeft += 5;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        out.add((buffer >> bitsLeft) & 0xff);
        buffer &= (1 << bitsLeft) - 1;
      }
    }

    return out;
  }
}
