import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class NestFab extends StatelessWidget {
  const NestFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    final fab = SizedBox(
      height: 58,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        tooltip: l10n.qaFabTooltip,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.qaFabLabel,
          style: NestText.button16.copyWith(color: c.onAccent),
        ),
      ),
    );

    if (disableAnim) return fab;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: fab,
    );
  }
}
