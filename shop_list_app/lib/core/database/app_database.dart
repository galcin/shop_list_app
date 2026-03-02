import 'package:drift/drift.dart';
import 'tables/product_category_table.dart';
import 'tables/product_table.dart';
import 'tables/recipe_table.dart';
import 'seeder/recipe_seeder.dart';
import 'seeder/product_category_seeder.dart';
import 'seeder/product_seeder.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [ProductCategories, Products, Recipes])
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
  int get schemaVersion => 2;

  // Call this method to ensure database is initialized and seeded
  Future<void> ensureInitialized() async {
    try {
      print('[Database] Starting seeding...');
      // Seed data - the seeders check if data already exists
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
