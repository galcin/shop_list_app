import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/route_constants.dart';
import 'package:shop_list_app/shared/widgets/menu_buttons.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Application'),
          actions: const [CustomMenuButtons()]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Actions'),
          const SizedBox(
            width: 20,
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Recipe list'),
              onPressed: () {
                Navigator.pushNamed(context, recipesView);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Products'),
              onPressed: () {
                Navigator.pushNamed(context, productView);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Product Categories'),
              onPressed: () {
                Navigator.pushNamed(context, productCategoryView);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Create Week Menu'),
              onPressed: () {
                Navigator.pushNamed(context, menuComposer);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Filter selector test'),
              onPressed: () {
                Navigator.pushNamed(context, filterSelector);
              },
            ),
          )
        ],
      ),
    );
  }
}
