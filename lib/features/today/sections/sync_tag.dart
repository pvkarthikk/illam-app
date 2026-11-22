import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Formats elapsed time between [thenMs] and [nowMs] using localized units.
String agoText(AppLocalizations l, int nowMs, int thenMs) {
  final (unit, n) = agoParts(nowMs, thenMs);
  return switch (unit) {
    AgoUnit.now => l.agoNow,
    AgoUnit.minutes => l.agoMinutes(n),
    AgoUnit.hours => l.agoHours(n),
    AgoUnit.days => l.agoDays(n),
  };
}

/// Interactive Today hero tag showing sync freshness and opening Home details.
class SyncTag extends ConsumerWidget {
  const SyncTag({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(syncSummaryProvider).value;
    if (summary == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final nowMs = ref.read(clockProvider).nowMs;

    final String text;
    final NestTagKind kind;
    if (summary.onlyThisPhone) {
      text = l10n.syncTagOnlyThisPhone;
      kind = NestTagKind.neutral;
    } else if (summary.lastSyncAt == 0) {
      text = l10n.syncNotYet;
      kind = NestTagKind.accent;
    } else if (agoParts(nowMs, summary.lastSyncAt).$1 == AgoUnit.now &&
        (summary.freshest?.device.name.isNotEmpty ?? false)) {
      text = l10n.syncTagJustNow(summary.freshest!.device.name);
      kind = NestTagKind.ok;
    } else {
      text = l10n.syncTagLast(agoText(l10n, nowMs, summary.lastSyncAt));
      kind = summary.allInSync ? NestTagKind.ok : NestTagKind.accent;
    }

    void openHome() => context.push(Routes.home);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.syncTagLabel(text),
      onTap: openHome,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: openHome,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            widthFactor: 1.0,
            child: NestTag(label: text, kind: kind),
          ),
        ),
      ),
    );
  }
}
