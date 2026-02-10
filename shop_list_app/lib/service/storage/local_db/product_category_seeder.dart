// product_category_seeder.dart
import 'package:drift/drift.dart';

import 'app_database.dart';

class ProductCategorySeeder {
  static Future<void> seedDefaultCategories(AppDatabase db) async {
    // Check if any categories exist (single query)
    final count = await db
        .customSelect('SELECT COUNT(*) as count FROM product_categories',
            readsFrom: {db.productCategories})
        .map((row) => row.read<int>('count'))
        .getSingle();

    if (count > 0) {
      return; // Already seeded
    }

    final defaultCategories = [
      ProductCategoriesCompanion.insert(
        name: 'Fruits',
        photo: Value('🍎'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Vegetables',
        photo: Value('🥕'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Dairy',
        photo: Value('🥛'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Bakery',
        photo: Value('🍞'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Meat',
        photo: Value('🥩'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Beverages',
        photo: Value('🥤'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Snacks',
        photo: Value('🍿'),
      ),
    ];

    // Batch insert all categories at once
    await db.batch((batch) {
      batch.insertAll(db.productCategories, defaultCategories);
    });
  }
}
