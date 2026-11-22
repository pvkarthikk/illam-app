import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return Semantics(
      toggled: value,
      label: title,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: Switch(value: value, onChanged: onChanged),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.leading,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final String label;
  final String value;
  final String? sub;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        fontVariations: const [FontVariation.weight(700)],
                        color: c.ink3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontVariations: const [FontVariation.weight(700)],
                        color: danger ? c.danger : c.ink,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          fontVariations: const [FontVariation.weight(400)],
                          color: c.ink3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null || onTap != null) ...[
                const SizedBox(width: 8),
                trailing ?? Icon(Icons.chevron_right_rounded, color: c.ink3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
