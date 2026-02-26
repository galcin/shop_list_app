# Revised Epics - Database-First Approach

## Flutter Shopping List & Meal Planning App

**Document Version:** 3.0  
**Date:** February 26, 2026  
**Author:** BMad Master  
**Status:** Development Ready  
**Approach:** Bottom-Up (Data → Domain → UI), Offline-First, Drift Database  
**Related Documents:** [PRD](prd-shopping-list-app.md), [Architecture](architecture-shopping-list-app.md), [Original Epics](epics-and-stories.md)

---

## Key Changes in v3.0

- **Database:** Replaced Hive with Drift (SQLite) for better querying and type safety
- **Offline-First:** App works 100% offline in MVP (Phases 0-3)
- **Sync Later:** Cloud sync moved to Phase 4 (post-MVP) as optional feature
- **Simplified MVP:** Focus on core local functionality first

---

## Document Overview

This document reorganizes development work using a **database-first, bottom-up approach**. Instead of building features vertically (shopping list from DB to UI), we build horizontally in layers:

1. **Foundation Layer** - Core infrastructure and tooling
2. **Data Layer** - All database schemas, models, and repositories
3. **Domain Layer** - Business logic, use cases, and validation
4. **Presentation Layer** - UI components and screens

### Why Database-First?

- ✅ **Solid Foundation** - Data structure changes are expensive; get it right first
- ✅ **Parallel Development** - Multiple developers can work on different features once data layer is ready
- ✅ **Testability** - Data layer can be fully tested before UI exists
- ✅ **API Independence** - Backend can be built in parallel without blocking frontend
- ✅ **Migration Safety** - Database changes are versioned and tested early

---

## Epic Summary

| Phase | Epic ID | Epic Name                       | Stories | Points | Priority | Duration   |
| ----- | ------- | ------------------------------- | ------- | ------ | -------- | ---------- |
| 0     | E0      | Foundation & Infrastructure     | 6       | 28     | P0       | Week 1-2   |
| 1     | E1      | Recipe Data Layer (Drift)       | 5       | 23     | P0       | Week 2-3   |
| 1     | E2      | Shopping List Data Layer        | 4       | 18     | P0       | Week 2-3   |
| 1     | E3      | Meal Plan Data Layer            | 4       | 18     | P0       | Week 3-4   |
| 1     | E4      | Pantry Data Layer               | 4       | 17     | P0       | Week 3-4   |
| 2     | E5      | Recipe Use Cases (Offline)      | 6       | 24     | P0       | Week 4-5   |
| 2     | E6      | Shopping Use Cases (Offline)    | 5       | 19     | P0       | Week 4-5   |
| 2     | E7      | Meal Planning Use Cases         | 5       | 23     | P0       | Week 5-6   |
| 2     | E8      | Pantry Use Cases                | 4       | 18     | P0       | Week 5-6   |
| 3     | E9      | Core UI Components              | 6       | 22     | P0       | Week 6-7   |
| 3     | E10     | Shopping List UI                | 5       | 20     | P0       | Week 7-8   |
| 3     | E11     | Recipe Management UI            | 6       | 25     | P0       | Week 8-9   |
| 3     | E12     | Meal Planning UI                | 5       | 23     | P0       | Week 9-10  |
| 3     | E13     | Pantry Inventory UI             | 4       | 18     | P0       | Week 10-11 |
| 3     | E14     | Settings & Data Management UI   | 4       | 16     | P0       | Week 11    |
| 4     | E15     | Cloud Sync & Authentication     | 7       | 34     | P1       | Week 12-14 |
| 4     | E16     | Family & Collaboration Features | 6       | 27     | P1       | Week 14-15 |
| 4     | E17     | Smart Features & AI             | 7       | 41     | P1       | Week 16-18 |

**MVP Scope (Offline-First, Phases 0-3):** Epics E0-E14 = **292 story points** (~11-13 weeks for 2 developers)

**Post-MVP (Cloud Features, Phase 4):** Epics E15-E17 = **102 story points** (~5-6 weeks)

**Key Difference:** MVP is fully functional offline without any cloud dependency

---

## PHASE 0: Foundation & Infrastructure

### Epic E0: Foundation & Infrastructure

**Epic Goal:** Establish core development infrastructure, project structure, and shared utilities.

**Business Value:** Enables all future development with clean architecture patterns.

**Story Count:** 6 stories | **Total Points:** 28 | **Duration:** Week 1-2

---

#### US-E0.1: Project Setup & Clean Architecture Structure

**As a** developer  
**I want to** set up the Flutter project with clean architecture structure  
**So that** code is maintainable and follows best practices

**Acceptance Criteria:**

