import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/navigation/app_route.dart';
import 'package:shop_list_app/features/meal_planning/presentation/pages/menu_view.dart';
import 'package:shop_list_app/features/pantry/presentation/pages/pantry_page.dart';
import 'package:shop_list_app/features/product_category/presentation/pages/product_category_view_page.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:shop_list_app/features/recipes/presentation/pages/recipe_form_page.dart';
import 'package:shop_list_app/features/recipes/presentation/pages/recipe_list_view.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/pages/shopping_list_detail_page.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/pages/shopping_lists_page.dart';
import 'package:shop_list_app/main.dart' show SplashScreen;
import 'package:shop_list_app/shared/widgets/layout/main_shell.dart';
import 'package:shop_list_app/shared/widgets/views/settings_view_page.dart';

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
      builder: (context, state) => const SplashScreen(),
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
              builder: (context, state) => const MenuView(),
            ),
          ],
        ),

        // 1 – Shop
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.shopping.path,
              builder: (context, state) => const ShoppingListsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ShoppingListDetailPage(listId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // 2 – Recipes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.recipes.path,
              builder: (context, state) => const RecipeListView(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const RecipeFormPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return RecipeDetailPage(recipeId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final recipe = state.extra as Recipe?;
                        return RecipeFormPage(initialRecipe: recipe);
                      },
                    ),
                  ],
                ),
              ],
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
              builder: (context, state) => const SettingsView(),
              routes: [
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const ProductCategoryViewPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
