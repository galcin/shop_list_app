# Revised Epics - Drift Database, Offline-First Approach

## Flutter Shopping List & Meal Planning App

**Document Version:** 3.0  
**Date:** February 26, 2026  
**Author:** BMad Master  
**Status:** Development Ready  
**Approach:** Bottom-Up (Data → Domain → UI), **Offline-First**, **Drift/SQLite Database**  
**Related Documents:** [PRD](prd-shopping-list-app.md), [Architecture](architecture-shopping-list-app.md)

---

## Key Changes in v3.0

✅ **Database Technology:** Drift (SQLite) instead of Hive for better querying, type safety, and complex queries  
✅ **Offline-First MVP:** App is fully functional offline without any cloud dependency (Phases 0-3)  
✅ **Cloud Sync as Post-MVP:** Sync with external database moved to Phase 4 as optional enhancement  
✅ **Simplified Development:** Build solid local app first, add cloud features later

---

## Document Overview

This document reorganizes development using a **database-first, offline-only approach** for MVP:

### Development Phases

1. **Phase 0: Foundation** - Core infrastructure with Drift database
2. **Phase 1: Data Layer** - All local database tables, models, repositories (Drift)
3. **Phase 2: Domain Layer** - Business logic, use cases (offline operations)
4. **Phase 3: Presentation Layer** - UI components and screens (local data only)
5. **Phase 4: Cloud Features** - Authentication, sync, collaboration (post-MVP)

### Why Offline-First with Drift?

- ✅ **User Experience** - App works anywhere, anytime without internet
- ✅ **Simplicity** - No complex sync logic in MVP
- ✅ **Type Safety** - Drift provides compile-time checked SQL queries
- ✅ **Performance** - SQLite is fast for complex queries (search, filtering)
- ✅ **Migrations** - Built-in schema versioning and migrations
- ✅ **Reactive** - Stream-based queries for real-time UI updates

---

## Epic Summary

| Phase | Epic ID | Epic Name                       | Stories | Points | Priority | Duration   |
| ----- | ------- | ------------------------------- | ------- | ------ | -------- | ---------- |
| **0** | **E0**  | **Foundation & Infrastructure** | **6**   | **29** | **P0**   | Week 1-2   |
| **1** | **E1**  | **Recipe Data Layer (Drift)**   | **5**   | **24** | **P0**   | Week 2-3   |
| **1** | **E2**  | **Shopping List Data Layer**    | **4**   | **19** | **P0**   | Week 2-3   |
| **1** | **E3**  | **Meal Plan Data Layer**        | **4**   | **18** | **P0**   | Week 3-4   |
| **1** | **E4**  | **Pantry Data Layer**           | **4**   | **17** | **P0**   | Week 3-4   |
| **2** | **E5**  | **Recipe Use Cases (Offline)**  | **6**   | **24** | **P0**   | Week 4-5   |
| **2** | **E6**  | **Shopping Use Cases**          | **5**   | **19** | **P0**   | Week 4-5   |
| **2** | **E7**  | **Meal Planning Use Cases**     | **5**   | **23** | **P0**   | Week 5-6   |
| **2** | **E8**  | **Pantry Use Cases**            | **4**   | **18** | **P0**   | Week 5-6   |
| **3** | **E9**  | **Core UI Components**          | **6**   | **22** | **P0**   | Week 6-7   |
| **3** | **E10** | **Shopping List UI**            | **5**   | **20** | **P0**   | Week 7-8   |
| **3** | **E11** | **Recipe Management UI**        | **6**   | **25** | **P0**   | Week 8-9   |
| **3** | **E12** | **Meal Planning UI**            | **5**   | **23** | **P0**   | Week 9-10  |
| **3** | **E13** | **Pantry Inventory UI**         | **4**   | **18** | **P0**   | Week 10-11 |
| **3** | **E14** | **Settings & Data Management**  | **4**   | **17** | **P0**   | Week 11    |
| **4** | **E15** | **Cloud Sync & Authentication** | **8**   | **42** | **P1**   | Week 12-14 |
| **4** | **E16** | **Family & Collaboration**      | **6**   | **27** | **P1**   | Week 15-16 |
| **4** | **E17** | **Smart Features & AI**         | **7**   | **41** | **P2**   | Week 17-19 |

