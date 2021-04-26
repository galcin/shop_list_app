import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/viewModels/recipe_viewmodel.dart';
import 'package:shop_list_app/ui/views/recipes/list_tile_component.dart';

class RecipeListView extends StatelessWidget {
  final recipeViewModel = new RecipeViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe list"),
      ),
      body: FutureBuilder(
        future: recipeViewModel.getItemList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
          } else if (snapshot.hasError) {}
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ListTileComponent(snapshot.data[index]);
            },
          );
        },
      ),
    );
  }
}
