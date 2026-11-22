import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/channels.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<String?> showStorePicker(BuildContext context, String list) {
  final l10n = AppLocalizations.of(context);
  final channels = listChannels[list] ?? const <String>[];
  return showNestSheet<String>(
    context,
    (ctx) {
      final c = ctx.nest;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(
            title: l10n.listsPickerTitle,
            lead: l10n.listsPickerLead,
          ),
          for (final id in channels)
            InkWell(
              onTap: () => Navigator.of(ctx).pop(id),
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ChannelBadge(channel: id),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              channelName(l10n, id),
                              style: TextStyle(
                                fontFamily: NestText.sans,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontVariations: const [
                                  FontVariation.weight(700),
                                ],
                                color: c.ink,
                              ),
                            ),
                            Text(
                              channelEta(l10n, id),
                              style: NestText.meta13.copyWith(color: c.ink3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
