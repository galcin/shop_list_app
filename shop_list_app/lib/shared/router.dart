import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/route_constants.dart';
import 'package:shop_list_app/shared/widgets/about_view.dart';
import 'package:shop_list_app/shared/widgets/error_view.dart';
import 'package:shop_list_app/shared/widgets/main_view.dart';
import 'package:shop_list_app/presentation/widgets/meal_planning/carousel/test_file.dart';
import 'package:shop_list_app/presentation/pages/meal_planning/menu_composer_view.dart';
import 'package:shop_list_app/presentation/pages/meal_planning/menu_view.dart';
import 'package:shop_list_app/presentation/pages/recipes/recipe_list_view.dart';
import 'package:shop_list_app/shared/widgets/settings_view_page.dart';
import 'package:shop_list_app/presentation/pages/shopping/product_view_page.dart';
import 'package:shop_list_app/presentation/pages/shopping/product_category_view_page.dart';
import '../main.dart' show SplashScreen;

Route<dynamic> generateRoute(RouteSettings settings) {
  //final args = settings.arguments;

  switch (settings.name) {
    case splashView:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case mainView:
      return MaterialPageRoute(builder: (context) => MainView());
    case aboutView:
      return MaterialPageRoute(builder: (context) => AboutView());
    case menuView:
      return MaterialPageRoute(builder: (context) => MenuView());
    case settingsView:
      return MaterialPageRoute(builder: (context) => SettingsView());
    case recipesView:
      return MaterialPageRoute(builder: (context) => RecipeListView());
    case productView:
      return MaterialPageRoute(builder: (context) => ProductViewPage());
    case productCategoryView:
      return MaterialPageRoute(
          builder: (context) => const ProductCategoryViewPage());
    case menuComposer:
      return MaterialPageRoute(builder: (context) => MenuComposerView());
    case filterSelector:
      return MaterialPageRoute(
          builder: (context) => const ExampleInstagramFilterSelection());
    default:
      return MaterialPageRoute(builder: (context) => ErrorView());
  }
}
