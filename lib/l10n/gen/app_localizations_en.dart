// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nest Mojo : Flat';

  @override
  String get tabToday => 'Today';

  @override
  String get tabLists => 'Lists';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabMeals => 'Meals';

  @override
  String get tabMoney => 'Money';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDecrease => 'Decrease';

  @override
  String get commonIncrease => 'Increase';

  @override
  String commonArrivesIn(Object phase) {
    return 'Arrives in $phase';
  }

  @override
  String get debugTitle => 'Developer tools';

  @override
  String get debugGallery => 'Component gallery';

  @override
  String get debugGallerySub => 'Every shared component, light and dark';

  @override
  String get debugDarkTheme => 'Dark theme';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String undoConflict(Object name) {
    return 'Couldn’t undo — $name changed it.';
  }

  @override
  String get undoConflictYou => 'Couldn’t undo — you changed it.';

  @override
  String get undoConflictSomeone => 'Couldn’t undo — someone else changed it.';

  @override
  String get debugDataLab => 'Data lab';

  @override
  String get debugDataLabSub => 'Notes, undo and the op log';

  @override
  String get labAddNote => 'Add note';

  @override
  String get labNoteHint => 'Note title';

  @override
  String get labNoteAdded => 'Note added';

  @override
  String get labNoteRenamed => 'Note renamed';

  @override
  String get labNoteDeleted => 'Note deleted';

  @override
  String get labPinned => 'Pinned';

  @override
  String get labUnpinned => 'Unpinned';

  @override
  String labTaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taps',
      one: '1 tap',
    );
    return '$_temp0';
  }

  @override
  String get labRecent => 'Recent changes';

  @override
  String get labOpLog => 'Op log';

  @override
  String labOpsTotal(int count) {
    return '$count ops';
  }

  @override
  String get labPin => 'Pin';

  @override
  String get labEdit => 'Edit';

  @override
  String get labDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get debugLoadDemo => 'Load demo home';

  @override
  String get debugLoadDemoSub => 'Adds sample data for every finished phase';

  @override
  String get debugDemoLoaded => 'Demo data loaded';

  @override
  String get debugWipe => 'Wipe this phone';

  @override
  String get debugWipeSub => 'Erase the database and settings';

  @override
  String get debugWipeTitle => 'Erase everything on this phone?';

  @override
  String get debugWipeConfirm => 'Wipe';

  @override
  String get debugWiped => 'This phone was wiped';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get errCantSecure =>
      'Nest Mojo : Flat can’t secure data on this phone';

  @override
  String welcomeHeadline(Object em) {
    return 'Run your home,\n$em';
  }

  @override
  String get welcomeHeadlineEm => 'together.';

  @override
  String get welcomeSub =>
      'House help, groceries, chores, meals and spends — shared between the phones in your home.';

  @override
  String get welcomeStartLabel => 'How do you want to start?';

  @override
  String get welcomeCreateTitle => 'Create a home';

  @override
  String get welcomeCreateBody =>
      'Set it up for your family. You’ll be the admin and invite the others.';

  @override
  String get welcomeJoinTitle => 'Join a home';

  @override
  String get welcomeJoinBody =>
      'Someone at home already uses Nest Mojo : Flat. Scan their QR code or type their phrase.';

  @override
  String get welcomeHint =>
      'Only one person creates the home — everyone else joins it.';

  @override
  String get welcomeRestore => 'Restore from a backup';

  @override
  String get welcomeFine =>
      'No account, no cloud. Your home’s data stays on your family’s phones and syncs directly between them.';

  @override
  String get welcomeCreditLine1 => 'Made at home, for homes.';

  @override
  String welcomeCreditLine2(Object heart) {
    return 'with $heart by Nandini Srinivasan & Karthik Venkatesh';
  }

  @override
  String get welcomeCreditA11y =>
      'Made at home, for homes, with love by Nandini Srinivasan and Karthik Venkatesh';

  @override
  String get createTitle => 'Create your home';

  @override
  String get createSub =>
      'You’ll be its admin. Others join from their phones with a QR code or a short phrase.';

  @override
  String get createYourName => 'Your name';

  @override
  String get createYourNameHint => 'e.g. Anand Kumar';

  @override
  String get createHomeName => 'Home name';

  @override
  String createHomeNameHint(Object surname) {
    return 'e.g. $surname Home';
  }

  @override
  String createSuggestHome(Object surname) {
    return '$surname Home';
  }

  @override
  String get createSuggestFlat => 'Our flat';

  @override
  String get createSuggestAmma => 'Amma’s house';

  @override
  String get createSurnameFallback => 'Our';

  @override
  String get createSuggestionsLabel => 'Suggestions';

  @override
  String get createHomeIdLabel => 'Home ID';

  @override
  String get createHomeIdNote => 'Made on this phone · unique to your home';

  @override
  String get createButton => 'Create home';

  @override
  String get createErrName => 'Add your name.';

  @override
  String get createErrHome => 'Give your home a name.';

  @override
  String get todayGreetingLate => 'Still up';

  @override
  String get todayGreetingMorning => 'Good morning';

  @override
  String get todayGreetingAfternoon => 'Good afternoon';

  @override
  String get todayGreetingEvening => 'Good evening';

  @override
  String todayEyebrow(Object home, Object date) {
    return '$home · $date';
  }

  @override
  String todayHeadlineAllSet(Object em) {
    return 'The house is $em today.';
  }

  @override
  String get todayAllSetEm => 'all set';

  @override
  String get debugViewAsMember => 'Viewing as member';

  @override
  String get debugViewAsMemberSub => 'Hide admin-only controls (UI test only)';

  @override
  String debugIsAdmin(Object value) {
    return 'Admin on this phone: $value';
  }

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get weekdayLetters => 'M,T,W,T,F,S,S';

  @override
  String get staffDaily => 'Daily';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffNotFound => 'This house help isn’t in your home any more.';

  @override
  String staffMarkedIn(Object name, Object time) {
    return '$name marked in at $time';
  }

  @override
  String staffMarkedOut(Object name, Object duration) {
    return '$name out · $duration today';
  }

  @override
  String staffExpected(Object times) {
    return 'Expected $times';
  }

  @override
  String staffInSince(Object time, Object duration) {
    return 'In since $time · $duration';
  }

  @override
  String staffDoneToday(Object duration, Object time) {
    return '$duration today · out $time';
  }

  @override
  String get staffOnLeaveToday => 'On leave today (informed)';

  @override
  String get staffDayOff => 'Day off';

  @override
  String get staffMarkIn => 'Mark in';

  @override
  String get staffMarkOut => 'Mark out';

  @override
  String get staffVisitButton => 'Visit';

  @override
  String get staffChange => 'Change';

  @override
  String staffStartAnother(Object name) {
    return 'Start another visit for $name';
  }

  @override
  String get staffHelpTitle => 'Help at home';

  @override
  String get staffHelpSub => 'Tap a name for attendance & pay';

  @override
  String get staffNoneYet => 'No house help added yet.';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonFix => 'Fix';

  @override
  String staffAlertNotMarkedOut(Object name, Object day) {
    return '$name wasn’t marked out on $day';
  }

  @override
  String staffAlertTwoOpen(Object name) {
    return '$name has 2 open visits';
  }

  @override
  String get staffAddTitle => 'Add house help';

  @override
  String get staffAddLead =>
      'They don’t need the app. Anyone at home marks them in and out; pay is worked out for you.';

  @override
  String get staffName => 'Name';

  @override
  String get staffAddNameHint => 'e.g. Kamala';

  @override
  String get staffRole => 'Role';

  @override
  String get staffRoleHouseHelp => 'House help';

  @override
  String get staffRoleCook => 'Cook';

  @override
  String get staffRoleDriver => 'Driver';

  @override
  String get staffRoleNanny => 'Nanny';

  @override
  String get staffRoleGardener => 'Gardener';

  @override
  String get staffPay => 'Pay';

  @override
  String get staffPayPerHour => 'Per hour';

  @override
  String get staffPayPerMonth => 'Per month';

  @override
  String get staffAmount => 'Amount (₹)';

  @override
  String get staffAmountHint => 'e.g. 6000';

  @override
  String get staffUsuallyAt => 'Usually comes at';

  @override
  String get staffMobile => 'Mobile (optional, for WhatsApp)';

  @override
  String get staffPhoneInvalid =>
      'Check the number — 10 digits starting with 6, 7, 8 or 9.';

  @override
  String get staffAddInfo =>
      'Works Mon–Sat by default; change days and pay rules later on their page.';

  @override
  String staffAdded(Object name) {
    return '$name added · mark them in from Today';
  }

  @override
  String get staffIn => 'In';

  @override
  String get staffOut => 'Out';

  @override
  String get staffErrNoIn => 'Add an in-time, or close this sheet.';

  @override
  String get staffErrOutBeforeIn => 'Out time has to be after in time.';

  @override
  String get staffErrTooLong => 'A visit can’t be longer than 16 hours.';

  @override
  String staffOverlap(Object time) {
    return 'This overlaps another visit at $time.';
  }

  @override
  String get staffOnlyAdminsOlder => 'Only admins can change older visits.';

  @override
  String staffVisitTitle(Object name, Object day) {
    return '$name · $day';
  }

  @override
  String get staffVisitLeadSome =>
      'Tapped late or forgot? Fix the time — salary recalculates from this.';

  @override
  String get staffVisitLeadNone =>
      'No visit recorded. Add one, or mark an informed leave so it isn’t counted as absent.';

  @override
  String get staffNow => 'now';

  @override
  String get staffAddVisit => 'Add visit';

  @override
  String get staffEditVisit => 'Edit visit';

  @override
  String get staffRemoveVisit => 'Remove visit';

  @override
  String staffSettledNotice(Object month) {
    return '$month is settled — changes will show as a difference to pay';
  }

  @override
  String get staffVisitUpdated => 'Visit updated · salary recalculated';

  @override
  String get staffVisitRemoved => 'Visit removed';

  @override
  String get staffInformedLeave => 'Informed leave';

  @override
  String get staffUndoLeave => 'Undo leave';

  @override
  String staffLeaveMarked(Object day) {
    return '$day marked as informed leave';
  }

  @override
  String get staffLeaveRemoved => 'Leave removed';

  @override
  String staffCall(Object name) {
    return 'Call $name';
  }

  @override
  String staffWhatsApp(Object name) {
    return 'WhatsApp $name';
  }

  @override
  String get staffEditDetails => 'Edit details';

  @override
  String staffRoleWindow(Object role, Object window) {
    return '$role · $window';
  }

  @override
  String staffPayHourlyLine(Object rate) {
    return '$rate/hour';
  }

  @override
  String staffPayMonthlyLine(Object amount) {
    return '$amount/month';
  }

  @override
  String get staffFormerTag => 'Former house help';

  @override
  String get staffUpi => 'UPI ID (optional)';

  @override
  String get staffWorkDays => 'Work days';

  @override
  String get staffAddTime => 'Add a second time';

  @override
  String get staffDetailsSaved => 'Details saved';

  @override
  String staffMonthAttendance(Object month) {
    return '$month attendance';
  }

  @override
  String get staffPrevMonth => 'Previous month';

  @override
  String get staffNextMonth => 'Next month';

  @override
  String staffCellWorked(Object day, Object duration) {
    return '$day: worked $duration';
  }

  @override
  String staffCellAbsent(Object day) {
    return '$day: absent';
  }

  @override
  String staffCellLeave(Object day) {
    return '$day: informed leave';
  }

  @override
  String staffCellOff(Object day) {
    return '$day: day off';
  }

  @override
  String staffCellUpcoming(Object day) {
    return '$day: upcoming';
  }

  @override
  String staffCellNotMarked(Object day) {
    return '$day: not marked yet';
  }

  @override
  String staffCellBeforeStart(Object day) {
    return '$day: before start';
  }

  @override
  String get staffLegendWorked => 'Worked (stronger = longer)';

  @override
  String get staffLegendAbsent => 'Absent';

  @override
  String get staffLegendLeave => 'Leave';

  @override
  String get staffStatPresent => 'Days present';

  @override
  String get staffStatAbsent => 'Absent';

  @override
  String get staffStatHours => 'Hours';

  @override
  String get staffVisitLog => 'Visit log';

  @override
  String get staffVisitLogHint => 'Tap to fix a time';

  @override
  String staffSalaryButton(Object month) {
    return '$month salary';
  }

  @override
  String staffRemoveButton(Object name) {
    return 'Remove $name from home';
  }

  @override
  String staffRemoveTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String get staffRemoveLead =>
      'They disappear from Today and attendance. Salary already paid stays in Money.';

  @override
  String get commonRemove => 'Remove';

  @override
  String staffRemoved(Object name) {
    return '$name removed';
  }

  @override
  String get staffRestore => 'Restore';

  @override
  String staffRestored(Object name) {
    return '$name restored';
  }

  @override
  String staffFormerCount(int count) {
    return 'Former house help ($count)';
  }
}
