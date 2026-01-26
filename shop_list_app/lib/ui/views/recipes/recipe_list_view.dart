import 'package:flutter/material.dart';
import 'package:shop_list_app/core/viewModels/recipe_viewmodel.dart';
import 'package:shop_list_app/service/models/recipe.dart';
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
          initialData: [],
          future: recipeViewModel.getItemList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final _data = snapshot.data as List<Recipe>;
              return ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return ListTileComponent(_data[index]);
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
