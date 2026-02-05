import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'product_category_table.dart';
import 'product_table.dart';
import 'recipe_table.dart';
import 'recipe_seeder.dart';
import 'product_category_seeder.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProductCategories, Products, Recipes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection()) {
    _seedDefaultData();
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'shop_list_db');
  }

  Future<void> _seedDefaultData() async {
    await ProductCategorySeeder.seedDefaultCategories(this);
    await RecipeSeeder.seedDefaultRecipes(this);
  }
}
