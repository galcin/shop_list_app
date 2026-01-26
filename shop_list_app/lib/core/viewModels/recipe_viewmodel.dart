import '../../service/models/recipe.dart';
import '../repository/recipe_repository.dart';

class RecipeViewModel {
  RecipeRepository repository = new RecipeRepository();

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