### MVP Scope (Offline-First)

**Phases 0-3 (Epics E0-E14):** **294 story points** ≈ **11-13 weeks** for 2 developers

- ✅ Fully functional app without internet
- ✅ All core features (shopping lists, recipes, meal planning, pantry)
- ✅ Local data export/import for backup
- ✅ No cloud dependency

### Post-MVP (Cloud Features)

**Phase 4 (Epics E15-E17):** **110 story points** ≈ **5-6 weeks**

- 🌐 Optional cloud sync
- 👥 Family sharing
- 🤖 AI recipes suggestions

---

## PHASE 0: Foundation & Infrastructure

### Epic E0: Foundation & Infrastructure

**Epic Goal:** Establish core development infrastructure with Drift database.

**Business Value:** Clean architecture foundation enables rapid feature development.

**Story Count:** 6 stories | **Total Points:** 29 | **Duration:** Week 1-2

---

#### US-E0.1: Project Setup & Clean Architecture Structure

**As a** developer  
**I want to** set up Flutter project with clean architecture  
**So that** code is maintainable and scalable

**Acceptance Criteria:**

- [ ] Flutter project initialized (latest stable)
- [ ] Clean architecture folder structure created
- [ ] Riverpod dependency injection configured
- [ ] Linting rules configured
- [ ] Git repository initialized
- [ ] README with architecture docs

**Folder Structure:**

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── database/          # Drift database
│   ├── constants/
│   ├── error/
│   ├── utils/
│   ├── theme/
│   └── providers/
├── features/
│   ├── shopping/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── recipes/
│   ├── meal_planning/
│   └── pantry/
└── shared/
    └── widgets/
```

**Dependencies (pubspec.yaml):**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  equatable: ^2.0.5
  dartz: ^0.10.1
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3
  uuid: ^4.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.6
  drift_dev: ^2.14.0
  mockito: ^5.4.2
```

**Story Points:** 3  
**Priority:** P0  
**Dependencies:** None  
**Acceptance Tests:** `flutter analyze` passes, project builds

---

#### US-E0.2: Core Error Handling & Result Types

**As a** developer  
**I want to** implement consistent error handling  
**So that** failures are handled gracefully

**Acceptance Criteria:**

- [ ] Failure abstract class with concrete types
- [ ] Result<T> type (Either<Failure, T>)
- [ ] Exception types defined
- [ ] Error mapping utilities
- [ ] Unit tests for error types

**Implementation:**

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Database error']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}

// core/error/exceptions.dart
class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Database error']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);
}

// core/utils/result.dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

typedef Result<T> = Either<Failure, T>;
```

**Story Points:** 2  
**Priority:** P0  
**Acceptance Tests:** Unit tests for failures and result types

---

#### US-E0.3: Drift Database Setup

**As a** developer  
**I want to** configure Drift as local SQLite database  
**So that** type-safe, reactive data persistence is available

**Acceptance Criteria:**

- [ ] Drift package integrated
- [ ] AppDatabase class created
- [ ] Database connection configured
- [ ] Migration strategy defined
- [ ] Test database utilities created
- [ ] Database provider configured

**Implementation:**

```dart
// core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// Table imports will be added as features are built
// import 'package:shop_list_app/features/recipes/data/models/recipe_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Tables will be added incrementally:
    // Recipes,
    // ShoppingLists,
    // ShoppingItems,
    // MealPlans,
    // PantryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration logic when schema changes
        // if (from < 2) {
        //   await m.addColumn(recipes, recipes.rating);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shopping_app.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

// core/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
```

**Test Helper:**

```dart
// test/helpers/test_database.dart
import 'package:drift/native.dart';
import 'package:shop_list_app/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.test(NativeDatabase.memory());
}

extension AppDatabaseTest on AppDatabase {
  static AppDatabase test(QueryExecutor executor) {
    return AppDatabase.private(executor);
  }