- [ ] Flutter project initialized with latest stable version
- [ ] Folder structure follows clean architecture (features/{domain,data,presentation})
- [ ] Core folder with shared utilities, constants, errors
- [ ] Dependency injection setup with Riverpod providers
- [ ] Linting rules configured (analysis_options.yaml)
- [ ] Git repository initialized with .gitignore
- [ ] README with architecture documentation

**Technical Implementation:**

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── utils/
│   ├── theme/
│   └── providers/
├── features/
│   ├── shopping/
│   ├── recipes/
│   ├── meal_planning/
│   ├── pantry/
│   └── sync/
└── shared/
```

**Dependencies:**

- flutter_riverpod: ^2.4.0
- equatable: ^2.0.5
- dartz: ^0.10.1 (functional programming)

**Story Points:** 3  
**Priority:** P0  
**Assignee:** TBD  
**Acceptance Tests:** Project builds successfully, linter passes

---

#### US-E0.2: Core Error Handling & Result Types

**As a** developer  
**I want to** implement consistent error handling patterns  
**So that** failures are handled gracefully throughout the app

**Acceptance Criteria:**

- [ ] Create Failure abstract class with concrete types
- [ ] Implement Result<T> type (Either<Failure, T>)
- [ ] Define Exception types for data layer
- [ ] Create error mapping utilities
- [ ] Implement logging infrastructure
- [ ] Document error handling patterns

**Technical Implementation:**

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error']) : super(message);
}

// core/utils/result.dart
typedef Result<T> = Either<Failure, T>;
```

**Story Points:** 2  
**Priority:** P0  
**Acceptance Tests:** Unit tests for error mapping

---

#### US-E0.3: Local Database Setup (Drift)

**As a** developer  
**I want to** configure Drift as the local SQLite database  
**So that** offline data persistence with type-safe queries is available

**Acceptance Criteria:**

- [ ] Hive package integrated and initialized
- [ ] Base HiveObject type adapters registered
- [ ] Box naming conventions defined
- [ ] Database versioning strategy implemented
- [ ] Migration path planned for schema changes
- [ ] Encryption setup for sensitive data (optional)
- [ ] Test database utilities for unit tests

**Technical Implementation:**

```dart
// core/database/hive_setup.dart
class HiveSetup {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(RecipeModelAdapter());
    Hive.registerAdapter(ShoppingListModelAdapter());
    Hive.registerAdapter(PantryItemModelAdapter());
    Hive.registerAdapter(MealPlanModelAdapter());
    Hive.registerAdapter(SyncOperationModelAdapter());

    // Open boxes
    await Hive.openBox<RecipeModel>('recipes');
    await Hive.openBox<ShoppingListModel>('shopping_lists');
    await Hive.openBox<PantryItemModel>('pantry_items');
    await Hive.openBox<MealPlanModel>('meal_plans');
    await Hive.openBox<SyncOperationModel>('sync_queue');
  }
}
```

**Dependencies:**

- hive: ^2.2.3
- hive_flutter: ^1.1.0
- build_runner: ^2.4.6 (dev)
- hive_generator: ^2.0.1 (dev)

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Database initialization succeeds, boxes open correctly

---

#### US-E0.4: Data Export/Import Utilities

**As a** developer  
**I want to** implement JSON export/import for data backup  
**So that** users can backup and restore data locally without cloud

**Acceptance Criteria:**

- [ ] NetworkInfo interface defined
- [ ] Connectivity detection implementation
- [ ] Stream-based connectivity status
- [ ] Offline mode flag management
- [ ] Mock implementation for testing
- [ ] Provider for dependency injection

**Technical Implementation:**

```dart
// core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

**Dependencies:**

- connectivity_plus: ^5.0.2

**Story Points:** 3  
**Priority:** P0  
**Acceptance Tests:** Connectivity changes detected correctly

---

#### US-E0.5: Core Theme & Design System

**As a** developer  
**I want to** define app theme and design tokens  
**So that** UI is consistent across all screens

**Acceptance Criteria:**

- [ ] Color palette defined (primary, secondary, semantic colors)
- [ ] Typography scale defined (Material Design 3)
- [ ] Spacing constants defined (4px, 8px, 16px, 24px, 32px)
- [ ] Border radius tokens
- [ ] Shadow/elevation definitions
- [ ] Dark mode theme defined
- [ ] Theme provider configured

**Technical Implementation:**

```dart
// core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTypography.textTheme,
    // ... other theme properties
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTypography.textTheme,
  );
}

