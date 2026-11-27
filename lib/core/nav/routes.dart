abstract final class Routes {
  static const today = '/today',
      lists = '/lists',
      tasks = '/tasks',
      meals = '/meals',
      money = '/money';
  static const debug = '/debug',
      debugGallery = '/debug/gallery',
      debugDataLab = '/debug/data-lab',
      debugSyncLab = '/debug/sync-lab',
      debugBackupLab = '/debug/backup-lab';
  static const onboarding = '/onboarding';
  static String onboardingStep(String step) => '/onboarding/$step';
  static String staff(String id) => '/staff/$id';
  static String staffSalary(String id) => '/staff/$id/salary';
  static const listsStore = '/lists/store';
  static String trip(String id) => '/tasks/trip/$id';
  static const tripTemplate = '/tasks/trip-template';
  static const moneyTransactions = '/money/transactions';
  static String recipe(String id) => '/meals/recipe/$id';
  static String recipeEdit(String id) => '/meals/recipe-edit/$id';
  static String cook(String id) => '/meals/cook/$id';
  static const profile = '/profile';
  static const home = '/home';
  static const invite = '/invite';
  static const backup = '/backup';
  static const remoteSync = '/remote-sync';
  static const gmailImport = '/gmail-import';
  static const smsImport = '/sms-import';
}

enum NestTab { today, lists, tasks, meals, money }
