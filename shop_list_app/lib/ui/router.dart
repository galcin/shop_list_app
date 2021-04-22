import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/route_constants.dart';
import 'package:shop_list_app/ui/views/aboutView/about_view.dart';
import 'package:shop_list_app/ui/views/errorView/error_view.dart';
import 'package:shop_list_app/ui/views/mainView/main_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;

  switch (settings.name) {
    case mainView:
      return MaterialPageRoute(builder: (context) => MainView());
    case aboutView:
      return MaterialPageRoute(builder: (context) => AboutView());
    default:
      return MaterialPageRoute(builder: (context) => ErrorView());
  }
}
