// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Illam';

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
  String get errCantSecure => 'Illam can’t secure data on this phone';

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
      'Someone at home already uses Illam. Scan their QR code or type their phrase.';

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
    return 'We copied the list and opened $store. Shown when you return to Illam, so the list stays honest.';
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

  @override
  String get tasksYou => 'You';

  @override
  String get tasksEyebrow => 'KEEP THE HOUSE';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksCleaningTab => 'Cleaning';

  @override
  String get tasksTodosTab => 'To-dos';

  @override
  String get tasksEveryone => 'Everyone';

  @override
  String tasksOverdue(int n) {
    return 'Overdue ${n}d';
  }

  @override
  String get tasksDueToday => 'Due today';

  @override
  String get tasksDueTomorrow => 'Due tomorrow';

  @override
  String tasksInDays(int n) {
    return 'In $n days';
  }

  @override
  String get tasksFreqDaily => 'Daily';

  @override
  String get tasksFreqWeekly => 'Weekly';

  @override
  String get tasksFreqFortnightly => 'Fortnightly';

  @override
  String get tasksFreqMonthly => 'Monthly';

  @override
  String get tasksFreqEvery3Months => 'Every 3 months';

  @override
  String tasksFreqEveryN(int n) {
    return 'Every $n days';
  }

  @override
  String tasksRoutineMeta(Object who, Object room, Object freq) {
    return '$who · $room · $freq';
  }

  @override
  String get tasksFreshness => 'Freshness';

  @override
  String get tasksDone => 'Done';

  @override
  String tasksMarkDone(Object name) {
    return 'Mark $name done';
  }

  @override
  String tasksRoutineDone(Object name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n days',
      one: 'tomorrow',
    );
    return '$name done · next $_temp0';
  }

  @override
  String get tasksNoRoutines => 'No routines here';

  @override
  String tasksNoRoutinesBody(Object who) {
    return 'Assign one to $who.';
  }

  @override
  String get tasksAnyone => 'anyone';

  @override
  String get tasksNewRoutine => 'New cleaning routine';

  @override
  String get tasksNewRoutineTitle => 'New cleaning routine';

  @override
  String get tasksRoutineLead =>
      'It comes back on its own — no need to re-add it.';

  @override
  String get tasksWhatNeedsDoing => 'What needs doing?';

  @override
  String get tasksRoutinePlaceholder => 'e.g. Clean kitchen chimney';

  @override
  String get tasksNameRequired => 'Add what needs doing.';

  @override
  String get tasksWhere => 'Where';

  @override
  String get tasksRoomKitchen => 'Kitchen';

  @override
  String get tasksRoomLiving => 'Living room';

  @override
  String get tasksRoomBedrooms => 'Bedrooms';

  @override
  String get tasksRoomBathrooms => 'Bathrooms';

  @override
  String get tasksRoomBalcony => 'Balcony';

  @override
  String get tasksRoomWhole => 'Whole house';

  @override
  String get tasksOther => 'Other…';

  @override
  String get tasksRoomName => 'Room';

  @override
  String get tasksHowOften => 'How often';

  @override
  String get tasksEvery2 => 'Every 2 days';

  @override
  String get tasksEvery3 => 'Every 3 days';

  @override
  String get tasksCustom => 'Custom…';

  @override
  String get tasksEveryHowMany => 'Every how many days?';

  @override
  String get tasksDaysRange => 'Enter 1 to 365 days.';

  @override
  String get tasksWhoDoesIt => 'Who does it';

  @override
  String get tasksAddRoutine => 'Add routine';

  @override
  String get tasksRoutineAdded => 'Routine added · first one is due today';

  @override
  String get tasksEditRoutineTitle => 'Edit routine';

  @override
  String get tasksSaveChanges => 'Save changes';

  @override
  String get tasksRoutineUpdated => 'Routine updated';

  @override
  String get tasksDeleteRoutine => 'Delete routine';

  @override
  String get tasksRoutineDeleted => 'Routine deleted';

  @override
  String get tasksGroupOverdue => 'Overdue';

  @override
  String get tasksGroupToday => 'Today';

  @override
  String get tasksGroupTomorrow => 'Tomorrow';

  @override
  String get tasksGroupLater => 'Later';

  @override
  String tasksTodoMeta(Object day, Object who) {
    return '$day · $who';
  }

  @override
  String tasksCompleteTodo(Object title) {
    return 'Complete “$title”';
  }

  @override
  String tasksTodoDone(Object title) {
    return 'Done: $title';
  }

  @override
  String get tasksAllDone => 'All done';

  @override
  String get tasksNothingPending => 'Nothing pending.';

  @override
  String tasksNothingPendingFor(Object name) {
    return 'Nothing pending for $name.';
  }

  @override
  String tasksCompleted(int n) {
    return 'Completed ($n)';
  }

  @override
  String tasksReopenTodo(Object title) {
    return 'Reopen “$title”';
  }

  @override
  String get tasksMovedBack => 'Moved back to open';

  @override
  String get tasksNewTodo => 'New to-do';

  @override
  String get tasksEditTodo => 'Edit to-do';

  @override
  String get tasksWhat => 'What';

  @override
  String get tasksTodoPlaceholder => 'e.g. Book AC service';

  @override
  String get tasksTodoRequired => 'Add what needs doing.';

  @override
  String get tasksWhen => 'When';

  @override
  String get tasksToday => 'Today';

  @override
  String get tasksTomorrow => 'Tomorrow';

  @override
  String get tasksWeekend => 'Weekend';

  @override
  String get tasksNextWeek => 'Next week';

  @override
  String get tasksPickDate => 'Pick date…';

  @override
  String get tasksWho => 'Who';

  @override
  String get tasksAddTodo => 'Add to-do';

  @override
  String get tasksTodoAdded => 'To-do added';

  @override
  String get tasksTodoUpdated => 'To-do updated';

  @override
  String get tasksDeleteTodo => 'Delete to-do';

  @override
  String get tasksTodoDeleted => 'To-do deleted';

  @override
  String tasksSendList(Object name) {
    return 'Send $name today’s list';
  }

  @override
  String tasksJobs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jobs',
      one: '1 job',
    );
    return '$_temp0 · they don’t need the app';
  }

  @override
  String get tasksPreview => 'Preview';

  @override
  String tasksListFor(Object name) {
    return '$name’s list for today';
  }

  @override
  String get tasksShareLead =>
      'Sent as a WhatsApp message in their language. They don’t need the app.';

  @override
  String get tasksLanguage => 'Language';

  @override
  String get tasksLangEnglish => 'English';

  @override
  String get tasksLangHindi => 'हिंदी';

  @override
  String get tasksLangTamil => 'தமிழ்';

  @override
  String get tasksCopy => 'Copy';

  @override
  String get tasksCopied => 'Copied — paste it in any chat';

  @override
  String get tasksWhatsApp => 'WhatsApp';

  @override
  String get todayDueToday => 'Due today';

  @override
  String get todayAllTasks => 'All tasks';

  @override
  String get todayTodoKind => 'To-do';

  @override
  String todayMoreDue(int n) {
    return '+ $n more due';
  }

  @override
  String get todayNothingDue => 'Nothing due';

  @override
  String get todayEnjoyQuiet => 'Enjoy the quiet.';

  @override
  String get tasksRemoveStaffMoves =>
      'Their routines and open to-dos will move to you.';

  @override
  String get moneyEyebrow => 'Household spends';

  @override
  String get moneyTitle => 'Money';

  @override
  String moneySpentIn(Object month) {
    return 'Spent in $month';
  }

  @override
  String moneyLeftOf(Object left, Object budget) {
    return '$left left of $budget';
  }

  @override
  String moneyDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String moneyBelowPrev(Object amount, Object month) {
    return '$amount below $month’s total';
  }

  @override
  String moneyAbovePrev(Object amount, Object month) {
    return '$amount above $month’s total';
  }

  @override
  String moneyOverBudget(Object amount) {
    return '$amount over budget';
  }

  @override
  String get moneySetBudget => 'Set a monthly budget';

  @override
  String get moneyNoBudget => 'No budget set';

  @override
  String get moneyBudgetTitle => 'Monthly budget';

  @override
  String get moneyBudgetSaved => 'Budget saved';

  @override
  String get moneySave => 'Save';

  @override
  String get moneyAddSpend => '＋ Add a spend';

  @override
  String get moneyQuickAddHint =>
      'Or type “₹450 Swiggy” in Quick add from any tab.';

  @override
  String get moneyBills => 'Bills this month';

  @override
  String moneyBillsPaid(int k, int n) {
    return '$k of $n paid';
  }

  @override
  String get moneyAddBill => '＋ Add bill';

  @override
  String moneyBillDue(Object date, Object amount) {
    return 'Due $date · $amount last time';
  }

  @override
  String get moneyOverdue => 'Overdue';

  @override
  String get moneyToday => 'Today';

  @override
  String get moneyPaid => 'Paid';

  @override
  String moneyBillPaidOn(Object date, Object method) {
    return 'Paid $date · $method';
  }

  @override
  String get moneyPaidTwice => 'Marked paid twice — check';

  @override
  String moneyFirstDue(Object date, Object amount) {
    return 'First due $date · $amount';
  }

  @override
  String moneyMarkBillPaid(Object bill) {
    return 'Mark $bill paid';
  }

  @override
  String get moneyBillsEmpty =>
      'Add rent, electricity, milk, internet… — we’ll remind you when they’re due.';

  @override
  String moneyStoppedBills(int count) {
    return 'Stopped bills ($count)';
  }

  @override
  String moneyStoppedRow(Object amount, int day) {
    return '$amount · day $day';
  }

  @override
  String get moneyTrackAgain => 'Track again';

  @override
  String moneyTrackingAgain(Object bill) {
    return 'Tracking $bill again';
  }

  @override
  String get moneyMethodUpi => 'UPI';

  @override
  String get moneyMethodCash => 'Cash';

  @override
  String get moneyMethodCard => 'Card';

  @override
  String get moneyMethodBank => 'Bank';

  @override
  String get moneyErrAmount => 'Check the amount';

  @override
  String get moneyWhereItWent => 'Where it went';

  @override
  String moneyStaffPay(Object month) {
    return 'Staff pay · $month';
  }

  @override
  String moneyBilledRate(Object billed, Object rate) {
    return '$billed billed · $rate/hr';
  }

  @override
  String moneyMonthlyLeaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Monthly · $count leaves',
      one: 'Monthly · 1 leave',
    );
    return '$_temp0';
  }

  @override
  String get moneyRecent => 'Recent';

  @override
  String get moneySeeAll => 'See all';

  @override
  String moneyRowSub(Object day, Object category, Object source) {
    return '$day · $category · $source';
  }

  @override
  String moneySrcManual(Object name) {
    return 'Added by $name';
  }

  @override
  String get moneySrcYou => 'Added by you';

  @override
  String moneySrcOrder(Object channel) {
    return '$channel order';
  }

  @override
  String get moneySrcStore => 'Store bill';

  @override
  String get moneySrcBill => 'Bill';

  @override
  String get moneySrcSalary => 'Salary';

  @override
  String get moneyEmptyTitle => 'No spends yet this month';

  @override
  String get moneyEmptyBody => 'Tap “＋ Add a spend”, or mark a bill paid.';

  @override
  String get moneyAddSpendTitle => 'Add a spend';

  @override
  String get moneyEditSpendTitle => 'Edit spend';

  @override
  String get moneyAmountLabel => 'Amount in rupees';

  @override
  String get moneyPaidTo => 'Paid to / for';

  @override
  String get moneyCategory => 'Category';

  @override
  String get moneyPaidWith => 'Paid with';

  @override
  String get moneyWhen => 'When';

  @override
  String get moneyYesterday => 'Yesterday';

  @override
  String get moneyOtherDay => 'Other day';

  @override
  String get moneyMore => 'More';

  @override
  String get moneyPaidBy => 'Paid by';

  @override
  String get moneyYou => 'You';

  @override
  String get moneyNote => 'Note';

  @override
  String get moneyRepeat => 'Repeat every month — makes it a bill';

  @override
  String get moneySaveChanges => 'Save changes';

  @override
  String get moneyDelete => 'Delete';

  @override
  String moneyAdded(Object amount) {
    return '$amount added';
  }

  @override
  String moneyAddedBill(Object amount, Object merchant) {
    return '$amount added · $merchant is now a monthly bill';
  }

  @override
  String moneyLearned(Object merchant, Object category) {
    return 'Saved · $merchant will go to $category from now on.';
  }

  @override
  String get moneySpendUpdated => 'Spend updated';

  @override
  String get moneySpendDeleted => 'Spend deleted';

  @override
  String get moneyErrMerchant => 'Who was it paid to?';

  @override
  String moneyReadOnly(Object name) {
    return 'Added by $name · only $name or an admin can change it.';
  }

  @override
  String moneySalaryManaged(Object name) {
    return 'Salary spends are managed in $name’s salary.';
  }

  @override
  String get moneyOpenSalary => 'Open salary';

  @override
  String moneyDuplicate(
    Object who,
    Object amount,
    Object merchant,
    Object when,
  ) {
    return 'Looks like $who already added $amount · $merchant $when.';
  }

  @override
  String get moneyWhoYou => 'you';

  @override
  String get moneyWhenToday => 'today';

  @override
  String get moneyWhenYesterday => 'yesterday';

  @override
  String moneyWhenOn(Object day) {
    return 'on $day';
  }

  @override
  String get moneyAddAnyway => 'Add anyway';

  @override
  String get moneyDontAdd => 'Don’t add';

  @override
  String get moneyCashSpend => 'Cash spend';

  @override
  String moneyOrdinal(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': '1st',
      '2': '2nd',
      '3': '3rd',
      '21': '21st',
      '22': '22nd',
      '23': '23rd',
      '31': '31st',
      'other': '${n}th',
    });
    return '$_temp0';
  }

  @override
  String get moneyAddBillTitle => 'Add a bill';

  @override
  String get moneyEditBillTitle => 'Edit bill';

  @override
  String get moneyBillName => 'Name';

  @override
  String get moneyUsualAmount => 'Usual amount (₹)';

  @override
  String get moneyDueDay => 'Due day';

  @override
  String moneyDueHelper(Object nth) {
    return 'Paid around the $nth each month';
  }

  @override
  String get moneyRemind => 'Remind me on the due day';

  @override
  String get moneyBillErrName => 'Add the bill’s name.';

  @override
  String get moneyBillErrDay => 'Pick a day from 1 to 31.';

  @override
  String moneyBillAdded(Object bill) {
    return '$bill added';
  }

  @override
  String get moneyBillSaved => 'Bill saved';

  @override
  String get moneyStopTracking => 'Stop tracking this bill';

  @override
  String moneyStopped(Object bill) {
    return 'Stopped tracking $bill';
  }

  @override
  String get moneyDeleteBill => 'Delete bill';

  @override
  String moneyDeleteBillTitle(Object bill) {
    return 'Delete $bill?';
  }

  @override
  String get moneyDeleteBillLead => 'Past spends keep their “Bill” label.';

  @override
  String get moneyKeep => 'Keep';

  @override
  String moneyBillDeleted(Object bill) {
    return '$bill deleted';
  }

  @override
  String moneyPaidTitle(Object bill) {
    return '$bill — paid?';
  }

  @override
  String moneyPaidLead(Object amount, Object nth) {
    return 'Usually $amount around the $nth.';
  }

  @override
  String moneyForMonth(Object month) {
    return 'For $month';
  }

  @override
  String get moneyMarkPaid => 'Mark paid';

  @override
  String moneyBillPaidSnack(Object bill, Object amount) {
    return '$bill paid · $amount added';
  }

  @override
  String get moneyAllSpends => 'All spends';

  @override
  String get moneySearch => 'Search spends';

  @override
  String moneyCount(int count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spends · $total',
      one: '1 spend · $total',
    );
    return '$_temp0';
  }

  @override
  String get moneyNoMatch => 'No spends match.';

  @override
  String moneyClearFilter(Object category) {
    return 'Remove filter $category';
  }

  @override
  String todayMonthSoFar(Object month) {
    return '$month so far';
  }

  @override
  String get todayMoneyLink => 'Money';

  @override
  String todayOfBudget(Object budget, int pct) {
    return 'of $budget budget · $pct% used';
  }

  @override
  String todayBillsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills due',
      one: '1 bill due',
    );
    return '$_temp0';
  }

  @override
  String todaySpentSoFar(Object amount) {
    return '$amount spent so far';
  }

  @override
  String get todaySetBudget => 'Set budget';

  @override
  String get recipeAPinch => 'a pinch';

  @override
  String get onboardingAddStarterRecipes => 'Add 9 popular recipes';

  @override
  String get mealsTitle => 'Meals';

  @override
  String mealsWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get mealsPrevWeek => 'Previous week';

  @override
  String get mealsNextWeek => 'Next week';

  @override
  String get mealsThisWeek => 'This week';

  @override
  String mealsDaySemantics(String weekday, String date, int count) {
    return '$weekday $date, $count of 3 meals planned';
  }

  @override
  String mealsMissingWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients missing for the rest of the week',
      one: '1 ingredient missing for the rest of the week',
    );
    return '$_temp0';
  }

  @override
  String get mealsAddAll => 'Add all';

  @override
  String get mealsPastDay => 'Past day';

  @override
  String mealsSlotTitle(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'other': 'Dinner',
    });
    return '$_temp0';
  }

  @override
  String mealsSlotLower(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'breakfast',
      'lunch': 'lunch',
      'other': 'dinner',
    });
    return '$_temp0';
  }

  @override
  String mealsPlanSlot(String slot) {
    return 'Plan $slot';
  }

  @override
  String mealsChangeSlot(String slot) {
    return 'Change $slot';
  }

  @override
  String get mealsPickFromBook => 'Pick from your recipe book';

  @override
  String mealsMinutes(int min) {
    return '$min min';
  }

  @override
  String get mealsReadyToCook => 'ready to cook';

  @override
  String mealsMissingCount(int count) {
    return '$count missing';
  }

  @override
  String get mealsEatingOut => 'Eating out';

  @override
  String get mealsLeftovers => 'Leftovers';

  @override
  String mealsRemoved(String name) {
    return '$name (removed)';
  }

  @override
  String get mealsRecipeBook => 'Recipe book';

  @override
  String get mealsAdd => 'Add';

  @override
  String mealsCardMeta(int min, String tag) {
    return '$min min · $tag';
  }

  @override
  String get mealsEmptyTitle => 'No recipes yet';

  @override
  String get mealsEmptyBody => 'Add your first, or add the 9 popular ones.';

  @override
  String get mealsAddStarter => 'Add 9 popular recipes';

  @override
  String get mealsTypeRecipe => 'Type a recipe';

  @override
  String mealsStarterAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count recipes',
      one: 'Added 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String mealsPickerTitle(String slot, String day) {
    return '$slot · $day';
  }

  @override
  String mealsPickerLead(String slot) {
    return 'Suggested for $slot first. Missing ingredients flow into your grocery list.';
  }

  @override
  String get mealsOptEatingOut => '🍽 Eating out';

  @override
  String get mealsOptLeftovers => '♻ Leftovers';

  @override
  String get mealsOptNote => '✎ Note…';

  @override
  String get mealsNoteHint => 'e.g. Dosa from Amma';

  @override
  String get mealsNoteSave => 'Save note';

  @override
  String get mealsSearchRecipes => 'Search recipes';

  @override
  String mealsClearSlot(String slot) {
    return 'Clear $slot';
  }

  @override
  String mealsPlanned(String dish) {
    return '$dish planned';
  }

  @override
  String mealsPlannedMissing(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients missing',
      one: '1 ingredient missing',
    );
    return '$dish planned · $_temp0';
  }

  @override
  String mealsPlannedKind(String slot, String what) {
    return '$slot · $what';
  }

  @override
  String get mealsSlotCleared => 'Slot cleared';

  @override
  String get mealsReviewTitle => 'Add to Grocery';

  @override
  String get mealsReviewLead =>
      'Untick anything you already have — we’ll remember it.';

  @override
  String mealsReviewAdd(int count) {
    return 'Add $count';
  }

  @override
  String mealsAddedToGrocery(int count) {
    return 'Added $count to Grocery';
  }

  @override
  String get recipeTitle => 'Recipe';

  @override
  String get recipeAddToPlan => 'Add to meal plan';

  @override
  String get recipeMoreOptions => 'More options';

  @override
  String get recipeEdit => 'Edit';

  @override
  String get recipeDelete => 'Delete';

  @override
  String recipeServes(int n) {
    return 'Serves $n';
  }

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeServings => 'Servings';

  @override
  String recipePpl(int n) {
    return '$n ppl';
  }

  @override
  String get recipeFewer => 'Fewer servings';

  @override
  String get recipeMoreServings => 'More servings';

  @override
  String get recipeInKitchen => 'In kitchen';

  @override
  String get recipeOnList => 'On list';

  @override
  String get recipeMissing => 'Missing';

  @override
  String get recipeSrHave => 'in kitchen';

  @override
  String get recipeSrOnList => 'already on grocery list';

  @override
  String get recipeSrMissing => 'missing';

  @override
  String recipeMarkedHave(String name) {
    return '$name marked as in kitchen';
  }

  @override
  String recipeMarkedMissing(String name) {
    return '$name marked as missing';
  }

  @override
  String recipeAddMissing(int count) {
    return '🛒 Add $count missing to Grocery';
  }

  @override
  String get recipeAllThere => '✓ Everything is in the kitchen or on the list';

  @override
  String get recipeMethod => 'Method';

  @override
  String get recipeStartCook => '🔥 Start cook mode';

  @override
  String recipePlanTitle(String dish) {
    return 'Plan $dish';
  }

  @override
  String get recipePlanDay => 'Day';

  @override
  String get recipePlanMeal => 'Meal';

  @override
  String get recipePlanAdd => 'Add to plan';

  @override
  String recipePlannedFor(String day, String slot) {
    return 'Planned for $day $slot';
  }

  @override
  String recipeDeletePlanned(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$dish is planned on $_temp0. Remove it from those days too?';
  }

  @override
  String get recipeKeepPlans => 'Keep on those days';

  @override
  String get recipeRemoveToo => 'Remove too';

  @override
  String get recipeDeleted => 'Recipe deleted';

  @override
  String get recipeAddTitle => 'Add a recipe';

  @override
  String get recipeAddLead =>
      'Pick the fastest way in — you can tidy it later.';

  @override
  String get recipeTypeIt => 'Type it';

  @override
  String get recipeTypeItSub => 'Name, ingredients, steps';

  @override
  String get recipePasteLink => 'Paste a link';

  @override
  String get recipePasteLinkSub =>
      'YouTube, Instagram or a blog — ingredients are pulled out for you';

  @override
  String get recipeSnap => 'Snap a page';

  @override
  String get recipeSnapSub => 'Photo of a cookbook or a handwritten card';

  @override
  String get recipeComingSoon => 'Coming soon';

  @override
  String get recipeFormNew => 'New recipe';

  @override
  String get recipeFormEdit => 'Edit recipe';

  @override
  String get recipeFieldName => 'Name';

  @override
  String get recipeFieldTime => 'Time in minutes';

  @override
  String get recipeFieldServes => 'Serves';

  @override
  String get recipeFieldMealType => 'Meal type';

  @override
  String get recipeFieldTags => 'Tags';

  @override
  String get recipeTagsHint => 'e.g. Quick, Kids like';

  @override
  String get recipeFieldIngredients => 'Ingredients';

  @override
  String get recipeIngName => 'Ingredient';

  @override
  String get recipeIngQty => 'Qty';

  @override
  String get recipeIngUnit => 'Unit';

  @override
  String get recipeUnitNone => '(none)';

  @override
  String get recipeAddIngredient => '+ Add ingredient';

  @override
  String get recipeFieldSteps => 'Steps';

  @override
  String recipeStepLabel(int n) {
    return 'Step $n';
  }

  @override
  String get recipeAddStep => '+ Add step';

  @override
  String get recipeMoveUp => 'Move up';

  @override
  String get recipeMoveDown => 'Move down';

  @override
  String get recipeRemoveRow => 'Remove';

  @override
  String get recipeSave => 'Save';

  @override
  String get recipeSaved => 'Recipe saved';

  @override
  String get recipeErrName => 'Add a name.';

  @override
  String get recipeErrIngredients => 'Add at least one ingredient.';

  @override
  String get recipeErrSteps => 'Add at least one step.';

  @override
  String get recipeErrQty => 'Quantity must be more than 0.';

  @override
  String get recipeErrIngName => 'Add the ingredient’s name.';

  @override
  String get recipeErrTime => 'Time must be 1–600 minutes.';

  @override
  String get recipeErrServes => 'Serves must be 1–20.';

  @override
  String get recipeErrStepLong => 'A step can be at most 500 characters.';

  @override
  String get recipeDiscardTitle => 'Discard changes?';

  @override
  String get recipeKeepEditing => 'Keep editing';

  @override
  String get recipeDiscard => 'Discard';

  @override
  String get cookSub => 'Cook mode · screen stays on';

  @override
  String cookOf(int total) {
    return '/$total';
  }

  @override
  String cookStepSemantics(int n, int total, String text) {
    return 'Step $n of $total: $text';
  }

  @override
  String get cookBack => 'Back';

  @override
  String get cookNext => 'Next step';

  @override
  String get cookFinished => '✓ Finished';

  @override
  String get todayMenuTitle => 'On the menu';

  @override
  String get todayWeekPlan => 'Week plan';

  @override
  String get todayPlan => '+ Plan';

  @override
  String todayMissingToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🛒 $count ingredients missing today',
      one: '🛒 1 ingredient missing today',
    );
    return '$_temp0';
  }

  @override
  String get todayAddToList => 'Add to list';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileRoleHome(String role, String home) {
    return '$role · $home';
  }

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Member';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameSheetTitle => 'Your name';

  @override
  String get profileNameSheetLead =>
      'Shown to everyone in your home. Syncs to their phones.';

  @override
  String get profileNameError => 'Add your name.';

  @override
  String get profileSave => 'Save';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileThisPhone => 'This phone';

  @override
  String get profileOnlyThisPhone => 'Only this phone';

  @override
  String get profileDeviceKey => 'Device key';

  @override
  String get profileDeviceKeySub =>
      'Others see this to know it’s really your phone';

  @override
  String get profileYourHomes => 'Your homes';

  @override
  String get profileCurrent => 'Current';

  @override
  String profileHomeSub(int family, int help, String role) {
    String _temp0 = intl.Intl.pluralLogic(
      family,
      locale: localeName,
      other: '$family family',
      one: '1 family',
    );
    String _temp1 = intl.Intl.pluralLogic(
      help,
      locale: localeName,
      other: '$help house help',
      one: '1 house help',
    );
    return '$_temp0 · $_temp1 · you’re $role';
  }

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get notifArrival => 'House help arrival';

  @override
  String get notifArrivalSub =>
      'Reminds you to mark them in when they usually arrive';

  @override
  String get notifDigest => 'Morning task digest';

  @override
  String get notifDigestSub => '8 AM · what’s due today';

  @override
  String get notifBillDue => 'Bill due';

  @override
  String get notifBillDueSub => 'On the due day · “Electricity ₹1,980 — paid?”';

  @override
  String get notifEvening => 'Evening spend nudge';

  @override
  String get notifEveningSub => '9 PM, only if nothing was added that day';

  @override
  String get profileOnThisPhone => 'On this phone';

  @override
  String get profileBackup => 'Backup';

  @override
  String get profileBackupNotSetUp => 'Not set up';

  @override
  String get profileBackupArrives => 'Backups arrive in P18';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileEnglish => 'English';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileDevTools => 'Developer tools';

  @override
  String profileRemoveHome(String home) {
    return '🗑 Remove $home from this phone';
  }

  @override
  String profileRemoveTitle(String home) {
    return 'Remove $home from this phone?';
  }

  @override
  String get profileRemoveLead =>
      'This phone leaves the home and its copy of the data is erased. Everyone else keeps everything.';

  @override
  String get profileOnlyAdminLead =>
      'You’re the only admin. Make someone else admin first, so the home isn’t left without one.';

  @override
  String get profileGoToMembers => 'Go to members';

  @override
  String get profileKeep => 'Keep';

  @override
  String get profileRemove => 'Remove';

  @override
  String get profileFinePrint =>
      '🔒 No account, no cloud. Data syncs directly between your home’s phones, encrypted.';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileVersion => 'Version';

  @override
  String homeSubtitle(int count, String id) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count family',
      one: '1 family',
    );
    return '$_temp0 · Home ID $id';
  }

  @override
  String get homeRename => 'Rename home';

  @override
  String get homeSyncPlaceholderTitle => 'Only this phone so far';

  @override
  String get homeSyncPlaceholderSub =>
      'Invite your family to sync their phones.';

  @override
  String homeYourPhone(String model) {
    return 'Your $model';
  }

  @override
  String get homeThisPhone => 'This phone';

  @override
  String get homeSyncFootnote =>
      'ⓘ Phones sync directly on the same Wi-Fi, or over the internet when Illam is open on both.';

  @override
  String get homeBackupNone => 'No backups yet';

  @override
  String get homeBackupNotThisPhone =>
      'Not backing up from this phone — add your own copy';

  @override
  String get homeInvite => '+ Invite someone';

  @override
  String get homeInviteArrives => 'Invites arrive in P14';

  @override
  String homeAskAdmins(String names) {
    return '🔒 Only admins can invite or remove people. Ask $names.';
  }

  @override
  String homeOr(String a, String b) {
    return '$a or $b';
  }

  @override
  String get homeFamily => 'Family · uses the app';

  @override
  String get homeYou => '(you)';

  @override
  String homeMemberSub(String model, String month) {
    return '$model · joined $month';
  }

  @override
  String get homeHouseHelp => 'House help · no app needed';

  @override
  String get homeNoHelp => 'No house help added yet.';

  @override
  String get homeAddHelp => '+ Add house help';

  @override
  String get homeRolesTitle => 'What can admins and members do?';

  @override
  String get homeRolesAdmin =>
      'Everything a member can, plus: invite and remove people, change roles, set staff pay rules, pay salary, rename or delete the home.';

  @override
  String get homeRolesMember =>
      'Lists, tasks and meals; mark house help in and out; add and review spends; see the budget and salary totals.';

  @override
  String get homeRolesFootnote =>
      'Every phone checks these rules itself, so a change from someone without permission is ignored by everyone else.';

  @override
  String get homeLeaveDelete => 'Leave or delete';

  @override
  String homeLeave(String home) {
    return 'Leave $home';
  }

  @override
  String get homeDelete => '🗑 Delete this home on all phones';

  @override
  String memberJoined(String month, String how) {
    return 'Joined $month · $how';
  }

  @override
  String get memberHowCreated => 'Created the home';

  @override
  String memberHowInvited(String name) {
    return 'Invited by $name';
  }

  @override
  String get memberHowQr => 'Joined with a QR code';

  @override
  String get memberHowPhrase => 'Joined with a phrase';

  @override
  String memberDeviceKey(String fp) {
    return 'Device key $fp';
  }

  @override
  String get memberEditProfile => 'Edit profile';

  @override
  String get memberStepDown => 'Step down as admin';

  @override
  String get memberStepDownLead =>
      'You’ll need another admin to make you admin again.';

  @override
  String get memberCancel => 'Cancel';

  @override
  String get memberStepDownConfirm => 'Step down';

  @override
  String get memberNowMemberSelf => 'You’re now a member.';

  @override
  String get homeLastAdmin => 'A home needs at least one admin.';

  @override
  String get memberMakeAdmin => '🛡 Make admin';

  @override
  String get memberRemoveAdmin => 'Remove admin rights';

  @override
  String get memberRemove => 'Remove';

  @override
  String memberNowAdmin(String name) {
    return '$name is now an admin';
  }

  @override
  String memberNowMember(String name) {
    return '$name is now a member';
  }

  @override
  String get homeOnlyAdminsRoles =>
      'Only admins can change roles or remove people.';

  @override
  String get homeNameLength => 'Give your home a name.';

  @override
  String get homeChooseAdmin => 'Choose a new admin first';

  @override
  String memberRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String memberRemoveLeadWork(String home, String work) {
    return 'Their phone stops syncing with $home and gets no new changes. Their $work will move to you.';
  }

  @override
  String memberRemoveLead(String home) {
    return 'Their phone stops syncing with $home and gets no new changes.';
  }

  @override
  String get memberRemoveInfo =>
      'Their phone erases the home the next time it connects to one of yours. Until then — or if it never reconnects — it keeps what it already had. Everyone else switches to a new home key.';

  @override
  String memberRemoved(String name) {
    return '$name removed';
  }

  @override
  String workRoutines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines',
      one: '1 routine',
    );
    return '$_temp0';
  }

  @override
  String workTodos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open to-dos',
      one: '1 open to-do',
    );
    return '$_temp0';
  }

  @override
  String workAnd(String a, String b) {
    return '$a and $b';
  }

  @override
  String get homeRenameLead =>
      'Everyone sees the new name after their phone syncs.';

  @override
  String get homeRenamed => 'Home renamed';

  @override
  String get homeOnlyOneTitle => 'You’re the only one here';

  @override
  String homeOnlyOneLead(String home) {
    return 'Leaving would leave $home with no phones, so it would be deleted.';
  }

  @override
  String get homeStay => 'Stay';

  @override
  String get homeDeleteHome => 'Delete home';

  @override
  String homeLeaveTitle(String home) {
    return 'Leave $home?';
  }

  @override
  String homeLeaveLeadWork(String work, String admin) {
    return 'This phone stops syncing and its copy is erased. Your $work will move to $admin. An admin can invite you back any time.';
  }

  @override
  String get homeLeaveLead =>
      'This phone stops syncing and its copy is erased. An admin can invite you back any time.';

  @override
  String get homeLeaveConfirm => 'Leave';

  @override
  String homeLeft(String home) {
    return 'You left $home. Create or join a home to continue.';
  }

  @override
  String homeDeleteTitle(String home) {
    return 'Delete $home?';
  }

  @override
  String get homeDeleteLead =>
      'Every phone in the home erases its copy — lists, tasks, meals, attendance, salary and spends — as soon as it syncs. It can’t be undone.';

  @override
  String get homeDeleteInfo =>
      'A phone that never syncs again keeps its copy until someone opens it.';

  @override
  String homeTypeToConfirm(String home) {
    return 'Type $home to confirm';
  }

  @override
  String get homeDeleteConfirm => 'Delete on all phones';

  @override
  String todayFamilyButton(String home, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count family members',
      one: '1 family member',
    );
    return '$home: $_temp0. Manage home';
  }

  @override
  String get todayYourProfile => 'Your profile';

  @override
  String todayThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things',
      one: '1 thing',
    );
    return '$_temp0';
  }

  @override
  String todayThingsNeed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' need the house today.',
      one: ' needs the house today.',
    );
    return '$_temp0';
  }

  @override
  String todayStaffAtHome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count staff at home now',
      one: '1 staff at home now',
    );
    return '$_temp0';
  }

  @override
  String get todayNoStaff => 'No staff at home';

  @override
  String todayBudgetLeft(String amount) {
    return '$amount left in budget';
  }

  @override
  String todayBudgetOver(String amount) {
    return '$amount over budget';
  }

  @override
  String get todaySetABudget => 'Set a budget';

  @override
  String get qaGrocery => 'Grocery';

  @override
  String get qaShopping => 'Shopping';

  @override
  String get qaTodo => 'To-do';

  @override
  String get qaSpend => 'Spend';

  @override
  String get qaEmpty => '✨ Start typing — we’ll pick the right place.';

  @override
  String qaPreviewTodo(String title, String day, String who) {
    return 'To-do · “$title” · $day · $who';
  }

  @override
  String qaPreviewSpend(String amount, String merchant, String category) {
    return 'Spend · $amount · $merchant · $category';
  }

  @override
  String get qaPreviewSpendNoAmount => 'Spend · add an amount, like “₹450”';

  @override
  String qaPreviewItem(String type, String name, String qty, String store) {
    return '$type · $name $qty → $store';
  }

  @override
  String get qaUsual => ' (usual)';

  @override
  String get qaNeedAmount => 'ⓘ Add an amount, like “₹450 Swiggy”';

  @override
  String get qaTitle => 'Quick add';

  @override
  String get qaLead => 'Type it the way you’d say it.';

  @override
  String get qaPlaceholder => 'Milk 2L · Pay water bill tomorrow · ₹450 Swiggy';

  @override
  String get qaAdd => 'Add';

  @override
  String get qaFabLabel => 'Add';

  @override
  String get qaFabTooltip => 'Quick add';

  @override
  String get qaTodoAddedToday => 'To-do added for today';

  @override
  String get qaTodoAddedTomorrow => 'To-do added for tomorrow';

  @override
  String qaTodoAddedOn(String day) {
    return 'To-do added for $day';
  }

  @override
  String qaSpendAdded(String amount) {
    return '$amount added to spends';
  }

  @override
  String get notifChannelStaff => 'House help';

  @override
  String get notifChannelTasks => 'Tasks & reminders';

  @override
  String get notifChannelMoney => 'Bills & spends';

  @override
  String get notifChannelBackup => 'Backup';

  @override
  String get notifChannelHome => 'Home & members';

  @override
  String get notifAppName => 'Illam';

  @override
  String notifArrivalBody(String name, String time) {
    return '$name usually comes by $time — mark in?';
  }

  @override
  String get notifMarkInNow => 'Mark in now';

  @override
  String get notifOnLeaveToday => 'On leave today';

  @override
  String notifDigestBody(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things today: $titles…',
      one: '1 thing today: $titles',
    );
    return '$_temp0';
  }

  @override
  String notifBillBody(String bill, String amount) {
    return '$bill is due today · $amount last time';
  }

  @override
  String notifPaidAmount(String amount) {
    return 'Paid $amount';
  }

  @override
  String get notifOpen => 'Open';

  @override
  String get notifEveningBody =>
      'Spent anything today? Add it in a few seconds.';

  @override
  String get notifExplainerTitle => 'Turn on reminders?';

  @override
  String notifExplainerBody(String name) {
    return 'Get a nudge when $name usually arrives, and a morning list of what’s due.';
  }

  @override
  String get notifYourHelp => 'your house help';

  @override
  String get notifNotNow => 'Not now';

  @override
  String get notifContinue => 'Continue';

  @override
  String get notifOffBanner => 'Notifications are off for Illam';

  @override
  String get notifTurnOn => 'Turn on';

  @override
  String get debugRunJobs => 'Run background jobs now';

  @override
  String get debugPlanReminders => 'Plan reminders';

  @override
  String get debugRanJobs => 'Ran background jobs';

  @override
  String syncChangeNotApplied(String reason) {
    return 'Your change wasn’t applied: $reason';
  }

  @override
  String get syncReasonAdminOnly => 'only admins can change this';

  @override
  String get syncReasonOwnOnly => 'you can only change your own entries';

  @override
  String get syncReasonTooOld => 'it’s older than 48 hours';

  @override
  String get syncReasonLastAdmin => 'A home needs at least one admin.';

  @override
  String get syncReasonOther => 'Something went wrong. Try again.';

  @override
  String get syncLabTitle => 'Sync lab';

  @override
  String syncLabCounts(int applied, int pending, int quarantined) {
    return 'Changes: $applied applied · $pending waiting · $quarantined quarantined';
  }

  @override
  String get syncLabMemberLog => 'Membership log';

  @override
  String get syncLabVerify => 'Verify all signatures';

  @override
  String syncLabVerifyResult(int ok, int bad, int unsigned) {
    return '$ok ✓ signed · $bad bad · $unsigned unsigned';
  }

  @override
  String get syncLabExport => 'Export bundle';

  @override
  String syncLabExported(int n) {
    return 'Bundle copied · $n changes';
  }

  @override
  String get syncLabImport => 'Import bundle from clipboard';

  @override
  String syncLabImportResult(
    int applied,
    int already,
    int pending,
    int quarantined,
  ) {
    return 'Applied $applied · already had $already · waiting $pending · quarantined $quarantined';
  }

  @override
  String get syncLabOtherHome => 'This bundle is for another home.';

  @override
  String get syncLabReplace => 'Replace this phone’s home';

  @override
  String get syncLabBadBundle => 'That isn’t an Illam bundle.';

  @override
  String get syncLabTamper => 'Tamper test';

  @override
  String get syncLabAsArjunTick => 'As Arjun: tick a grocery item';

  @override
  String get syncLabAsArjunRename => 'As Arjun: rename the home';

  @override
  String get syncLabSigned => '✓ signed';

  @override
  String get syncLabUnsigned => '✕ not signed';

  @override
  String get syncLabShare => 'Share';

  @override
  String syncLabRecentOps(int count) {
    return 'Last $count ops';
  }

  @override
  String syncLabMemberCounts(
    int applied,
    int ignored,
    int pending,
    int devices,
  ) {
    return '$applied applied · $ignored ignored · $pending waiting · $devices devices';
  }

  @override
  String get inviteTitle => 'Invite someone';

  @override
  String inviteFirstRunTitle(String home) {
    return '$home is ready';
  }

  @override
  String inviteFirstRunSub(String homeId) {
    return 'Home ID $homeId';
  }

  @override
  String get inviteFirstRunLead =>
      'Let your family scan this from their phone, or send them the phrase. You’ll approve each person here.';

  @override
  String inviteQrLabel(String home) {
    return 'QR code to join $home';
  }

  @override
  String get inviteOrTypePhrase => 'OR TYPE THIS PHRASE';

  @override
  String get inviteSendWhatsApp => 'Send phrase on WhatsApp';

  @override
  String inviteWhatsAppText(String home, String phrase) {
    return 'Join \"$home\" on Illam. Open the app → Join a home → type: $phrase\n(works for 10 minutes)';
  }

  @override
  String get inviteCopyPhrase => 'Copy phrase';

  @override
  String get invitePhraseCopied =>
      'Phrase copied — it works once, for 10 minutes';

  @override
  String inviteValidFor(String time) {
    return 'Valid for $time · works once';
  }

  @override
  String get inviteExpired => 'This code has expired.';

  @override
  String get inviteMakeNew => 'Make a new code';

  @override
  String get inviteVisibleWifi => 'Visible on this Wi-Fi';

  @override
  String get inviteVisibleWifiSub =>
      'Phones on the same Wi-Fi connect directly';

  @override
  String get inviteNoWifi =>
      'Not on Wi-Fi — others can still join over the internet';

  @override
  String get inviteWaiting => 'Waiting for someone to join…';

  @override
  String get inviteWaitingSub => 'Keep this screen open until they’re in';

  @override
  String get inviteRequestEyebrow => 'JOIN REQUEST';

  @override
  String inviteRequestVia(String model) {
    return '$model · on this Wi-Fi';
  }

  @override
  String inviteRequestSas(String emojis) {
    return 'Their phone should show $emojis';
  }

  @override
  String get inviteRequestSasHint => 'If it doesn’t, tap Deny.';

  @override
  String get inviteJoinsAs => 'Joins as';

  @override
  String get inviteAdminNote =>
      'Admins can invite and remove people and manage pay.';

  @override
  String get inviteDeny => 'Deny';

  @override
  String get inviteAllow => '✓ Allow';

  @override
  String inviteAdding(String name) {
    return 'Adding $name';
  }

  @override
  String inviteSending(int pct) {
    return 'Sending the home’s data… $pct%';
  }

  @override
  String get inviteSendingSub =>
      'Directly to their phone, encrypted. Keep this screen open.';

  @override
  String inviteJoined(String name) {
    return '$name joined';
  }

  @override
  String get inviteJoinedSub => 'Their phone now syncs with this home.';

  @override
  String get inviteAnother => 'Invite someone else';

  @override
  String inviteDeclinedSnack(String name) {
    return 'Declined $name. Made a new phrase so the old one can’t be reused.';
  }

  @override
  String get inviteSkip => 'Skip for now — invite later';

  @override
  String get inviteContinue => 'Continue to my home';

  @override
  String get inviteDone => 'Done';

  @override
  String inviteWelcomeSnack(String home) {
    return 'Welcome to $home';
  }

  @override
  String inviteMembersOnly(String admins) {
    return 'Only admins can invite people. Ask $admins.';
  }

  @override
  String debugInvitePort(int port) {
    return 'Debug: listening on port $port';
  }

  @override
  String get joinTitle => 'Join a home';

  @override
  String get joinSub =>
      'Ask someone at home to open Invite on their phone. Then scan their QR code or type the phrase they share.';

  @override
  String get joinYourName => 'Your name';

  @override
  String get joinNameRequired =>
      'Add your name first — it’s how your family will see you.';

  @override
  String get joinScanTitle => 'Scan QR code';

  @override
  String get joinScanSub =>
      'Fastest when you’re next to them. Works on the same Wi-Fi or over the internet.';

  @override
  String get joinPhraseTitle => 'Type the join phrase';

  @override
  String get joinPhraseSub =>
      'Like 47-mango-river-tulip — good when they sent it on WhatsApp.';

  @override
  String get phraseSub =>
      'A number and three words, shown on the Invite screen of their phone.';

  @override
  String get phraseField => 'Join phrase';

  @override
  String get phraseHint => '47-mango-river-tulip';

  @override
  String get phraseNote =>
      'Spaces are fine too: ‘47 mango river tulip’. The phrase works once and expires after 10 minutes.';

  @override
  String get phraseConnect => 'Connect';

  @override
  String get phraseBadFormat =>
      'That doesn’t look right. It’s a number and three words, like 47-mango-river-tulip.';

  @override
  String get phraseBadWord =>
      'One of the words isn’t in the phrase list — check the spelling.';

  @override
  String get debugPort => 'Debug port';

  @override
  String get scanTitle => 'Scan the QR code';

  @override
  String get scanHint => 'On their phone: Profile → Home → Invite someone';

  @override
  String get scanTypeInstead => 'Type the phrase instead';

  @override
  String get scanNote =>
      '🔒 The camera is used only to read the code. Nothing is recorded.';

  @override
  String get scanDenied => 'Allow camera to scan, or type the phrase instead.';

  @override
  String get scanOpenSettings => 'Open settings';

  @override
  String get scanTorch => 'Torch';

  @override
  String get whoTheir => 'their';

  @override
  String whoName(String name) {
    return '$name’s';
  }

  @override
  String get connectEyebrow => 'Joining';

  @override
  String connectEyebrowHome(String home) {
    return 'Joining · $home';
  }

  @override
  String get connectTitle => 'Connecting…';

  @override
  String connectWelcome(String home) {
    return 'Welcome to $home';
  }

  @override
  String get connectFailed => 'Something stopped the join';

  @override
  String stepFindActive(String who) {
    return 'Looking for $who phone on this Wi-Fi…';
  }

  @override
  String stepFindDone(String who) {
    return 'Found $who phone on this Wi-Fi';
  }

  @override
  String get stepCodeActive => 'Checking the code…';

  @override
  String get stepCodeDone => 'Code matched · connection encrypted';

  @override
  String stepApproveActive(String inviter) {
    return 'Waiting for $inviter to approve…';
  }

  @override
  String stepApproveSas(String inviter, String emojis) {
    return 'Check that $inviter’s phone shows $emojis';
  }

  @override
  String stepApproveDone(String inviter, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'an admin',
      'other': 'a member',
    });
    return '$inviter approved you as $_temp0';
  }

  @override
  String stepCopyActive(int pct) {
    return 'Copying the home’s data… $pct%';
  }

  @override
  String stepCopyDone(int n) {
    return 'Copied $n items · you’re in sync';
  }

  @override
  String successBody(String names) {
    return 'You’re in with $names. Changes now sync between your phones.';
  }

  @override
  String goHome(String home) {
    return 'Go to $home';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get useDifferentCode => 'Use a different code';

  @override
  String get finishLater => 'Finish later';

  @override
  String get finishLaterNote =>
      'You’re already in — the copy continues next time.';

  @override
  String get stoppedSnack => 'Stopped. Nothing was shared.';

  @override
  String joinedSnack(String home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'an admin',
      'other': 'a member',
    });
    return 'You joined $home as $_temp0';
  }

  @override
  String errNotFound(String who) {
    return 'Couldn’t reach $who phone';
  }

  @override
  String errNotFoundHelp(String inviter) {
    return 'Tips: keep the Invite screen open on $inviter’s phone, and make sure both phones have Wi-Fi or mobile data on. The phrase is valid for 10 minutes.';
  }

  @override
  String get errWrongCode => 'The phrase didn’t match';

  @override
  String errWrongCodeHelp(String inviter) {
    return 'Check the phrase with $inviter — after 3 wrong tries it stops working and they’ll need to make a new one.';
  }

  @override
  String get errExpired =>
      'This phrase has expired or was already used. Ask for a new one.';

  @override
  String errDeclined(String inviter) {
    return '$inviter declined the request';
  }

  @override
  String errDeclinedHelp(String inviter) {
    return 'Ask $inviter to try again if this was a mistake.';
  }

  @override
  String errVersion(String inviter) {
    return '$inviter’s Illam is a different version. Update both apps from the Play Store, then try again.';
  }

  @override
  String get errCopy => 'Copy interrupted';

  @override
  String setupBanner(int pct) {
    return 'Finishing setup… $pct% — keep Illam open on a family phone';
  }

  @override
  String get agoNow => 'now';

  @override
  String agoMinutes(int m) {
    return '$m min ago';
  }

  @override
  String agoHours(int h) {
    return '$h h ago';
  }

  @override
  String agoDays(int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get syncTagOnlyThisPhone => 'Only this phone';

  @override
  String syncTagJustNow(String name) {
    return 'Synced with $name just now';
  }

  @override
  String syncTagLast(String ago) {
    return 'Last synced $ago';
  }

  @override
  String syncTagLabel(String text) {
    return '$text. Open sync details';
  }

  @override
  String get syncNotYet => 'Not synced yet';

  @override
  String get todayOffline => 'Offline — changes will sync';

  @override
  String get syncCardAllInSync => 'All phones in sync';

  @override
  String syncCardBehind(int k) {
    String _temp0 = intl.Intl.pluralLogic(
      k,
      locale: localeName,
      other: '$k phones not up to date',
      one: '1 phone not up to date',
    );
    return '$_temp0';
  }

  @override
  String syncCardLastSynced(String ago) {
    return 'Last synced $ago';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncedSnack => 'Synced with phones that are reachable right now';

  @override
  String get syncNoPeers => 'No family phones reachable right now';

  @override
  String syncRowTheirs(String name, String model) {
    return '$name’s $model';
  }

  @override
  String get syncOnWifiNow => 'On this Wi-Fi now';

  @override
  String syncSyncedAgo(String ago) {
    return 'Synced $ago';
  }

  @override
  String syncNotForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Not synced for $n days',
      one: 'Not synced for 1 day',
    );
    return '$_temp0';
  }

  @override
  String syncMissing(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ' · missing $n of your changes',
      one: ' · missing 1 of your changes',
    );
    return '$_temp0';
  }

  @override
  String get syncClockWrong =>
      'Your phone’s clock looks wrong — sync may be off';

  @override
  String get syncWifiBlocked =>
      'Your Wi-Fi may block phones from seeing each other — syncing over the internet instead.';

  @override
  String syncUpdateNeeded(String name) {
    return 'Update Illam to keep syncing with $name';
  }

  @override
  String get profileInSync => '✓ In sync';

  @override
  String profileOneBehind(String name) {
    return '$name’s phone is behind';
  }

  @override
  String profileManyBehind(int n) {
    return '$n phones behind';
  }

  @override
  String get notifOutOfSync =>
      'Illam hasn’t synced with your family for 3 days. Open it on the same Wi-Fi to catch up.';

  @override
  String get notifTodoAssignedTitle => 'To-do assigned to you';

  @override
  String notifTodoAssignedBody(String title, String name) {
    return '$title · from $name';
  }

  @override
  String notifJoinedTitle(String name, String home) {
    return '$name joined $home';
  }

  @override
  String get notifJoinedBody => 'Their phone now syncs with this home.';

  @override
  String syncLabPort(int port) {
    return 'Listening on port $port';
  }

  @override
  String get syncLabPeers => 'Peers';

  @override
  String get syncLabVector => 'My version vector';

  @override
  String get syncLabConnectLocal => 'Connect to 127.0.0.1';

  @override
  String homeGoneRemoved(String home) {
    return 'You’re no longer in $home';
  }

  @override
  String homeGoneDeleted(String home, String name) {
    return '$home was deleted by $name';
  }

  @override
  String get homeGoneOk => 'OK';

  @override
  String memberRemovedNewKey(String name) {
    return '$name removed · new home key shared with the others';
  }

  @override
  String leaveChooseAdminLead(String home) {
    return 'You’re the only admin. Pick someone to look after $home after you leave.';
  }

  @override
  String get leaveWaiting => 'Leaving… waiting for a family phone';

  @override
  String get leaveRemoveNow =>
      'Remove from this phone now — we’ll tell your family the next time this phone reaches one of theirs';

  @override
  String deleteDone(String home) {
    return '$home deleted. Other phones erase it when they sync.';
  }

  @override
  String get opIgnoredRoleChanged => 'Someone changed your role first.';

  @override
  String get inviteTipSecondAdmin =>
      'Tip: make a second admin, so the home is never stuck without one.';

  @override
  String inviteBackupNow(String home) {
    return 'Back up $home now';
  }

  @override
  String backupHealthOk(Object ago, Object provider, Object name) {
    return 'Backed up $ago to $provider · by $name';
  }

  @override
  String get backupOnlyOnPhone => 'Only on this phone — add another place';

  @override
  String get backupNoRecoveryReady => 'No recovery-ready backup';

  @override
  String backupNoBackupDays(int n) {
    return 'No backup in $n days';
  }

  @override
  String backupThisPhoneOn(Object provider) {
    return 'Backing up from this phone · $provider';
  }

  @override
  String backupAlso(Object name, Object provider, Object ago) {
    return 'Also: $name backs up to $provider ($ago)';
  }

  @override
  String get backupNoAdminHint =>
      'No admin has a backup yet — if every admin phone is lost, a restore brings people back as members.';

  @override
  String get backupProviderFolderShort => 'a folder';

  @override
  String get backupJustNow => 'just now';

  @override
  String backupAttention(Object reason) {
    return 'Backup needs attention — $reason';
  }

  @override
  String backupReasonAuth(Object provider) {
    return 'Sign in to $provider again to keep backups running.';
  }

  @override
  String backupReasonFull(Object provider) {
    return '$provider is full — free space or choose another place.';
  }

  @override
  String get backupErrNoPermission => 'No permission to write to that folder';

  @override
  String backupStatusStale(int n) {
    return 'Not backed up for $n days';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String backupProfileRow(Object provider, Object frequency, Object ago) {
    return 'Backup — $provider · $frequency · last $ago';
  }

  @override
  String get backupProfileNotSetUp => 'Backup — not set up';

  @override
  String get backupDaily => 'Daily';

  @override
  String get backupWeekly => 'Weekly';

  @override
  String get backupMonthly => 'Monthly';

  @override
  String get notifBackupAttention => 'Backup needs attention';

  @override
  String get notifBackupAttentionSub => 'Only when backups stop working';

  @override
  String backupHeroTitle(Object home) {
    return 'Keep $home safe';
  }

  @override
  String get backupHeroLead =>
      'Illam has no cloud of its own. If every phone in the home is lost, a backup is the only way back.';

  @override
  String get backupPromise1Title => 'Locked before it leaves this phone';

  @override
  String get backupPromise1 =>
      'Encrypted with a password only you know. Your cloud sees just a locked file.';

  @override
  String get backupPromise2Title => 'Runs by itself';

  @override
  String get backupPromise2 =>
      'Every week on Wi-Fi while charging. You’ll hear from us only if it stops working.';

  @override
  String get backupPromise3Title => 'Brings everything back';

  @override
  String get backupPromise3 =>
      'Lists, staff, attendance, salary, meals and spends, plus your own recovery key, so a new phone gets you back in with the same role you have now.';

  @override
  String get backupWhere => 'Where should backups go?';

  @override
  String get backupGroupSignIn => 'Sign in';

  @override
  String get backupGroupServer => 'Your own server';

  @override
  String get backupGroupDevice => 'On this phone';

  @override
  String get backupDontSee => 'Don’t see yours?';

  @override
  String get backupDontSeeBody =>
      'Don’t see yours? Proton Drive and MEGA are coming later. iCloud, Box, Terabox and JioCloud can’t be connected from Android apps — use WebDAV if your provider offers it, or a folder on this phone.';

  @override
  String backupAlsoIn(Object home, Object name, Object provider, Object ago) {
    return 'Also in $home: $name backs up to $provider ($ago).';
  }

  @override
  String get backupArrivesP19 => 'Arrives in P19';

  @override
  String get backupArrivesP20 => 'Arrives in P20';

  @override
  String get backupProvFolder => 'Folder on this phone or another app';

  @override
  String get backupProvFolderSub =>
      'SD card, USB drive, or a cloud app that offers folders';

  @override
  String get backupProvGdrive => 'Google Drive';

  @override
  String get backupProvGdriveSub => 'Sign in · Hidden app folder in your Drive';

  @override
  String get backupProvOnedrive => 'OneDrive';

  @override
  String get backupProvOnedriveSub => 'Sign in · Apps › Illam';

  @override
  String get backupProvDropbox => 'Dropbox';

  @override
  String get backupProvDropboxSub => 'Sign in · Apps › Illam';

  @override
  String get backupProvPcloud => 'pCloud';

  @override
  String get backupProvPcloudSub => 'Sign in · App folder · EU or US region';

  @override
  String get backupProvNextcloud => 'Nextcloud';

  @override
  String get backupProvNextcloudSub => 'Your own or a hosted Nextcloud';

  @override
  String get backupProvWebdav => 'WebDAV';

  @override
  String get backupProvWebdavSub =>
      'ownCloud, Synology, QNAP, Koofr, Yandex Disk, any WebDAV';

  @override
  String get backupProvS3 => 'S3-compatible';

  @override
  String get backupProvS3Sub =>
      'AWS S3, Backblaze B2, Wasabi, Cloudflare R2, MinIO';

  @override
  String get backupProvSftp => 'SFTP';

  @override
  String get backupProvSftpSub => 'Home NAS or your own server';

  @override
  String get backupChecking => 'Checking… wrote a test file';

  @override
  String get backupErrUnreachable => 'Couldn’t reach that server';

  @override
  String get backupLocalCopy => 'Local copy — lost with the phone';

  @override
  String get backupPwTitle => 'Set a backup password';

  @override
  String get backupPwField => 'Backup password';

  @override
  String get backupPwConfirm => 'Confirm password';

  @override
  String get backupPwTooShort => 'Too short';

  @override
  String get backupPwOkay => 'Okay';

  @override
  String get backupPwStrong => 'Strong';

  @override
  String get backupPwSuggest => 'Suggest one';

  @override
  String get backupPwWarning =>
      'We can’t reset this password. Without it, backups can’t be opened. Save it in your password manager or write it down.';

  @override
  String get backupPwSaved => 'I’ve saved this password somewhere safe';

  @override
  String get backupPwSave => 'Save password & back up';

  @override
  String get backupPwMismatch => 'The two passwords don’t match.';

  @override
  String get backupPwMissing =>
      'Nothing is backed up yet. Set a backup password to start.';

  @override
  String backupStatusOk(Object ago) {
    return 'Backed up $ago';
  }

  @override
  String backupStatusRunning(int pct) {
    return 'Backing up… $pct%';
  }

  @override
  String backupStatusFailed(Object reason) {
    return 'Last backup failed — $reason';
  }

  @override
  String get backupStatusUnchanged => 'No changes since last backup';

  @override
  String backupNext(Object when, Object conditions) {
    return 'Next: $when · $conditions';
  }

  @override
  String get backupOnWifi => 'on Wi-Fi';

  @override
  String get backupWhileCharging => 'while charging';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupWhereGo => 'Where backups go';

  @override
  String backupPlacesCount(int k) {
    return '$k of 3';
  }

  @override
  String backupDestLast(Object ago, int k) {
    return 'Last: $ago · $k kept';
  }

  @override
  String get backupDisconnect => 'Disconnect';

  @override
  String get backupStayThere => 'Backups already there stay there.';

  @override
  String get backupAddPlace => '＋ Add another place';

  @override
  String get backupSchedule => 'Schedule';

  @override
  String get backupHowOften => 'How often';

  @override
  String get backupWifiOnly => 'Only on Wi-Fi';

  @override
  String get backupWifiOnlySub => 'Never uses mobile data';

  @override
  String get backupCharging => 'Only while charging';

  @override
  String get backupChargingSub => 'Usually overnight';

  @override
  String get backupKeep => 'Keep the most recent';

  @override
  String backupKeepN(int n) {
    return '$n backups';
  }

  @override
  String get backupKeepSub =>
      'Older ones are deleted from that place after a successful backup.';

  @override
  String backupProgressNotif(Object home) {
    return 'Backing up $home…';
  }

  @override
  String get backupLocalTag => 'Local copy';

  @override
  String get backupPwRow => 'Backup password';

  @override
  String backupPwRowSub(Object date) {
    return 'Set $date · saved on this phone';
  }

  @override
  String get backupPwChangeTitle => 'Change backup password';

  @override
  String get backupPwChangeNote =>
      'New backups use the new password. Older backups still need the old one.';

  @override
  String get backupPwChangeSave => 'Save new password';

  @override
  String get backupCheck => 'Check a backup';

  @override
  String get backupCheckSub => 'Opens the latest backup to make sure it works';

  @override
  String backupCheckOk(int n, Object size) {
    return 'Latest backup opens fine · $n items · $size';
  }

  @override
  String get backupDamaged => 'This backup is damaged — try an older one.';

  @override
  String get backupCheckUnreachable =>
      'Couldn’t reach the backup place — try again later.';

  @override
  String get backupRecent => 'Recent backups';

  @override
  String backupRecentRow(Object ago, Object size, Object place) {
    return '$ago · $size · $place';
  }

  @override
  String get backupRecentEmpty => 'No backups yet.';

  @override
  String get backupKits => 'Recovery keys';

  @override
  String backupKitRow(Object name, Object model) {
    return '$name’s $model';
  }

  @override
  String get backupKitThisPhone => 'This phone';

  @override
  String backupKitSub(Object date, Object name, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'an admin',
      'other': 'a member',
    });
    return 'Made $date · restores $name as $_temp0';
  }

  @override
  String get backupKitTurnOff => 'Turn off';

  @override
  String backupKitOffTitle(Object name) {
    return 'Turn off $name’s recovery key?';
  }

  @override
  String backupKitOffLead(Object name, Object home) {
    return 'Backups made with it can still be opened, but only as a separate copy — they can’t bring $name back into $home. $name’s phone makes a new key at its next backup.';
  }

  @override
  String get backupKitKeep => 'Keep';

  @override
  String get backupKitDead =>
      'Make a new backup — the old recovery kit no longer works.';

  @override
  String backupFinePrint(Object home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'an admin',
      'other': 'a member',
    });
    return 'Backups include your recovery key. Anyone with the file and the password can restore $home as $_temp0 — keep the password private.';
  }

  @override
  String get debugDamageBackup => 'Write a damaged copy of the latest backup';

  @override
  String get debugFolderOffPhone => 'Count folders as off-phone';

  @override
  String get restoreTitle => 'Restore from a backup';

  @override
  String get restoreSub => 'Choose where your backup is.';

  @override
  String get restoreNote =>
      '🔒 Your backup is opened on this phone. Nothing is sent to Illam.';

  @override
  String get restorePickTitle => 'Pick a backup';

  @override
  String restoreFoundIn(Object provider, Object account) {
    return 'Found in $provider · $account';
  }

  @override
  String restoreVault(Object vault) {
    return 'Home backup · $vault';
  }

  @override
  String restoreRow(Object date, Object size) {
    return '$date · $size';
  }

  @override
  String get restoreTagKit => 'Recovery key';

  @override
  String get restoreTagData => 'Data only';

  @override
  String restoreOlder(int n) {
    return 'Older backups ($n)';
  }

  @override
  String get restoreEmpty =>
      'No Illam backups here — check you picked the right account or folder.';

  @override
  String get restoreChooseAnother => 'Choose another place';

  @override
  String get restoreUnlockTitle => 'Unlock this backup';

  @override
  String get restoreUnlocking => 'Unlocking…';

  @override
  String get restoreWrongPw => 'Wrong password — passwords are case-sensitive.';

  @override
  String restoreHeaderCard(
    Object home,
    Object homeId,
    Object date,
    Object model,
    Object name,
  ) {
    return '$home · $homeId · $date · from $model ($name)';
  }

  @override
  String get restoreStepDownload => 'Downloading';

  @override
  String get restoreStepUnlock => 'Unlocking';

  @override
  String get restoreStepCheck => 'Checking the home’s history';

  @override
  String get restoreStepSetup => 'Setting up this phone';

  @override
  String restoreWelcome(Object home) {
    return 'Welcome back to $home';
  }

  @override
  String restoreOthersNote(Object home) {
    return 'Phones still in $home will show that you restored on a new phone.';
  }

  @override
  String restoreKeepBackingUp(Object provider) {
    return 'Keep backing up to $provider';
  }

  @override
  String restoreGo(Object home) {
    return 'Go to $home';
  }

  @override
  String restoreAlreadyHere(Object home) {
    return '$home is already on this phone.';
  }

  @override
  String get restoreOpen => 'Open';

  @override
  String get restoreDownloadFail =>
      'Couldn’t download — check your connection and try again.';

  @override
  String restoreBanner(Object date, Object home) {
    return 'Restored from a backup made $date. Connecting to the rest of $home…';
  }

  @override
  String restoreDeadKit(Object date, Object home) {
    return 'This backup’s recovery key was turned off on $date. Ask an admin in $home to invite you.';
  }

  @override
  String get restoreSeparateCopy => 'Keep as a separate copy';

  @override
  String get restoreRemoveFromPhone => 'Remove from this phone';

  @override
  String restoreSeparateName(Object home, Object date) {
    return '$home (restored $date)';
  }

  @override
  String restoreOtherAdmin(Object name, Object home) {
    return '$name restored $home on a new phone from a backup';
  }

  @override
  String get restoreKeep => 'Keep';

  @override
  String get restoreRemove => 'Remove';

  @override
  String get bkSrvErrAuth => 'Wrong username or app password';

  @override
  String get bkSrvErrBucket => 'Bucket not found';

  @override
  String get bkSrvErrOther =>
      'That didn’t work — check the details and try again.';

  @override
  String get bkSrvErrHttps => 'Use an address that starts with https://';

  @override
  String get bkSrvErrHostKeyChanged =>
      'This server’s fingerprint changed. If you didn’t change the server, don’t connect.';

  @override
  String get bkSrvConnect => 'Connect';

  @override
  String get bkSrvTrustTitle => 'Trust this server?';

  @override
  String bkSrvTrustLead(Object host) {
    return 'First time connecting to $host. Check that this fingerprint matches the one on your server.';
  }

  @override
  String get bkSrvTrust => 'Trust';

  @override
  String get bkSrvWebdavTitle => 'WebDAV';

  @override
  String get bkSrvServerAddress => 'Server address';

  @override
  String get bkSrvUsername => 'Username';

  @override
  String get bkSrvAppPassword => 'App password';

  @override
  String get bkSrvWebdavHint =>
      'Works with ownCloud, Synology, QNAP, Koofr, Yandex Disk, pCloud and any WebDAV server. Use an app password, not your main one.';

  @override
  String bkSrvAccount(Object user, Object host) {
    return '$user @ $host';
  }

  @override
  String get bkSrvNextcloudTitle => 'Nextcloud';

  @override
  String get bkSrvNextcloudHint =>
      'We’ll open your Nextcloud login in the browser. Approve Illam there — it gets its own app password you can revoke any time.';

  @override
  String get bkSrvNextcloudAccessNote =>
      'This app password can reach your whole Nextcloud account. A separate Nextcloud user just for backups is safer.';

  @override
  String get bkSrvContinueInBrowser => 'Continue in browser';

  @override
  String get bkSrvOpeningLogin => 'Opening your Nextcloud login…';

  @override
  String get bkSrvApproveTitle => 'Approve in your browser';

  @override
  String bkSrvApproveLead(Object host) {
    return 'Log in to $host and tap Grant access for Illam. Then come back here.';
  }

  @override
  String get bkSrvWaitingApproval => 'Waiting for approval…';

  @override
  String get bkSrvS3Title => 'S3-compatible';

  @override
  String get bkSrvService => 'Service';

  @override
  String get bkSrvPresetAws => 'AWS';

  @override
  String get bkSrvPresetB2 => 'Backblaze B2';

  @override
  String get bkSrvPresetWasabi => 'Wasabi';

  @override
  String get bkSrvPresetR2 => 'Cloudflare R2';

  @override
  String get bkSrvPresetMinio => 'MinIO';

  @override
  String get bkSrvPresetOther => 'Other';

  @override
  String get bkSrvRegion => 'Region';

  @override
  String get bkSrvEndpoint => 'Endpoint';

  @override
  String get bkSrvBucket => 'Bucket';

  @override
  String get bkSrvAccessKeyId => 'Access key ID';

  @override
  String get bkSrvSecretKey => 'Secret access key';

  @override
  String get bkSrvS3Hint =>
      'Create a key that can only write to this bucket. Files go under illam/.';

  @override
  String bkSrvS3Account(Object bucket, Object service) {
    return '$bucket · $service';
  }

  @override
  String get bkSrvSftpTitle => 'SFTP';

  @override
  String get bkSrvHost => 'Host';

  @override
  String get bkSrvPort => 'Port';

  @override
  String get bkSrvPassword => 'Password';

  @override
  String get bkSrvFolder => 'Folder';

  @override
  String get bkSrvSignInWith => 'Sign in with';

  @override
  String get bkSrvAuthPassword => 'Password';

  @override
  String get bkSrvAuthKey => 'A key made on this phone';

  @override
  String get bkSrvKeyHint =>
      'Add this key to the server’s authorized_keys file for this user, then tap Connect.';

  @override
  String get bkSrvCopyKey => 'Copy key';

  @override
  String get bkSrvKeyCopied => 'Key copied';

  @override
  String get bkSrvSftpAccessNote =>
      'Tip: a server user that can only see its own folder is safer.';

  @override
  String bkSrvSftpAccount(Object user, Object host, Object port) {
    return '$user@$host:$port';
  }

  @override
  String get bkSrvSignInAgain => 'Sign in again';

  @override
  String get bkCloudGdriveAccess =>
      'See, create and delete its own data in your Google Drive — a hidden app folder. It can’t see your other files.';

  @override
  String get bkCloudGdriveWhere => 'Hidden app folder in your Drive';

  @override
  String bkCloudConnected(Object provider) {
    return 'Connected to $provider';
  }

  @override
  String bkCloudSignedInAgain(Object provider) {
    return 'Signed in to $provider again';
  }

  @override
  String get bkCloudSignInAgainSub =>
      'Use this if backups say the sign-in expired';

  @override
  String get bkCloudExpiredRow => 'Sign-in expired — Sign in again';

  @override
  String bkCloudNotConfigured(Object provider) {
    return 'This build isn’t set up for $provider yet.';
  }

  @override
  String bkCloudSignInFailed(Object provider) {
    return 'Couldn’t sign in to $provider — try again.';
  }

  @override
  String get bkCloudDropboxAccess =>
      'Read and write files in Apps › Illam only. It can’t see your other files.';

  @override
  String get bkCloudOnedriveAccess =>
      'Read and write files in its own folder, Apps › Illam. It can’t see your other files.';

  @override
  String get bkCloudAppsFolder => 'Apps › Illam';

  @override
  String get bkCloudOrgApproval =>
      'Your organisation must approve Illam before it can use this OneDrive. Ask your IT admin, or choose another place.';

  @override
  String get bkCloudPcloudAccess =>
      'Read and write files in its own app folder only.';

  @override
  String get bkCloudPcloudWhere => 'App folder · EU or US region';

  @override
  String bkCloudPcloudAccount(Object email, Object region) {
    return '$email · $region';
  }

  @override
  String get debugBackupLab => 'Backup lab';

  @override
  String get debugGoogleSilent => 'Google silent sign-in now';

  @override
  String get debugExpireTokens => 'Expire Dropbox/OneDrive tokens';

  @override
  String get debugBreakTokens => 'Break Dropbox/OneDrive refresh token';

  @override
  String get debugResultOk => 'ok';

  @override
  String get debugResultNeedsSignIn => 'needs sign-in';

  @override
  String get debugAdd200Items => 'Add 200 test items';

  @override
  String get remoteSyncTitle => 'Remote sync';

  @override
  String get remoteSyncExperimental => 'Experimental';

  @override
  String get remoteSyncToggleTitle => 'Remote sync (experimental)';

  @override
  String get remoteSyncToggleSub =>
      'Relay end-to-end encrypted updates through your own Firebase project';

  @override
  String get remoteSyncOffTitle => 'Bring Your Own Firebase';

  @override
  String get remoteSyncOffBody =>
      'By default, Illam only syncs on home Wi-Fi. Turn on Remote sync to connect your own free Firebase project so family phones can sync over mobile data — with zero developer servers and end-to-end encryption.';

  @override
  String get remoteSyncStatusTitle => 'Firebase relay';

  @override
  String remoteSyncStatusConnected(Object projectId) {
    return 'Connected · $projectId';
  }

  @override
  String remoteSyncStatusLastSynced(Object ago) {
    return 'Last synced $ago';
  }

  @override
  String get remoteSyncStatusNever => 'Enabled · not synced yet';

  @override
  String get remoteSyncStatusNeedsSetup =>
      'Enabled · add Firebase details below';

  @override
  String get remoteSyncStatusOff => 'Off · home Wi-Fi only';

  @override
  String remoteSyncStatusError(Object projectId) {
    return 'Attention · $projectId';
  }

  @override
  String get remoteSyncSyncNow => 'Sync now';

  @override
  String get remoteSyncSyncing => 'Syncing…';

  @override
  String remoteSyncSyncedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remote sync updated ($count items)',
      one: 'Remote sync updated (1 item)',
    );
    return '$_temp0';
  }

  @override
  String get remoteSyncSyncedNone => 'Remote relay already up to date';

  @override
  String get remoteSyncShareFamily => 'Share with family';

  @override
  String get remoteSyncGuideTitle => 'How to set up your Firebase project';

  @override
  String get remoteSyncGuideStep1 =>
      '1. Create a free Firebase project at console.firebase.google.com and add a Web app (</>) to view your Project ID and Web API key.';

  @override
  String get remoteSyncGuideStep2 =>
      '2. Under Authentication → Sign-in method, turn on Anonymous sign-in.';

  @override
  String get remoteSyncGuideStep3 =>
      '3. Under Firestore Database, create a database, open Rules, and paste Illam’s security rules.';

  @override
  String get remoteSyncGuideStep4 =>
      '4. Enter your config below, test the connection, and share the QR code with family phones.';

  @override
  String get remoteSyncCopyRules => 'Copy security rules';

  @override
  String get remoteSyncRulesCopied => 'Security rules copied';

  @override
  String get remoteSyncShowRules => 'View security rules';

  @override
  String get remoteSyncHideRules => 'Hide security rules';

  @override
  String get remoteSyncConfigTitle => 'Firebase configuration';

  @override
  String get remoteSyncConfigLead =>
      'Enter your project details, or paste the firebaseConfig snippet from Firebase Console.';

  @override
  String get remoteSyncPasteConfig => 'Paste config';

  @override
  String get remoteSyncScanQr => 'Scan QR';

  @override
  String get remoteSyncPasteSheetTitle => 'Paste Firebase config';

  @override
  String get remoteSyncPasteSheetLead =>
      'Paste a firebaseConfig JS/JSON snippet or an Illam remote sync link.';

  @override
  String get remoteSyncPasteFieldLabel => 'Config snippet or link';

  @override
  String get remoteSyncApplyConfig => 'Fill fields';

  @override
  String get remoteSyncConfigApplied => 'Firebase fields filled';

  @override
  String get remoteSyncConfigNotFound =>
      'Couldn’t find projectId and apiKey in pasted text';

  @override
  String get remoteSyncProjectIdLabel => 'Project ID';

  @override
  String get remoteSyncProjectIdHint => 'my-family-illam';

  @override
  String get remoteSyncApiKeyLabel => 'Web API key';

  @override
  String get remoteSyncApiKeyHint => 'AIzaSy...';

  @override
  String get remoteSyncShowApiKey => 'Show API key';

  @override
  String get remoteSyncHideApiKey => 'Hide API key';

  @override
  String get remoteSyncDatabaseIdLabel => 'Database ID (optional)';

  @override
  String get remoteSyncDatabaseIdHint => '(default)';

  @override
  String get remoteSyncErrProjectEmpty => 'Enter your Firebase Project ID';

  @override
  String get remoteSyncErrProjectInvalid =>
      'Use lowercase letters, numbers, and hyphens';

  @override
  String get remoteSyncErrKeyEmpty => 'Enter your Firebase Web API key';

  @override
  String get remoteSyncErrKeyInvalid => 'Check the Web API key format';

  @override
  String get remoteSyncErrDbInvalid =>
      'Leave as (default) or use lowercase letters, numbers, and hyphens';

  @override
  String get remoteSyncTestBtn => 'Test connection';

  @override
  String get remoteSyncTestingBtn => 'Testing…';

  @override
  String get remoteSyncTestOk =>
      'Connection OK — Anonymous Auth and Firestore rules verified.';

  @override
  String get remoteSyncSaveBtn => 'Save & connect';

  @override
  String get remoteSyncSavingBtn => 'Saving…';

  @override
  String get remoteSyncSavedSnack => 'Firebase configuration saved';

  @override
  String get remoteSyncRemoveBtn => 'Remove Firebase config';

  @override
  String get remoteSyncRemoveTitle => 'Remove Firebase config?';

  @override
  String get remoteSyncRemoveBody =>
      'This phone will stop using remote sync and clear stored Firebase credentials. Local home data stays untouched.';

  @override
  String get remoteSyncRemoveConfirm => 'Remove';

  @override
  String get remoteSyncShareTitle => 'Share Firebase setup';

  @override
  String get remoteSyncShareLead =>
      'Scan this QR on another family phone after enabling Remote sync there.';

  @override
  String get remoteSyncShareWarning =>
      'Share only with family members of this home — anyone with your Project ID and API key can access your Firebase project’s anonymous relay.';

  @override
  String get remoteSyncCopyShareLink => 'Copy setup link';

  @override
  String get remoteSyncShareLinkCopied => 'Setup link copied';

  @override
  String get remoteSyncScanTitle => 'Scan remote sync QR';

  @override
  String get remoteSyncScanHint =>
      'Point at the Remote sync QR code from your family member’s phone.';

  @override
  String get remoteSyncScanInvalid =>
      'That QR code isn’t an Illam remote sync config';

  @override
  String get remoteSyncErrInvalidApiKey => 'Firebase rejected the Web API key.';

  @override
  String get remoteSyncErrAnonDisabled =>
      'Turn on Anonymous sign-in under Firebase Authentication → Sign-in method.';

  @override
  String get remoteSyncErrPermissionDenied =>
      'Firestore denied access. Paste Illam’s security rules in Firestore → Rules.';

  @override
  String get remoteSyncErrDatabaseNotFound =>
      'Firestore database or Project ID not found.';

  @override
  String get remoteSyncErrQuota =>
      'Firebase daily Spark quota exceeded. Try again later.';

  @override
  String get remoteSyncErrNetwork =>
      'Could not reach Firebase. Check your internet connection.';

  @override
  String get remoteSyncErrOther =>
      'Firebase sync failed — check your configuration and rules.';

  @override
  String get remoteSyncCardTitle => 'Remote sync';

  @override
  String get remoteSyncProfileSubOff => 'Off';

  @override
  String get remoteSyncProfileSubNeedsSetup => 'Needs setup';

  @override
  String remoteSyncProfileSubConnected(Object projectId) {
    return 'Connected · $projectId';
  }

  @override
  String get remoteSyncNoHomeKey => 'Home encryption key not ready yet';

  @override
  String get remoteSyncCombinedSynced => 'Synced phones and remote relay';
}
