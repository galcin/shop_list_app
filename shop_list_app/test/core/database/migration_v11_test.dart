import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Builds an in-memory database shaped like schema v10 (the last version
/// before the product catalogue redesign) with representative data, then
/// opens it through [AppDatabase] so the v10 → v11 migration runs.
void main() {
  late sqlite.Database raw;
  late AppDatabase db;

  setUp(() {
    raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE product_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photo TEXT,
        color_hex TEXT,
        icon_name TEXT,
        image_name TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        units TEXT NOT NULL,
        photo TEXT NOT NULL,
        expiration_date INTEGER NOT NULL,
        product_category_id INTEGER NOT NULL REFERENCES product_categories (id)
      );
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category TEXT,
        instructions TEXT,
        prep_time INTEGER,
        cook_time INTEGER,
        servings INTEGER,
        favorite INTEGER,
        image_url TEXT,
        rating REAL,
        tags_json TEXT,
        ingredients_json TEXT
      );
      CREATE TABLE sync_queue (
        id TEXT NOT NULL PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        error TEXT
      );
      CREATE TABLE shopping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL REFERENCES shopping_lists (id) ON DELETE CASCADE,
        product_id INTEGER REFERENCES products (id) ON DELETE SET NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1.0,
        unit TEXT NOT NULL DEFAULT 'pcs',
        is_checked INTEGER NOT NULL DEFAULT 0,
        category_id INTEGER REFERENCES product_categories (id) ON DELETE SET NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
      CREATE TABLE meal_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
      CREATE TABLE meal_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL REFERENCES meal_plans (id) ON DELETE CASCADE,
        date INTEGER NOT NULL,
        meal_type INTEGER NOT NULL,
        recipe_id INTEGER REFERENCES recipes (id) ON DELETE SET NULL,
        custom_name TEXT,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
      CREATE TABLE pantry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER REFERENCES products (id),
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        category_id INTEGER NOT NULL REFERENCES product_categories (id),
        expiry_date INTEGER,
        purchased_date INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        location TEXT,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      );
      PRAGMA user_version = 10;
    ''');

    raw.execute(
        "INSERT INTO product_categories (id, name, photo, created_at, updated_at) "
        "VALUES (1, 'Vegetables', '🥕', 0, 0)");
    raw.execute(
        "INSERT INTO products (id, name, quantity, units, photo, expiration_date, product_category_id) "
        "VALUES (7, 'Carrots', 3.0, 'kg', '🥕', 0, 1)");
    raw.execute(
        "INSERT INTO products (id, name, quantity, units, photo, expiration_date, product_category_id) "
        "VALUES (8, 'Mystery', 1.0, '', '', 0, 1)");
    raw.execute(
        "INSERT INTO recipes (id, name, category, favorite, ingredients_json) VALUES "
        "(3, 'Chicken Soup', 'Soups', 1, "
        "'[{\"name\":\"Chicken\",\"quantity\":\"500\",\"unit\":\"g\"},"
        "{\"name\":\"Carrots\",\"quantity\":\"2\",\"unit\":\"pcs\"},"
        "{\"name\":\"Salt\",\"quantity\":\"to taste\",\"unit\":\"\"},"
        "{\"name\":\"Celery\",\"quantity\":\"2\",\"unit\":\"stalks\"}]')");
    raw.execute(
        "INSERT INTO recipes (id, name, favorite, ingredients_json) VALUES (4, 'Empty', NULL, NULL)");
    raw.execute("INSERT INTO meal_plans (id, week_start_date) VALUES (1, 0)");
    raw.execute(
        "INSERT INTO meal_slots (plan_id, date, meal_type, recipe_id) VALUES (1, 0, 0, 3)");
    raw.execute("INSERT INTO shopping_lists (id, name) VALUES (1, 'Weekly')");
    raw.execute(
        "INSERT INTO shopping_items (list_id, product_id, name) VALUES (1, 7, 'Carrots')");
    raw.execute(
        "INSERT INTO pantry_items (product_id, name, quantity, unit, category_id) "
        "VALUES (7, 'Carrots', 2, 'pcs', 1)");

    db = AppDatabase.forTesting(NativeDatabase.opened(raw));
  });

  tearDown(() => db.close());

  test('upgrades v10 data to the v11 schema without losing rows', () async {
    // Any query triggers the migration.
    final products = await db.select(db.products).get();
    expect(products, hasLength(2));

    final carrots = products.firstWhere((p) => p.id == 7);
    expect(carrots.defaultUnit, 'kg');
    expect(carrots.photo, '🥕');
    expect(carrots.isBuiltIn, isFalse);
    final mystery = products.firstWhere((p) => p.id == 8);
    expect(mystery.defaultUnit, 'pcs', reason: 'blank unit gets a default');
    expect(mystery.photo, isNull, reason: 'blank photo becomes null');

    final recipes = await db.select(db.recipes).get();
    expect(recipes, hasLength(2));
    final soup = recipes.firstWhere((r) => r.id == 3);
    expect(soup.favorite, isTrue);
    expect(soup.isBuiltIn, isFalse);
    expect(soup.seedKey, isNull);
    expect(recipes.firstWhere((r) => r.id == 4).favorite, isFalse);

    final ingredients = await (db.select(db.recipeIngredients)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    expect(ingredients.map((i) => i.name),
        ['Chicken', 'Carrots', 'Salt', 'Celery']);
    expect(ingredients[0].quantity, 500);
    expect(ingredients[0].unit, 'g');
    expect(ingredients[2].quantity, isNull);
    expect(ingredients[2].note, 'to taste');
    expect(ingredients[3].unit, 'stalk', reason: 'units are normalised');
    expect(ingredients.every((i) => i.recipeId == 3), isTrue);

    // Foreign keys from other tables still point at the rebuilt tables.
    final slot = await db.select(db.mealSlots).getSingle();
    expect(slot.recipeId, 3);
    final item = await db.select(db.shoppingItems).getSingle();
    expect(item.productId, 7);
    final pantry = await db.select(db.pantryItems).getSingle();
    expect(pantry.productId, 7);

    // New bookkeeping table exists and is empty (seed has not run).
    expect(await db.select(db.appMeta).get(), isEmpty);

    // Cascades keep working after the rebuild.
    await (db.delete(db.recipes)..where((t) => t.id.equals(3))).go();
    expect(await db.select(db.recipeIngredients).get(), isEmpty);
    expect((await db.select(db.mealSlots).getSingle()).recipeId, isNull);
  });
}
