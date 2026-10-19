import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shop_list_app/core/constants/units.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_type.dart';

import 'connection/connection.dart' as impl;
import 'seeder/seed_service.dart';
import 'tables/app_meta_table.dart';
import 'tables/meal_plan_table.dart';
import 'tables/meal_slot_table.dart';
import 'tables/pantry_table.dart';
import 'tables/product_category_table.dart';
import 'tables/product_table.dart';
import 'tables/recipe_ingredient_table.dart';
import 'tables/recipe_table.dart';
import 'tables/shopping_item_table.dart';
import 'tables/shopping_list_table.dart';
import 'tables/sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProductCategories,
  Products,
  Recipes,
  RecipeIngredients,
  SyncQueue,
  ShoppingLists,
  ShoppingItems,
  MealPlans,
  MealSlots,
  PantryItems,
  AppMeta,
])
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  // Private constructor
  AppDatabase._internal() : super(impl.openConnection());

  // Factory constructor for backward compatibility
  factory AppDatabase() => instance;

  /// Factory constructor for tests: accepts any [QueryExecutor] (e.g. NativeDatabase.memory()).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  /// Step-by-step migration strategy.
  ///
  /// v1 → v2:  initial data tables (ProductCategories, Products, Recipes).
  /// v2 → v3:  sync_queue table (post-MVP cloud sync).
  /// v3 → v4:  colorHex, iconName, sortOrder, timestamps on product_categories.
  /// v4 → v5:  image_name on product_categories.
  /// v5 → v6:  shopping_lists + shopping_items.
  /// v6 → v7:  description, cook_time, servings, image_url, rating, tags_json,
  ///           ingredients_json on recipes.
  /// v7 → v8:  meal_plans + meal_slots.
  /// v8 → v9:  pantry_items.
  /// v9 → v10: category on recipes.
  /// v10 → v11: product catalogue redesign — products lose quantity/expiry and
  ///           gain default_unit/aliases/is_built_in; recipe ingredients move
  ///           from a JSON column into the recipe_ingredients table; recipes
  ///           gain is_built_in/seed_key/timestamps; app_meta table added.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        AppLogger.instance.info('[DB] onUpgrade from=$from to=$to');
        // Table rebuilds below must not trip foreign key checks.
        await customStatement('PRAGMA foreign_keys = OFF');

        if (from < 3) {
          await _tryCreateTable(m, syncQueue, 'sync_queue');
        }
        if (from < 4) {
          await _tryAddColumn(m, productCategories, productCategories.colorHex);
          await _tryAddColumn(m, productCategories, productCategories.iconName);
          await _tryAddColumn(
              m, productCategories, productCategories.sortOrder);
          await _tryAddColumn(
              m, productCategories, productCategories.createdAt);
          await _tryAddColumn(
              m, productCategories, productCategories.updatedAt);
          final nowMillis = DateTime.now().millisecondsSinceEpoch;
          await customStatement(
            'UPDATE product_categories SET created_at = $nowMillis '
            "WHERE typeof(created_at) != 'integer'",
          );
          await customStatement(
            'UPDATE product_categories SET updated_at = $nowMillis '
            "WHERE typeof(updated_at) != 'integer'",
          );
        }
        if (from < 5) {
          await _tryAddColumn(
              m, productCategories, productCategories.imageName);
        }
        if (from < 6) {
          await _tryCreateTable(m, shoppingLists, 'shopping_lists');
          await _tryCreateTable(m, shoppingItems, 'shopping_items');
        }
        if (from < 7) {
          for (final col in const {
            'description': 'TEXT',
            'cook_time': 'INTEGER',
            'servings': 'INTEGER',
            'image_url': 'TEXT',
            'rating': 'REAL',
            'tags_json': 'TEXT',
            'ingredients_json': 'TEXT',
          }.entries) {
            await _tryRawAddColumn('recipes', col.key, col.value);
          }
        }
        if (from < 8) {
          await _tryCreateTable(m, mealPlans, 'meal_plans');
          await _tryCreateTable(m, mealSlots, 'meal_slots');
        }
        if (from < 9) {
          await _tryCreateTable(m, pantryItems, 'pantry_items');
        }
        if (from < 10) {
          await _tryRawAddColumn('recipes', 'category', 'TEXT');
        }
        if (from < 11) {
          await _migrateToV11(m);
        }
        AppLogger.instance.info('[DB] onUpgrade complete');
      },
      beforeOpen: (details) async {
        AppLogger.instance.info(
          '[DB] Opening — schemaVersion=${details.versionNow}, '
          'wasCreated=${details.wasCreated}, '
          'hadUpgrade=${details.hadUpgrade}',
        );
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ── v11 ────────────────────────────────────────────────────────────────────

  Future<void> _migrateToV11(Migrator m) async {
    await _tryCreateTable(m, appMeta, 'app_meta');
    await _tryAddColumn(m, productCategories, productCategories.isBuiltIn);

    // Products: rebuild without quantity/expiration_date, renaming units.
    await m.alterTable(TableMigration(
      products,
      columnTransformer: {
        products.defaultUnit: const CustomExpression<String>(
            "COALESCE(NULLIF(TRIM(units), ''), 'pcs')"),
        products.photo: const CustomExpression<String>("NULLIF(photo, '')"),
      },
    ));
    await m.createIndex(idxProductsName);
    await m.createIndex(idxProductsCategory);

    // Recipe ingredients: new table, filled from the old JSON column.
    await _tryCreateTable(m, recipeIngredients, 'recipe_ingredients');
    await _copyIngredientsFromJson();

    // Recipes: drop ingredients_json, add built-in bookkeeping columns.
    await m.alterTable(TableMigration(
      recipes,
      columnTransformer: {
        recipes.favorite:
            const CustomExpression<bool>('COALESCE(favorite, 0)'),
      },
    ));
    await m.createIndex(idxRecipesName);
    await m.createIndex(idxRecipesCategory);
    await m.createIndex(idxRecipeIngredientsRecipe);
    await m.createIndex(idxRecipeIngredientsProduct);
    AppLogger.instance.info('[DB] onUpgrade v10→v11 complete');
  }

  /// Reads `recipes.ingredients_json` (pre-v11) and inserts one
  /// `recipe_ingredients` row per entry. Quantities that are not numbers
  /// ("to taste") become notes; units are normalised.
  Future<void> _copyIngredientsFromJson() async {
    final rows = await customSelect(
      'SELECT id, ingredients_json FROM recipes '
      'WHERE ingredients_json IS NOT NULL',
    ).get();

    final companions = <RecipeIngredientsCompanion>[];
    for (final row in rows) {
      final recipeId = row.read<int>('id');
      final raw = row.read<String?>('ingredients_json');
      if (raw == null || raw.isEmpty) continue;
      List<dynamic> list;
      try {
        list = jsonDecode(raw) as List<dynamic>;
      } catch (_) {
        continue;
      }
      for (var i = 0; i < list.length; i++) {
        final map = list[i];
        if (map is! Map) continue;
        final name = (map['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        final rawQty = (map['quantity'] ?? '').toString().trim();
        final qty = double.tryParse(rawQty.replaceAll(',', '.'));
        companions.add(RecipeIngredientsCompanion.insert(
          recipeId: recipeId,
          name: name,
          quantity: Value(qty),
          unit: Value(Units.normalize(map['unit'] as String?)),
          note: Value(qty == null && rawQty.isNotEmpty ? rawQty : null),
          sortOrder: Value(i),
        ));
      }
    }
    if (companions.isNotEmpty) {
      await batch((b) => b.insertAll(recipeIngredients, companions));
    }
    AppLogger.instance.info(
        '[DB] Copied ${companions.length} ingredient rows from JSON');
  }

  // ── Migration helpers ──────────────────────────────────────────────────────

  Future<void> _tryCreateTable(
      Migrator m, TableInfo table, String label) async {
    try {
      await m.createTable(table);
      AppLogger.instance.info('[DB] Created $label table');
    } catch (e) {
      AppLogger.instance.warning('[DB] $label already exists (skipped)',
          error: e);
    }
  }

  Future<void> _tryAddColumn(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    try {
      await m.addColumn(table, column);
      AppLogger.instance.info('[DB] Added column ${column.name}');
    } catch (e) {
      AppLogger.instance.warning(
          '[DB] Column ${column.name} already exists (skipped)',
          error: e);
    }
  }

  Future<void> _tryRawAddColumn(String table, String column, String type) async {
    try {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
      AppLogger.instance.info('[DB] Added column $column to $table');
    } catch (e) {
      AppLogger.instance.warning(
          '[DB] Column $column already exists in $table (skipped)',
          error: e);
    }
  }

  // ── Seeding ────────────────────────────────────────────────────────────────

  /// Applies bundled seed data when the database is behind the bundled seed
  /// version. Safe to call on every launch — it is a no-op otherwise.
  Future<void> ensureInitialized() async {
    try {
      final result = await SeedService(this).run();
      AppLogger.instance.info('[Database] $result');
    } catch (e, stackTrace) {
      AppLogger.instance.error(
        '[Database] Error during seeding',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
