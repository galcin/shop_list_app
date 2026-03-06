import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/navigation/app_route.dart';
import 'package:shop_list_app/presentation/pages/meal_planning/menu_view.dart';
import 'package:shop_list_app/presentation/pages/pantry/pantry_page.dart';
import 'package:shop_list_app/presentation/pages/recipes/recipe_list_view.dart';
import 'package:shop_list_app/presentation/pages/shopping/product_category_view_page.dart';
import 'package:shop_list_app/shared/widgets/main_shell.dart';
import 'package:shop_list_app/shared/widgets/settings_view_page.dart';
import 'package:shop_list_app/main.dart' show SplashScreen;

/// Application-level [GoRouter] instance.
///
/// Routes:
///   /splash            – splash / initialisation screen
///   /meal-plan         – Meal Planning tab (index 0)
///   /shopping          – Shopping tab (index 1)
///   /recipes           – Recipes tab (index 2)
///   /pantry            – Pantry tab (index 3)
///   /settings          – Settings tab (index 4)
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),

    // ── Main shell (bottom nav + IndexedStack) ───────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // 0 – Plan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.mealPlanning.path,
              builder: (context, state) => MenuView(),
            ),
          ],
        ),

        // 1 – Shop
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.shopping.path,
              builder: (context, state) => const ProductCategoryViewPage(),
            ),
          ],
        ),

        // 2 – Recipes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.recipes.path,
              builder: (context, state) => RecipeListView(),
            ),
          ],
        ),

        // 3 – Pantry
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.pantry.path,
              builder: (context, state) => const PantryPage(),
            ),
          ],
        ),

        // 4 – Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.settings.path,
              builder: (context, state) => SettingsView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
