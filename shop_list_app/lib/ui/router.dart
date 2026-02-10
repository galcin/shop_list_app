import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/route_constants.dart';
import 'package:shop_list_app/ui/views/aboutView/about_view.dart';
import 'package:shop_list_app/ui/views/errorView/error_view.dart';
import 'package:shop_list_app/ui/views/mainView/main_view.dart';
import 'package:shop_list_app/ui/views/menuComposer/components/carousel/test_file.dart';
import 'package:shop_list_app/ui/views/menuComposer/menu_composer_view.dart';
import 'package:shop_list_app/ui/views/menuView/menu_view.dart';
import 'package:shop_list_app/ui/views/recipes/recipe_list_view.dart';
import 'package:shop_list_app/ui/views/settingsView/settings_view_page.dart';
import 'package:shop_list_app/ui/views/productView/product_view_page.dart';
import 'package:shop_list_app/ui/views/productCategoryView/product_category_view_page.dart';
import '../main.dart' show SplashScreen;

Route<dynamic> generateRoute(RouteSettings settings) {
  //final args = settings.arguments;

  switch (settings.name) {
    case splashView:
      return MaterialPageRoute(builder: (context) => SplashScreen());
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
      return MaterialPageRoute(builder: (context) => ProductCategoryViewPage());
    case menuComposer:
      return MaterialPageRoute(builder: (context) => MenuComposerView());
    case filterSelector:
      return MaterialPageRoute(
          builder: (context) => ExampleInstagramFilterSelection());
    default:
      return MaterialPageRoute(builder: (context) => ErrorView());
  }
}
