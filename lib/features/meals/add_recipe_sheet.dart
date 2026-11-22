import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showAddRecipeSheet(BuildContext context) => showNestSheet<void>(
  context,
  (sheetCtx) => const _AddRecipeSheet(),
);

class _AddRecipeSheet extends StatelessWidget {
  const _AddRecipeSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.recipeAddTitle,
          lead: l10n.recipeAddLead,
        ),
        _AddOptionRow(
          icon: Icons.edit_note_rounded,
          title: l10n.recipeTypeIt,
          subtitle: l10n.recipeTypeItSub,
          onTap: () {
            Navigator.of(context).pop();
            context.push(Routes.recipeEdit('new'));
          },
        ),
        const SizedBox(height: 8),
        _AddOptionRow(
          icon: Icons.link_rounded,
          title: l10n.recipePasteLink,
          subtitle: l10n.recipePasteLinkSub,
          comingSoonLabel: l10n.recipeComingSoon,
        ),
        const SizedBox(height: 8),
        _AddOptionRow(
          icon: Icons.photo_camera_outlined,
          title: l10n.recipeSnap,
          subtitle: l10n.recipeSnapSub,
          comingSoonLabel: l10n.recipeComingSoon,
        ),
      ],
    );
  }
}

class _AddOptionRow extends StatelessWidget {
  const _AddOptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoonLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final disabled = comingSoonLabel != null;

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.paper2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: c.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      if (comingSoonLabel != null)
                        NestTag(label: comingSoonLabel!),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (disabled) {
      return Semantics(
        enabled: false,
        child: Opacity(opacity: 0.6, child: row),
      );
    }

    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: row,
      ),
    );
  }
}
