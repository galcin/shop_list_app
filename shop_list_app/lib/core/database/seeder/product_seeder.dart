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
        expirationDate: now.add(const Duration(days: 14)),
        productCategoryId: 1, // Fruits
      ),
      ProductsCompanion.insert(
        name: 'Bananas',
        quantity: 2.0,
        units: 'kg',
        photo: '🍌',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 1, // Fruits
      ),
      ProductsCompanion.insert(
        name: 'Carrots',
        quantity: 3.0,
        units: 'kg',
        photo: '🥕',
        expirationDate: now.add(const Duration(days: 21)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Tomatoes',
        quantity: 1.5,
        units: 'kg',
        photo: '🍅',
        expirationDate: now.add(const Duration(days: 10)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Milk',
        quantity: 2.0,
        units: 'liters',
        photo: '🥛',
        expirationDate: now.add(const Duration(days: 5)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Cheese',
        quantity: 0.5,
        units: 'kg',
        photo: '🧀',
        expirationDate: now.add(const Duration(days: 30)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Bread',
        quantity: 2.0,
        units: 'loaves',
        photo: '🍞',
        expirationDate: now.add(const Duration(days: 3)),
        productCategoryId: 4, // Bakery
      ),
      ProductsCompanion.insert(
        name: 'Chicken Breast',
        quantity: 1.0,
        units: 'kg',
        photo: '🍗',
        expirationDate: now.add(const Duration(days: 4)),
        productCategoryId: 5, // Meat
      ),
      ProductsCompanion.insert(
        name: 'Orange Juice',
        quantity: 1.0,
        units: 'liters',
        photo: '🧃',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 6, // Beverages
      ),
      ProductsCompanion.insert(
        name: 'Potato Chips',
        quantity: 3.0,
        units: 'bags',
        photo: '🥔',
        expirationDate: now.add(const Duration(days: 60)),
        productCategoryId: 7, // Snacks
      ),

      // ── Dairy ──────────────────────────────────────────────────────────────
      ProductsCompanion.insert(
        name: 'Eggs',
        quantity: 12.0,
        units: 'pcs',
        photo: '🥚',
        expirationDate: now.add(const Duration(days: 21)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Butter',
        quantity: 200.0,
        units: 'g',
        photo: '🧈',
        expirationDate: now.add(const Duration(days: 30)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Sour Cream',
        quantity: 200.0,
        units: 'ml',
        photo: '🥛',
        expirationDate: now.add(const Duration(days: 10)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Cooking Cream',
        quantity: 200.0,
        units: 'ml',
        photo: '🥛',
        expirationDate: now.add(const Duration(days: 10)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Fresh Mozzarella',
        quantity: 125.0,
        units: 'g',
        photo: '🧀',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 3, // Dairy
      ),
      ProductsCompanion.insert(
        name: 'Parmesan',
        quantity: 100.0,
        units: 'g',
        photo: '🧀',
        expirationDate: now.add(const Duration(days: 60)),
        productCategoryId: 3, // Dairy
      ),

      // ── Meat ───────────────────────────────────────────────────────────────
      ProductsCompanion.insert(
        name: 'Minced Beef',
        quantity: 500.0,
        units: 'g',
        photo: '🥩',
        expirationDate: now.add(const Duration(days: 2)),
        productCategoryId: 5, // Meat
      ),
      ProductsCompanion.insert(
        name: 'Bacon',
        quantity: 200.0,
        units: 'g',
        photo: '🥓',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 5, // Meat
      ),
      ProductsCompanion.insert(
        name: 'Turkey Breast',
        quantity: 400.0,
        units: 'g',
        photo: '🍗',
        expirationDate: now.add(const Duration(days: 3)),
        productCategoryId: 5, // Meat
      ),
      ProductsCompanion.insert(
        name: 'Pressed Ham',
        quantity: 200.0,
        units: 'g',
        photo: '🍖',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 5, // Meat
      ),

      // ── Vegetables ─────────────────────────────────────────────────────────
      ProductsCompanion.insert(
        name: 'Onion',
        quantity: 5.0,
        units: 'pcs',
        photo: '🧅',
        expirationDate: now.add(const Duration(days: 30)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Garlic',
        quantity: 3.0,
        units: 'heads',
        photo: '🧄',
        expirationDate: now.add(const Duration(days: 30)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Celery',
        quantity: 1.0,
        units: 'bunch',
        photo: '🥬',
        expirationDate: now.add(const Duration(days: 10)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Zucchini',
        quantity: 2.0,
        units: 'pcs',
        photo: '🥒',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Potatoes',
        quantity: 2.0,
        units: 'kg',
        photo: '🥔',
        expirationDate: now.add(const Duration(days: 30)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Bell Peppers',
        quantity: 3.0,
        units: 'pcs',
        photo: '🫑',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Broccoli',
        quantity: 1.0,
        units: 'head',
        photo: '🥦',
        expirationDate: now.add(const Duration(days: 5)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Lettuce',
        quantity: 1.0,
        units: 'head',
        photo: '🥬',
        expirationDate: now.add(const Duration(days: 5)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Cucumber',
        quantity: 2.0,
        units: 'pcs',
        photo: '🥒',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Cherry Tomatoes',
        quantity: 250.0,
        units: 'g',
        photo: '🍅',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Mushrooms',
        quantity: 300.0,
        units: 'g',
        photo: '🍄',
        expirationDate: now.add(const Duration(days: 5)),
        productCategoryId: 2, // Vegetables
      ),
      ProductsCompanion.insert(
        name: 'Frozen Vegetables',
        quantity: 400.0,
        units: 'g',
        photo: '🥦',
        expirationDate: now.add(const Duration(days: 180)),
        productCategoryId: 2, // Vegetables
      ),

      // ── Fruits ─────────────────────────────────────────────────────────────
      ProductsCompanion.insert(
        name: 'Lemon',
        quantity: 3.0,
        units: 'pcs',
        photo: '🍋',
        expirationDate: now.add(const Duration(days: 14)),
        productCategoryId: 1, // Fruits
      ),

      // ── Bakery ─────────────────────────────────────────────────────────────
      ProductsCompanion.insert(
        name: 'Flatbread',
        quantity: 4.0,
        units: 'pcs',
        photo: '🫓',
        expirationDate: now.add(const Duration(days: 5)),
        productCategoryId: 4, // Bakery
      ),
      ProductsCompanion.insert(
        name: 'Puff Pastry Dough',
        quantity: 400.0,
        units: 'g',
        photo: '🧇',
        expirationDate: now.add(const Duration(days: 7)),
        productCategoryId: 4, // Bakery
      ),

      // ── Pantry / Dry Goods & Condiments (Snacks category) ──────────────────
      ProductsCompanion.insert(
        name: 'Spaghetti',
        quantity: 500.0,
        units: 'g',
        photo: '🍝',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Pasta',
        quantity: 500.0,
        units: 'g',
        photo: '🍝',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Noodles',
        quantity: 250.0,
        units: 'g',
        photo: '🍜',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Rice',
        quantity: 1.0,
        units: 'kg',
        photo: '🍚',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Flour',
        quantity: 1.0,
        units: 'kg',
        photo: '🌾',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Rolled Oats',
        quantity: 500.0,
        units: 'g',
        photo: '🌾',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Honey',
        quantity: 350.0,
        units: 'g',
        photo: '🍯',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Olive Oil',
        quantity: 500.0,
        units: 'ml',
        photo: '🫙',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Vegetable Oil',
        quantity: 500.0,
        units: 'ml',
        photo: '🫙',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Soy Sauce',
        quantity: 150.0,
        units: 'ml',
        photo: '🫙',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Oyster Sauce',
        quantity: 150.0,
        units: 'ml',
        photo: '🫙',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Tomato Sauce',
        quantity: 350.0,
        units: 'g',
        photo: '🍅',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Tomato Paste',
        quantity: 140.0,
        units: 'g',
        photo: '🍅',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Crushed Tomatoes',
        quantity: 400.0,
        units: 'g',
        photo: '🍅',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Vegetable Broth',
        quantity: 1.0,
        units: 'liters',
        photo: '🍲',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Canned Tuna',
        quantity: 4.0,
        units: 'cans',
        photo: '🐟',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Canned Corn',
        quantity: 2.0,
        units: 'cans',
        photo: '🌽',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Canned Mushrooms',
        quantity: 2.0,
        units: 'cans',
        photo: '🍄',
        expirationDate: now.add(const Duration(days: 730)),
        productCategoryId: 7, // Snacks
      ),
      ProductsCompanion.insert(
        name: 'Olives',
        quantity: 200.0,
        units: 'g',
        photo: '🫒',
        expirationDate: now.add(const Duration(days: 365)),
        productCategoryId: 7, // Snacks
      ),
    ];

    await database.batch((batch) {
      batch.insertAll(database.products, defaultProducts);
    });
  }
}
