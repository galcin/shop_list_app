import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/route_constants.dart';
import 'ui/router.dart' as router;

void main(List<String> args) {
  runApp(ShopingListApp());
}

class ShopingListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      onGenerateRoute: router.generateRoute,
      initialRoute: mainView,
    );
  }
}