  AppDatabase.private(QueryExecutor executor) : super.private(executor);
}
```

**Story Points:** 6  
**Priority:** P0 (Blocking)  
**Acceptance Tests:** Database opens, creates schema, queries work

---

#### US-E0.4: Data Export/Import Utilities

**As a** user  
**I want to** export and import my data as JSON  
**So that** I can backup and restore my data without cloud

**Acceptance Criteria:**

- [ ] Export all data to JSON file
- [ ] Import data from JSON file
- [ ] Validate JSON structure
- [ ] Handle import conflicts (skip/override/merge)
- [ ] Progress feedback for large exports
- [ ] Error handling for corrupt files

**Implementation:**

```dart
// core/data/data_export_service.dart
class DataExportService {
  final AppDatabase database;

  DataExportService(this.database);

  Future<File> exportAllData() async {
    final data = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'recipes': await database.select(database.recipes).get(),
      'shoppingLists': await database.select(database.shoppingLists).get(),
      'pantryItems': await database.select(database.pantryItems).get(),
      'mealPlans': await database.select(database.mealPlans).get(),
    };

    final jsonString = jsonEncode(data);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(p.join(directory.path, fileName));

    await file.writeAsString(jsonString);
    return file;
  }

  Future<void> importFromJson(File file, {ImportStrategy strategy = ImportStrategy.skipExisting}) async {
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validate version
    if (data['version'] != 1) {
      throw Exception('Unsupported backup version');
    }

    await database.transaction(() async {
      // Import each table with conflict resolution
      await _importRecipes(data['recipes'], strategy);
      await _importShoppingLists(data['shoppingLists'], strategy);
      await _importPantryItems(data['pantryItems'], strategy);
      await _importMealPlans(data['mealPlans'], strategy);
    });
  }
}

enum ImportStrategy {
  skipExisting,
  overrideExisting,
  merge,
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Export/import round-trip preserves all data

---

#### US-E0.5: Core Theme & Design System

**As a** developer  
**I want to** define app theme and design tokens  
**So that** UI is consistent

**Acceptance Criteria:**

- [ ] Color palette (light/dark themes)
- [ ] Typography scale (Material 3)
- [ ] Spacing constants
- [ ] Border radius tokens
- [ ] Elevation/shadow definitions
- [ ] Theme provider

**Implementation:**

```dart
// core/theme/app_colors.dart
class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF2E7D32);      // Green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  static const Color secondary = Color(0xFFFF6F00);    // Orange

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Expiration states
  static const Color fresh = Color(0xFF4CAF50);
  static const Color useSoon = Color(0xFFFFC107);
  static const Color urgent = Color(0xFFF44336);
  static const Color neutral = Color(0xFF9E9E9E);
}

// core/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      // ... theme configuration
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Theme applies correctly, dark mode switches

---

#### US-E0.6: Testing Infrastructure

**As a** developer  
**I want to** set up testing utilities  
**So that** code quality is maintained

**Acceptance Criteria:**

- [ ] Test helpers created
- [ ] Mock factories structure
- [ ] Test database utilities
- [ ] Coverage configuration
- [ ] Sample tests pass

**Implementation:**

```dart
// test/helpers/test_helpers.dart
class TestHelpers {
  static Future<void> setupTests() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  static AppDatabase createTestDatabase() {
    return AppDatabase.test(NativeDatabase.memory());
  }

