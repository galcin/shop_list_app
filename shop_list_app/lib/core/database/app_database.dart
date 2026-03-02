import 'package:drift/drift.dart';
import 'tables/product_category_table.dart';
import 'tables/product_table.dart';
import 'tables/recipe_table.dart';
import 'tables/sync_queue_table.dart';
import 'seeder/recipe_seeder.dart';
import 'seeder/product_category_seeder.dart';
import 'seeder/product_seeder.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [ProductCategories, Products, Recipes, SyncQueue])
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

  @override
  int get schemaVersion => 3;

  /// Step-by-step migration strategy.
  ///
  /// v1 → v2: initial data-table additions (ProductCategories, Products, Recipes).
  /// v2 → v3: add sync_queue table to support Post-MVP cloud sync (US-E0.2).
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // Called when the database is created for the first time.
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      // Called for each schema version increment above the stored version.
      onUpgrade: (Migrator m, int from, int to) async {
        // v1 → v2: ProductCategories, Products, Recipes were already handled
        // by the original createAll(); nothing additional needed here.

        // v2 → v3: create the SyncQueue table.
        if (from < 3) {
          await m.createTable(syncQueue);
        }
      },
      // Optional: runs after every open (new or upgraded) to verify integrity.
      beforeOpen: (details) async {
        // Enable foreign-key enforcement on every connection.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Ensures the database is initialised and seeded with default data.
  /// Safe to call multiple times – seeders check for existing data.
  Future<void> ensureInitialized() async {
    try {
      print('[Database] Starting seeding...');
      await ProductCategorySeeder.seedDefaultCategories(this);
      print('[Database] Product categories seeded');
      await ProductSeeder.seedDefaultProducts(this);
      print('[Database] Products seeded');
      await RecipeSeeder.seedDefaultRecipes(this);
      print('[Database] Recipes seeded');
      print('[Database] Seeding complete');
    } catch (e, stackTrace) {
      print('[Database] Error during seeding: $e');
      print('[Database] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
