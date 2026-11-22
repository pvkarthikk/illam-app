import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

enum NestButtonKind { primary, accent, tonal, ghost, dangerGhost, danger }

enum NestButtonSize { sm, md, block }

class NestButton extends StatefulWidget {
  const NestButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = NestButtonKind.primary,
    this.size = NestButtonSize.md,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final NestButtonKind kind;
  final NestButtonSize size;
  final IconData? icon;
  final String? semanticLabel;

  @override
  State<NestButton> createState() => _NestButtonState();
}

class _NestButtonState extends State<NestButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final enabled = widget.onPressed != null;

    final (Color bg, Color fg, BorderSide side) = switch (widget.kind) {
      NestButtonKind.primary => (c.primary, c.onPrimary, BorderSide.none),
      NestButtonKind.accent => (c.accent, c.onAccent, BorderSide.none),
      NestButtonKind.tonal => (c.primarySoft, c.primary, BorderSide.none),
      NestButtonKind.ghost => (
        Colors.transparent,
        c.ink,
        BorderSide(color: c.line2, width: 1.5),
      ),
      NestButtonKind.dangerGhost => (
        Colors.transparent,
        c.danger,
        BorderSide(color: c.danger.withValues(alpha: 0.45), width: 1.5),
      ),
      NestButtonKind.danger => (c.danger, c.onDanger, BorderSide.none),
    };

    final double minHeight = switch (widget.size) {
      NestButtonSize.sm => 36,
      NestButtonSize.md => 44,
      NestButtonSize.block => 52,
    };
    final double horizontalPad = widget.size == NestButtonSize.sm ? 14 : 18;
    final TextStyle textStyle =
        (widget.size == NestButtonSize.block
                ? NestText.button16
                : NestText.button15)
            .copyWith(color: fg);

    final pill = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Material(
          color: bg,
          shape: StadiumBorder(side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: widget.onPressed,
            onTapDown: enabled ? (_) => _setPressed(true) : null,
            onTapUp: enabled ? (_) => _setPressed(false) : null,
            onTapCancel: enabled ? () => _setPressed(false) : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                minWidth: widget.size == NestButtonSize.block
                    ? double.infinity
                    : 0,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: widget.size == NestButtonSize.block
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget target = widget.size == NestButtonSize.block
        ? pill
        : ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: widget.onPressed,
              child: Center(widthFactor: 1.0, child: pill),
            ),
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: target,
    );
  }
}
