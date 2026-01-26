import '../../service/models/recipe.dart';
import '../../service/storage/fakeApi/fake_data.dart';

class RecipeRepository {
  RecipeRepository() {
    FakeData.seedData();
  }

  Future<List<Recipe>> getRecipesList() async {
    return FakeData.fakeList;
  }

  Future<void> addRecipe(Recipe recipe) async {
    FakeData.fakeList.add(recipe);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    deleteRecipe(recipe);
    addRecipe(recipe);
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    FakeData.fakeList.removeWhere((x) => x.id == recipe.id);
  }
}
