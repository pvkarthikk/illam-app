import 'package:material_ui/material_ui.dart';

/// Semantic colour tokens for Illam, attached via [ThemeExtension].
@immutable
class NestColors extends ThemeExtension<NestColors> {
  const NestColors({
    required this.paper,
    required this.paper2,
    required this.card,
    required this.card2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.ok,
    required this.dot,
    required this.scrim,
    required this.onAccent,
    required this.onDanger,
  });

  final Color paper;
  final Color paper2;
  final Color card;
  final Color card2;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color line;
  final Color line2;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color accent;
  final Color accentInk;
  final Color accentSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color ok;
  final Color dot;
  final Color scrim;
  final Color onAccent;
  final Color onDanger;

  static const light = NestColors(
    paper: Color(0xFFF4ECDF),
    paper2: Color(0xFFEBE0CE),
    card: Color(0xFFFFFAF2),
    card2: Color(0xFFF7EFE2),
    ink: Color(0xFF1D2A21),
    ink2: Color(0xFF47544A),
    ink3: Color(0xFF6A756B),
    line: Color(0x1F1D2A21),
    line2: Color(0x3D1D2A21),
    primary: Color(0xFF23503A),
    onPrimary: Color(0xFFFFF8EC),
    primarySoft: Color(0xFFDCE8DA),
    accent: Color(0xFFD98F1C),
    accentInk: Color(0xFF6B4307),
    accentSoft: Color(0xFFF7E3BC),
    danger: Color(0xFFB0412A),
    dangerSoft: Color(0xFFF6DACF),
    info: Color(0xFF34508A),
    infoSoft: Color(0xFFDDE3F2),
    ok: Color(0xFF2E7A4F),
    dot: Color(0x2623503A),
    scrim: Color(0x73121A14),
    onAccent: Color(0xFF241603),
    onDanger: Color(0xFFFFFFFF),
  );

  static const dark = NestColors(
    paper: Color(0xFF0F1612),
    paper2: Color(0xFF18231C),
    card: Color(0xFF19241D),
    card2: Color(0xFF1F2C23),
    ink: Color(0xFFEFE7D8),
    ink2: Color(0xFFC3CABF),
    ink3: Color(0xFF9AA498),
    line: Color(0x1AEFE7D8),
    line2: Color(0x38EFE7D8),
    primary: Color(0xFF8FD0A8),
    onPrimary: Color(0xFF0D1A12),
    primarySoft: Color(0xFF203828),
    accent: Color(0xFFF0B44E),
    accentInk: Color(0xFFF6D9A2),
    accentSoft: Color(0xFF3A2E17),
    danger: Color(0xFFF08C72),
    dangerSoft: Color(0xFF3B211A),
    info: Color(0xFFA3B8EC),
    infoSoft: Color(0xFF1E2841),
    ok: Color(0xFF8FD0A8),
    dot: Color(0x1A8FD0A8),
    scrim: Color(0x99000000),
    onAccent: Color(0xFF241603),
    onDanger: Color(0xFF1B140A),
  );

  @override
  NestColors copyWith({
    Color? paper,
    Color? paper2,
    Color? card,
    Color? card2,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? line2,
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? ok,
    Color? dot,
    Color? scrim,
    Color? onAccent,
    Color? onDanger,
  }) {
    return NestColors(
      paper: paper ?? this.paper,
      paper2: paper2 ?? this.paper2,
      card: card ?? this.card,
      card2: card2 ?? this.card2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      line2: line2 ?? this.line2,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      ok: ok ?? this.ok,
      dot: dot ?? this.dot,
      scrim: scrim ?? this.scrim,
      onAccent: onAccent ?? this.onAccent,
      onDanger: onDanger ?? this.onDanger,
    );
  }

  @override
  NestColors lerp(ThemeExtension<NestColors>? other, double t) {
    if (other is! NestColors) return this;
    return NestColors(
      paper: Color.lerp(paper, other.paper, t)!,
      paper2: Color.lerp(paper2, other.paper2, t)!,
      card: Color.lerp(card, other.card, t)!,
      card2: Color.lerp(card2, other.card2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      dot: Color.lerp(dot, other.dot, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
    );
  }
}

class NestPalette {
  static const immersiveBg = Color(0xFF0F1612),
      immersiveRow = Color(0xFF1A251D),
      immersiveText = Color(0xFFF3EBDD),
      immersiveMuted = Color(0xFFA9B4A7),
      immersiveAccent = Color(0xFFE9A93C),
      immersiveChecked = Color(0xFF8FD0A8),
      immersiveBox = Color(0xFF6E7B70);
  static const categories = <String, Color>{
    'Groceries': Color(0xFF2E7A4F),
    'Shopping': Color(0xFF34508A),
    'Staff': Color(0xFFD98F1C),
    'Utilities': Color(0xFF7A5AA8),
    'Eating out': Color(0xFFB0412A),
    'Home care': Color(0xFF4F8A8B),
    'Other': Color(0xFF8E998C),
  };
  static const avatars = <Color>[
    Color(0xFF23503A),
    Color(0xFF34508A),
    Color(0xFFB0412A),
    Color(0xFFB07A1A),
    Color(0xFF7A5AA8),
    Color(0xFF4F8A8B),
    Color(0xFF8A5A2B),
    Color(0xFF5E8A2B),
    Color(0xFFA8362A),
  ];
  // Store badges: background, letters, foreground (contrast-checked; Flipkart darkened)
  static const channels = <String, ChannelStyle>{
    'zepto': ChannelStyle(Color(0xFF5B1E8C), 'Z', Color(0xFFFFFFFF)),
    'blinkit': ChannelStyle(Color(0xFFF2C21B), 'b', Color(0xFF2B2205)),
    'bigbasket': ChannelStyle(Color(0xFF5E9A1C), 'bb', Color(0xFF1B140A)),
    'amazon': ChannelStyle(Color(0xFFE58A00), 'a', Color(0xFF1B140A)),
    'flipkart': ChannelStyle(Color(0xFF2468D8), 'F', Color(0xFFFFFFFF)),
    'meesho': ChannelStyle(Color(0xFFC81E65), 'M', Color(0xFFFFFFFF)),
  }; // 'offline' is drawn by ChannelBadge
  static Color fromHex(String hex) =>
      Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}

class ChannelStyle {
  const ChannelStyle(this.bg, this.letters, this.fg);
  final Color bg, fg;
  final String letters;
}

extension NestContext on BuildContext {
  NestColors get nest =>
      Theme.of(this).extension<NestColors>() ?? NestColors.light;
}
