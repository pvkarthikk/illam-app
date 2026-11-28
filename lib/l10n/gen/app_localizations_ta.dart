// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'இல்லம்';

  @override
  String get tabToday => 'இன்று';

  @override
  String get tabLists => 'பட்டியல்கள்';

  @override
  String get tabTasks => 'வேலைகள்';

  @override
  String get tabMeals => 'உணவு';

  @override
  String get tabMoney => 'பணம்';

  @override
  String get commonUndo => 'செயல்தவிர்';

  @override
  String get commonBack => 'பின்செல்';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonDecrease => 'குறை';

  @override
  String get commonIncrease => 'அதிகரி';

  @override
  String commonArrivesIn(Object phase) {
    return '$phase-இல் வரும்';
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
  String get dayToday => 'இன்று';

  @override
  String get dayTomorrow => 'நாளை';

  @override
  String get dayYesterday => 'நேற்று';

  @override
  String undoConflict(Object name) {
    return 'செயல்தவிர்க்க முடியவில்லை — $name இதை மாற்றியுள்ளார்.';
  }

  @override
  String get undoConflictYou =>
      'செயல்தவிர்க்க முடியவில்லை — நீங்கள் இதை மாற்றியுள்ளீர்கள்.';

  @override
  String get undoConflictSomeone =>
      'செயல்தவிர்க்க முடியவில்லை — வேறொருவர் இதை மாற்றியுள்ளார்.';

  @override
  String get debugDataLab => 'Data lab';

  @override
  String get debugDataLabSub => 'Notes, undo and the op log';

  @override
  String get labAddNote => 'குறிப்பு சேர்';

  @override
  String get labNoteHint => 'குறிப்பு தலைப்பு';

  @override
  String get labNoteAdded => 'குறிப்பு சேர்க்கப்பட்டது';

  @override
  String get labNoteRenamed => 'குறிப்பு பெயர் மாற்றப்பட்டது';

  @override
  String get labNoteDeleted => 'குறிப்பு நீக்கப்பட்டது';

  @override
  String get labPinned => 'பின் செய்யப்பட்டது';

  @override
  String get labUnpinned => 'பின் நீக்கப்பட்டது';

  @override
  String labTaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count தட்டுகள்',
      one: '1 தட்டு',
    );
    return '$_temp0';
  }

  @override
  String get labRecent => 'சமீபத்திய மாற்றங்கள்';

  @override
  String get labOpLog => 'செயல் பதிவு';

  @override
  String labOpsTotal(int count) {
    return '$count செயல்கள்';
  }

  @override
  String get labPin => 'பின் செய்';

  @override
  String get labEdit => 'திருத்து';

  @override
  String get labDelete => 'நீக்கு';

  @override
  String get commonSave => 'சேமி';

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
  String get commonCancel => 'ரத்து';

  @override
  String get errCantSecure =>
      'இந்தப் போனில் இல்லத்தால் தரவைப் பாதுகாக்க முடியவில்லை';

  @override
  String welcomeHeadline(Object em) {
    return 'உங்கள் வீட்டை நிர்வகிக்கலாம்,\n$em';
  }

  @override
  String get welcomeHeadlineEm => 'ஒன்றாக.';

  @override
  String get welcomeSub =>
      'வீட்டு உதவியாளர், மளிகை, வேலைகள், உணவு மற்றும் செலவுகள் — உங்கள் வீட்டில் உள்ள போன்களுக்கு இடையே பகிரப்படும்.';

  @override
  String get welcomeStartLabel => 'எப்படித் தொடங்க விரும்புகிறீர்கள்?';

  @override
  String get welcomeCreateTitle => 'வீடு உருவாக்கவும்';

  @override
  String get welcomeCreateBody =>
      'உங்கள் குடும்பத்திற்காக அமையுங்கள். நீங்கள் நிர்வாகியாக இருந்து மற்றவர்களை அழைப்பீர்கள்.';

  @override
  String get welcomeJoinTitle => 'வீட்டில் இணையவும்';

  @override
  String get welcomeJoinBody =>
      'வீட்டில் ஒருவர் ஏற்கனவே இல்லம் பயன்படுத்துகிறார். அவர்களின் QR குறியீட்டை ஸ்கேன் செய்யவும் அல்லது சொற்றொடரை உள்ளிடவும்.';

  @override
  String get welcomeHint =>
      'ஒருவர் மட்டுமே வீட்டை உருவாக்குவார் — மற்ற அனைவரும் அதில் இணைவார்கள்.';

  @override
  String get welcomeRestore => 'காப்புப்பிரதியிலிருந்து மீட்டெடு';

  @override
  String get welcomeFine =>
      'கணக்கு இல்லை, கிளவுட் இல்லை. உங்கள் வீட்டின் தகவல்கள் குடும்பப் போன்களிலேயே இருந்து நேரடியாக ஒத்திசைக்கப்படும்.';

  @override
  String get welcomeCreditLine1 => 'வீட்டில் உருவானது, வீடுகளுக்காக.';

  @override
  String welcomeCreditLine2(Object heart) {
    return '$heart உடன் நந்தினி சீனிவாசன் & கார்த்திக் வெங்கடேஷ்';
  }

  @override
  String get welcomeCreditA11y =>
      'வீட்டில் உருவானது, வீடுகளுக்காக, நந்தினி சீனிவாசன் மற்றும் கார்த்திக் வெங்கடேஷ் ஆகியோரின் அன்புடன்';

  @override
  String get createTitle => 'உங்கள் வீட்டை உருவாக்கவும்';

  @override
  String get createSub =>
      'நீங்கள் இதன் நிர்வாகி ஆவீர்கள். மற்றவர்கள் தங்கள் போனில் QR குறியீடு அல்லது சிறிய சொற்றொடர் மூலம் இணைவார்கள்.';

  @override
  String get createYourName => 'உங்கள் பெயர்';

  @override
  String get createYourNameHint => 'எ.கா. ஆனந்த் குமார்';

  @override
  String get createHomeName => 'வீட்டின் பெயர்';

  @override
  String createHomeNameHint(Object surname) {
    return 'எ.கா. $surname இல்லம்';
  }

  @override
  String createSuggestHome(Object surname) {
    return '$surname இல்லம்';
  }

  @override
  String get createSuggestFlat => 'எங்கள் ஃபிளாட்';

  @override
  String get createSuggestAmma => 'அம்மா வீடு';

  @override
  String get createSurnameFallback => 'எங்கள்';

  @override
  String get createSuggestionsLabel => 'பரிந்துரைகள்';

  @override
  String get createHomeIdLabel => 'வீட்டு ID';

  @override
  String get createHomeIdNote =>
      'இந்தப் போனில் உருவாக்கப்பட்டது · உங்கள் வீட்டிற்குத் தனித்துவமானது';

  @override
  String get createButton => 'வீடு உருவாக்கு';

  @override
  String get createErrName => 'உங்கள் பெயரைச் சேர்க்கவும்.';

  @override
  String get createErrHome => 'உங்கள் வீட்டிற்கு ஒரு பெயர் கொடுக்கவும்.';

  @override
  String get todayGreetingLate => 'இன்னும் விழிப்பில்';

  @override
  String get todayGreetingMorning => 'காலை வணக்கம்';

  @override
  String get todayGreetingAfternoon => 'மதிய வணக்கம்';

  @override
  String get todayGreetingEvening => 'மாலை வணக்கம்';

  @override
  String todayEyebrow(Object home, Object date) {
    return '$home · $date';
  }

  @override
  String todayHeadlineAllSet(Object em) {
    return 'இன்று வீட்டில் $em.';
  }

  @override
  String get todayAllSetEm => 'எல்லாம் தயார்';

  @override
  String get debugViewAsMember => 'Viewing as member';

  @override
  String get debugViewAsMemberSub => 'Hide admin-only controls (UI test only)';

  @override
  String debugIsAdmin(Object value) {
    return 'Admin on this phone: $value';
  }

  @override
  String get weekdayShortMon => 'திங்';

  @override
  String get weekdayShortTue => 'செவ்';

  @override
  String get weekdayShortWed => 'புத';

  @override
  String get weekdayShortThu => 'வியா';

  @override
  String get weekdayShortFri => 'வெள்';

  @override
  String get weekdayShortSat => 'சனி';

  @override
  String get weekdayShortSun => 'ஞாயி';

  @override
  String get weekdayLetters => 'தி,செ,பு,வி,வெ,ச,ஞா';

  @override
  String get staffDaily => 'தினசரி';

  @override
  String get staffTitle => 'உதவியாளர்கள்';

  @override
  String get staffNotFound =>
      'இந்த வீட்டு உதவியாளர் இப்போது உங்கள் வீட்டில் இல்லை.';

  @override
  String staffMarkedIn(Object name, Object time) {
    return '$name $time-க்கு வந்ததாகப் பதிவானது';
  }

  @override
  String staffMarkedOut(Object name, Object duration) {
    return '$name சென்றார் · இன்று $duration';
  }

  @override
  String staffExpected(Object times) {
    return 'எதிர்பார்ப்பு $times';
  }

  @override
  String staffInSince(Object time, Object duration) {
    return '$time முதல் உள்ளே · $duration';
  }

  @override
  String staffDoneToday(Object duration, Object time) {
    return 'இன்று $duration · $time-க்கு சென்றார்';
  }

  @override
  String get staffOnLeaveToday => 'இன்று விடுப்பு (தெரிவிக்கப்பட்டது)';

  @override
  String get staffOnPaidLeaveToday => 'இன்று சம்பளத்துடன் விடுப்பு';

  @override
  String get staffDayOff => 'விடுமுறை நாள்';

  @override
  String get staffMarkIn => 'வந்ததைப் பதி';

  @override
  String get staffMarkOut => 'சென்றதைப் பதி';

  @override
  String get staffVisitButton => 'வருகை';

  @override
  String get staffChange => 'மாற்று';

  @override
  String staffStartAnother(Object name) {
    return '$name-க்கு மற்றொரு வருகையைத் தொடங்கு';
  }

  @override
  String get staffHelpTitle => 'வீட்டு உதவியாளர்கள்';

  @override
  String get staffHelpSub => 'வருகை மற்றும் சம்பளத்திற்குப் பெயரைத் தட்டவும்';

  @override
  String get staffNoneYet =>
      'இன்னும் வீட்டு உதவியாளர் யாரும் சேர்க்கப்படவில்லை.';

  @override
  String get commonAdd => 'சேர்';

  @override
  String get commonFix => 'சரிசெய்';

  @override
  String staffAlertNotMarkedOut(Object name, Object day) {
    return '$day அன்று $name சென்றது பதிவாகவில்லை';
  }

  @override
  String staffAlertTwoOpen(Object name) {
    return '$name-க்கு 2 வெளியேறாத வருகைகள் உள்ளன';
  }

  @override
  String get staffAddTitle => 'வீட்டு உதவியாளர் சேர்';

  @override
  String get staffAddLead =>
      'அவர்களுக்கு இந்த செயலி தேவையில்லை. வீட்டில் உள்ள யாரும் அவர்களின் வரவையும் போக்கையும் பதியலாம்; சம்பளம் தானாகக் கணக்கிடப்படும்.';

  @override
  String get staffName => 'பெயர்';

  @override
  String get staffAddNameHint => 'எ.கா. கமலா';

  @override
  String get staffRole => 'பணி';

  @override
  String get staffRoleHouseHelp => 'வீட்டு உதவி';

  @override
  String get staffRoleCook => 'சமையல்காரர்';

  @override
  String get staffRoleDriver => 'ஓட்டுநர்';

  @override
  String get staffRoleNanny => 'குழந்தை பராமரிப்பு';

  @override
  String get staffRoleGardener => 'தோட்டக்காரர்';

  @override
  String get staffPay => 'சம்பளம்';

  @override
  String get staffPayPerHour => 'மணி நேரத்திற்கு';

  @override
  String get staffPayPerMonth => 'மாதத்திற்கு';

  @override
  String get staffAmount => 'தொகை (₹)';

  @override
  String get staffAmountHint => 'எ.கா. 6000';

  @override
  String get staffUsuallyAt => 'வழக்கமாக வரும் நேரம்';

  @override
  String get staffMobile => 'மொபைல் எண் (விருப்பம், WhatsApp-க்கு)';

  @override
  String get staffPhoneInvalid =>
      'எண்ணைச் சரிபார்க்கவும் — 6, 7, 8 அல்லது 9-இல் தொடங்கும் 10 இலக்கங்கள்.';

  @override
  String get staffAddInfo =>
      'இயல்பாக திங்–சனி வேலை நாட்கள்; நாட்கள் மற்றும் சம்பள விதிகளைப் பின்னர் அவர்களின் பக்கத்தில் மாற்றலாம்.';

  @override
  String staffAdded(Object name) {
    return '$name சேர்க்கப்பட்டார் · இன்று பக்கத்தில் வருகையைப் பதியலாம்';
  }

  @override
  String get staffIn => 'உள்ளே';

  @override
  String get staffOut => 'வெளியே';

  @override
  String get staffErrNoIn =>
      'உள்வரும் நேரத்தைச் சேர்க்கவும், அல்லது இந்தத் தாளை மூடவும்.';

  @override
  String get staffErrOutBeforeIn =>
      'வெளியேறும் நேரம் உள்வரும் நேரத்திற்குப் பிறகு இருக்க வேண்டும்.';

  @override
  String get staffErrTooLong =>
      'ஒரு வருகை 16 மணி நேரத்திற்கு மேல் இருக்க முடியாது.';

  @override
  String staffOverlap(Object time) {
    return 'இது $time நேரத்தில் உள்ள மற்றொரு வருகையுடன் மோதுகிறது.';
  }

  @override
  String get staffOnlyAdminsOlder =>
      'பழைய வருகைகளை நிர்வாகிகள் மட்டுமே மாற்ற முடியும்.';

  @override
  String staffVisitTitle(Object name, Object day) {
    return '$name · $day';
  }

  @override
  String get staffVisitLeadSome =>
      'தாமதமாகப் பதிந்தீர்களா அல்லது மறந்துவிட்டீர்களா? நேரத்தைச் சரிசெய்யவும் — சம்பளம் இதிலிருந்து மீண்டும் கணக்கிடப்படும்.';

  @override
  String get staffVisitLeadNone =>
      'வருகை எதுவும் பதிவாகவில்லை. ஒன்றைச் சேர்க்கவும், அல்லது வராததாகக் கணக்கிடாமல் இருக்கத் தெரிவித்த விடுப்பாகப் பதியவும்.';

  @override
  String get staffVisitLeadLeave =>
      'தெரிவித்த விடுப்பாகக் குறிக்கப்பட்டுள்ளது.';

  @override
  String get staffVisitLeadPaidLeave =>
      'சம்பளத்துடன் விடுப்பாகக் குறிக்கப்பட்டுள்ளது (சம்பளப் பிடித்தம் இல்லை).';

  @override
  String get staffNow => 'இப்போது';

  @override
  String get staffAddVisit => 'வருகை சேர்';

  @override
  String get staffEditVisit => 'வருகையைத் திருத்து';

  @override
  String get staffRemoveVisit => 'வருகையை நீக்கு';

  @override
  String staffSettledNotice(Object month) {
    return '$month கணக்கு முடிக்கப்பட்டுவிட்டது — மாற்றங்கள் செலுத்த வேண்டிய வித்தியாசமாகக் காட்டப்படும்';
  }

  @override
  String get staffVisitUpdated =>
      'வருகை புதுப்பிக்கப்பட்டது · சம்பளம் மறுகணக்கீடு செய்யப்பட்டது';

  @override
  String get staffVisitRemoved => 'வருகை நீக்கப்பட்டது';

  @override
  String get staffInformedLeave => 'தெரிவித்த விடுப்பு';

  @override
  String get staffPaidLeave => 'சம்பளத்துடன் விடுப்பு';

  @override
  String get staffUndoLeave => 'விடுப்பை நீக்கு';

  @override
  String staffLeaveMarked(Object day) {
    return '$day தெரிவித்த விடுப்பாகப் பதிவானது';
  }

  @override
  String staffPaidLeaveMarked(String day) {
    return '$day சம்பளத்துடன் விடுப்பாகக் குறிக்கப்பட்டது';
  }

  @override
  String get staffLeaveRemoved => 'விடுப்பு நீக்கப்பட்டது';

  @override
  String staffCall(Object name) {
    return '$name-க்கு அழைக்கவும்';
  }

  @override
  String staffWhatsApp(Object name) {
    return '$name-க்கு WhatsApp செய்யவும்';
  }

  @override
  String get staffEditDetails => 'விவரங்களைத் திருத்து';

  @override
  String staffRoleWindow(Object role, Object window) {
    return '$role · $window';
  }

  @override
  String staffPayHourlyLine(Object rate) {
    return '$rate/மணி';
  }

  @override
  String staffPayMonthlyLine(Object amount) {
    return '$amount/மாதம்';
  }

  @override
  String get staffFormerTag => 'முன்னாள் வீட்டு உதவியாளர்';

  @override
  String get staffUpi => 'UPI ID (விருப்பம்)';

  @override
  String get staffWorkDays => 'வேலை நாட்கள்';

  @override
  String get staffAddTime => 'இரண்டாவது நேரத்தைச் சேர்';

  @override
  String get staffDetailsSaved => 'விவரங்கள் சேமிக்கப்பட்டன';

  @override
  String staffMonthAttendance(Object month) {
    return '$month வருகைப்பதிவு';
  }

  @override
  String get staffPrevMonth => 'முந்தைய மாதம்';

  @override
  String get staffNextMonth => 'அடுத்த மாதம்';

  @override
  String staffCellWorked(Object day, Object duration) {
    return '$day: $duration வேலை';
  }

  @override
  String staffCellAbsent(Object day) {
    return '$day: வரவில்லை';
  }

  @override
  String staffCellLeave(Object day) {
    return '$day: தெரிவித்த விடுப்பு';
  }

  @override
  String staffCellPaidLeave(int day) {
    return '$day: சம்பளத்துடன் விடுப்பு';
  }

  @override
  String staffCellOff(Object day) {
    return '$day: விடுமுறை நாள்';
  }

  @override
  String staffCellUpcoming(Object day) {
    return '$day: வரவிருக்கும் நாள்';
  }

  @override
  String staffCellNotMarked(Object day) {
    return '$day: இன்னும் பதியப்படவில்லை';
  }

  @override
  String staffCellBeforeStart(Object day) {
    return '$day: தொடக்கத்திற்கு முன்';
  }

  @override
  String get staffLegendWorked => 'வேலை செய்தது (அடர்த்தி = அதிக நேரம்)';

  @override
  String get staffLegendAbsent => 'வராதது';

  @override
  String get staffLegendLeave => 'விடுப்பு';

  @override
  String get staffLegendPaidLeave => 'சம்பள விடுப்பு';

  @override
  String get staffStatPresent => 'வந்த நாட்கள்';

  @override
  String get staffStatAbsent => 'வராதது';

  @override
  String get staffStatHours => 'மணி நேரம்';

  @override
  String get staffVisitLog => 'வருகைப் பதிவு';

  @override
  String get staffVisitLogHint => 'நேரத்தை மாற்றத் தட்டவும்';

  @override
  String staffSalaryButton(Object month) {
    return '$month சம்பளம்';
  }

  @override
  String staffRemoveButton(Object name) {
    return '$name-ஐ வீட்டிலிருந்து நீக்கு';
  }

  @override
  String staffRemoveTitle(Object name) {
    return '$name-ஐ நீக்கவா?';
  }

  @override
  String get staffRemoveLead =>
      'அவர்கள் இன்று மற்றும் வருகைப்பதிவிலிருந்து மறைவார்கள். ஏற்கனவே கொடுத்த சம்பளம் பணம் பகுதியில் இருக்கும்.';

  @override
  String get commonRemove => 'நீக்கு';

  @override
  String staffRemoved(Object name) {
    return '$name நீக்கப்பட்டார்';
  }

  @override
  String get staffRestore => 'மீட்டெடு';

  @override
  String staffRestored(Object name) {
    return '$name மீட்டெடுக்கப்பட்டார்';
  }

  @override
  String staffFormerCount(int count) {
    return 'முன்னாள் உதவியாளர்கள் ($count)';
  }

  @override
  String salaryTitle(Object name) {
    return '$name-இன் சம்பளம்';
  }

  @override
  String salarySubtitleSoFar(Object month, Object day) {
    return '$month 1 – $day · இதுவரை';
  }

  @override
  String salarySubtitleProjected(Object month, Object day) {
    return '$month 1 – $day · கணிப்பு';
  }

  @override
  String salarySubtitlePast(Object month, Object day) {
    return '$month 1 – $day';
  }

  @override
  String get salaryFootnote =>
      'ஒவ்வொரு எண்ணும் வருகைப் பதிவிலிருந்து வருகிறது. அங்கு தவறான நேரத்தைச் சரிசெய்தால் இது உடனே புதுப்பிக்கப்படும்.';

  @override
  String salaryNotWorking(Object month) {
    return '$month மாதத்தில் பணியில் இல்லை';
  }

  @override
  String get salaryNoRules => 'இன்னும் சம்பள விதிகள் இல்லை';

  @override
  String get salaryNoRulesBody =>
      'செலுத்த வேண்டிய தொகையைப் பார்க்க மணி நேரக் கட்டணம் அல்லது மாதச் சம்பளத்தை அமைக்கவும்.';

  @override
  String get salarySetRules => 'சம்பள விதிகளை அமை';

  @override
  String get salaryEyebrowPayable => 'கொடுக்க வேண்டியது';

  @override
  String get salaryEyebrowPaid => 'கொடுக்கப்பட்டது';

  @override
  String salaryDaysLine(Object present, Object absent, Object leave) {
    return '$present நாட்கள் வருகை · $absent வராதது · $leave விடுப்பு';
  }

  @override
  String salaryCarryPreview(Object amount, Object month) {
    return 'செலுத்த வேண்டியது ₹0 · $amount $month-க்குத் தொடரும்';
  }

  @override
  String get salaryHoursWorked => 'வேலை செய்த மணி நேரம்';

  @override
  String salaryHoursDetail(
    Object billed,
    Object rate,
    Object visits,
    Object actual,
    Object rounding,
    Object minimum,
  ) {
    return 'கணக்கிடப்பட்டது $billed × $rate/மணி · $visits வருகைகள் · உண்மை $actual. ஒவ்வொரு வருகையும் $rounding என முழுமையாக்கப்பட்டது$minimum';
  }

  @override
  String salaryRoundMinutes(Object n) {
    return '$n நிமிடம்';
  }

  @override
  String get salaryRoundTheMinute => 'சரியான நிமிடம்';

  @override
  String salaryMinimumPart(Object hours) {
    return ', குறைந்தது $hours மணி';
  }

  @override
  String get salaryMonthlyLine => 'மாதச் சம்பளம்';

  @override
  String salaryMonthlyDetail(Object workDays, Object perDay) {
    return '$workDays வேலை நாட்கள் · $perDay/நாள்';
  }

  @override
  String get salaryLeavesLine => 'விடுப்புகள்';

  @override
  String salaryLeavesDetail(Object taken, Object paid, Object unpaid) {
    return '$taken எடுத்தது · $paid சம்பளத்துடன் · $unpaid சம்பளமின்றி';
  }

  @override
  String get salaryExtraDetail => 'கூடுதல் வேலை';

  @override
  String get salaryAdvanceLine => 'வாங்கிய முன்பணம்';

  @override
  String get salaryAdvanceDetail => 'இந்த மாதம் கழிக்கப்பட்டது';

  @override
  String get salaryDeductionDetail => 'கழிவு';

  @override
  String get salaryToPay => 'செலுத்த வேண்டியது';

  @override
  String salaryChipRate(Object rate) {
    return '$rate/மணி';
  }

  @override
  String salaryChipMonthly(Object amount) {
    return '$amount/மாதம்';
  }

  @override
  String salaryChipRound(Object n) {
    return '$n நிமி. முழுமை';
  }

  @override
  String get salaryChipExact => 'துல்லிய நிமிடங்கள்';

  @override
  String salaryChipPaidLeaves(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n சம்பள விடுப்புகள்',
      one: '1 சம்பள விடுப்பு',
    );
    return '$_temp0';
  }

  @override
  String get salaryEditRules => 'சம்பள விதிகளைத் திருத்து';

  @override
  String get salaryAdminsSetRules => 'நிர்வாகிகள் சம்பள விதிகளை அமைப்பார்கள்';

  @override
  String get salaryPrevMonth => 'முந்தைய மாதம்';

  @override
  String get salaryNextMonth => 'அடுத்த மாதம்';

  @override
  String salaryMarkPaidButton(Object amount) {
    return '$amount கொடுத்ததாகக் குறி';
  }

  @override
  String salaryCloseAtZero(Object month) {
    return '$month-ஐ ₹0-இல் முடி';
  }

  @override
  String salaryClosedSnack(Object month) {
    return '$month ₹0-இல் முடிக்கப்பட்டது';
  }

  @override
  String salaryCarryNote(Object month) {
    return '$month-இலிருந்து தொடர்ந்தது';
  }

  @override
  String salaryMemberNote(Object names) {
    return 'நிர்வாகிகள் மட்டுமே சம்பளம் செலுத்துவார்கள். $names-இடம் கேளுங்கள் — செலுத்தியதும் இங்கே காணலாம்.';
  }

  @override
  String get salaryYou => 'நீங்கள்';

  @override
  String salaryNamesOr(Object first, Object second) {
    return '$first அல்லது $second';
  }

  @override
  String salaryPaidTag(Object amount, Object date, Object method) {
    return '$date அன்று $amount கொடுக்கப்பட்டது · $method';
  }

  @override
  String salaryClosedTag(Object date) {
    return '$date அன்று ₹0-இல் முடிக்கப்பட்டது';
  }

  @override
  String get salaryUndoPayment => 'கட்டணம் செயல்தவிர்';

  @override
  String get salaryUndoTitle => 'கட்டணத்தைச் செயல்தவிர்க்கவா?';

  @override
  String salaryUndoLead(Object amount, Object month) {
    return '$amount சம்பளச் செலவு நீக்கப்பட்டு, $month மீண்டும் செலுத்தக் கூடியதாகும்.';
  }

  @override
  String get salaryUndoneSnack => 'கட்டணம் செயல்தவிர்க்கப்பட்டது';

  @override
  String get salaryMethodUpi => 'UPI';

  @override
  String get salaryMethodCash => 'ரொக்கம்';

  @override
  String get salaryMethodBank => 'வங்கி';

  @override
  String salaryDuplicateAlert(
    Object name,
    Object month,
    Object a,
    Object x,
    Object b,
    Object y,
  ) {
    return '$name-இன் $month சம்பளம் இருமுறை கொடுத்ததாகக் குறிக்கப்பட்டுள்ளது ($x மூலம் $a, $y மூலம் $b). முதலாவது வைக்கப்பட்டுள்ளது — இருமுறை செலுத்திவிடவில்லை என்பதைச் சரிபார்க்கவும்.';
  }

  @override
  String get salaryUndoSecond => 'இரண்டாவது கட்டணத்தைச் செயல்தவிர்';

  @override
  String salaryDifferenceAlert(Object x, Object y, Object z) {
    return 'மறுகணக்கீடு $x — $y-இல் முடிக்கப்பட்டது. வித்தியாசம் $z';
  }

  @override
  String salaryAddToMonth(Object month) {
    return '$month-இல் சேர்';
  }

  @override
  String salaryDifferenceNote(Object month) {
    return '$month-இலிருந்து வித்தியாசம்';
  }

  @override
  String salaryDifferenceSnack(Object month) {
    return 'வித்தியாசம் $month-இல் சேர்க்கப்பட்டது';
  }

  @override
  String salarySharePaySlip(Object name) {
    return '$name-உடன் சம்பளச் சீட்டைப் பகிர்';
  }

  @override
  String salaryRulesTitle(Object name) {
    return '$name-இன் சம்பள விதிகள்';
  }

  @override
  String get salaryRulesLead =>
      'ஒருமுறை ஒப்புக்கொண்டால், ஒவ்வொரு மாதமும் பொருந்தும். குழப்பம் இல்லாமல் இருக்க சம்பளச் சீட்டில் காட்டப்படும்.';

  @override
  String get salaryPayType => 'சம்பள வகை';

  @override
  String get salaryHourly => 'மணி நேரப்படி';

  @override
  String get salaryMonthly => 'மாதாந்திரம்';

  @override
  String get salaryRatePerHour => 'மணி நேரக் கட்டணம் (₹)';

  @override
  String get salaryRoundTo => 'ஒவ்வொரு வருகையையும் முழுமையாக்கு';

  @override
  String get salaryRoundExactMinute => 'சரியான நிமிடம்';

  @override
  String get salaryRound15 => '15 நிமிடம்';

  @override
  String get salaryRound30 => '30 நிமிடம்';

  @override
  String get salaryMinimum => 'ஒரு வருகைக்குக் குறைந்தபட்சம்';

  @override
  String get salaryMinNone => 'இல்லை';

  @override
  String get salaryMin1 => '1 மணி';

  @override
  String get salaryMin2 => '2 மணி';

  @override
  String get salaryMonthlyAmount => 'மாதச் சம்பளம் (₹)';

  @override
  String get salaryPaidLeaves => 'மாதத்திற்குச் சம்பள விடுப்புகள்';

  @override
  String get salaryWorkDays => 'வேலை நாட்கள்';

  @override
  String get salaryDayMon => 'திங்';

  @override
  String get salaryDayTue => 'செவ்';

  @override
  String get salaryDayWed => 'புத';

  @override
  String get salaryDayThu => 'வியா';

  @override
  String get salaryDayFri => 'வெள்';

  @override
  String get salaryDaySat => 'சனி';

  @override
  String get salaryDaySun => 'ஞாயி';

  @override
  String get salaryApplyFrom => 'பொருந்தும் காலம்';

  @override
  String get salaryThisMonth => 'இந்த மாதம்';

  @override
  String get salaryNextMonthChip => 'அடுத்த மாதம்';

  @override
  String get salarySaveRules => 'விதிகளைச் சேமி';

  @override
  String get salaryRulesSaved =>
      'சம்பள விதிகள் சேமிக்கப்பட்டன · சம்பளம் மறுகணக்கீடு செய்யப்பட்டது';

  @override
  String get salaryCheckAmount => 'தொகையைச் சரிபார்க்கவும்';

  @override
  String salaryAdjustmentsFor(Object month) {
    return '$month சரிசெய்தல்கள்';
  }

  @override
  String get salaryAddExtra => '+ கூடுதல் சேர்';

  @override
  String get salaryAddAdvance => '+ முன்பணம் சேர்';

  @override
  String get salaryAddDeduction => '+ கழிவு சேர்';

  @override
  String get salaryAdjNote => 'குறிப்பு';

  @override
  String get salaryAdjAmount => 'தொகை (₹)';

  @override
  String get salaryAdjSave => 'சேமி';

  @override
  String get salaryAdjRemove => 'நீக்கு';

  @override
  String get salaryAdjAdded =>
      'சரிசெய்தல் சேர்க்கப்பட்டது · சம்பளம் மறுகணக்கீடு செய்யப்பட்டது';

  @override
  String get salaryAdjRemoved => 'சரிசெய்தல் நீக்கப்பட்டது';

  @override
  String salaryAdjLocked(Object month) {
    return '$month கணக்கு முடிக்கப்பட்டது — சரிசெய்தல்கள் பூட்டப்பட்டுள்ளன.';
  }

  @override
  String get salaryKindExtra => 'கூடுதல்';

  @override
  String get salaryKindAdvance => 'முன்பணம்';

  @override
  String get salaryKindDeduction => 'பிடித்தம்';

  @override
  String salaryMarkPaidTitle(Object amount) {
    return '$amount வழங்கப்பட்டதாகக் குறிக்கவா?';
  }

  @override
  String get salaryPaidWith => 'செலுத்திய முறை';

  @override
  String get salaryMarkPaidConfirm => 'வழங்கியதாகக் குறி';

  @override
  String salaryPaidSnack(Object amount, Object name) {
    return '$name-க்கு $amount வழங்கப்பட்டது · செலவுகளில் சேர்க்கப்பட்டது';
  }

  @override
  String salaryExpenseMerchant(Object name, Object month) {
    return '$name — $month சம்பளம்';
  }

  @override
  String salarySlipHeader(Object month, Object name) {
    return '$month சம்பளம் — $name';
  }

  @override
  String salarySlipDaysHours(Object present, Object billed) {
    return 'நாட்கள்: $present · மணிநேரம்: $billed';
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
    return '− முன்பணம்: $amount';
  }

  @override
  String salarySlipDeduction(Object label, Object amount) {
    return '− $label: $amount';
  }

  @override
  String salarySlipSalary(Object amount) {
    return 'சம்பளம்: $amount';
  }

  @override
  String salarySlipLeaves(Object taken, Object paid) {
    return 'விடுப்பு: $taken ($paid சம்பளத்துடன்)';
  }

  @override
  String salarySlipTotal(Object amount) {
    return 'மொத்தம்: $amount';
  }

  @override
  String get salarySlipTitle => 'சம்பளச் சீட்டு';

  @override
  String get salarySlipLead =>
      'தெளிவான கணக்கு நம்பிக்கையை வளர்க்கும்; “எப்படிக் கணக்கிட்டீர்கள்?” என்ற கேள்விகளையும் தவிர்க்கும்.';

  @override
  String get salarySlipSend => 'WhatsApp-இல் அனுப்பு';

  @override
  String salaryRuleHourlyRounded(Object rate, Object n) {
    return '$rate/மணி · $n நிமி. முழுமையாக்கம்';
  }

  @override
  String salaryRuleHourlyExact(Object rate) {
    return '$rate/மணி · துல்லிய நிமிடங்கள்';
  }

  @override
  String salaryRuleMonthly(Object amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n சம்பள விடுப்புகள்',
      one: '1 சம்பள விடுப்பு',
    );
    return '$amount/மாதம் · $_temp0';
  }

  @override
  String salaryStaffButton(Object month, Object amount) {
    return '$month சம்பளம் · $amount';
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
  String get listsChannelOffline => 'நேரடிக் கடை';

  @override
  String get listsEtaZepto => '~10 நிமி.';

  @override
  String get listsEtaBlinkit => '~10 நிமி.';

  @override
  String get listsEtaBigbasket => 'நாளை காலை 7–9';

  @override
  String get listsEtaAmazon => '1–2 நாட்கள்';

  @override
  String get listsEtaFlipkart => '2–3 நாட்கள்';

  @override
  String get listsEtaMeesho => '4–6 நாட்கள்';

  @override
  String get listsEtaOffline => 'அருகிலுள்ள கடை / D-Mart';

  @override
  String get listsEyebrow => 'வாங்க வேண்டியவை';

  @override
  String get listsTitle => 'பட்டியல்கள்';

  @override
  String get listsStoreMode => 'கடை முறை';

  @override
  String get listsGrocery => 'மளிகை';

  @override
  String get listsShopping => 'ஷாப்பிங்';

  @override
  String get listsPlaceholderGrocery =>
      '“பால் 2L”, “வெங்காயம் 1kg” சேர்க்கவும்…';

  @override
  String get listsPlaceholderShopping => '“போன் சார்ஜர்” சேர்க்கவும்…';

  @override
  String listsStoreButton(Object store) {
    return '$store-இல் வாங்க. மாற்று';
  }

  @override
  String get listsAddTooltip => 'சேர்';

  @override
  String get listsHintIdle =>
      'குறிப்பு: அளவுகள் தானாகப் புரியும் — “அரிசி 5kg”.';

  @override
  String listsHint(Object item, Object store, Object usual) {
    return '$item → $store$usual';
  }

  @override
  String listsHintItemQty(Object name, Object qty) {
    return '$name · $qty';
  }

  @override
  String get listsHintUsual => ' (வழக்கமாக வாங்கும் இடம்)';

  @override
  String listsAdded(Object name, Object store) {
    return 'சேர்க்கப்பட்டது: $name → $store';
  }

  @override
  String listsMerged(Object name, Object qty) {
    return '$name ஏற்கனவே பட்டியலில் இருந்தது — இப்போது $qty';
  }

  @override
  String listsAlready(Object name, Object qty) {
    return '$name ஏற்கனவே பட்டியலில் உள்ளது ($qty)';
  }

  @override
  String get listsPickerTitle => 'எங்கே வாங்குவீர்கள்?';

  @override
  String get listsPickerLead =>
      'புதிய பொருட்கள் இங்கே சேரும். முன்பு வாங்கியவை வழக்கமான கடையில் தானாகச் சேரும்.';

  @override
  String get listsAll => 'அனைத்தும்';

  @override
  String listsToBuy(int n, Object eta) {
    return 'வாங்க $n · $eta';
  }

  @override
  String get listsOrder => 'ஆர்டர் செய்';

  @override
  String get listsShop => 'கடைக்குச் செல்';

  @override
  String listsGotSemantics(Object name) {
    return '$name வாங்கப்பட்டது';
  }

  @override
  String get listsLess => 'குறை';

  @override
  String get listsMore => 'அதிகம்';

  @override
  String get listsCheckQty => 'அளவைச் சரிபார்க்கவும்';

  @override
  String listsGot(Object name) {
    return '$name வாங்கப்பட்டது';
  }

  @override
  String listsAllBought(Object store) {
    return '$store-இல் அனைத்தும் வாங்கப்பட்டன.';
  }

  @override
  String listsGotFooter(Object names) {
    return 'வாங்கியவை: $names';
  }

  @override
  String get listsClear => 'அகற்று';

  @override
  String listsCleared(int n) {
    return '$n அகற்றப்பட்டன · மீண்டும் வாங்கு பகுதியில் உள்ளன';
  }

  @override
  String listsItemLead(Object qty, Object category, String list) {
    String _temp0 = intl.Intl.selectLogic(list, {
      'grocery': 'மளிகை',
      'other': 'ஷாப்பிங்',
    });
    return '$qty · $category · $_temp0 பட்டியலில்';
  }

  @override
  String get listsName => 'பெயர்';

  @override
  String get listsQuantity => 'அளவு';

  @override
  String get listsUnit => 'அலகு';

  @override
  String get listsCategory => 'வகை';

  @override
  String get listsMoveTo => 'இங்கு நகர்த்து';

  @override
  String get listsRemove => 'நீக்கு';

  @override
  String get listsRemoved => 'நீக்கப்பட்டது';

  @override
  String get listsSave => 'சேமி';

  @override
  String get listsSaved => 'சேமிக்கப்பட்டது';

  @override
  String listsMoved(Object name, Object store) {
    return '$name → $store. இதை நினைவில் கொள்வோம்.';
  }

  @override
  String listsMergeAsk(Object name, Object qty) {
    return '$name ($qty) உடன் இணைக்கவா?';
  }

  @override
  String get listsMerge => 'இணை';

  @override
  String get listsCancel => 'ரத்து செய்';

  @override
  String get listsBuyAgain => 'மீண்டும் வாங்கு';

  @override
  String listsBuyAgainChip(Object name) {
    return '+ $name';
  }

  @override
  String get todayReadyToOrder => 'ஆர்டர் செய்யத் தயார்';

  @override
  String get todayListsLink => 'பட்டியல்கள்';

  @override
  String todayPillCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n பொருட்கள்',
      one: '1 பொருள்',
    );
    return '$_temp0';
  }

  @override
  String get todayStoreRun => 'கடைப் பயணம்';

  @override
  String get storeTitle => 'கடை முறை';

  @override
  String get storeBack => 'பின்செல்';

  @override
  String storeProgress(int done, int total) {
    return '$total-இல் $done எடுக்கப்பட்டது · திரை இயக்கத்தில் இருக்கும்';
  }

  @override
  String get storeEmptyTitle => 'நேரடிக் கடையில் வாங்க எதுவுமில்லை';

  @override
  String get storeEmptyBody =>
      'எந்தப் பட்டியலிலிருந்தும் பொருட்களை இங்கே நகர்த்தலாம்.';

  @override
  String get storeDoneLogBill => 'முடிந்தது · பில்லைப் பதிவிடு';

  @override
  String get storeLogTitle => 'இந்த பில்லைப் பதிவிடு';

  @override
  String get storeLogLead =>
      'கடை செலவுகளையும் உங்கள் மாதாந்திர செலவுகளில் சேர்த்து வைக்கும்.';

  @override
  String get storeBillAmount => 'பில் தொகை (₹)';

  @override
  String get storeStore => 'கடை';

  @override
  String get storeDMart => 'D-Mart';

  @override
  String get storeKirana => 'மளிகைக் கடை';

  @override
  String get storeSabzi => 'காய்கறி சந்தை';

  @override
  String get storeReliance => 'Reliance Fresh';

  @override
  String get storeOther => 'மற்றவை…';

  @override
  String get storeOtherName => 'கடையின் பெயர்';

  @override
  String get storePaidWith => 'செலுத்திய முறை';

  @override
  String get storeCash => 'ரொக்கம்';

  @override
  String get storeUpi => 'UPI';

  @override
  String get storeCard => 'கார்டு';

  @override
  String get storeSkip => 'தவிர்';

  @override
  String get storeSave => 'சேமி';

  @override
  String get storeCheckAmount => 'தொகையைச் சரிபார்க்கவும்';

  @override
  String get storeNameRequired => 'எந்தக் கடை?';

  @override
  String storeLogged(Object amount, Object store) {
    return '$store-இல் $amount பதிவானது';
  }

  @override
  String get storeTripDone => 'கடைப் பயணம் முடிந்தது · எடுத்தவை அகற்றப்பட்டன';

  @override
  String storeOpenFailed(Object store) {
    return '$store திறக்க முடியவில்லை. பட்டியல் நகலெடுக்கப்பட்டது — செயலியில் ஒட்டவும்.';
  }

  @override
  String storeBackFrom(Object store) {
    return '$store-இலிருந்து திரும்பினீர்களா?';
  }

  @override
  String storeBackLead(Object store) {
    return 'பட்டியலை நகலெடுத்து $store திறந்தோம். பட்டியல் சரியாக இருக்க, நீங்கள் இல்லம் செயலிக்குத் திரும்பும்போது இது காட்டப்படும்.';
  }

  @override
  String storeUnitChanged(Object qty) {
    return 'இப்போது $qty — அனைத்தும் ஆர்டர் செய்ததாகக் குறிக்கவும்';
  }

  @override
  String get storeNotYet => 'இன்னும் இல்லை';

  @override
  String get storeOrderedAll => 'அனைத்தும் ஆர்டர்';

  @override
  String storeOrderedN(int n) {
    return '$n ஆர்டர் செய்தேன்';
  }

  @override
  String storeOrderedNote(Object qty, Object store) {
    return '$store-இல் $qty ஆர்டர் செய்யப்பட்டது';
  }

  @override
  String get storeMarkedOrdered => 'ஆர்டர் செய்ததாகக் குறிக்கப்பட்டது';

  @override
  String storeOrderedOn(Object store) {
    return '$store-இல் ஆர்டர் செய்தது ✓';
  }

  @override
  String get storeHowMuch =>
      'எவ்வளவு செலவானது? இந்த மாத மொத்தம் சரியாக இருக்க இப்போதே சேர்க்கவும்.';

  @override
  String get storeAmount => 'தொகை (₹)';

  @override
  String get storeCashOnDelivery => 'டெலிவரியில் ரொக்கம்';

  @override
  String get storeAddLater => 'பின்னர் சேர்';

  @override
  String storeOrderAdded(Object amount, Object store) {
    return '$store ஆர்டர் $amount சேர்க்கப்பட்டது';
  }

  @override
  String get tasksYou => 'நீங்கள்';

  @override
  String get tasksEyebrow => 'வீட்டுப் பராமரிப்பு';

  @override
  String get tasksTitle => 'வேலைகள்';

  @override
  String get tasksCleaningTab => 'வழக்கங்கள்';

  @override
  String get tasksTodosTab => 'பணிகள்';

  @override
  String get tasksEveryone => 'அனைவரும்';

  @override
  String tasksOverdue(int n) {
    return '$n நா. தாமதம்';
  }

  @override
  String get tasksDueToday => 'இன்று செய்ய வேண்டியது';

  @override
  String get tasksDueTomorrow => 'நாளை செய்ய வேண்டியது';

  @override
  String tasksInDays(int n) {
    return '$n நாட்களில்';
  }

  @override
  String get tasksFreqDaily => 'தினமும்';

  @override
  String get tasksFreqWeekly => 'வாரம் ஒருமுறை';

  @override
  String get tasksFreqFortnightly => 'இரு வாரம் ஒருமுறை';

  @override
  String get tasksFreqMonthly => 'மாதம் ஒருமுறை';

  @override
  String get tasksFreqEvery3Months => '3 மாதத்திற்கு ஒருமுறை';

  @override
  String tasksFreqEveryN(int n) {
    return '$n நாட்களுக்கு ஒருமுறை';
  }

  @override
  String tasksRoutineMeta(Object who, Object room, Object freq) {
    return '$who · $room · $freq';
  }

  @override
  String get tasksFreshness => 'புத்துணர்வு';

  @override
  String get tasksDone => 'முடிந்தது';

  @override
  String tasksMarkDone(Object name) {
    return '$name முடிந்ததாகக் குறி';
  }

  @override
  String tasksRoutineDone(Object name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n நாட்களில்',
      one: 'நாளை',
    );
    return '$name முடிந்தது · அடுத்தது $_temp0';
  }

  @override
  String get tasksNoRoutines => 'இங்கே வழக்கங்கள் இல்லை';

  @override
  String tasksNoRoutinesBody(Object who) {
    return 'ஒன்றை ஒதுக்குங்கள் ($who).';
  }

  @override
  String get tasksAnyone => 'யாரேனும்';

  @override
  String get tasksNewRoutine => 'புதிய வழக்கம்';

  @override
  String get tasksNewRoutineTitle => 'புதிய வழக்கம்';

  @override
  String get tasksRoutineLead =>
      'இது தானாகவே மீண்டும் வரும் — மறுபடி சேர்க்கத் தேவையில்லை.';

  @override
  String get tasksWhatNeedsDoing => 'என்ன செய்ய வேண்டும்?';

  @override
  String get tasksRoutinePlaceholder =>
      'எ.கா. வாட்டர் ஃபில்டர் சோதனை, சிம்னி சுத்தம்';

  @override
  String get tasksNameRequired => 'என்ன செய்ய வேண்டும் எனச் சேர்க்கவும்.';

  @override
  String get tasksWhere => 'எங்கே';

  @override
  String get tasksRoomKitchen => 'சமையலறை';

  @override
  String get tasksRoomLiving => 'வரவேற்பறை';

  @override
  String get tasksRoomBedrooms => 'படுக்கையறைகள்';

  @override
  String get tasksRoomBathrooms => 'குளியலறைகள்';

  @override
  String get tasksRoomBalcony => 'பால்கனி';

  @override
  String get tasksRoomWhole => 'முழு வீடு';

  @override
  String get tasksOther => 'மற்றவை…';

  @override
  String get tasksRoomName => 'இடம் அல்லது பகுதி';

  @override
  String get tasksHowOften => 'எவ்வளவு அடிக்கடி';

  @override
  String get tasksEvery2 => '2 நாட்களுக்கு ஒருமுறை';

  @override
  String get tasksEvery3 => '3 நாட்களுக்கு ஒருமுறை';

  @override
  String get tasksCustom => 'தனிப்பயன்…';

  @override
  String get tasksEveryHowMany => 'எத்தனை நாட்களுக்கு ஒருமுறை?';

  @override
  String get tasksDaysRange => '1 முதல் 365 நாட்கள் வரை உள்ளிடவும்.';

  @override
  String get tasksWhoDoesIt => 'யார் செய்வது';

  @override
  String get tasksAddRoutine => 'வழக்கம் சேர்';

  @override
  String get tasksRoutineAdded => 'வழக்கம் சேர்க்கப்பட்டது · முதல் முறை இன்று';

  @override
  String get tasksEditRoutineTitle => 'வழக்கத்தைத் திருத்து';

  @override
  String get tasksSaveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get tasksRoutineUpdated => 'வழக்கம் புதுப்பிக்கப்பட்டது';

  @override
  String get tasksDeleteRoutine => 'வழக்கத்தை நீக்கு';

  @override
  String get tasksRoutineDeleted => 'வழக்கம் நீக்கப்பட்டது';

  @override
  String get tasksGroupOverdue => 'தாமதமானவை';

  @override
  String get tasksGroupToday => 'இன்று';

  @override
  String get tasksGroupTomorrow => 'நாளை';

  @override
  String get tasksGroupLater => 'பின்னர்';

  @override
  String tasksTodoMeta(Object day, Object who) {
    return '$day · $who';
  }

  @override
  String tasksCompleteTodo(Object title) {
    return '“$title” பணியை முடி';
  }

  @override
  String tasksTodoDone(Object title) {
    return 'முடிந்தது: $title';
  }

  @override
  String get tasksAllDone => 'அனைத்தும் முடிந்தது';

  @override
  String get tasksNothingPending => 'நிலுவையில் எதுவுமில்லை.';

  @override
  String tasksNothingPendingFor(Object name) {
    return '$name: நிலுவையில் எதுவுமில்லை.';
  }

  @override
  String tasksCompleted(int n) {
    return 'முடிந்தவை ($n)';
  }

  @override
  String tasksReopenTodo(Object title) {
    return '“$title” பணியை மீண்டும் திற';
  }

  @override
  String get tasksMovedBack => 'மீண்டும் நிலுவைக்கு மாற்றப்பட்டது';

  @override
  String get tasksNewTodo => 'புதிய பணி';

  @override
  String get tasksEditTodo => 'பணியைத் திருத்து';

  @override
  String get tasksWhat => 'என்ன';

  @override
  String get tasksTodoPlaceholder => 'எ.கா. AC சர்வீஸ் பதிவு செய்';

  @override
  String get tasksTodoRequired => 'என்ன செய்ய வேண்டும் எனச் சேர்க்கவும்.';

  @override
  String get tasksWhen => 'எப்போது';

  @override
  String get tasksToday => 'இன்று';

  @override
  String get tasksTomorrow => 'நாளை';

  @override
  String get tasksWeekend => 'வார இறுதி';

  @override
  String get tasksNextWeek => 'அடுத்த வாரம்';

  @override
  String get tasksPickDate => 'தேதி தேர்ந்தெடு…';

  @override
  String get tasksWho => 'யார்';

  @override
  String get tasksAddTodo => 'பணி சேர்';

  @override
  String get tasksTodoAdded => 'பணி சேர்க்கப்பட்டது';

  @override
  String get tasksTodoUpdated => 'பணி புதுப்பிக்கப்பட்டது';

  @override
  String get tasksDeleteTodo => 'பணியை நீக்கு';

  @override
  String get tasksTodoDeleted => 'பணி நீக்கப்பட்டது';

  @override
  String tasksSendList(Object name) {
    return '$name-க்கு இன்றைய பட்டியலை அனுப்பு';
  }

  @override
  String tasksJobs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n வேலைகள்',
      one: '1 வேலை',
    );
    return '$_temp0 · அவர்களுக்கு செயலி தேவையில்லை';
  }

  @override
  String get tasksPreview => 'முன்னோட்டம்';

  @override
  String tasksListFor(Object name) {
    return '$name — இன்றைய பட்டியல்';
  }

  @override
  String get tasksShareLead =>
      'அவர்களின் மொழியில் WhatsApp செய்தியாக அனுப்பப்படும். அவர்களுக்கு செயலி தேவையில்லை.';

  @override
  String get tasksLanguage => 'மொழி';

  @override
  String get tasksLangEnglish => 'English';

  @override
  String get tasksLangHindi => 'हिंदी';

  @override
  String get tasksLangTamil => 'தமிழ்';

  @override
  String get tasksCopy => 'நகலெடு';

  @override
  String get tasksCopied => 'நகலெடுக்கப்பட்டது — எந்த உரையாடலிலும் ஒட்டவும்';

  @override
  String get tasksWhatsApp => 'WhatsApp';

  @override
  String get todayDueToday => 'இன்று செய்ய வேண்டியவை';

  @override
  String get todayAllTasks => 'அனைத்து வேலைகள்';

  @override
  String get todayTodoKind => 'பணி';

  @override
  String todayMoreDue(int n) {
    return '+ மேலும் $n';
  }

  @override
  String get todayNothingDue => 'இன்று எதுவுமில்லை';

  @override
  String get todayEnjoyQuiet => 'அமைதியான நேரத்தை மகிழுங்கள்.';

  @override
  String get tasksRemoveStaffMoves =>
      'அவர்களின் வழக்கங்களும் நிலுவைப் பணிகளும் உங்களிடம் மாற்றப்படும்.';

  @override
  String get moneyEyebrow => 'வீட்டுச் செலவுகள்';

  @override
  String get moneyTitle => 'பணம்';

  @override
  String moneySpentIn(Object month) {
    return '$month மாதச் செலவு';
  }

  @override
  String moneyLeftOf(Object left, Object budget) {
    return '$budget-இல் $left மீதம்';
  }

  @override
  String moneyDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இன்னும் $count நாட்கள்',
      one: 'இன்னும் 1 நாள்',
    );
    return '$_temp0';
  }

  @override
  String moneyBelowPrev(Object amount, Object month) {
    return '$month மொத்தத்தை விட $amount குறைவு';
  }

  @override
  String moneyAbovePrev(Object amount, Object month) {
    return '$month மொத்தத்தை விட $amount அதிகம்';
  }

  @override
  String moneyOverBudget(Object amount) {
    return 'பட்ஜெட்டை விட $amount அதிகம்';
  }

  @override
  String get moneySetBudget => 'மாதாந்திர பட்ஜெட் அமை';

  @override
  String get moneyNoBudget => 'பட்ஜெட் அமைக்கவில்லை';

  @override
  String get moneyBudgetTitle => 'மாதாந்திர பட்ஜெட்';

  @override
  String get moneyBudgetSaved => 'பட்ஜெட் சேமிக்கப்பட்டது';

  @override
  String get moneySave => 'சேமி';

  @override
  String get moneyAddSpend => '＋ செலவு சேர்';

  @override
  String get moneyQuickAddHint =>
      'அல்லது எந்தத் தாவலிலிருந்தும் விரைவுச் சேர்ப்பில் “₹450 Swiggy” எனத் தட்டச்சு செய்யவும்.';

  @override
  String get moneyBills => 'இந்த மாத பில்கள்';

  @override
  String moneyBillsPaid(int k, int n) {
    return '$n-இல் $k செலுத்தியது';
  }

  @override
  String get moneyAddBill => '＋ பில் சேர்';

  @override
  String moneyBillDue(Object date, Object amount) {
    return 'கடைசித் தேதி $date · முன்பு $amount';
  }

  @override
  String get moneyOverdue => 'தாமதம்';

  @override
  String get moneyToday => 'இன்று';

  @override
  String get moneyPaid => 'செலுத்தியது';

  @override
  String moneyBillPaidOn(Object date, Object method) {
    return '$date அன்று செலுத்தியது · $method';
  }

  @override
  String get moneyPaidTwice =>
      'இருமுறை செலுத்தியதாகக் குறிக்கப்பட்டுள்ளது — சரிபார்க்கவும்';

  @override
  String moneyFirstDue(Object date, Object amount) {
    return 'முதல் தவணை $date · $amount';
  }

  @override
  String moneyMarkBillPaid(Object bill) {
    return '$bill செலுத்தியதாகக் குறி';
  }

  @override
  String get moneyBillsEmpty =>
      'வாடகை, மின்சாரம், பால், இணையம்… சேர்க்கவும் — செலுத்தும் நேரம் வரும்போது நினைவூட்டுவோம்.';

  @override
  String moneyStoppedBills(int count) {
    return 'நிறுத்திய பில்கள் ($count)';
  }

  @override
  String moneyStoppedRow(Object amount, int day) {
    return '$amount · $day-ஆம் தேதி';
  }

  @override
  String get moneyTrackAgain => 'மீண்டும் தொடங்கு';

  @override
  String moneyTrackingAgain(Object bill) {
    return '$bill மீண்டும் கண்காணிக்கப்படுகிறது';
  }

  @override
  String get moneyMethodUpi => 'UPI';

  @override
  String get moneyMethodCash => 'ரொக்கம்';

  @override
  String get moneyMethodCard => 'கார்டு';

  @override
  String get moneyMethodBank => 'வங்கி';

  @override
  String get moneyErrAmount => 'தொகையைச் சரிபார்க்கவும்';

  @override
  String get moneyWhereItWent => 'எதில் செலவானது';

  @override
  String moneyStaffPay(Object month) {
    return 'பணியாளர் சம்பளம் · $month';
  }

  @override
  String moneyBilledRate(Object billed, Object rate) {
    return '$billed கணக்கு · $rate/மணி';
  }

  @override
  String moneyMonthlyLeaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'மாதாந்திரம் · $count விடுப்புகள்',
      one: 'மாதாந்திரம் · 1 விடுப்பு',
    );
    return '$_temp0';
  }

  @override
  String get moneyRecent => 'சமீபத்தியவை';

  @override
  String get moneySeeAll => 'அனைத்தும் பார்';

  @override
  String moneyRowSub(Object day, Object category, Object source) {
    return '$day · $category · $source';
  }

  @override
  String moneySrcManual(Object name) {
    return '$name சேர்த்தது';
  }

  @override
  String get moneySrcYou => 'நீங்கள் சேர்த்தது';

  @override
  String moneySrcOrder(Object channel) {
    return '$channel ஆர்டர்';
  }

  @override
  String get moneySrcStore => 'கடை பில்';

  @override
  String get moneySrcBill => 'பில்';

  @override
  String get moneySrcSalary => 'சம்பளம்';

  @override
  String get moneyEmptyTitle => 'இந்த மாதம் இன்னும் செலவுகள் இல்லை';

  @override
  String get moneyEmptyBody =>
      '“＋ செலவு சேர்” என்பதைத் தட்டவும், அல்லது ஒரு பில்லைச் செலுத்தியதாகக் குறிக்கவும்.';

  @override
  String get moneyAddSpendTitle => 'செலவு சேர்';

  @override
  String get moneyEditSpendTitle => 'செலவைத் திருத்து';

  @override
  String get moneyAmountLabel => 'ரூபாயில் தொகை';

  @override
  String get moneyPaidTo => 'யாருக்கு / எதற்கு';

  @override
  String get moneyCategory => 'வகை';

  @override
  String get moneyCustomCategoryChip => '＋ தனிப்பயன்';

  @override
  String get moneyCustomCategoryLabel => 'தனிப்பயன் வகை';

  @override
  String get moneyCustomCategoryHint => 'எ.கா. மருத்துவம், பயணம், எரிபொருள்';

  @override
  String get moneyErrCategory => 'வகையின் பெயரை உள்ளிடவும்';

  @override
  String get moneyShowChart => 'வரைபடம் காட்டு';

  @override
  String get moneyHideChart => 'வரைபடம் மறை';

  @override
  String get moneyChartByItem => 'பொருள் வாரியாக';

  @override
  String get moneyChartByCategory => 'வகை வாரியாக';

  @override
  String get moneyChartByPeople => 'நபர் வாரியாக';

  @override
  String get moneyChartOther => 'பிற';

  @override
  String get moneyChartUnknown => 'தெரியாதவை';

  @override
  String get moneyDraftsCollapse => 'வரைவுச் செலவுகளைச் சுருக்கு';

  @override
  String get moneyDraftsExpand => 'வரைவுச் செலவுகளை விரி';

  @override
  String moneyDraftsShowAll(int count) {
    return 'அனைத்தையும் காட்டு ($count)';
  }

  @override
  String moneyDraftsShowLess(int count) {
    return 'முதல் $count காட்டு';
  }

  @override
  String moneyDraftsShowingCount(int shown, int total) {
    return '$total-இல் $shown காட்டப்படுகிறது';
  }

  @override
  String get moneyPaidWith => 'செலுத்திய முறை';

  @override
  String get moneyWhen => 'எப்போது';

  @override
  String get moneyYesterday => 'நேற்று';

  @override
  String get moneyOtherDay => 'வேறு நாள்';

  @override
  String get moneyMore => 'மேலும்';

  @override
  String get moneyPaidBy => 'செலுத்தியவர்';

  @override
  String get moneyYou => 'நீங்கள்';

  @override
  String get moneyNote => 'குறிப்பு';

  @override
  String get moneyRepeat => 'மாதந்தோறும் தொடரவும் — இது பில் ஆகும்';

  @override
  String get moneySaveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get moneyDelete => 'நீக்கு';

  @override
  String moneyAdded(Object amount) {
    return '$amount சேர்க்கப்பட்டது';
  }

  @override
  String moneyAddedBill(Object amount, Object merchant) {
    return '$amount சேர்க்கப்பட்டது · $merchant இப்போது மாதாந்திர பில்';
  }

  @override
  String moneyLearned(Object merchant, Object category) {
    return 'சேமிக்கப்பட்டது · இனி $merchant, $category வகையில் சேரும்.';
  }

  @override
  String get moneySpendUpdated => 'செலவு புதுப்பிக்கப்பட்டது';

  @override
  String get moneySpendDeleted => 'செலவு நீக்கப்பட்டது';

  @override
  String get moneyErrMerchant => 'யாருக்குச் செலுத்தப்பட்டது?';

  @override
  String moneyReadOnly(Object name) {
    return '$name சேர்த்தது · $name அல்லது நிர்வாகி மட்டுமே மாற்ற முடியும்.';
  }

  @override
  String moneySalaryManaged(Object name) {
    return 'சம்பளச் செலவுகள் $name-இன் சம்பளப் பகுதியில் நிர்வகிக்கப்படுகின்றன.';
  }

  @override
  String get moneyOpenSalary => 'சம்பளத்தைத் திற';

  @override
  String moneyDuplicate(
    Object who,
    Object amount,
    Object merchant,
    Object when,
  ) {
    return '$who ஏற்கனவே $when $amount · $merchant சேர்த்திருப்பது போல் தெரிகிறது.';
  }

  @override
  String get moneyWhoYou => 'நீங்கள்';

  @override
  String get moneyWhenToday => 'இன்று';

  @override
  String get moneyWhenYesterday => 'நேற்று';

  @override
  String moneyWhenOn(Object day) {
    return '$day அன்று';
  }

  @override
  String get moneyAddAnyway => 'இருந்தாலும் சேர்';

  @override
  String get moneyDontAdd => 'சேர்க்க வேண்டாம்';

  @override
  String get moneyCashSpend => 'ரொக்கச் செலவு';

  @override
  String moneyOrdinal(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': '1-ஆம்',
      '2': '2-ஆம்',
      '3': '3-ஆம்',
      '21': '21-ஆம்',
      '22': '22-ஆம்',
      '23': '23-ஆம்',
      '31': '31-ஆம்',
      'other': '$n-ஆம்',
    });
    return '$_temp0';
  }

  @override
  String get moneyAddBillTitle => 'பில் சேர்';

  @override
  String get moneyEditBillTitle => 'பில்லைத் திருத்து';

  @override
  String get moneyBillName => 'பெயர்';

  @override
  String get moneyUsualAmount => 'வழக்கமான தொகை (₹)';

  @override
  String get moneyDueDay => 'கெடு நாள்';

  @override
  String moneyDueHelper(Object nth) {
    return 'மாதந்தோறும் $nth தேதி வாக்கில் செலுத்தப்படும்';
  }

  @override
  String get moneyRemind => 'கெடு நாளில் நினைவூட்டு';

  @override
  String get moneyBillErrName => 'பில்லின் பெயரைச் சேர்க்கவும்.';

  @override
  String get moneyBillErrDay => '1 முதல் 31 வரை ஒரு நாளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String moneyBillAdded(Object bill) {
    return '$bill சேர்க்கப்பட்டது';
  }

  @override
  String get moneyBillSaved => 'பில் சேமிக்கப்பட்டது';

  @override
  String get moneyStopTracking => 'இந்த பில்லைக் கண்காணிப்பதை நிறுத்து';

  @override
  String moneyStopped(Object bill) {
    return '$bill கண்காணிப்பு நிறுத்தப்பட்டது';
  }

  @override
  String get moneyDeleteBill => 'பில்லை நீக்கு';

  @override
  String moneyDeleteBillTitle(Object bill) {
    return '$bill-ஐ நீக்கவா?';
  }

  @override
  String get moneyDeleteBillLead =>
      'முந்தைய செலவுகளில் “பில்” அடையாளம் அப்படியே இருக்கும்.';

  @override
  String get moneyKeep => 'வைத்திரு';

  @override
  String moneyBillDeleted(Object bill) {
    return '$bill நீக்கப்பட்டது';
  }

  @override
  String moneyPaidTitle(Object bill) {
    return '$bill — செலுத்தியதா?';
  }

  @override
  String moneyPaidLead(Object amount, Object nth) {
    return 'வழக்கமாக $nth தேதி வாக்கில் $amount.';
  }

  @override
  String moneyForMonth(Object month) {
    return '$month மாதத்திற்கு';
  }

  @override
  String get moneyMarkPaid => 'செலுத்தியதாகக் குறி';

  @override
  String moneyBillPaidSnack(Object bill, Object amount) {
    return '$bill செலுத்தப்பட்டது · $amount சேர்க்கப்பட்டது';
  }

  @override
  String get moneyAllSpends => 'அனைத்து செலவுகள்';

  @override
  String get moneySearch => 'செலவுகளைத் தேடு';

  @override
  String moneyCount(int count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செலவுகள் · $total',
      one: '1 செலவு · $total',
    );
    return '$_temp0';
  }

  @override
  String get moneyNoMatch => 'பொருந்தும் செலவுகள் இல்லை.';

  @override
  String moneyClearFilter(Object category) {
    return '$category வடிகட்டியை நீக்கு';
  }

  @override
  String todayMonthSoFar(Object month) {
    return '$month இதுவரை';
  }

  @override
  String get todayMoneyLink => 'பணம்';

  @override
  String todayOfBudget(Object budget, int pct) {
    return '$budget பட்ஜெட்டில் · $pct% செலவானது';
  }

  @override
  String todayBillsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பில்கள் நிலுவை',
      one: '1 பில் நிலுவை',
    );
    return '$_temp0';
  }

  @override
  String todaySpentSoFar(Object amount) {
    return 'இதுவரை $amount செலவு';
  }

  @override
  String get todaySetBudget => 'பட்ஜெட் அமை';

  @override
  String get recipeAPinch => 'ஒரு சிட்டிகை';

  @override
  String get onboardingAddStarterRecipes => '9 பிரபல சமையல் குறிப்புகளைச் சேர்';

  @override
  String get mealsTitle => 'உணவுகள்';

  @override
  String mealsWeekOf(String date) {
    return '$date வாரம்';
  }

  @override
  String get mealsPrevWeek => 'முந்தைய வாரம்';

  @override
  String get mealsNextWeek => 'அடுத்த வாரம்';

  @override
  String get mealsThisWeek => 'இந்த வாரம்';

  @override
  String mealsDaySemantics(String weekday, String date, int count) {
    return '$weekday $date, 3 வேளையில் $count உணவு திட்டமிடப்பட்டது';
  }

  @override
  String mealsMissingWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'வாரத்தின் மீதி நாட்களுக்கு $count பொருட்கள் இல்லை',
      one: 'வாரத்தின் மீதி நாட்களுக்கு 1 பொருள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get mealsAddAll => 'அனைத்தும் சேர்';

  @override
  String get mealsPastDay => 'கடந்த நாள்';

  @override
  String mealsSlotTitle(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'காலை',
      'lunch': 'மதியம்',
      'other': 'இரவு',
    });
    return '$_temp0';
  }

  @override
  String mealsSlotLower(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'காலை',
      'lunch': 'மதிய',
      'other': 'இரவு',
    });
    return '$_temp0';
  }

  @override
  String mealsPlanSlot(String slot) {
    return '$slot உணவு திட்டமிடு';
  }

  @override
  String mealsChangeSlot(String slot) {
    return '$slot உணவை மாற்று';
  }

  @override
  String get mealsPickFromBook =>
      'உங்கள் சமையல் புத்தகத்திலிருந்து தேர்ந்தெடுக்கவும்';

  @override
  String mealsMinutes(int min) {
    return '$min நிமி.';
  }

  @override
  String get mealsReadyToCook => 'சமைக்கத் தயார்';

  @override
  String mealsMissingCount(int count) {
    return '$count இல்லை';
  }

  @override
  String get mealsEatingOut => 'வெளியே சாப்பாடு';

  @override
  String get mealsLeftovers => 'மீதமுள்ள உணவு';

  @override
  String mealsRemoved(String name) {
    return '$name (நீக்கப்பட்டது)';
  }

  @override
  String get mealsRecipeBook => 'சமையல் புத்தகம்';

  @override
  String get mealsAdd => 'சேர்';

  @override
  String mealsCardMeta(int min, String tag) {
    return '$min நிமி. · $tag';
  }

  @override
  String get mealsEmptyTitle => 'இன்னும் சமையல் குறிப்புகள் இல்லை';

  @override
  String get mealsEmptyBody =>
      'உங்கள் முதல் குறிப்பைச் சேர்க்கவும், அல்லது பிரபலமான 9-ஐச் சேர்க்கவும்.';

  @override
  String get mealsAddStarter => '9 பிரபல சமையல் குறிப்புகளைச் சேர்';

  @override
  String get mealsTypeRecipe => 'சமையல் குறிப்பைத் தட்டச்சு செய்';

  @override
  String mealsStarterAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count சமையல் குறிப்புகள் சேர்க்கப்பட்டன',
      one: '1 சமையல் குறிப்பு சேர்க்கப்பட்டது',
    );
    return '$_temp0';
  }

  @override
  String mealsPickerTitle(String slot, String day) {
    return '$slot · $day';
  }

  @override
  String mealsPickerLead(String slot) {
    return 'முதலில் $slot உணவுக்கான பரிந்துரைகள். இல்லாத பொருட்கள் உங்கள் மளிகைப் பட்டியலில் சேரும்.';
  }

  @override
  String get mealsOptEatingOut => '🍽 வெளியே சாப்பாடு';

  @override
  String get mealsOptLeftovers => '♻ மீதமுள்ள உணவு';

  @override
  String get mealsOptNote => '✎ குறிப்பு…';

  @override
  String get mealsNoteHint => 'எ.கா. அம்மா வீட்டு தோசை';

  @override
  String get mealsNoteSave => 'குறிப்பைச் சேமி';

  @override
  String get mealsSearchRecipes => 'சமையல் குறிப்புகளைத் தேடு';

  @override
  String mealsClearSlot(String slot) {
    return '$slot உணவை நீக்கு';
  }

  @override
  String mealsPlanned(String dish) {
    return '$dish திட்டமிடப்பட்டது';
  }

  @override
  String mealsPlannedMissing(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்கள் இல்லை',
      one: '1 பொருள் இல்லை',
    );
    return '$dish திட்டமிடப்பட்டது · $_temp0';
  }

  @override
  String mealsPlannedKind(String slot, String what) {
    return '$slot · $what';
  }

  @override
  String get mealsSlotCleared => 'உணவுத் திட்டம் நீக்கப்பட்டது';

  @override
  String get mealsReviewTitle => 'மளிகைப் பட்டியலில் சேர்';

  @override
  String get mealsReviewLead =>
      'ஏற்கனவே வீட்டில் உள்ளவற்றின் தேர்வை நீக்கவும் — நாங்கள் நினைவில் வைத்திருப்போம்.';

  @override
  String mealsReviewAdd(int count) {
    return '$count சேர்';
  }

  @override
  String mealsAddedToGrocery(int count) {
    return 'மளிகைப் பட்டியலில் $count சேர்க்கப்பட்டது';
  }

  @override
  String get recipeTitle => 'சமையல் குறிப்பு';

  @override
  String get recipeAddToPlan => 'உணவுத் திட்டத்தில் சேர்';

  @override
  String get recipeMoreOptions => 'மேலும் விருப்பங்கள்';

  @override
  String get recipeEdit => 'திருத்து';

  @override
  String get recipeDelete => 'நீக்கு';

  @override
  String recipeServes(int n) {
    return '$n நபர்களுக்கு';
  }

  @override
  String get recipeIngredients => 'தேவையான பொருட்கள்';

  @override
  String get recipeServings => 'பரிமாறும் அளவு';

  @override
  String recipePpl(int n) {
    return '$n நபர்';
  }

  @override
  String get recipeFewer => 'குறைவான அளவு';

  @override
  String get recipeMoreServings => 'அதிக அளவு';

  @override
  String get recipeInKitchen => 'சமையலறையில் உள்ளது';

  @override
  String get recipeOnList => 'பட்டியலில் உள்ளது';

  @override
  String get recipeMissing => 'இல்லை';

  @override
  String get recipeSrHave => 'சமையலறையில் உள்ளது';

  @override
  String get recipeSrOnList => 'ஏற்கனவே மளிகைப் பட்டியலில் உள்ளது';

  @override
  String get recipeSrMissing => 'இல்லை';

  @override
  String recipeMarkedHave(String name) {
    return '$name சமையலறையில் உள்ளதாகக் குறிக்கப்பட்டது';
  }

  @override
  String recipeMarkedMissing(String name) {
    return '$name இல்லாததாகக் குறிக்கப்பட்டது';
  }

  @override
  String recipeAddMissing(int count) {
    return '🛒 இல்லாத $count-ஐ மளிகையில் சேர்';
  }

  @override
  String get recipeAllThere => '✓ எல்லாம் சமையலறையில் அல்லது பட்டியலில் உள்ளது';

  @override
  String get recipeMethod => 'செய்முறை';

  @override
  String get recipeStartCook => '🔥 சமையல் முறையைத் தொடங்கு';

  @override
  String recipePlanTitle(String dish) {
    return '$dish திட்டமிடு';
  }

  @override
  String get recipePlanDay => 'நாள்';

  @override
  String get recipePlanMeal => 'உணவு வேளை';

  @override
  String get recipePlanAdd => 'திட்டத்தில் சேர்';

  @override
  String recipePlannedFor(String day, String slot) {
    return '$day $slot உணவுக்குத் திட்டமிடப்பட்டது';
  }

  @override
  String recipeDeletePlanned(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: '1 நாளில்',
    );
    return '$dish $_temp0 திட்டமிடப்பட்டுள்ளது. அந்த நாட்களிலிருந்தும் நீக்கவா?';
  }

  @override
  String get recipeKeepPlans => 'அந்த நாட்களில் வைத்திரு';

  @override
  String get recipeRemoveToo => 'அங்கிருந்தும் நீக்கு';

  @override
  String get recipeDeleted => 'சமையல் குறிப்பு நீக்கப்பட்டது';

  @override
  String get recipeAddTitle => 'சமையல் குறிப்பு சேர்';

  @override
  String get recipeAddLead =>
      'எளிதான வழியைத் தேர்ந்தெடுக்கவும் — பிறகு திருத்திக்கொள்ளலாம்.';

  @override
  String get recipeTypeIt => 'தட்டச்சு செய்';

  @override
  String get recipeTypeItSub => 'பெயர், பொருட்கள், படிகள்';

  @override
  String get recipePasteLink => 'இணைப்பை ஒட்டு';

  @override
  String get recipePasteLinkSub =>
      'YouTube, Instagram அல்லது வலைப்பதிவு — பொருட்கள் தானாக எடுக்கப்படும்';

  @override
  String get recipeSnap => 'பக்கத்தைப் படம் எடு';

  @override
  String get recipeSnapSub =>
      'சமையல் புத்தகம் அல்லது கையெழுத்துக் குறிப்பின் படம்';

  @override
  String get recipeComingSoon => 'விரைவில் வருகிறது';

  @override
  String get recipeFormNew => 'புதிய சமையல் குறிப்பு';

  @override
  String get recipeFormEdit => 'சமையல் குறிப்பைத் திருத்து';

  @override
  String get recipeFieldName => 'பெயர்';

  @override
  String get recipeFieldTime => 'நேரம் (நிமிடங்களில்)';

  @override
  String get recipeFieldServes => 'பரிமாறும் நபர்கள்';

  @override
  String get recipeFieldMealType => 'உணவு வகை';

  @override
  String get recipeFieldTags => 'குறிச்சொற்கள்';

  @override
  String get recipeTagsHint => 'எ.கா. எளிது, குழந்தைகளுக்குப் பிடித்தது';

  @override
  String get recipeFieldIngredients => 'தேவையான பொருட்கள்';

  @override
  String get recipeIngName => 'பொருள்';

  @override
  String get recipeIngQty => 'அளவு';

  @override
  String get recipeIngUnit => 'அலகு';

  @override
  String get recipeUnitNone => '(ஏதுமில்லை)';

  @override
  String get recipeAddIngredient => '+ பொருள் சேர்';

  @override
  String get recipeFieldSteps => 'படிகள்';

  @override
  String recipeStepLabel(int n) {
    return 'படி $n';
  }

  @override
  String get recipeAddStep => '+ படி சேர்';

  @override
  String get recipeMoveUp => 'மேலே நகர்த்து';

  @override
  String get recipeMoveDown => 'கீழே நகர்த்து';

  @override
  String get recipeRemoveRow => 'நீக்கு';

  @override
  String get recipeSave => 'சேமி';

  @override
  String get recipeSaved => 'சமையல் குறிப்பு சேமிக்கப்பட்டது';

  @override
  String get recipeErrName => 'பெயரைச் சேர்க்கவும்.';

  @override
  String get recipeErrIngredients => 'குறைந்தது ஒரு பொருளையாவது சேர்க்கவும்.';

  @override
  String get recipeErrSteps => 'குறைந்தது ஒரு படியையாவது சேர்க்கவும்.';

  @override
  String get recipeErrQty => 'அளவு 0-ஐ விட அதிகமாக இருக்க வேண்டும்.';

  @override
  String get recipeErrIngName => 'பொருளின் பெயரைச் சேர்க்கவும்.';

  @override
  String get recipeErrTime => 'நேரம் 1–600 நிமிடங்களுக்குள் இருக்க வேண்டும்.';

  @override
  String get recipeErrServes => 'பரிமாறும் அளவு 1–20க்குள் இருக்க வேண்டும்.';

  @override
  String get recipeErrStepLong =>
      'ஒரு படி அதிகபட்சம் 500 எழுத்துகளுக்குள் இருக்க வேண்டும்.';

  @override
  String get recipeDiscardTitle => 'மாற்றங்களைக் கைவிடவா?';

  @override
  String get recipeKeepEditing => 'தொடர்ந்து திருத்து';

  @override
  String get recipeDiscard => 'கைவிடு';

  @override
  String get cookSub => 'சமையல் முறை · திரை அணைந்துவிடாது';

  @override
  String cookOf(int total) {
    return '/$total';
  }

  @override
  String cookStepSemantics(int n, int total, String text) {
    return '$total-இல் படி $n: $text';
  }

  @override
  String get cookBack => 'பின்செல்';

  @override
  String get cookNext => 'அடுத்த படி';

  @override
  String get cookFinished => '✓ முடிந்தது';

  @override
  String get todayMenuTitle => 'இன்றைய உணவு';

  @override
  String get todayWeekPlan => 'வாரத் திட்டம்';

  @override
  String get todayPlan => '+ திட்டம்';

  @override
  String todayMissingToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🛒 இன்று $count பொருட்கள் இல்லை',
      one: '🛒 இன்று 1 பொருள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get todayAddToList => 'பட்டியலில் சேர்';

  @override
  String get profileTitle => 'சுயவிவரம்';

  @override
  String profileRoleHome(String role, String home) {
    return '$role · $home';
  }

  @override
  String get roleAdmin => 'நிர்வாகி';

  @override
  String get roleMember => 'உறுப்பினர்';

  @override
  String get profileName => 'பெயர்';

  @override
  String get profileNameSheetTitle => 'உங்கள் பெயர்';

  @override
  String get profileNameSheetLead =>
      'உங்கள் வீட்டில் உள்ள அனைவருக்கும் காட்டப்படும். அவர்களின் ஃபோன்களிலும் ஒத்திசைக்கப்படும்.';

  @override
  String get profileNameError => 'உங்கள் பெயரைச் சேர்க்கவும்.';

  @override
  String get profileSave => 'சேமி';

  @override
  String get profileNameUpdated => 'பெயர் புதுப்பிக்கப்பட்டது';

  @override
  String get profileEditName => 'பெயரைத் திருத்து';

  @override
  String get profileThisPhone => 'இந்த ஃபோன்';

  @override
  String get profileOnlyThisPhone => 'இந்த ஃபோன் மட்டும்';

  @override
  String get profileDeviceKey => 'சாதனத் திறவுகோல்';

  @override
  String get profileDeviceKeySub =>
      'இது உண்மையில் உங்கள் ஃபோன் தான் என்பதை அறிய மற்றவர்கள் இதைப் பார்ப்பார்கள்';

  @override
  String get profileYourHomes => 'உங்கள் வீடுகள்';

  @override
  String get profileCurrent => 'தற்போதையது';

  @override
  String profileHomeSub(int family, int help, String role) {
    String _temp0 = intl.Intl.pluralLogic(
      family,
      locale: localeName,
      other: '$family குடும்பத்தினர்',
      one: '1 குடும்பத்தினர்',
    );
    String _temp1 = intl.Intl.pluralLogic(
      help,
      locale: localeName,
      other: '$help வீட்டு உதவியாளர்கள்',
      one: '1 வீட்டு உதவியாளர்',
    );
    return '$_temp0 · $_temp1 · நீங்கள் $role';
  }

  @override
  String get profileNotifications => 'அறிவிப்புகள்';

  @override
  String get notifArrival => 'வீட்டு உதவியாளர் வருகை';

  @override
  String get notifArrivalSub =>
      'வழக்கமாக வரும் நேரத்தில் வருகையைக் குறிக்க நினைவூட்டும்';

  @override
  String get notifDigest => 'காலைப் பணிச் சுருக்கம்';

  @override
  String get notifDigestSub => 'காலை 8 மணி · இன்று செய்ய வேண்டியவை';

  @override
  String get notifBillDue => 'பில் நிலுவை';

  @override
  String get notifBillDueSub =>
      'கெடு நாளில் · “மின்சாரம் ₹1,980 — செலுத்தியதா?”';

  @override
  String get notifEvening => 'மாலை செலவு நினைவூட்டல்';

  @override
  String get notifEveningSub =>
      'இரவு 9 மணி, அன்று எதுவும் சேர்க்கப்படாவிட்டால் மட்டும்';

  @override
  String get profileOnThisPhone => 'இந்த ஃபோனில்';

  @override
  String get profileBackup => 'காப்பு நகல்';

  @override
  String get profileBackupNotSetUp => 'அமைக்கப்படவில்லை';

  @override
  String get profileBackupArrives => 'காப்பு நகல்கள் P18-இல் வரும்';

  @override
  String get profileLanguage => 'மொழி';

  @override
  String get profileEnglish => 'ஆங்கிலம்';

  @override
  String get profileAppearance => 'தோற்றம்';

  @override
  String get themeSystem => 'கணினி';

  @override
  String get themeLight => 'வெளிர்';

  @override
  String get themeDark => 'அடர்';

  @override
  String get profileDevTools => 'மேம்பாட்டாளர் கருவிகள்';

  @override
  String profileRemoveHome(String home) {
    return '🗑 இந்த ஃபோனிலிருந்து $home-ஐ நீக்கு';
  }

  @override
  String profileRemoveTitle(String home) {
    return 'இந்த ஃபோனிலிருந்து $home-ஐ நீக்கவா?';
  }

  @override
  String get profileRemoveLead =>
      'இந்த ஃபோன் வீட்டிலிருந்து வெளியேறும், இதில் உள்ள தரவின் நகல் அழிக்கப்படும். மற்ற அனைவரிடமும் எல்லாம் அப்படியே இருக்கும்.';

  @override
  String get profileOnlyAdminLead =>
      'நீங்கள் மட்டுமே நிர்வாகி. வீட்டிற்கு நிர்வாகி இல்லாமல் போகாமல் இருக்க, முதலில் வேறு ஒருவரை நிர்வாகியாக்குங்கள்.';

  @override
  String get profileGoToMembers => 'உறுப்பினர்களுக்குச் செல்';

  @override
  String get profileKeep => 'வைத்திரு';

  @override
  String get profileRemove => 'நீக்கு';

  @override
  String get profileFinePrint =>
      '🔒 கணக்கு இல்லை, கிளவுட் இல்லை. உங்கள் வீட்டின் ஃபோன்களுக்கு இடையே தரவு நேரடியாகவும் மறைகுறியாக்கப்பட்டும் ஒத்திசைக்கப்படும்.';

  @override
  String get profilePrivacy => 'தனியுரிமைக் கொள்கை';

  @override
  String get profileHelp => 'உதவி';

  @override
  String get profileVersion => 'பதிப்பு';

  @override
  String homeSubtitle(int count, String id) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count குடும்பத்தினர்',
      one: '1 குடும்பத்தினர்',
    );
    return '$_temp0 · வீட்டு ஐடி $id';
  }

  @override
  String get homeRename => 'வீட்டின் பெயரை மாற்று';

  @override
  String get homeSyncPlaceholderTitle => 'இதுவரை இந்த ஃபோன் மட்டும்';

  @override
  String get homeSyncPlaceholderSub =>
      'உங்கள் குடும்பத்தினரின் ஃபோன்களை ஒத்திசைக்க அவர்களை அழையுங்கள்.';

  @override
  String homeYourPhone(String model) {
    return 'உங்கள் $model';
  }

  @override
  String get homeThisPhone => 'இந்த ஃபோன்';

  @override
  String get homeSyncFootnote =>
      'ⓘ ஒரே Wi-Fi-யில் இருக்கும்போது ஃபோன்கள் நேரடியாக ஒத்திசைக்கப்படும்; அல்லது இரண்டிலும் இல்லம் திறந்திருக்கும்போது இணையம் வழியாக ஒத்திசைக்கப்படும்.';

  @override
  String get homeBackupNone => 'இன்னும் காப்பு நகல்கள் இல்லை';

  @override
  String get homeBackupNotThisPhone =>
      'இந்த ஃபோனிலிருந்து காப்பு நகல் எடுக்கப்படவில்லை — உங்கள் நகலைச் சேர்க்கவும்';

  @override
  String get homeInvite => '+ ஒருவரை அழை';

  @override
  String get homeInviteArrives => 'அழைப்புகள் P14-இல் வரும்';

  @override
  String homeAskAdmins(String names) {
    return '🔒 நிர்வாகிகள் மட்டுமே உறுப்பினர்களை அழைக்கவோ நீக்கவோ முடியும். $names-ஐக் கேளுங்கள்.';
  }

  @override
  String homeOr(String a, String b) {
    return '$a அல்லது $b';
  }

  @override
  String get homeFamily => 'குடும்பம் · செயலியைப் பயன்படுத்துபவர்';

  @override
  String get homeYou => '(நீங்கள்)';

  @override
  String homeMemberSub(String model, String month) {
    return '$model · இணைந்தது $month';
  }

  @override
  String get homeHouseHelp => 'வீட்டு உதவியாளர் · செயலி தேவையில்லை';

  @override
  String get homeNoHelp => 'வீட்டு உதவியாளர் யாரும் இன்னும் சேர்க்கப்படவில்லை.';

  @override
  String get homeAddHelp => '+ வீட்டு உதவியாளர் சேர்';

  @override
  String get homeRolesTitle => 'நிர்வாகிகளும் உறுப்பினர்களும் என்ன செய்யலாம்?';

  @override
  String get homeRolesAdmin =>
      'உறுப்பினர் செய்யக்கூடிய அனைத்தும், மேலும்: ஆட்களை அழைக்கலாம், நீக்கலாம், பொறுப்புகளை மாற்றலாம், பணியாளர் சம்பள விதிகளை அமைக்கலாம், சம்பளம் கொடுக்கலாம், வீட்டின் பெயரை மாற்றலாம் அல்லது வீட்டை நீக்கலாம்.';

  @override
  String get homeRolesMember =>
      'பட்டியல்கள், பணிகள் மற்றும் உணவுகள்; வீட்டு உதவியாளர் வருகையைக் குறிக்கலாம்; செலவுகளைச் சேர்த்துப் பார்க்கலாம்; பட்ஜெட் மற்றும் சம்பள மொத்தத்தைப் பார்க்கலாம்.';

  @override
  String get homeRolesFootnote =>
      'ஒவ்வொரு ஃபோனும் இந்த விதிகளைத் தானே சரிபார்க்கும்; எனவே அனுமதியற்ற ஒருவர் செய்யும் மாற்றம் மற்ற அனைவராலும் புறக்கணிக்கப்படும்.';

  @override
  String get homeLeaveDelete => 'வெளியேறு அல்லது நீக்கு';

  @override
  String homeLeave(String home) {
    return '$home விட்டு வெளியேறு';
  }

  @override
  String get homeDelete => '🗑 எல்லா ஃபோன்களிலும் இந்த வீட்டை நீக்கு';

  @override
  String memberJoined(String month, String how) {
    return 'இணைந்தது $month · $how';
  }

  @override
  String get memberHowCreated => 'வீட்டை உருவாக்கியவர்';

  @override
  String memberHowInvited(String name) {
    return '$name அழைப்பின் மூலம்';
  }

  @override
  String get memberHowQr => 'QR குறியீடு மூலம் இணைந்தது';

  @override
  String get memberHowPhrase => 'சொற்றொடர் மூலம் இணைந்தது';

  @override
  String memberDeviceKey(String fp) {
    return 'சாதனத் திறவுகோல் $fp';
  }

  @override
  String get memberEditProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get memberStepDown => 'நிர்வாகி பொறுப்பிலிருந்து விலகு';

  @override
  String get memberStepDownLead =>
      'மீண்டும் நிர்வாகியாக மற்றொரு நிர்வாகி உங்களை நியமிக்க வேண்டும்.';

  @override
  String get memberCancel => 'ரத்து செய்';

  @override
  String get memberStepDownConfirm => 'விலகு';

  @override
  String get memberNowMemberSelf => 'நீங்கள் இப்போது உறுப்பினராக உள்ளீர்கள்.';

  @override
  String get homeLastAdmin =>
      'ஒரு வீட்டிற்கு குறைந்தது ஒரு நிர்வாகி இருக்க வேண்டும்.';

  @override
  String get memberMakeAdmin => '🛡 நிர்வாகியாக்கு';

  @override
  String get memberRemoveAdmin => 'நிர்வாகி உரிமையை நீக்கு';

  @override
  String get memberRemove => 'நீக்கு';

  @override
  String memberNowAdmin(String name) {
    return '$name இப்போது நிர்வாகி';
  }

  @override
  String memberNowMember(String name) {
    return '$name இப்போது உறுப்பினர்';
  }

  @override
  String get homeOnlyAdminsRoles =>
      'நிர்வாகிகள் மட்டுமே பொறுப்புகளை மாற்றவோ ஆட்களை நீக்கவோ முடியும்.';

  @override
  String get homeNameLength => 'உங்கள் வீட்டிற்கு ஒரு பெயர் கொடுங்கள்.';

  @override
  String get homeChooseAdmin => 'முதலில் புதிய நிர்வாகியைத் தேர்ந்தெடுக்கவும்';

  @override
  String memberRemoveTitle(String name) {
    return '$name-ஐ நீக்கவா?';
  }

  @override
  String memberRemoveLeadWork(String home, String work) {
    return 'அவர்களின் ஃபோன் $home உடன் ஒத்திசைப்பதை நிறுத்திவிடும்; புதிய மாற்றங்கள் எதுவும் கிடைக்காது. அவர்களின் $work உங்களுக்கு மாற்றப்படும்.';
  }

  @override
  String memberRemoveLead(String home) {
    return 'அவர்களின் ஃபோன் $home உடன் ஒத்திசைப்பதை நிறுத்திவிடும்; புதிய மாற்றங்கள் எதுவும் கிடைக்காது.';
  }

  @override
  String get memberRemoveInfo =>
      'அவர்களின் ஃபோன் அடுத்து உங்கள் ஃபோன்களில் ஒன்றுடன் இணையும்போது வீட்டை அழித்துவிடும். அதுவரை — அல்லது மீண்டும் இணையவே இல்லையென்றால் — ஏற்கனவே இருந்த தகவல்கள் அதில் இருக்கும். மற்ற அனைவரும் புதிய வீட்டுத் திறவுகோலுக்கு மாறுவார்கள்.';

  @override
  String memberRemoved(String name) {
    return '$name நீக்கப்பட்டார்';
  }

  @override
  String workRoutines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வழக்கப் பணிகள்',
      one: '1 வழக்கப் பணி',
    );
    return '$_temp0';
  }

  @override
  String workTodos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நிலுவைப் பணிகள்',
      one: '1 நிலுவைப் பணி',
    );
    return '$_temp0';
  }

  @override
  String workAnd(String a, String b) {
    return '$a மற்றும் $b';
  }

  @override
  String get homeRenameLead =>
      'அவர்களின் ஃபோன் ஒத்திசைத்த பிறகு புதிய பெயரை அனைவரும் பார்ப்பார்கள்.';

  @override
  String get homeRenamed => 'வீட்டின் பெயர் மாற்றப்பட்டது';

  @override
  String get homeOnlyOneTitle => 'இங்கு நீங்கள் மட்டுமே உள்ளீர்கள்';

  @override
  String homeOnlyOneLead(String home) {
    return 'வெளியேறினால் $home-ல் எந்த ஃபோனும் இருக்காது; அதனால் அது நீக்கப்படும்.';
  }

  @override
  String get homeStay => 'தொடர்ந்திரு';

  @override
  String get homeDeleteHome => 'வீட்டை நீக்கு';

  @override
  String homeLeaveTitle(String home) {
    return '$home விட்டு வெளியேறவா?';
  }

  @override
  String homeLeaveLeadWork(String work, String admin) {
    return 'இந்த ஃபோன் ஒத்திசைப்பதை நிறுத்தி, இதன் நகல் அழிக்கப்படும். உங்கள் $work $admin-க்கு மாற்றப்படும். ஒரு நிர்வாகி எப்போது வேண்டுமானாலும் உங்களை மீண்டும் அழைக்கலாம்.';
  }

  @override
  String get homeLeaveLead =>
      'இந்த ஃபோன் ஒத்திசைப்பதை நிறுத்தி, இதன் நகல் அழிக்கப்படும். ஒரு நிர்வாகி எப்போது வேண்டுமானாலும் உங்களை மீண்டும் அழைக்கலாம்.';

  @override
  String get homeLeaveConfirm => 'வெளியேறு';

  @override
  String homeLeft(String home) {
    return '$home விட்டு வெளியேறிவிட்டீர்கள். தொடர, ஒரு வீட்டை உருவாக்கவும் அல்லது இணையவும்.';
  }

  @override
  String homeDeleteTitle(String home) {
    return '$home-ஐ நீக்கவா?';
  }

  @override
  String get homeDeleteLead =>
      'வீட்டில் உள்ள ஒவ்வொரு ஃபோனும் ஒத்திசைத்தவுடன் அதன் நகலை — பட்டியல்கள், பணிகள், உணவுகள், வருகை, சம்பளம் மற்றும் செலவுகள் — அழித்துவிடும். இதைத் திரும்பப் பெற முடியாது.';

  @override
  String get homeDeleteInfo =>
      'இனிமேல் ஒத்திசைக்காத ஃபோனில், யாராவது அதைத் திறக்கும் வரை அதன் நகல் இருக்கும்.';

  @override
  String homeTypeToConfirm(String home) {
    return 'உறுதிசெய்ய $home எனத் தட்டச்சு செய்யவும்';
  }

  @override
  String get homeDeleteConfirm => 'எல்லா ஃபோன்களிலும் நீக்கு';

  @override
  String todayFamilyButton(String home, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count குடும்ப உறுப்பினர்கள்',
      one: '1 குடும்ப உறுப்பினர்',
    );
    return '$home: $_temp0. வீட்டை நிர்வகி';
  }

  @override
  String get todayYourProfile => 'உங்கள் சுயவிவரம்';

  @override
  String todayThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count விஷயங்கள்',
      one: '1 விஷயம்',
    );
    return '$_temp0';
  }

  @override
  String todayThingsNeed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' இன்று வீட்டிற்குத் தேவை.',
      one: ' இன்று வீட்டிற்குத் தேவை.',
    );
    return '$_temp0';
  }

  @override
  String todayStaffAtHome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இப்போது $count உதவியாளர்கள் வீட்டில்',
      one: 'இப்போது 1 உதவியாளர் வீட்டில்',
    );
    return '$_temp0';
  }

  @override
  String get todayNoStaff => 'வீட்டில் உதவியாளர் இல்லை';

  @override
  String todayBudgetLeft(String amount) {
    return 'பட்ஜெட்டில் $amount மீதம்';
  }

  @override
  String todayBudgetOver(String amount) {
    return 'பட்ஜெட்டை விட $amount அதிகம்';
  }

  @override
  String get todaySetABudget => 'பட்ஜெட் அமை';

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
  String get notifChannelStaff => 'வீட்டு உதவியாளர்';

  @override
  String get notifChannelTasks => 'பணிகள் & நினைவூட்டல்கள்';

  @override
  String get notifChannelMoney => 'பில்கள் & செலவுகள்';

  @override
  String get notifChannelBackup => 'காப்புப்பிரதி';

  @override
  String get notifChannelHome => 'வீடு & உறுப்பினர்கள்';

  @override
  String get notifAppName => 'இல்லம்';

  @override
  String notifArrivalBody(String name, String time) {
    return '$name வழக்கமாக $time மணிக்கு வருவார் — வருகையைக் குறிக்கவா?';
  }

  @override
  String get notifMarkInNow => 'வருகை குறி';

  @override
  String get notifOnLeaveToday => 'இன்று விடுப்பு';

  @override
  String notifDigestBody(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இன்று $count விஷயங்கள்: $titles…',
      one: 'இன்று 1 விஷயம்: $titles',
    );
    return '$_temp0';
  }

  @override
  String notifBillBody(String bill, String amount) {
    return '$bill இன்று செலுத்த வேண்டும் · கடந்த முறை $amount';
  }

  @override
  String notifPaidAmount(String amount) {
    return '$amount செலுத்தப்பட்டது';
  }

  @override
  String get notifOpen => 'திற';

  @override
  String get notifEveningBody =>
      'இன்று ஏதாவது செலவு செய்தீர்களா? சில நொடிகளில் சேர்க்கலாம்.';

  @override
  String get notifExplainerTitle => 'நினைவூட்டல்களை இயக்கவா?';

  @override
  String notifExplainerBody(String name) {
    return '$name வழக்கமாக வரும் நேரத்தில் நினைவூட்டலும், அன்றைய பணிகளின் காலைப் பட்டியலும் பெறுங்கள்.';
  }

  @override
  String get notifYourHelp => 'உங்கள் வீட்டு உதவியாளர்';

  @override
  String get notifNotNow => 'இப்போது வேண்டாம்';

  @override
  String get notifContinue => 'தொடர்';

  @override
  String get notifOffBanner => 'இல்லம் அறிவிப்புகள் நிறுத்தப்பட்டுள்ளன';

  @override
  String get notifTurnOn => 'இயக்கு';

  @override
  String get debugRunJobs => 'Run background jobs now';

  @override
  String get debugPlanReminders => 'Plan reminders';

  @override
  String get debugRanJobs => 'Ran background jobs';

  @override
  String syncChangeNotApplied(String reason) {
    return 'உங்கள் மாற்றம் சேர்க்கப்படவில்லை: $reason';
  }

  @override
  String get syncReasonAdminOnly => 'நிர்வாகிகள் மட்டுமே இதை மாற்ற முடியும்';

  @override
  String get syncReasonOwnOnly =>
      'உங்கள் சொந்தப் பதிவுகளை மட்டுமே மாற்ற முடியும்';

  @override
  String get syncReasonTooOld => 'இது 48 மணி நேரத்திற்கும் பழமையானது';

  @override
  String get syncReasonLastAdmin =>
      'ஒரு வீட்டிற்கு குறைந்தது ஒரு நிர்வாகி இருக்க வேண்டும்.';

  @override
  String get syncReasonOther => 'ஏதோ தவறு ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get syncLabTitle => 'ஒத்திசைவு ஆய்வகம்';

  @override
  String syncLabCounts(int applied, int pending, int quarantined) {
    return 'மாற்றங்கள்: $applied சேர்த்தது · $pending காத்திருப்பு · $quarantined நிறுத்தம்';
  }

  @override
  String get syncLabMemberLog => 'உறுப்பினர் பதிவு';

  @override
  String get syncLabVerify => 'எல்லா கையொப்பங்களையும் சரிபார்';

  @override
  String syncLabVerifyResult(int ok, int bad, int unsigned) {
    return '$ok ✓ கையொப்பம் · $bad தவறு · $unsigned கையொப்பமற்றது';
  }

  @override
  String get syncLabExport => 'தொகுப்பை ஏற்றுமதி செய்';

  @override
  String syncLabExported(int n) {
    return 'தொகுப்பு நகலெடுக்கப்பட்டது · $n மாற்றங்கள்';
  }

  @override
  String get syncLabImport => 'கிளிப்போர்டிலிருந்து தொகுப்பை இறக்குமதி செய்';

  @override
  String syncLabImportResult(
    int applied,
    int already,
    int pending,
    int quarantined,
  ) {
    return 'சேர்த்தது $applied · முன்பே உள்ளது $already · காத்திருப்பு $pending · நிறுத்தம் $quarantined';
  }

  @override
  String get syncLabOtherHome => 'இந்தத் தொகுப்பு வேறொரு வீட்டிற்கானது.';

  @override
  String get syncLabReplace => 'இந்த ஃபோனின் வீட்டை மாற்று';

  @override
  String get syncLabBadBundle => 'அது இல்லம் தொகுப்பு அல்ல.';

  @override
  String get syncLabTamper => 'மாற்றச் சோதனை';

  @override
  String get syncLabAsArjunTick => 'அர்ஜுனாக: மளிகைப் பொருளைக் குறி';

  @override
  String get syncLabAsArjunRename => 'அர்ஜுனாக: வீட்டின் பெயரை மாற்று';

  @override
  String get syncLabSigned => '✓ கையொப்பமிட்டது';

  @override
  String get syncLabUnsigned => '✕ கையொப்பமற்றது';

  @override
  String get syncLabShare => 'பகிர்';

  @override
  String syncLabRecentOps(int count) {
    return 'கடைசி $count செயல்கள்';
  }

  @override
  String syncLabMemberCounts(
    int applied,
    int ignored,
    int pending,
    int devices,
  ) {
    return '$applied சேர்த்தது · $ignored புறக்கணிப்பு · $pending காத்திருப்பு · $devices சாதனங்கள்';
  }

  @override
  String get inviteTitle => 'ஒருவரை அழைக்கவும்';

  @override
  String inviteFirstRunTitle(String home) {
    return '$home தயாராக உள்ளது';
  }

  @override
  String inviteFirstRunSub(String homeId) {
    return 'வீட்டு ID $homeId';
  }

  @override
  String get inviteFirstRunLead =>
      'உங்கள் குடும்பத்தினர் இதைத் தங்கள் ஃபோனில் ஸ்கேன் செய்யலாம் அல்லது சொற்றொடரை அனுப்பலாம். ஒவ்வொருவரையும் நீங்கள் இங்கே அனுமதிக்க வேண்டும்.';

  @override
  String inviteQrLabel(String home) {
    return '$home-ல் இணைய QR குறியீடு';
  }

  @override
  String get inviteOrTypePhrase => 'அல்லது இந்தச் சொற்றொடரைத் தட்டச்சு செய்';

  @override
  String get inviteSendWhatsApp => 'WhatsApp-ல் சொற்றொடரை அனுப்பு';

  @override
  String inviteWhatsAppText(String home, String phrase) {
    return 'இல்லத்தில் \"$home\" வீட்டில் இணையுங்கள். செயலியைத் திறந்து → வீட்டில் இணையுங்கள் → இதைத் தட்டச்சு செய்யவும்: $phrase\n(10 நிமிடங்கள் செல்லுபடியாகும்)';
  }

  @override
  String get inviteCopyPhrase => 'சொற்றொடரை நகலெடு';

  @override
  String get invitePhraseCopied =>
      'சொற்றொடர் நகலெடுக்கப்பட்டது — 10 நிமிடங்களுக்கு ஒருமுறை மட்டுமே பயன்படும்';

  @override
  String inviteValidFor(String time) {
    return '$time வரை செல்லும் · ஒருமுறை மட்டுமே';
  }

  @override
  String get inviteExpired => 'இந்தக் குறியீடு காலாவதியாகிவிட்டது.';

  @override
  String get inviteMakeNew => 'புதிய குறியீடு உருவாக்கு';

  @override
  String get inviteVisibleWifi => 'இந்த Wi-Fi-ல் தெரிகிறது';

  @override
  String get inviteVisibleWifiSub =>
      'ஒரே Wi-Fi-ல் உள்ள ஃபோன்கள் நேரடியாக இணையும்';

  @override
  String get inviteNoWifi =>
      'Wi-Fi இல்லை — மற்றவர்கள் இணையம் வழியாகவும் இணையலாம்';

  @override
  String get inviteWaiting => 'யாராவது இணையக் காத்திருக்கிறது…';

  @override
  String get inviteWaitingSub =>
      'அவர்கள் இணையும் வரை இந்தத் திரையைத் திறந்தே வைத்திருக்கவும்';

  @override
  String get inviteRequestEyebrow => 'இணைப்பு கோரிக்கை';

  @override
  String inviteRequestVia(String model) {
    return '$model · இந்த Wi-Fi-ல்';
  }

  @override
  String inviteRequestSas(String emojis) {
    return 'அவர்களின் ஃபோனில் $emojis தெரிய வேண்டும்';
  }

  @override
  String get inviteRequestSasHint => 'தெரியாவிட்டால், மறு என்பதைத் தட்டவும்.';

  @override
  String get inviteJoinsAs => 'இணையும் பொறுப்பு';

  @override
  String get inviteAdminNote =>
      'நிர்வாகிகள் ஆட்களை அழைக்கலாம், நீக்கலாம் மற்றும் சம்பளத்தை நிர்வகிக்கலாம்.';

  @override
  String get inviteDeny => 'மறு';

  @override
  String get inviteAllow => '✓ அனுமதி';

  @override
  String inviteAdding(String name) {
    return '$name-ஐச் சேர்க்கிறது';
  }

  @override
  String inviteSending(int pct) {
    return 'வீட்டின் தகவல்களை அனுப்புகிறது… $pct%';
  }

  @override
  String get inviteSendingSub =>
      'மறைகுறியாக்கப்பட்டு, நேரடியாக அவர்களின் ஃபோனுக்கு அனுப்பப்படுகிறது. இந்தத் திரையைத் திறந்தே வைத்திருக்கவும்.';

  @override
  String inviteJoined(String name) {
    return '$name இணைந்தார்';
  }

  @override
  String get inviteJoinedSub =>
      'அவர்களின் ஃபோன் இப்போது இந்த வீட்டுடன் ஒத்திசைகிறது.';

  @override
  String get inviteAnother => 'வேறொருவரை அழை';

  @override
  String inviteDeclinedSnack(String name) {
    return '$name மறுக்கப்பட்டார். பழைய சொற்றொடர் மீண்டும் பயன்படாதபடி புதியது உருவாக்கப்பட்டது.';
  }

  @override
  String get inviteSkip => 'இப்போது தவிர் — பிறகு அழைக்கலாம்';

  @override
  String get inviteContinue => 'என் வீட்டிற்குச் செல்';

  @override
  String get inviteDone => 'முடிந்தது';

  @override
  String inviteWelcomeSnack(String home) {
    return '$home-க்கு நல்வரவு';
  }

  @override
  String inviteMembersOnly(String admins) {
    return 'நிர்வாகிகள் மட்டுமே ஆட்களை அழைக்க முடியும். $admins-ஐக் கேளுங்கள்.';
  }

  @override
  String debugInvitePort(int port) {
    return 'Debug: listening on port $port';
  }

  @override
  String get joinTitle => 'வீட்டில் இணையுங்கள்';

  @override
  String get joinSub =>
      'வீட்டில் உள்ள ஒருவரை அவர்கள் ஃபோனில் \'ஒருவரை அழைக்கவும்\' திரையைத் திறக்கச் சொல்லுங்கள். பிறகு QR குறியீட்டை ஸ்கேன் செய்யவும் அல்லது அவர்கள் பகிரும் சொற்றொடரைத் தட்டச்சு செய்யவும்.';

  @override
  String get joinYourName => 'உங்கள் பெயர்';

  @override
  String get joinNameRequired =>
      'முதலில் உங்கள் பெயரைச் சேர்க்கவும் — உங்கள் குடும்பத்தினர் உங்களை இப்படியே பார்ப்பார்கள்.';

  @override
  String get joinScanTitle => 'QR குறியீட்டை ஸ்கேன் செய்';

  @override
  String get joinScanSub =>
      'அருகில் இருக்கும்போது மிக விரைவானது. ஒரே Wi-Fi அல்லது இணையம் வழியாக வேலை செய்யும்.';

  @override
  String get joinPhraseTitle => 'இணைப்புச் சொற்றொடரைத் தட்டச்சு செய்';

  @override
  String get joinPhraseSub =>
      '47-mango-river-tulip போன்றது — WhatsApp-ல் அனுப்பியிருந்தால் வசதியானது.';

  @override
  String get phraseSub =>
      'அவர்களின் ஃபோனில் அழைப்புத் திரையில் தெரியும் ஒரு எண்ணும் மூன்று சொற்களும்.';

  @override
  String get phraseField => 'இணைப்புச் சொற்றொடர்';

  @override
  String get phraseHint => '47-mango-river-tulip';

  @override
  String get phraseNote =>
      'இடைவெளி விட்டும் தட்டச்சு செய்யலாம்: ‘47 mango river tulip’. இந்தச் சொற்றொடர் ஒருமுறை மட்டுமே வேலை செய்யும்; 10 நிமிடங்களில் காலாவதியாகும்.';

  @override
  String get phraseConnect => 'இணை';

  @override
  String get phraseBadFormat =>
      'இது சரியாகத் தெரியவில்லை. 47-mango-river-tulip போல ஒரு எண்ணும் மூன்று சொற்களும் இருக்க வேண்டும்.';

  @override
  String get phraseBadWord =>
      'சொற்களில் ஒன்று பட்டியலில் இல்லை — எழுத்துப்பிழையைச் சரிபார்க்கவும்.';

  @override
  String get debugPort => 'Debug port';

  @override
  String get scanTitle => 'QR குறியீட்டை ஸ்கேன் செய்';

  @override
  String get scanHint =>
      'அவர்களின் ஃபோனில்: சுயவிவரம் → வீடு → ஒருவரை அழைக்கவும்';

  @override
  String get scanTypeInstead => 'பதிலாக சொற்றொடரைத் தட்டச்சு செய்';

  @override
  String get scanNote =>
      '🔒 குறியீட்டைப் படிக்க மட்டுமே கேமரா பயன்படும். எதுவும் பதிவு செய்யப்படாது.';

  @override
  String get scanDenied =>
      'ஸ்கேன் செய்ய கேமராவை அனுமதிக்கவும், அல்லது சொற்றொடரைத் தட்டச்சு செய்யவும்.';

  @override
  String get scanOpenSettings => 'அமைப்புகளைத் திற';

  @override
  String get scanTorch => 'டார்ச்';

  @override
  String get whoTheir => 'அவர்களின்';

  @override
  String whoName(String name) {
    return '$name-ன்';
  }

  @override
  String get connectEyebrow => 'இணைகிறது';

  @override
  String connectEyebrowHome(String home) {
    return 'இணைகிறது · $home';
  }

  @override
  String get connectTitle => 'இணைகிறது…';

  @override
  String connectWelcome(String home) {
    return '$home-க்கு நல்வரவு';
  }

  @override
  String get connectFailed => 'இணைவதில் ஏதோ தடை ஏற்பட்டது';

  @override
  String stepFindActive(String who) {
    return '$who ஃபோனை இந்த Wi-Fi-ல் தேடுகிறது…';
  }

  @override
  String stepFindDone(String who) {
    return '$who ஃபோன் இந்த Wi-Fi-ல் கிடைத்தது';
  }

  @override
  String get stepCodeActive => 'குறியீட்டைச் சரிபார்க்கிறது…';

  @override
  String get stepCodeDone =>
      'குறியீடு பொருந்தியது · இணைப்பு மறைகுறியாக்கப்பட்டது';

  @override
  String stepApproveActive(String inviter) {
    return '$inviter அனுமதிக்கக் காத்திருக்கிறது…';
  }

  @override
  String stepApproveSas(String inviter, String emojis) {
    return '$inviter-ன் ஃபோனில் $emojis தெரிகிறதா எனச் சரிபார்க்கவும்';
  }

  @override
  String stepApproveDone(String inviter, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'நிர்வாகியாக',
      'other': 'உறுப்பினராக',
    });
    return '$inviter உங்களை $_temp0 அனுமதித்தார்';
  }

  @override
  String stepCopyActive(int pct) {
    return 'வீட்டின் தகவல்களை நகலெடுக்கிறது… $pct%';
  }

  @override
  String stepCopyDone(int n) {
    return '$n உருப்படிகள் நகலெடுக்கப்பட்டன · நீங்கள் ஒத்திசைவில் உள்ளீர்கள்';
  }

  @override
  String successBody(String names) {
    return '$names உடன் இணைந்துவிட்டீர்கள். மாற்றங்கள் இப்போது உங்கள் ஃபோன்களுக்கு இடையே ஒத்திசைக்கும்.';
  }

  @override
  String goHome(String home) {
    return '$home-க்குச் செல்';
  }

  @override
  String get tryAgain => 'மீண்டும் முயற்சி';

  @override
  String get useDifferentCode => 'வேறு குறியீடு பயன்படுத்து';

  @override
  String get finishLater => 'பிறகு முடி';

  @override
  String get finishLaterNote =>
      'நீங்கள் ஏற்கனவே இணைந்துவிட்டீர்கள் — நகலெடுப்பு அடுத்த முறை தொடரும்.';

  @override
  String get stoppedSnack => 'நிறுத்தப்பட்டது. எதுவும் பகிரப்படவில்லை.';

  @override
  String joinedSnack(String home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'நிர்வாகியாக',
      'other': 'உறுப்பினராக',
    });
    return '$home-ல் $_temp0 இணைந்துவிட்டீர்கள்';
  }

  @override
  String errNotFound(String who) {
    return '$who ஃபோனைத் தொடர்பு கொள்ள முடியவில்லை';
  }

  @override
  String errNotFoundHelp(String inviter) {
    return 'குறிப்பு: $inviter-ன் ஃபோனில் அழைப்புத் திரையைத் திறந்தே வைத்திருக்கவும்; இரு ஃபோன்களிலும் Wi-Fi அல்லது மொபைல் டேட்டா இயக்கத்தில் இருப்பதை உறுதிசெய்யவும். சொற்றொடர் 10 நிமிடங்கள் செல்லுபடியாகும்.';
  }

  @override
  String get errWrongCode => 'சொற்றொடர் பொருந்தவில்லை';

  @override
  String errWrongCodeHelp(String inviter) {
    return '$inviter-டம் சொற்றொடரைச் சரிபார்க்கவும் — 3 தவறான முயற்சிகளுக்குப் பிறகு இது செயலிழக்கும், அவர்கள் புதியதை உருவாக்க வேண்டும்.';
  }

  @override
  String get errExpired =>
      'இந்தச் சொற்றொடர் காலாவதியாகிவிட்டது அல்லது ஏற்கனவே பயன்படுத்தப்பட்டது. புதியதைக் கேளுங்கள்.';

  @override
  String errDeclined(String inviter) {
    return '$inviter கோரிக்கையை மறுத்துவிட்டார்';
  }

  @override
  String errDeclinedHelp(String inviter) {
    return 'இது தவறுதலாக நடந்திருந்தால் $inviter-ஐ மீண்டும் முயற்சிக்கச் சொல்லுங்கள்.';
  }

  @override
  String errVersion(String inviter) {
    return '$inviter-ன் இல்லம் வேறு பதிப்பில் உள்ளது. Play Store-ல் இரு செயலிகளையும் புதுப்பித்து, மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String get errCopy => 'நகலெடுப்பு தடைபட்டது';

  @override
  String setupBanner(int pct) {
    return 'அமைப்பு முடிகிறது… $pct% — குடும்ப ஃபோன் ஒன்றில் இல்லத்தைத் திறந்து வைத்திருக்கவும்';
  }

  @override
  String get agoNow => 'இப்போது';

  @override
  String agoMinutes(int m) {
    return '$m நிமி முன்பு';
  }

  @override
  String agoHours(int h) {
    return '$h மணி முன்பு';
  }

  @override
  String agoDays(int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d நாட்கள் முன்பு',
      one: '1 நாள் முன்பு',
    );
    return '$_temp0';
  }

  @override
  String get syncTagOnlyThisPhone => 'இந்த ஃபோனில் மட்டும்';

  @override
  String syncTagJustNow(String name) {
    return '$name உடன் சற்று முன் ஒத்திசைத்தது';
  }

  @override
  String syncTagLast(String ago) {
    return 'கடைசி ஒத்திசைவு $ago';
  }

  @override
  String syncTagLabel(String text) {
    return '$text. ஒத்திசைவு விவரங்களைத் திற';
  }

  @override
  String get syncNotYet => 'இன்னும் ஒத்திசைக்கவில்லை';

  @override
  String get todayOffline => 'ஆஃப்லைன் — மாற்றங்கள் ஒத்திசைக்கும்';

  @override
  String get syncCardAllInSync => 'எல்லா ஃபோன்களும் ஒத்திசைவில் உள்ளன';

  @override
  String syncCardBehind(int k) {
    String _temp0 = intl.Intl.pluralLogic(
      k,
      locale: localeName,
      other: '$k ஃபோன்கள் புதுப்பிக்கப்படவில்லை',
      one: '1 ஃபோன் புதுப்பிக்கப்படவில்லை',
    );
    return '$_temp0';
  }

  @override
  String syncCardLastSynced(String ago) {
    return 'கடைசி ஒத்திசைவு $ago';
  }

  @override
  String get syncNow => 'இப்போது ஒத்திசை';

  @override
  String get syncing => 'ஒத்திசைக்கிறது…';

  @override
  String get syncedSnack =>
      'இப்போது தொடர்பிலுள்ள ஃபோன்களுடன் ஒத்திசைக்கப்பட்டது';

  @override
  String get syncNoPeers => 'குடும்ப ஃபோன்கள் எதுவும் இப்போது தொடர்பில் இல்லை';

  @override
  String syncRowTheirs(String name, String model) {
    return '$name-ன் $model';
  }

  @override
  String get syncOnWifiNow => 'இப்போது இந்த Wi-Fi-ல்';

  @override
  String syncSyncedAgo(String ago) {
    return 'ஒத்திசைத்தது $ago';
  }

  @override
  String syncNotForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n நாட்களாக ஒத்திசைக்கவில்லை',
      one: '1 நாளாக ஒத்திசைக்கவில்லை',
    );
    return '$_temp0';
  }

  @override
  String syncMissing(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ' · உங்கள் $n மாற்றங்கள் சேரவில்லை',
      one: ' · உங்கள் 1 மாற்றம் சேரவில்லை',
    );
    return '$_temp0';
  }

  @override
  String get syncClockWrong =>
      'உங்கள் ஃபோனின் கடிகாரம் தவறாகத் தெரிகிறது — ஒத்திசைவு பாதிக்கப்படலாம்';

  @override
  String get syncWifiBlocked =>
      'உங்கள் Wi-Fi ஃபோன்கள் ஒன்றையொன்று பார்ப்பதைத் தடுக்கலாம் — பதிலாக இணையம் வழியாக ஒத்திசைக்கிறது.';

  @override
  String syncUpdateNeeded(String name) {
    return '$name உடன் தொடர்ந்து ஒத்திசைக்க இல்லத்தைப் புதுப்பிக்கவும்';
  }

  @override
  String get profileInSync => '✓ ஒத்திசைவில்';

  @override
  String profileOneBehind(String name) {
    return '$name-ன் ஃபோன் பின்தங்கியுள்ளது';
  }

  @override
  String profileManyBehind(int n) {
    return '$n ஃபோன்கள் பின்தங்கியுள்ளன';
  }

  @override
  String get notifOutOfSync =>
      'உங்கள் குடும்பத்துடன் இல்லம் 3 நாட்களாக ஒத்திசைக்கவில்லை. தகவல்களைப் பெற ஒரே Wi-Fi-ல் திறக்கவும்.';

  @override
  String get notifTodoAssignedTitle => 'உங்களுக்குப் பணி ஒதுக்கப்பட்டது';

  @override
  String notifTodoAssignedBody(String title, String name) {
    return '$title · $name அனுப்பியது';
  }

  @override
  String get notifTodoDoneTitle => 'பணி முடிந்தது எனக் குறிக்கப்பட்டது';

  @override
  String notifTodoDoneBody(String title, String name) {
    return '$title · $name முடித்ததாகக் குறித்தார்';
  }

  @override
  String notifJoinedTitle(String name, String home) {
    return '$home-ல் $name இணைந்தார்';
  }

  @override
  String get notifJoinedBody =>
      'அவர்களின் ஃபோன் இப்போது இந்த வீட்டுடன் ஒத்திசைக்கிறது.';

  @override
  String syncLabPort(int port) {
    return '$port போர்ட்டில் கேட்கிறது';
  }

  @override
  String get syncLabPeers => 'இணை சாதனங்கள்';

  @override
  String get syncLabVector => 'என் பதிப்பு வெக்டர்';

  @override
  String get syncLabConnectLocal => '127.0.0.1 உடன் இணை';

  @override
  String homeGoneRemoved(String home) {
    return 'நீங்கள் இனி $home-ல் இல்லை';
  }

  @override
  String homeGoneDeleted(String home, String name) {
    return '$home-ஐ $name நீக்கிவிட்டார்';
  }

  @override
  String get homeGoneOk => 'சரி';

  @override
  String memberRemovedNewKey(String name) {
    return '$name நீக்கப்பட்டார் · புதிய வீட்டுத் திறவுகோல் மற்றவர்களுக்குப் பகிரப்பட்டது';
  }

  @override
  String leaveChooseAdminLead(String home) {
    return 'நீங்கள் மட்டுமே நிர்வாகி. நீங்கள் வெளியேறிய பின் $home-ஐப் பார்த்துக்கொள்ள ஒருவரைத் தேர்ந்தெடுக்கவும்.';
  }

  @override
  String get leaveWaiting =>
      'வெளியேறுகிறது… குடும்ப ஃபோனுக்குக் காத்திருக்கிறது';

  @override
  String get leaveRemoveNow =>
      'இந்த ஃபோனிலிருந்து இப்போது நீக்கு — அடுத்து உங்கள் குடும்ப ஃபோனை இது தொடர்பு கொள்ளும்போது அவர்களுக்குத் தெரியப்படுத்தப்படும்';

  @override
  String deleteDone(String home) {
    return '$home நீக்கப்பட்டது. மற்ற ஃபோன்கள் ஒத்திசைக்கும்போது அதை அழித்துவிடும்.';
  }

  @override
  String get opIgnoredRoleChanged =>
      'முதலில் யாரோ உங்கள் பொறுப்பை மாற்றிவிட்டார்கள்.';

  @override
  String get inviteTipSecondAdmin =>
      'குறிப்பு: இரண்டாவது நிர்வாகியையும் நியமித்து வையுங்கள்; அப்போதுதான் வீடு நிர்வாகி இல்லாமல் சிக்கிக்கொள்ளாது.';

  @override
  String inviteBackupNow(String home) {
    return '$home-ஐ இப்போது காப்புப்பிரதி எடு';
  }

  @override
  String backupHealthOk(Object ago, Object provider, Object name) {
    return '$ago $provider-ல் காப்புப்பிரதி · $name';
  }

  @override
  String get backupOnlyOnPhone => 'இந்த ஃபோனில் மட்டும் — வேறொரு இடத்தைச் சேர்';

  @override
  String get backupNoRecoveryReady => 'மீட்கத் தயாரான காப்புப்பிரதி இல்லை';

  @override
  String backupNoBackupDays(int n) {
    return '$n நாட்களாகக் காப்புப்பிரதி இல்லை';
  }

  @override
  String backupThisPhoneOn(Object provider) {
    return 'இந்த ஃபோனிலிருந்து காப்புப்பிரதி எடுக்கிறது · $provider';
  }

  @override
  String backupAlso(Object name, Object provider, Object ago) {
    return 'மேலும்: $name $provider-ல் காப்புப்பிரதி எடுக்கிறார் ($ago)';
  }

  @override
  String get backupNoAdminHint =>
      'எந்த நிர்வாகியிடமும் இன்னும் காப்புப்பிரதி இல்லை — எல்லா நிர்வாகி ஃபோன்களும் தொலைந்தால், மீட்டெடுக்கும்போது அனைவரும் உறுப்பினர்களாகவே திரும்புவார்கள்.';

  @override
  String get backupProviderFolderShort => 'ஒரு கோப்புறை';

  @override
  String get backupJustNow => 'சற்று முன்';

  @override
  String backupAttention(Object reason) {
    return 'காப்புப்பிரதியில் கவனம் தேவை — $reason';
  }

  @override
  String backupReasonAuth(Object provider) {
    return 'காப்புப்பிரதிகள் தொடர $provider-ல் மீண்டும் உள்நுழையவும்.';
  }

  @override
  String backupReasonFull(Object provider) {
    return '$provider நிறைந்துவிட்டது — இடத்தைக் காலி செய்யவும் அல்லது வேறொரு இடத்தைத் தேர்ந்தெடுக்கவும்.';
  }

  @override
  String get backupErrNoPermission => 'அந்தக் கோப்புறையில் எழுத அனுமதி இல்லை';

  @override
  String backupStatusStale(int n) {
    return '$n நாட்களாகக் காப்புப்பிரதி எடுக்கப்படவில்லை';
  }

  @override
  String get backupTitle => 'காப்புப்பிரதி';

  @override
  String backupProfileRow(Object provider, Object frequency, Object ago) {
    return 'காப்புப்பிரதி — $provider · $frequency · கடைசி $ago';
  }

  @override
  String get backupProfileNotSetUp => 'காப்புப்பிரதி — அமைக்கப்படவில்லை';

  @override
  String get backupDaily => 'தினமும்';

  @override
  String get backupWeekly => 'வாரம் ஒருமுறை';

  @override
  String get backupMonthly => 'மாதம் ஒருமுறை';

  @override
  String get notifBackupAttention => 'காப்புப்பிரதியில் கவனம் தேவை';

  @override
  String get notifBackupAttentionSub =>
      'காப்புப்பிரதி வேலை செய்வது நின்றால் மட்டும்';

  @override
  String backupHeroTitle(Object home) {
    return '$home-ஐப் பாதுகாப்பாக வைத்திருங்கள்';
  }

  @override
  String get backupHeroLead =>
      'இல்லத்திற்குச் சொந்த கிளவுட் இல்லை. வீட்டில் உள்ள எல்லா ஃபோன்களும் தொலைந்து போனால், காப்புப்பிரதி மட்டுமே தகவல்களைத் திரும்பப் பெறும் ஒரே வழி.';

  @override
  String get backupPromise1Title =>
      'இந்த ஃபோனிலிருந்து செல்லும் முன்பே பூட்டப்படும்';

  @override
  String get backupPromise1 =>
      'உங்களுக்கு மட்டுமே தெரிந்த கடவுச்சொல்லால் மறைகுறியாக்கப்படும். உங்கள் கிளவுடில் பூட்டப்பட்ட ஒரு கோப்பு மட்டுமே தெரியும்.';

  @override
  String get backupPromise2Title => 'தானாகவே இயங்கும்';

  @override
  String get backupPromise2 =>
      'ஒவ்வொரு வாரமும் Wi-Fi-இல் சார்ஜ் செய்யும்போது இயங்கும். அது வேலை செய்வதை நிறுத்தினால் மட்டுமே உங்களுக்குத் தெரிவிப்போம்.';

  @override
  String get backupPromise3Title => 'அனைத்தையும் மீட்டெடுக்கும்';

  @override
  String get backupPromise3 =>
      'பட்டியல்கள், பணியாளர்கள், வருகைப் பதிவு, சம்பளம், உணவுகள் மற்றும் செலவுகள் ஆகியவற்றுடன் உங்கள் மீட்புச் சாவியும் இருக்கும்; எனவே புதிய தொலைபேசியில் இப்போதுள்ள அதே பொறுப்புடன் மீண்டும் இணையலாம்.';

  @override
  String get backupWhere => 'காப்புப் பிரதிகள் எங்கே சேமிக்கப்பட வேண்டும்?';

  @override
  String get backupGroupSignIn => 'உள்நுழைவு';

  @override
  String get backupGroupServer => 'உங்கள் சொந்த சர்வர்';

  @override
  String get backupGroupDevice => 'இந்தத் தொலைபேசியில்';

  @override
  String get backupDontSee => 'உங்களுடையது தெரியவில்லையா?';

  @override
  String get backupDontSeeBody =>
      'உங்களுடையது தெரியவில்லையா? Proton Drive மற்றும் MEGA பின்னர் வரும். Android ஆப்களிலிருந்து iCloud, Box, Terabox மற்றும் JioCloud ஆகியவற்றை இணைக்க முடியாது — உங்கள் வழங்குநர் வழங்கினால் WebDAV-ஐப் பயன்படுத்துங்கள், அல்லது இந்தத் தொலைபேசியில் ஒரு கோப்புறையைத் தேர்ந்தெடுங்கள்.';

  @override
  String backupAlsoIn(Object home, Object name, Object provider, Object ago) {
    return '$home-இலும்: $name $provider-இல் காப்புப் பிரதி எடுக்கிறார் ($ago).';
  }

  @override
  String get backupArrivesP19 => 'P19-இல் வரும்';

  @override
  String get backupArrivesP20 => 'P20-இல் வரும்';

  @override
  String get backupProvFolder =>
      'இந்தத் தொலைபேசி அல்லது வேறொரு ஆப்பின் கோப்புறை';

  @override
  String get backupProvFolderSub =>
      'SD கார்டு, USB டிரைவ் அல்லது கோப்புறைகளை வழங்கும் கிளவுட் ஆப்';

  @override
  String get backupProvGdrive => 'Google Drive';

  @override
  String get backupProvGdriveSub =>
      'உள்நுழைவு · உங்கள் Drive-இல் மறைக்கப்பட்ட ஆப் கோப்புறை';

  @override
  String get backupProvOnedrive => 'OneDrive';

  @override
  String get backupProvOnedriveSub => 'உள்நுழைவு · Apps › இல்லம்';

  @override
  String get backupProvDropbox => 'Dropbox';

  @override
  String get backupProvDropboxSub => 'உள்நுழைவு · Apps › இல்லம்';

  @override
  String get backupProvPcloud => 'pCloud';

  @override
  String get backupProvPcloudSub =>
      'உள்நுழைவு · ஆப் கோப்புறை · EU அல்லது US பகுதி';

  @override
  String get backupProvNextcloud => 'Nextcloud';

  @override
  String get backupProvNextcloudSub =>
      'உங்கள் சொந்த அல்லது ஹோஸ்ட் செய்யப்பட்ட Nextcloud';

  @override
  String get backupProvWebdav => 'WebDAV';

  @override
  String get backupProvWebdavSub =>
      'ownCloud, Synology, QNAP, Koofr, Yandex Disk, எந்த WebDAV-உம்';

  @override
  String get backupProvS3 => 'S3-இணக்க சேவை';

  @override
  String get backupProvS3Sub =>
      'AWS S3, Backblaze B2, Wasabi, Cloudflare R2, MinIO';

  @override
  String get backupProvSftp => 'SFTP';

  @override
  String get backupProvSftpSub => 'வீட்டு NAS அல்லது உங்கள் சொந்த சர்வர்';

  @override
  String get backupChecking => 'சோதிக்கிறது… சோதனைக் கோப்பு எழுதப்பட்டது';

  @override
  String get backupErrUnreachable => 'அந்த சர்வரைத் தொடர்புகொள்ள முடியவில்லை';

  @override
  String get backupLocalCopy =>
      'உள்ளூர் நகல் — தொலைபேசியுடன் சேர்ந்து இழக்கப்படும்';

  @override
  String get backupPwTitle => 'காப்புப் பிரதி கடவுச்சொல்லை அமைக்கவும்';

  @override
  String get backupPwField => 'காப்புப் பிரதி கடவுச்சொல்';

  @override
  String get backupPwConfirm => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get backupPwTooShort => 'மிகக் குறுகியது';

  @override
  String get backupPwOkay => 'பரவாயில்லை';

  @override
  String get backupPwStrong => 'வலுவானது';

  @override
  String get backupPwSuggest => 'பரிந்துரை செய்';

  @override
  String get backupPwWarning =>
      'இந்தக் கடவுச்சொல்லை எங்களால் மீட்டமைக்க முடியாது. இது இல்லாமல் காப்புப் பிரதிகளைத் திறக்க முடியாது. உங்கள் கடவுச்சொல் மேலாளரில் சேமிக்கவும் அல்லது எழுதி வைக்கவும்.';

  @override
  String get backupPwSaved =>
      'இந்தக் கடவுச்சொல்லை பாதுகாப்பான இடத்தில் சேமித்துவிட்டேன்';

  @override
  String get backupPwSave => 'சேமித்து காப்புப் பிரதி எடு';

  @override
  String get backupPwMismatch => 'இரண்டு கடவுச்சொற்களும் பொருந்தவில்லை.';

  @override
  String get backupPwMissing =>
      'இன்னும் எதுவும் காப்புப் பிரதி எடுக்கப்படவில்லை. தொடங்க காப்புப் பிரதி கடவுச்சொல்லை அமைக்கவும்.';

  @override
  String backupStatusOk(Object ago) {
    return '$ago காப்புப் பிரதி எடுக்கப்பட்டது';
  }

  @override
  String backupStatusRunning(int pct) {
    return 'காப்புப் பிரதி எடுக்கிறது… $pct%';
  }

  @override
  String backupStatusFailed(Object reason) {
    return 'கடைசி காப்புப் பிரதி தோல்வி — $reason';
  }

  @override
  String get backupStatusUnchanged =>
      'கடைசி காப்புப் பிரதிக்குப் பிறகு மாற்றங்கள் இல்லை';

  @override
  String backupNext(Object when, Object conditions) {
    return 'அடுத்து: $when · $conditions';
  }

  @override
  String get backupOnWifi => 'Wi-Fi-இல்';

  @override
  String get backupWhileCharging => 'சார்ஜ் செய்யும்போது';

  @override
  String get backupNow => 'இப்போது காப்புப் பிரதி எடு';

  @override
  String get backupWhereGo => 'காப்புப் பிரதிகள் சேமிக்கப்படும் இடங்கள்';

  @override
  String backupPlacesCount(int k) {
    return '3-இல் $k';
  }

  @override
  String backupDestLast(Object ago, int k) {
    return 'கடைசி: $ago · $k உள்ளன';
  }

  @override
  String get backupDisconnect => 'துண்டி';

  @override
  String get backupStayThere =>
      'அங்கு ஏற்கனவே உள்ள காப்புப் பிரதிகள் அங்கேயே இருக்கும்.';

  @override
  String get backupAddPlace => '＋ வேறொரு இடத்தைச் சேர்';

  @override
  String get backupSchedule => 'அட்டவணை';

  @override
  String get backupHowOften => 'எவ்வளவு அடிக்கடி';

  @override
  String get backupWifiOnly => 'Wi-Fi-இல் மட்டும்';

  @override
  String get backupWifiOnlySub => 'மொபைல் டேட்டாவை ஒருபோதும் பயன்படுத்தாது';

  @override
  String get backupCharging => 'சார்ஜ் செய்யும்போது மட்டும்';

  @override
  String get backupChargingSub => 'பொதுவாக இரவில்';

  @override
  String get backupKeep => 'மிகச் சமீபத்தியவற்றை வைத்திரு';

  @override
  String backupKeepN(int n) {
    return '$n காப்புப் பிரதிகள்';
  }

  @override
  String get backupKeepSub =>
      'வெற்றிகரமான காப்புப் பிரதிக்குப் பிறகு பழையவை அந்த இடத்திலிருந்து நீக்கப்படும்.';

  @override
  String backupProgressNotif(Object home) {
    return '$home காப்புப் பிரதி எடுக்கப்படுகிறது…';
  }

  @override
  String get backupLocalTag => 'உள்ளூர் நகல்';

  @override
  String get backupPwRow => 'காப்புப் பிரதி கடவுச்சொல்';

  @override
  String backupPwRowSub(Object date) {
    return 'அமைக்கப்பட்டது: $date · இந்தத் தொலைபேசியில் சேமிக்கப்பட்டது';
  }

  @override
  String get backupPwChangeTitle => 'காப்புப் பிரதி கடவுச்சொல்லை மாற்று';

  @override
  String get backupPwChangeNote =>
      'புதிய காப்புப் பிரதிகள் புதிய கடவுச்சொல்லைப் பயன்படுத்தும். பழைய காப்புப் பிரதிகளுக்குப் பழைய கடவுச்சொல்லே தேவை.';

  @override
  String get backupPwChangeSave => 'புதிய கடவுச்சொல்லைச் சேமி';

  @override
  String get backupCheck => 'காப்புப் பிரதியைச் சோதி';

  @override
  String get backupCheckSub =>
      'சரியாக வேலை செய்கிறதா என உறுதிப்படுத்த சமீபத்திய காப்புப் பிரதியைத் திறக்கும்';

  @override
  String backupCheckOk(int n, Object size) {
    return 'சமீபத்திய காப்புப் பிரதி சரியாகத் திறக்கிறது · $n உருப்படிகள் · $size';
  }

  @override
  String get backupDamaged =>
      'இந்தக் காப்புப் பிரதி சேதமடைந்துள்ளது — பழையதை முயற்சிக்கவும்.';

  @override
  String get backupCheckUnreachable =>
      'காப்புப் பிரதி இடத்தைத் தொடர்புகொள்ள முடியவில்லை — பின்னர் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get backupRecent => 'சமீபத்திய காப்புப் பிரதிகள்';

  @override
  String backupRecentRow(Object ago, Object size, Object place) {
    return '$ago · $size · $place';
  }

  @override
  String get backupRecentEmpty => 'இன்னும் காப்புப் பிரதிகள் இல்லை.';

  @override
  String get backupKits => 'மீட்புச் சாவிகள்';

  @override
  String backupKitRow(Object name, Object model) {
    return '$name-இன் $model';
  }

  @override
  String get backupKitThisPhone => 'இந்தத் தொலைபேசி';

  @override
  String backupKitSub(Object date, Object name, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'நிர்வாகியாக',
      'other': 'உறுப்பினராக',
    });
    return 'உருவாக்கப்பட்டது: $date · $name-ஐ $_temp0 மீட்டெடுக்கும்';
  }

  @override
  String get backupKitTurnOff => 'முடக்கு';

  @override
  String backupKitOffTitle(Object name) {
    return '$name-இன் மீட்புச் சாவியை முடக்கவா?';
  }

  @override
  String backupKitOffLead(Object name, Object home) {
    return 'இதைக் கொண்டு எடுத்த காப்புப் பிரதிகளைத் திறக்க முடியும், ஆனால் தனி நகலாக மட்டுமே — அவற்றால் $name-ஐ மீண்டும் $home-க்குள் கொண்டு வர முடியாது. $name-இன் தொலைபேசி அடுத்த காப்புப் பிரதியில் புதிய சாவியை உருவாக்கும்.';
  }

  @override
  String get backupKitKeep => 'வைத்திரு';

  @override
  String get backupKitDead =>
      'புதிய காப்புப் பிரதி எடுக்கவும் — பழைய மீட்புச் சாவி இனி வேலை செய்யாது.';

  @override
  String backupFinePrint(Object home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'நிர்வாகியாக',
      'other': 'உறுப்பினராக',
    });
    return 'காப்புப் பிரதிகளில் உங்கள் மீட்புச் சாவியும் அடங்கும். கோப்பும் கடவுச்சொல்லும் உள்ள எவரும் $home-ஐ $_temp0 மீட்டெடுக்க முடியும் — கடவுச்சொல்லை ரகசியமாக வைத்திருங்கள்.';
  }

  @override
  String get debugDamageBackup => 'Write a damaged copy of the latest backup';

  @override
  String get debugFolderOffPhone => 'Count folders as off-phone';

  @override
  String get restoreTitle => 'காப்புப் பிரதியிலிருந்து மீட்டெடு';

  @override
  String get restoreSub =>
      'உங்கள் காப்புப் பிரதி எங்கே உள்ளது என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get restoreNote =>
      '🔒 உங்கள் காப்புப் பிரதி இந்தத் தொலைபேசியிலேயே திறக்கப்படுகிறது. இல்லத்திற்கு எதுவும் அனுப்பப்படாது.';

  @override
  String get restorePickTitle => 'ஒரு காப்புப் பிரதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String restoreFoundIn(Object provider, Object account) {
    return '$provider-இல் கண்டறியப்பட்டது · $account';
  }

  @override
  String restoreVault(Object vault) {
    return 'வீட்டுக் காப்புப் பிரதி · $vault';
  }

  @override
  String restoreRow(Object date, Object size) {
    return '$date · $size';
  }

  @override
  String get restoreTagKit => 'மீட்புச் சாவி';

  @override
  String get restoreTagData => 'தரவு மட்டும்';

  @override
  String restoreOlder(int n) {
    return 'பழைய காப்புப் பிரதிகள் ($n)';
  }

  @override
  String get restoreEmpty =>
      'இங்கே இல்லம் காப்புப் பிரதிகள் எதுவும் இல்லை — சரியான கணக்கு அல்லது கோப்புறையைத் தேர்ந்தெடுத்தீர்களா எனச் சரிபார்க்கவும்.';

  @override
  String get restoreChooseAnother => 'வேறொரு இடத்தைத் தேர்ந்தெடு';

  @override
  String get restoreUnlockTitle => 'இந்தக் காப்புப் பிரதியைத் திறக்கவும்';

  @override
  String get restoreUnlocking => 'திறக்கிறது…';

  @override
  String get restoreWrongPw =>
      'தவறான கடவுச்சொல் — கடவுச்சொற்கள் எழுத்து வடிவ உணர்திறன் (case-sensitive) கொண்டவை.';

  @override
  String restoreHeaderCard(
    Object home,
    Object homeId,
    Object date,
    Object model,
    Object name,
  ) {
    return '$home · $homeId · $date · $model ($name) இலிருந்து';
  }

  @override
  String get restoreStepDownload => 'பதிவிறக்குகிறது';

  @override
  String get restoreStepUnlock => 'திறக்கிறது';

  @override
  String get restoreStepCheck => 'வீட்டின் வரலாற்றைச் சரிபார்க்கிறது';

  @override
  String get restoreStepSetup => 'இந்தத் தொலைபேசியை அமைக்கிறது';

  @override
  String restoreWelcome(Object home) {
    return '$home-க்கு மீண்டும் வருக';
  }

  @override
  String restoreOthersNote(Object home) {
    return '$home-இல் இன்னும் உள்ள தொலைபேசிகளில் நீங்கள் புதிய தொலைபேசியில் மீட்டெடுத்ததைக் காட்டும்.';
  }

  @override
  String restoreKeepBackingUp(Object provider) {
    return '$provider-க்குத் தொடர்ந்து காப்புப் பிரதி எடு';
  }

  @override
  String restoreGo(Object home) {
    return '$home-க்குச் செல்';
  }

  @override
  String restoreAlreadyHere(Object home) {
    return '$home ஏற்கனவே இந்தத் தொலைபேசியில் உள்ளது.';
  }

  @override
  String get restoreOpen => 'திற';

  @override
  String get restoreDownloadFail =>
      'பதிவிறக்க முடியவில்லை — உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String restoreBanner(Object date, Object home) {
    return '$date அன்று எடுத்த காப்புப் பிரதியிலிருந்து மீட்டெடுக்கப்பட்டது. $home-இன் மற்ற பகுதிகளுடன் இணைகிறது…';
  }

  @override
  String restoreDeadKit(Object date, Object home) {
    return 'இந்தக் காப்புப் பிரதியின் மீட்புச் சாவி $date அன்று முடக்கப்பட்டது. உங்களை அழைக்குமாறு $home-இல் உள்ள நிர்வாகியிடம் கேளுங்கள்.';
  }

  @override
  String get restoreSeparateCopy => 'தனி நகலாக வைத்திரு';

  @override
  String get restoreRemoveFromPhone => 'இந்தத் தொலைபேசியிலிருந்து நீக்கு';

  @override
  String restoreSeparateName(Object home, Object date) {
    return '$home (மீட்டெடுக்கப்பட்டது $date)';
  }

  @override
  String restoreOtherAdmin(Object name, Object home) {
    return '$name காப்புப் பிரதியிலிருந்து புதிய தொலைபேசியில் $home-ஐ மீட்டெடுத்தார்';
  }

  @override
  String get restoreKeep => 'வைத்திரு';

  @override
  String get restoreRemove => 'நீக்கு';

  @override
  String get bkSrvErrAuth => 'தவறான பயனர்பெயர் அல்லது ஆப் கடவுச்சொல்';

  @override
  String get bkSrvErrBucket => 'பக்கெட் (Bucket) கிடைக்கவில்லை';

  @override
  String get bkSrvErrOther =>
      'அது வேலை செய்யவில்லை — விவரங்களைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get bkSrvErrHttps =>
      'https:// உடன் தொடங்கும் முகவரியைப் பயன்படுத்தவும்';

  @override
  String get bkSrvErrHostKeyChanged =>
      'இந்த சர்வரின் கைரேகை (fingerprint) மாறியுள்ளது. நீங்கள் சர்வரை மாற்றவில்லை என்றால், இணைக்க வேண்டாம்.';

  @override
  String get bkSrvConnect => 'இணை';

  @override
  String get bkSrvTrustTitle => 'இந்த சர்வரை நம்பலாமா?';

  @override
  String bkSrvTrustLead(Object host) {
    return '$host உடன் முதல் முறையாக இணைக்கிறீர்கள். இந்தக் கைரேகை உங்கள் சர்வரில் உள்ளதோடு பொருந்துகிறதா எனச் சரிபார்க்கவும்.';
  }

  @override
  String get bkSrvTrust => 'நம்பு';

  @override
  String get bkSrvWebdavTitle => 'WebDAV';

  @override
  String get bkSrvServerAddress => 'சர்வர் முகவரி';

  @override
  String get bkSrvUsername => 'பயனர்பெயர்';

  @override
  String get bkSrvAppPassword => 'ஆப் கடவுச்சொல்';

  @override
  String get bkSrvWebdavHint =>
      'ownCloud, Synology, QNAP, Koofr, Yandex Disk, pCloud மற்றும் எந்த WebDAV சர்வருடனும் வேலை செய்யும். உங்கள் முதன்மைக் கடவுச்சொல்லுக்குப் பதிலாக ஆப் கடவுச்சொல்லைப் பயன்படுத்தவும்.';

  @override
  String bkSrvAccount(Object user, Object host) {
    return '$user @ $host';
  }

  @override
  String get bkSrvNextcloudTitle => 'Nextcloud';

  @override
  String get bkSrvNextcloudHint =>
      'உங்கள் Nextcloud உள்நுழைவை உலாவியில் திறப்போம். அங்கே இல்லத்திற்கு அனுமதி அளிக்கவும் — எப்போது வேண்டுமானாலும் திரும்பப் பெறக்கூடிய தனியான ஆப் கடவுச்சொல்லை அது பெறும்.';

  @override
  String get bkSrvNextcloudAccessNote =>
      'இந்த ஆப் கடவுச்சொல் உங்கள் முழு Nextcloud கணக்கையும் அணுக முடியும். காப்புப் பிரதிகளுக்காக மட்டும் தனியான Nextcloud பயனரை வைத்திருப்பது பாதுகாப்பானது.';

  @override
  String get bkSrvContinueInBrowser => 'உலாவியில் தொடர்';

  @override
  String get bkSrvOpeningLogin => 'உங்கள் Nextcloud உள்நுழைவைத் திறக்கிறது…';

  @override
  String get bkSrvApproveTitle => 'உங்கள் உலாவியில் அனுமதிக்கவும்';

  @override
  String bkSrvApproveLead(Object host) {
    return '$host-இல் உள்நுழைந்து இல்லத்திற்கு அணுகல் வழங்கு (Grant access) என்பதைத் தட்டவும். பிறகு இங்கே திரும்பி வரவும்.';
  }

  @override
  String get bkSrvWaitingApproval => 'அனுமதிக்காகக் காத்திருக்கிறது…';

  @override
  String get bkSrvS3Title => 'S3-இணக்க சேவை';

  @override
  String get bkSrvService => 'சேவை';

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
  String get bkSrvPresetOther => 'மற்றவை';

  @override
  String get bkSrvRegion => 'பகுதி (Region)';

  @override
  String get bkSrvEndpoint => 'முனையம் (Endpoint)';

  @override
  String get bkSrvBucket => 'பக்கெட் (Bucket)';

  @override
  String get bkSrvAccessKeyId => 'அணுகல் சாவி ID';

  @override
  String get bkSrvSecretKey => 'ரகசிய அணுகல் சாவி';

  @override
  String get bkSrvS3Hint =>
      'இந்தப் பக்கெட்டில் மட்டுமே எழுதக்கூடிய சாவியை உருவாக்கவும். கோப்புகள் illam/ என்பதன் கீழ் சேமிக்கப்படும்.';

  @override
  String bkSrvS3Account(Object bucket, Object service) {
    return '$bucket · $service';
  }

  @override
  String get bkSrvSftpTitle => 'SFTP';

  @override
  String get bkSrvHost => 'ஹோஸ்ட் (Host)';

  @override
  String get bkSrvPort => 'போர்ட் (Port)';

  @override
  String get bkSrvPassword => 'கடவுச்சொல்';

  @override
  String get bkSrvFolder => 'கோப்புறை';

  @override
  String get bkSrvSignInWith => 'உள்நுழையும் முறை';

  @override
  String get bkSrvAuthPassword => 'கடவுச்சொல்';

  @override
  String get bkSrvAuthKey => 'இந்தத் தொலைபேசியில் உருவாக்கிய சாவி';

  @override
  String get bkSrvKeyHint =>
      'இந்தப் பயனருக்கான சர்வரின் authorized_keys கோப்பில் இந்தச் சாவியைச் சேர்த்து, பிறகு இணை என்பதைத் தட்டவும்.';

  @override
  String get bkSrvCopyKey => 'சாவியை நகலெடு';

  @override
  String get bkSrvKeyCopied => 'சாவி நகலெடுக்கப்பட்டது';

  @override
  String get bkSrvSftpAccessNote =>
      'குறிப்பு: தன் சொந்தக் கோப்புறையை மட்டுமே பார்க்கக்கூடிய சர்வர் பயனர் பாதுகாப்பானது.';

  @override
  String bkSrvSftpAccount(Object user, Object host, Object port) {
    return '$user@$host:$port';
  }

  @override
  String get bkSrvSignInAgain => 'மீண்டும் உள்நுழை';

  @override
  String get bkCloudGdriveAccess =>
      'உங்கள் Google Drive-இல் உள்ள மறைக்கப்பட்ட ஆப் கோப்புறையில் தன் சொந்தத் தரவைப் பார்க்கவும், உருவாக்கவும், நீக்கவும் மட்டுமே முடியும். உங்கள் மற்ற கோப்புகளைப் பார்க்க முடியாது.';

  @override
  String get bkCloudGdriveWhere => 'உங்கள் Drive-இல் மறைக்கப்பட்ட ஆப் கோப்புறை';

  @override
  String bkCloudConnected(Object provider) {
    return '$provider உடன் இணைக்கப்பட்டது';
  }

  @override
  String bkCloudSignedInAgain(Object provider) {
    return '$provider-இல் மீண்டும் உள்நுழையப்பட்டது';
  }

  @override
  String get bkCloudSignInAgainSub =>
      'உள்நுழைவு காலாவதியானதாகக் காப்புப் பிரதிகள் கூறினால் இதைப் பயன்படுத்தவும்';

  @override
  String get bkCloudExpiredRow => 'உள்நுழைவு காலாவதியானது — மீண்டும் உள்நுழைக';

  @override
  String bkCloudNotConfigured(Object provider) {
    return 'இந்த ஆப் பதிப்பு இன்னும் $provider-க்கு அமைக்கப்படவில்லை.';
  }

  @override
  String bkCloudSignInFailed(Object provider) {
    return '$provider-இல் உள்நுழைய முடியவில்லை — மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String get bkCloudDropboxAccess =>
      'Apps › இல்லம் கோப்புறையில் மட்டுமே கோப்புகளைப் படிக்கவும் எழுதவும் முடியும். உங்கள் மற்ற கோப்புகளைப் பார்க்க முடியாது.';

  @override
  String get bkCloudOnedriveAccess =>
      'Apps › இல்லம் என்ற தன் சொந்தக் கோப்புறையில் மட்டுமே கோப்புகளைப் படிக்கவும் எழுதவும் முடியும். உங்கள் மற்ற கோப்புகளைப் பார்க்க முடியாது.';

  @override
  String get bkCloudAppsFolder => 'Apps › இல்லம்';

  @override
  String get bkCloudOrgApproval =>
      'இந்த OneDrive-ஐப் பயன்படுத்தும் முன் உங்கள் நிறுவனம் இல்லத்திற்கு அனுமதி அளிக்க வேண்டும். உங்கள் IT நிர்வாகியிடம் கேளுங்கள் அல்லது வேறொரு இடத்தைத் தேர்ந்தெடுங்கள்.';

  @override
  String get bkCloudPcloudAccess =>
      'தன் சொந்த ஆப் கோப்புறையில் மட்டுமே கோப்புகளைப் படிக்கவும் எழுதவும் முடியும்.';

  @override
  String get bkCloudPcloudWhere => 'ஆப் கோப்புறை · EU அல்லது US பகுதி';

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
  String get remoteSyncTitle => 'தொலைநிலை ஒத்திசைவு';

  @override
  String get remoteSyncExperimental => 'சோதனை நிலை';

  @override
  String get remoteSyncToggleTitle => 'தொலைநிலை ஒத்திசைவு (சோதனை நிலை)';

  @override
  String get remoteSyncToggleSub =>
      'உங்கள் சொந்த Firebase திட்டம் வழியாக முனை-முதல்-முனை குறியாக்கம் செய்யப்பட்ட புதுப்பிப்புகளை அனுப்பவும்';

  @override
  String get remoteSyncOffTitle => 'உங்கள் சொந்த Firebase-ஐ இணைக்கவும்';

  @override
  String get remoteSyncOffBody =>
      'இயல்பாக, இல்லம் வீட்டு Wi-Fi-இல் மட்டுமே ஒத்திசைக்கும். குடும்பத் தொலைபேசிகள் மொபைல் டேட்டாவிலும் ஒத்திசைக்க, தொலைநிலை ஒத்திசைவை இயக்கி உங்கள் சொந்த இலவச Firebase திட்டத்தை இணைக்கவும் — டெவலப்பர் சர்வர்கள் இல்லாமலும் முனை-முதல்-முனை குறியாக்கத்துடனும்.';

  @override
  String get remoteSyncStatusTitle => 'Firebase ரிலே';

  @override
  String remoteSyncStatusConnected(Object projectId) {
    return 'இணைக்கப்பட்டது · $projectId';
  }

  @override
  String remoteSyncStatusLastSynced(Object ago) {
    return 'கடைசியாக ஒத்திசைக்கப்பட்டது: $ago';
  }

  @override
  String get remoteSyncStatusNever =>
      'இயக்கப்பட்டது · இன்னும் ஒத்திசைக்கப்படவில்லை';

  @override
  String get remoteSyncStatusNeedsSetup =>
      'இயக்கப்பட்டது · கீழே Firebase விவரங்களைச் சேர்க்கவும்';

  @override
  String get remoteSyncStatusOff => 'முடக்கப்பட்டது · வீட்டு Wi-Fi மட்டும்';

  @override
  String remoteSyncStatusError(Object projectId) {
    return 'கவனம் தேவை · $projectId';
  }

  @override
  String get remoteSyncSyncNow => 'இப்போது ஒத்திசை';

  @override
  String get remoteSyncSyncing => 'ஒத்திசைக்கிறது…';

  @override
  String remoteSyncSyncedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'தொலைநிலை ஒத்திசைவு புதுப்பிக்கப்பட்டது ($count உருப்படிகள்)',
      one: 'தொலைநிலை ஒத்திசைவு புதுப்பிக்கப்பட்டது (1 உருப்படி)',
    );
    return '$_temp0';
  }

  @override
  String get remoteSyncSyncedNone =>
      'தொலைநிலை ரிலே ஏற்கனவே புதுப்பிக்கப்பட்டுள்ளது';

  @override
  String get remoteSyncShareFamily => 'குடும்பத்துடன் பகிர்';

  @override
  String get remoteSyncGuideTitle =>
      'உங்கள் Firebase திட்டத்தை அமைப்பது எப்படி';

  @override
  String get remoteSyncGuideStep1 =>
      '1. console.firebase.google.com இல் இலவச Firebase திட்டத்தை உருவாக்கி, உங்கள் Project ID மற்றும் Web API key-ஐப் பார்க்க ஒரு Web app (</>) சேர்க்கவும்.';

  @override
  String get remoteSyncGuideStep2 =>
      '2. Authentication → Sign-in method என்பதன் கீழ் Anonymous உள்நுழைவை இயக்கவும்.';

  @override
  String get remoteSyncGuideStep3 =>
      '3. Firestore Database என்பதன் கீழ் ஒரு தரவுத்தளத்தை உருவாக்கி, Rules-ஐத் திறந்து இல்லத்தின் பாதுகாப்பு விதிகளை ஒட்டவும்.';

  @override
  String get remoteSyncGuideStep4 =>
      '4. உங்கள் அமைப்பைக் கீழே உள்ளிட்டு, இணைப்பைச் சோதித்து, குடும்பத் தொலைபேசிகளுடன் QR குறியீட்டைப் பகிரவும்.';

  @override
  String get remoteSyncCopyRules => 'பாதுகாப்பு விதிகளை நகலெடு';

  @override
  String get remoteSyncRulesCopied => 'பாதுகாப்பு விதிகள் நகலெடுக்கப்பட்டன';

  @override
  String get remoteSyncShowRules => 'பாதுகாப்பு விதிகளைப் பார்';

  @override
  String get remoteSyncHideRules => 'பாதுகாப்பு விதிகளை மறை';

  @override
  String get remoteSyncConfigTitle => 'Firebase அமைப்பு';

  @override
  String get remoteSyncConfigLead =>
      'உங்கள் திட்ட விவரங்களை உள்ளிடவும், அல்லது Firebase Console-இலிருந்து firebaseConfig பகுதியை ஒட்டவும்.';

  @override
  String get remoteSyncPasteConfig => 'அமைப்பை ஒட்டு';

  @override
  String get remoteSyncScanQr => 'QR ஸ்கேன்';

  @override
  String get remoteSyncPasteSheetTitle => 'Firebase அமைப்பை ஒட்டவும்';

  @override
  String get remoteSyncPasteSheetLead =>
      'firebaseConfig JS/JSON பகுதியை அல்லது இல்லம் தொலைநிலை ஒத்திசைவு இணைப்பை ஒட்டவும்.';

  @override
  String get remoteSyncPasteFieldLabel => 'அமைப்புப் பகுதி அல்லது இணைப்பு';

  @override
  String get remoteSyncApplyConfig => 'நிரப்பு';

  @override
  String get remoteSyncConfigApplied => 'Firebase புலங்கள் நிரப்பப்பட்டன';

  @override
  String get remoteSyncConfigNotFound =>
      'ஒட்டிய உரையில் projectId மற்றும் apiKey-ஐக் கண்டறிய முடியவில்லை';

  @override
  String get remoteSyncProjectIdLabel => 'Project ID';

  @override
  String get remoteSyncProjectIdHint => 'my-family-illam';

  @override
  String get remoteSyncApiKeyLabel => 'Web API key';

  @override
  String get remoteSyncApiKeyHint => 'AIzaSy...';

  @override
  String get remoteSyncShowApiKey => 'API key-ஐக் காட்டு';

  @override
  String get remoteSyncHideApiKey => 'API key-ஐ மறை';

  @override
  String get remoteSyncDatabaseIdLabel => 'Database ID (விருப்பத்திற்குரியது)';

  @override
  String get remoteSyncDatabaseIdHint => '(default)';

  @override
  String get remoteSyncErrProjectEmpty =>
      'உங்கள் Firebase Project ID-ஐ உள்ளிடவும்';

  @override
  String get remoteSyncErrProjectInvalid =>
      'ஆங்கில சிறிய எழுத்துகள், எண்கள் மற்றும் இடைக்கோடுகளைப் (-) பயன்படுத்தவும்';

  @override
  String get remoteSyncErrKeyEmpty =>
      'உங்கள் Firebase Web API key-ஐ உள்ளிடவும்';

  @override
  String get remoteSyncErrKeyInvalid =>
      'Web API key வடிவமைப்பைச் சரிபார்க்கவும்';

  @override
  String get remoteSyncErrDbInvalid =>
      '(default) என விடவும் அல்லது ஆங்கில சிறிய எழுத்துகள், எண்கள் மற்றும் இடைக்கோடுகளைப் (-) பயன்படுத்தவும்';

  @override
  String get remoteSyncTestBtn => 'இணைப்பைச் சோதி';

  @override
  String get remoteSyncTestingBtn => 'சோதிக்கிறது…';

  @override
  String get remoteSyncTestOk =>
      'இணைப்பு சரி — Anonymous Auth மற்றும் Firestore விதிகள் சரிபார்க்கப்பட்டன.';

  @override
  String get remoteSyncSaveBtn => 'சேமித்து இணை';

  @override
  String get remoteSyncSavingBtn => 'சேமிக்கிறது…';

  @override
  String get remoteSyncSavedSnack => 'Firebase அமைப்பு சேமிக்கப்பட்டது';

  @override
  String get remoteSyncRemoveBtn => 'Firebase அமைப்பை நீக்கு';

  @override
  String get remoteSyncRemoveTitle => 'Firebase அமைப்பை நீக்கவா?';

  @override
  String get remoteSyncRemoveBody =>
      'இந்தத் தொலைபேசி தொலைநிலை ஒத்திசைவைப் பயன்படுத்துவதை நிறுத்தி, சேமிக்கப்பட்ட Firebase விவரங்களை அழிக்கும். தொலைபேசியில் உள்ள இல்லத் தரவு பாதிக்கப்படாது.';

  @override
  String get remoteSyncRemoveConfirm => 'நீக்கு';

  @override
  String get remoteSyncShareTitle => 'Firebase அமைப்பைப் பகிர்';

  @override
  String get remoteSyncShareLead =>
      'மற்றொரு குடும்பத் தொலைபேசியில் தொலைநிலை ஒத்திசைவை இயக்கிய பிறகு, அதில் இந்த QR குறியீட்டை ஸ்கேன் செய்யவும்.';

  @override
  String get remoteSyncShareWarning =>
      'இந்த வீட்டின் குடும்ப உறுப்பினர்களுடன் மட்டுமே பகிரவும் — உங்கள் Project ID மற்றும் API key வைத்திருக்கும் எவரும் உங்கள் Firebase திட்டத்தின் அநாமதேய ரிலேவை அணுக முடியும்.';

  @override
  String get remoteSyncCopyShareLink => 'அமைப்பு இணைப்பை நகலெடு';

  @override
  String get remoteSyncShareLinkCopied => 'அமைப்பு இணைப்பு நகலெடுக்கப்பட்டது';

  @override
  String get remoteSyncScanTitle => 'தொலைநிலை ஒத்திசைவு QR-ஐ ஸ்கேன் செய்';

  @override
  String get remoteSyncScanHint =>
      'உங்கள் குடும்ப உறுப்பினரின் தொலைபேசியில் உள்ள தொலைநிலை ஒத்திசைவு QR குறியீட்டின் மீது காட்டவும்.';

  @override
  String get remoteSyncScanInvalid =>
      'அந்த QR குறியீடு இல்லம் தொலைநிலை ஒத்திசைவு அமைப்பு அல்ல';

  @override
  String get remoteSyncErrInvalidApiKey =>
      'Firebase அந்த Web API key-ஐ நிராகரித்தது.';

  @override
  String get remoteSyncErrAnonDisabled =>
      'Firebase Authentication → Sign-in method என்பதன் கீழ் Anonymous உள்நுழைவை இயக்கவும்.';

  @override
  String get remoteSyncErrPermissionDenied =>
      'Firestore அணுகலை மறுத்தது. Firestore → Rules என்பதில் இல்லத்தின் பாதுகாப்பு விதிகளை ஒட்டவும்.';

  @override
  String get remoteSyncErrDatabaseNotFound =>
      'Firestore தரவுத்தளம் அல்லது Project ID கிடைக்கவில்லை.';

  @override
  String get remoteSyncErrQuota =>
      'Firebase தினசரி Spark அளவு (quota) முடிந்துவிட்டது. பின்னர் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get remoteSyncErrNetwork =>
      'Firebase-ஐத் தொடர்புகொள்ள முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get remoteSyncErrOther =>
      'Firebase ஒத்திசைவு தோல்வியடைந்தது — உங்கள் அமைப்பு மற்றும் விதிகளைச் சரிபார்க்கவும்.';

  @override
  String get remoteSyncCardTitle => 'தொலைநிலை ஒத்திசைவு';

  @override
  String get remoteSyncProfileSubOff => 'முடக்கப்பட்டது';

  @override
  String get remoteSyncProfileSubNeedsSetup => 'அமைப்பு தேவை';

  @override
  String remoteSyncProfileSubConnected(Object projectId) {
    return 'இணைக்கப்பட்டது · $projectId';
  }

  @override
  String get remoteSyncNoHomeKey =>
      'வீட்டு குறியாக்கச் சாவி இன்னும் தயாராகவில்லை';

  @override
  String get remoteSyncCombinedSynced =>
      'ஒத்திசைக்கப்பட்ட தொலைபேசிகள் மற்றும் தொலைநிலை ரிலே';

  @override
  String get gmailImportTitle => 'Gmail விலைப்பட்டியல் இறக்குமதி';

  @override
  String get gmailImportExperimental => 'சோதனை நிலை';

  @override
  String get gmailImportCardTitle => 'Gmail விலைப்பட்டியல் இறக்குமதி';

  @override
  String get gmailImportToggleTitle => 'Gmail விலைப்பட்டியல் இறக்குமதி';

  @override
  String get gmailImportToggleSubtitle =>
      'கணக்கில் சேர்க்கும் முன் Zepto, Blinkit, Amazon, Flipkart மின்னஞ்சல்கள் மற்றும் PDF ரசீதுகளை ஸ்கேன் செய்து வரைவுகளில் சேமிக்கும்.';

  @override
  String get gmailImportOffHint =>
      'உங்கள் Google Desktop App OAuth client-ஐ இணைக்கவும், கடை ஆர்டர் மின்னஞ்சல்களை ஸ்கேன் செய்யவும், வரைவுச் செலவுகளைச் சரிபார்க்கவும் Gmail ரசீது இறக்குமதியை இயக்கவும்.';

  @override
  String get gmailImportProfileSubOff => 'நிறுத்தம்';

  @override
  String get gmailImportProfileSubNeedsSetup => 'அமைப்பு தேவை';

  @override
  String gmailImportProfileSubConnected(Object email) {
    return 'இணைக்கப்பட்டது · $email';
  }

  @override
  String gmailImportProfileSubDrafts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'சரிபார்க்க $count வரைவுகள்',
      one: 'சரிபார்க்க 1 வரைவு',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportStatusTitle => 'Gmail இணைப்பு';

  @override
  String get gmailImportStatusNeedsOAuth =>
      'கீழே உங்கள் Desktop OAuth client ID மற்றும் secret-ஐச் சேர்க்கவும்.';

  @override
  String get gmailImportStatusReadyToConnect =>
      'OAuth விவரங்கள் சேமிக்கப்பட்டன — உங்கள் Gmail கணக்கை இணைக்கவும்.';

  @override
  String gmailImportStatusConnected(Object email) {
    return '$email ஆக இணைக்கப்பட்டது';
  }

  @override
  String get gmailImportStatusConnectedFallback => 'Gmail உடன் இணைக்கப்பட்டது';

  @override
  String gmailImportLastScan(Object ago) {
    return 'கடைசியாக ஸ்கேன் செய்தது: $ago';
  }

  @override
  String get gmailImportNeverScanned => 'இதுவரை ஸ்கேன் செய்யவில்லை';

  @override
  String get gmailImportConnectBtn => 'Gmail இணை';

  @override
  String get gmailImportConnectingBtn =>
      'Google உள்நுழைவுக்காகக் காத்திருக்கிறது…';

  @override
  String get gmailImportCancelAuthBtn => 'உள்நுழைவை ரத்துசெய்';

  @override
  String get gmailImportScanNowBtn => 'மின்னஞ்சல் ஸ்கேன்';

  @override
  String get gmailImportScanningBtn => 'ஸ்கேன் செய்கிறது…';

  @override
  String get gmailImportDisconnectBtn => 'Gmail துண்டி';

  @override
  String get gmailImportDisconnectedSnack => 'Gmail கணக்கு துண்டிக்கப்பட்டது';

  @override
  String gmailImportConnectedSnack(Object email) {
    return '$email உடன் இணைக்கப்பட்டது';
  }

  @override
  String get gmailImportWindowLabel => 'ஸ்கேன் கால அளவு';

  @override
  String gmailImportWindowDays(Object days) {
    return 'கடந்த $days நாட்கள்';
  }

  @override
  String gmailImportScanSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gmail-இல் இருந்து $count புதிய வரைவுச் செலவுகள் சேர்க்கப்பட்டன',
      one: 'Gmail-இல் இருந்து 1 புதிய வரைவுச் செலவு சேர்க்கப்பட்டது',
      zero: 'மின்னஞ்சல்கள் ஸ்கேன் செய்யப்பட்டன — புதிய ரசீதுகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportGuideTitle =>
      'உங்கள் Google Desktop OAuth அமைக்கும் முறை';

  @override
  String get gmailImportGuideStep1 =>
      '1. console.cloud.google.com திறந்து, ஒரு project உருவாக்கி, Gmail API-ஐ இயக்கவும்.';

  @override
  String get gmailImportGuideStep2 =>
      '2. Google Auth platform → Audience பகுதியில், உங்கள் Gmail முகவரியை Test user ஆகச் சேர்க்கவும்.';

  @override
  String get gmailImportGuideStep3 =>
      '3. Clients → Create client → Desktop app என்பதைத் தேர்ந்தெடுக்கவும் (லோக்கல் உள்நுழைவுக்கு இது தேவை).';

  @override
  String get gmailImportGuideStep4 =>
      '4. பதிவிறக்கிய JSON-ஐ (அல்லது client ID & secret) கீழே ஒட்டி, \'Gmail இணை\' தட்டி, கணக்கில் சேர்க்கும் முன் வரைவுகளைச் சரிபார்க்கவும்.';

  @override
  String get gmailImportOAuthTitle => 'Google Desktop OAuth';

  @override
  String get gmailImportOAuthLead =>
      'உங்கள் சான்றுகளும் Gmail டோக்கன்களும் இந்த ஃபோனிலேயே மறையாக்கம் செய்யப்பட்டு பாதுகாப்பாக இருக்கும்.';

  @override
  String get gmailImportPasteJsonBtn => 'OAuth JSON ஒட்டு';

  @override
  String get gmailImportPasteJsonTitle => 'OAuth client JSON ஒட்டுக';

  @override
  String get gmailImportPasteJsonLead =>
      'Google Cloud Console-இல் இருந்து பதிவிறக்கிய Desktop app client JSON-ஐ ஒட்டவும்.';

  @override
  String get gmailImportPasteJsonField => 'Desktop app JSON';

  @override
  String get gmailImportApplyJsonBtn => 'நிரப்பு';

  @override
  String get gmailImportJsonApplied => 'OAuth விவரங்கள் நிரப்பப்பட்டன';

  @override
  String get gmailImportClientIdLabel => 'Client ID';

  @override
  String get gmailImportClientIdHint => '123456-abc.apps.googleusercontent.com';

  @override
  String get gmailImportClientSecretLabel => 'Client secret';

  @override
  String get gmailImportClientSecretHint => 'GOCSPX-...';

  @override
  String get gmailImportShowSecret => 'Client secret-ஐக் காட்டு';

  @override
  String get gmailImportHideSecret => 'Client secret-ஐ மறை';

  @override
  String get gmailImportSaveOAuthBtn => 'விவரங்களைச் சேமி';

  @override
  String get gmailImportOAuthSavedSnack => 'OAuth விவரங்கள் சேமிக்கப்பட்டன';

  @override
  String get gmailImportRemoveConfigBtn => 'OAuth & வரைவுகளை அழி';

  @override
  String get gmailImportRemoveTitle => 'Gmail இறக்குமதி தரவை அழிக்கவா?';

  @override
  String get gmailImportRemoveBody =>
      'இந்த ஃபோனில் சேமித்த OAuth விவரங்கள், டோக்கன்கள் மற்றும் நிலுவையில் உள்ள வரைவுகளை நீக்கும். ஏற்கனவே கணக்கில் சேர்த்த செலவுகள் \'பணம்\' பகுதியில் இருக்கும்.';

  @override
  String get gmailImportRemoveConfirm => 'அழி';

  @override
  String get gmailImportPasteInvoiceBtn => 'ரசீது உரை ஒட்டு';

  @override
  String get gmailImportPasteInvoiceTitle => 'ஒட்டிய ரசீதைப் பிரித்தெடு';

  @override
  String get gmailImportPasteInvoiceLead =>
      'Zepto, Blinkit, Amazon அல்லது Flipkart மின்னஞ்சல் அல்லது PDF ரசீது உரையை ஒட்டி ஆஃப்லைனில் சோதிக்கலாம் அல்லது ஆர்டரை இறக்குமதி செய்யலாம்.';

  @override
  String get gmailImportPasteInvoiceField => 'மின்னஞ்சல் அல்லது ரசீது உரை';

  @override
  String get gmailImportParseToDraftBtn => 'வரைவு உருவாக்கு';

  @override
  String get gmailImportPasteNotMatched =>
      'அந்த உரையில் Zepto, Blinkit, Amazon அல்லது Flipkart மொத்தத் தொகையைக் கண்டறிய முடியவில்லை.';

  @override
  String gmailImportPasteAddedSnack(Object channel) {
    return 'வரைவுச் செலவு உருவாக்கப்பட்டது ($channel)';
  }

  @override
  String gmailImportDraftsSectionTitle(Object count) {
    return 'வரைவுச் செலவுகள் ($count)';
  }

  @override
  String get gmailImportDraftsEmpty =>
      'நிலுவையில் வரைவுகள் இல்லை. Zepto, Blinkit, Amazon அல்லது Flipkart-இல் வாங்கிய பின் உங்கள் Gmail-ஐ ஸ்கேன் செய்யவும்.';

  @override
  String get gmailImportDraftBadge => 'வரைவு';

  @override
  String get gmailImportDraftsMoneyNote =>
      'நீங்கள் சரிபார்த்து \'கணக்கில் சேர்\' என்பதைத் தட்டும் வரை செலவுகளிலோ பட்ஜெட்டிலோ சேர்க்கப்படாது.';

  @override
  String get gmailImportReviewAllAction => 'இறக்குமதி திற';

  @override
  String get gmailImportAccountItBtn => 'கணக்கில் சேர்';

  @override
  String get gmailImportAccountingBtn => 'சேர்க்கிறது…';

  @override
  String get gmailImportDiscardBtn => 'தவிர்';

  @override
  String get gmailImportEditDraftBtn => 'சரிபார்';

  @override
  String gmailImportDraftItemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்கள் எடுக்கப்பட்டன',
      one: '1 பொருள் எடுக்கப்பட்டது',
      zero: 'ஆர்டர் மொத்தம் மட்டும்',
    );
    return '$_temp0';
  }

  @override
  String gmailImportReviewSheetTitle(Object channel) {
    return '$channel வரைவு';
  }

  @override
  String get gmailImportSplitByItemLabel =>
      'ஒவ்வொரு பொருளையும் தனித்தனியாகப் பதிவுசெய்';

  @override
  String gmailImportSplitByItemSub(Object channel) {
    return '$channel-க்கு ஒரே மொத்தச் செலவாகச் சேர்க்க இதை அணைக்கவும்.';
  }

  @override
  String gmailImportFeesDiscountInfo(Object fees, Object discount) {
    return 'டெலிவரி/கட்டணம் $fees · தள்ளுபடி $discount (செலுத்திய மொத்தத்துடன் சரிசெய்யப்பட்டது)';
  }

  @override
  String get gmailImportOrderTotalLabel => 'செலுத்திய மொத்தம்';

  @override
  String gmailImportSelectedTotalLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'பதிவுகள்',
      one: 'பதிவு',
    );
    return 'கணக்கில் சேர்க்க ($count $_temp0)';
  }

  @override
  String gmailImportAccountedSnack(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செலவுகள் கணக்கில் சேர்க்கப்பட்டன ($total)',
      one: '1 செலவு கணக்கில் சேர்க்கப்பட்டது ($total)',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportNothingSelected =>
      'குறைந்தது ஒரு நேர்மறைத் தொகைப் பொருளையாவது தேர்ந்தெடுக்கவும் அல்லது மொத்த ஆர்டர் தொகைக்கு மாற்றவும்.';

  @override
  String get gmailImportItemAmountInvalid =>
      'சேர்க்கப்பட்ட ஒவ்வொரு பொருளுக்கும் நேர்மறைத் தொகையை உள்ளிடவும்.';

  @override
  String gmailImportDuplicateWarning(Object date) {
    return '$date வாக்கில் இதேபோன்ற செலவு ஏற்கனவே உள்ளது. வேண்டுமானால் கணக்கில் சேர்க்கலாம் அல்லது இந்த வரைவைத் தவிர்க்கலாம்.';
  }

  @override
  String gmailImportOrderIdLabel(Object id) {
    return 'ஆர்டர் $id';
  }

  @override
  String get gmailImportErrOAuthEmpty =>
      'Google Desktop App OAuth JSON-ஐ ஒட்டவும் அல்லது இரண்டு புலங்களையும் நிரப்பவும்.';

  @override
  String get gmailImportErrOAuthMalformed =>
      'அந்த உள்ளீட்டிலிருந்து Client ID மற்றும் Secret-ஐப் படிக்க முடியவில்லை.';

  @override
  String get gmailImportErrWebClient =>
      'அது Web OAuth client ஆகும். Google Cloud Console-இல் Desktop app client-ஐ உருவாக்கவும்.';

  @override
  String get gmailImportErrInvalidClientId =>
      'Client ID வடிவத்தைச் சரிபார்க்கவும் (.apps.googleusercontent.com என முடிய வேண்டும்).';

  @override
  String get gmailImportErrMissingSecret =>
      'உங்கள் Google OAuth Client secret-ஐ உள்ளிடவும்.';

  @override
  String get gmailImportErrUnauthorized =>
      'Gmail அமர்வு காலாவதியானது அல்லது அனுமதி நீக்கப்பட்டது. Gmail-ஐ மீண்டும் இணைக்கவும்.';

  @override
  String get gmailImportErrForbidden =>
      'Gmail அணுகலை மறுத்தது — Gmail API இயக்கப்பட்டுள்ளதையும் உங்கள் முகவரி Test user ஆகச் சேர்க்கப்பட்டுள்ளதையும் உறுதிப்படுத்தவும்.';

  @override
  String get gmailImportErrRateLimited =>
      'Gmail வரம்பை எட்டிவிட்டது. சிறிது நேரத்தில் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get gmailImportErrNetwork =>
      'Google-ஐத் தொடர்பு கொள்ள முடியவில்லை. இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get gmailImportErrAuthUnsupported =>
      'Gmail உலாவி உள்நுழைவுக்கு Android அல்லது டெஸ்க்டாப் தேவை; இங்கே சோதிக்க ரசீது உரையை ஒட்டவும்.';

  @override
  String get gmailImportErrAuthBrowser =>
      'Google உள்நுழைவுக்கு உலாவியைத் திறக்க முடியவில்லை.';

  @override
  String get gmailImportErrAuthDenied =>
      'Google உள்நுழைவு ரத்து செய்யப்பட்டது அல்லது மறுக்கப்பட்டது.';

  @override
  String get gmailImportErrAuthTimeout =>
      'Google உள்நுழைவு நேரம் முடிந்தது. மீண்டும் முயற்சிக்க \'Gmail இணை\' என்பதைத் தட்டவும்.';

  @override
  String get gmailImportErrAuthOther =>
      'Google உள்நுழைவு முடியவில்லை — உங்கள் Desktop OAuth client அமைப்புகளைச் சரிபார்க்கவும்.';

  @override
  String get smsImportTitle => 'SMS செலவு இறக்குமதி';

  @override
  String get smsImportExperimental => 'சோதனை';

  @override
  String get smsImportCardTitle => 'SMS செலவு இறக்குமதி';

  @override
  String get smsImportTagLabel => 'SMS';

  @override
  String get smsImportToggleTitle => 'SMS செலவு இறக்குமதி';

  @override
  String get smsImportToggleSubtitle =>
      'கணக்கில் சேர்க்கும் முன் வங்கி, UPI, கார்டு கட்டண SMS-களை இந்த ஃபோனிலேயே கண்டறிந்து வரைவுகளில் சேமிக்கும்.';

  @override
  String get smsImportOffHint =>
      'பரிவர்த்தனை SMS-களை ஃபோனிலேயே ஸ்கேன் செய்ய அல்லது பின்னணியில் தானாகப் பிடிக்க SMS செலவு இறக்குமதியை இயக்கவும். நீங்கள் \'கணக்கில் சேர்\' தட்டும் வரை எதுவும் \'பணம்\' பகுதியில் சேராது.';

  @override
  String get smsImportProfileSubOff => 'நிறுத்தம்';

  @override
  String smsImportProfileSubDrafts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'சரிபார்க்க $count வரைவுகள்',
      one: 'சரிபார்க்க 1 வரைவு',
    );
    return '$_temp0';
  }

  @override
  String get smsImportProfileSubAuto => 'தானியங்கி இயக்கம்';

  @override
  String get smsImportProfileSubManual => 'கைமுறை ஸ்கேன்';

  @override
  String get smsImportProfileSubPermission => 'அனுமதி தேவை';

  @override
  String get smsImportStatusTitle => 'SMS அனுமதி';

  @override
  String get smsImportStatusGranted =>
      'SMS அனுமதி வழங்கப்பட்டது — தகவல்கள் இந்த ஃபோனிலேயே இருக்கும்.';

  @override
  String get smsImportStatusPartial =>
      'இன்பாக்ஸ் படிக்க அனுமதி உள்ளது — பின்னணியில் பெற SMS பெறும் அனுமதியையும் வழங்கவும்.';

  @override
  String get smsImportStatusNeeded =>
      'இந்த ஃபோனில் உள்ள பரிவர்த்தனை SMS-களைப் படிக்க இல்லம் செயலிக்கு அனுமதி வழங்கவும்.';

  @override
  String get smsImportStatusRestricted =>
      'Android SMS அணுகலைத் தடுத்துள்ளது. நேரடியாக நிறுவிய செயலிகளில் App info → ⋮ → Allow restricted settings திறந்து பின் SMS அனுமதியை இயக்கவும்.';

  @override
  String get smsImportStatusUnsupported =>
      'SMS படிக்கும் வசதி Android-இல் மட்டுமே உள்ளது; இங்கே சோதிக்க \'SMS உரை ஒட்டு\' என்பதைப் பயன்படுத்தவும்.';

  @override
  String get smsImportGrantBtn => 'SMS அனுமதி கொடு';

  @override
  String get smsImportOpenSettingsBtn => 'ஆப் அமைப்புகளைத் திற';

  @override
  String get smsImportAutoCaptureTitle => 'வரும் SMS-ஐத் தானாகச் சேர்';

  @override
  String get smsImportAutoCaptureSub =>
      'புதிய வங்கி, UPI, கார்டு கட்டண SMS-களைத் தானாக வரைவுகளில் சேமிக்கும்.';

  @override
  String get smsImportWindowLabel => 'ஸ்கேன் கால அளவு';

  @override
  String smsImportWindowDays(Object days) {
    return 'கடந்த $days நாட்கள்';
  }

  @override
  String smsImportLastScan(Object ago) {
    return 'கடைசியாக ஸ்கேன் செய்தது: $ago';
  }

  @override
  String get smsImportNeverScanned => 'இதுவரை ஸ்கேன் செய்யவில்லை';

  @override
  String get smsImportScanNowBtn => 'SMS ஸ்கேன்';

  @override
  String get smsImportScanningBtn => 'ஸ்கேன் செய்கிறது…';

  @override
  String smsImportScanSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'SMS-இல் இருந்து $count புதிய வரைவுச் செலவுகள் சேர்க்கப்பட்டன',
      one: 'SMS-இல் இருந்து 1 புதிய வரைவுச் செலவு சேர்க்கப்பட்டது',
      zero: 'SMS ஸ்கேன் செய்யப்பட்டது — புதிய கட்டணச் செய்திகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get smsImportPasteBtn => 'SMS உரை ஒட்டு';

  @override
  String get smsImportPasteTitle => 'ஒட்டிய வங்கி SMS-ஐப் பிரித்தெடு';

  @override
  String get smsImportPasteLead =>
      'வரைவுகளில் பிரித்தெடுப்பதைச் சோதிக்க எந்த இந்திய வங்கி, UPI அல்லது கார்டு செலவு SMS-ஐயும் ஒட்டவும்.';

  @override
  String get smsImportPasteField => 'பரிவர்த்தனை SMS உரை';

  @override
  String get smsImportPasteNotMatched =>
      'அந்தச் செய்தியில் முடிந்த செலவுத் தொகை எதுவும் இல்லை (OTP, வரவு, விளம்பரங்கள், கார்டு பில் கட்டணங்கள் தவிர்க்கப்படும்).';

  @override
  String smsImportPasteAddedSnack(Object merchant) {
    return 'SMS வரைவு உருவாக்கப்பட்டது ($merchant)';
  }

  @override
  String get smsImportDraftsEmpty =>
      'நிலுவையில் SMS வரைவுகள் இல்லை. உங்கள் இன்பாக்ஸை ஸ்கேன் செய்யவும் அல்லது புதிய கட்டணங்களுக்குத் தானியங்கிப் பிடிப்பை இயக்கவும்.';

  @override
  String get smsImportClearBtn => 'SMS இறக்குமதி தரவை அழி';

  @override
  String get smsImportClearTitle => 'SMS இறக்குமதி தரவை அழிக்கவா?';

  @override
  String get smsImportClearBody =>
      'இந்த ஃபோனில் உள்ள நிலுவை SMS வரைவுகள் மற்றும் செயலாக்கப்பட்ட வரலாற்றை நீக்கி, பின்னணி SMS பிடிப்பை நிறுத்தும். ஏற்கனவே கணக்கில் சேர்த்த செலவுகள் \'பணம்\' பகுதியில் இருக்கும்.';

  @override
  String get smsImportClearConfirm => 'அழி';

  @override
  String get smsImportReviewTitle => 'SMS செலவைச் சரிபார்';

  @override
  String smsImportAccountMeta(Object bank, Object when) {
    return '$bank · $when';
  }

  @override
  String get smsImportRawLabel => 'அசல் SMS பகுதி';

  @override
  String smsImportGmailOverlapWarning(Object channel, Object date) {
    return '$date வாக்கில் இதே தொகையில் நிலுவையிலுள்ள Gmail வரைவு ($channel) உள்ளது.';
  }

  @override
  String get smsImportErrAmount =>
      '₹10,00,000 வரை நேர்மறைத் தொகையை உள்ளிடவும்.';

  @override
  String get smsImportErrMerchant =>
      'இந்தப் பணம் யாருக்கு அல்லது எதற்குச் செலுத்தப்பட்டது என்பதை உள்ளிடவும்.';

  @override
  String smsImportAccountedSnack(Object merchant, Object amount) {
    return '$merchant ($amount) கணக்கில் சேர்க்கப்பட்டது';
  }

  @override
  String get tripsTab => 'பயணங்கள்';

  @override
  String get tripsGenericTitle => 'பொது சரிபார்ப்புப் பட்டியல்';

  @override
  String tripsGenericSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொதுப் பொருட்கள் · புதிய பயணங்களில் தானாகச் சேரும்',
      one: '1 பொதுப் பொருள் · புதிய பயணங்களில் தானாகச் சேரும்',
      zero: 'ஒவ்வொரு பயணத்திற்கும் எடுத்துச் செல்லும் பொருட்களைச் சேர்க்கவும்',
    );
    return '$_temp0';
  }

  @override
  String get tripsGenericLead =>
      'அவசியப் பொருட்களை மறக்காமல் இருக்க, இங்குள்ளவை ஒவ்வொரு புதிய பயணத்திலும் தானாக நகலெடுக்கப்படும்.';

  @override
  String get tripsGenericAddHint =>
      'பொதுப் பொருளைச் சேர்க்கவும் (எ.கா. சார்ஜர், அடையாள அட்டை)…';

  @override
  String get tripsGenericEmptyTitle => 'பொதுப் பொருட்கள் இன்னும் இல்லை';

  @override
  String get tripsGenericEmptyBody =>
      'ஒவ்வொரு பயணத்திற்கும் முன் சரிபார்க்கும் அவசியப் பொருட்களைச் சேர்க்கவும் அல்லது அடிப்படைப் பட்டியலை ஏற்றவும்.';

  @override
  String get tripsLoadStarter => 'அடிப்படைப் பொருட்களை ஏற்று';

  @override
  String tripsStarterLoaded(int count) {
    return '$count அடிப்படைப் பொருட்கள் சேர்க்கப்பட்டன';
  }

  @override
  String get tripsStarterChargers => 'ஃபோன் சார்ஜர்கள் & கேபிள்கள்';

  @override
  String get tripsStarterIds => 'அடையாள அட்டைகள் / டிக்கெட்டுகள்';

  @override
  String get tripsStarterMedicines => 'மருந்துகள் & முதலுதவிப் பெட்டி';

  @override
  String get tripsStarterClothes => 'உடைகள் & குளியல் பொருட்கள்';

  @override
  String get tripsStarterWater => 'தண்ணீர் பாட்டில்கள் & தின்பண்டங்கள்';

  @override
  String get tripsStarterKeys => 'வீட்டுச் சாவிகள்';

  @override
  String get tripsStarterGas => 'கேஸ் அடுப்பை அணைக்கவும்';

  @override
  String get tripsStarterLocks => 'ஜன்னல், கதவுகளைப் பூட்டவும்';

  @override
  String get tripsNewTrip => 'புதிய பயணம்';

  @override
  String get tripsNewTripTitle => 'புதிய பயணம்';

  @override
  String get tripsEditTripTitle => 'பயணத்தைத் திருத்து';

  @override
  String get tripsNameLabel => 'பயணப் பெயர்';

  @override
  String get tripsNameHint => 'எ.கா. கோவா குடும்பப் பயணம்';

  @override
  String get tripsNameRequired => 'பயணப் பெயரைச் சேர்க்கவும்.';

  @override
  String get tripsStartDate => 'பயணத் தேதி';

  @override
  String get tripsEndDate => 'திரும்பும் தேதி (விருப்பம்)';

  @override
  String get tripsAddEndDate => 'திரும்பும் தேதி சேர்';

  @override
  String get tripsClearEndDate => 'திரும்பும் தேதியை அழி';

  @override
  String get tripsNoteLabel => 'குறிப்பு (விருப்பம்)';

  @override
  String get tripsNoteHint => 'எ.கா. விமானம், ரயில் அல்லது தங்கும் விவரம்';

  @override
  String tripsIncludeGeneric(int count) {
    return 'பொதுப் பட்டியலைச் சேர் ($count)';
  }

  @override
  String get tripsSaveTrip => 'பயணம் சேர்';

  @override
  String get tripsSaveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get tripsDeleteTrip => 'பயணத்தை நீக்கு';

  @override
  String get tripsAdded => 'பயணம் சேர்க்கப்பட்டது';

  @override
  String get tripsUpdated => 'பயணம் புதுப்பிக்கப்பட்டது';

  @override
  String get tripsDeleted => 'பயணம் நீக்கப்பட்டது';

  @override
  String get tripsEmptyTitle => 'திட்டமிட்ட பயணங்கள் இல்லை';

  @override
  String get tripsEmptyBody =>
      'பயணத் தேதியுடன் திட்டமிட்டு, கிளம்பும் முன் பொருட்களைச் சரிபார்க்கவும்.';

  @override
  String tripsPastHeader(int count) {
    return 'முடிந்த பயணங்கள் ($count)';
  }

  @override
  String get tripsReady => 'தயார்';

  @override
  String get tripsOngoing => 'பயணத்தில்';

  @override
  String get tripsPast => 'முடிந்தது';

  @override
  String get tripsStartsToday => 'இன்று தொடக்கம்';

  @override
  String get tripsStartsTomorrow => 'நாளை';

  @override
  String tripsInDays(int n) {
    return '$n நாட்களில்';
  }

  @override
  String tripsCheckedCount(int done, int total) {
    return '$total-இல் $done சரிபார்க்கப்பட்டது';
  }

  @override
  String get tripsNoItemsYet => 'சரிபார்ப்புப் பொருட்கள் இன்னும் இல்லை';

  @override
  String get tripsAllReadyTitle => 'பயணத்திற்கு எல்லாம் தயார்!';

  @override
  String tripsRemainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கிளம்பும் முன் $count பொருட்கள் பாக்கி',
      one: 'கிளம்பும் முன் 1 பொருள் பாக்கி',
    );
    return '$_temp0';
  }

  @override
  String get tripsAddItemHint =>
      'கிளம்பும் முன் சரிபார்க்கப் பொருள் சேர்க்கவும்…';

  @override
  String get tripsAddItem => 'பொருள் சேர்';

  @override
  String get tripsItemAdded => 'பொருள் சேர்க்கப்பட்டது';

  @override
  String tripsItemChecked(Object title) {
    return 'சரிபார்க்கப்பட்டது: $title';
  }

  @override
  String tripsItemUnchecked(Object title) {
    return 'மீண்டும் சேர்க்கப்பட்டது: $title';
  }

  @override
  String tripsCheckedSection(int count) {
    return 'சரிபார்த்தவை ($count)';
  }

  @override
  String get tripsImportGeneric => 'பொதுப் பட்டியலைச் சேர்';

  @override
  String tripsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொதுப் பொருட்கள் சேர்க்கப்பட்டன',
      one: '1 பொதுப் பொருள் சேர்க்கப்பட்டது',
      zero: 'பொதுப் பொருட்கள் அனைத்தும் ஏற்கனவே இதில் உள்ளன',
    );
    return '$_temp0';
  }

  @override
  String get tripsResetChecks => 'அனைத்தையும் மீட்டமை';

  @override
  String get tripsChecksReset => 'சரிபார்ப்புப் பட்டியல் மீட்டமைக்கப்பட்டது';

  @override
  String tripsCopyGenericBtn(int count) {
    return 'பொதுப் பட்டியலை நகலெடு ($count)';
  }

  @override
  String get tripsEditItemTitle => 'பொருளைத் திருத்து';

  @override
  String get tripsItemLabel => 'பொருள்';

  @override
  String get tripsSaveToGeneric => 'பொதுப் பட்டியலிலும் சேர்';

  @override
  String get tripsSavedToGeneric => 'பொதுப் பட்டியலில் சேர்க்கப்பட்டது';

  @override
  String get tripsDeleteItem => 'பொருளை நீக்கு';

  @override
  String get tripsItemDeleted => 'பொருள் நீக்கப்பட்டது';

  @override
  String get tripsMoreActions => 'மேலும் பயணச் செயல்கள்';

  @override
  String get tripsEditTrip => 'பயணத்தைத் திருத்து';

  @override
  String get tripsNotFound => 'பயணம் கிடைக்கவில்லை';

  @override
  String get tripsTodaySection => 'வரவிருக்கும் பயணம்';

  @override
  String tripsTodayMeta(Object when, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left பொருட்கள் பாக்கி',
      one: '1 பொருள் பாக்கி',
    );
    return '$when · $_temp0';
  }

  @override
  String get tripsOpenChecklist => 'சரிபார்ப்புப் பட்டியல்';

  @override
  String get moneyScanBill => 'பில் ஸ்கேன்';

  @override
  String get billScanSheetTitle => 'பில் ஸ்கேன்';

  @override
  String get billScanChooseHint =>
      'அச்சிட்ட ரசீதைப் புகைப்படம் எடுக்கவும், கேலரியிலிருந்து தேர்வு செய்யவும் அல்லது பில் உரையை ஒட்டவும். OCR உங்கள் ஃபோனிலேயே ஆஃப்லைனில் இயங்கும்.';

  @override
  String get billScanTakePhoto => 'புகைப்படம் எடு';

  @override
  String get billScanFromGallery => 'கேலரியிலிருந்து தேர்வு';

  @override
  String get billScanPasteText => 'பில் உரை ஒட்டு';

  @override
  String get billScanPasteHint =>
      'பொருட்கள் மற்றும் விலைகளுடன் ரசீது வரிகளை ஒட்டவும் அல்லது தட்டச்சு செய்யவும்';

  @override
  String get billScanExtractAction => 'பொருட்களை எடு';

  @override
  String get billScanScanning => 'பில் உரையை ஆஃப்லைனில் படிக்கிறது…';

  @override
  String get billScanErrPermission =>
      'பில் புகைப்படம் எடுக்க கேமரா அனுமதி தேவை. கேலரியிலிருந்தும் புகைப்படத்தைத் தேர்வு செய்யலாம்.';

  @override
  String get billScanErrNoCamera =>
      'இந்தச் சாதனத்தில் கேமரா ஆப் இல்லை. கேலரியிலிருந்து படத்தைத் தேர்வு செய்யவும் அல்லது உரையை ஒட்டவும்.';

  @override
  String get billScanErrUnsupported =>
      'கேமரா OCR வசதி Android-இல் மட்டுமே உள்ளது. ஆஃப்லைனில் பொருட்களை எடுக்கக் கீழே பில் உரையை ஒட்டவும்.';

  @override
  String get billScanErrFailed =>
      'அந்தப் படத்தைப் படிக்க முடியவில்லை. தெளிவான புகைப்படத்தை மீண்டும் எடுக்கவும் அல்லது உரையை ஒட்டவும்.';

  @override
  String get billScanErrEmptyPaste =>
      'முதலில் பில் உரையை ஒட்டவும் அல்லது தட்டச்சு செய்யவும்.';

  @override
  String get billScanNoTextFound =>
      'படிக்கக்கூடிய உரை எதுவும் கிடைக்கவில்லை. 90° திருப்பி மீண்டும் ஸ்கேன் செய்யவும் அல்லது கைமுறையாகப் பொருட்களைச் சேர்க்கவும்.';

  @override
  String get billScanReviewTitle => 'ஸ்கேன் செய்த பில்லைச் சரிபார்';

  @override
  String billScanConfidenceLabel(int percent) {
    return 'OCR நம்பகத்தன்மை: $percent%';
  }

  @override
  String get billScanRotateRescan => '90° திருப்பி மீண்டும் ஸ்கேன்';

  @override
  String get billScanRawOcrShow => 'அசல் OCR உரையைக் காட்டு';

  @override
  String get billScanRawOcrHide => 'அசல் OCR உரையை மறை';

  @override
  String get billScanMerchantLabel => 'கடை அல்லது வணிகர்';

  @override
  String get billScanMerchantHint => 'எ.கா. Reliance Fresh';

  @override
  String billScanModeSplit(int count) {
    return 'பொருள் வாரியாக ($count)';
  }

  @override
  String get billScanModeSingle => 'ஒரே மொத்தம்';

  @override
  String get billScanSingleAmountLabel => 'மொத்த பில் தொகை';

  @override
  String get billScanItemsTitle => 'எடுக்கப்பட்ட பொருட்கள்';

  @override
  String get billScanAddItem => '+ பொருள் சேர்';

  @override
  String get billScanItemNameHint => 'பொருள் பெயர்';

  @override
  String get billScanItemAmountHint => 'தொகை';

  @override
  String get billScanDeleteItemTooltip => 'பொருளை நீக்கு';

  @override
  String billScanSummaryCompare(Object selected, Object billTotal) {
    return 'தேர்வு: $selected · பில் மொத்தம்: $billTotal';
  }

  @override
  String billScanSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செலவுகளைச் சேமி',
      one: '1 செலவைச் சேமி',
    );
    return '$_temp0';
  }

  @override
  String get billScanSaveSingle => 'செலவைச் சேமி';

  @override
  String get billScanErrNoItems =>
      'சரியான பெயர் மற்றும் நேர்மறைத் தொகையுடன் குறைந்தது ஒரு பொருளையாவது தேர்ந்தெடுக்கவும்.';

  @override
  String get billScanErrAmount => 'சரியான நேர்மறைத் தொகையை உள்ளிடவும்.';

  @override
  String get billScanErrMerchant => 'கடை அல்லது வணிகர் பெயரை உள்ளிடவும்.';

  @override
  String billScanSavedCount(int count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செலவுகள் சேமிக்கப்பட்டன ($total)',
      one: '1 செலவு சேமிக்கப்பட்டது ($total)',
    );
    return '$_temp0';
  }

  @override
  String get profileLangSystem => 'சாதன இயல்புநிலை';

  @override
  String get profileLangEnglish => 'English (ஆங்கிலம்)';

  @override
  String get profileLangTamil => 'தமிழ்';

  @override
  String get profileLangHindi => 'हिन्दी (இந்தி)';

  @override
  String get profileLangBadgeTamil => 'தமிழ்';

  @override
  String get profileLangBadgeHindi => 'हिन्दी';

  @override
  String get spendCatGroceries => 'மளிகை';

  @override
  String get spendCatShopping => 'ஷாப்பிங்';

  @override
  String get spendCatStaff => 'பணியாளர்';

  @override
  String get spendCatUtilities => 'பயன்பாடுகள்';

  @override
  String get spendCatEatingOut => 'வெளி உணவு';

  @override
  String get spendCatHomeCare => 'வீட்டுப் பராமரிப்பு';

  @override
  String get spendCatOther => 'மற்றவை';

  @override
  String get whatsNewTitle => 'புதியவை';

  @override
  String get whatsNewHistoryTitle => 'வெளியீட்டுக் குறிப்புகள்';

  @override
  String get whatsNewGotIt => 'புரிந்தது';

  @override
  String whatsNewVersionHeader(Object version) {
    return 'பதிப்பு $version';
  }

  @override
  String get whatsNewV180MlKitOcr =>
      'பில் ஸ்கேனர் Google ML Kit ஆஃப்லைன் OCR மற்றும் துல்லிய வரி சீரமைப்புக்கு மேம்படுத்தப்பட்டது — வேகமான, துல்லியமான ரசீது வாசிப்புக்கு.';

  @override
  String get whatsNewV180MlKitQr =>
      'குடும்ப இணைப்பு மற்றும் தொலை ஒத்திசைவு QR ஸ்கேனிங் குறைந்த வெளிச்சத்திலும் வேகமாகப் படிக்கும் வகையில் Google ML Kit-க்கு மேம்படுத்தப்பட்டது.';

  @override
  String get whatsNewV180SmallerApk =>
      'பழைய OCR கோப்புகள் நீக்கப்பட்டு, ஒவ்வொரு சாதனத்திற்கும் ஏற்ற சிறிய பதிவிறக்க உருவாக்கங்கள் சேர்க்கப்பட்டுள்ளன.';

  @override
  String get whatsNewV172PaidLeave =>
      'வருகை நாட்காட்டியில் உதவியாளருக்குச் சம்பளத்துடன் கூடிய விடுப்பு நாட்களைப் பதியலாம்; சம்பளப் பிடித்தமும் இல்லை, மாத விடுப்பு வரம்பும் குறையாது.';

  @override
  String get whatsNewV171TodoDoneNotif =>
      'குடும்ப உறுப்பினர் ஒருவர் உங்கள் பணியை முடித்ததாகக் குறித்தால், பணி உரிமையாளருக்கு அறிவிப்பு வரும்.';

  @override
  String get whatsNewV171TodoWidgetMine =>
      'இன்றைய பணிகள் முகப்புத் திரை விட்ஜெட் இனி உங்கள் பணிகளை மட்டுமே காட்டும்; செயலியின் \'இன்று\' திரையில் முழு வீட்டின் பணிகளும் தொடரும்.';

  @override
  String get whatsNewV170Changelog =>
      'புதுப்பிப்புக்குப் பிறகு \'புதியவை\' பக்கம் வெளியீட்டுக் குறிப்புகளைத் தானாகக் காட்டும் — எப்போது வேண்டுமானாலும் சுயவிவரம் → பதிப்பு வழியாகப் பார்க்கலாம்.';

  @override
  String get whatsNewV170SpendWidget =>
      'ஒரே தட்டில் செலவு சேர்க்க, மாதச் செலவைப் பார்க்க மற்றும் விரைவு பில் ஸ்கேன் செய்யப் புதிய \'பணம் செலவு\' முகப்புத் திரை விட்ஜெட்.';

  @override
  String get whatsNewV170Languages =>
      'தமிழ் மற்றும் இந்தி மொழிகள் சேர்க்கப்பட்டுள்ளன; ஃபோன் மொழியைத் தானாகப் பின்பற்றும் அல்லது சுயவிவரம் → மொழி வழியாகத் தேர்ந்தெடுக்கலாம்.';

  @override
  String get whatsNewV160BillScan =>
      'பணம் பகுதியில் ஆஃப்லைன் கேமரா பில் ஸ்கேனர்: ஃபோனிலேயே இயங்கும் Tesseract OCR மூலம் கடை, தேதி மற்றும் பொருள் வாரியான விலைகளை எடுக்கும்.';

  @override
  String get whatsNewV150Trips =>
      'பணிகள் பகுதியில் பயணத் திட்டமிடல்: பயணத் தேதிகள், பொது சரிபார்ப்புப் பட்டியல்கள், கிளம்பும் முன் சரிபார்ப்பு மற்றும் \'இன்று\' பகுதியில் தயார்நிலை அட்டை.';

  @override
  String get whatsNewV140MoneyCharts =>
      'விருப்பப் பண வகைகள், செலவுப் பகிர்வு வட்ட விளக்கப்படம் (வகை, பொருள் அல்லது நபர் வாரியாக) மற்றும் சுருக்கக்கூடிய வரைவுகள்.';

  @override
  String get whatsNewV132SmsParser =>
      'ஃபோனிலேயே வங்கி, கிரெடிட் கார்டு, ப்ரீபெய்ட் கார்டு மற்றும் UPI SMS செலவு பிரித்தெடுத்தல் மேம்படுத்தப்பட்டது.';

  @override
  String get whatsNewV131Routines =>
      'வீட்டுப் பராமரிப்புப் பணிகள் இயல்பாகப் பொருந்தும்படி \'சுத்தம் செய்தல்\' என்பது \'வழக்கங்கள்\' என மாற்றப்பட்டது.';

  @override
  String get whatsNewV130SmsImport =>
      'பணம் பகுதியில் சேர்க்கும் முன் வரைவுச் சரிபார்ப்புடன் கூடிய சோதனை ஆஃப்லைன் SMS செலவு இறக்குமதி.';

  @override
  String get whatsNewV120GmailImport =>
      'ஆன்லைன் மளிகை மற்றும் சில்லறை ஆர்டர்களுக்கான சோதனை Gmail ரசீது & PDF இறக்குமதி.';

  @override
  String get widgetMoneyHeader => 'மாதச் செலவு';

  @override
  String get widgetMoneyAdd => 'செலவு சேர்';

  @override
  String get widgetMoneyScan => 'ஸ்கேன்';

  @override
  String get widgetMoneyEmpty => 'இந்த மாதம் செலவுகள் எதுவும் பதிவாகவில்லை.';

  @override
  String get widgetMoneyNoHome =>
      'உங்கள் வீட்டை அமைக்க இல்லம் செயலியைத் திறக்கவும்.';

  @override
  String widgetMoneyBudgetLeft(Object amount, Object budget) {
    return '$budget-இல் $amount மீதம்';
  }

  @override
  String widgetMoneyBudgetOver(Object amount, Object budget) {
    return '$budget பட்ஜெட்டை விட $amount அதிகம்';
  }
}
