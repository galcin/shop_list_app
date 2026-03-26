import 'package:drift/drift.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'tables/product_category_table.dart';
import 'tables/product_table.dart';
import 'tables/recipe_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/shopping_list_table.dart';
import 'tables/shopping_item_table.dart';
import 'seeder/recipe_seeder.dart';
import 'seeder/product_category_seeder.dart';
import 'seeder/product_seeder.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProductCategories,
  Products,
  Recipes,
  SyncQueue,
  ShoppingLists,
  ShoppingItems
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
  int get schemaVersion => 6;

  /// Step-by-step migration strategy.
  ///
  /// v1 → v2: initial data-table additions (ProductCategories, Products, Recipes).
  /// v2 → v3: add sync_queue table to support Post-MVP cloud sync (US-E0.2).
  /// v3 → v4: add colorHex, iconName, sortOrder, createdAt, updatedAt to
  ///           product_categories for E2 feature (US-E2.1 – US-E2.3).
  /// v4 → v5: add image_name to product_categories for asset image support.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // Called when the database is created for the first time.
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      // Called for each schema version increment above the stored version.
      onUpgrade: (Migrator m, int from, int to) async {
        AppLogger.instance.info('[DB] onUpgrade from=$from to=$to');

        // v2 → v3: create the SyncQueue table.
        if (from < 3) {
          try {
            await m.createTable(syncQueue);
            AppLogger.instance.info('[DB] Created sync_queue table');
          } catch (e) {
            AppLogger.instance
                .warning('[DB] sync_queue already exists (skipped)', error: e);
          }
        }

        // v3 → v4: add new columns to ProductCategories.
        if (from < 4) {
          Future<void> tryAdd(
              String colName, Future<void> Function() fn) async {
            try {
              await fn();
              AppLogger.instance.info('[DB] Added column $colName');
            } catch (e) {
              AppLogger.instance.warning(
                  '[DB] Column $colName already exists (skipped)',
                  error: e);
            }
          }

          await tryAdd('color_hex',
              () => m.addColumn(productCategories, productCategories.colorHex));
          await tryAdd('icon_name',
              () => m.addColumn(productCategories, productCategories.iconName));
          await tryAdd(
              'sort_order',
              () =>
                  m.addColumn(productCategories, productCategories.sortOrder));
          await tryAdd(
              'created_at',
              () =>
                  m.addColumn(productCategories, productCategories.createdAt));
          await tryAdd(
              'updated_at',
              () =>
                  m.addColumn(productCategories, productCategories.updatedAt));

          final nowMillis = DateTime.now().millisecondsSinceEpoch;
          await customStatement(
            'UPDATE product_categories SET created_at = $nowMillis '
            "WHERE typeof(created_at) != 'integer'",
          );
          await customStatement(
            'UPDATE product_categories SET updated_at = $nowMillis '
            "WHERE typeof(updated_at) != 'integer'",
          );
          AppLogger.instance.info('[DB] onUpgrade v3→v4 complete');
        }

        // v4 → v5: add image_name column to product_categories.
        if (from < 5) {
          try {
            await m.addColumn(productCategories, productCategories.imageName);
            AppLogger.instance.info('[DB] Added column image_name');
          } catch (e) {
            AppLogger.instance.warning(
                '[DB] Column image_name already exists (skipped)',
                error: e);
          }
          AppLogger.instance.info('[DB] onUpgrade v4→v5 complete');
        }

        // v5 → v6: create shopping_lists and shopping_items tables.
        if (from < 6) {
          try {
            await m.createTable(shoppingLists);
            AppLogger.instance.info('[DB] Created shopping_lists table');
          } catch (e) {
            AppLogger.instance.warning(
                '[DB] shopping_lists already exists (skipped)',
                error: e);
          }
          try {
            await m.createTable(shoppingItems);
            AppLogger.instance.info('[DB] Created shopping_items table');
          } catch (e) {
            AppLogger.instance.warning(
                '[DB] shopping_items already exists (skipped)',
                error: e);
          }
          AppLogger.instance.info('[DB] onUpgrade v5→v6 complete');
        }
      },
      // Runs after every open (new or upgraded) to verify integrity.
      beforeOpen: (details) async {
        AppLogger.instance.info(
          '[DB] Opening — schemaVersion=${details.versionNow}, '
          'wasCreated=${details.wasCreated}, '
          'hadUpgrade=${details.hadUpgrade}',
        );

        await customStatement('PRAGMA foreign_keys = ON');

        // Self-healing: ensure all v4 columns exist regardless of migration
        // history. This recovers databases where onUpgrade failed silently.
        try {
          final existingCols = await customSelect(
            "SELECT name FROM pragma_table_info('product_categories')",
          )
              .get()
              .then((rows) => rows.map((r) => r.read<String>('name')).toSet());

          AppLogger.instance
              .info('[DB] product_categories columns: $existingCols');

          if (!existingCols.contains('color_hex')) {
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN color_hex TEXT');
            AppLogger.instance.info('[DB] Recovered: added color_hex');
          }
          if (!existingCols.contains('icon_name')) {
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN icon_name TEXT');
            AppLogger.instance.info('[DB] Recovered: added icon_name');
          }
          if (!existingCols.contains('sort_order')) {
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
            AppLogger.instance.info('[DB] Recovered: added sort_order');
          }
          if (!existingCols.contains('created_at')) {
            final nowMillis = DateTime.now().millisecondsSinceEpoch;
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN created_at INTEGER NOT NULL DEFAULT $nowMillis');
            AppLogger.instance.info('[DB] Recovered: added created_at');
          }
          if (!existingCols.contains('updated_at')) {
            final nowMillis = DateTime.now().millisecondsSinceEpoch;
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN updated_at INTEGER NOT NULL DEFAULT $nowMillis');
            AppLogger.instance.info('[DB] Recovered: added updated_at');
          }
          if (!existingCols.contains('image_name')) {
            await customStatement(
                'ALTER TABLE product_categories ADD COLUMN image_name TEXT');
            AppLogger.instance.info('[DB] Recovered: added image_name');
          }

          // Fix any rows where datetime was stored as SQLite text instead of
          // integer milliseconds (happens when DEFAULT CURRENT_TIMESTAMP was used).
          final nowMillis = DateTime.now().millisecondsSinceEpoch;
          await customStatement(
            'UPDATE product_categories SET created_at = $nowMillis '
            "WHERE typeof(created_at) != 'integer'",
          );
          await customStatement(
            'UPDATE product_categories SET updated_at = $nowMillis '
            "WHERE typeof(updated_at) != 'integer'",
          );
          AppLogger.instance.info('[DB] Self-heal complete');
        } catch (e, st) {
          AppLogger.instance
              .error('[DB] Self-heal failed', error: e, stackTrace: st);
        }
      },
    );
  }

  /// Ensures the database is initialised and seeded with default data.
  /// Safe to call multiple times – seeders check for existing data.
  Future<void> ensureInitialized() async {
    try {
      AppLogger.instance.info('[Database] Starting seeding...');
      await ProductCategorySeeder.seedDefaultCategories(this);
      AppLogger.instance.info('[Database] Product categories seeded');
      await ProductSeeder.seedDefaultProducts(this);
      AppLogger.instance.info('[Database] Products seeded');
      await RecipeSeeder.seedDefaultRecipes(this);
      AppLogger.instance.info('[Database] Recipes seeded');
      AppLogger.instance.info('[Database] Seeding complete');
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
