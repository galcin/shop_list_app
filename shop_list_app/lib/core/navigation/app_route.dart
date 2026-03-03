/// Represents the five top-level tabs in the app shell.
enum AppRoute {
  mealPlanning('/meal-plan'),
  shopping('/shopping'),
  recipes('/recipes'),
  pantry('/pantry'),
  settings('/settings');

  const AppRoute(this.path);
  final String path;
}
