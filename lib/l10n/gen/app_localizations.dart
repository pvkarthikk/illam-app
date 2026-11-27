import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Illam'**
  String get appName;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get tabLists;

  /// No description provided for @tabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tabTasks;

  /// No description provided for @tabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tabMeals;

  /// No description provided for @tabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tabMoney;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get commonDecrease;

  /// No description provided for @commonIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get commonIncrease;

  /// No description provided for @commonArrivesIn.
  ///
  /// In en, this message translates to:
  /// **'Arrives in {phase}'**
  String commonArrivesIn(Object phase);

  /// No description provided for @debugTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get debugTitle;

  /// No description provided for @debugGallery.
  ///
  /// In en, this message translates to:
  /// **'Component gallery'**
  String get debugGallery;

  /// No description provided for @debugGallerySub.
  ///
  /// In en, this message translates to:
  /// **'Every shared component, light and dark'**
  String get debugGallerySub;

  /// No description provided for @debugDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get debugDarkTheme;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @undoConflict.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — {name} changed it.'**
  String undoConflict(Object name);

  /// No description provided for @undoConflictYou.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — you changed it.'**
  String get undoConflictYou;

  /// No description provided for @undoConflictSomeone.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — someone else changed it.'**
  String get undoConflictSomeone;

  /// No description provided for @debugDataLab.
  ///
  /// In en, this message translates to:
  /// **'Data lab'**
  String get debugDataLab;

  /// No description provided for @debugDataLabSub.
  ///
  /// In en, this message translates to:
  /// **'Notes, undo and the op log'**
  String get debugDataLabSub;

  /// No description provided for @labAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get labAddNote;

  /// No description provided for @labNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get labNoteHint;

  /// No description provided for @labNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get labNoteAdded;

  /// No description provided for @labNoteRenamed.
  ///
  /// In en, this message translates to:
  /// **'Note renamed'**
  String get labNoteRenamed;

  /// No description provided for @labNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get labNoteDeleted;

  /// No description provided for @labPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get labPinned;

  /// No description provided for @labUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get labUnpinned;

  /// No description provided for @labTaps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tap} other{{count} taps}}'**
  String labTaps(int count);

  /// No description provided for @labRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent changes'**
  String get labRecent;

  /// No description provided for @labOpLog.
  ///
  /// In en, this message translates to:
  /// **'Op log'**
  String get labOpLog;

  /// No description provided for @labOpsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} ops'**
  String labOpsTotal(int count);

  /// No description provided for @labPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get labPin;

  /// No description provided for @labEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get labEdit;

  /// No description provided for @labDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get labDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @debugLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo home'**
  String get debugLoadDemo;

  /// No description provided for @debugLoadDemoSub.
  ///
  /// In en, this message translates to:
  /// **'Adds sample data for every finished phase'**
  String get debugLoadDemoSub;

  /// No description provided for @debugDemoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded'**
  String get debugDemoLoaded;

  /// No description provided for @debugWipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe this phone'**
  String get debugWipe;

  /// No description provided for @debugWipeSub.
  ///
  /// In en, this message translates to:
  /// **'Erase the database and settings'**
  String get debugWipeSub;

  /// No description provided for @debugWipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase everything on this phone?'**
  String get debugWipeTitle;

  /// No description provided for @debugWipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Wipe'**
  String get debugWipeConfirm;

  /// No description provided for @debugWiped.
  ///
  /// In en, this message translates to:
  /// **'This phone was wiped'**
  String get debugWiped;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @errCantSecure.
  ///
  /// In en, this message translates to:
  /// **'Illam can’t secure data on this phone'**
  String get errCantSecure;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Run your home,\n{em}'**
  String welcomeHeadline(Object em);

  /// No description provided for @welcomeHeadlineEm.
  ///
  /// In en, this message translates to:
  /// **'together.'**
  String get welcomeHeadlineEm;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'House help, groceries, chores, meals and spends — shared between the phones in your home.'**
  String get welcomeSub;

  /// No description provided for @welcomeStartLabel.
  ///
  /// In en, this message translates to:
  /// **'How do you want to start?'**
  String get welcomeStartLabel;

  /// No description provided for @welcomeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a home'**
  String get welcomeCreateTitle;

  /// No description provided for @welcomeCreateBody.
  ///
  /// In en, this message translates to:
  /// **'Set it up for your family. You’ll be the admin and invite the others.'**
  String get welcomeCreateBody;

  /// No description provided for @welcomeJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a home'**
  String get welcomeJoinTitle;

  /// No description provided for @welcomeJoinBody.
  ///
  /// In en, this message translates to:
  /// **'Someone at home already uses Illam. Scan their QR code or type their phrase.'**
  String get welcomeJoinBody;

  /// No description provided for @welcomeHint.
  ///
  /// In en, this message translates to:
  /// **'Only one person creates the home — everyone else joins it.'**
  String get welcomeHint;

  /// No description provided for @welcomeRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get welcomeRestore;

  /// No description provided for @welcomeFine.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud. Your home’s data stays on your family’s phones and syncs directly between them.'**
  String get welcomeFine;

  /// No description provided for @welcomeCreditLine1.
  ///
  /// In en, this message translates to:
  /// **'Made at home, for homes.'**
  String get welcomeCreditLine1;

  /// No description provided for @welcomeCreditLine2.
  ///
  /// In en, this message translates to:
  /// **'with {heart} by Nandini Srinivasan & Karthik Venkatesh'**
  String welcomeCreditLine2(Object heart);

  /// No description provided for @welcomeCreditA11y.
  ///
  /// In en, this message translates to:
  /// **'Made at home, for homes, with love by Nandini Srinivasan and Karthik Venkatesh'**
  String get welcomeCreditA11y;

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your home'**
  String get createTitle;

  /// No description provided for @createSub.
  ///
  /// In en, this message translates to:
  /// **'You’ll be its admin. Others join from their phones with a QR code or a short phrase.'**
  String get createSub;

  /// No description provided for @createYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get createYourName;

  /// No description provided for @createYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anand Kumar'**
  String get createYourNameHint;

  /// No description provided for @createHomeName.
  ///
  /// In en, this message translates to:
  /// **'Home name'**
  String get createHomeName;

  /// No description provided for @createHomeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {surname} Home'**
  String createHomeNameHint(Object surname);

  /// No description provided for @createSuggestHome.
  ///
  /// In en, this message translates to:
  /// **'{surname} Home'**
  String createSuggestHome(Object surname);

  /// No description provided for @createSuggestFlat.
  ///
  /// In en, this message translates to:
  /// **'Our flat'**
  String get createSuggestFlat;

  /// No description provided for @createSuggestAmma.
  ///
  /// In en, this message translates to:
  /// **'Amma’s house'**
  String get createSuggestAmma;

  /// No description provided for @createSurnameFallback.
  ///
  /// In en, this message translates to:
  /// **'Our'**
  String get createSurnameFallback;

  /// No description provided for @createSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get createSuggestionsLabel;

  /// No description provided for @createHomeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Home ID'**
  String get createHomeIdLabel;

  /// No description provided for @createHomeIdNote.
  ///
  /// In en, this message translates to:
  /// **'Made on this phone · unique to your home'**
  String get createHomeIdNote;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create home'**
  String get createButton;

  /// No description provided for @createErrName.
  ///
  /// In en, this message translates to:
  /// **'Add your name.'**
  String get createErrName;

  /// No description provided for @createErrHome.
  ///
  /// In en, this message translates to:
  /// **'Give your home a name.'**
  String get createErrHome;

  /// No description provided for @todayGreetingLate.
  ///
  /// In en, this message translates to:
  /// **'Still up'**
  String get todayGreetingLate;

  /// No description provided for @todayGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get todayGreetingMorning;

  /// No description provided for @todayGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get todayGreetingAfternoon;

  /// No description provided for @todayGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get todayGreetingEvening;

  /// No description provided for @todayEyebrow.
  ///
  /// In en, this message translates to:
  /// **'{home} · {date}'**
  String todayEyebrow(Object home, Object date);

  /// No description provided for @todayHeadlineAllSet.
  ///
  /// In en, this message translates to:
  /// **'The house is {em} today.'**
  String todayHeadlineAllSet(Object em);

  /// No description provided for @todayAllSetEm.
  ///
  /// In en, this message translates to:
  /// **'all set'**
  String get todayAllSetEm;

  /// No description provided for @debugViewAsMember.
  ///
  /// In en, this message translates to:
  /// **'Viewing as member'**
  String get debugViewAsMember;

  /// No description provided for @debugViewAsMemberSub.
  ///
  /// In en, this message translates to:
  /// **'Hide admin-only controls (UI test only)'**
  String get debugViewAsMemberSub;

  /// No description provided for @debugIsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin on this phone: {value}'**
  String debugIsAdmin(Object value);

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @weekdayLetters.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdayLetters;

  /// No description provided for @staffDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get staffDaily;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @staffNotFound.
  ///
  /// In en, this message translates to:
  /// **'This house help isn’t in your home any more.'**
  String get staffNotFound;

  /// No description provided for @staffMarkedIn.
  ///
  /// In en, this message translates to:
  /// **'{name} marked in at {time}'**
  String staffMarkedIn(Object name, Object time);

  /// No description provided for @staffMarkedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} out · {duration} today'**
  String staffMarkedOut(Object name, Object duration);

  /// No description provided for @staffExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected {times}'**
  String staffExpected(Object times);

  /// No description provided for @staffInSince.
  ///
  /// In en, this message translates to:
  /// **'In since {time} · {duration}'**
  String staffInSince(Object time, Object duration);

  /// No description provided for @staffDoneToday.
  ///
  /// In en, this message translates to:
  /// **'{duration} today · out {time}'**
  String staffDoneToday(Object duration, Object time);

  /// No description provided for @staffOnLeaveToday.
  ///
  /// In en, this message translates to:
  /// **'On leave today (informed)'**
  String get staffOnLeaveToday;

  /// No description provided for @staffDayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get staffDayOff;

  /// No description provided for @staffMarkIn.
  ///
  /// In en, this message translates to:
  /// **'Mark in'**
  String get staffMarkIn;

  /// No description provided for @staffMarkOut.
  ///
  /// In en, this message translates to:
  /// **'Mark out'**
  String get staffMarkOut;

  /// No description provided for @staffVisitButton.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get staffVisitButton;

  /// No description provided for @staffChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get staffChange;

  /// No description provided for @staffStartAnother.
  ///
  /// In en, this message translates to:
  /// **'Start another visit for {name}'**
  String staffStartAnother(Object name);

  /// No description provided for @staffHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help at home'**
  String get staffHelpTitle;

  /// No description provided for @staffHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Tap a name for attendance & pay'**
  String get staffHelpSub;

  /// No description provided for @staffNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No house help added yet.'**
  String get staffNoneYet;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get commonFix;

  /// No description provided for @staffAlertNotMarkedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} wasn’t marked out on {day}'**
  String staffAlertNotMarkedOut(Object name, Object day);

  /// No description provided for @staffAlertTwoOpen.
  ///
  /// In en, this message translates to:
  /// **'{name} has 2 open visits'**
  String staffAlertTwoOpen(Object name);

  /// No description provided for @staffAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add house help'**
  String get staffAddTitle;

  /// No description provided for @staffAddLead.
  ///
  /// In en, this message translates to:
  /// **'They don’t need the app. Anyone at home marks them in and out; pay is worked out for you.'**
  String get staffAddLead;

  /// No description provided for @staffName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get staffName;

  /// No description provided for @staffAddNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kamala'**
  String get staffAddNameHint;

  /// No description provided for @staffRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffRole;

  /// No description provided for @staffRoleHouseHelp.
  ///
  /// In en, this message translates to:
  /// **'House help'**
  String get staffRoleHouseHelp;

  /// No description provided for @staffRoleCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get staffRoleCook;

  /// No description provided for @staffRoleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get staffRoleDriver;

  /// No description provided for @staffRoleNanny.
  ///
  /// In en, this message translates to:
  /// **'Nanny'**
  String get staffRoleNanny;

  /// No description provided for @staffRoleGardener.
  ///
  /// In en, this message translates to:
  /// **'Gardener'**
  String get staffRoleGardener;

  /// No description provided for @staffPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get staffPay;

  /// No description provided for @staffPayPerHour.
  ///
  /// In en, this message translates to:
  /// **'Per hour'**
  String get staffPayPerHour;

  /// No description provided for @staffPayPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get staffPayPerMonth;

  /// No description provided for @staffAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get staffAmount;

  /// No description provided for @staffAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 6000'**
  String get staffAmountHint;

  /// No description provided for @staffUsuallyAt.
  ///
  /// In en, this message translates to:
  /// **'Usually comes at'**
  String get staffUsuallyAt;

  /// No description provided for @staffMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile (optional, for WhatsApp)'**
  String get staffMobile;

  /// No description provided for @staffPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the number — 10 digits starting with 6, 7, 8 or 9.'**
  String get staffPhoneInvalid;

  /// No description provided for @staffAddInfo.
  ///
  /// In en, this message translates to:
  /// **'Works Mon–Sat by default; change days and pay rules later on their page.'**
  String get staffAddInfo;

  /// No description provided for @staffAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added · mark them in from Today'**
  String staffAdded(Object name);

  /// No description provided for @staffIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get staffIn;

  /// No description provided for @staffOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get staffOut;

  /// No description provided for @staffErrNoIn.
  ///
  /// In en, this message translates to:
  /// **'Add an in-time, or close this sheet.'**
  String get staffErrNoIn;

  /// No description provided for @staffErrOutBeforeIn.
  ///
  /// In en, this message translates to:
  /// **'Out time has to be after in time.'**
  String get staffErrOutBeforeIn;

  /// No description provided for @staffErrTooLong.
  ///
  /// In en, this message translates to:
  /// **'A visit can’t be longer than 16 hours.'**
  String get staffErrTooLong;

  /// No description provided for @staffOverlap.
  ///
  /// In en, this message translates to:
  /// **'This overlaps another visit at {time}.'**
  String staffOverlap(Object time);

  /// No description provided for @staffOnlyAdminsOlder.
  ///
  /// In en, this message translates to:
  /// **'Only admins can change older visits.'**
  String get staffOnlyAdminsOlder;

  /// No description provided for @staffVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {day}'**
  String staffVisitTitle(Object name, Object day);

  /// No description provided for @staffVisitLeadSome.
  ///
  /// In en, this message translates to:
  /// **'Tapped late or forgot? Fix the time — salary recalculates from this.'**
  String get staffVisitLeadSome;

  /// No description provided for @staffVisitLeadNone.
  ///
  /// In en, this message translates to:
  /// **'No visit recorded. Add one, or mark an informed leave so it isn’t counted as absent.'**
  String get staffVisitLeadNone;

  /// No description provided for @staffNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get staffNow;

  /// No description provided for @staffAddVisit.
  ///
  /// In en, this message translates to:
  /// **'Add visit'**
  String get staffAddVisit;

  /// No description provided for @staffEditVisit.
  ///
  /// In en, this message translates to:
  /// **'Edit visit'**
  String get staffEditVisit;

  /// No description provided for @staffRemoveVisit.
  ///
  /// In en, this message translates to:
  /// **'Remove visit'**
  String get staffRemoveVisit;

  /// No description provided for @staffSettledNotice.
  ///
  /// In en, this message translates to:
  /// **'{month} is settled — changes will show as a difference to pay'**
  String staffSettledNotice(Object month);

  /// No description provided for @staffVisitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Visit updated · salary recalculated'**
  String get staffVisitUpdated;

  /// No description provided for @staffVisitRemoved.
  ///
  /// In en, this message translates to:
  /// **'Visit removed'**
  String get staffVisitRemoved;

  /// No description provided for @staffInformedLeave.
  ///
  /// In en, this message translates to:
  /// **'Informed leave'**
  String get staffInformedLeave;

  /// No description provided for @staffUndoLeave.
  ///
  /// In en, this message translates to:
  /// **'Undo leave'**
  String get staffUndoLeave;

  /// No description provided for @staffLeaveMarked.
  ///
  /// In en, this message translates to:
  /// **'{day} marked as informed leave'**
  String staffLeaveMarked(Object day);

  /// No description provided for @staffLeaveRemoved.
  ///
  /// In en, this message translates to:
  /// **'Leave removed'**
  String get staffLeaveRemoved;

  /// No description provided for @staffCall.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String staffCall(Object name);

  /// No description provided for @staffWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp {name}'**
  String staffWhatsApp(Object name);

  /// No description provided for @staffEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get staffEditDetails;

  /// No description provided for @staffRoleWindow.
  ///
  /// In en, this message translates to:
  /// **'{role} · {window}'**
  String staffRoleWindow(Object role, Object window);

  /// No description provided for @staffPayHourlyLine.
  ///
  /// In en, this message translates to:
  /// **'{rate}/hour'**
  String staffPayHourlyLine(Object rate);

  /// No description provided for @staffPayMonthlyLine.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month'**
  String staffPayMonthlyLine(Object amount);

  /// No description provided for @staffFormerTag.
  ///
  /// In en, this message translates to:
  /// **'Former house help'**
  String get staffFormerTag;

  /// No description provided for @staffUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI ID (optional)'**
  String get staffUpi;

  /// No description provided for @staffWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Work days'**
  String get staffWorkDays;

  /// No description provided for @staffAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add a second time'**
  String get staffAddTime;

  /// No description provided for @staffDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Details saved'**
  String get staffDetailsSaved;

  /// No description provided for @staffMonthAttendance.
  ///
  /// In en, this message translates to:
  /// **'{month} attendance'**
  String staffMonthAttendance(Object month);

  /// No description provided for @staffPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get staffPrevMonth;

  /// No description provided for @staffNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get staffNextMonth;

  /// No description provided for @staffCellWorked.
  ///
  /// In en, this message translates to:
  /// **'{day}: worked {duration}'**
  String staffCellWorked(Object day, Object duration);

  /// No description provided for @staffCellAbsent.
  ///
  /// In en, this message translates to:
  /// **'{day}: absent'**
  String staffCellAbsent(Object day);

  /// No description provided for @staffCellLeave.
  ///
  /// In en, this message translates to:
  /// **'{day}: informed leave'**
  String staffCellLeave(Object day);

  /// No description provided for @staffCellOff.
  ///
  /// In en, this message translates to:
  /// **'{day}: day off'**
  String staffCellOff(Object day);

  /// No description provided for @staffCellUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{day}: upcoming'**
  String staffCellUpcoming(Object day);

  /// No description provided for @staffCellNotMarked.
  ///
  /// In en, this message translates to:
  /// **'{day}: not marked yet'**
  String staffCellNotMarked(Object day);

  /// No description provided for @staffCellBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'{day}: before start'**
  String staffCellBeforeStart(Object day);

  /// No description provided for @staffLegendWorked.
  ///
  /// In en, this message translates to:
  /// **'Worked (stronger = longer)'**
  String get staffLegendWorked;

  /// No description provided for @staffLegendAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get staffLegendAbsent;

  /// No description provided for @staffLegendLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get staffLegendLeave;

  /// No description provided for @staffStatPresent.
  ///
  /// In en, this message translates to:
  /// **'Days present'**
  String get staffStatPresent;

  /// No description provided for @staffStatAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get staffStatAbsent;

  /// No description provided for @staffStatHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get staffStatHours;

  /// No description provided for @staffVisitLog.
  ///
  /// In en, this message translates to:
  /// **'Visit log'**
  String get staffVisitLog;

  /// No description provided for @staffVisitLogHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to fix a time'**
  String get staffVisitLogHint;

  /// No description provided for @staffSalaryButton.
  ///
  /// In en, this message translates to:
  /// **'{month} salary'**
  String staffSalaryButton(Object month);

  /// No description provided for @staffRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from home'**
  String staffRemoveButton(Object name);

  /// No description provided for @staffRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String staffRemoveTitle(Object name);

  /// No description provided for @staffRemoveLead.
  ///
  /// In en, this message translates to:
  /// **'They disappear from Today and attendance. Salary already paid stays in Money.'**
  String get staffRemoveLead;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @staffRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String staffRemoved(Object name);

  /// No description provided for @staffRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get staffRestore;

  /// No description provided for @staffRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String staffRestored(Object name);

  /// No description provided for @staffFormerCount.
  ///
  /// In en, this message translates to:
  /// **'Former house help ({count})'**
  String staffFormerCount(int count);

  /// No description provided for @salaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}’s salary'**
  String salaryTitle(Object name);

  /// No description provided for @salarySubtitleSoFar.
  ///
  /// In en, this message translates to:
  /// **'{month} 1 – {day} · so far'**
  String salarySubtitleSoFar(Object month, Object day);

  /// No description provided for @salarySubtitleProjected.
  ///
  /// In en, this message translates to:
  /// **'{month} 1 – {day} · projected'**
  String salarySubtitleProjected(Object month, Object day);

  /// No description provided for @salarySubtitlePast.
  ///
  /// In en, this message translates to:
  /// **'{month} 1 – {day}'**
  String salarySubtitlePast(Object month, Object day);

  /// No description provided for @salaryFootnote.
  ///
  /// In en, this message translates to:
  /// **'Every number traces back to the visit log. Fix a wrong time there and this updates instantly.'**
  String get salaryFootnote;

  /// No description provided for @salaryNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Not working in {month}'**
  String salaryNotWorking(Object month);

  /// No description provided for @salaryNoRules.
  ///
  /// In en, this message translates to:
  /// **'No pay rules yet'**
  String get salaryNoRules;

  /// No description provided for @salaryNoRulesBody.
  ///
  /// In en, this message translates to:
  /// **'Set the hourly rate or monthly salary to see what to pay.'**
  String get salaryNoRulesBody;

  /// No description provided for @salarySetRules.
  ///
  /// In en, this message translates to:
  /// **'Set pay rules'**
  String get salarySetRules;

  /// No description provided for @salaryEyebrowPayable.
  ///
  /// In en, this message translates to:
  /// **'PAYABLE'**
  String get salaryEyebrowPayable;

  /// No description provided for @salaryEyebrowPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get salaryEyebrowPaid;

  /// No description provided for @salaryDaysLine.
  ///
  /// In en, this message translates to:
  /// **'{present} days present · {absent} absent · {leave} leave'**
  String salaryDaysLine(Object present, Object absent, Object leave);

  /// No description provided for @salaryCarryPreview.
  ///
  /// In en, this message translates to:
  /// **'₹0 to pay · {amount} will carry to {month}'**
  String salaryCarryPreview(Object amount, Object month);

  /// No description provided for @salaryHoursWorked.
  ///
  /// In en, this message translates to:
  /// **'Hours worked'**
  String get salaryHoursWorked;

  /// No description provided for @salaryHoursDetail.
  ///
  /// In en, this message translates to:
  /// **'{billed} billed × {rate}/hr · {visits} visits · actual {actual}. Each visit rounded to {rounding}{minimum}'**
  String salaryHoursDetail(
    Object billed,
    Object rate,
    Object visits,
    Object actual,
    Object rounding,
    Object minimum,
  );

  /// No description provided for @salaryRoundMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String salaryRoundMinutes(Object n);

  /// No description provided for @salaryRoundTheMinute.
  ///
  /// In en, this message translates to:
  /// **'the minute'**
  String get salaryRoundTheMinute;

  /// No description provided for @salaryMinimumPart.
  ///
  /// In en, this message translates to:
  /// **', min {hours} hr'**
  String salaryMinimumPart(Object hours);

  /// No description provided for @salaryMonthlyLine.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary'**
  String get salaryMonthlyLine;

  /// No description provided for @salaryMonthlyDetail.
  ///
  /// In en, this message translates to:
  /// **'{workDays} working days · {perDay}/day'**
  String salaryMonthlyDetail(Object workDays, Object perDay);

  /// No description provided for @salaryLeavesLine.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get salaryLeavesLine;

  /// No description provided for @salaryLeavesDetail.
  ///
  /// In en, this message translates to:
  /// **'{taken} taken · {paid} paid · {unpaid} unpaid'**
  String salaryLeavesDetail(Object taken, Object paid, Object unpaid);

  /// No description provided for @salaryExtraDetail.
  ///
  /// In en, this message translates to:
  /// **'Extra task'**
  String get salaryExtraDetail;

  /// No description provided for @salaryAdvanceLine.
  ///
  /// In en, this message translates to:
  /// **'Advance taken'**
  String get salaryAdvanceLine;

  /// No description provided for @salaryAdvanceDetail.
  ///
  /// In en, this message translates to:
  /// **'Deducted this month'**
  String get salaryAdvanceDetail;

  /// No description provided for @salaryDeductionDetail.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get salaryDeductionDetail;

  /// No description provided for @salaryToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get salaryToPay;

  /// No description provided for @salaryChipRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}/hr'**
  String salaryChipRate(Object rate);

  /// No description provided for @salaryChipMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String salaryChipMonthly(Object amount);

  /// No description provided for @salaryChipRound.
  ///
  /// In en, this message translates to:
  /// **'Round {n} min'**
  String salaryChipRound(Object n);

  /// No description provided for @salaryChipExact.
  ///
  /// In en, this message translates to:
  /// **'Exact minutes'**
  String get salaryChipExact;

  /// No description provided for @salaryChipPaidLeaves.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 paid leave} other{{n} paid leaves}}'**
  String salaryChipPaidLeaves(int n);

  /// No description provided for @salaryEditRules.
  ///
  /// In en, this message translates to:
  /// **'Edit pay rules'**
  String get salaryEditRules;

  /// No description provided for @salaryAdminsSetRules.
  ///
  /// In en, this message translates to:
  /// **'Admins set pay rules'**
  String get salaryAdminsSetRules;

  /// No description provided for @salaryPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get salaryPrevMonth;

  /// No description provided for @salaryNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get salaryNextMonth;

  /// No description provided for @salaryMarkPaidButton.
  ///
  /// In en, this message translates to:
  /// **'Mark {amount} as paid'**
  String salaryMarkPaidButton(Object amount);

  /// No description provided for @salaryCloseAtZero.
  ///
  /// In en, this message translates to:
  /// **'Close {month} at ₹0'**
  String salaryCloseAtZero(Object month);

  /// No description provided for @salaryClosedSnack.
  ///
  /// In en, this message translates to:
  /// **'{month} closed at ₹0'**
  String salaryClosedSnack(Object month);

  /// No description provided for @salaryCarryNote.
  ///
  /// In en, this message translates to:
  /// **'Carried from {month}'**
  String salaryCarryNote(Object month);

  /// No description provided for @salaryMemberNote.
  ///
  /// In en, this message translates to:
  /// **'Only admins pay salary. Ask {names} — you’ll see it here once paid.'**
  String salaryMemberNote(Object names);

  /// No description provided for @salaryYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get salaryYou;

  /// No description provided for @salaryNamesOr.
  ///
  /// In en, this message translates to:
  /// **'{first} or {second}'**
  String salaryNamesOr(Object first, Object second);

  /// No description provided for @salaryPaidTag.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount} on {date} · {method}'**
  String salaryPaidTag(Object amount, Object date, Object method);

  /// No description provided for @salaryClosedTag.
  ///
  /// In en, this message translates to:
  /// **'Closed at ₹0 on {date}'**
  String salaryClosedTag(Object date);

  /// No description provided for @salaryUndoPayment.
  ///
  /// In en, this message translates to:
  /// **'Undo payment'**
  String get salaryUndoPayment;

  /// No description provided for @salaryUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo payment?'**
  String get salaryUndoTitle;

  /// No description provided for @salaryUndoLead.
  ///
  /// In en, this message translates to:
  /// **'The {amount} salary spend is removed and {month} can be paid again.'**
  String salaryUndoLead(Object amount, Object month);

  /// No description provided for @salaryUndoneSnack.
  ///
  /// In en, this message translates to:
  /// **'Payment undone'**
  String get salaryUndoneSnack;

  /// No description provided for @salaryMethodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get salaryMethodUpi;

  /// No description provided for @salaryMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get salaryMethodCash;

  /// No description provided for @salaryMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get salaryMethodBank;

  /// No description provided for @salaryDuplicateAlert.
  ///
  /// In en, this message translates to:
  /// **'{name}’s {month} salary was marked paid twice ({a} by {x}, {b} by {y}). The first is kept — check you didn’t pay twice.'**
  String salaryDuplicateAlert(
    Object name,
    Object month,
    Object a,
    Object x,
    Object b,
    Object y,
  );

  /// No description provided for @salaryUndoSecond.
  ///
  /// In en, this message translates to:
  /// **'Undo the second payment'**
  String get salaryUndoSecond;

  /// No description provided for @salaryDifferenceAlert.
  ///
  /// In en, this message translates to:
  /// **'Recalculated {x} — settled at {y}. Difference {z}'**
  String salaryDifferenceAlert(Object x, Object y, Object z);

  /// No description provided for @salaryAddToMonth.
  ///
  /// In en, this message translates to:
  /// **'Add to {month}'**
  String salaryAddToMonth(Object month);

  /// No description provided for @salaryDifferenceNote.
  ///
  /// In en, this message translates to:
  /// **'Difference from {month}'**
  String salaryDifferenceNote(Object month);

  /// No description provided for @salaryDifferenceSnack.
  ///
  /// In en, this message translates to:
  /// **'Difference added to {month}'**
  String salaryDifferenceSnack(Object month);

  /// No description provided for @salarySharePaySlip.
  ///
  /// In en, this message translates to:
  /// **'Share pay slip with {name}'**
  String salarySharePaySlip(Object name);

  /// No description provided for @salaryRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}’s pay rules'**
  String salaryRulesTitle(Object name);

  /// No description provided for @salaryRulesLead.
  ///
  /// In en, this message translates to:
  /// **'Agreed once, applied every month. Shown on the pay slip so there are no surprises.'**
  String get salaryRulesLead;

  /// No description provided for @salaryPayType.
  ///
  /// In en, this message translates to:
  /// **'Pay type'**
  String get salaryPayType;

  /// No description provided for @salaryHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get salaryHourly;

  /// No description provided for @salaryMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get salaryMonthly;

  /// No description provided for @salaryRatePerHour.
  ///
  /// In en, this message translates to:
  /// **'Rate per hour (₹)'**
  String get salaryRatePerHour;

  /// No description provided for @salaryRoundTo.
  ///
  /// In en, this message translates to:
  /// **'Round each visit to'**
  String get salaryRoundTo;

  /// No description provided for @salaryRoundExactMinute.
  ///
  /// In en, this message translates to:
  /// **'Exact minute'**
  String get salaryRoundExactMinute;

  /// No description provided for @salaryRound15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get salaryRound15;

  /// No description provided for @salaryRound30.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get salaryRound30;

  /// No description provided for @salaryMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum per visit'**
  String get salaryMinimum;

  /// No description provided for @salaryMinNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get salaryMinNone;

  /// No description provided for @salaryMin1.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get salaryMin1;

  /// No description provided for @salaryMin2.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get salaryMin2;

  /// No description provided for @salaryMonthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary (₹)'**
  String get salaryMonthlyAmount;

  /// No description provided for @salaryPaidLeaves.
  ///
  /// In en, this message translates to:
  /// **'Paid leaves per month'**
  String get salaryPaidLeaves;

  /// No description provided for @salaryWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Work days'**
  String get salaryWorkDays;

  /// No description provided for @salaryDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get salaryDayMon;

  /// No description provided for @salaryDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get salaryDayTue;

  /// No description provided for @salaryDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get salaryDayWed;

  /// No description provided for @salaryDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get salaryDayThu;

  /// No description provided for @salaryDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get salaryDayFri;

  /// No description provided for @salaryDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get salaryDaySat;

  /// No description provided for @salaryDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get salaryDaySun;

  /// No description provided for @salaryApplyFrom.
  ///
  /// In en, this message translates to:
  /// **'Apply from'**
  String get salaryApplyFrom;

  /// No description provided for @salaryThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get salaryThisMonth;

  /// No description provided for @salaryNextMonthChip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get salaryNextMonthChip;

  /// No description provided for @salarySaveRules.
  ///
  /// In en, this message translates to:
  /// **'Save rules'**
  String get salarySaveRules;

  /// No description provided for @salaryRulesSaved.
  ///
  /// In en, this message translates to:
  /// **'Pay rules saved · salary recalculated'**
  String get salaryRulesSaved;

  /// No description provided for @salaryCheckAmount.
  ///
  /// In en, this message translates to:
  /// **'Check the amount'**
  String get salaryCheckAmount;

  /// No description provided for @salaryAdjustmentsFor.
  ///
  /// In en, this message translates to:
  /// **'Adjustments for {month}'**
  String salaryAdjustmentsFor(Object month);

  /// No description provided for @salaryAddExtra.
  ///
  /// In en, this message translates to:
  /// **'+ Add extra'**
  String get salaryAddExtra;

  /// No description provided for @salaryAddAdvance.
  ///
  /// In en, this message translates to:
  /// **'+ Add advance'**
  String get salaryAddAdvance;

  /// No description provided for @salaryAddDeduction.
  ///
  /// In en, this message translates to:
  /// **'+ Add deduction'**
  String get salaryAddDeduction;

  /// No description provided for @salaryAdjNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get salaryAdjNote;

  /// No description provided for @salaryAdjAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get salaryAdjAmount;

  /// No description provided for @salaryAdjSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get salaryAdjSave;

  /// No description provided for @salaryAdjRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get salaryAdjRemove;

  /// No description provided for @salaryAdjAdded.
  ///
  /// In en, this message translates to:
  /// **'Adjustment added · salary recalculated'**
  String get salaryAdjAdded;

  /// No description provided for @salaryAdjRemoved.
  ///
  /// In en, this message translates to:
  /// **'Adjustment removed'**
  String get salaryAdjRemoved;

  /// No description provided for @salaryAdjLocked.
  ///
  /// In en, this message translates to:
  /// **'{month} is settled — adjustments are locked.'**
  String salaryAdjLocked(Object month);

  /// No description provided for @salaryKindExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get salaryKindExtra;

  /// No description provided for @salaryKindAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get salaryKindAdvance;

  /// No description provided for @salaryKindDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get salaryKindDeduction;

  /// No description provided for @salaryMarkPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark {amount} as paid?'**
  String salaryMarkPaidTitle(Object amount);

  /// No description provided for @salaryPaidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get salaryPaidWith;

  /// No description provided for @salaryMarkPaidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get salaryMarkPaidConfirm;

  /// No description provided for @salaryPaidSnack.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid to {name} · added to spends'**
  String salaryPaidSnack(Object amount, Object name);

  /// No description provided for @salaryExpenseMerchant.
  ///
  /// In en, this message translates to:
  /// **'{name} — {month} salary'**
  String salaryExpenseMerchant(Object name, Object month);

  /// No description provided for @salarySlipHeader.
  ///
  /// In en, this message translates to:
  /// **'{month} pay — {name}'**
  String salarySlipHeader(Object month, Object name);

  /// No description provided for @salarySlipDaysHours.
  ///
  /// In en, this message translates to:
  /// **'Days: {present} · Hours: {billed}'**
  String salarySlipDaysHours(Object present, Object billed);

  /// No description provided for @salarySlipHoursCalc.
  ///
  /// In en, this message translates to:
  /// **'{billed} × {rate} = {gross}'**
  String salarySlipHoursCalc(Object billed, Object rate, Object gross);

  /// No description provided for @salarySlipExtra.
  ///
  /// In en, this message translates to:
  /// **'+ {label}: {amount}'**
  String salarySlipExtra(Object label, Object amount);

  /// No description provided for @salarySlipAdvance.
  ///
  /// In en, this message translates to:
  /// **'− Advance: {amount}'**
  String salarySlipAdvance(Object amount);

  /// No description provided for @salarySlipDeduction.
  ///
  /// In en, this message translates to:
  /// **'− {label}: {amount}'**
  String salarySlipDeduction(Object label, Object amount);

  /// No description provided for @salarySlipSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary: {amount}'**
  String salarySlipSalary(Object amount);

  /// No description provided for @salarySlipLeaves.
  ///
  /// In en, this message translates to:
  /// **'Leaves: {taken} ({paid} paid)'**
  String salarySlipLeaves(Object taken, Object paid);

  /// No description provided for @salarySlipTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String salarySlipTotal(Object amount);

  /// No description provided for @salarySlipTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay slip'**
  String get salarySlipTitle;

  /// No description provided for @salarySlipLead.
  ///
  /// In en, this message translates to:
  /// **'A clear breakdown builds trust and ends “how did you calculate?” conversations.'**
  String get salarySlipLead;

  /// No description provided for @salarySlipSend.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp'**
  String get salarySlipSend;

  /// No description provided for @salaryRuleHourlyRounded.
  ///
  /// In en, this message translates to:
  /// **'{rate}/hour · rounded to {n} min'**
  String salaryRuleHourlyRounded(Object rate, Object n);

  /// No description provided for @salaryRuleHourlyExact.
  ///
  /// In en, this message translates to:
  /// **'{rate}/hour · exact minutes'**
  String salaryRuleHourlyExact(Object rate);

  /// No description provided for @salaryRuleMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month · {n, plural, =1{1 paid leave} other{{n} paid leaves}}'**
  String salaryRuleMonthly(Object amount, int n);

  /// No description provided for @salaryStaffButton.
  ///
  /// In en, this message translates to:
  /// **'{month} salary · {amount}'**
  String salaryStaffButton(Object month, Object amount);

  /// No description provided for @listsChannelZepto.
  ///
  /// In en, this message translates to:
  /// **'Zepto'**
  String get listsChannelZepto;

  /// No description provided for @listsChannelBlinkit.
  ///
  /// In en, this message translates to:
  /// **'Blinkit'**
  String get listsChannelBlinkit;

  /// No description provided for @listsChannelBigbasket.
  ///
  /// In en, this message translates to:
  /// **'BigBasket'**
  String get listsChannelBigbasket;

  /// No description provided for @listsChannelAmazon.
  ///
  /// In en, this message translates to:
  /// **'Amazon'**
  String get listsChannelAmazon;

  /// No description provided for @listsChannelFlipkart.
  ///
  /// In en, this message translates to:
  /// **'Flipkart'**
  String get listsChannelFlipkart;

  /// No description provided for @listsChannelMeesho.
  ///
  /// In en, this message translates to:
  /// **'Meesho'**
  String get listsChannelMeesho;

  /// No description provided for @listsChannelOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get listsChannelOffline;

  /// No description provided for @listsEtaZepto.
  ///
  /// In en, this message translates to:
  /// **'~10 min'**
  String get listsEtaZepto;

  /// No description provided for @listsEtaBlinkit.
  ///
  /// In en, this message translates to:
  /// **'~10 min'**
  String get listsEtaBlinkit;

  /// No description provided for @listsEtaBigbasket.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow 7–9 AM'**
  String get listsEtaBigbasket;

  /// No description provided for @listsEtaAmazon.
  ///
  /// In en, this message translates to:
  /// **'1–2 days'**
  String get listsEtaAmazon;

  /// No description provided for @listsEtaFlipkart.
  ///
  /// In en, this message translates to:
  /// **'2–3 days'**
  String get listsEtaFlipkart;

  /// No description provided for @listsEtaMeesho.
  ///
  /// In en, this message translates to:
  /// **'4–6 days'**
  String get listsEtaMeesho;

  /// No description provided for @listsEtaOffline.
  ///
  /// In en, this message translates to:
  /// **'Local store / D-Mart'**
  String get listsEtaOffline;

  /// No description provided for @listsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get listsEyebrow;

  /// No description provided for @listsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTitle;

  /// No description provided for @listsStoreMode.
  ///
  /// In en, this message translates to:
  /// **'Store mode'**
  String get listsStoreMode;

  /// No description provided for @listsGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get listsGrocery;

  /// No description provided for @listsShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get listsShopping;

  /// No description provided for @listsPlaceholderGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add “Milk 2L”, “Onions 1kg”…'**
  String get listsPlaceholderGrocery;

  /// No description provided for @listsPlaceholderShopping.
  ///
  /// In en, this message translates to:
  /// **'Add “Phone charger”…'**
  String get listsPlaceholderShopping;

  /// No description provided for @listsStoreButton.
  ///
  /// In en, this message translates to:
  /// **'Buy from {store}. Change'**
  String listsStoreButton(Object store);

  /// No description provided for @listsAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get listsAddTooltip;

  /// No description provided for @listsHintIdle.
  ///
  /// In en, this message translates to:
  /// **'Tip: quantities are understood — “Rice 5kg”.'**
  String get listsHintIdle;

  /// No description provided for @listsHint.
  ///
  /// In en, this message translates to:
  /// **'{item} → {store}{usual}'**
  String listsHint(Object item, Object store, Object usual);

  /// No description provided for @listsHintItemQty.
  ///
  /// In en, this message translates to:
  /// **'{name} · {qty}'**
  String listsHintItemQty(Object name, Object qty);

  /// No description provided for @listsHintUsual.
  ///
  /// In en, this message translates to:
  /// **' (where you usually buy it)'**
  String get listsHintUsual;

  /// No description provided for @listsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {name} → {store}'**
  String listsAdded(Object name, Object store);

  /// No description provided for @listsMerged.
  ///
  /// In en, this message translates to:
  /// **'{name} was already on the list — now {qty}'**
  String listsMerged(Object name, Object qty);

  /// No description provided for @listsAlready.
  ///
  /// In en, this message translates to:
  /// **'{name} is already on the list ({qty})'**
  String listsAlready(Object name, Object qty);

  /// No description provided for @listsPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Where will you buy it?'**
  String get listsPickerTitle;

  /// No description provided for @listsPickerLead.
  ///
  /// In en, this message translates to:
  /// **'New items go here. Items you’ve bought before go to their usual store automatically.'**
  String get listsPickerLead;

  /// No description provided for @listsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get listsAll;

  /// No description provided for @listsToBuy.
  ///
  /// In en, this message translates to:
  /// **'{n} to buy · {eta}'**
  String listsToBuy(int n, Object eta);

  /// No description provided for @listsOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get listsOrder;

  /// No description provided for @listsShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get listsShop;

  /// No description provided for @listsGotSemantics.
  ///
  /// In en, this message translates to:
  /// **'Got {name}'**
  String listsGotSemantics(Object name);

  /// No description provided for @listsLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get listsLess;

  /// No description provided for @listsMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get listsMore;

  /// No description provided for @listsCheckQty.
  ///
  /// In en, this message translates to:
  /// **'Check quantity'**
  String get listsCheckQty;

  /// No description provided for @listsGot.
  ///
  /// In en, this message translates to:
  /// **'Got {name}'**
  String listsGot(Object name);

  /// No description provided for @listsAllBought.
  ///
  /// In en, this message translates to:
  /// **'All bought from {store}.'**
  String listsAllBought(Object store);

  /// No description provided for @listsGotFooter.
  ///
  /// In en, this message translates to:
  /// **'Got: {names}'**
  String listsGotFooter(Object names);

  /// No description provided for @listsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get listsClear;

  /// No description provided for @listsCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {n} · they’re in Buy again'**
  String listsCleared(int n);

  /// No description provided for @listsItemLead.
  ///
  /// In en, this message translates to:
  /// **'{qty} · {category} · on {list, select, grocery{grocery} other{shopping}} list'**
  String listsItemLead(Object qty, Object category, String list);

  /// No description provided for @listsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get listsName;

  /// No description provided for @listsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get listsQuantity;

  /// No description provided for @listsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get listsUnit;

  /// No description provided for @listsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get listsCategory;

  /// No description provided for @listsMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get listsMoveTo;

  /// No description provided for @listsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get listsRemove;

  /// No description provided for @listsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get listsRemoved;

  /// No description provided for @listsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get listsSave;

  /// No description provided for @listsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get listsSaved;

  /// No description provided for @listsMoved.
  ///
  /// In en, this message translates to:
  /// **'{name} → {store}. We’ll remember that.'**
  String listsMoved(Object name, Object store);

  /// No description provided for @listsMergeAsk.
  ///
  /// In en, this message translates to:
  /// **'Merge with {name} ({qty})?'**
  String listsMergeAsk(Object name, Object qty);

  /// No description provided for @listsMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get listsMerge;

  /// No description provided for @listsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get listsCancel;

  /// No description provided for @listsBuyAgain.
  ///
  /// In en, this message translates to:
  /// **'Buy again'**
  String get listsBuyAgain;

  /// No description provided for @listsBuyAgainChip.
  ///
  /// In en, this message translates to:
  /// **'+ {name}'**
  String listsBuyAgainChip(Object name);

  /// No description provided for @todayReadyToOrder.
  ///
  /// In en, this message translates to:
  /// **'Ready to order'**
  String get todayReadyToOrder;

  /// No description provided for @todayListsLink.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get todayListsLink;

  /// No description provided for @todayPillCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 item} other{{n} items}}'**
  String todayPillCount(int n);

  /// No description provided for @todayStoreRun.
  ///
  /// In en, this message translates to:
  /// **'store run'**
  String get todayStoreRun;

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'Store mode'**
  String get storeTitle;

  /// No description provided for @storeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get storeBack;

  /// No description provided for @storeProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} picked · screen stays on'**
  String storeProgress(int done, int total);

  /// No description provided for @storeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy offline'**
  String get storeEmptyTitle;

  /// No description provided for @storeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Move items here from any list.'**
  String get storeEmptyBody;

  /// No description provided for @storeDoneLogBill.
  ///
  /// In en, this message translates to:
  /// **'Done · log the bill'**
  String get storeDoneLogBill;

  /// No description provided for @storeLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log this bill'**
  String get storeLogTitle;

  /// No description provided for @storeLogLead.
  ///
  /// In en, this message translates to:
  /// **'Keeps offline shopping in your monthly spends.'**
  String get storeLogLead;

  /// No description provided for @storeBillAmount.
  ///
  /// In en, this message translates to:
  /// **'Bill amount (₹)'**
  String get storeBillAmount;

  /// No description provided for @storeStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeStore;

  /// No description provided for @storeDMart.
  ///
  /// In en, this message translates to:
  /// **'D-Mart'**
  String get storeDMart;

  /// No description provided for @storeKirana.
  ///
  /// In en, this message translates to:
  /// **'Kirana'**
  String get storeKirana;

  /// No description provided for @storeSabzi.
  ///
  /// In en, this message translates to:
  /// **'Sabzi market'**
  String get storeSabzi;

  /// No description provided for @storeReliance.
  ///
  /// In en, this message translates to:
  /// **'Reliance Fresh'**
  String get storeReliance;

  /// No description provided for @storeOther.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get storeOther;

  /// No description provided for @storeOtherName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeOtherName;

  /// No description provided for @storePaidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get storePaidWith;

  /// No description provided for @storeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get storeCash;

  /// No description provided for @storeUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get storeUpi;

  /// No description provided for @storeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get storeCard;

  /// No description provided for @storeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get storeSkip;

  /// No description provided for @storeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get storeSave;

  /// No description provided for @storeCheckAmount.
  ///
  /// In en, this message translates to:
  /// **'Check the amount'**
  String get storeCheckAmount;

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Which store was it?'**
  String get storeNameRequired;

  /// No description provided for @storeLogged.
  ///
  /// In en, this message translates to:
  /// **'{amount} at {store} logged'**
  String storeLogged(Object amount, Object store);

  /// No description provided for @storeTripDone.
  ///
  /// In en, this message translates to:
  /// **'Trip done · picked items cleared'**
  String get storeTripDone;

  /// No description provided for @storeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open {store}. The list is copied — paste it in the app.'**
  String storeOpenFailed(Object store);

  /// No description provided for @storeBackFrom.
  ///
  /// In en, this message translates to:
  /// **'Back from {store}?'**
  String storeBackFrom(Object store);

  /// No description provided for @storeBackLead.
  ///
  /// In en, this message translates to:
  /// **'We copied the list and opened {store}. Shown when you return to Illam, so the list stays honest.'**
  String storeBackLead(Object store);

  /// No description provided for @storeUnitChanged.
  ///
  /// In en, this message translates to:
  /// **'now {qty} — tick to mark all as ordered'**
  String storeUnitChanged(Object qty);

  /// No description provided for @storeNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get storeNotYet;

  /// No description provided for @storeOrderedAll.
  ///
  /// In en, this message translates to:
  /// **'Ordered all'**
  String get storeOrderedAll;

  /// No description provided for @storeOrderedN.
  ///
  /// In en, this message translates to:
  /// **'Ordered {n}'**
  String storeOrderedN(int n);

  /// No description provided for @storeOrderedNote.
  ///
  /// In en, this message translates to:
  /// **'{qty} ordered on {store}'**
  String storeOrderedNote(Object qty, Object store);

  /// No description provided for @storeMarkedOrdered.
  ///
  /// In en, this message translates to:
  /// **'Marked ordered'**
  String get storeMarkedOrdered;

  /// No description provided for @storeOrderedOn.
  ///
  /// In en, this message translates to:
  /// **'Ordered on {store} ✓'**
  String storeOrderedOn(Object store);

  /// No description provided for @storeHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much was it? Add it now so this month’s total stays right.'**
  String get storeHowMuch;

  /// No description provided for @storeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get storeAmount;

  /// No description provided for @storeCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get storeCashOnDelivery;

  /// No description provided for @storeAddLater.
  ///
  /// In en, this message translates to:
  /// **'Add later'**
  String get storeAddLater;

  /// No description provided for @storeOrderAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount} {store} order added'**
  String storeOrderAdded(Object amount, Object store);

  /// No description provided for @tasksYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tasksYou;

  /// No description provided for @tasksEyebrow.
  ///
  /// In en, this message translates to:
  /// **'KEEP THE HOUSE'**
  String get tasksEyebrow;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksCleaningTab.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get tasksCleaningTab;

  /// No description provided for @tasksTodosTab.
  ///
  /// In en, this message translates to:
  /// **'To-dos'**
  String get tasksTodosTab;

  /// No description provided for @tasksEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get tasksEveryone;

  /// No description provided for @tasksOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue {n}d'**
  String tasksOverdue(int n);

  /// No description provided for @tasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get tasksDueToday;

  /// No description provided for @tasksDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get tasksDueTomorrow;

  /// No description provided for @tasksInDays.
  ///
  /// In en, this message translates to:
  /// **'In {n} days'**
  String tasksInDays(int n);

  /// No description provided for @tasksFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get tasksFreqDaily;

  /// No description provided for @tasksFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get tasksFreqWeekly;

  /// No description provided for @tasksFreqFortnightly.
  ///
  /// In en, this message translates to:
  /// **'Fortnightly'**
  String get tasksFreqFortnightly;

  /// No description provided for @tasksFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get tasksFreqMonthly;

  /// No description provided for @tasksFreqEvery3Months.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get tasksFreqEvery3Months;

  /// No description provided for @tasksFreqEveryN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String tasksFreqEveryN(int n);

  /// No description provided for @tasksRoutineMeta.
  ///
  /// In en, this message translates to:
  /// **'{who} · {room} · {freq}'**
  String tasksRoutineMeta(Object who, Object room, Object freq);

  /// No description provided for @tasksFreshness.
  ///
  /// In en, this message translates to:
  /// **'Freshness'**
  String get tasksFreshness;

  /// No description provided for @tasksDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksDone;

  /// No description provided for @tasksMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} done'**
  String tasksMarkDone(Object name);

  /// No description provided for @tasksRoutineDone.
  ///
  /// In en, this message translates to:
  /// **'{name} done · next {n, plural, =1{tomorrow} other{in {n} days}}'**
  String tasksRoutineDone(Object name, int n);

  /// No description provided for @tasksNoRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines here'**
  String get tasksNoRoutines;

  /// No description provided for @tasksNoRoutinesBody.
  ///
  /// In en, this message translates to:
  /// **'Assign one to {who}.'**
  String tasksNoRoutinesBody(Object who);

  /// No description provided for @tasksAnyone.
  ///
  /// In en, this message translates to:
  /// **'anyone'**
  String get tasksAnyone;

  /// No description provided for @tasksNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get tasksNewRoutine;

  /// No description provided for @tasksNewRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get tasksNewRoutineTitle;

  /// No description provided for @tasksRoutineLead.
  ///
  /// In en, this message translates to:
  /// **'It comes back on its own — no need to re-add it.'**
  String get tasksRoutineLead;

  /// No description provided for @tasksWhatNeedsDoing.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get tasksWhatNeedsDoing;

  /// No description provided for @tasksRoutinePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Check water filter, clean chimney'**
  String get tasksRoutinePlaceholder;

  /// No description provided for @tasksNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Add what needs doing.'**
  String get tasksNameRequired;

  /// No description provided for @tasksWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get tasksWhere;

  /// No description provided for @tasksRoomKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get tasksRoomKitchen;

  /// No description provided for @tasksRoomLiving.
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get tasksRoomLiving;

  /// No description provided for @tasksRoomBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get tasksRoomBedrooms;

  /// No description provided for @tasksRoomBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get tasksRoomBathrooms;

  /// No description provided for @tasksRoomBalcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get tasksRoomBalcony;

  /// No description provided for @tasksRoomWhole.
  ///
  /// In en, this message translates to:
  /// **'Whole house'**
  String get tasksRoomWhole;

  /// No description provided for @tasksOther.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get tasksOther;

  /// No description provided for @tasksRoomName.
  ///
  /// In en, this message translates to:
  /// **'Area or place'**
  String get tasksRoomName;

  /// No description provided for @tasksHowOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get tasksHowOften;

  /// No description provided for @tasksEvery2.
  ///
  /// In en, this message translates to:
  /// **'Every 2 days'**
  String get tasksEvery2;

  /// No description provided for @tasksEvery3.
  ///
  /// In en, this message translates to:
  /// **'Every 3 days'**
  String get tasksEvery3;

  /// No description provided for @tasksCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get tasksCustom;

  /// No description provided for @tasksEveryHowMany.
  ///
  /// In en, this message translates to:
  /// **'Every how many days?'**
  String get tasksEveryHowMany;

  /// No description provided for @tasksDaysRange.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 365 days.'**
  String get tasksDaysRange;

  /// No description provided for @tasksWhoDoesIt.
  ///
  /// In en, this message translates to:
  /// **'Who does it'**
  String get tasksWhoDoesIt;

  /// No description provided for @tasksAddRoutine.
  ///
  /// In en, this message translates to:
  /// **'Add routine'**
  String get tasksAddRoutine;

  /// No description provided for @tasksRoutineAdded.
  ///
  /// In en, this message translates to:
  /// **'Routine added · first one is due today'**
  String get tasksRoutineAdded;

  /// No description provided for @tasksEditRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get tasksEditRoutineTitle;

  /// No description provided for @tasksSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get tasksSaveChanges;

  /// No description provided for @tasksRoutineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Routine updated'**
  String get tasksRoutineUpdated;

  /// No description provided for @tasksDeleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get tasksDeleteRoutine;

  /// No description provided for @tasksRoutineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Routine deleted'**
  String get tasksRoutineDeleted;

  /// No description provided for @tasksGroupOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasksGroupOverdue;

  /// No description provided for @tasksGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tasksGroupToday;

  /// No description provided for @tasksGroupTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tasksGroupTomorrow;

  /// No description provided for @tasksGroupLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get tasksGroupLater;

  /// No description provided for @tasksTodoMeta.
  ///
  /// In en, this message translates to:
  /// **'{day} · {who}'**
  String tasksTodoMeta(Object day, Object who);

  /// No description provided for @tasksCompleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Complete “{title}”'**
  String tasksCompleteTodo(Object title);

  /// No description provided for @tasksTodoDone.
  ///
  /// In en, this message translates to:
  /// **'Done: {title}'**
  String tasksTodoDone(Object title);

  /// No description provided for @tasksAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get tasksAllDone;

  /// No description provided for @tasksNothingPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending.'**
  String get tasksNothingPending;

  /// No description provided for @tasksNothingPendingFor.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending for {name}.'**
  String tasksNothingPendingFor(Object name);

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed ({n})'**
  String tasksCompleted(int n);

  /// No description provided for @tasksReopenTodo.
  ///
  /// In en, this message translates to:
  /// **'Reopen “{title}”'**
  String tasksReopenTodo(Object title);

  /// No description provided for @tasksMovedBack.
  ///
  /// In en, this message translates to:
  /// **'Moved back to open'**
  String get tasksMovedBack;

  /// No description provided for @tasksNewTodo.
  ///
  /// In en, this message translates to:
  /// **'New to-do'**
  String get tasksNewTodo;

  /// No description provided for @tasksEditTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit to-do'**
  String get tasksEditTodo;

  /// No description provided for @tasksWhat.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get tasksWhat;

  /// No description provided for @tasksTodoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Book AC service'**
  String get tasksTodoPlaceholder;

  /// No description provided for @tasksTodoRequired.
  ///
  /// In en, this message translates to:
  /// **'Add what needs doing.'**
  String get tasksTodoRequired;

  /// No description provided for @tasksWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get tasksWhen;

  /// No description provided for @tasksToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tasksToday;

  /// No description provided for @tasksTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tasksTomorrow;

  /// No description provided for @tasksWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get tasksWeekend;

  /// No description provided for @tasksNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get tasksNextWeek;

  /// No description provided for @tasksPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date…'**
  String get tasksPickDate;

  /// No description provided for @tasksWho.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get tasksWho;

  /// No description provided for @tasksAddTodo.
  ///
  /// In en, this message translates to:
  /// **'Add to-do'**
  String get tasksAddTodo;

  /// No description provided for @tasksTodoAdded.
  ///
  /// In en, this message translates to:
  /// **'To-do added'**
  String get tasksTodoAdded;

  /// No description provided for @tasksTodoUpdated.
  ///
  /// In en, this message translates to:
  /// **'To-do updated'**
  String get tasksTodoUpdated;

  /// No description provided for @tasksDeleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Delete to-do'**
  String get tasksDeleteTodo;

  /// No description provided for @tasksTodoDeleted.
  ///
  /// In en, this message translates to:
  /// **'To-do deleted'**
  String get tasksTodoDeleted;

  /// No description provided for @tasksSendList.
  ///
  /// In en, this message translates to:
  /// **'Send {name} today’s list'**
  String tasksSendList(Object name);

  /// No description provided for @tasksJobs.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 job} other{{n} jobs}} · they don’t need the app'**
  String tasksJobs(int n);

  /// No description provided for @tasksPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tasksPreview;

  /// No description provided for @tasksListFor.
  ///
  /// In en, this message translates to:
  /// **'{name}’s list for today'**
  String tasksListFor(Object name);

  /// No description provided for @tasksShareLead.
  ///
  /// In en, this message translates to:
  /// **'Sent as a WhatsApp message in their language. They don’t need the app.'**
  String get tasksShareLead;

  /// No description provided for @tasksLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get tasksLanguage;

  /// No description provided for @tasksLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get tasksLangEnglish;

  /// No description provided for @tasksLangHindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get tasksLangHindi;

  /// No description provided for @tasksLangTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tasksLangTamil;

  /// No description provided for @tasksCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get tasksCopy;

  /// No description provided for @tasksCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied — paste it in any chat'**
  String get tasksCopied;

  /// No description provided for @tasksWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get tasksWhatsApp;

  /// No description provided for @todayDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get todayDueToday;

  /// No description provided for @todayAllTasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get todayAllTasks;

  /// No description provided for @todayTodoKind.
  ///
  /// In en, this message translates to:
  /// **'To-do'**
  String get todayTodoKind;

  /// No description provided for @todayMoreDue.
  ///
  /// In en, this message translates to:
  /// **'+ {n} more due'**
  String todayMoreDue(int n);

  /// No description provided for @todayNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get todayNothingDue;

  /// No description provided for @todayEnjoyQuiet.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the quiet.'**
  String get todayEnjoyQuiet;

  /// No description provided for @tasksRemoveStaffMoves.
  ///
  /// In en, this message translates to:
  /// **'Their routines and open to-dos will move to you.'**
  String get tasksRemoveStaffMoves;

  /// No description provided for @moneyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Household spends'**
  String get moneyEyebrow;

  /// No description provided for @moneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneyTitle;

  /// No description provided for @moneySpentIn.
  ///
  /// In en, this message translates to:
  /// **'Spent in {month}'**
  String moneySpentIn(Object month);

  /// No description provided for @moneyLeftOf.
  ///
  /// In en, this message translates to:
  /// **'{left} left of {budget}'**
  String moneyLeftOf(Object left, Object budget);

  /// No description provided for @moneyDaysToGo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String moneyDaysToGo(int count);

  /// No description provided for @moneyBelowPrev.
  ///
  /// In en, this message translates to:
  /// **'{amount} below {month}’s total'**
  String moneyBelowPrev(Object amount, Object month);

  /// No description provided for @moneyAbovePrev.
  ///
  /// In en, this message translates to:
  /// **'{amount} above {month}’s total'**
  String moneyAbovePrev(Object amount, Object month);

  /// No description provided for @moneyOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String moneyOverBudget(Object amount);

  /// No description provided for @moneySetBudget.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get moneySetBudget;

  /// No description provided for @moneyNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget set'**
  String get moneyNoBudget;

  /// No description provided for @moneyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get moneyBudgetTitle;

  /// No description provided for @moneyBudgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get moneyBudgetSaved;

  /// No description provided for @moneySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get moneySave;

  /// No description provided for @moneyAddSpend.
  ///
  /// In en, this message translates to:
  /// **'＋ Add a spend'**
  String get moneyAddSpend;

  /// No description provided for @moneyQuickAddHint.
  ///
  /// In en, this message translates to:
  /// **'Or type “₹450 Swiggy” in Quick add from any tab.'**
  String get moneyQuickAddHint;

  /// No description provided for @moneyBills.
  ///
  /// In en, this message translates to:
  /// **'Bills this month'**
  String get moneyBills;

  /// No description provided for @moneyBillsPaid.
  ///
  /// In en, this message translates to:
  /// **'{k} of {n} paid'**
  String moneyBillsPaid(int k, int n);

  /// No description provided for @moneyAddBill.
  ///
  /// In en, this message translates to:
  /// **'＋ Add bill'**
  String get moneyAddBill;

  /// No description provided for @moneyBillDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date} · {amount} last time'**
  String moneyBillDue(Object date, Object amount);

  /// No description provided for @moneyOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get moneyOverdue;

  /// No description provided for @moneyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get moneyToday;

  /// No description provided for @moneyPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get moneyPaid;

  /// No description provided for @moneyBillPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid {date} · {method}'**
  String moneyBillPaidOn(Object date, Object method);

  /// No description provided for @moneyPaidTwice.
  ///
  /// In en, this message translates to:
  /// **'Marked paid twice — check'**
  String get moneyPaidTwice;

  /// No description provided for @moneyFirstDue.
  ///
  /// In en, this message translates to:
  /// **'First due {date} · {amount}'**
  String moneyFirstDue(Object date, Object amount);

  /// No description provided for @moneyMarkBillPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark {bill} paid'**
  String moneyMarkBillPaid(Object bill);

  /// No description provided for @moneyBillsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add rent, electricity, milk, internet… — we’ll remind you when they’re due.'**
  String get moneyBillsEmpty;

  /// No description provided for @moneyStoppedBills.
  ///
  /// In en, this message translates to:
  /// **'Stopped bills ({count})'**
  String moneyStoppedBills(int count);

  /// No description provided for @moneyStoppedRow.
  ///
  /// In en, this message translates to:
  /// **'{amount} · day {day}'**
  String moneyStoppedRow(Object amount, int day);

  /// No description provided for @moneyTrackAgain.
  ///
  /// In en, this message translates to:
  /// **'Track again'**
  String get moneyTrackAgain;

  /// No description provided for @moneyTrackingAgain.
  ///
  /// In en, this message translates to:
  /// **'Tracking {bill} again'**
  String moneyTrackingAgain(Object bill);

  /// No description provided for @moneyMethodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get moneyMethodUpi;

  /// No description provided for @moneyMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get moneyMethodCash;

  /// No description provided for @moneyMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get moneyMethodCard;

  /// No description provided for @moneyMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get moneyMethodBank;

  /// No description provided for @moneyErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Check the amount'**
  String get moneyErrAmount;

  /// No description provided for @moneyWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get moneyWhereItWent;

  /// No description provided for @moneyStaffPay.
  ///
  /// In en, this message translates to:
  /// **'Staff pay · {month}'**
  String moneyStaffPay(Object month);

  /// No description provided for @moneyBilledRate.
  ///
  /// In en, this message translates to:
  /// **'{billed} billed · {rate}/hr'**
  String moneyBilledRate(Object billed, Object rate);

  /// No description provided for @moneyMonthlyLeaves.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Monthly · 1 leave} other{Monthly · {count} leaves}}'**
  String moneyMonthlyLeaves(int count);

  /// No description provided for @moneyRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get moneyRecent;

  /// No description provided for @moneySeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get moneySeeAll;

  /// No description provided for @moneyRowSub.
  ///
  /// In en, this message translates to:
  /// **'{day} · {category} · {source}'**
  String moneyRowSub(Object day, Object category, Object source);

  /// No description provided for @moneySrcManual.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String moneySrcManual(Object name);

  /// No description provided for @moneySrcYou.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get moneySrcYou;

  /// No description provided for @moneySrcOrder.
  ///
  /// In en, this message translates to:
  /// **'{channel} order'**
  String moneySrcOrder(Object channel);

  /// No description provided for @moneySrcStore.
  ///
  /// In en, this message translates to:
  /// **'Store bill'**
  String get moneySrcStore;

  /// No description provided for @moneySrcBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get moneySrcBill;

  /// No description provided for @moneySrcSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get moneySrcSalary;

  /// No description provided for @moneyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No spends yet this month'**
  String get moneyEmptyTitle;

  /// No description provided for @moneyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap “＋ Add a spend”, or mark a bill paid.'**
  String get moneyEmptyBody;

  /// No description provided for @moneyAddSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a spend'**
  String get moneyAddSpendTitle;

  /// No description provided for @moneyEditSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit spend'**
  String get moneyEditSpendTitle;

  /// No description provided for @moneyAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount in rupees'**
  String get moneyAmountLabel;

  /// No description provided for @moneyPaidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid to / for'**
  String get moneyPaidTo;

  /// No description provided for @moneyCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get moneyCategory;

  /// No description provided for @moneyCustomCategoryChip.
  ///
  /// In en, this message translates to:
  /// **'＋ Custom'**
  String get moneyCustomCategoryChip;

  /// No description provided for @moneyCustomCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get moneyCustomCategoryLabel;

  /// No description provided for @moneyCustomCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Medical, Travel, Fuel'**
  String get moneyCustomCategoryHint;

  /// No description provided for @moneyErrCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get moneyErrCategory;

  /// No description provided for @moneyShowChart.
  ///
  /// In en, this message translates to:
  /// **'Show chart'**
  String get moneyShowChart;

  /// No description provided for @moneyHideChart.
  ///
  /// In en, this message translates to:
  /// **'Hide chart'**
  String get moneyHideChart;

  /// No description provided for @moneyChartByItem.
  ///
  /// In en, this message translates to:
  /// **'By item'**
  String get moneyChartByItem;

  /// No description provided for @moneyChartByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get moneyChartByCategory;

  /// No description provided for @moneyChartByPeople.
  ///
  /// In en, this message translates to:
  /// **'By people'**
  String get moneyChartByPeople;

  /// No description provided for @moneyChartOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get moneyChartOther;

  /// No description provided for @moneyChartUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get moneyChartUnknown;

  /// No description provided for @moneyDraftsCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse draft expenses'**
  String get moneyDraftsCollapse;

  /// No description provided for @moneyDraftsExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand draft expenses'**
  String get moneyDraftsExpand;

  /// No description provided for @moneyDraftsShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String moneyDraftsShowAll(int count);

  /// No description provided for @moneyDraftsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show first {count}'**
  String moneyDraftsShowLess(int count);

  /// No description provided for @moneyDraftsShowingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total}'**
  String moneyDraftsShowingCount(int shown, int total);

  /// No description provided for @moneyPaidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get moneyPaidWith;

  /// No description provided for @moneyWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get moneyWhen;

  /// No description provided for @moneyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get moneyYesterday;

  /// No description provided for @moneyOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Other day'**
  String get moneyOtherDay;

  /// No description provided for @moneyMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moneyMore;

  /// No description provided for @moneyPaidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get moneyPaidBy;

  /// No description provided for @moneyYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get moneyYou;

  /// No description provided for @moneyNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get moneyNote;

  /// No description provided for @moneyRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month — makes it a bill'**
  String get moneyRepeat;

  /// No description provided for @moneySaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get moneySaveChanges;

  /// No description provided for @moneyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get moneyDelete;

  /// No description provided for @moneyAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount} added'**
  String moneyAdded(Object amount);

  /// No description provided for @moneyAddedBill.
  ///
  /// In en, this message translates to:
  /// **'{amount} added · {merchant} is now a monthly bill'**
  String moneyAddedBill(Object amount, Object merchant);

  /// No description provided for @moneyLearned.
  ///
  /// In en, this message translates to:
  /// **'Saved · {merchant} will go to {category} from now on.'**
  String moneyLearned(Object merchant, Object category);

  /// No description provided for @moneySpendUpdated.
  ///
  /// In en, this message translates to:
  /// **'Spend updated'**
  String get moneySpendUpdated;

  /// No description provided for @moneySpendDeleted.
  ///
  /// In en, this message translates to:
  /// **'Spend deleted'**
  String get moneySpendDeleted;

  /// No description provided for @moneyErrMerchant.
  ///
  /// In en, this message translates to:
  /// **'Who was it paid to?'**
  String get moneyErrMerchant;

  /// No description provided for @moneyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Added by {name} · only {name} or an admin can change it.'**
  String moneyReadOnly(Object name);

  /// No description provided for @moneySalaryManaged.
  ///
  /// In en, this message translates to:
  /// **'Salary spends are managed in {name}’s salary.'**
  String moneySalaryManaged(Object name);

  /// No description provided for @moneyOpenSalary.
  ///
  /// In en, this message translates to:
  /// **'Open salary'**
  String get moneyOpenSalary;

  /// No description provided for @moneyDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Looks like {who} already added {amount} · {merchant} {when}.'**
  String moneyDuplicate(
    Object who,
    Object amount,
    Object merchant,
    Object when,
  );

  /// No description provided for @moneyWhoYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get moneyWhoYou;

  /// No description provided for @moneyWhenToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get moneyWhenToday;

  /// No description provided for @moneyWhenYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get moneyWhenYesterday;

  /// No description provided for @moneyWhenOn.
  ///
  /// In en, this message translates to:
  /// **'on {day}'**
  String moneyWhenOn(Object day);

  /// No description provided for @moneyAddAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get moneyAddAnyway;

  /// No description provided for @moneyDontAdd.
  ///
  /// In en, this message translates to:
  /// **'Don’t add'**
  String get moneyDontAdd;

  /// No description provided for @moneyCashSpend.
  ///
  /// In en, this message translates to:
  /// **'Cash spend'**
  String get moneyCashSpend;

  /// No description provided for @moneyOrdinal.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 1{1st} 2{2nd} 3{3rd} 21{21st} 22{22nd} 23{23rd} 31{31st} other{{n}th}}'**
  String moneyOrdinal(String n);

  /// No description provided for @moneyAddBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a bill'**
  String get moneyAddBillTitle;

  /// No description provided for @moneyEditBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get moneyEditBillTitle;

  /// No description provided for @moneyBillName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get moneyBillName;

  /// No description provided for @moneyUsualAmount.
  ///
  /// In en, this message translates to:
  /// **'Usual amount (₹)'**
  String get moneyUsualAmount;

  /// No description provided for @moneyDueDay.
  ///
  /// In en, this message translates to:
  /// **'Due day'**
  String get moneyDueDay;

  /// No description provided for @moneyDueHelper.
  ///
  /// In en, this message translates to:
  /// **'Paid around the {nth} each month'**
  String moneyDueHelper(Object nth);

  /// No description provided for @moneyRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me on the due day'**
  String get moneyRemind;

  /// No description provided for @moneyBillErrName.
  ///
  /// In en, this message translates to:
  /// **'Add the bill’s name.'**
  String get moneyBillErrName;

  /// No description provided for @moneyBillErrDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day from 1 to 31.'**
  String get moneyBillErrDay;

  /// No description provided for @moneyBillAdded.
  ///
  /// In en, this message translates to:
  /// **'{bill} added'**
  String moneyBillAdded(Object bill);

  /// No description provided for @moneyBillSaved.
  ///
  /// In en, this message translates to:
  /// **'Bill saved'**
  String get moneyBillSaved;

  /// No description provided for @moneyStopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking this bill'**
  String get moneyStopTracking;

  /// No description provided for @moneyStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped tracking {bill}'**
  String moneyStopped(Object bill);

  /// No description provided for @moneyDeleteBill.
  ///
  /// In en, this message translates to:
  /// **'Delete bill'**
  String get moneyDeleteBill;

  /// No description provided for @moneyDeleteBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {bill}?'**
  String moneyDeleteBillTitle(Object bill);

  /// No description provided for @moneyDeleteBillLead.
  ///
  /// In en, this message translates to:
  /// **'Past spends keep their “Bill” label.'**
  String get moneyDeleteBillLead;

  /// No description provided for @moneyKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get moneyKeep;

  /// No description provided for @moneyBillDeleted.
  ///
  /// In en, this message translates to:
  /// **'{bill} deleted'**
  String moneyBillDeleted(Object bill);

  /// No description provided for @moneyPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'{bill} — paid?'**
  String moneyPaidTitle(Object bill);

  /// No description provided for @moneyPaidLead.
  ///
  /// In en, this message translates to:
  /// **'Usually {amount} around the {nth}.'**
  String moneyPaidLead(Object amount, Object nth);

  /// No description provided for @moneyForMonth.
  ///
  /// In en, this message translates to:
  /// **'For {month}'**
  String moneyForMonth(Object month);

  /// No description provided for @moneyMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get moneyMarkPaid;

  /// No description provided for @moneyBillPaidSnack.
  ///
  /// In en, this message translates to:
  /// **'{bill} paid · {amount} added'**
  String moneyBillPaidSnack(Object bill, Object amount);

  /// No description provided for @moneyAllSpends.
  ///
  /// In en, this message translates to:
  /// **'All spends'**
  String get moneyAllSpends;

  /// No description provided for @moneySearch.
  ///
  /// In en, this message translates to:
  /// **'Search spends'**
  String get moneySearch;

  /// No description provided for @moneyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 spend · {total}} other{{count} spends · {total}}}'**
  String moneyCount(int count, Object total);

  /// No description provided for @moneyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No spends match.'**
  String get moneyNoMatch;

  /// No description provided for @moneyClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Remove filter {category}'**
  String moneyClearFilter(Object category);

  /// No description provided for @todayMonthSoFar.
  ///
  /// In en, this message translates to:
  /// **'{month} so far'**
  String todayMonthSoFar(Object month);

  /// No description provided for @todayMoneyLink.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get todayMoneyLink;

  /// No description provided for @todayOfBudget.
  ///
  /// In en, this message translates to:
  /// **'of {budget} budget · {pct}% used'**
  String todayOfBudget(Object budget, int pct);

  /// No description provided for @todayBillsDue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill due} other{{count} bills due}}'**
  String todayBillsDue(int count);

  /// No description provided for @todaySpentSoFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent so far'**
  String todaySpentSoFar(Object amount);

  /// No description provided for @todaySetBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get todaySetBudget;

  /// No description provided for @recipeAPinch.
  ///
  /// In en, this message translates to:
  /// **'a pinch'**
  String get recipeAPinch;

  /// No description provided for @onboardingAddStarterRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add 9 popular recipes'**
  String get onboardingAddStarterRecipes;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTitle;

  /// No description provided for @mealsWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String mealsWeekOf(String date);

  /// No description provided for @mealsPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get mealsPrevWeek;

  /// No description provided for @mealsNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get mealsNextWeek;

  /// No description provided for @mealsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get mealsThisWeek;

  /// No description provided for @mealsDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {date}, {count} of 3 meals planned'**
  String mealsDaySemantics(String weekday, String date, int count);

  /// No description provided for @mealsMissingWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient missing for the rest of the week} other{{count} ingredients missing for the rest of the week}}'**
  String mealsMissingWeek(int count);

  /// No description provided for @mealsAddAll.
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get mealsAddAll;

  /// No description provided for @mealsPastDay.
  ///
  /// In en, this message translates to:
  /// **'Past day'**
  String get mealsPastDay;

  /// No description provided for @mealsSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'{slot, select, breakfast{Breakfast} lunch{Lunch} other{Dinner}}'**
  String mealsSlotTitle(String slot);

  /// No description provided for @mealsSlotLower.
  ///
  /// In en, this message translates to:
  /// **'{slot, select, breakfast{breakfast} lunch{lunch} other{dinner}}'**
  String mealsSlotLower(String slot);

  /// No description provided for @mealsPlanSlot.
  ///
  /// In en, this message translates to:
  /// **'Plan {slot}'**
  String mealsPlanSlot(String slot);

  /// No description provided for @mealsChangeSlot.
  ///
  /// In en, this message translates to:
  /// **'Change {slot}'**
  String mealsChangeSlot(String slot);

  /// No description provided for @mealsPickFromBook.
  ///
  /// In en, this message translates to:
  /// **'Pick from your recipe book'**
  String get mealsPickFromBook;

  /// No description provided for @mealsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String mealsMinutes(int min);

  /// No description provided for @mealsReadyToCook.
  ///
  /// In en, this message translates to:
  /// **'ready to cook'**
  String get mealsReadyToCook;

  /// No description provided for @mealsMissingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} missing'**
  String mealsMissingCount(int count);

  /// No description provided for @mealsEatingOut.
  ///
  /// In en, this message translates to:
  /// **'Eating out'**
  String get mealsEatingOut;

  /// No description provided for @mealsLeftovers.
  ///
  /// In en, this message translates to:
  /// **'Leftovers'**
  String get mealsLeftovers;

  /// No description provided for @mealsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} (removed)'**
  String mealsRemoved(String name);

  /// No description provided for @mealsRecipeBook.
  ///
  /// In en, this message translates to:
  /// **'Recipe book'**
  String get mealsRecipeBook;

  /// No description provided for @mealsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get mealsAdd;

  /// No description provided for @mealsCardMeta.
  ///
  /// In en, this message translates to:
  /// **'{min} min · {tag}'**
  String mealsCardMeta(int min, String tag);

  /// No description provided for @mealsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get mealsEmptyTitle;

  /// No description provided for @mealsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first, or add the 9 popular ones.'**
  String get mealsEmptyBody;

  /// No description provided for @mealsAddStarter.
  ///
  /// In en, this message translates to:
  /// **'Add 9 popular recipes'**
  String get mealsAddStarter;

  /// No description provided for @mealsTypeRecipe.
  ///
  /// In en, this message translates to:
  /// **'Type a recipe'**
  String get mealsTypeRecipe;

  /// No description provided for @mealsStarterAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 recipe} other{Added {count} recipes}}'**
  String mealsStarterAdded(int count);

  /// No description provided for @mealsPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'{slot} · {day}'**
  String mealsPickerTitle(String slot, String day);

  /// No description provided for @mealsPickerLead.
  ///
  /// In en, this message translates to:
  /// **'Suggested for {slot} first. Missing ingredients flow into your grocery list.'**
  String mealsPickerLead(String slot);

  /// No description provided for @mealsOptEatingOut.
  ///
  /// In en, this message translates to:
  /// **'🍽 Eating out'**
  String get mealsOptEatingOut;

  /// No description provided for @mealsOptLeftovers.
  ///
  /// In en, this message translates to:
  /// **'♻ Leftovers'**
  String get mealsOptLeftovers;

  /// No description provided for @mealsOptNote.
  ///
  /// In en, this message translates to:
  /// **'✎ Note…'**
  String get mealsOptNote;

  /// No description provided for @mealsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dosa from Amma'**
  String get mealsNoteHint;

  /// No description provided for @mealsNoteSave.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get mealsNoteSave;

  /// No description provided for @mealsSearchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get mealsSearchRecipes;

  /// No description provided for @mealsClearSlot.
  ///
  /// In en, this message translates to:
  /// **'Clear {slot}'**
  String mealsClearSlot(String slot);

  /// No description provided for @mealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'{dish} planned'**
  String mealsPlanned(String dish);

  /// No description provided for @mealsPlannedMissing.
  ///
  /// In en, this message translates to:
  /// **'{dish} planned · {count, plural, =1{1 ingredient missing} other{{count} ingredients missing}}'**
  String mealsPlannedMissing(String dish, int count);

  /// No description provided for @mealsPlannedKind.
  ///
  /// In en, this message translates to:
  /// **'{slot} · {what}'**
  String mealsPlannedKind(String slot, String what);

  /// No description provided for @mealsSlotCleared.
  ///
  /// In en, this message translates to:
  /// **'Slot cleared'**
  String get mealsSlotCleared;

  /// No description provided for @mealsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Grocery'**
  String get mealsReviewTitle;

  /// No description provided for @mealsReviewLead.
  ///
  /// In en, this message translates to:
  /// **'Untick anything you already have — we’ll remember it.'**
  String get mealsReviewLead;

  /// No description provided for @mealsReviewAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String mealsReviewAdd(int count);

  /// No description provided for @mealsAddedToGrocery.
  ///
  /// In en, this message translates to:
  /// **'Added {count} to Grocery'**
  String mealsAddedToGrocery(int count);

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipeTitle;

  /// No description provided for @recipeAddToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to meal plan'**
  String get recipeAddToPlan;

  /// No description provided for @recipeMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get recipeMoreOptions;

  /// No description provided for @recipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get recipeEdit;

  /// No description provided for @recipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recipeDelete;

  /// No description provided for @recipeServes.
  ///
  /// In en, this message translates to:
  /// **'Serves {n}'**
  String recipeServes(int n);

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipeServings;

  /// No description provided for @recipePpl.
  ///
  /// In en, this message translates to:
  /// **'{n} ppl'**
  String recipePpl(int n);

  /// No description provided for @recipeFewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer servings'**
  String get recipeFewer;

  /// No description provided for @recipeMoreServings.
  ///
  /// In en, this message translates to:
  /// **'More servings'**
  String get recipeMoreServings;

  /// No description provided for @recipeInKitchen.
  ///
  /// In en, this message translates to:
  /// **'In kitchen'**
  String get recipeInKitchen;

  /// No description provided for @recipeOnList.
  ///
  /// In en, this message translates to:
  /// **'On list'**
  String get recipeOnList;

  /// No description provided for @recipeMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get recipeMissing;

  /// No description provided for @recipeSrHave.
  ///
  /// In en, this message translates to:
  /// **'in kitchen'**
  String get recipeSrHave;

  /// No description provided for @recipeSrOnList.
  ///
  /// In en, this message translates to:
  /// **'already on grocery list'**
  String get recipeSrOnList;

  /// No description provided for @recipeSrMissing.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get recipeSrMissing;

  /// No description provided for @recipeMarkedHave.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as in kitchen'**
  String recipeMarkedHave(String name);

  /// No description provided for @recipeMarkedMissing.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as missing'**
  String recipeMarkedMissing(String name);

  /// No description provided for @recipeAddMissing.
  ///
  /// In en, this message translates to:
  /// **'🛒 Add {count} missing to Grocery'**
  String recipeAddMissing(int count);

  /// No description provided for @recipeAllThere.
  ///
  /// In en, this message translates to:
  /// **'✓ Everything is in the kitchen or on the list'**
  String get recipeAllThere;

  /// No description provided for @recipeMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get recipeMethod;

  /// No description provided for @recipeStartCook.
  ///
  /// In en, this message translates to:
  /// **'🔥 Start cook mode'**
  String get recipeStartCook;

  /// No description provided for @recipePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan {dish}'**
  String recipePlanTitle(String dish);

  /// No description provided for @recipePlanDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get recipePlanDay;

  /// No description provided for @recipePlanMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get recipePlanMeal;

  /// No description provided for @recipePlanAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get recipePlanAdd;

  /// No description provided for @recipePlannedFor.
  ///
  /// In en, this message translates to:
  /// **'Planned for {day} {slot}'**
  String recipePlannedFor(String day, String slot);

  /// No description provided for @recipeDeletePlanned.
  ///
  /// In en, this message translates to:
  /// **'{dish} is planned on {count, plural, =1{1 day} other{{count} days}}. Remove it from those days too?'**
  String recipeDeletePlanned(String dish, int count);

  /// No description provided for @recipeKeepPlans.
  ///
  /// In en, this message translates to:
  /// **'Keep on those days'**
  String get recipeKeepPlans;

  /// No description provided for @recipeRemoveToo.
  ///
  /// In en, this message translates to:
  /// **'Remove too'**
  String get recipeRemoveToo;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get recipeDeleted;

  /// No description provided for @recipeAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a recipe'**
  String get recipeAddTitle;

  /// No description provided for @recipeAddLead.
  ///
  /// In en, this message translates to:
  /// **'Pick the fastest way in — you can tidy it later.'**
  String get recipeAddLead;

  /// No description provided for @recipeTypeIt.
  ///
  /// In en, this message translates to:
  /// **'Type it'**
  String get recipeTypeIt;

  /// No description provided for @recipeTypeItSub.
  ///
  /// In en, this message translates to:
  /// **'Name, ingredients, steps'**
  String get recipeTypeItSub;

  /// No description provided for @recipePasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get recipePasteLink;

  /// No description provided for @recipePasteLinkSub.
  ///
  /// In en, this message translates to:
  /// **'YouTube, Instagram or a blog — ingredients are pulled out for you'**
  String get recipePasteLinkSub;

  /// No description provided for @recipeSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap a page'**
  String get recipeSnap;

  /// No description provided for @recipeSnapSub.
  ///
  /// In en, this message translates to:
  /// **'Photo of a cookbook or a handwritten card'**
  String get recipeSnapSub;

  /// No description provided for @recipeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get recipeComingSoon;

  /// No description provided for @recipeFormNew.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get recipeFormNew;

  /// No description provided for @recipeFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipeFormEdit;

  /// No description provided for @recipeFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get recipeFieldName;

  /// No description provided for @recipeFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time in minutes'**
  String get recipeFieldTime;

  /// No description provided for @recipeFieldServes.
  ///
  /// In en, this message translates to:
  /// **'Serves'**
  String get recipeFieldServes;

  /// No description provided for @recipeFieldMealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get recipeFieldMealType;

  /// No description provided for @recipeFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get recipeFieldTags;

  /// No description provided for @recipeTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Quick, Kids like'**
  String get recipeTagsHint;

  /// No description provided for @recipeFieldIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeFieldIngredients;

  /// No description provided for @recipeIngName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get recipeIngName;

  /// No description provided for @recipeIngQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get recipeIngQty;

  /// No description provided for @recipeIngUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get recipeIngUnit;

  /// No description provided for @recipeUnitNone.
  ///
  /// In en, this message translates to:
  /// **'(none)'**
  String get recipeUnitNone;

  /// No description provided for @recipeAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'+ Add ingredient'**
  String get recipeAddIngredient;

  /// No description provided for @recipeFieldSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipeFieldSteps;

  /// No description provided for @recipeStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String recipeStepLabel(int n);

  /// No description provided for @recipeAddStep.
  ///
  /// In en, this message translates to:
  /// **'+ Add step'**
  String get recipeAddStep;

  /// No description provided for @recipeMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get recipeMoveUp;

  /// No description provided for @recipeMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get recipeMoveDown;

  /// No description provided for @recipeRemoveRow.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get recipeRemoveRow;

  /// No description provided for @recipeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get recipeSave;

  /// No description provided for @recipeSaved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved'**
  String get recipeSaved;

  /// No description provided for @recipeErrName.
  ///
  /// In en, this message translates to:
  /// **'Add a name.'**
  String get recipeErrName;

  /// No description provided for @recipeErrIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient.'**
  String get recipeErrIngredients;

  /// No description provided for @recipeErrSteps.
  ///
  /// In en, this message translates to:
  /// **'Add at least one step.'**
  String get recipeErrSteps;

  /// No description provided for @recipeErrQty.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be more than 0.'**
  String get recipeErrQty;

  /// No description provided for @recipeErrIngName.
  ///
  /// In en, this message translates to:
  /// **'Add the ingredient’s name.'**
  String get recipeErrIngName;

  /// No description provided for @recipeErrTime.
  ///
  /// In en, this message translates to:
  /// **'Time must be 1–600 minutes.'**
  String get recipeErrTime;

  /// No description provided for @recipeErrServes.
  ///
  /// In en, this message translates to:
  /// **'Serves must be 1–20.'**
  String get recipeErrServes;

  /// No description provided for @recipeErrStepLong.
  ///
  /// In en, this message translates to:
  /// **'A step can be at most 500 characters.'**
  String get recipeErrStepLong;

  /// No description provided for @recipeDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get recipeDiscardTitle;

  /// No description provided for @recipeKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get recipeKeepEditing;

  /// No description provided for @recipeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get recipeDiscard;

  /// No description provided for @cookSub.
  ///
  /// In en, this message translates to:
  /// **'Cook mode · screen stays on'**
  String get cookSub;

  /// No description provided for @cookOf.
  ///
  /// In en, this message translates to:
  /// **'/{total}'**
  String cookOf(int total);

  /// No description provided for @cookStepSemantics.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}: {text}'**
  String cookStepSemantics(int n, int total, String text);

  /// No description provided for @cookBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cookBack;

  /// No description provided for @cookNext.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get cookNext;

  /// No description provided for @cookFinished.
  ///
  /// In en, this message translates to:
  /// **'✓ Finished'**
  String get cookFinished;

  /// No description provided for @todayMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'On the menu'**
  String get todayMenuTitle;

  /// No description provided for @todayWeekPlan.
  ///
  /// In en, this message translates to:
  /// **'Week plan'**
  String get todayWeekPlan;

  /// No description provided for @todayPlan.
  ///
  /// In en, this message translates to:
  /// **'+ Plan'**
  String get todayPlan;

  /// No description provided for @todayMissingToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🛒 1 ingredient missing today} other{🛒 {count} ingredients missing today}}'**
  String todayMissingToday(int count);

  /// No description provided for @todayAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get todayAddToList;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileRoleHome.
  ///
  /// In en, this message translates to:
  /// **'{role} · {home}'**
  String profileRoleHome(String role, String home);

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileNameSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNameSheetTitle;

  /// No description provided for @profileNameSheetLead.
  ///
  /// In en, this message translates to:
  /// **'Shown to everyone in your home. Syncs to their phones.'**
  String get profileNameSheetLead;

  /// No description provided for @profileNameError.
  ///
  /// In en, this message translates to:
  /// **'Add your name.'**
  String get profileNameError;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileNameUpdated;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditName;

  /// No description provided for @profileThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get profileThisPhone;

  /// No description provided for @profileOnlyThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Only this phone'**
  String get profileOnlyThisPhone;

  /// No description provided for @profileDeviceKey.
  ///
  /// In en, this message translates to:
  /// **'Device key'**
  String get profileDeviceKey;

  /// No description provided for @profileDeviceKeySub.
  ///
  /// In en, this message translates to:
  /// **'Others see this to know it’s really your phone'**
  String get profileDeviceKeySub;

  /// No description provided for @profileYourHomes.
  ///
  /// In en, this message translates to:
  /// **'Your homes'**
  String get profileYourHomes;

  /// No description provided for @profileCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get profileCurrent;

  /// No description provided for @profileHomeSub.
  ///
  /// In en, this message translates to:
  /// **'{family, plural, =1{1 family} other{{family} family}} · {help, plural, =1{1 house help} other{{help} house help}} · you’re {role}'**
  String profileHomeSub(int family, int help, String role);

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @notifArrival.
  ///
  /// In en, this message translates to:
  /// **'House help arrival'**
  String get notifArrival;

  /// No description provided for @notifArrivalSub.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to mark them in when they usually arrive'**
  String get notifArrivalSub;

  /// No description provided for @notifDigest.
  ///
  /// In en, this message translates to:
  /// **'Morning task digest'**
  String get notifDigest;

  /// No description provided for @notifDigestSub.
  ///
  /// In en, this message translates to:
  /// **'8 AM · what’s due today'**
  String get notifDigestSub;

  /// No description provided for @notifBillDue.
  ///
  /// In en, this message translates to:
  /// **'Bill due'**
  String get notifBillDue;

  /// No description provided for @notifBillDueSub.
  ///
  /// In en, this message translates to:
  /// **'On the due day · “Electricity ₹1,980 — paid?”'**
  String get notifBillDueSub;

  /// No description provided for @notifEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening spend nudge'**
  String get notifEvening;

  /// No description provided for @notifEveningSub.
  ///
  /// In en, this message translates to:
  /// **'9 PM, only if nothing was added that day'**
  String get notifEveningSub;

  /// No description provided for @profileOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get profileOnThisPhone;

  /// No description provided for @profileBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get profileBackup;

  /// No description provided for @profileBackupNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get profileBackupNotSetUp;

  /// No description provided for @profileBackupArrives.
  ///
  /// In en, this message translates to:
  /// **'Backups arrive in P18'**
  String get profileBackupArrives;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileEnglish;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @profileDevTools.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get profileDevTools;

  /// No description provided for @profileRemoveHome.
  ///
  /// In en, this message translates to:
  /// **'🗑 Remove {home} from this phone'**
  String profileRemoveHome(String home);

  /// No description provided for @profileRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {home} from this phone?'**
  String profileRemoveTitle(String home);

  /// No description provided for @profileRemoveLead.
  ///
  /// In en, this message translates to:
  /// **'This phone leaves the home and its copy of the data is erased. Everyone else keeps everything.'**
  String get profileRemoveLead;

  /// No description provided for @profileOnlyAdminLead.
  ///
  /// In en, this message translates to:
  /// **'You’re the only admin. Make someone else admin first, so the home isn’t left without one.'**
  String get profileOnlyAdminLead;

  /// No description provided for @profileGoToMembers.
  ///
  /// In en, this message translates to:
  /// **'Go to members'**
  String get profileGoToMembers;

  /// No description provided for @profileKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get profileKeep;

  /// No description provided for @profileRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get profileRemove;

  /// No description provided for @profileFinePrint.
  ///
  /// In en, this message translates to:
  /// **'🔒 No account, no cloud. Data syncs directly between your home’s phones, encrypted.'**
  String get profileFinePrint;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 family} other{{count} family}} · Home ID {id}'**
  String homeSubtitle(int count, String id);

  /// No description provided for @homeRename.
  ///
  /// In en, this message translates to:
  /// **'Rename home'**
  String get homeRename;

  /// No description provided for @homeSyncPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Only this phone so far'**
  String get homeSyncPlaceholderTitle;

  /// No description provided for @homeSyncPlaceholderSub.
  ///
  /// In en, this message translates to:
  /// **'Invite your family to sync their phones.'**
  String get homeSyncPlaceholderSub;

  /// No description provided for @homeYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Your {model}'**
  String homeYourPhone(String model);

  /// No description provided for @homeThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get homeThisPhone;

  /// No description provided for @homeSyncFootnote.
  ///
  /// In en, this message translates to:
  /// **'ⓘ Phones sync directly on the same Wi-Fi, or over the internet when Illam is open on both.'**
  String get homeSyncFootnote;

  /// No description provided for @homeBackupNone.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get homeBackupNone;

  /// No description provided for @homeBackupNotThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Not backing up from this phone — add your own copy'**
  String get homeBackupNotThisPhone;

  /// No description provided for @homeInvite.
  ///
  /// In en, this message translates to:
  /// **'+ Invite someone'**
  String get homeInvite;

  /// No description provided for @homeInviteArrives.
  ///
  /// In en, this message translates to:
  /// **'Invites arrive in P14'**
  String get homeInviteArrives;

  /// No description provided for @homeAskAdmins.
  ///
  /// In en, this message translates to:
  /// **'🔒 Only admins can invite or remove people. Ask {names}.'**
  String homeAskAdmins(String names);

  /// No description provided for @homeOr.
  ///
  /// In en, this message translates to:
  /// **'{a} or {b}'**
  String homeOr(String a, String b);

  /// No description provided for @homeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family · uses the app'**
  String get homeFamily;

  /// No description provided for @homeYou.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get homeYou;

  /// No description provided for @homeMemberSub.
  ///
  /// In en, this message translates to:
  /// **'{model} · joined {month}'**
  String homeMemberSub(String model, String month);

  /// No description provided for @homeHouseHelp.
  ///
  /// In en, this message translates to:
  /// **'House help · no app needed'**
  String get homeHouseHelp;

  /// No description provided for @homeNoHelp.
  ///
  /// In en, this message translates to:
  /// **'No house help added yet.'**
  String get homeNoHelp;

  /// No description provided for @homeAddHelp.
  ///
  /// In en, this message translates to:
  /// **'+ Add house help'**
  String get homeAddHelp;

  /// No description provided for @homeRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'What can admins and members do?'**
  String get homeRolesTitle;

  /// No description provided for @homeRolesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Everything a member can, plus: invite and remove people, change roles, set staff pay rules, pay salary, rename or delete the home.'**
  String get homeRolesAdmin;

  /// No description provided for @homeRolesMember.
  ///
  /// In en, this message translates to:
  /// **'Lists, tasks and meals; mark house help in and out; add and review spends; see the budget and salary totals.'**
  String get homeRolesMember;

  /// No description provided for @homeRolesFootnote.
  ///
  /// In en, this message translates to:
  /// **'Every phone checks these rules itself, so a change from someone without permission is ignored by everyone else.'**
  String get homeRolesFootnote;

  /// No description provided for @homeLeaveDelete.
  ///
  /// In en, this message translates to:
  /// **'Leave or delete'**
  String get homeLeaveDelete;

  /// No description provided for @homeLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave {home}'**
  String homeLeave(String home);

  /// No description provided for @homeDelete.
  ///
  /// In en, this message translates to:
  /// **'🗑 Delete this home on all phones'**
  String get homeDelete;

  /// No description provided for @memberJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {month} · {how}'**
  String memberJoined(String month, String how);

  /// No description provided for @memberHowCreated.
  ///
  /// In en, this message translates to:
  /// **'Created the home'**
  String get memberHowCreated;

  /// No description provided for @memberHowInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String memberHowInvited(String name);

  /// No description provided for @memberHowQr.
  ///
  /// In en, this message translates to:
  /// **'Joined with a QR code'**
  String get memberHowQr;

  /// No description provided for @memberHowPhrase.
  ///
  /// In en, this message translates to:
  /// **'Joined with a phrase'**
  String get memberHowPhrase;

  /// No description provided for @memberDeviceKey.
  ///
  /// In en, this message translates to:
  /// **'Device key {fp}'**
  String memberDeviceKey(String fp);

  /// No description provided for @memberEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get memberEditProfile;

  /// No description provided for @memberStepDown.
  ///
  /// In en, this message translates to:
  /// **'Step down as admin'**
  String get memberStepDown;

  /// No description provided for @memberStepDownLead.
  ///
  /// In en, this message translates to:
  /// **'You’ll need another admin to make you admin again.'**
  String get memberStepDownLead;

  /// No description provided for @memberCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get memberCancel;

  /// No description provided for @memberStepDownConfirm.
  ///
  /// In en, this message translates to:
  /// **'Step down'**
  String get memberStepDownConfirm;

  /// No description provided for @memberNowMemberSelf.
  ///
  /// In en, this message translates to:
  /// **'You’re now a member.'**
  String get memberNowMemberSelf;

  /// No description provided for @homeLastAdmin.
  ///
  /// In en, this message translates to:
  /// **'A home needs at least one admin.'**
  String get homeLastAdmin;

  /// No description provided for @memberMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'🛡 Make admin'**
  String get memberMakeAdmin;

  /// No description provided for @memberRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove admin rights'**
  String get memberRemoveAdmin;

  /// No description provided for @memberRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get memberRemove;

  /// No description provided for @memberNowAdmin.
  ///
  /// In en, this message translates to:
  /// **'{name} is now an admin'**
  String memberNowAdmin(String name);

  /// No description provided for @memberNowMember.
  ///
  /// In en, this message translates to:
  /// **'{name} is now a member'**
  String memberNowMember(String name);

  /// No description provided for @homeOnlyAdminsRoles.
  ///
  /// In en, this message translates to:
  /// **'Only admins can change roles or remove people.'**
  String get homeOnlyAdminsRoles;

  /// No description provided for @homeNameLength.
  ///
  /// In en, this message translates to:
  /// **'Give your home a name.'**
  String get homeNameLength;

  /// No description provided for @homeChooseAdmin.
  ///
  /// In en, this message translates to:
  /// **'Choose a new admin first'**
  String get homeChooseAdmin;

  /// No description provided for @memberRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String memberRemoveTitle(String name);

  /// No description provided for @memberRemoveLeadWork.
  ///
  /// In en, this message translates to:
  /// **'Their phone stops syncing with {home} and gets no new changes. Their {work} will move to you.'**
  String memberRemoveLeadWork(String home, String work);

  /// No description provided for @memberRemoveLead.
  ///
  /// In en, this message translates to:
  /// **'Their phone stops syncing with {home} and gets no new changes.'**
  String memberRemoveLead(String home);

  /// No description provided for @memberRemoveInfo.
  ///
  /// In en, this message translates to:
  /// **'Their phone erases the home the next time it connects to one of yours. Until then — or if it never reconnects — it keeps what it already had. Everyone else switches to a new home key.'**
  String get memberRemoveInfo;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String memberRemoved(String name);

  /// No description provided for @workRoutines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 routine} other{{count} routines}}'**
  String workRoutines(int count);

  /// No description provided for @workTodos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open to-do} other{{count} open to-dos}}'**
  String workTodos(int count);

  /// No description provided for @workAnd.
  ///
  /// In en, this message translates to:
  /// **'{a} and {b}'**
  String workAnd(String a, String b);

  /// No description provided for @homeRenameLead.
  ///
  /// In en, this message translates to:
  /// **'Everyone sees the new name after their phone syncs.'**
  String get homeRenameLead;

  /// No description provided for @homeRenamed.
  ///
  /// In en, this message translates to:
  /// **'Home renamed'**
  String get homeRenamed;

  /// No description provided for @homeOnlyOneTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re the only one here'**
  String get homeOnlyOneTitle;

  /// No description provided for @homeOnlyOneLead.
  ///
  /// In en, this message translates to:
  /// **'Leaving would leave {home} with no phones, so it would be deleted.'**
  String homeOnlyOneLead(String home);

  /// No description provided for @homeStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get homeStay;

  /// No description provided for @homeDeleteHome.
  ///
  /// In en, this message translates to:
  /// **'Delete home'**
  String get homeDeleteHome;

  /// No description provided for @homeLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {home}?'**
  String homeLeaveTitle(String home);

  /// No description provided for @homeLeaveLeadWork.
  ///
  /// In en, this message translates to:
  /// **'This phone stops syncing and its copy is erased. Your {work} will move to {admin}. An admin can invite you back any time.'**
  String homeLeaveLeadWork(String work, String admin);

  /// No description provided for @homeLeaveLead.
  ///
  /// In en, this message translates to:
  /// **'This phone stops syncing and its copy is erased. An admin can invite you back any time.'**
  String get homeLeaveLead;

  /// No description provided for @homeLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get homeLeaveConfirm;

  /// No description provided for @homeLeft.
  ///
  /// In en, this message translates to:
  /// **'You left {home}. Create or join a home to continue.'**
  String homeLeft(String home);

  /// No description provided for @homeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {home}?'**
  String homeDeleteTitle(String home);

  /// No description provided for @homeDeleteLead.
  ///
  /// In en, this message translates to:
  /// **'Every phone in the home erases its copy — lists, tasks, meals, attendance, salary and spends — as soon as it syncs. It can’t be undone.'**
  String get homeDeleteLead;

  /// No description provided for @homeDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'A phone that never syncs again keeps its copy until someone opens it.'**
  String get homeDeleteInfo;

  /// No description provided for @homeTypeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type {home} to confirm'**
  String homeTypeToConfirm(String home);

  /// No description provided for @homeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete on all phones'**
  String get homeDeleteConfirm;

  /// No description provided for @todayFamilyButton.
  ///
  /// In en, this message translates to:
  /// **'{home}: {count, plural, =1{1 family member} other{{count} family members}}. Manage home'**
  String todayFamilyButton(String home, int count);

  /// No description provided for @todayYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get todayYourProfile;

  /// No description provided for @todayThingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing} other{{count} things}}'**
  String todayThingsCount(int count);

  /// No description provided for @todayThingsNeed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ needs the house today.} other{ need the house today.}}'**
  String todayThingsNeed(int count);

  /// No description provided for @todayStaffAtHome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 staff at home now} other{{count} staff at home now}}'**
  String todayStaffAtHome(int count);

  /// No description provided for @todayNoStaff.
  ///
  /// In en, this message translates to:
  /// **'No staff at home'**
  String get todayNoStaff;

  /// No description provided for @todayBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left in budget'**
  String todayBudgetLeft(String amount);

  /// No description provided for @todayBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String todayBudgetOver(String amount);

  /// No description provided for @todaySetABudget.
  ///
  /// In en, this message translates to:
  /// **'Set a budget'**
  String get todaySetABudget;

  /// No description provided for @qaGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get qaGrocery;

  /// No description provided for @qaShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get qaShopping;

  /// No description provided for @qaTodo.
  ///
  /// In en, this message translates to:
  /// **'To-do'**
  String get qaTodo;

  /// No description provided for @qaSpend.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get qaSpend;

  /// No description provided for @qaEmpty.
  ///
  /// In en, this message translates to:
  /// **'✨ Start typing — we’ll pick the right place.'**
  String get qaEmpty;

  /// No description provided for @qaPreviewTodo.
  ///
  /// In en, this message translates to:
  /// **'To-do · “{title}” · {day} · {who}'**
  String qaPreviewTodo(String title, String day, String who);

  /// No description provided for @qaPreviewSpend.
  ///
  /// In en, this message translates to:
  /// **'Spend · {amount} · {merchant} · {category}'**
  String qaPreviewSpend(String amount, String merchant, String category);

  /// No description provided for @qaPreviewSpendNoAmount.
  ///
  /// In en, this message translates to:
  /// **'Spend · add an amount, like “₹450”'**
  String get qaPreviewSpendNoAmount;

  /// No description provided for @qaPreviewItem.
  ///
  /// In en, this message translates to:
  /// **'{type} · {name} {qty} → {store}'**
  String qaPreviewItem(String type, String name, String qty, String store);

  /// No description provided for @qaUsual.
  ///
  /// In en, this message translates to:
  /// **' (usual)'**
  String get qaUsual;

  /// No description provided for @qaNeedAmount.
  ///
  /// In en, this message translates to:
  /// **'ⓘ Add an amount, like “₹450 Swiggy”'**
  String get qaNeedAmount;

  /// No description provided for @qaTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get qaTitle;

  /// No description provided for @qaLead.
  ///
  /// In en, this message translates to:
  /// **'Type it the way you’d say it.'**
  String get qaLead;

  /// No description provided for @qaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Milk 2L · Pay water bill tomorrow · ₹450 Swiggy'**
  String get qaPlaceholder;

  /// No description provided for @qaAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get qaAdd;

  /// No description provided for @qaFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get qaFabLabel;

  /// No description provided for @qaFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get qaFabTooltip;

  /// No description provided for @qaTodoAddedToday.
  ///
  /// In en, this message translates to:
  /// **'To-do added for today'**
  String get qaTodoAddedToday;

  /// No description provided for @qaTodoAddedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'To-do added for tomorrow'**
  String get qaTodoAddedTomorrow;

  /// No description provided for @qaTodoAddedOn.
  ///
  /// In en, this message translates to:
  /// **'To-do added for {day}'**
  String qaTodoAddedOn(String day);

  /// No description provided for @qaSpendAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to spends'**
  String qaSpendAdded(String amount);

  /// No description provided for @notifChannelStaff.
  ///
  /// In en, this message translates to:
  /// **'House help'**
  String get notifChannelStaff;

  /// No description provided for @notifChannelTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks & reminders'**
  String get notifChannelTasks;

  /// No description provided for @notifChannelMoney.
  ///
  /// In en, this message translates to:
  /// **'Bills & spends'**
  String get notifChannelMoney;

  /// No description provided for @notifChannelBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get notifChannelBackup;

  /// No description provided for @notifChannelHome.
  ///
  /// In en, this message translates to:
  /// **'Home & members'**
  String get notifChannelHome;

  /// No description provided for @notifAppName.
  ///
  /// In en, this message translates to:
  /// **'Illam'**
  String get notifAppName;

  /// No description provided for @notifArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'{name} usually comes by {time} — mark in?'**
  String notifArrivalBody(String name, String time);

  /// No description provided for @notifMarkInNow.
  ///
  /// In en, this message translates to:
  /// **'Mark in now'**
  String get notifMarkInNow;

  /// No description provided for @notifOnLeaveToday.
  ///
  /// In en, this message translates to:
  /// **'On leave today'**
  String get notifOnLeaveToday;

  /// No description provided for @notifDigestBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing today: {titles}} other{{count} things today: {titles}…}}'**
  String notifDigestBody(int count, String titles);

  /// No description provided for @notifBillBody.
  ///
  /// In en, this message translates to:
  /// **'{bill} is due today · {amount} last time'**
  String notifBillBody(String bill, String amount);

  /// No description provided for @notifPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String notifPaidAmount(String amount);

  /// No description provided for @notifOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notifOpen;

  /// No description provided for @notifEveningBody.
  ///
  /// In en, this message translates to:
  /// **'Spent anything today? Add it in a few seconds.'**
  String get notifEveningBody;

  /// No description provided for @notifExplainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders?'**
  String get notifExplainerTitle;

  /// No description provided for @notifExplainerBody.
  ///
  /// In en, this message translates to:
  /// **'Get a nudge when {name} usually arrives, and a morning list of what’s due.'**
  String notifExplainerBody(String name);

  /// No description provided for @notifYourHelp.
  ///
  /// In en, this message translates to:
  /// **'your house help'**
  String get notifYourHelp;

  /// No description provided for @notifNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notifNotNow;

  /// No description provided for @notifContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get notifContinue;

  /// No description provided for @notifOffBanner.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Illam'**
  String get notifOffBanner;

  /// No description provided for @notifTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notifTurnOn;

  /// No description provided for @debugRunJobs.
  ///
  /// In en, this message translates to:
  /// **'Run background jobs now'**
  String get debugRunJobs;

  /// No description provided for @debugPlanReminders.
  ///
  /// In en, this message translates to:
  /// **'Plan reminders'**
  String get debugPlanReminders;

  /// No description provided for @debugRanJobs.
  ///
  /// In en, this message translates to:
  /// **'Ran background jobs'**
  String get debugRanJobs;

  /// No description provided for @syncChangeNotApplied.
  ///
  /// In en, this message translates to:
  /// **'Your change wasn’t applied: {reason}'**
  String syncChangeNotApplied(String reason);

  /// No description provided for @syncReasonAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'only admins can change this'**
  String get syncReasonAdminOnly;

  /// No description provided for @syncReasonOwnOnly.
  ///
  /// In en, this message translates to:
  /// **'you can only change your own entries'**
  String get syncReasonOwnOnly;

  /// No description provided for @syncReasonTooOld.
  ///
  /// In en, this message translates to:
  /// **'it’s older than 48 hours'**
  String get syncReasonTooOld;

  /// No description provided for @syncReasonLastAdmin.
  ///
  /// In en, this message translates to:
  /// **'A home needs at least one admin.'**
  String get syncReasonLastAdmin;

  /// No description provided for @syncReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get syncReasonOther;

  /// No description provided for @syncLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync lab'**
  String get syncLabTitle;

  /// No description provided for @syncLabCounts.
  ///
  /// In en, this message translates to:
  /// **'Changes: {applied} applied · {pending} waiting · {quarantined} quarantined'**
  String syncLabCounts(int applied, int pending, int quarantined);

  /// No description provided for @syncLabMemberLog.
  ///
  /// In en, this message translates to:
  /// **'Membership log'**
  String get syncLabMemberLog;

  /// No description provided for @syncLabVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify all signatures'**
  String get syncLabVerify;

  /// No description provided for @syncLabVerifyResult.
  ///
  /// In en, this message translates to:
  /// **'{ok} ✓ signed · {bad} bad · {unsigned} unsigned'**
  String syncLabVerifyResult(int ok, int bad, int unsigned);

  /// No description provided for @syncLabExport.
  ///
  /// In en, this message translates to:
  /// **'Export bundle'**
  String get syncLabExport;

  /// No description provided for @syncLabExported.
  ///
  /// In en, this message translates to:
  /// **'Bundle copied · {n} changes'**
  String syncLabExported(int n);

  /// No description provided for @syncLabImport.
  ///
  /// In en, this message translates to:
  /// **'Import bundle from clipboard'**
  String get syncLabImport;

  /// No description provided for @syncLabImportResult.
  ///
  /// In en, this message translates to:
  /// **'Applied {applied} · already had {already} · waiting {pending} · quarantined {quarantined}'**
  String syncLabImportResult(
    int applied,
    int already,
    int pending,
    int quarantined,
  );

  /// No description provided for @syncLabOtherHome.
  ///
  /// In en, this message translates to:
  /// **'This bundle is for another home.'**
  String get syncLabOtherHome;

  /// No description provided for @syncLabReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace this phone’s home'**
  String get syncLabReplace;

  /// No description provided for @syncLabBadBundle.
  ///
  /// In en, this message translates to:
  /// **'That isn’t an Illam bundle.'**
  String get syncLabBadBundle;

  /// No description provided for @syncLabTamper.
  ///
  /// In en, this message translates to:
  /// **'Tamper test'**
  String get syncLabTamper;

  /// No description provided for @syncLabAsArjunTick.
  ///
  /// In en, this message translates to:
  /// **'As Arjun: tick a grocery item'**
  String get syncLabAsArjunTick;

  /// No description provided for @syncLabAsArjunRename.
  ///
  /// In en, this message translates to:
  /// **'As Arjun: rename the home'**
  String get syncLabAsArjunRename;

  /// No description provided for @syncLabSigned.
  ///
  /// In en, this message translates to:
  /// **'✓ signed'**
  String get syncLabSigned;

  /// No description provided for @syncLabUnsigned.
  ///
  /// In en, this message translates to:
  /// **'✕ not signed'**
  String get syncLabUnsigned;

  /// No description provided for @syncLabShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get syncLabShare;

  /// No description provided for @syncLabRecentOps.
  ///
  /// In en, this message translates to:
  /// **'Last {count} ops'**
  String syncLabRecentOps(int count);

  /// No description provided for @syncLabMemberCounts.
  ///
  /// In en, this message translates to:
  /// **'{applied} applied · {ignored} ignored · {pending} waiting · {devices} devices'**
  String syncLabMemberCounts(
    int applied,
    int ignored,
    int pending,
    int devices,
  );

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteTitle;

  /// No description provided for @inviteFirstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'{home} is ready'**
  String inviteFirstRunTitle(String home);

  /// No description provided for @inviteFirstRunSub.
  ///
  /// In en, this message translates to:
  /// **'Home ID {homeId}'**
  String inviteFirstRunSub(String homeId);

  /// No description provided for @inviteFirstRunLead.
  ///
  /// In en, this message translates to:
  /// **'Let your family scan this from their phone, or send them the phrase. You’ll approve each person here.'**
  String get inviteFirstRunLead;

  /// No description provided for @inviteQrLabel.
  ///
  /// In en, this message translates to:
  /// **'QR code to join {home}'**
  String inviteQrLabel(String home);

  /// No description provided for @inviteOrTypePhrase.
  ///
  /// In en, this message translates to:
  /// **'OR TYPE THIS PHRASE'**
  String get inviteOrTypePhrase;

  /// No description provided for @inviteSendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send phrase on WhatsApp'**
  String get inviteSendWhatsApp;

  /// No description provided for @inviteWhatsAppText.
  ///
  /// In en, this message translates to:
  /// **'Join \"{home}\" on Illam. Open the app → Join a home → type: {phrase}\n(works for 10 minutes)'**
  String inviteWhatsAppText(String home, String phrase);

  /// No description provided for @inviteCopyPhrase.
  ///
  /// In en, this message translates to:
  /// **'Copy phrase'**
  String get inviteCopyPhrase;

  /// No description provided for @invitePhraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Phrase copied — it works once, for 10 minutes'**
  String get invitePhraseCopied;

  /// No description provided for @inviteValidFor.
  ///
  /// In en, this message translates to:
  /// **'Valid for {time} · works once'**
  String inviteValidFor(String time);

  /// No description provided for @inviteExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired.'**
  String get inviteExpired;

  /// No description provided for @inviteMakeNew.
  ///
  /// In en, this message translates to:
  /// **'Make a new code'**
  String get inviteMakeNew;

  /// No description provided for @inviteVisibleWifi.
  ///
  /// In en, this message translates to:
  /// **'Visible on this Wi-Fi'**
  String get inviteVisibleWifi;

  /// No description provided for @inviteVisibleWifiSub.
  ///
  /// In en, this message translates to:
  /// **'Phones on the same Wi-Fi connect directly'**
  String get inviteVisibleWifiSub;

  /// No description provided for @inviteNoWifi.
  ///
  /// In en, this message translates to:
  /// **'Not on Wi-Fi — others can still join over the internet'**
  String get inviteNoWifi;

  /// No description provided for @inviteWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for someone to join…'**
  String get inviteWaiting;

  /// No description provided for @inviteWaitingSub.
  ///
  /// In en, this message translates to:
  /// **'Keep this screen open until they’re in'**
  String get inviteWaitingSub;

  /// No description provided for @inviteRequestEyebrow.
  ///
  /// In en, this message translates to:
  /// **'JOIN REQUEST'**
  String get inviteRequestEyebrow;

  /// No description provided for @inviteRequestVia.
  ///
  /// In en, this message translates to:
  /// **'{model} · on this Wi-Fi'**
  String inviteRequestVia(String model);

  /// No description provided for @inviteRequestSas.
  ///
  /// In en, this message translates to:
  /// **'Their phone should show {emojis}'**
  String inviteRequestSas(String emojis);

  /// No description provided for @inviteRequestSasHint.
  ///
  /// In en, this message translates to:
  /// **'If it doesn’t, tap Deny.'**
  String get inviteRequestSasHint;

  /// No description provided for @inviteJoinsAs.
  ///
  /// In en, this message translates to:
  /// **'Joins as'**
  String get inviteJoinsAs;

  /// No description provided for @inviteAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Admins can invite and remove people and manage pay.'**
  String get inviteAdminNote;

  /// No description provided for @inviteDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get inviteDeny;

  /// No description provided for @inviteAllow.
  ///
  /// In en, this message translates to:
  /// **'✓ Allow'**
  String get inviteAllow;

  /// No description provided for @inviteAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding {name}'**
  String inviteAdding(String name);

  /// No description provided for @inviteSending.
  ///
  /// In en, this message translates to:
  /// **'Sending the home’s data… {pct}%'**
  String inviteSending(int pct);

  /// No description provided for @inviteSendingSub.
  ///
  /// In en, this message translates to:
  /// **'Directly to their phone, encrypted. Keep this screen open.'**
  String get inviteSendingSub;

  /// No description provided for @inviteJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined'**
  String inviteJoined(String name);

  /// No description provided for @inviteJoinedSub.
  ///
  /// In en, this message translates to:
  /// **'Their phone now syncs with this home.'**
  String get inviteJoinedSub;

  /// No description provided for @inviteAnother.
  ///
  /// In en, this message translates to:
  /// **'Invite someone else'**
  String get inviteAnother;

  /// No description provided for @inviteDeclinedSnack.
  ///
  /// In en, this message translates to:
  /// **'Declined {name}. Made a new phrase so the old one can’t be reused.'**
  String inviteDeclinedSnack(String name);

  /// No description provided for @inviteSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now — invite later'**
  String get inviteSkip;

  /// No description provided for @inviteContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to my home'**
  String get inviteContinue;

  /// No description provided for @inviteDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inviteDone;

  /// No description provided for @inviteWelcomeSnack.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {home}'**
  String inviteWelcomeSnack(String home);

  /// No description provided for @inviteMembersOnly.
  ///
  /// In en, this message translates to:
  /// **'Only admins can invite people. Ask {admins}.'**
  String inviteMembersOnly(String admins);

  /// No description provided for @debugInvitePort.
  ///
  /// In en, this message translates to:
  /// **'Debug: listening on port {port}'**
  String debugInvitePort(int port);

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a home'**
  String get joinTitle;

  /// No description provided for @joinSub.
  ///
  /// In en, this message translates to:
  /// **'Ask someone at home to open Invite on their phone. Then scan their QR code or type the phrase they share.'**
  String get joinSub;

  /// No description provided for @joinYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get joinYourName;

  /// No description provided for @joinNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Add your name first — it’s how your family will see you.'**
  String get joinNameRequired;

  /// No description provided for @joinScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get joinScanTitle;

  /// No description provided for @joinScanSub.
  ///
  /// In en, this message translates to:
  /// **'Fastest when you’re next to them. Works on the same Wi-Fi or over the internet.'**
  String get joinScanSub;

  /// No description provided for @joinPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Type the join phrase'**
  String get joinPhraseTitle;

  /// No description provided for @joinPhraseSub.
  ///
  /// In en, this message translates to:
  /// **'Like 47-mango-river-tulip — good when they sent it on WhatsApp.'**
  String get joinPhraseSub;

  /// No description provided for @phraseSub.
  ///
  /// In en, this message translates to:
  /// **'A number and three words, shown on the Invite screen of their phone.'**
  String get phraseSub;

  /// No description provided for @phraseField.
  ///
  /// In en, this message translates to:
  /// **'Join phrase'**
  String get phraseField;

  /// No description provided for @phraseHint.
  ///
  /// In en, this message translates to:
  /// **'47-mango-river-tulip'**
  String get phraseHint;

  /// No description provided for @phraseNote.
  ///
  /// In en, this message translates to:
  /// **'Spaces are fine too: ‘47 mango river tulip’. The phrase works once and expires after 10 minutes.'**
  String get phraseNote;

  /// No description provided for @phraseConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get phraseConnect;

  /// No description provided for @phraseBadFormat.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look right. It’s a number and three words, like 47-mango-river-tulip.'**
  String get phraseBadFormat;

  /// No description provided for @phraseBadWord.
  ///
  /// In en, this message translates to:
  /// **'One of the words isn’t in the phrase list — check the spelling.'**
  String get phraseBadWord;

  /// No description provided for @debugPort.
  ///
  /// In en, this message translates to:
  /// **'Debug port'**
  String get debugPort;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'On their phone: Profile → Home → Invite someone'**
  String get scanHint;

  /// No description provided for @scanTypeInstead.
  ///
  /// In en, this message translates to:
  /// **'Type the phrase instead'**
  String get scanTypeInstead;

  /// No description provided for @scanNote.
  ///
  /// In en, this message translates to:
  /// **'🔒 The camera is used only to read the code. Nothing is recorded.'**
  String get scanNote;

  /// No description provided for @scanDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera to scan, or type the phrase instead.'**
  String get scanDenied;

  /// No description provided for @scanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanOpenSettings;

  /// No description provided for @scanTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get scanTorch;

  /// No description provided for @whoTheir.
  ///
  /// In en, this message translates to:
  /// **'their'**
  String get whoTheir;

  /// No description provided for @whoName.
  ///
  /// In en, this message translates to:
  /// **'{name}’s'**
  String whoName(String name);

  /// No description provided for @connectEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Joining'**
  String get connectEyebrow;

  /// No description provided for @connectEyebrowHome.
  ///
  /// In en, this message translates to:
  /// **'Joining · {home}'**
  String connectEyebrowHome(String home);

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectTitle;

  /// No description provided for @connectWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {home}'**
  String connectWelcome(String home);

  /// No description provided for @connectFailed.
  ///
  /// In en, this message translates to:
  /// **'Something stopped the join'**
  String get connectFailed;

  /// No description provided for @stepFindActive.
  ///
  /// In en, this message translates to:
  /// **'Looking for {who} phone on this Wi-Fi…'**
  String stepFindActive(String who);

  /// No description provided for @stepFindDone.
  ///
  /// In en, this message translates to:
  /// **'Found {who} phone on this Wi-Fi'**
  String stepFindDone(String who);

  /// No description provided for @stepCodeActive.
  ///
  /// In en, this message translates to:
  /// **'Checking the code…'**
  String get stepCodeActive;

  /// No description provided for @stepCodeDone.
  ///
  /// In en, this message translates to:
  /// **'Code matched · connection encrypted'**
  String get stepCodeDone;

  /// No description provided for @stepApproveActive.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {inviter} to approve…'**
  String stepApproveActive(String inviter);

  /// No description provided for @stepApproveSas.
  ///
  /// In en, this message translates to:
  /// **'Check that {inviter}’s phone shows {emojis}'**
  String stepApproveSas(String inviter, String emojis);

  /// No description provided for @stepApproveDone.
  ///
  /// In en, this message translates to:
  /// **'{inviter} approved you as {role, select, admin{an admin} other{a member}}'**
  String stepApproveDone(String inviter, String role);

  /// No description provided for @stepCopyActive.
  ///
  /// In en, this message translates to:
  /// **'Copying the home’s data… {pct}%'**
  String stepCopyActive(int pct);

  /// No description provided for @stepCopyDone.
  ///
  /// In en, this message translates to:
  /// **'Copied {n} items · you’re in sync'**
  String stepCopyDone(int n);

  /// No description provided for @successBody.
  ///
  /// In en, this message translates to:
  /// **'You’re in with {names}. Changes now sync between your phones.'**
  String successBody(String names);

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to {home}'**
  String goHome(String home);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @useDifferentCode.
  ///
  /// In en, this message translates to:
  /// **'Use a different code'**
  String get useDifferentCode;

  /// No description provided for @finishLater.
  ///
  /// In en, this message translates to:
  /// **'Finish later'**
  String get finishLater;

  /// No description provided for @finishLaterNote.
  ///
  /// In en, this message translates to:
  /// **'You’re already in — the copy continues next time.'**
  String get finishLaterNote;

  /// No description provided for @stoppedSnack.
  ///
  /// In en, this message translates to:
  /// **'Stopped. Nothing was shared.'**
  String get stoppedSnack;

  /// No description provided for @joinedSnack.
  ///
  /// In en, this message translates to:
  /// **'You joined {home} as {role, select, admin{an admin} other{a member}}'**
  String joinedSnack(String home, String role);

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach {who} phone'**
  String errNotFound(String who);

  /// No description provided for @errNotFoundHelp.
  ///
  /// In en, this message translates to:
  /// **'Tips: keep the Invite screen open on {inviter}’s phone, and make sure both phones have Wi-Fi or mobile data on. The phrase is valid for 10 minutes.'**
  String errNotFoundHelp(String inviter);

  /// No description provided for @errWrongCode.
  ///
  /// In en, this message translates to:
  /// **'The phrase didn’t match'**
  String get errWrongCode;

  /// No description provided for @errWrongCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Check the phrase with {inviter} — after 3 wrong tries it stops working and they’ll need to make a new one.'**
  String errWrongCodeHelp(String inviter);

  /// No description provided for @errExpired.
  ///
  /// In en, this message translates to:
  /// **'This phrase has expired or was already used. Ask for a new one.'**
  String get errExpired;

  /// No description provided for @errDeclined.
  ///
  /// In en, this message translates to:
  /// **'{inviter} declined the request'**
  String errDeclined(String inviter);

  /// No description provided for @errDeclinedHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask {inviter} to try again if this was a mistake.'**
  String errDeclinedHelp(String inviter);

  /// No description provided for @errVersion.
  ///
  /// In en, this message translates to:
  /// **'{inviter}’s Illam is a different version. Update both apps from the Play Store, then try again.'**
  String errVersion(String inviter);

  /// No description provided for @errCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy interrupted'**
  String get errCopy;

  /// No description provided for @setupBanner.
  ///
  /// In en, this message translates to:
  /// **'Finishing setup… {pct}% — keep Illam open on a family phone'**
  String setupBanner(int pct);

  /// No description provided for @agoNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m} min ago'**
  String agoMinutes(int m);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{h} h ago'**
  String agoHours(int h);

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{d, plural, =1{1 day ago} other{{d} days ago}}'**
  String agoDays(int d);

  /// No description provided for @syncTagOnlyThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Only this phone'**
  String get syncTagOnlyThisPhone;

  /// No description provided for @syncTagJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced with {name} just now'**
  String syncTagJustNow(String name);

  /// No description provided for @syncTagLast.
  ///
  /// In en, this message translates to:
  /// **'Last synced {ago}'**
  String syncTagLast(String ago);

  /// No description provided for @syncTagLabel.
  ///
  /// In en, this message translates to:
  /// **'{text}. Open sync details'**
  String syncTagLabel(String text);

  /// No description provided for @syncNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNotYet;

  /// No description provided for @todayOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — changes will sync'**
  String get todayOffline;

  /// No description provided for @syncCardAllInSync.
  ///
  /// In en, this message translates to:
  /// **'All phones in sync'**
  String get syncCardAllInSync;

  /// No description provided for @syncCardBehind.
  ///
  /// In en, this message translates to:
  /// **'{k, plural, =1{1 phone not up to date} other{{k} phones not up to date}}'**
  String syncCardBehind(int k);

  /// No description provided for @syncCardLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {ago}'**
  String syncCardLastSynced(String ago);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncedSnack.
  ///
  /// In en, this message translates to:
  /// **'Synced with phones that are reachable right now'**
  String get syncedSnack;

  /// No description provided for @syncNoPeers.
  ///
  /// In en, this message translates to:
  /// **'No family phones reachable right now'**
  String get syncNoPeers;

  /// No description provided for @syncRowTheirs.
  ///
  /// In en, this message translates to:
  /// **'{name}’s {model}'**
  String syncRowTheirs(String name, String model);

  /// No description provided for @syncOnWifiNow.
  ///
  /// In en, this message translates to:
  /// **'On this Wi-Fi now'**
  String get syncOnWifiNow;

  /// No description provided for @syncSyncedAgo.
  ///
  /// In en, this message translates to:
  /// **'Synced {ago}'**
  String syncSyncedAgo(String ago);

  /// No description provided for @syncNotForDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Not synced for 1 day} other{Not synced for {n} days}}'**
  String syncNotForDays(int n);

  /// No description provided for @syncMissing.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{ · missing 1 of your changes} other{ · missing {n} of your changes}}'**
  String syncMissing(int n);

  /// No description provided for @syncClockWrong.
  ///
  /// In en, this message translates to:
  /// **'Your phone’s clock looks wrong — sync may be off'**
  String get syncClockWrong;

  /// No description provided for @syncWifiBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your Wi-Fi may block phones from seeing each other — syncing over the internet instead.'**
  String get syncWifiBlocked;

  /// No description provided for @syncUpdateNeeded.
  ///
  /// In en, this message translates to:
  /// **'Update Illam to keep syncing with {name}'**
  String syncUpdateNeeded(String name);

  /// No description provided for @profileInSync.
  ///
  /// In en, this message translates to:
  /// **'✓ In sync'**
  String get profileInSync;

  /// No description provided for @profileOneBehind.
  ///
  /// In en, this message translates to:
  /// **'{name}’s phone is behind'**
  String profileOneBehind(String name);

  /// No description provided for @profileManyBehind.
  ///
  /// In en, this message translates to:
  /// **'{n} phones behind'**
  String profileManyBehind(int n);

  /// No description provided for @notifOutOfSync.
  ///
  /// In en, this message translates to:
  /// **'Illam hasn’t synced with your family for 3 days. Open it on the same Wi-Fi to catch up.'**
  String get notifOutOfSync;

  /// No description provided for @notifTodoAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'To-do assigned to you'**
  String get notifTodoAssignedTitle;

  /// No description provided for @notifTodoAssignedBody.
  ///
  /// In en, this message translates to:
  /// **'{title} · from {name}'**
  String notifTodoAssignedBody(String title, String name);

  /// No description provided for @notifJoinedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} joined {home}'**
  String notifJoinedTitle(String name, String home);

  /// No description provided for @notifJoinedBody.
  ///
  /// In en, this message translates to:
  /// **'Their phone now syncs with this home.'**
  String get notifJoinedBody;

  /// No description provided for @syncLabPort.
  ///
  /// In en, this message translates to:
  /// **'Listening on port {port}'**
  String syncLabPort(int port);

  /// No description provided for @syncLabPeers.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get syncLabPeers;

  /// No description provided for @syncLabVector.
  ///
  /// In en, this message translates to:
  /// **'My version vector'**
  String get syncLabVector;

  /// No description provided for @syncLabConnectLocal.
  ///
  /// In en, this message translates to:
  /// **'Connect to 127.0.0.1'**
  String get syncLabConnectLocal;

  /// No description provided for @homeGoneRemoved.
  ///
  /// In en, this message translates to:
  /// **'You’re no longer in {home}'**
  String homeGoneRemoved(String home);

  /// No description provided for @homeGoneDeleted.
  ///
  /// In en, this message translates to:
  /// **'{home} was deleted by {name}'**
  String homeGoneDeleted(String home, String name);

  /// No description provided for @homeGoneOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get homeGoneOk;

  /// No description provided for @memberRemovedNewKey.
  ///
  /// In en, this message translates to:
  /// **'{name} removed · new home key shared with the others'**
  String memberRemovedNewKey(String name);

  /// No description provided for @leaveChooseAdminLead.
  ///
  /// In en, this message translates to:
  /// **'You’re the only admin. Pick someone to look after {home} after you leave.'**
  String leaveChooseAdminLead(String home);

  /// No description provided for @leaveWaiting.
  ///
  /// In en, this message translates to:
  /// **'Leaving… waiting for a family phone'**
  String get leaveWaiting;

  /// No description provided for @leaveRemoveNow.
  ///
  /// In en, this message translates to:
  /// **'Remove from this phone now — we’ll tell your family the next time this phone reaches one of theirs'**
  String get leaveRemoveNow;

  /// No description provided for @deleteDone.
  ///
  /// In en, this message translates to:
  /// **'{home} deleted. Other phones erase it when they sync.'**
  String deleteDone(String home);

  /// No description provided for @opIgnoredRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Someone changed your role first.'**
  String get opIgnoredRoleChanged;

  /// No description provided for @inviteTipSecondAdmin.
  ///
  /// In en, this message translates to:
  /// **'Tip: make a second admin, so the home is never stuck without one.'**
  String get inviteTipSecondAdmin;

  /// No description provided for @inviteBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up {home} now'**
  String inviteBackupNow(String home);

  /// No description provided for @backupHealthOk.
  ///
  /// In en, this message translates to:
  /// **'Backed up {ago} to {provider} · by {name}'**
  String backupHealthOk(Object ago, Object provider, Object name);

  /// No description provided for @backupOnlyOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone — add another place'**
  String get backupOnlyOnPhone;

  /// No description provided for @backupNoRecoveryReady.
  ///
  /// In en, this message translates to:
  /// **'No recovery-ready backup'**
  String get backupNoRecoveryReady;

  /// No description provided for @backupNoBackupDays.
  ///
  /// In en, this message translates to:
  /// **'No backup in {n} days'**
  String backupNoBackupDays(int n);

  /// No description provided for @backupThisPhoneOn.
  ///
  /// In en, this message translates to:
  /// **'Backing up from this phone · {provider}'**
  String backupThisPhoneOn(Object provider);

  /// No description provided for @backupAlso.
  ///
  /// In en, this message translates to:
  /// **'Also: {name} backs up to {provider} ({ago})'**
  String backupAlso(Object name, Object provider, Object ago);

  /// No description provided for @backupNoAdminHint.
  ///
  /// In en, this message translates to:
  /// **'No admin has a backup yet — if every admin phone is lost, a restore brings people back as members.'**
  String get backupNoAdminHint;

  /// No description provided for @backupProviderFolderShort.
  ///
  /// In en, this message translates to:
  /// **'a folder'**
  String get backupProviderFolderShort;

  /// No description provided for @backupJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get backupJustNow;

  /// No description provided for @backupAttention.
  ///
  /// In en, this message translates to:
  /// **'Backup needs attention — {reason}'**
  String backupAttention(Object reason);

  /// No description provided for @backupReasonAuth.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {provider} again to keep backups running.'**
  String backupReasonAuth(Object provider);

  /// No description provided for @backupReasonFull.
  ///
  /// In en, this message translates to:
  /// **'{provider} is full — free space or choose another place.'**
  String backupReasonFull(Object provider);

  /// No description provided for @backupErrNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No permission to write to that folder'**
  String get backupErrNoPermission;

  /// No description provided for @backupStatusStale.
  ///
  /// In en, this message translates to:
  /// **'Not backed up for {n} days'**
  String backupStatusStale(int n);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupProfileRow.
  ///
  /// In en, this message translates to:
  /// **'Backup — {provider} · {frequency} · last {ago}'**
  String backupProfileRow(Object provider, Object frequency, Object ago);

  /// No description provided for @backupProfileNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Backup — not set up'**
  String get backupProfileNotSetUp;

  /// No description provided for @backupDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backupDaily;

  /// No description provided for @backupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backupWeekly;

  /// No description provided for @backupMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backupMonthly;

  /// No description provided for @notifBackupAttention.
  ///
  /// In en, this message translates to:
  /// **'Backup needs attention'**
  String get notifBackupAttention;

  /// No description provided for @notifBackupAttentionSub.
  ///
  /// In en, this message translates to:
  /// **'Only when backups stop working'**
  String get notifBackupAttentionSub;

  /// No description provided for @backupHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep {home} safe'**
  String backupHeroTitle(Object home);

  /// No description provided for @backupHeroLead.
  ///
  /// In en, this message translates to:
  /// **'Illam has no cloud of its own. If every phone in the home is lost, a backup is the only way back.'**
  String get backupHeroLead;

  /// No description provided for @backupPromise1Title.
  ///
  /// In en, this message translates to:
  /// **'Locked before it leaves this phone'**
  String get backupPromise1Title;

  /// No description provided for @backupPromise1.
  ///
  /// In en, this message translates to:
  /// **'Encrypted with a password only you know. Your cloud sees just a locked file.'**
  String get backupPromise1;

  /// No description provided for @backupPromise2Title.
  ///
  /// In en, this message translates to:
  /// **'Runs by itself'**
  String get backupPromise2Title;

  /// No description provided for @backupPromise2.
  ///
  /// In en, this message translates to:
  /// **'Every week on Wi-Fi while charging. You’ll hear from us only if it stops working.'**
  String get backupPromise2;

  /// No description provided for @backupPromise3Title.
  ///
  /// In en, this message translates to:
  /// **'Brings everything back'**
  String get backupPromise3Title;

  /// No description provided for @backupPromise3.
  ///
  /// In en, this message translates to:
  /// **'Lists, staff, attendance, salary, meals and spends, plus your own recovery key, so a new phone gets you back in with the same role you have now.'**
  String get backupPromise3;

  /// No description provided for @backupWhere.
  ///
  /// In en, this message translates to:
  /// **'Where should backups go?'**
  String get backupWhere;

  /// No description provided for @backupGroupSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get backupGroupSignIn;

  /// No description provided for @backupGroupServer.
  ///
  /// In en, this message translates to:
  /// **'Your own server'**
  String get backupGroupServer;

  /// No description provided for @backupGroupDevice.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get backupGroupDevice;

  /// No description provided for @backupDontSee.
  ///
  /// In en, this message translates to:
  /// **'Don’t see yours?'**
  String get backupDontSee;

  /// No description provided for @backupDontSeeBody.
  ///
  /// In en, this message translates to:
  /// **'Don’t see yours? Proton Drive and MEGA are coming later. iCloud, Box, Terabox and JioCloud can’t be connected from Android apps — use WebDAV if your provider offers it, or a folder on this phone.'**
  String get backupDontSeeBody;

  /// No description provided for @backupAlsoIn.
  ///
  /// In en, this message translates to:
  /// **'Also in {home}: {name} backs up to {provider} ({ago}).'**
  String backupAlsoIn(Object home, Object name, Object provider, Object ago);

  /// No description provided for @backupArrivesP19.
  ///
  /// In en, this message translates to:
  /// **'Arrives in P19'**
  String get backupArrivesP19;

  /// No description provided for @backupArrivesP20.
  ///
  /// In en, this message translates to:
  /// **'Arrives in P20'**
  String get backupArrivesP20;

  /// No description provided for @backupProvFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder on this phone or another app'**
  String get backupProvFolder;

  /// No description provided for @backupProvFolderSub.
  ///
  /// In en, this message translates to:
  /// **'SD card, USB drive, or a cloud app that offers folders'**
  String get backupProvFolderSub;

  /// No description provided for @backupProvGdrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get backupProvGdrive;

  /// No description provided for @backupProvGdriveSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in · Hidden app folder in your Drive'**
  String get backupProvGdriveSub;

  /// No description provided for @backupProvOnedrive.
  ///
  /// In en, this message translates to:
  /// **'OneDrive'**
  String get backupProvOnedrive;

  /// No description provided for @backupProvOnedriveSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in · Apps › Illam'**
  String get backupProvOnedriveSub;

  /// No description provided for @backupProvDropbox.
  ///
  /// In en, this message translates to:
  /// **'Dropbox'**
  String get backupProvDropbox;

  /// No description provided for @backupProvDropboxSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in · Apps › Illam'**
  String get backupProvDropboxSub;

  /// No description provided for @backupProvPcloud.
  ///
  /// In en, this message translates to:
  /// **'pCloud'**
  String get backupProvPcloud;

  /// No description provided for @backupProvPcloudSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in · App folder · EU or US region'**
  String get backupProvPcloudSub;

  /// No description provided for @backupProvNextcloud.
  ///
  /// In en, this message translates to:
  /// **'Nextcloud'**
  String get backupProvNextcloud;

  /// No description provided for @backupProvNextcloudSub.
  ///
  /// In en, this message translates to:
  /// **'Your own or a hosted Nextcloud'**
  String get backupProvNextcloudSub;

  /// No description provided for @backupProvWebdav.
  ///
  /// In en, this message translates to:
  /// **'WebDAV'**
  String get backupProvWebdav;

  /// No description provided for @backupProvWebdavSub.
  ///
  /// In en, this message translates to:
  /// **'ownCloud, Synology, QNAP, Koofr, Yandex Disk, any WebDAV'**
  String get backupProvWebdavSub;

  /// No description provided for @backupProvS3.
  ///
  /// In en, this message translates to:
  /// **'S3-compatible'**
  String get backupProvS3;

  /// No description provided for @backupProvS3Sub.
  ///
  /// In en, this message translates to:
  /// **'AWS S3, Backblaze B2, Wasabi, Cloudflare R2, MinIO'**
  String get backupProvS3Sub;

  /// No description provided for @backupProvSftp.
  ///
  /// In en, this message translates to:
  /// **'SFTP'**
  String get backupProvSftp;

  /// No description provided for @backupProvSftpSub.
  ///
  /// In en, this message translates to:
  /// **'Home NAS or your own server'**
  String get backupProvSftpSub;

  /// No description provided for @backupChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking… wrote a test file'**
  String get backupChecking;

  /// No description provided for @backupErrUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach that server'**
  String get backupErrUnreachable;

  /// No description provided for @backupLocalCopy.
  ///
  /// In en, this message translates to:
  /// **'Local copy — lost with the phone'**
  String get backupLocalCopy;

  /// No description provided for @backupPwTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a backup password'**
  String get backupPwTitle;

  /// No description provided for @backupPwField.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPwField;

  /// No description provided for @backupPwConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPwConfirm;

  /// No description provided for @backupPwTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get backupPwTooShort;

  /// No description provided for @backupPwOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get backupPwOkay;

  /// No description provided for @backupPwStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get backupPwStrong;

  /// No description provided for @backupPwSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest one'**
  String get backupPwSuggest;

  /// No description provided for @backupPwWarning.
  ///
  /// In en, this message translates to:
  /// **'We can’t reset this password. Without it, backups can’t be opened. Save it in your password manager or write it down.'**
  String get backupPwWarning;

  /// No description provided for @backupPwSaved.
  ///
  /// In en, this message translates to:
  /// **'I’ve saved this password somewhere safe'**
  String get backupPwSaved;

  /// No description provided for @backupPwSave.
  ///
  /// In en, this message translates to:
  /// **'Save password & back up'**
  String get backupPwSave;

  /// No description provided for @backupPwMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords don’t match.'**
  String get backupPwMismatch;

  /// No description provided for @backupPwMissing.
  ///
  /// In en, this message translates to:
  /// **'Nothing is backed up yet. Set a backup password to start.'**
  String get backupPwMissing;

  /// No description provided for @backupStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Backed up {ago}'**
  String backupStatusOk(Object ago);

  /// No description provided for @backupStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Backing up… {pct}%'**
  String backupStatusRunning(int pct);

  /// No description provided for @backupStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Last backup failed — {reason}'**
  String backupStatusFailed(Object reason);

  /// No description provided for @backupStatusUnchanged.
  ///
  /// In en, this message translates to:
  /// **'No changes since last backup'**
  String get backupStatusUnchanged;

  /// No description provided for @backupNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {when} · {conditions}'**
  String backupNext(Object when, Object conditions);

  /// No description provided for @backupOnWifi.
  ///
  /// In en, this message translates to:
  /// **'on Wi-Fi'**
  String get backupOnWifi;

  /// No description provided for @backupWhileCharging.
  ///
  /// In en, this message translates to:
  /// **'while charging'**
  String get backupWhileCharging;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @backupWhereGo.
  ///
  /// In en, this message translates to:
  /// **'Where backups go'**
  String get backupWhereGo;

  /// No description provided for @backupPlacesCount.
  ///
  /// In en, this message translates to:
  /// **'{k} of 3'**
  String backupPlacesCount(int k);

  /// No description provided for @backupDestLast.
  ///
  /// In en, this message translates to:
  /// **'Last: {ago} · {k} kept'**
  String backupDestLast(Object ago, int k);

  /// No description provided for @backupDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get backupDisconnect;

  /// No description provided for @backupStayThere.
  ///
  /// In en, this message translates to:
  /// **'Backups already there stay there.'**
  String get backupStayThere;

  /// No description provided for @backupAddPlace.
  ///
  /// In en, this message translates to:
  /// **'＋ Add another place'**
  String get backupAddPlace;

  /// No description provided for @backupSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get backupSchedule;

  /// No description provided for @backupHowOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get backupHowOften;

  /// No description provided for @backupWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Only on Wi-Fi'**
  String get backupWifiOnly;

  /// No description provided for @backupWifiOnlySub.
  ///
  /// In en, this message translates to:
  /// **'Never uses mobile data'**
  String get backupWifiOnlySub;

  /// No description provided for @backupCharging.
  ///
  /// In en, this message translates to:
  /// **'Only while charging'**
  String get backupCharging;

  /// No description provided for @backupChargingSub.
  ///
  /// In en, this message translates to:
  /// **'Usually overnight'**
  String get backupChargingSub;

  /// No description provided for @backupKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep the most recent'**
  String get backupKeep;

  /// No description provided for @backupKeepN.
  ///
  /// In en, this message translates to:
  /// **'{n} backups'**
  String backupKeepN(int n);

  /// No description provided for @backupKeepSub.
  ///
  /// In en, this message translates to:
  /// **'Older ones are deleted from that place after a successful backup.'**
  String get backupKeepSub;

  /// No description provided for @backupProgressNotif.
  ///
  /// In en, this message translates to:
  /// **'Backing up {home}…'**
  String backupProgressNotif(Object home);

  /// No description provided for @backupLocalTag.
  ///
  /// In en, this message translates to:
  /// **'Local copy'**
  String get backupLocalTag;

  /// No description provided for @backupPwRow.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPwRow;

  /// No description provided for @backupPwRowSub.
  ///
  /// In en, this message translates to:
  /// **'Set {date} · saved on this phone'**
  String backupPwRowSub(Object date);

  /// No description provided for @backupPwChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change backup password'**
  String get backupPwChangeTitle;

  /// No description provided for @backupPwChangeNote.
  ///
  /// In en, this message translates to:
  /// **'New backups use the new password. Older backups still need the old one.'**
  String get backupPwChangeNote;

  /// No description provided for @backupPwChangeSave.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get backupPwChangeSave;

  /// No description provided for @backupCheck.
  ///
  /// In en, this message translates to:
  /// **'Check a backup'**
  String get backupCheck;

  /// No description provided for @backupCheckSub.
  ///
  /// In en, this message translates to:
  /// **'Opens the latest backup to make sure it works'**
  String get backupCheckSub;

  /// No description provided for @backupCheckOk.
  ///
  /// In en, this message translates to:
  /// **'Latest backup opens fine · {n} items · {size}'**
  String backupCheckOk(int n, Object size);

  /// No description provided for @backupDamaged.
  ///
  /// In en, this message translates to:
  /// **'This backup is damaged — try an older one.'**
  String get backupDamaged;

  /// No description provided for @backupCheckUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach the backup place — try again later.'**
  String get backupCheckUnreachable;

  /// No description provided for @backupRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent backups'**
  String get backupRecent;

  /// No description provided for @backupRecentRow.
  ///
  /// In en, this message translates to:
  /// **'{ago} · {size} · {place}'**
  String backupRecentRow(Object ago, Object size, Object place);

  /// No description provided for @backupRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backups yet.'**
  String get backupRecentEmpty;

  /// No description provided for @backupKits.
  ///
  /// In en, this message translates to:
  /// **'Recovery keys'**
  String get backupKits;

  /// No description provided for @backupKitRow.
  ///
  /// In en, this message translates to:
  /// **'{name}’s {model}'**
  String backupKitRow(Object name, Object model);

  /// No description provided for @backupKitThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get backupKitThisPhone;

  /// No description provided for @backupKitSub.
  ///
  /// In en, this message translates to:
  /// **'Made {date} · restores {name} as {role, select, admin{an admin} other{a member}}'**
  String backupKitSub(Object date, Object name, String role);

  /// No description provided for @backupKitTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get backupKitTurnOff;

  /// No description provided for @backupKitOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off {name}’s recovery key?'**
  String backupKitOffTitle(Object name);

  /// No description provided for @backupKitOffLead.
  ///
  /// In en, this message translates to:
  /// **'Backups made with it can still be opened, but only as a separate copy — they can’t bring {name} back into {home}. {name}’s phone makes a new key at its next backup.'**
  String backupKitOffLead(Object name, Object home);

  /// No description provided for @backupKitKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get backupKitKeep;

  /// No description provided for @backupKitDead.
  ///
  /// In en, this message translates to:
  /// **'Make a new backup — the old recovery kit no longer works.'**
  String get backupKitDead;

  /// No description provided for @backupFinePrint.
  ///
  /// In en, this message translates to:
  /// **'Backups include your recovery key. Anyone with the file and the password can restore {home} as {role, select, admin{an admin} other{a member}} — keep the password private.'**
  String backupFinePrint(Object home, String role);

  /// No description provided for @debugDamageBackup.
  ///
  /// In en, this message translates to:
  /// **'Write a damaged copy of the latest backup'**
  String get debugDamageBackup;

  /// No description provided for @debugFolderOffPhone.
  ///
  /// In en, this message translates to:
  /// **'Count folders as off-phone'**
  String get debugFolderOffPhone;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get restoreTitle;

  /// No description provided for @restoreSub.
  ///
  /// In en, this message translates to:
  /// **'Choose where your backup is.'**
  String get restoreSub;

  /// No description provided for @restoreNote.
  ///
  /// In en, this message translates to:
  /// **'🔒 Your backup is opened on this phone. Nothing is sent to Illam.'**
  String get restoreNote;

  /// No description provided for @restorePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a backup'**
  String get restorePickTitle;

  /// No description provided for @restoreFoundIn.
  ///
  /// In en, this message translates to:
  /// **'Found in {provider} · {account}'**
  String restoreFoundIn(Object provider, Object account);

  /// No description provided for @restoreVault.
  ///
  /// In en, this message translates to:
  /// **'Home backup · {vault}'**
  String restoreVault(Object vault);

  /// No description provided for @restoreRow.
  ///
  /// In en, this message translates to:
  /// **'{date} · {size}'**
  String restoreRow(Object date, Object size);

  /// No description provided for @restoreTagKit.
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get restoreTagKit;

  /// No description provided for @restoreTagData.
  ///
  /// In en, this message translates to:
  /// **'Data only'**
  String get restoreTagData;

  /// No description provided for @restoreOlder.
  ///
  /// In en, this message translates to:
  /// **'Older backups ({n})'**
  String restoreOlder(int n);

  /// No description provided for @restoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Illam backups here — check you picked the right account or folder.'**
  String get restoreEmpty;

  /// No description provided for @restoreChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another place'**
  String get restoreChooseAnother;

  /// No description provided for @restoreUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock this backup'**
  String get restoreUnlockTitle;

  /// No description provided for @restoreUnlocking.
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get restoreUnlocking;

  /// No description provided for @restoreWrongPw.
  ///
  /// In en, this message translates to:
  /// **'Wrong password — passwords are case-sensitive.'**
  String get restoreWrongPw;

  /// No description provided for @restoreHeaderCard.
  ///
  /// In en, this message translates to:
  /// **'{home} · {homeId} · {date} · from {model} ({name})'**
  String restoreHeaderCard(
    Object home,
    Object homeId,
    Object date,
    Object model,
    Object name,
  );

  /// No description provided for @restoreStepDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get restoreStepDownload;

  /// No description provided for @restoreStepUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlocking'**
  String get restoreStepUnlock;

  /// No description provided for @restoreStepCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking the home’s history'**
  String get restoreStepCheck;

  /// No description provided for @restoreStepSetup.
  ///
  /// In en, this message translates to:
  /// **'Setting up this phone'**
  String get restoreStepSetup;

  /// No description provided for @restoreWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to {home}'**
  String restoreWelcome(Object home);

  /// No description provided for @restoreOthersNote.
  ///
  /// In en, this message translates to:
  /// **'Phones still in {home} will show that you restored on a new phone.'**
  String restoreOthersNote(Object home);

  /// No description provided for @restoreKeepBackingUp.
  ///
  /// In en, this message translates to:
  /// **'Keep backing up to {provider}'**
  String restoreKeepBackingUp(Object provider);

  /// No description provided for @restoreGo.
  ///
  /// In en, this message translates to:
  /// **'Go to {home}'**
  String restoreGo(Object home);

  /// No description provided for @restoreAlreadyHere.
  ///
  /// In en, this message translates to:
  /// **'{home} is already on this phone.'**
  String restoreAlreadyHere(Object home);

  /// No description provided for @restoreOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get restoreOpen;

  /// No description provided for @restoreDownloadFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t download — check your connection and try again.'**
  String get restoreDownloadFail;

  /// No description provided for @restoreBanner.
  ///
  /// In en, this message translates to:
  /// **'Restored from a backup made {date}. Connecting to the rest of {home}…'**
  String restoreBanner(Object date, Object home);

  /// No description provided for @restoreDeadKit.
  ///
  /// In en, this message translates to:
  /// **'This backup’s recovery key was turned off on {date}. Ask an admin in {home} to invite you.'**
  String restoreDeadKit(Object date, Object home);

  /// No description provided for @restoreSeparateCopy.
  ///
  /// In en, this message translates to:
  /// **'Keep as a separate copy'**
  String get restoreSeparateCopy;

  /// No description provided for @restoreRemoveFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Remove from this phone'**
  String get restoreRemoveFromPhone;

  /// No description provided for @restoreSeparateName.
  ///
  /// In en, this message translates to:
  /// **'{home} (restored {date})'**
  String restoreSeparateName(Object home, Object date);

  /// No description provided for @restoreOtherAdmin.
  ///
  /// In en, this message translates to:
  /// **'{name} restored {home} on a new phone from a backup'**
  String restoreOtherAdmin(Object name, Object home);

  /// No description provided for @restoreKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get restoreKeep;

  /// No description provided for @restoreRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get restoreRemove;

  /// No description provided for @bkSrvErrAuth.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or app password'**
  String get bkSrvErrAuth;

  /// No description provided for @bkSrvErrBucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket not found'**
  String get bkSrvErrBucket;

  /// No description provided for @bkSrvErrOther.
  ///
  /// In en, this message translates to:
  /// **'That didn’t work — check the details and try again.'**
  String get bkSrvErrOther;

  /// No description provided for @bkSrvErrHttps.
  ///
  /// In en, this message translates to:
  /// **'Use an address that starts with https://'**
  String get bkSrvErrHttps;

  /// No description provided for @bkSrvErrHostKeyChanged.
  ///
  /// In en, this message translates to:
  /// **'This server’s fingerprint changed. If you didn’t change the server, don’t connect.'**
  String get bkSrvErrHostKeyChanged;

  /// No description provided for @bkSrvConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get bkSrvConnect;

  /// No description provided for @bkSrvTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust this server?'**
  String get bkSrvTrustTitle;

  /// No description provided for @bkSrvTrustLead.
  ///
  /// In en, this message translates to:
  /// **'First time connecting to {host}. Check that this fingerprint matches the one on your server.'**
  String bkSrvTrustLead(Object host);

  /// No description provided for @bkSrvTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get bkSrvTrust;

  /// No description provided for @bkSrvWebdavTitle.
  ///
  /// In en, this message translates to:
  /// **'WebDAV'**
  String get bkSrvWebdavTitle;

  /// No description provided for @bkSrvServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get bkSrvServerAddress;

  /// No description provided for @bkSrvUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get bkSrvUsername;

  /// No description provided for @bkSrvAppPassword.
  ///
  /// In en, this message translates to:
  /// **'App password'**
  String get bkSrvAppPassword;

  /// No description provided for @bkSrvWebdavHint.
  ///
  /// In en, this message translates to:
  /// **'Works with ownCloud, Synology, QNAP, Koofr, Yandex Disk, pCloud and any WebDAV server. Use an app password, not your main one.'**
  String get bkSrvWebdavHint;

  /// No description provided for @bkSrvAccount.
  ///
  /// In en, this message translates to:
  /// **'{user} @ {host}'**
  String bkSrvAccount(Object user, Object host);

  /// No description provided for @bkSrvNextcloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Nextcloud'**
  String get bkSrvNextcloudTitle;

  /// No description provided for @bkSrvNextcloudHint.
  ///
  /// In en, this message translates to:
  /// **'We’ll open your Nextcloud login in the browser. Approve Illam there — it gets its own app password you can revoke any time.'**
  String get bkSrvNextcloudHint;

  /// No description provided for @bkSrvNextcloudAccessNote.
  ///
  /// In en, this message translates to:
  /// **'This app password can reach your whole Nextcloud account. A separate Nextcloud user just for backups is safer.'**
  String get bkSrvNextcloudAccessNote;

  /// No description provided for @bkSrvContinueInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Continue in browser'**
  String get bkSrvContinueInBrowser;

  /// No description provided for @bkSrvOpeningLogin.
  ///
  /// In en, this message translates to:
  /// **'Opening your Nextcloud login…'**
  String get bkSrvOpeningLogin;

  /// No description provided for @bkSrvApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve in your browser'**
  String get bkSrvApproveTitle;

  /// No description provided for @bkSrvApproveLead.
  ///
  /// In en, this message translates to:
  /// **'Log in to {host} and tap Grant access for Illam. Then come back here.'**
  String bkSrvApproveLead(Object host);

  /// No description provided for @bkSrvWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval…'**
  String get bkSrvWaitingApproval;

  /// No description provided for @bkSrvS3Title.
  ///
  /// In en, this message translates to:
  /// **'S3-compatible'**
  String get bkSrvS3Title;

  /// No description provided for @bkSrvService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bkSrvService;

  /// No description provided for @bkSrvPresetAws.
  ///
  /// In en, this message translates to:
  /// **'AWS'**
  String get bkSrvPresetAws;

  /// No description provided for @bkSrvPresetB2.
  ///
  /// In en, this message translates to:
  /// **'Backblaze B2'**
  String get bkSrvPresetB2;

  /// No description provided for @bkSrvPresetWasabi.
  ///
  /// In en, this message translates to:
  /// **'Wasabi'**
  String get bkSrvPresetWasabi;

  /// No description provided for @bkSrvPresetR2.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare R2'**
  String get bkSrvPresetR2;

  /// No description provided for @bkSrvPresetMinio.
  ///
  /// In en, this message translates to:
  /// **'MinIO'**
  String get bkSrvPresetMinio;

  /// No description provided for @bkSrvPresetOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get bkSrvPresetOther;

  /// No description provided for @bkSrvRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get bkSrvRegion;

  /// No description provided for @bkSrvEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get bkSrvEndpoint;

  /// No description provided for @bkSrvBucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get bkSrvBucket;

  /// No description provided for @bkSrvAccessKeyId.
  ///
  /// In en, this message translates to:
  /// **'Access key ID'**
  String get bkSrvAccessKeyId;

  /// No description provided for @bkSrvSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret access key'**
  String get bkSrvSecretKey;

  /// No description provided for @bkSrvS3Hint.
  ///
  /// In en, this message translates to:
  /// **'Create a key that can only write to this bucket. Files go under illam/.'**
  String get bkSrvS3Hint;

  /// No description provided for @bkSrvS3Account.
  ///
  /// In en, this message translates to:
  /// **'{bucket} · {service}'**
  String bkSrvS3Account(Object bucket, Object service);

  /// No description provided for @bkSrvSftpTitle.
  ///
  /// In en, this message translates to:
  /// **'SFTP'**
  String get bkSrvSftpTitle;

  /// No description provided for @bkSrvHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get bkSrvHost;

  /// No description provided for @bkSrvPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get bkSrvPort;

  /// No description provided for @bkSrvPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get bkSrvPassword;

  /// No description provided for @bkSrvFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get bkSrvFolder;

  /// No description provided for @bkSrvSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Sign in with'**
  String get bkSrvSignInWith;

  /// No description provided for @bkSrvAuthPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get bkSrvAuthPassword;

  /// No description provided for @bkSrvAuthKey.
  ///
  /// In en, this message translates to:
  /// **'A key made on this phone'**
  String get bkSrvAuthKey;

  /// No description provided for @bkSrvKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Add this key to the server’s authorized_keys file for this user, then tap Connect.'**
  String get bkSrvKeyHint;

  /// No description provided for @bkSrvCopyKey.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get bkSrvCopyKey;

  /// No description provided for @bkSrvKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get bkSrvKeyCopied;

  /// No description provided for @bkSrvSftpAccessNote.
  ///
  /// In en, this message translates to:
  /// **'Tip: a server user that can only see its own folder is safer.'**
  String get bkSrvSftpAccessNote;

  /// No description provided for @bkSrvSftpAccount.
  ///
  /// In en, this message translates to:
  /// **'{user}@{host}:{port}'**
  String bkSrvSftpAccount(Object user, Object host, Object port);

  /// No description provided for @bkSrvSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get bkSrvSignInAgain;

  /// No description provided for @bkCloudGdriveAccess.
  ///
  /// In en, this message translates to:
  /// **'See, create and delete its own data in your Google Drive — a hidden app folder. It can’t see your other files.'**
  String get bkCloudGdriveAccess;

  /// No description provided for @bkCloudGdriveWhere.
  ///
  /// In en, this message translates to:
  /// **'Hidden app folder in your Drive'**
  String get bkCloudGdriveWhere;

  /// No description provided for @bkCloudConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to {provider}'**
  String bkCloudConnected(Object provider);

  /// No description provided for @bkCloudSignedInAgain.
  ///
  /// In en, this message translates to:
  /// **'Signed in to {provider} again'**
  String bkCloudSignedInAgain(Object provider);

  /// No description provided for @bkCloudSignInAgainSub.
  ///
  /// In en, this message translates to:
  /// **'Use this if backups say the sign-in expired'**
  String get bkCloudSignInAgainSub;

  /// No description provided for @bkCloudExpiredRow.
  ///
  /// In en, this message translates to:
  /// **'Sign-in expired — Sign in again'**
  String get bkCloudExpiredRow;

  /// No description provided for @bkCloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'This build isn’t set up for {provider} yet.'**
  String bkCloudNotConfigured(Object provider);

  /// No description provided for @bkCloudSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t sign in to {provider} — try again.'**
  String bkCloudSignInFailed(Object provider);

  /// No description provided for @bkCloudDropboxAccess.
  ///
  /// In en, this message translates to:
  /// **'Read and write files in Apps › Illam only. It can’t see your other files.'**
  String get bkCloudDropboxAccess;

  /// No description provided for @bkCloudOnedriveAccess.
  ///
  /// In en, this message translates to:
  /// **'Read and write files in its own folder, Apps › Illam. It can’t see your other files.'**
  String get bkCloudOnedriveAccess;

  /// No description provided for @bkCloudAppsFolder.
  ///
  /// In en, this message translates to:
  /// **'Apps › Illam'**
  String get bkCloudAppsFolder;

  /// No description provided for @bkCloudOrgApproval.
  ///
  /// In en, this message translates to:
  /// **'Your organisation must approve Illam before it can use this OneDrive. Ask your IT admin, or choose another place.'**
  String get bkCloudOrgApproval;

  /// No description provided for @bkCloudPcloudAccess.
  ///
  /// In en, this message translates to:
  /// **'Read and write files in its own app folder only.'**
  String get bkCloudPcloudAccess;

  /// No description provided for @bkCloudPcloudWhere.
  ///
  /// In en, this message translates to:
  /// **'App folder · EU or US region'**
  String get bkCloudPcloudWhere;

  /// No description provided for @bkCloudPcloudAccount.
  ///
  /// In en, this message translates to:
  /// **'{email} · {region}'**
  String bkCloudPcloudAccount(Object email, Object region);

  /// No description provided for @debugBackupLab.
  ///
  /// In en, this message translates to:
  /// **'Backup lab'**
  String get debugBackupLab;

  /// No description provided for @debugGoogleSilent.
  ///
  /// In en, this message translates to:
  /// **'Google silent sign-in now'**
  String get debugGoogleSilent;

  /// No description provided for @debugExpireTokens.
  ///
  /// In en, this message translates to:
  /// **'Expire Dropbox/OneDrive tokens'**
  String get debugExpireTokens;

  /// No description provided for @debugBreakTokens.
  ///
  /// In en, this message translates to:
  /// **'Break Dropbox/OneDrive refresh token'**
  String get debugBreakTokens;

  /// No description provided for @debugResultOk.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get debugResultOk;

  /// No description provided for @debugResultNeedsSignIn.
  ///
  /// In en, this message translates to:
  /// **'needs sign-in'**
  String get debugResultNeedsSignIn;

  /// No description provided for @debugAdd200Items.
  ///
  /// In en, this message translates to:
  /// **'Add 200 test items'**
  String get debugAdd200Items;

  /// No description provided for @remoteSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote sync'**
  String get remoteSyncTitle;

  /// No description provided for @remoteSyncExperimental.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get remoteSyncExperimental;

  /// No description provided for @remoteSyncToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote sync (experimental)'**
  String get remoteSyncToggleTitle;

  /// No description provided for @remoteSyncToggleSub.
  ///
  /// In en, this message translates to:
  /// **'Relay end-to-end encrypted updates through your own Firebase project'**
  String get remoteSyncToggleSub;

  /// No description provided for @remoteSyncOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring Your Own Firebase'**
  String get remoteSyncOffTitle;

  /// No description provided for @remoteSyncOffBody.
  ///
  /// In en, this message translates to:
  /// **'By default, Illam only syncs on home Wi-Fi. Turn on Remote sync to connect your own free Firebase project so family phones can sync over mobile data — with zero developer servers and end-to-end encryption.'**
  String get remoteSyncOffBody;

  /// No description provided for @remoteSyncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase relay'**
  String get remoteSyncStatusTitle;

  /// No description provided for @remoteSyncStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected · {projectId}'**
  String remoteSyncStatusConnected(Object projectId);

  /// No description provided for @remoteSyncStatusLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {ago}'**
  String remoteSyncStatusLastSynced(Object ago);

  /// No description provided for @remoteSyncStatusNever.
  ///
  /// In en, this message translates to:
  /// **'Enabled · not synced yet'**
  String get remoteSyncStatusNever;

  /// No description provided for @remoteSyncStatusNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Enabled · add Firebase details below'**
  String get remoteSyncStatusNeedsSetup;

  /// No description provided for @remoteSyncStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Off · home Wi-Fi only'**
  String get remoteSyncStatusOff;

  /// No description provided for @remoteSyncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Attention · {projectId}'**
  String remoteSyncStatusError(Object projectId);

  /// No description provided for @remoteSyncSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get remoteSyncSyncNow;

  /// No description provided for @remoteSyncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get remoteSyncSyncing;

  /// No description provided for @remoteSyncSyncedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remote sync updated (1 item)} other{Remote sync updated ({count} items)}}'**
  String remoteSyncSyncedCount(int count);

  /// No description provided for @remoteSyncSyncedNone.
  ///
  /// In en, this message translates to:
  /// **'Remote relay already up to date'**
  String get remoteSyncSyncedNone;

  /// No description provided for @remoteSyncShareFamily.
  ///
  /// In en, this message translates to:
  /// **'Share with family'**
  String get remoteSyncShareFamily;

  /// No description provided for @remoteSyncGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to set up your Firebase project'**
  String get remoteSyncGuideTitle;

  /// No description provided for @remoteSyncGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Create a free Firebase project at console.firebase.google.com and add a Web app (</>) to view your Project ID and Web API key.'**
  String get remoteSyncGuideStep1;

  /// No description provided for @remoteSyncGuideStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Under Authentication → Sign-in method, turn on Anonymous sign-in.'**
  String get remoteSyncGuideStep2;

  /// No description provided for @remoteSyncGuideStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Under Firestore Database, create a database, open Rules, and paste Illam’s security rules.'**
  String get remoteSyncGuideStep3;

  /// No description provided for @remoteSyncGuideStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Enter your config below, test the connection, and share the QR code with family phones.'**
  String get remoteSyncGuideStep4;

  /// No description provided for @remoteSyncCopyRules.
  ///
  /// In en, this message translates to:
  /// **'Copy security rules'**
  String get remoteSyncCopyRules;

  /// No description provided for @remoteSyncRulesCopied.
  ///
  /// In en, this message translates to:
  /// **'Security rules copied'**
  String get remoteSyncRulesCopied;

  /// No description provided for @remoteSyncShowRules.
  ///
  /// In en, this message translates to:
  /// **'View security rules'**
  String get remoteSyncShowRules;

  /// No description provided for @remoteSyncHideRules.
  ///
  /// In en, this message translates to:
  /// **'Hide security rules'**
  String get remoteSyncHideRules;

  /// No description provided for @remoteSyncConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase configuration'**
  String get remoteSyncConfigTitle;

  /// No description provided for @remoteSyncConfigLead.
  ///
  /// In en, this message translates to:
  /// **'Enter your project details, or paste the firebaseConfig snippet from Firebase Console.'**
  String get remoteSyncConfigLead;

  /// No description provided for @remoteSyncPasteConfig.
  ///
  /// In en, this message translates to:
  /// **'Paste config'**
  String get remoteSyncPasteConfig;

  /// No description provided for @remoteSyncScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get remoteSyncScanQr;

  /// No description provided for @remoteSyncPasteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Firebase config'**
  String get remoteSyncPasteSheetTitle;

  /// No description provided for @remoteSyncPasteSheetLead.
  ///
  /// In en, this message translates to:
  /// **'Paste a firebaseConfig JS/JSON snippet or an Illam remote sync link.'**
  String get remoteSyncPasteSheetLead;

  /// No description provided for @remoteSyncPasteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Config snippet or link'**
  String get remoteSyncPasteFieldLabel;

  /// No description provided for @remoteSyncApplyConfig.
  ///
  /// In en, this message translates to:
  /// **'Fill fields'**
  String get remoteSyncApplyConfig;

  /// No description provided for @remoteSyncConfigApplied.
  ///
  /// In en, this message translates to:
  /// **'Firebase fields filled'**
  String get remoteSyncConfigApplied;

  /// No description provided for @remoteSyncConfigNotFound.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find projectId and apiKey in pasted text'**
  String get remoteSyncConfigNotFound;

  /// No description provided for @remoteSyncProjectIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get remoteSyncProjectIdLabel;

  /// No description provided for @remoteSyncProjectIdHint.
  ///
  /// In en, this message translates to:
  /// **'my-family-illam'**
  String get remoteSyncProjectIdHint;

  /// No description provided for @remoteSyncApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Web API key'**
  String get remoteSyncApiKeyLabel;

  /// No description provided for @remoteSyncApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'AIzaSy...'**
  String get remoteSyncApiKeyHint;

  /// No description provided for @remoteSyncShowApiKey.
  ///
  /// In en, this message translates to:
  /// **'Show API key'**
  String get remoteSyncShowApiKey;

  /// No description provided for @remoteSyncHideApiKey.
  ///
  /// In en, this message translates to:
  /// **'Hide API key'**
  String get remoteSyncHideApiKey;

  /// No description provided for @remoteSyncDatabaseIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Database ID (optional)'**
  String get remoteSyncDatabaseIdLabel;

  /// No description provided for @remoteSyncDatabaseIdHint.
  ///
  /// In en, this message translates to:
  /// **'(default)'**
  String get remoteSyncDatabaseIdHint;

  /// No description provided for @remoteSyncErrProjectEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your Firebase Project ID'**
  String get remoteSyncErrProjectEmpty;

  /// No description provided for @remoteSyncErrProjectInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers, and hyphens'**
  String get remoteSyncErrProjectInvalid;

  /// No description provided for @remoteSyncErrKeyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your Firebase Web API key'**
  String get remoteSyncErrKeyEmpty;

  /// No description provided for @remoteSyncErrKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the Web API key format'**
  String get remoteSyncErrKeyInvalid;

  /// No description provided for @remoteSyncErrDbInvalid.
  ///
  /// In en, this message translates to:
  /// **'Leave as (default) or use lowercase letters, numbers, and hyphens'**
  String get remoteSyncErrDbInvalid;

  /// No description provided for @remoteSyncTestBtn.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get remoteSyncTestBtn;

  /// No description provided for @remoteSyncTestingBtn.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get remoteSyncTestingBtn;

  /// No description provided for @remoteSyncTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connection OK — Anonymous Auth and Firestore rules verified.'**
  String get remoteSyncTestOk;

  /// No description provided for @remoteSyncSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save & connect'**
  String get remoteSyncSaveBtn;

  /// No description provided for @remoteSyncSavingBtn.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get remoteSyncSavingBtn;

  /// No description provided for @remoteSyncSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Firebase configuration saved'**
  String get remoteSyncSavedSnack;

  /// No description provided for @remoteSyncRemoveBtn.
  ///
  /// In en, this message translates to:
  /// **'Remove Firebase config'**
  String get remoteSyncRemoveBtn;

  /// No description provided for @remoteSyncRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Firebase config?'**
  String get remoteSyncRemoveTitle;

  /// No description provided for @remoteSyncRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'This phone will stop using remote sync and clear stored Firebase credentials. Local home data stays untouched.'**
  String get remoteSyncRemoveBody;

  /// No description provided for @remoteSyncRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remoteSyncRemoveConfirm;

  /// No description provided for @remoteSyncShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Firebase setup'**
  String get remoteSyncShareTitle;

  /// No description provided for @remoteSyncShareLead.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR on another family phone after enabling Remote sync there.'**
  String get remoteSyncShareLead;

  /// No description provided for @remoteSyncShareWarning.
  ///
  /// In en, this message translates to:
  /// **'Share only with family members of this home — anyone with your Project ID and API key can access your Firebase project’s anonymous relay.'**
  String get remoteSyncShareWarning;

  /// No description provided for @remoteSyncCopyShareLink.
  ///
  /// In en, this message translates to:
  /// **'Copy setup link'**
  String get remoteSyncCopyShareLink;

  /// No description provided for @remoteSyncShareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Setup link copied'**
  String get remoteSyncShareLinkCopied;

  /// No description provided for @remoteSyncScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan remote sync QR'**
  String get remoteSyncScanTitle;

  /// No description provided for @remoteSyncScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point at the Remote sync QR code from your family member’s phone.'**
  String get remoteSyncScanHint;

  /// No description provided for @remoteSyncScanInvalid.
  ///
  /// In en, this message translates to:
  /// **'That QR code isn’t an Illam remote sync config'**
  String get remoteSyncScanInvalid;

  /// No description provided for @remoteSyncErrInvalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Firebase rejected the Web API key.'**
  String get remoteSyncErrInvalidApiKey;

  /// No description provided for @remoteSyncErrAnonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on Anonymous sign-in under Firebase Authentication → Sign-in method.'**
  String get remoteSyncErrAnonDisabled;

  /// No description provided for @remoteSyncErrPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firestore denied access. Paste Illam’s security rules in Firestore → Rules.'**
  String get remoteSyncErrPermissionDenied;

  /// No description provided for @remoteSyncErrDatabaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Firestore database or Project ID not found.'**
  String get remoteSyncErrDatabaseNotFound;

  /// No description provided for @remoteSyncErrQuota.
  ///
  /// In en, this message translates to:
  /// **'Firebase daily Spark quota exceeded. Try again later.'**
  String get remoteSyncErrQuota;

  /// No description provided for @remoteSyncErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Firebase. Check your internet connection.'**
  String get remoteSyncErrNetwork;

  /// No description provided for @remoteSyncErrOther.
  ///
  /// In en, this message translates to:
  /// **'Firebase sync failed — check your configuration and rules.'**
  String get remoteSyncErrOther;

  /// No description provided for @remoteSyncCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote sync'**
  String get remoteSyncCardTitle;

  /// No description provided for @remoteSyncProfileSubOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remoteSyncProfileSubOff;

  /// No description provided for @remoteSyncProfileSubNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Needs setup'**
  String get remoteSyncProfileSubNeedsSetup;

  /// No description provided for @remoteSyncProfileSubConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected · {projectId}'**
  String remoteSyncProfileSubConnected(Object projectId);

  /// No description provided for @remoteSyncNoHomeKey.
  ///
  /// In en, this message translates to:
  /// **'Home encryption key not ready yet'**
  String get remoteSyncNoHomeKey;

  /// No description provided for @remoteSyncCombinedSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced phones and remote relay'**
  String get remoteSyncCombinedSynced;

  /// No description provided for @gmailImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Gmail invoice import'**
  String get gmailImportTitle;

  /// No description provided for @gmailImportExperimental.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get gmailImportExperimental;

  /// No description provided for @gmailImportCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Gmail invoice import'**
  String get gmailImportCardTitle;

  /// No description provided for @gmailImportToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Gmail invoice import'**
  String get gmailImportToggleTitle;

  /// No description provided for @gmailImportToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Zepto, Blinkit, Amazon, and Flipkart emails and PDF invoices into Drafts before adding to your ledger.'**
  String get gmailImportToggleSubtitle;

  /// No description provided for @gmailImportOffHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on Gmail invoice import to connect your Google Desktop App OAuth client, scan store order emails, and review draft expenses.'**
  String get gmailImportOffHint;

  /// No description provided for @gmailImportProfileSubOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get gmailImportProfileSubOff;

  /// No description provided for @gmailImportProfileSubNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Needs setup'**
  String get gmailImportProfileSubNeedsSetup;

  /// No description provided for @gmailImportProfileSubConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected · {email}'**
  String gmailImportProfileSubConnected(Object email);

  /// No description provided for @gmailImportProfileSubDrafts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft to review} other{{count} drafts to review}}'**
  String gmailImportProfileSubDrafts(num count);

  /// No description provided for @gmailImportStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Gmail connection'**
  String get gmailImportStatusTitle;

  /// No description provided for @gmailImportStatusNeedsOAuth.
  ///
  /// In en, this message translates to:
  /// **'Add your Desktop OAuth client ID and secret below.'**
  String get gmailImportStatusNeedsOAuth;

  /// No description provided for @gmailImportStatusReadyToConnect.
  ///
  /// In en, this message translates to:
  /// **'OAuth credentials saved — connect your Gmail account.'**
  String get gmailImportStatusReadyToConnect;

  /// No description provided for @gmailImportStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email}'**
  String gmailImportStatusConnected(Object email);

  /// No description provided for @gmailImportStatusConnectedFallback.
  ///
  /// In en, this message translates to:
  /// **'Connected to Gmail'**
  String get gmailImportStatusConnectedFallback;

  /// No description provided for @gmailImportLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last scanned {ago}'**
  String gmailImportLastScan(Object ago);

  /// No description provided for @gmailImportNeverScanned.
  ///
  /// In en, this message translates to:
  /// **'Never scanned yet'**
  String get gmailImportNeverScanned;

  /// No description provided for @gmailImportConnectBtn.
  ///
  /// In en, this message translates to:
  /// **'Connect Gmail'**
  String get gmailImportConnectBtn;

  /// No description provided for @gmailImportConnectingBtn.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Google sign-in…'**
  String get gmailImportConnectingBtn;

  /// No description provided for @gmailImportCancelAuthBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel sign-in'**
  String get gmailImportCancelAuthBtn;

  /// No description provided for @gmailImportScanNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Scan emails'**
  String get gmailImportScanNowBtn;

  /// No description provided for @gmailImportScanningBtn.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get gmailImportScanningBtn;

  /// No description provided for @gmailImportDisconnectBtn.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Gmail'**
  String get gmailImportDisconnectBtn;

  /// No description provided for @gmailImportDisconnectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Gmail account disconnected'**
  String get gmailImportDisconnectedSnack;

  /// No description provided for @gmailImportConnectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Connected to {email}'**
  String gmailImportConnectedSnack(Object email);

  /// No description provided for @gmailImportWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan window'**
  String get gmailImportWindowLabel;

  /// No description provided for @gmailImportWindowDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String gmailImportWindowDays(Object days);

  /// No description provided for @gmailImportScanSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Scanned emails — no new invoices found} =1{Added 1 new draft expense from Gmail} other{Added {count} new draft expenses from Gmail}}'**
  String gmailImportScanSummary(num count);

  /// No description provided for @gmailImportGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to set up your Google Desktop OAuth'**
  String get gmailImportGuideTitle;

  /// No description provided for @gmailImportGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open console.cloud.google.com, create a project, and enable the Gmail API.'**
  String get gmailImportGuideStep1;

  /// No description provided for @gmailImportGuideStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Under Google Auth platform → Audience, add your Gmail address as a Test user.'**
  String get gmailImportGuideStep2;

  /// No description provided for @gmailImportGuideStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Under Clients → Create client → choose Desktop app (required for local loopback sign-in).'**
  String get gmailImportGuideStep3;

  /// No description provided for @gmailImportGuideStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Paste the downloaded JSON (or client ID & secret) below, tap Connect Gmail, and review Drafts before accounting.'**
  String get gmailImportGuideStep4;

  /// No description provided for @gmailImportOAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Desktop OAuth'**
  String get gmailImportOAuthTitle;

  /// No description provided for @gmailImportOAuthLead.
  ///
  /// In en, this message translates to:
  /// **'Your credentials and Gmail tokens stay encrypted on this phone.'**
  String get gmailImportOAuthLead;

  /// No description provided for @gmailImportPasteJsonBtn.
  ///
  /// In en, this message translates to:
  /// **'Paste OAuth JSON'**
  String get gmailImportPasteJsonBtn;

  /// No description provided for @gmailImportPasteJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste OAuth client JSON'**
  String get gmailImportPasteJsonTitle;

  /// No description provided for @gmailImportPasteJsonLead.
  ///
  /// In en, this message translates to:
  /// **'Paste the downloaded Desktop app client JSON from Google Cloud Console.'**
  String get gmailImportPasteJsonLead;

  /// No description provided for @gmailImportPasteJsonField.
  ///
  /// In en, this message translates to:
  /// **'Desktop app JSON'**
  String get gmailImportPasteJsonField;

  /// No description provided for @gmailImportApplyJsonBtn.
  ///
  /// In en, this message translates to:
  /// **'Fill fields'**
  String get gmailImportApplyJsonBtn;

  /// No description provided for @gmailImportJsonApplied.
  ///
  /// In en, this message translates to:
  /// **'OAuth credentials filled'**
  String get gmailImportJsonApplied;

  /// No description provided for @gmailImportClientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get gmailImportClientIdLabel;

  /// No description provided for @gmailImportClientIdHint.
  ///
  /// In en, this message translates to:
  /// **'123456-abc.apps.googleusercontent.com'**
  String get gmailImportClientIdHint;

  /// No description provided for @gmailImportClientSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get gmailImportClientSecretLabel;

  /// No description provided for @gmailImportClientSecretHint.
  ///
  /// In en, this message translates to:
  /// **'GOCSPX-...'**
  String get gmailImportClientSecretHint;

  /// No description provided for @gmailImportShowSecret.
  ///
  /// In en, this message translates to:
  /// **'Show client secret'**
  String get gmailImportShowSecret;

  /// No description provided for @gmailImportHideSecret.
  ///
  /// In en, this message translates to:
  /// **'Hide client secret'**
  String get gmailImportHideSecret;

  /// No description provided for @gmailImportSaveOAuthBtn.
  ///
  /// In en, this message translates to:
  /// **'Save credentials'**
  String get gmailImportSaveOAuthBtn;

  /// No description provided for @gmailImportOAuthSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'OAuth credentials saved'**
  String get gmailImportOAuthSavedSnack;

  /// No description provided for @gmailImportRemoveConfigBtn.
  ///
  /// In en, this message translates to:
  /// **'Clear OAuth & drafts'**
  String get gmailImportRemoveConfigBtn;

  /// No description provided for @gmailImportRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Gmail import data?'**
  String get gmailImportRemoveTitle;

  /// No description provided for @gmailImportRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Deletes saved OAuth credentials, tokens, and pending drafts on this phone. Already accounted expenses stay in Money.'**
  String get gmailImportRemoveBody;

  /// No description provided for @gmailImportRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get gmailImportRemoveConfirm;

  /// No description provided for @gmailImportPasteInvoiceBtn.
  ///
  /// In en, this message translates to:
  /// **'Paste invoice text'**
  String get gmailImportPasteInvoiceBtn;

  /// No description provided for @gmailImportPasteInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Parse pasted invoice'**
  String get gmailImportPasteInvoiceTitle;

  /// No description provided for @gmailImportPasteInvoiceLead.
  ///
  /// In en, this message translates to:
  /// **'Test parsing offline or import an order by pasting an email or PDF invoice text from Zepto, Blinkit, Amazon, or Flipkart.'**
  String get gmailImportPasteInvoiceLead;

  /// No description provided for @gmailImportPasteInvoiceField.
  ///
  /// In en, this message translates to:
  /// **'Email or invoice text'**
  String get gmailImportPasteInvoiceField;

  /// No description provided for @gmailImportParseToDraftBtn.
  ///
  /// In en, this message translates to:
  /// **'Create draft'**
  String get gmailImportParseToDraftBtn;

  /// No description provided for @gmailImportPasteNotMatched.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find a Zepto, Blinkit, Amazon, or Flipkart total in that text.'**
  String get gmailImportPasteNotMatched;

  /// No description provided for @gmailImportPasteAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Created draft expense ({channel})'**
  String gmailImportPasteAddedSnack(Object channel);

  /// No description provided for @gmailImportDraftsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft expenses ({count})'**
  String gmailImportDraftsSectionTitle(Object count);

  /// No description provided for @gmailImportDraftsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending drafts. Scan your Gmail after shopping on Zepto, Blinkit, Amazon, or Flipkart.'**
  String get gmailImportDraftsEmpty;

  /// No description provided for @gmailImportDraftBadge.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get gmailImportDraftBadge;

  /// No description provided for @gmailImportDraftsMoneyNote.
  ///
  /// In en, this message translates to:
  /// **'Not counted in spends or budgets until you review and tap Account it.'**
  String get gmailImportDraftsMoneyNote;

  /// No description provided for @gmailImportReviewAllAction.
  ///
  /// In en, this message translates to:
  /// **'Open importer'**
  String get gmailImportReviewAllAction;

  /// No description provided for @gmailImportAccountItBtn.
  ///
  /// In en, this message translates to:
  /// **'Account it'**
  String get gmailImportAccountItBtn;

  /// No description provided for @gmailImportAccountingBtn.
  ///
  /// In en, this message translates to:
  /// **'Accounting…'**
  String get gmailImportAccountingBtn;

  /// No description provided for @gmailImportDiscardBtn.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get gmailImportDiscardBtn;

  /// No description provided for @gmailImportEditDraftBtn.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get gmailImportEditDraftBtn;

  /// No description provided for @gmailImportDraftItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Order total only} =1{1 item extracted} other{{count} items extracted}}'**
  String gmailImportDraftItemsCount(num count);

  /// No description provided for @gmailImportReviewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'{channel} draft'**
  String gmailImportReviewSheetTitle(Object channel);

  /// No description provided for @gmailImportSplitByItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Log each item separately'**
  String get gmailImportSplitByItemLabel;

  /// No description provided for @gmailImportSplitByItemSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off to add one combined expense for {channel}.'**
  String gmailImportSplitByItemSub(Object channel);

  /// No description provided for @gmailImportFeesDiscountInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery/fees {fees} · Discount {discount} (reconciled to paid total)'**
  String gmailImportFeesDiscountInfo(Object fees, Object discount);

  /// No description provided for @gmailImportOrderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid total'**
  String get gmailImportOrderTotalLabel;

  /// No description provided for @gmailImportSelectedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'To account ({count} {count, plural, =1{entry} other{entries}})'**
  String gmailImportSelectedTotalLabel(num count);

  /// No description provided for @gmailImportAccountedSnack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Accounted 1 expense ({total})} other{Accounted {count} expenses ({total})}}'**
  String gmailImportAccountedSnack(num count, Object total);

  /// No description provided for @gmailImportNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one positive item or switch to combined order total.'**
  String get gmailImportNothingSelected;

  /// No description provided for @gmailImportItemAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount for every included item.'**
  String get gmailImportItemAmountInvalid;

  /// No description provided for @gmailImportDuplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'A similar spend already exists around {date}. You can still account it or discard this draft.'**
  String gmailImportDuplicateWarning(Object date);

  /// No description provided for @gmailImportOrderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order {id}'**
  String gmailImportOrderIdLabel(Object id);

  /// No description provided for @gmailImportErrOAuthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste Google Desktop App OAuth JSON or enter both fields.'**
  String get gmailImportErrOAuthEmpty;

  /// No description provided for @gmailImportErrOAuthMalformed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t read Client ID and Secret from that input.'**
  String get gmailImportErrOAuthMalformed;

  /// No description provided for @gmailImportErrWebClient.
  ///
  /// In en, this message translates to:
  /// **'That’s a Web OAuth client. Create a Desktop app client in Google Cloud Console.'**
  String get gmailImportErrWebClient;

  /// No description provided for @gmailImportErrInvalidClientId.
  ///
  /// In en, this message translates to:
  /// **'Check the Client ID format (must end with .apps.googleusercontent.com).'**
  String get gmailImportErrInvalidClientId;

  /// No description provided for @gmailImportErrMissingSecret.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google OAuth Client secret.'**
  String get gmailImportErrMissingSecret;

  /// No description provided for @gmailImportErrUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Gmail session expired or access was revoked. Reconnect Gmail.'**
  String get gmailImportErrUnauthorized;

  /// No description provided for @gmailImportErrForbidden.
  ///
  /// In en, this message translates to:
  /// **'Gmail denied access — make sure Gmail API is enabled and your address is added as a Test user.'**
  String get gmailImportErrForbidden;

  /// No description provided for @gmailImportErrRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Gmail rate limit reached. Try again in a moment.'**
  String get gmailImportErrRateLimited;

  /// No description provided for @gmailImportErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Google. Check your internet connection.'**
  String get gmailImportErrNetwork;

  /// No description provided for @gmailImportErrAuthUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Gmail browser sign-in requires Android or desktop; paste invoice text to test here.'**
  String get gmailImportErrAuthUnsupported;

  /// No description provided for @gmailImportErrAuthBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser for Google sign-in.'**
  String get gmailImportErrAuthBrowser;

  /// No description provided for @gmailImportErrAuthDenied.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled or denied.'**
  String get gmailImportErrAuthDenied;

  /// No description provided for @gmailImportErrAuthTimeout.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in timed out. Tap Connect Gmail to try again.'**
  String get gmailImportErrAuthTimeout;

  /// No description provided for @gmailImportErrAuthOther.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in did not complete — check your Desktop OAuth client settings.'**
  String get gmailImportErrAuthOther;

  /// No description provided for @smsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS spend import'**
  String get smsImportTitle;

  /// No description provided for @smsImportExperimental.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get smsImportExperimental;

  /// No description provided for @smsImportCardTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS spend import'**
  String get smsImportCardTitle;

  /// No description provided for @smsImportTagLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get smsImportTagLabel;

  /// No description provided for @smsImportToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS spend import'**
  String get smsImportToggleTitle;

  /// No description provided for @smsImportToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect bank, UPI, and card payment SMS locally into Drafts before adding to your ledger.'**
  String get smsImportToggleSubtitle;

  /// No description provided for @smsImportOffHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on SMS spend import to scan transaction alerts on-device or auto-capture payment SMS in the background. Nothing enters Money until you tap Account it.'**
  String get smsImportOffHint;

  /// No description provided for @smsImportProfileSubOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get smsImportProfileSubOff;

  /// No description provided for @smsImportProfileSubDrafts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft to review} other{{count} drafts to review}}'**
  String smsImportProfileSubDrafts(num count);

  /// No description provided for @smsImportProfileSubAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture on'**
  String get smsImportProfileSubAuto;

  /// No description provided for @smsImportProfileSubManual.
  ///
  /// In en, this message translates to:
  /// **'Manual scan'**
  String get smsImportProfileSubManual;

  /// No description provided for @smsImportProfileSubPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission needed'**
  String get smsImportProfileSubPermission;

  /// No description provided for @smsImportStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS access'**
  String get smsImportStatusTitle;

  /// No description provided for @smsImportStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'SMS permission granted — alerts stay on this phone.'**
  String get smsImportStatusGranted;

  /// No description provided for @smsImportStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Inbox read granted — grant receive permission for background capture.'**
  String get smsImportStatusPartial;

  /// No description provided for @smsImportStatusNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow Illam to read transaction SMS alerts on this phone.'**
  String get smsImportStatusNeeded;

  /// No description provided for @smsImportStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'Android blocked SMS access. On sideloaded builds, open App info → ⋮ → Allow restricted settings, then enable SMS.'**
  String get smsImportStatusRestricted;

  /// No description provided for @smsImportStatusUnsupported.
  ///
  /// In en, this message translates to:
  /// **'SMS reading is available on Android only; use Paste SMS text to test here.'**
  String get smsImportStatusUnsupported;

  /// No description provided for @smsImportGrantBtn.
  ///
  /// In en, this message translates to:
  /// **'Grant SMS permission'**
  String get smsImportGrantBtn;

  /// No description provided for @smsImportOpenSettingsBtn.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get smsImportOpenSettingsBtn;

  /// No description provided for @smsImportAutoCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture incoming SMS'**
  String get smsImportAutoCaptureTitle;

  /// No description provided for @smsImportAutoCaptureSub.
  ///
  /// In en, this message translates to:
  /// **'Stage new bank, UPI, and card payment alerts into Drafts automatically.'**
  String get smsImportAutoCaptureSub;

  /// No description provided for @smsImportWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan window'**
  String get smsImportWindowLabel;

  /// No description provided for @smsImportWindowDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String smsImportWindowDays(Object days);

  /// No description provided for @smsImportLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last scanned {ago}'**
  String smsImportLastScan(Object ago);

  /// No description provided for @smsImportNeverScanned.
  ///
  /// In en, this message translates to:
  /// **'Never scanned yet'**
  String get smsImportNeverScanned;

  /// No description provided for @smsImportScanNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Scan SMS'**
  String get smsImportScanNowBtn;

  /// No description provided for @smsImportScanningBtn.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get smsImportScanningBtn;

  /// No description provided for @smsImportScanSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Scanned SMS — no new payment alerts found} =1{Added 1 new draft expense from SMS} other{Added {count} new draft expenses from SMS}}'**
  String smsImportScanSummary(num count);

  /// No description provided for @smsImportPasteBtn.
  ///
  /// In en, this message translates to:
  /// **'Paste SMS text'**
  String get smsImportPasteBtn;

  /// No description provided for @smsImportPasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Parse pasted bank SMS'**
  String get smsImportPasteTitle;

  /// No description provided for @smsImportPasteLead.
  ///
  /// In en, this message translates to:
  /// **'Paste any Indian bank, UPI, or card debit SMS alert to test extraction into Drafts.'**
  String get smsImportPasteLead;

  /// No description provided for @smsImportPasteField.
  ///
  /// In en, this message translates to:
  /// **'Transaction SMS text'**
  String get smsImportPasteField;

  /// No description provided for @smsImportPasteNotMatched.
  ///
  /// In en, this message translates to:
  /// **'No completed debit/spend amount was found in that message (OTPs, credits, promos, and card bill payments are ignored).'**
  String get smsImportPasteNotMatched;

  /// No description provided for @smsImportPasteAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Created SMS draft ({merchant})'**
  String smsImportPasteAddedSnack(Object merchant);

  /// No description provided for @smsImportDraftsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending SMS drafts. Scan your inbox or enable auto-capture for new payment alerts.'**
  String get smsImportDraftsEmpty;

  /// No description provided for @smsImportClearBtn.
  ///
  /// In en, this message translates to:
  /// **'Clear SMS import data'**
  String get smsImportClearBtn;

  /// No description provided for @smsImportClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear SMS import data?'**
  String get smsImportClearTitle;

  /// No description provided for @smsImportClearBody.
  ///
  /// In en, this message translates to:
  /// **'Deletes pending SMS drafts and processed history on this phone and turns off background SMS capture. Already accounted expenses stay in Money.'**
  String get smsImportClearBody;

  /// No description provided for @smsImportClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get smsImportClearConfirm;

  /// No description provided for @smsImportReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review SMS spend'**
  String get smsImportReviewTitle;

  /// No description provided for @smsImportAccountMeta.
  ///
  /// In en, this message translates to:
  /// **'{bank} · {when}'**
  String smsImportAccountMeta(Object bank, Object when);

  /// No description provided for @smsImportRawLabel.
  ///
  /// In en, this message translates to:
  /// **'Original SMS excerpt'**
  String get smsImportRawLabel;

  /// No description provided for @smsImportGmailOverlapWarning.
  ///
  /// In en, this message translates to:
  /// **'A pending Gmail draft ({channel}) matches this amount around {date}.'**
  String smsImportGmailOverlapWarning(Object channel, Object date);

  /// No description provided for @smsImportErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount up to ₹10,00,000.'**
  String get smsImportErrAmount;

  /// No description provided for @smsImportErrMerchant.
  ///
  /// In en, this message translates to:
  /// **'Enter who or where this payment went to.'**
  String get smsImportErrMerchant;

  /// No description provided for @smsImportAccountedSnack.
  ///
  /// In en, this message translates to:
  /// **'Accounted {merchant} ({amount})'**
  String smsImportAccountedSnack(Object merchant, Object amount);

  /// No description provided for @tripsTab.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsTab;

  /// No description provided for @tripsGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Generic checklist'**
  String get tripsGenericTitle;

  /// No description provided for @tripsGenericSub.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add items you pack for every trip} =1{1 reusable item · auto-copies to new trips} other{{count} reusable items · auto-copies to new trips}}'**
  String tripsGenericSub(int count);

  /// No description provided for @tripsGenericLead.
  ///
  /// In en, this message translates to:
  /// **'Items here can be copied automatically into every new trip so you never forget essentials.'**
  String get tripsGenericLead;

  /// No description provided for @tripsGenericAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a generic item (e.g. Chargers, ID cards)…'**
  String get tripsGenericAddHint;

  /// No description provided for @tripsGenericEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No generic items yet'**
  String get tripsGenericEmptyTitle;

  /// No description provided for @tripsGenericEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add essentials you check before every trip, or load a starter list.'**
  String get tripsGenericEmptyBody;

  /// No description provided for @tripsLoadStarter.
  ///
  /// In en, this message translates to:
  /// **'Load starter essentials'**
  String get tripsLoadStarter;

  /// No description provided for @tripsStarterLoaded.
  ///
  /// In en, this message translates to:
  /// **'Added {count} starter items'**
  String tripsStarterLoaded(int count);

  /// No description provided for @tripsStarterChargers.
  ///
  /// In en, this message translates to:
  /// **'Phone chargers & cables'**
  String get tripsStarterChargers;

  /// No description provided for @tripsStarterIds.
  ///
  /// In en, this message translates to:
  /// **'ID cards / tickets'**
  String get tripsStarterIds;

  /// No description provided for @tripsStarterMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines & first aid'**
  String get tripsStarterMedicines;

  /// No description provided for @tripsStarterClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes & toiletries'**
  String get tripsStarterClothes;

  /// No description provided for @tripsStarterWater.
  ///
  /// In en, this message translates to:
  /// **'Water bottles & snacks'**
  String get tripsStarterWater;

  /// No description provided for @tripsStarterKeys.
  ///
  /// In en, this message translates to:
  /// **'House keys'**
  String get tripsStarterKeys;

  /// No description provided for @tripsStarterGas.
  ///
  /// In en, this message translates to:
  /// **'Turn off gas stove'**
  String get tripsStarterGas;

  /// No description provided for @tripsStarterLocks.
  ///
  /// In en, this message translates to:
  /// **'Lock windows & doors'**
  String get tripsStarterLocks;

  /// No description provided for @tripsNewTrip.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get tripsNewTrip;

  /// No description provided for @tripsNewTripTitle.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get tripsNewTripTitle;

  /// No description provided for @tripsEditTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get tripsEditTripTitle;

  /// No description provided for @tripsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip name'**
  String get tripsNameLabel;

  /// No description provided for @tripsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Goa family trip'**
  String get tripsNameHint;

  /// No description provided for @tripsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a trip name.'**
  String get tripsNameRequired;

  /// No description provided for @tripsStartDate.
  ///
  /// In en, this message translates to:
  /// **'Trip date'**
  String get tripsStartDate;

  /// No description provided for @tripsEndDate.
  ///
  /// In en, this message translates to:
  /// **'Return date (optional)'**
  String get tripsEndDate;

  /// No description provided for @tripsAddEndDate.
  ///
  /// In en, this message translates to:
  /// **'Add return date'**
  String get tripsAddEndDate;

  /// No description provided for @tripsClearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear return date'**
  String get tripsClearEndDate;

  /// No description provided for @tripsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get tripsNoteLabel;

  /// No description provided for @tripsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Flight, train, or stay details'**
  String get tripsNoteHint;

  /// No description provided for @tripsIncludeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Include generic checklist ({count})'**
  String tripsIncludeGeneric(int count);

  /// No description provided for @tripsSaveTrip.
  ///
  /// In en, this message translates to:
  /// **'Add trip'**
  String get tripsSaveTrip;

  /// No description provided for @tripsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get tripsSaveChanges;

  /// No description provided for @tripsDeleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get tripsDeleteTrip;

  /// No description provided for @tripsAdded.
  ///
  /// In en, this message translates to:
  /// **'Trip added'**
  String get tripsAdded;

  /// No description provided for @tripsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Trip updated'**
  String get tripsUpdated;

  /// No description provided for @tripsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted'**
  String get tripsDeleted;

  /// No description provided for @tripsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips planned'**
  String get tripsEmptyTitle;

  /// No description provided for @tripsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip with its date and check off items before you leave.'**
  String get tripsEmptyBody;

  /// No description provided for @tripsPastHeader.
  ///
  /// In en, this message translates to:
  /// **'Past trips ({count})'**
  String tripsPastHeader(int count);

  /// No description provided for @tripsReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get tripsReady;

  /// No description provided for @tripsOngoing.
  ///
  /// In en, this message translates to:
  /// **'On trip'**
  String get tripsOngoing;

  /// No description provided for @tripsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tripsPast;

  /// No description provided for @tripsStartsToday.
  ///
  /// In en, this message translates to:
  /// **'Starts today'**
  String get tripsStartsToday;

  /// No description provided for @tripsStartsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tripsStartsTomorrow;

  /// No description provided for @tripsInDays.
  ///
  /// In en, this message translates to:
  /// **'In {n} days'**
  String tripsInDays(int n);

  /// No description provided for @tripsCheckedCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checked'**
  String tripsCheckedCount(int done, int total);

  /// No description provided for @tripsNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No checklist items yet'**
  String get tripsNoItemsYet;

  /// No description provided for @tripsAllReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'All set for your trip!'**
  String get tripsAllReadyTitle;

  /// No description provided for @tripsRemainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item left before you go} other{{count} items left before you go}}'**
  String tripsRemainingCount(int count);

  /// No description provided for @tripsAddItemHint.
  ///
  /// In en, this message translates to:
  /// **'Add item to check before leaving…'**
  String get tripsAddItemHint;

  /// No description provided for @tripsAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get tripsAddItem;

  /// No description provided for @tripsItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item added'**
  String get tripsItemAdded;

  /// No description provided for @tripsItemChecked.
  ///
  /// In en, this message translates to:
  /// **'Checked: {title}'**
  String tripsItemChecked(Object title);

  /// No description provided for @tripsItemUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Moved back: {title}'**
  String tripsItemUnchecked(Object title);

  /// No description provided for @tripsCheckedSection.
  ///
  /// In en, this message translates to:
  /// **'Checked ({count})'**
  String tripsCheckedSection(int count);

  /// No description provided for @tripsImportGeneric.
  ///
  /// In en, this message translates to:
  /// **'Import generic checklist'**
  String get tripsImportGeneric;

  /// No description provided for @tripsImportedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All generic items are already in this trip} =1{Added 1 generic item} other{Added {count} generic items}}'**
  String tripsImportedCount(int count);

  /// No description provided for @tripsResetChecks.
  ///
  /// In en, this message translates to:
  /// **'Reset all checks'**
  String get tripsResetChecks;

  /// No description provided for @tripsChecksReset.
  ///
  /// In en, this message translates to:
  /// **'Checklist reset'**
  String get tripsChecksReset;

  /// No description provided for @tripsCopyGenericBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy generic checklist ({count})'**
  String tripsCopyGenericBtn(int count);

  /// No description provided for @tripsEditItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get tripsEditItemTitle;

  /// No description provided for @tripsItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get tripsItemLabel;

  /// No description provided for @tripsSaveToGeneric.
  ///
  /// In en, this message translates to:
  /// **'Also add to generic checklist'**
  String get tripsSaveToGeneric;

  /// No description provided for @tripsSavedToGeneric.
  ///
  /// In en, this message translates to:
  /// **'Added to generic checklist'**
  String get tripsSavedToGeneric;

  /// No description provided for @tripsDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get tripsDeleteItem;

  /// No description provided for @tripsItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get tripsItemDeleted;

  /// No description provided for @tripsMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More trip actions'**
  String get tripsMoreActions;

  /// No description provided for @tripsEditTrip.
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get tripsEditTrip;

  /// No description provided for @tripsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trip not found'**
  String get tripsNotFound;

  /// No description provided for @tripsTodaySection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming trip'**
  String get tripsTodaySection;

  /// No description provided for @tripsTodayMeta.
  ///
  /// In en, this message translates to:
  /// **'{when} · {left, plural, =1{1 item left} other{{left} items left}}'**
  String tripsTodayMeta(Object when, int left);

  /// No description provided for @tripsOpenChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get tripsOpenChecklist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
