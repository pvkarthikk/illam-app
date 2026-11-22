import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

void main() {
  test('NestColors lerp returns light at 0 and dark at 1', () {
    expect(NestColors.light.lerp(NestColors.dark, 0).paper, NestColors.light.paper);
    expect(NestColors.light.lerp(NestColors.dark, 1).paper, NestColors.dark.paper);
  });

  test('NestColors copyWith replaces specified token', () {
    const custom = Color(0xFF123456);
    expect(NestColors.light.copyWith(accent: custom).accent, custom);
  });

  test('NestPalette.fromHex parses 6-digit hex with #', () {
    expect(NestPalette.fromHex('#D98F1C'), const Color(0xFFD98F1C));
  });
}
