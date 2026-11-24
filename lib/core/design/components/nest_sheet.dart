import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

Future<T?> showNestSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.88,
    ),
    builder: (ctx) => _KeyboardInset(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: builder(ctx),
      ),
    ),
  );
}

class _KeyboardInset extends StatelessWidget {
  const _KeyboardInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}

class NestSheetHeader extends StatelessWidget {
  const NestSheetHeader({
    super.key,
    required this.title,
    this.lead,
  });

  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: NestText.sheetTitle24.copyWith(color: c.ink)),
        if (lead != null) ...[
          const SizedBox(height: 8),
          Text(lead!, style: NestText.body15.copyWith(color: c.ink2)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class NestSheetActions extends StatelessWidget {
  const NestSheetActions({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}
