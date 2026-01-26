import 'package:shop_list_app/service/storage/local_db/app_database.dart';

class IngredientsViewModel {
  final AppDatabase _db;
  IngredientsViewModel(this._db);

  Future<List<Ingredient>> getAllIngredients() => _db.getAllIngredients();
}
