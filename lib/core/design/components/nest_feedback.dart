import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/nest_buttons.dart';
import 'package:nm_flat/core/design/components/nest_surfaces.dart';
import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

class AlertLine extends StatelessWidget {
  const AlertLine({
    super.key,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.danger = false,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final bg = danger ? c.dangerSoft : c.accentSoft;
    final fg = danger ? c.danger : c.accentInk;

    return Semantics(
      liveRegion: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: NestText.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontVariations: const [FontVariation.weight(600)],
                  color: fg,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              NestButton(
                label: actionLabel!,
                kind: NestButtonKind.accent,
                size: NestButtonSize.sm,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.info = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool info;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final tileBg = info ? c.infoSoft : c.accentSoft;
    final tileFg = info ? c.info : c.accentInk;

    return NestCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: tileFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: c.ink3),
        ],
      ),
    );
  }
}
