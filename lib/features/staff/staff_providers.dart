import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';

final minuteTickProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => clock.now());
});

final todayDateProvider = Provider<String>((ref) {
  ref.watch(minuteTickProvider);
  return Dates.today(ref.watch(clockProvider));
});

VisitLite toLite(Visit v) =>
    VisitLite(id: v.id, date: v.date ?? '', inAt: v.inAt ?? 0, outAt: v.outAt);

/// TEMPORARY: always false — P05 replaces the body.
final monthSettledProvider = Provider.family<bool, (String, String)>(
  (ref, arg) => false,
);

final activeStaffProvider = StreamProvider<List<StaffData>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <StaffData>[]);
  return ref.watch(staffRepoProvider).watchActive(id);
});

final formerStaffProvider = StreamProvider<List<StaffData>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <StaffData>[]);
  return ref.watch(staffRepoProvider).watchFormer(id);
});

final staffByIdProvider = StreamProvider.family<StaffData?, String>(
  (ref, id) => ref.watch(staffRepoProvider).watchOne(id),
);

final visitsTodayProvider = StreamProvider<List<Visit>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <Visit>[]);
  final today = ref.watch(todayDateProvider);
  return ref.watch(staffRepoProvider).watchVisitsOn(id, today);
});

final leavesTodayProvider = StreamProvider<List<Leave>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <Leave>[]);
  final today = ref.watch(todayDateProvider);
  return ref.watch(staffRepoProvider).watchLeavesOn(id, today);
});

final openVisitsProvider = StreamProvider<List<Visit>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <Visit>[]);
  return ref.watch(staffRepoProvider).watchOpenVisits(id);
});

final staffVisitsProvider =
    StreamProvider.family<List<Visit>, (String, String, String)>(
      (ref, arg) =>
          ref.watch(staffRepoProvider).watchVisits(arg.$1, arg.$2, arg.$3),
    );

final staffLeavesProvider =
    StreamProvider.family<List<Leave>, (String, String, String)>(
      (ref, arg) =>
          ref.watch(staffRepoProvider).watchLeaves(arg.$1, arg.$2, arg.$3),
    );
