// product_category_seeder.dart
import 'package:drift/drift.dart';

import '../app_database.dart';

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
        photo: const Value('🍎'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Vegetables',
        photo: const Value('🥕'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Dairy',
        photo: const Value('🥛'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Bakery',
        photo: const Value('🍞'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Meat',
        photo: const Value('🥩'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Beverages',
        photo: const Value('🥤'),
      ),
      ProductCategoriesCompanion.insert(
        name: 'Snacks',
        photo: const Value('🍿'),
      ),
    ];

    // Batch insert all categories at once
    await db.batch((batch) {
      batch.insertAll(db.productCategories, defaultCategories);
    });
  }
}
