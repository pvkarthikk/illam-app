import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

enum AvatarSize { s24, s32, s52, s72 }

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    required this.color,
    this.size = AvatarSize.s32,
    this.ring = false,
    this.semanticLabel,
  });

  final String name;
  final Color color;
  final AvatarSize size;
  final bool ring;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double diameter = switch (size) {
      AvatarSize.s24 => 24,
      AvatarSize.s32 => 32,
      AvatarSize.s52 => 52,
      AvatarSize.s72 => 72,
    };
    final double fontSize = switch (size) {
      AvatarSize.s24 => 10,
      AvatarSize.s32 => 13,
      AvatarSize.s52 => 19,
      AvatarSize.s72 => 28,
    };

    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();

    final bg = Color.lerp(c.card, color, 0.22)!;
    final fg = isDark
        ? Color.lerp(color, Colors.white, 0.45)!
        : Color.lerp(color, Colors.black, 0.30)!;

    final TextStyle style = size == AvatarSize.s72
        ? TextStyle(
            fontFamily: NestText.serif,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: fg,
          )
        : TextStyle(
            fontFamily: NestText.sans,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            fontVariations: const [FontVariation.weight(800)],
            color: fg,
          );

    Widget avatar = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(letter, style: style),
    );

    if (ring) {
      avatar = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.paper,
          shape: BoxShape.circle,
          border: Border.all(color: c.accent, width: 2),
        ),
        child: avatar,
      );
    }

    if (semanticLabel == null) {
      return ExcludeSemantics(child: avatar);
    }

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: avatar,
    );
  }
}

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.people,
    this.max = 3,
  });

  final List<({String name, Color color})> people;
  final int max;

  @override
  Widget build(BuildContext context) {
    final visible = people.take(max).toList();
    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 24.0 + (visible.length - 1) * 16.0,
      height: 24,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 16.0,
              child: Avatar(
                name: visible[i].name,
                color: visible[i].color,
                size: AvatarSize.s24,
              ),
            ),
        ],
      ),
    );
  }
}

class ChannelBadge extends StatelessWidget {
  const ChannelBadge({
    super.key,
    required this.channel,
    this.size = 34,
  });

  final String channel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final style = NestPalette.channels[channel];

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style?.bg ?? c.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: style != null
            ? Text(
                style.letters,
                style: TextStyle(
                  fontFamily: NestText.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontVariations: const [FontVariation.weight(900)],
                  color: style.fg,
                ),
              )
            : Icon(Icons.storefront_outlined, size: 18, color: c.paper),
      ),
    );
  }
}
