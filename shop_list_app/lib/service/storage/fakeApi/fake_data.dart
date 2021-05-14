import 'package:shop_list_app/service/models/recipe.dart';

class FakeData {
  static List<Recipe> fakeList = [];

  static Future<void> seedData() async {
    fakeList.add(new Recipe(
        name: 'recipe1', photo: 'photo1', description: 'descr 1', id: 1));
    fakeList.add(new Recipe(
        name: 'recipe2', photo: 'photo2', description: 'descr 2', id: 1));
    fakeList.add(new Recipe(
        name: 'recipe3', photo: 'photo3', description: 'descr 3', id: 1));
    fakeList.add(new Recipe(
        name: 'recipe4', photo: 'photo4', description: 'descr 4', id: 1));
  }
}
