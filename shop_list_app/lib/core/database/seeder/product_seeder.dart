import 'package:shop_list_app/core/database/app_database.dart';

class ProductSeeder {
  static Future<void> seedDefaultProducts(AppDatabase database) async {
    // Check if any products exist (single query)
    final count = await database
        .customSelect('SELECT COUNT(*) as count FROM products',
            readsFrom: {database.products})
        .map((row) => row.read<int>('count'))
        .getSingle();

    if (count > 0) {
      return; // Already seeded
    }

    final now = DateTime.now();

    final defaultProducts = [
      ProductsCompanion.insert(
        name: 'Apples',
        quantity: 5.0,
        units: 'kg',
        photo: '🍎',
        expirationDate: now.add(Duration(days: 14)),
        productCategoryId: 1, // Fruits
      ),
      ProductsCompanion.insert(
        name: 'Bananas',
        quantity: 2.0,
        units: 'kg',
        photo: '🍌',
        expirationDate: now.add(Duration(days: 7)),
        productCategoryId: 1, // Fruits
      ),
      ProductsCompanion.insert(
        name: 'Carrots',
        quantity: 3.0,
        units: 'kg',
        photo: '🥕',
        expirationDate: now.add(Duration(days: 21)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Tomatoes',
        quantity: 1.5,
        units: 'kg',
        photo: '🍅',
        expirationDate: now.add(Duration(days: 10)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Milk',
        quantity: 2.0,
        units: 'liters',
        photo: '🥛',
        expirationDate: now.add(Duration(days: 5)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Cheese',
        quantity: 0.5,
        units: 'kg',
        photo: '🧀',
        expirationDate: now.add(Duration(days: 30)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Bread',
        quantity: 2.0,
        units: 'loaves',
        photo: '🍞',
        expirationDate: now.add(Duration(days: 3)),
        productCategoryId: 4, // Bakery
      ),
      ProductsCompanion.insert(
        name: 'Chicken Breast',
        quantity: 1.0,
        units: 'kg',
        photo: '🍗',
        expirationDate: now.add(Duration(days: 4)),
        productCategoryId: 5, // Meat
      ),
      ProductsCompanion.insert(
        name: 'Orange Juice',
        quantity: 1.0,
        units: 'liters',
        photo: '🧃',
        expirationDate: now.add(Duration(days: 7)),
        productCategoryId: 6, // Beverages
      ),
      ProductsCompanion.insert(
        name: 'Potato Chips',
        quantity: 3.0,
        units: 'bags',
        photo: '🥔',
        expirationDate: now.add(Duration(days: 60)),
        productCategoryId: 7, // Snacks
      ),
    ];

    await database.batch((batch) {
      batch.insertAll(database.products, defaultProducts);
    });
  }
}
