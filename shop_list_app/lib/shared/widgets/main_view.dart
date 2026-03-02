import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/route_constants.dart';
import 'package:shop_list_app/shared/widgets/menu_buttons.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Application'), actions: [CustomMenuButtons()]),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Actions"),
            SizedBox(
              width: 20,
            ),
            Center(
              child: ElevatedButton(
                child: Text("Recipe list"),
                onPressed: () {
                  Navigator.pushNamed(context, recipesView);
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Products"),
                onPressed: () {
                  Navigator.pushNamed(context, productView);
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Product Categories"),
                onPressed: () {
                  Navigator.pushNamed(context, productCategoryView);
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Create Week Menu"),
                onPressed: () {
                  Navigator.pushNamed(context, menuComposer);
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Filter selector test"),
                onPressed: () {
                  Navigator.pushNamed(context, filterSelector);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
