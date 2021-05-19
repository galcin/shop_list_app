import 'package:flutter/cupertino.dart';
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

import 'route_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;

  switch (settings.name) {
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
    case menuComposer:
      return MaterialPageRoute(builder: (context) => MenuComposerView());
    case filterSelector:
      return MaterialPageRoute(
          builder: (context) => ExampleInstagramFilterSelection());
    default:
      return MaterialPageRoute(builder: (context) => ErrorView());
  }
}
