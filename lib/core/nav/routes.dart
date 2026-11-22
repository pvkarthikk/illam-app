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
  static String recipe(String id) => '/meals/recipe/$id';
  static String recipeEdit(String id) => '/meals/recipe-edit/$id';
  static String cook(String id) => '/meals/cook/$id';
  static const profile = '/profile';
  static const home = '/home';
}

enum NestTab { today, lists, tasks, meals, money }
