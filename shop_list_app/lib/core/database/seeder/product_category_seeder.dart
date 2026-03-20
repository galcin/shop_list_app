// product_category_seeder.dart
import 'package:drift/drift.dart';

import '../app_database.dart';

class ProductCategorySeeder {
  /// Maps default category names to their asset image filenames.
  /// Categories not listed here have no image and will fall back to the emoji.
  static const Map<String, String> _categoryImages = {
    'Fruits': 'fruits_category.png',
    'Vegetables': 'vegetables_category.png',
    'Dairy': 'dairy_category.png',
    'Bakery': 'Bakery_category.png',
    'Meat': 'meat_category.png',
    'Oil': 'oil_category.png',
  };

  static Future<void> seedDefaultCategories(AppDatabase db) async {
    // Check if any categories exist (single query)
    final count = await db
        .customSelect('SELECT COUNT(*) as count FROM product_categories',
            readsFrom: {db.productCategories})
        .map((row) => row.read<int>('count'))
        .getSingle();

    if (count == 0) {
      // Fresh install – insert all default categories.
      final defaultCategories = [
        ProductCategoriesCompanion.insert(
          name: 'Fruits',
          photo: const Value('🍎'),
          imageName: const Value('fruits_category.png'),
        ),
        ProductCategoriesCompanion.insert(
          name: 'Vegetables',
          photo: const Value('🥕'),
          imageName: const Value('vegetables_category.png'),
        ),
        ProductCategoriesCompanion.insert(
          name: 'Dairy',
          photo: const Value('🥛'),
          imageName: const Value('dairy_category.png'),
        ),
        ProductCategoriesCompanion.insert(
          name: 'Bakery',
          photo: const Value('🍞'),
          imageName: const Value('Bakery_category.png'),
        ),
        ProductCategoriesCompanion.insert(
          name: 'Meat',
          photo: const Value('🥩'),
          imageName: const Value('meat_category.png'),
        ),
        ProductCategoriesCompanion.insert(
          name: 'Beverages',
          photo: const Value('🥤'),
          // No image available – falls back to emoji.
        ),
        ProductCategoriesCompanion.insert(
          name: 'Snacks',
          photo: const Value('🍿'),
          // No image available – falls back to emoji.
        ),
      ];

      await db.batch((batch) {
        batch.insertAll(db.productCategories, defaultCategories);
      });
    } else {
      // Already seeded – back-fill image_name for default categories that are
      // missing it (handles upgrades from earlier app versions).
      await _backfillImageNames(db);
    }
  }

  /// Updates existing default category rows that have no image_name set yet.
  static Future<void> _backfillImageNames(AppDatabase db) async {
    for (final entry in _categoryImages.entries) {
      await (db.update(db.productCategories)
            ..where(
              (t) => t.name.equals(entry.key) & t.imageName.isNull(),
            ))
          .write(ProductCategoriesCompanion(imageName: Value(entry.value)));
    }
  }
}
