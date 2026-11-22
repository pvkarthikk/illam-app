import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class StaffActions extends Notifier<void> {
  @override
  void build() {}

  Future<void> markIn(StaffData s) async {
    final repo = ref.read(staffRepoProvider);
    final memberId = ref.read(myMemberIdProvider);
    final clock = ref.read(clockProvider);
    final l10n = lookupAppLocalizations(const Locale('en'));

    final result = await repo.markIn(s.id, memberId);
    ref
        .read(snackbarProvider)
        .show(
          l10n.staffMarkedIn(s.name ?? '', Formatters.time12(clock.now())),
          undo: result.undo,
        );
  }

  Future<void> markOut(StaffData s, Visit open) async {
    final repo = ref.read(staffRepoProvider);
    final memberId = ref.read(myMemberIdProvider);
    final clock = ref.read(clockProvider);
    final l10n = lookupAppLocalizations(const Locale('en'));

    final nowMs = clock.nowMs;
    final closedOut = max(nowMs, (open.inAt ?? nowMs) + 60000);
    final todayVisits = (ref.read(visitsTodayProvider).value ?? const [])
        .where((v) => v.staffId == s.id)
        .toList();
    final lites = <VisitLite>[
      for (final v in todayVisits)
        if (v.id == open.id)
          VisitLite(
            id: v.id,
            date: v.date ?? '',
            inAt: v.inAt ?? 0,
            outAt: closedOut,
          )
        else
          toLite(v),
    ];
    if (!todayVisits.any((v) => v.id == open.id)) {
      lites.add(
        VisitLite(
          id: open.id,
          date: open.date ?? '',
          inAt: open.inAt ?? 0,
          outAt: closedOut,
        ),
      );
    }

    final result = await repo.markOut(open, memberId);
    ref
        .read(snackbarProvider)
        .show(
          l10n.staffMarkedOut(
            s.name ?? '',
            Formatters.duration(mergedMinutes(lites)),
          ),
          undo: result.undo,
        );
  }
}

final staffActionsProvider = NotifierProvider<StaffActions, void>(
  StaffActions.new,
);
