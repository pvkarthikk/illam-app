import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: c.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: NestText.sheetTitle24.copyWith(color: c.ink),
            textAlign: TextAlign.center,
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: NestText.body15.copyWith(color: c.ink2),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
