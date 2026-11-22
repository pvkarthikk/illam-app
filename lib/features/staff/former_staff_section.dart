import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class FormerStaffSection extends ConsumerWidget {
  const FormerStaffSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final list = ref.watch(formerStaffProvider).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();

    return NestCard(
      child: ExpansionTile(
        title: Text(
          l10n.staffFormerCount(list.length),
          style: NestText.itemTitle16.copyWith(color: c.ink),
        ),
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.line),
            InkWell(
              onTap: () => context.push(Routes.staff(list[i].id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Avatar(
                      name: list[i].name ?? '',
                      color: list[i].color != null
                          ? NestPalette.fromHex(list[i].color!)
                          : c.primary,
                      size: AvatarSize.s32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list[i].name ?? '',
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                          Text(
                            roleLabel(l10n, list[i].role),
                            style: NestText.meta13.copyWith(color: c.ink3),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.ink3),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
