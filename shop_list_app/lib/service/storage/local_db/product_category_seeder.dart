// product_category_seeder.dart
import 'app_database.dart';

class ProductCategorySeeder {
  static Future<void> seedDefaultCategories(AppDatabase db) async {
    final defaultCategories = [
      'Fruits',
      'Vegetables',
      'Dairy',
      'Bakery',
      'Meat',
      'Beverages',
      'Snacks',
    ];

    for (final name in defaultCategories) {
      final exists = await (db.select(db.productCategories)
            ..where((tbl) => tbl.name.equals(name)))
          .getSingleOrNull();

      if (exists == null) {
        await db.into(db.productCategories).insert(
              ProductCategoriesCompanion.insert(name: name),
            );
      }
    }
  }
}