  static Future<void> teardownTests() async {
    // Cleanup
  }
}

// test/helpers/mock_factories.dart
class MockRecipeFactory {
  static Recipe createTestRecipe({String? id}) {
    return Recipe(
      id: RecipeId(id ?? 'test-1'),
      title: 'Test Recipe',
      ingredients: const [
        Ingredient(name: 'Flour', quantity: 2, unit: 'cups'),
      ],
      instructions: const [
        Instruction('Mix ingredients', stepNumber: 1),
      ],
      servings: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
```

**Story Points:** 8  
**Priority:** P0  
**Acceptance Tests:** Test suite runs successfully

---

## PHASE 1: Data Layer (Drift Tables & Repositories)

### Epic E1: Recipe Data Layer (Drift)

**Epic Goal:** Implement recipe data persistence using Drift tables.

**Story Count:** 5 stories | **Total Points:** 24 | **Duration:** Week 2-3

---

#### US-E1.1: Recipe Domain Entities

**As a** developer  
**I want to** define recipe domain entities  
**So that** business logic is type-safe

**Acceptance Criteria:**

- [ ] RecipeId value object
- [ ] Ingredient value object
- [ ] Instruction value object
- [ ] Recipe entity with validation
- [ ] Unit tests for entities

**Story Points:** 3  
**Priority:** P0

---

#### US-E1.2: Recipe Drift Table & Data Model

**As a** developer  
**I want to** create Recipe table using Drift  
**So that** recipes can be persisted in SQLite

**Acceptance Criteria:**

- [ ] Recipes table defined
- [ ] Ingredients table (separate table, foreign key)
- [ ] Instructions table (separate table, foreign key)
- [ ] RecipeTags table (many-to-many)
- [ ] Generated code working
- [ ] Serialization to/from entities

**Implementation:**

```dart
// features/recipes/data/models/recipe_table.dart
import 'package:drift/drift.dart';

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get servings => integer()();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  RealColumn get rating => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer()();
}

class Instructions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get text => text()();
  IntColumn get stepNumber => integer()();
}

class RecipeTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text()();
}

class RecipePhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get photoPath => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isCover => boolean().withDefault(const Constant(false))();
}
```

**Story Points:** 6  
**Priority:** P0

---

#### US-E1.3: Recipe Data Access Object (DAO)

**As a** developer  
**I want to** implement recipe DAO with Drift  
**So that** CRUD operations are available

**Acceptance Criteria:**

- [ ] RecipeDao class created
- [ ] CRUD methods (insert, update, delete, getById)
- [ ] Query methods (search, filter by tags)
- [ ] Join queries for complete recipe with ingredients
- [ ] Stream-based queries
- [ ] Transaction support

**Implementation:**

```dart
// features/recipes/data/datasources/recipe_dao.dart
import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';

part 'recipe_dao.g.dart';

@DriftAccessor(tables: [Recipes, Ingredients, Instructions, RecipeTags, RecipePhotos])
class RecipeDao extends DatabaseAccessor<AppDatabase> with _$RecipeDaoMixin {
  RecipeDao(AppDatabase db) : super(db);

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() {
    return select(recipes).get();
  }

  // Watch recipes (reactive)
  Stream<List<Recipe>> watchAllRecipes() {
    return select(recipes).watch();
  }

  // Get recipe with all related data (ingredients, instructions, etc.)
  Future<RecipeWithDetails?> getRecipeWithDetails(String id) async {
    final recipe = await (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (recipe == null) return null;

    final ingredients = await (select(this.ingredients)
      ..where((i) => i.recipeId.equals(id))
      ..orderBy([(i) => OrderingTerm(expression: i.sortOrder)])).get();

    final instructions = await (select(this.instructions)
      ..where((i) => i.recipeId.equals(id))
      ..orderBy([(i) => OrderingTerm(expression: i.stepNumber)])).get();

    final tags = await (select(recipeTags)..where((t) => t.recipeId.equals(id))).get();
    final photos = await (select(recipePhotos)..where((p) => p.recipeId.equals(id))).get();

    return RecipeWithDetails(
      recipe: recipe,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags.map((t) => t.tag).toList(),
      photos: photos,
    );
  }

  // Insert recipe with related data (transaction)
  Future<void> insertRecipeWithDetails(RecipeWithDetails data) {
    return transaction(() async {
      await into(recipes).insert(data.recipe);

      await batch((batch) {
        batch.insertAll(ingredients, data.ingredients);
        batch.insertAll(instructions, data.instructions);
        batch.insertAll(recipeTags, data.tags.map((tag) =>
          RecipeTag(recipeId: data.recipe.id, tag: tag)
        ).toList());
        batch.insertAll(recipePhotos, data.photos);
      });
    });
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe) {
    return update(recipes).replace(recipe);
  }

  // Delete recipe (cascade deletes related data)
  Future<void> deleteRecipe(String id) {
    return (delete(recipes)..where((r) => r.id.equals(id))).go();
  }

  // Search recipes by title or description
  Future<List<Recipe>> searchRecipes(String query) {
    final lowerQuery = query.toLowerCase();
    return (select(recipes)
      ..where((r) =>
        r.title.lower().contains(lowerQuery) |
        r.description.lower().contains(lowerQuery)
      )
    ).get();
  }

  // Get recipes by tags
  Future<List<Recipe>> getRecipesByTags(List<String> tags) async {
    // Find recipe IDs that have any of the specified tags
    final recipeIds = await (selectOnly(recipeTags)
      ..where(recipeTags.tag.isIn(tags))
      ..addColumns([recipeTags.recipeId])
    ).map((row) => row.read(recipeTags.recipeId)!).get();

    if (recipeIds.isEmpty) return [];

    return (select(recipes)..where((r) => r.id.isIn(recipeIds))).get();
  }

  // Get favorite recipes
  Stream<List<Recipe>> watchFavoriteRecipes() {
    return (select(recipes)..where((r) => r.isFavorite.equals(true))).watch();
  }
}

class RecipeWithDetails {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;
  final List<String> tags;
  final List<RecipePhoto> photos;

