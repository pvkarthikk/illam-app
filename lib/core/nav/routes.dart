abstract final class Routes {
  static const today = '/today',
      lists = '/lists',
      tasks = '/tasks',
      meals = '/meals',
      money = '/money';
  static const debug = '/debug',
      debugGallery = '/debug/gallery',
      debugDataLab = '/debug/data-lab';
  static const onboarding = '/onboarding';
  static String onboardingStep(String step) => '/onboarding/$step';
  static String staff(String id) => '/staff/$id';
  static String staffSalary(String id) => '/staff/$id/salary';
  static const listsStore = '/lists/store';
  static const moneyTransactions = '/money/transactions';
}

enum NestTab { today, lists, tasks, meals, money }
