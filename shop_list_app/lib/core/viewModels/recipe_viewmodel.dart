import 'package:shop_list_app/core/repository/recipe_repository.dart';
import 'package:shop_list_app/service/models/recipe.dart';

class RecipeViewModel {
  Future<List<Recipe>> getItemList() {
    return RecipeRepository.getRecipesList();
  }

  void addItem(Recipe recipe) {
    RecipeRepository.addRecipe(recipe);
  }

  void removeItem(Recipe recipe) {
    RecipeRepository.deleteRecipe(recipe);
  }
}
