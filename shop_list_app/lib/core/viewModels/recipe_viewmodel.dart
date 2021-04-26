import 'package:shop_list_app/core/repository/recipe_repository.dart';
import 'package:shop_list_app/service/models/recipe.dart';

class RecipeViewModel {
  RecipeRepository repository;

  RecipeViewModel() {
    repository = new RecipeRepository();
  }

  Future<List<Recipe>> getItemList() async {
    return await repository.getRecipesList();
  }

  void addItem(Recipe recipe) {
    repository.addRecipe(recipe);
  }

  void removeItem(Recipe recipe) {
    repository.deleteRecipe(recipe);
  }
}
