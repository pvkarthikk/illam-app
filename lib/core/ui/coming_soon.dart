import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/ui/empty_state.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.phase});

  final String phase;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.construction_rounded,
      title: AppLocalizations.of(context).commonArrivesIn(phase),
      body: '',
    );
  }
}