// core/theme/colors.dart
class AppColors {
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color secondary = Color(0xFFFF6F00); // Orange

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Expiration states
  static const Color fresh = Color(0xFF4CAF50);
  static const Color useSoon = Color(0xFFFFC107);
  static const Color urgent = Color(0xFFF44336);
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Theme applies correctly in sample screens

---

#### US-E0.6: Testing Infrastructure & Utilities

**As a** developer  
**I want to** set up testing infrastructure  
**So that** code quality is maintained through tests

**Acceptance Criteria:**

- [ ] Unit test folder structure created
- [ ] Widget test utilities set up
- [ ] Mock factory utilities created
- [ ] Test data generators implemented
- [ ] Integration test framework configured
- [ ] Code coverage reporting configured
- [ ] CI/CD test pipeline ready

**Technical Implementation:**

```dart
// test/helpers/test_helpers.dart
class TestHelpers {
  static RecipeModel createTestRecipe({String? id}) {
    return RecipeModel(
      id: id ?? 'test-recipe-1',
      title: 'Test Recipe',
      ingredients: [/* ... */],
      instructions: [/* ... */],
      // ... other fields
    );
  }

  static Box<T> createMockBox<T>() {
    return MockBox<T>();
  }
}
```

**Dependencies:**

- mockito: ^5.4.2 (dev)
- build_runner: ^2.4.6 (dev)
- flutter_test: sdk

**Story Points:** 8  
**Priority:** P0  
**Acceptance Tests:** Sample tests run successfully

---

## PHASE 1: Data Layer

### Epic E1: Recipe Data Layer

**Epic Goal:** Implement complete data layer for recipe management (models, repositories, data sources).

**Business Value:** Foundation for recipe features - CRUD, search, import.

**Story Count:** 5 stories | **Total Points:** 21 | **Duration:** Week 2-3

---

#### US-E1.1: Recipe Domain Entity & Value Objects

**As a** developer  
**I want to** define Recipe domain entity and related value objects  
**So that** recipe business logic is type-safe and validated

**Acceptance Criteria:**

- [ ] Recipe entity class (pure Dart, no dependencies)
- [ ] Ingredient value object with validation
- [ ] Instruction value object
- [ ] RecipeId value object (UUID)
- [ ] Equality and hashCode implemented
- [ ] Validation rules enforced (e.g., non-empty title)
- [ ] Unit tests for entities

**Technical Implementation:**

```dart
// features/recipes/domain/entities/recipe.dart
class Recipe extends Equatable {
  final RecipeId id;
  final String title;
  final String? description;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;
  final int servings;
  final Duration? prepTime;
  final Duration? cookTime;
  final List<String> tags;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.ingredients,
    required this.instructions,
    required this.servings,
    this.prepTime,
    this.cookTime,
    this.tags = const [],
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [id, title, updatedAt];
}

// features/recipes/domain/entities/ingredient.dart
class Ingredient extends Equatable {
  final String name;
  final double? quantity;
  final String? unit;
  final String? notes;

  const Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
  });

  @override
  List<Object?> get props => [name, quantity, unit, notes];
}
```

**Story Points:** 3  
**Priority:** P0  
**Acceptance Tests:** Unit tests for entity validation

---

#### US-E1.2: Recipe Data Model & Hive Adapter

**As a** developer  
**I want to** create Recipe data model with Hive serialization  
**So that** recipes can be stored locally

**Acceptance Criteria:**

- [ ] RecipeModel class extending HiveObject
- [ ] TypeAdapter generated with hive_generator
- [ ] JSON serialization (toJson/fromJson)
- [ ] Conversion to/from domain Recipe entity
- [ ] Handle null safety correctly
- [ ] Migration strategy for schema changes
- [ ] Unit tests for serialization

**Technical Implementation:**

```dart
// features/recipes/data/models/recipe_model.dart
import 'package:hive/hive.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late List<IngredientModel> ingredients;

  @HiveField(4)
  late List<String> instructions;

  @HiveField(5)
  late int servings;

  @HiveField(6)
  int? prepTimeMinutes;

  @HiveField(7)
  int? cookTimeMinutes;

  @HiveField(8)
  List<String> tags = [];

  @HiveField(9)
  List<String> photoUrls = [];

  @HiveField(10)
  late DateTime createdAt;

  @HiveField(11)
  late DateTime updatedAt;

  @HiveField(12)
  bool isFavorite = false;

  @HiveField(13)
  bool isDeleted = false;

  @HiveField(14)
  late int syncVersion;

  // Constructor
  RecipeModel({
    required this.id,
    required this.title,
    this.description,
    required this.ingredients,
    required this.instructions,
    required this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.tags = const [],
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isDeleted = false,
    this.syncVersion = 0,
  });

  // Convert to domain entity
  Recipe toEntity() {
    return Recipe(
      id: RecipeId(id),
      title: title,
      description: description,
      ingredients: ingredients.map((i) => i.toEntity()).toList(),
      instructions: instructions.map((i) => Instruction(i)).toList(),
      servings: servings,
      prepTime: prepTimeMinutes != null ? Duration(minutes: prepTimeMinutes!) : null,
      cookTime: cookTimeMinutes != null ? Duration(minutes: cookTimeMinutes!) : null,
      tags: tags,
      photoUrls: photoUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
    );
  }

  // Create from domain entity
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id.value,
      title: recipe.title,
      description: recipe.description,
      ingredients: recipe.ingredients.map((i) => IngredientModel.fromEntity(i)).toList(),
      instructions: recipe.instructions.map((i) => i.text).toList(),
      servings: recipe.servings,
      prepTimeMinutes: recipe.prepTime?.inMinutes,
      cookTimeMinutes: recipe.cookTime?.inMinutes,
      tags: recipe.tags,
      photoUrls: recipe.photoUrls,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      isFavorite: recipe.isFavorite,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'servings': servings,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'tags': tags,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'syncVersion': syncVersion,
    };
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ingredients: (json['ingredients'] as List)
          .map((i) => IngredientModel.fromJson(i))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      servings: json['servings'],
      prepTimeMinutes: json['prepTimeMinutes'],
      cookTimeMinutes: json['cookTimeMinutes'],
      tags: List<String>.from(json['tags'] ?? []),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      syncVersion: json['syncVersion'] ?? 0,
    );
  }
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Serialization round-trip tests

---

#### US-E1.3: Recipe Local Data Source

**As a** developer  
**I want to** implement local data source for recipes  
**So that** recipes can be persisted and queried from Hive

**Acceptance Criteria:**

- [ ] RecipeLocalDataSource interface defined
- [ ] Implementation using Hive box
- [ ] CRUD operations (create, read, update, delete)
- [ ] Query operations (search, filter, sort)
- [ ] Soft delete implementation
- [ ] Error handling with custom exceptions
- [ ] Unit tests with mock Hive box

**Technical Implementation:**

```dart
// features/recipes/data/datasources/recipe_local_data_source.dart
abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getAllRecipes();
  Future<RecipeModel?> getRecipeById(String id);
  Future<void> saveRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String id);
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<List<RecipeModel>> getRecipesByTags(List<String> tags);
  Stream<List<RecipeModel>> watchRecipes();
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final Box<RecipeModel> recipeBox;

  RecipeLocalDataSourceImpl({required this.recipeBox});

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    try {
      return recipeBox.values
          .where((recipe) => !recipe.isDeleted)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw CacheException('Failed to get recipes: $e');
    }
  }

  @override
  Future<RecipeModel?> getRecipeById(String id) async {
    try {
      return recipeBox.values.firstWhere(
        (recipe) => recipe.id == id && !recipe.isDeleted,
        orElse: () => throw RecipeNotFoundException(),
      );
    } catch (e) {
      if (e is RecipeNotFoundException) rethrow;
      throw CacheException('Failed to get recipe: $e');
    }
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    try {
      await recipeBox.put(recipe.id, recipe);
    } catch (e) {
      throw CacheException('Failed to save recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      final recipe = await getRecipeById(id);
      if (recipe != null) {
        recipe.isDeleted = true;
        recipe.updatedAt = DateTime.now();
        await recipe.save();
      }
    } catch (e) {
      throw CacheException('Failed to delete recipe: $e');
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      return recipeBox.values
          .where((recipe) =>
              !recipe.isDeleted &&
              (recipe.title.toLowerCase().contains(lowerQuery) ||
               recipe.description?.toLowerCase().contains(lowerQuery) == true))
          .toList();
    } catch (e) {
      throw CacheException('Failed to search recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByTags(List<String> tags) async {
    try {
      return recipeBox.values
          .where((recipe) =>
              !recipe.isDeleted &&
              recipe.tags.any((tag) => tags.contains(tag)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get recipes by tags: $e');
    }
  }

  @override
  Stream<List<RecipeModel>> watchRecipes() {
    return recipeBox.watch().map((_) => getAllRecipes() as List<RecipeModel>);
  }
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Unit tests for all CRUD operations

---

#### US-E1.4: Recipe Repository Implementation

**As a** developer  
**I want to** implement recipe repository with offline-first logic  
**So that** domain layer has clean interface to recipe data

**Acceptance Criteria:**

- [ ] RecipeRepository interface in domain layer
- [ ] Repository implementation in data layer
- [ ] Offline-first pattern (local is source of truth)
- [ ] Result type wrapping (Either<Failure, T>)
- [ ] Error mapping from exceptions to failures
- [ ] Network check integration
- [ ] Unit tests with mocked data sources

**Technical Implementation:**

```dart
// features/recipes/domain/repositories/recipe_repository.dart
abstract class RecipeRepository {
  Future<Result<List<Recipe>>> getAllRecipes();
  Future<Result<Recipe>> getRecipeById(RecipeId id);
  Future<Result<void>> saveRecipe(Recipe recipe);
  Future<Result<void>> deleteRecipe(RecipeId id);
  Future<Result<List<Recipe>>> searchRecipes(String query);
  Future<Result<List<Recipe>>> getRecipesByTags(List<String> tags);
  Stream<Result<List<Recipe>>> watchRecipes();
}

// features/recipes/data/repositories/recipe_repository_impl.dart
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource localDataSource;
  final RecipeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RecipeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Recipe>>> getAllRecipes() async {
    try {
      final recipeModels = await localDataSource.getAllRecipes();
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Recipe>> getRecipeById(RecipeId id) async {
    try {
      final recipeModel = await localDataSource.getRecipeById(id.value);
      if (recipeModel == null) {
        return Left(CacheFailure('Recipe not found'));
      }
      return Right(recipeModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);
      await localDataSource.saveRecipe(model);

      // Queue for sync if online
      if (await networkInfo.isConnected) {
        // Add to sync queue (implemented in sync epic)
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteRecipe(RecipeId id) async {
    try {
      await localDataSource.deleteRecipe(id.value);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<List<Recipe>>> searchRecipes(String query) async {
    try {
      final recipeModels = await localDataSource.searchRecipes(query);
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<List<Recipe>>> getRecipesByTags(List<String> tags) async {
    try {
      final recipeModels = await localDataSource.getRecipesByTags(tags);
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Stream<Result<List<Recipe>>> watchRecipes() {
    return localDataSource.watchRecipes().map(
      (recipeModels) {
        final recipes = recipeModels.map((model) => model.toEntity()).toList();
        return Right(recipes) as Result<List<Recipe>>;
      },
    );
  }
}
```

**Story Points:** 5  
**Priority:** P0  
**Acceptance Tests:** Repository integration tests

---

#### US-E1.5: Recipe Data Layer Provider Setup

**As a** developer  
**I want to** configure Riverpod providers for recipe data layer  
**So that** dependencies are properly injected

**Acceptance Criteria:**

- [ ] RecipeLocalDataSource provider
- [ ] RecipeRepository provider
- [ ] Hive box provider for recipes
- [ ] Provider overrides for testing
- [ ] Documentation of provider hierarchy
- [ ] Integration test validating DI

**Technical Implementation:**

```dart
// features/recipes/data/providers/recipe_data_providers.dart
final recipeBoxProvider = Provider<Box<RecipeModel>>((ref) {
  return Hive.box<RecipeModel>('recipes');
});

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSourceImpl(
    recipeBox: ref.watch(recipeBoxProvider),
  );
});

final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  // Placeholder for future implementation
  return RecipeRemoteDataSourceImpl();
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(
    localDataSource: ref.watch(recipeLocalDataSourceProvider),
    remoteDataSource: ref.watch(recipeRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});
```

**Story Points:** 3  
**Priority:** P0  
**Acceptance Tests:** Provider resolution successful

---

### Epic E2: Shopping List Data Layer

**Epic Goal:** Implement complete data layer for shopping list management.

**Story Count:** 4 stories | **Total Points:** 16 | **Duration:** Week 2-3

---

#### US-E2.1: Shopping List Domain Entities

**As a** developer  
**I want to** define shopping list domain entities  
**So that** shopping list business logic is type-safe

**Acceptance Criteria:**

- [ ] ShoppingList entity
- [ ] ShoppingItem value object
- [ ] Category enum/value object
- [ ] Validation rules
- [ ] Unit tests

**Story Points:** 3  
**Priority:** P0

---

#### US-E2.2: Shopping List Data Models & Adapters

**As a** developer  
**I want to** create shopping list data models  
**So that** shopping lists can be persisted

**Acceptance Criteria:**

- [ ] ShoppingListModel with Hive adapter
- [ ] ShoppingItemModel with Hive adapter
- [ ] JSON serialization
- [ ] Entity conversion
- [ ] Unit tests

**Story Points:** 5  
**Priority:** P0

---

#### US-E2.3: Shopping List Local Data Source

**As a** developer  
**I want to** implement shopping list local data source  
**So that** shopping lists can be stored and queried

**Acceptance Criteria:**

- [ ] Interface defined
- [ ] CRUD operations
- [ ] Category filtering
- [ ] Purchased/unpurchased filtering
- [ ] Unit tests

**Story Points:** 5  
**Priority:** P0

---

#### US-E2.4: Shopping List Repository

**As a** developer  
**I want to** implement shopping list repository  
**So that** domain has clean data access

**Acceptance Criteria:**

- [ ] Repository interface
- [ ] Implementation with offline-first
- [ ] Result type wrapping
- [ ] Provider setup
- [ ] Integration tests

**Story Points:** 3  
**Priority:** P0

---

### Epic E3: Meal Plan Data Layer

**Epic Goal:** Implement complete data layer for meal planning.

**Story Count:** 4 stories | **Total Points:** 18 | **Duration:** Week 3-4

**Stories:**

- US-E3.1: Meal Plan Domain Entities (3 pts)
- US-E3.2: Meal Plan Data Models (5 pts)
- US-E3.3: Meal Plan Local Data Source (5 pts)
- US-E3.4: Meal Plan Repository (5 pts)

---

### Epic E4: Pantry Data Layer

**Epic Goal:** Implement complete data layer for pantry inventory.

**Story Count:** 4 stories | **Total Points:** 17 | **Duration:** Week 3-4

**Stories:**

- US-E4.1: Pantry Item Domain Entities (3 pts)
- US-E4.2: Pantry Item Data Models (5 pts)
- US-E4.3: Pantry Local Data Source (5 pts)
- US-E4.4: Pantry Repository (4 pts)

---

### Epic E5: Sync Engine Data Layer

**Epic Goal:** Implement sync queue and conflict resolution data layer.

**Story Count:** 5 stories | **Total Points:** 29 | **Duration:** Week 4-5

**Stories:**

- US-E5.1: Sync Operation Domain Entities (3 pts)
- US-E5.2: Sync Queue Data Model (5 pts)
- US-E5.3: Sync Queue Local Data Source (8 pts)
- US-E5.4: Conflict Resolution Strategy (8 pts)
- US-E5.5: Sync Repository (5 pts)

---

## PHASE 2: Domain Layer (Use Cases)

### Epic E6: Recipe Use Cases

**Epic Goal:** Implement business logic for recipe operations.

**Story Count:** 6 stories | **Total Points:** 24 | **Duration:** Week 5-6

---

#### US-E6.1: Get All Recipes Use Case

**As a** user  
**I want to** retrieve all my recipes  
**So that** I can browse my recipe collection

**Acceptance Criteria:**

- [ ] UseCase class following clean architecture
- [ ] Call repository to get recipes
- [ ] Return Result type
- [ ] Unit tests with mocked repository

**Technical Implementation:**

```dart
// features/recipes/domain/usecases/get_all_recipes.dart
class GetAllRecipesUseCase {
  final RecipeRepository repository;

  GetAllRecipesUseCase(this.repository);

  Future<Result<List<Recipe>>> call() async {
    return await repository.getAllRecipes();
  }
}
```

**Story Points:** 2  
**Priority:** P0

---

#### US-E6.2: Save Recipe Use Case

**As a** user  
**I want to** save a recipe  
**So that** I can add it to my collection

**Acceptance Criteria:**

- [ ] Validation logic (non-empty fields)
- [ ] Generate UUID if new recipe
- [ ] Update timestamp
- [ ] Call repository
- [ ] Unit tests

**Story Points:** 3  
**Priority:** P0

---

#### US-E6.3: Delete Recipe Use Case

**Story Points:** 2 | **Priority:** P0

---

#### US-E6.4: Search Recipes Use Case

**Story Points:** 5 (includes search ranking logic) | **Priority:** P0

---

#### US-E6.5: Filter Recipes by Dietary Restrictions

**Story Points:** 8 (complex filtering logic) | **Priority:** P1

---

#### US-E6.6: Scale Recipe Servings Use Case

**Story Points:** 5 (ingredient quantity scaling) | **Priority:** P1

---

### Epic E7: Shopping Use Cases

**Story Count:** 5 stories | **Total Points:** 19 | **Duration:** Week 5-6

**Stories:**

- US-E7.1: Get Shopping List (2 pts)
- US-E7.2: Add Item to Shopping List (3 pts)
- US-E7.3: Toggle Item Purchased (2 pts)
- US-E7.4: Generate List from Meal Plan (8 pts - complex logic)
- US-E7.5: Organize by Category (4 pts)

---

### Epic E8: Meal Planning Use Cases

**Story Count:** 5 stories | **Total Points:** 23 | **Duration:** Week 6-7

**Stories:**

- US-E8.1: Get Weekly Meal Plan (2 pts)
- US-E8.2: Assign Recipe to Meal Slot (3 pts)
- US-E8.3: Remove Recipe from Slot (2 pts)
- US-E8.4: Copy Previous Week Plan (5 pts)
- US-E8.5: Match Recipes with Pantry ("What Can I Make?") (11 pts - algorithm heavy)

---

### Epic E9: Pantry Use Cases

**Story Count:** 4 stories | **Total Points:** 18 | **Duration:** Week 6-7

**Stories:**

- US-E9.1: Get Pantry Inventory (2 pts)
- US-E9.2: Add/Update Pantry Item (3 pts)
- US-E9.3: Get Expiring Items (5 pts - date logic)
- US-E9.4: Suggest Recipes for Expiring Items (8 pts)

---

### Epic E10: Sync & Offline Use Cases

**Story Count:** 4 stories | **Total Points:** 21 | **Duration:** Week 7-8

**Stories:**

- US-E10.1: Queue Operation for Sync (5 pts)
- US-E10.2: Process Sync Queue (8 pts)
- US-E10.3: Resolve Conflicts (8 pts - complex logic)
- US-E10.4: Handle Offline Mode (included in above)

---

## PHASE 3: Presentation Layer (UI)

### Epic E11: Core UI Components

**Epic Goal:** Build reusable UI components and navigation.

**Story Count:** 6 stories | **Total Points:** 22 | **Duration:** Week 8-9

**Stories:**

- US-E11.1: Bottom Navigation & Routing (5 pts)
- US-E11.2: Custom Widgets Library (card, button, input) (5 pts)
- US-E11.3: Empty State Components (2 pts)
- US-E11.4: Loading Skeletons (3 pts)
- US-E11.5: Error Handling UI (3 pts)
- US-E11.6: Sync Status Indicator Widget (4 pts)

---

### Epic E12: Shopping List UI

**Epic Goal:** Build shopping list screens and interactions.

**Story Count:** 5 stories | **Total Points:** 20 | **Duration:** Week 9-10

**Stories:**

- US-E12.1: Shopping Lists Page (list view) (5 pts)
- US-E12.2: Shopping List Detail Page (5 pts)
- US-E12.3: Add Item Bottom Sheet (4 pts)
- US-E12.4: Category Organization UI (3 pts)
- US-E12.5: Swipe Actions (edit/delete) (3 pts)

---

### Epic E13: Recipe Management UI

**Epic Goal:** Build recipe screens.

**Story Count:** 6 stories | **Total Points:** 25 | **Duration:** Week 10-11

**Stories:**

- US-E13.1: Recipe List Page (5 pts)
- US-E13.2: Recipe Detail Page (5 pts)
- US-E13.3: Recipe Form (create/edit) (8 pts)
- US-E13.4: Recipe Search & Filter UI (4 pts)
- US-E13.5: Photo Gallery Widget (3 pts)

---

### Epic E14: Meal Planning UI

**Epic Goal:** Build meal planning calendar and interactions.

**Story Count:** 5 stories | **Total Points:** 23 | **Duration:** Week 11-12

**Stories:**

- US-E14.1: Weekly Calendar View (8 pts)
- US-E14.2: Assign Recipe to Slot Bottom Sheet (5 pts)
- US-E14.3: Meal Slot Card Widget (3 pts)
- US-E14.4: Generate Shopping List Button & Flow (4 pts)
- US-E14.5: "What Can I Make?" Filter UI (3 pts)

---

### Epic E15: Pantry Inventory UI

**Epic Goal:** Build pantry management screens.

**Story Count:** 4 stories | **Total Points:** 18 | **Duration:** Week 12-13

**Stories:**

- US-E15.1: Pantry Inventory List (5 pts)
- US-E15.2: Add Pantry Item Form (4 pts)
- US-E15.3: Expiring Items Dashboard (5 pts)
- US-E15.4: Color-Coded Freshness Indicators (4 pts)

---

## PHASE 4: Advanced Features

### Epic E16: Family & Collaboration Features

**Story Count:** 6 stories | **Total Points:** 27 | **Duration:** Week 13-14

**Stories:**

- US-E16.1: Household Profiles Data Layer (5 pts)
- US-E16.2: Meal Voting System (8 pts)
- US-E16.3: Shared Shopping Lists (8 pts)
- US-E16.4: Profile Management UI (3 pts)
- US-E16.5: Dietary Restrictions per Profile (3 pts)

---

### Epic E17: Smart Features & AI

**Story Count:** 7 stories | **Total Points:** 41 | **Duration:** Week 15-17

**Stories:**

- US-E17.1: Recipe URL Import Service (8 pts)
- US-E17.2: Photo-Based Item Recognition (8 pts)
- US-E17.3: Voice Input Integration (5 pts)
- US-E17.4: Recipe Recommendations Algorithm (8 pts)
- US-E17.5: Leftover Planning Suggestions (8 pts)
- US-E17.6: Budget Tracking (4 pts)

---

### Epic E18: Settings & Privacy UI

**Story Count:** 4 stories | **Total Points:** 15 | **Duration:** Week 13-14

**Stories:**

- US-E18.1: Settings Screen Structure (3 pts)
- US-E18.2: Cloud Sync Toggle & Setup (5 pts)
- US-E18.3: Data Export/Import (5 pts)
- US-E18.4: Privacy & Account Deletion (2 pts)

---

## Release Planning

### MVP Release (v1.0) - Week 13

**Included Epics:** E0-E15  
**Total Points:** 310  
**Features:**

- ✅ Core shopping list management (offline)
- ✅ Recipe CRUD and search
- ✅ Weekly meal planning
- ✅ Pantry inventory with expiration tracking
- ✅ Auto-generate shopping lists from meal plans
- ✅ "What Can I Make?" recipe matching
- ✅ Offline-first with sync queue

**Not Included:**

- ❌ Family collaboration
- ❌ AI/ML features
- ❌ Recipe import from URL
- ❌ Photo recognition

---

### Post-MVP Release (v1.1) - Week 16

**Included Epics:** E16  
**Features:**

- ✅ Household profiles
- ✅ Meal voting
- ✅ Shared shopping lists

---

### Future Release (v1.2) - Week 20

**Included Epics:** E17  
**Features:**

- ✅ Recipe URL import
- ✅ Photo-based item entry
- ✅ Voice input
- ✅ Smart recommendations
- ✅ Budget tracking

---

## Testing Strategy by Phase

### Phase 1 (Data Layer)

- **Unit Tests:** 100% coverage for models, data sources, repositories
- **Integration Tests:** Database operations, serialization
- **Test Data:** Factories for generating test entities

### Phase 2 (Use Cases)

- **Unit Tests:** All use cases with mocked repositories
- **Business Logic Tests:** Validation, calculations, algorithms

### Phase 3 (UI)

- **Widget Tests:** All custom widgets
- **Integration Tests:** Screen flows
- **Golden Tests:** Visual regression tests

### Phase 4 (Advanced Features)

- **E2E Tests:** Critical user journeys
- **Performance Tests:** Large data loads

---

## Success Metrics

### Data Layer Completion (Phase 1)

- [ ] All repositories return Result types
- [ ] 100% unit test coverage for models
- [ ] All CRUD operations tested
- [ ] Migration strategy documented

### Use Case Completion (Phase 2)

- [ ] All business logic unit tested
- [ ] No domain layer dependencies on Flutter
- [ ] Use cases reusable across UI

### UI Completion (Phase 3)

- [ ] All screens navigable
- [ ] Offline mode functional
- [ ] Widget tests pass
- [ ] Performance benchmarks met (<16ms frame time)

---

## Dependencies & Risks

### Critical Path

1. **E0 Foundation** → blocks everything
2. **E1-E4 Data Layer** → blocks use cases
3. **E6-E9 Use Cases** → blocks UI
4. **E5 Sync Engine** → can be done in parallel but needed for MVP

### Risks

- **Hive Performance:** Monitor with large datasets (10K+ recipes)
- **Sync Conflicts:** Complex resolution logic may take longer
- **Search Performance:** May need to add search index library
- **Migration Strategy:** First schema change will validate approach

### Mitigation

- Benchmark Hive early (Week 2)
- Prototype sync conflict resolution (Week 4)
- Evaluate `flutter_search` or `meilisearch` (Week 5)
- Document migration process in E0

---

## Appendix

### Definition of Done (DoD)

Each story is considered done when:

- [ ] Code written and peer reviewed
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration tests written for data layer
- [ ] Documentation updated (inline comments + README)
- [ ] No linter warnings
- [ ] Merged to main branch

### Tools & Packages by Phase

**Phase 0-1 (Foundation & Data):**

- hive, hive_flutter, hive_generator
- flutter_riverpod
- dartz, equatable
- connectivity_plus
- uuid

**Phase 2 (Use Cases):**

- (same as above, no new packages)

**Phase 3 (UI):**

- go_router (navigation)
- cached_network_image
- flutter_svg
- shimmer (loading skeletons)
- image_picker

**Phase 4 (Advanced):**

- speech_to_text
- http (recipe import)
- share_plus
- google_ml_kit (photo recognition)

---

**Document End**