  RecipeWithDetails({
    required this.recipe,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.photos,
  });
}
```

**Story Points:** 8  
**Priority:** P0

---

#### US-E1.4: Recipe Repository Implementation

**As a** developer  
**I want to** implement recipe repository  
**So that** domain layer has clean interface

**Acceptance Criteria:**

- [ ] Repository interface in domain
- [ ] Repository implementation in data layer
- [ ] Converts between Drift models and entities
- [ ] Returns Result types
- [ ] Error handling
- [ ] Unit tests with mocked DAO

**Implementation:**

```dart
// features/recipes/domain/repositories/recipe_repository.dart
abstract class RecipeRepository {
  Future<Result<List<Recipe>>> getAllRecipes();
  Future<Result<Recipe>> getRecipeById(RecipeId id);
  Future<Result<void>> saveRecipe(Recipe recipe);
  Future<Result<void>> deleteRecipe(RecipeId id);
  Future<Result<List<Recipe>>> searchRecipes(String query);
  Stream<Result<List<Recipe>>> watchRecipes();
}

// features/recipes/data/repositories/recipe_repository_impl.dart
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDao dao;

  RecipeRepositoryImpl(this.dao);

  @override
  Future<Result<List<Recipe>>> getAllRecipes() async {
    try {
      final driftRecipes = await dao.getAllRecipes();
      final recipes = driftRecipes.map(_toEntity).toList();
      return Right(recipes);
    } on DriftWrappedException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Recipe>> getRecipeById(RecipeId id) async {
    try {
      final data = await dao.getRecipeWithDetails(id.value);
      if (data == null) {
        return const Left(NotFoundFailure('Recipe not found'));
      }
      return Right(_toEntityWithDetails(data));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveRecipe(Recipe recipe) async {
    try {
      final data = _fromEntity(recipe);
      await dao.insertRecipeWithDetails(data);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // Entity conversion helpers
  Recipe _toEntityWithDetails(RecipeWithDetails data) {
    return Recipe(
      id: RecipeId(data.recipe.id),
      title: data.recipe.title,
      description: data.recipe.description,
      ingredients: data.ingredients.map((i) => Ingredient(
        name: i.name,
        quantity: i.quantity,
        unit: i.unit,
        notes: i.notes,
      )).toList(),
      instructions: data.instructions.map((i) => Instruction(
        i.text,
        stepNumber: i.stepNumber,
      )).toList(),
      servings: data.recipe.servings,
      prepTime: data.recipe.prepTimeMinutes != null
          ? Duration(minutes: data.recipe.prepTimeMinutes!)
          : null,
      cookTime: data.recipe.cookTimeMinutes != null
          ? Duration(minutes: data.recipe.cookTimeMinutes!)
          : null,
      tags: data.tags,
      photoUrls: data.photos.map((p) => p.photoPath).toList(),
      createdAt: data.recipe.createdAt,
      updatedAt: data.recipe.updatedAt,
      isFavorite: data.recipe.isFavorite,
      rating: data.recipe.rating,
    );
  }

  RecipeWithDetails _fromEntity(Recipe recipe) {
    // Convert entity to Drift models
    // Implementation details...
  }
}
```

**Story Points:** 5  
**Priority:** P0

---

#### US-E1.5: Recipe Data Layer Provider Setup

**As a** developer  
**I want to** configure Riverpod providers  
**So that** dependencies are injected

**Acceptance Criteria:**

- [ ] RecipeDao provider
- [ ] RecipeRepository provider
- [ ] Provider hierarchy documented

**Implementation:**

```dart
// features/recipes/data/providers/recipe_providers.dart
final recipeDaoProvider = Provider<RecipeDao>((ref) {
  final database = ref.watch(databaseProvider);
  return RecipeDao(database);
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return RecipeRepositoryImpl(dao);
});
```

**Story Points:** 2  
**Priority:** P0

---

### Epic E2-E4: Shopping List, Meal Plan, Pantry Data Layers

**Similar structure to E1, using Drift tables:**

- **E2: Shopping Lists** - ShoppingLists, ShoppingItems tables
- **E3: Meal Plans** - MealPlans, MealSlots tables
- **E4: Pantry** - PantryItems table with expiration tracking

**Combined Points:** 54 points | **Duration:** Weeks 2-4

---

## PHASE 2: Domain Layer (Use Cases - Offline Only)

### Epic E5-E8: Use Cases

All use cases operate on local data only (no cloud sync in MVP).

- **E5: Recipe Use Cases** - CRUD, search, filter (24 pts)
- **E6: Shopping Use Cases** - Manage lists, generate from meal plan (19 pts)
- **E7: Meal Planning Use Cases** - Weekly planning, recipe matching (23 pts)
- **E8: Pantry Use Cases** - Inventory, expiration alerts (18 pts)

**Total:** 84 points | **Duration:** Weeks 4-6

---

## PHASE 3: Presentation Layer (UI - Local Data)

### Epic E9-E14: UI Components & Screens

All UI screens display and modify local data only.

- **E9: Core UI Components** - Navigation, widgets, theme (22 pts)
- **E10: Shopping List UI** - Lists, items, categories (20 pts)
- **E11: Recipe Management UI** - List, detail, form (25 pts)
- **E12: Meal Planning UI** - Calendar, assignment (23 pts)
- **E13: Pantry Inventory UI** - List, expiration dashboard (18 pts)
- **E14: Settings & Data Management** - Export/import, preferences (17 pts)

**Total:** 125 points | **Duration:** Weeks 6-11

---

## PHASE 4: Cloud Features (Post-MVP)

### Epic E15: Cloud Sync & Authentication

**Epic Goal:** Add optional cloud sync for multi-device access.

**Story Count:** 8 stories | **Total Points:** 42 | **Duration:** Weeks 12-14

---

#### Stories:

1. **US-E15.1:** Firebase/Supabase Setup (5 pts)
2. **US-E15.2:** Authentication (Email, Google, Apple) (8 pts)
3. **US-E15.3:** Sync Queue Implementation (8 pts)
4. **US-E15.4:** Conflict Resolution Strategy (8 pts)
5. **US-E15.5:** Cloud Database Schema (5 pts)
6. **US-E15.6:** Two-Way Sync Logic (8 pts)
7. **US-E15.7:** Sync UI Indicators (3 pts)
8. **US-E15.8:** Account Management (5 pts)

---

### Epic E16: Family & Collaboration

**Story Count:** 6 stories | **Total Points:** 27

- Household profiles
- Shared shopping lists
- Meal voting
- Real-time sync

---

### Epic E17: Smart Features & AI

**Story Count:** 7 stories | **Total Points:** 41

- Recipe URL import
- Photo recognition for items
- Voice input
- Recipe recommendations
- Leftover planning

---

## Release Planning

### MVP Release v1.0 (Offline-First) - Week 11

**Scope:** Epics E0-E14  
**Points:** 294  
**Duration:** 11-13 weeks

**Features:**

- ✅ Full offline functionality
- ✅ Shopping lists with categories
- ✅ Recipe management with photos
- ✅ Weekly meal planning
- ✅ Pantry inventory with expiration tracking
- ✅ Auto-generate shopping lists from meal plans
- ✅ "What Can I Make?" recipe matching
- ✅ Local data export/import
- ✅ Dark mode support

**Not Included:**

- ❌ Cloud sync
- ❌ Multi-device access
- ❌ Family sharing
- ❌ Online recipe import

---

### v1.1 Release (Cloud Sync) - Week 14

**Scope:** Epic E15  
**Features:**

- ✅ Optional cloud sync
- ✅ Multi-device access
- ✅ Authentication
- ✅ Conflict resolution

---

### v1.2 Release (Collaboration) - Week 16

**Scope:** Epic E16  
**Features:**

- ✅ Family profiles
- ✅ Shared lists
- ✅ Meal voting

---

### v1.3 Release (Smart Features) - Week 19

**Scope:** Epic E17  
**Features:**

- ✅ AI-powered suggestions
- ✅ Recipe import
- ✅ Voice/photo input

---

## Testing Strategy

### Data Layer (Phase 1)

- Unit tests: 100% coverage for DAOs
- Integration tests: Database operations
- Migration tests: Schema versioning

### Domain Layer (Phase 2)

- Unit tests: All use cases with mocked repositories
- Business logic tests: Validation, calculations

### UI Layer (Phase 3)

- Widget tests: All custom widgets
- Integration tests: Screen flows
- Golden tests: Visual regression

### Cloud Layer (Phase 4)

- Integration tests: Sync scenarios
- E2E tests: Multi-device workflows

---

## Success Criteria

### MVP Success (v1.0)

- [ ] App works 100% offline
- [ ] All CRUD operations tested
- [ ] Data export/import functional
- [ ] Performance: <16ms frame time
- [ ] Database queries: <100ms
- [ ] Handles 1000+ recipes
- [ ] No data loss on app termination

### Post-MVP Success (v1.1+)

- [ ] Sync completes within 30 seconds
- [ ] Conflict resolution success rate >95%
- [ ] Multi-device consistency maintained

---

## Dependencies & Risks

### Critical Path

1. **E0 Foundation** → Blocks everything
2. **E1-E4 Data Layer** → Blocks use cases
3. **E5-E8 Use Cases** → Blocks UI
4. **E9 Core UI** → Blocks feature UIs

### Risks

- **Drift Learning Curve:** Team needs to learn Drift query syntax (4-8 hours training)
- **Complex Queries:** Recipe search may need optimization (add indexes)
- **Migration Testing:** Schema changes need thorough testing
- **Photo Storage:** Large photo libraries may impact performance

### Mitigation

- Drift documentation study (Week 1)
- Benchmark complex queries early (Week 3)
- Document migration strategy (Week 2)
- Implement photo compression (Phase 3)

---

## Tools & Packages by Phase

### Phase 0-1 (Foundation & Data)

- drift: ^2.14.0
- sqlite3_flutter_libs: ^0.5.0
- drift_dev: ^2.14.0 (dev)
- build_runner: ^2.4.6 (dev)
- flutter_riverpod: ^2.4.0
- dartz: ^0.10.1
- uuid: ^4.0.0

### Phase 2 (Use Cases)

- (same as above)

### Phase 3 (UI)

- go_router: ^13.0.0
- cached_network_image: ^3.3.0
- image_picker: ^1.0.0
- shimmer: ^3.0.0

### Phase 4 (Cloud)

- firebase_core: ^2.24.0
- firebase_auth: ^4.15.0
- cloud_firestore: ^4.14.0
  OR
- supabase_flutter: ^2.0.0

---

**Document End - Ready for Development**
