import 'package:shop_list_app/service/models/recipe.dart';
import 'package:shop_list_app/service/storage/fakeApi/fake_data.dart';

class RecipeRepository {
  static Future<List<Recipe>> getRecipesList() async {
    return FakeData.fakeList;
  }

  static Future<void> addRecipe(Recipe recipe) async {
    FakeData.fakeList.add(recipe);
  }

  static Future<void> updateRecipe(Recipe recipe) async {
    deleteRecipe(recipe);
    addRecipe(recipe);
  }

  static Future<void> deleteRecipe(Recipe recipe) async {
    FakeData.fakeList.removeWhere((x) => x.id == recipe.id);
  }
}
