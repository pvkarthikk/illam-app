import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showRemoveStaffSheet(
  BuildContext context,
  WidgetRef ref,
  StaffData staff,
) async {
  final l10n = AppLocalizations.of(context);
  final name = staff.name ?? '';
  final outcome = await showNestSheet<({bool confirmed, AssignedWork? work})>(
    context,
    (_) => _RemoveStaffSheet(staff: staff),
  );
  if (outcome == null || !outcome.confirmed) return;

  final today = ref.read(todayDateProvider);
  final tasksRepo = ref.read(tasksRepoProvider);
  final staffRepo = ref.read(staffRepoProvider);
  final snackbar = ref.read(snackbarProvider);
  final me = ref.read(myMemberIdProvider);
  final work = outcome.work ?? await tasksRepo.loadAssigned(staff.id);
  final res = await staffRepo.removeStaff(
    staff.id,
    today,
    extra: work.isEmpty
        ? null
        : (c) => tasksRepo.buildReassignOps(c, work, me),
  );
  if (context.mounted) context.pop();
  snackbar.show(l10n.staffRemoved(name), undo: res.undo);
}

class _RemoveStaffSheet extends ConsumerStatefulWidget {
  const _RemoveStaffSheet({required this.staff});

  final StaffData staff;

  @override
  ConsumerState<_RemoveStaffSheet> createState() => _RemoveStaffSheetState();
}

class _RemoveStaffSheetState extends ConsumerState<_RemoveStaffSheet> {
  AssignedWork? _work;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final w = await ref.read(tasksRepoProvider).loadAssigned(widget.staff.id);
    if (mounted) {
      setState(() => _work = w);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = widget.staff.name ?? '';
    final lead = (_work != null && !_work!.isEmpty)
        ? '${l10n.staffRemoveLead} ${l10n.tasksRemoveStaffMoves}'
        : l10n.staffRemoveLead;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.staffRemoveTitle(name), lead: lead),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () =>
                  Navigator.of(context).pop((confirmed: false, work: _work)),
            ),
            NestButton(
              label: l10n.commonRemove,
              kind: NestButtonKind.danger,
              onPressed: () =>
                  Navigator.of(context).pop((confirmed: true, work: _work)),
            ),
          ],
        ),
      ],
    );
  }
}
