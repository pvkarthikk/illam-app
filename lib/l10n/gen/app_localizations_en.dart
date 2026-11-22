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

  @override
  String salaryTitle(Object name) {
    return '$name’s salary';
  }

  @override
  String salarySubtitleSoFar(Object month, Object day) {
    return '$month 1 – $day · so far';
  }

  @override
  String salarySubtitleProjected(Object month, Object day) {
    return '$month 1 – $day · projected';
  }

  @override
  String salarySubtitlePast(Object month, Object day) {
    return '$month 1 – $day';
  }

  @override
  String get salaryFootnote =>
      'Every number traces back to the visit log. Fix a wrong time there and this updates instantly.';

  @override
  String salaryNotWorking(Object month) {
    return 'Not working in $month';
  }

  @override
  String get salaryNoRules => 'No pay rules yet';

  @override
  String get salaryNoRulesBody =>
      'Set the hourly rate or monthly salary to see what to pay.';

  @override
  String get salarySetRules => 'Set pay rules';

  @override
  String get salaryEyebrowPayable => 'PAYABLE';

  @override
  String get salaryEyebrowPaid => 'PAID';

  @override
  String salaryDaysLine(Object present, Object absent, Object leave) {
    return '$present days present · $absent absent · $leave leave';
  }

  @override
  String salaryCarryPreview(Object amount, Object month) {
    return '₹0 to pay · $amount will carry to $month';
  }

  @override
  String get salaryHoursWorked => 'Hours worked';

  @override
  String salaryHoursDetail(
    Object billed,
    Object rate,
    Object visits,
    Object actual,
    Object rounding,
    Object minimum,
  ) {
    return '$billed billed × $rate/hr · $visits visits · actual $actual. Each visit rounded to $rounding$minimum';
  }

  @override
  String salaryRoundMinutes(Object n) {
    return '$n min';
  }

  @override
  String get salaryRoundTheMinute => 'the minute';

  @override
  String salaryMinimumPart(Object hours) {
    return ', min $hours hr';
  }

  @override
  String get salaryMonthlyLine => 'Monthly salary';

  @override
  String salaryMonthlyDetail(Object workDays, Object perDay) {
    return '$workDays working days · $perDay/day';
  }

  @override
  String get salaryLeavesLine => 'Leaves';

  @override
  String salaryLeavesDetail(Object taken, Object paid, Object unpaid) {
    return '$taken taken · $paid paid · $unpaid unpaid';
  }

  @override
  String get salaryExtraDetail => 'Extra task';

  @override
  String get salaryAdvanceLine => 'Advance taken';

  @override
  String get salaryAdvanceDetail => 'Deducted this month';

  @override
  String get salaryDeductionDetail => 'Deduction';

  @override
  String get salaryToPay => 'To pay';

  @override
  String salaryChipRate(Object rate) {
    return '$rate/hr';
  }

  @override
  String salaryChipMonthly(Object amount) {
    return '$amount/mo';
  }

  @override
  String salaryChipRound(Object n) {
    return 'Round $n min';
  }

  @override
  String get salaryChipExact => 'Exact minutes';

  @override
  String salaryChipPaidLeaves(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n paid leaves',
      one: '1 paid leave',
    );
    return '$_temp0';
  }

  @override
  String get salaryEditRules => 'Edit pay rules';

  @override
  String get salaryAdminsSetRules => 'Admins set pay rules';

  @override
  String get salaryPrevMonth => 'Previous month';

  @override
  String get salaryNextMonth => 'Next month';

  @override
  String salaryMarkPaidButton(Object amount) {
    return 'Mark $amount as paid';
  }

  @override
  String salaryCloseAtZero(Object month) {
    return 'Close $month at ₹0';
  }

  @override
  String salaryClosedSnack(Object month) {
    return '$month closed at ₹0';
  }

  @override
  String salaryCarryNote(Object month) {
    return 'Carried from $month';
  }

  @override
  String salaryMemberNote(Object names) {
    return 'Only admins pay salary. Ask $names — you’ll see it here once paid.';
  }

  @override
  String get salaryYou => 'you';

  @override
  String salaryNamesOr(Object first, Object second) {
    return '$first or $second';
  }

  @override
  String salaryPaidTag(Object amount, Object date, Object method) {
    return 'Paid $amount on $date · $method';
  }

  @override
  String salaryClosedTag(Object date) {
    return 'Closed at ₹0 on $date';
  }

  @override
  String get salaryUndoPayment => 'Undo payment';

  @override
  String get salaryUndoTitle => 'Undo payment?';

  @override
  String salaryUndoLead(Object amount, Object month) {
    return 'The $amount salary spend is removed and $month can be paid again.';
  }

  @override
  String get salaryUndoneSnack => 'Payment undone';

  @override
  String get salaryMethodUpi => 'UPI';

  @override
  String get salaryMethodCash => 'Cash';

  @override
  String get salaryMethodBank => 'Bank';

  @override
  String salaryDuplicateAlert(
    Object name,
    Object month,
    Object a,
    Object x,
    Object b,
    Object y,
  ) {
    return '$name’s $month salary was marked paid twice ($a by $x, $b by $y). The first is kept — check you didn’t pay twice.';
  }

  @override
  String get salaryUndoSecond => 'Undo the second payment';

  @override
  String salaryDifferenceAlert(Object x, Object y, Object z) {
    return 'Recalculated $x — settled at $y. Difference $z';
  }

  @override
  String salaryAddToMonth(Object month) {
    return 'Add to $month';
  }

  @override
  String salaryDifferenceNote(Object month) {
    return 'Difference from $month';
  }

  @override
  String salaryDifferenceSnack(Object month) {
    return 'Difference added to $month';
  }

  @override
  String salarySharePaySlip(Object name) {
    return 'Share pay slip with $name';
  }

  @override
  String salaryRulesTitle(Object name) {
    return '$name’s pay rules';
  }

  @override
  String get salaryRulesLead =>
      'Agreed once, applied every month. Shown on the pay slip so there are no surprises.';

  @override
  String get salaryPayType => 'Pay type';

  @override
  String get salaryHourly => 'Hourly';

  @override
  String get salaryMonthly => 'Monthly';

  @override
  String get salaryRatePerHour => 'Rate per hour (₹)';

  @override
  String get salaryRoundTo => 'Round each visit to';

  @override
  String get salaryRoundExactMinute => 'Exact minute';

  @override
  String get salaryRound15 => '15 min';

  @override
  String get salaryRound30 => '30 min';

  @override
  String get salaryMinimum => 'Minimum per visit';

  @override
  String get salaryMinNone => 'None';

  @override
  String get salaryMin1 => '1 hour';

  @override
  String get salaryMin2 => '2 hours';

  @override
  String get salaryMonthlyAmount => 'Monthly salary (₹)';

  @override
  String get salaryPaidLeaves => 'Paid leaves per month';

  @override
  String get salaryWorkDays => 'Work days';

  @override
  String get salaryDayMon => 'Mon';

  @override
  String get salaryDayTue => 'Tue';

  @override
  String get salaryDayWed => 'Wed';

  @override
  String get salaryDayThu => 'Thu';

  @override
  String get salaryDayFri => 'Fri';

  @override
  String get salaryDaySat => 'Sat';

  @override
  String get salaryDaySun => 'Sun';

  @override
  String get salaryApplyFrom => 'Apply from';

  @override
  String get salaryThisMonth => 'This month';

  @override
  String get salaryNextMonthChip => 'Next month';

  @override
  String get salarySaveRules => 'Save rules';

  @override
  String get salaryRulesSaved => 'Pay rules saved · salary recalculated';

  @override
  String get salaryCheckAmount => 'Check the amount';

  @override
  String salaryAdjustmentsFor(Object month) {
    return 'Adjustments for $month';
  }

  @override
  String get salaryAddExtra => '+ Add extra';

  @override
  String get salaryAddAdvance => '+ Add advance';

  @override
  String get salaryAddDeduction => '+ Add deduction';

  @override
  String get salaryAdjNote => 'Note';

  @override
  String get salaryAdjAmount => 'Amount (₹)';

  @override
  String get salaryAdjSave => 'Save';

  @override
  String get salaryAdjRemove => 'Remove';

  @override
  String get salaryAdjAdded => 'Adjustment added · salary recalculated';

  @override
  String get salaryAdjRemoved => 'Adjustment removed';

  @override
  String salaryAdjLocked(Object month) {
    return '$month is settled — adjustments are locked.';
  }

  @override
  String get salaryKindExtra => 'Extra';

  @override
  String get salaryKindAdvance => 'Advance';

  @override
  String get salaryKindDeduction => 'Deduction';

  @override
  String salaryMarkPaidTitle(Object amount) {
    return 'Mark $amount as paid?';
  }

  @override
  String get salaryPaidWith => 'Paid with';

  @override
  String get salaryMarkPaidConfirm => 'Mark paid';

  @override
  String salaryPaidSnack(Object amount, Object name) {
    return '$amount paid to $name · added to spends';
  }

  @override
  String salaryExpenseMerchant(Object name, Object month) {
    return '$name — $month salary';
  }

  @override
  String salarySlipHeader(Object month, Object name) {
    return '$month pay — $name';
  }

  @override
  String salarySlipDaysHours(Object present, Object billed) {
    return 'Days: $present · Hours: $billed';
  }

  @override
  String salarySlipHoursCalc(Object billed, Object rate, Object gross) {
    return '$billed × $rate = $gross';
  }

  @override
  String salarySlipExtra(Object label, Object amount) {
    return '+ $label: $amount';
  }

  @override
  String salarySlipAdvance(Object amount) {
    return '− Advance: $amount';
  }

  @override
  String salarySlipDeduction(Object label, Object amount) {
    return '− $label: $amount';
  }

  @override
  String salarySlipSalary(Object amount) {
    return 'Salary: $amount';
  }

  @override
  String salarySlipLeaves(Object taken, Object paid) {
    return 'Leaves: $taken ($paid paid)';
  }

  @override
  String salarySlipTotal(Object amount) {
    return 'Total: $amount';
  }

  @override
  String get salarySlipTitle => 'Pay slip';

  @override
  String get salarySlipLead =>
      'A clear breakdown builds trust and ends “how did you calculate?” conversations.';

  @override
  String get salarySlipSend => 'Send on WhatsApp';

  @override
  String salaryRuleHourlyRounded(Object rate, Object n) {
    return '$rate/hour · rounded to $n min';
  }

  @override
  String salaryRuleHourlyExact(Object rate) {
    return '$rate/hour · exact minutes';
  }

  @override
  String salaryRuleMonthly(Object amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n paid leaves',
      one: '1 paid leave',
    );
    return '$amount/month · $_temp0';
  }

  @override
  String salaryStaffButton(Object month, Object amount) {
    return '$month salary · $amount';
  }

  @override
  String get listsChannelZepto => 'Zepto';

  @override
  String get listsChannelBlinkit => 'Blinkit';

  @override
  String get listsChannelBigbasket => 'BigBasket';

  @override
  String get listsChannelAmazon => 'Amazon';

  @override
  String get listsChannelFlipkart => 'Flipkart';

  @override
  String get listsChannelMeesho => 'Meesho';

  @override
  String get listsChannelOffline => 'Offline';

  @override
  String get listsEtaZepto => '~10 min';

  @override
  String get listsEtaBlinkit => '~10 min';

  @override
  String get listsEtaBigbasket => 'Tomorrow 7–9 AM';

  @override
  String get listsEtaAmazon => '1–2 days';

  @override
  String get listsEtaFlipkart => '2–3 days';

  @override
  String get listsEtaMeesho => '4–6 days';

  @override
  String get listsEtaOffline => 'Local store / D-Mart';

  @override
  String get listsEyebrow => 'BUY';

  @override
  String get listsTitle => 'Lists';

  @override
  String get listsStoreMode => 'Store mode';

  @override
  String get listsGrocery => 'Grocery';

  @override
  String get listsShopping => 'Shopping';

  @override
  String get listsPlaceholderGrocery => 'Add “Milk 2L”, “Onions 1kg”…';

  @override
  String get listsPlaceholderShopping => 'Add “Phone charger”…';

  @override
  String listsStoreButton(Object store) {
    return 'Buy from $store. Change';
  }

  @override
  String get listsAddTooltip => 'Add';

  @override
  String get listsHintIdle => 'Tip: quantities are understood — “Rice 5kg”.';

  @override
  String listsHint(Object item, Object store, Object usual) {
    return '$item → $store$usual';
  }

  @override
  String listsHintItemQty(Object name, Object qty) {
    return '$name · $qty';
  }

  @override
  String get listsHintUsual => ' (where you usually buy it)';

  @override
  String listsAdded(Object name, Object store) {
    return 'Added $name → $store';
  }

  @override
  String listsMerged(Object name, Object qty) {
    return '$name was already on the list — now $qty';
  }

  @override
  String listsAlready(Object name, Object qty) {
    return '$name is already on the list ($qty)';
  }

  @override
  String get listsPickerTitle => 'Where will you buy it?';

  @override
  String get listsPickerLead =>
      'New items go here. Items you’ve bought before go to their usual store automatically.';

  @override
  String get listsAll => 'All';

  @override
  String listsToBuy(int n, Object eta) {
    return '$n to buy · $eta';
  }

  @override
  String get listsOrder => 'Order';

  @override
  String get listsShop => 'Shop';

  @override
  String listsGotSemantics(Object name) {
    return 'Got $name';
  }

  @override
  String get listsLess => 'Less';

  @override
  String get listsMore => 'More';

  @override
  String get listsCheckQty => 'Check quantity';

  @override
  String listsGot(Object name) {
    return 'Got $name';
  }

  @override
  String listsAllBought(Object store) {
    return 'All bought from $store.';
  }

  @override
  String listsGotFooter(Object names) {
    return 'Got: $names';
  }

  @override
  String get listsClear => 'Clear';

  @override
  String listsCleared(int n) {
    return 'Cleared $n · they’re in Buy again';
  }

  @override
  String listsItemLead(Object qty, Object category, String list) {
    String _temp0 = intl.Intl.selectLogic(list, {
      'grocery': 'grocery',
      'other': 'shopping',
    });
    return '$qty · $category · on $_temp0 list';
  }

  @override
  String get listsName => 'Name';

  @override
  String get listsQuantity => 'Quantity';

  @override
  String get listsUnit => 'Unit';

  @override
  String get listsCategory => 'Category';

  @override
  String get listsMoveTo => 'Move to';

  @override
  String get listsRemove => 'Remove';

  @override
  String get listsRemoved => 'Removed';

  @override
  String get listsSave => 'Save';

  @override
  String get listsSaved => 'Saved';

  @override
  String listsMoved(Object name, Object store) {
    return '$name → $store. We’ll remember that.';
  }

  @override
  String listsMergeAsk(Object name, Object qty) {
    return 'Merge with $name ($qty)?';
  }

  @override
  String get listsMerge => 'Merge';

  @override
  String get listsCancel => 'Cancel';

  @override
  String get listsBuyAgain => 'Buy again';

  @override
  String listsBuyAgainChip(Object name) {
    return '+ $name';
  }

  @override
  String get todayReadyToOrder => 'Ready to order';

  @override
  String get todayListsLink => 'Lists';

  @override
  String todayPillCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get todayStoreRun => 'store run';

  @override
  String get storeTitle => 'Store mode';

  @override
  String get storeBack => 'Back';

  @override
  String storeProgress(int done, int total) {
    return '$done of $total picked · screen stays on';
  }

  @override
  String get storeEmptyTitle => 'Nothing to buy offline';

  @override
  String get storeEmptyBody => 'Move items here from any list.';

  @override
  String get storeDoneLogBill => 'Done · log the bill';

  @override
  String get storeLogTitle => 'Log this bill';

  @override
  String get storeLogLead => 'Keeps offline shopping in your monthly spends.';

  @override
  String get storeBillAmount => 'Bill amount (₹)';

  @override
  String get storeStore => 'Store';

  @override
  String get storeDMart => 'D-Mart';

  @override
  String get storeKirana => 'Kirana';

  @override
  String get storeSabzi => 'Sabzi market';

  @override
  String get storeReliance => 'Reliance Fresh';

  @override
  String get storeOther => 'Other…';

  @override
  String get storeOtherName => 'Store name';

  @override
  String get storePaidWith => 'Paid with';

  @override
  String get storeCash => 'Cash';

  @override
  String get storeUpi => 'UPI';

  @override
  String get storeCard => 'Card';

  @override
  String get storeSkip => 'Skip';

  @override
  String get storeSave => 'Save';

  @override
  String get storeCheckAmount => 'Check the amount';

  @override
  String get storeNameRequired => 'Which store was it?';

  @override
  String storeLogged(Object amount, Object store) {
    return '$amount at $store logged';
  }

  @override
  String get storeTripDone => 'Trip done · picked items cleared';

  @override
  String storeOpenFailed(Object store) {
    return 'Couldn’t open $store. The list is copied — paste it in the app.';
  }

  @override
  String storeBackFrom(Object store) {
    return 'Back from $store?';
  }

  @override
  String storeBackLead(Object store) {
    return 'We copied the list and opened $store. Shown when you return to Nest Mojo : Flat, so the list stays honest.';
  }

  @override
  String storeUnitChanged(Object qty) {
    return 'now $qty — tick to mark all as ordered';
  }

  @override
  String get storeNotYet => 'Not yet';

  @override
  String get storeOrderedAll => 'Ordered all';

  @override
  String storeOrderedN(int n) {
    return 'Ordered $n';
  }

  @override
  String storeOrderedNote(Object qty, Object store) {
    return '$qty ordered on $store';
  }

  @override
  String get storeMarkedOrdered => 'Marked ordered';

  @override
  String storeOrderedOn(Object store) {
    return 'Ordered on $store ✓';
  }

  @override
  String get storeHowMuch =>
      'How much was it? Add it now so this month’s total stays right.';

  @override
  String get storeAmount => 'Amount (₹)';

  @override
  String get storeCashOnDelivery => 'Cash on delivery';

  @override
  String get storeAddLater => 'Add later';

  @override
  String storeOrderAdded(Object amount, Object store) {
    return '$amount $store order added';
  }
}
