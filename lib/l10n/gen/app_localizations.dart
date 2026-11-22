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
  /// **'Nest Mojo : Flat'**
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
  /// **'Nest Mojo : Flat can’t secure data on this phone'**
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
  /// **'Someone at home already uses Nest Mojo : Flat. Scan their QR code or type their phrase.'**
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
  /// **'We copied the list and opened {store}. Shown when you return to Nest Mojo : Flat, so the list stays honest.'**
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
