import 'package:shop_list_app/service/models/recipe.dart';

class FakeData {
  static List<Recipe> fakeList = new List<Recipe>();

  static Future<void> seedData() async {
    fakeList.add(new Recipe('recipe1', 'photo1', 'descr 1', 1));
    fakeList.add(new Recipe('recipe2', 'photo2', 'descr 2', 1));
    fakeList.add(new Recipe('recipe3', 'photo3', 'descr 3', 1));
    fakeList.add(new Recipe('recipe4', 'photo4', 'descr 4', 1));
  }
}
