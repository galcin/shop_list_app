# Technical Architecture Specification

## Flutter Shopping List & Meal Planning App

**Document Version:** 1.0  
**Date:** February 25, 2026  
**Status:** Draft  
**Related Documents:** [PRD](prd-shopping-list-app.md), [UX Design](ux-design-shopping-list-app.md), [Brainstorming](brainstorming/brainstorming-session-2026-02-25.md)

---

## Executive Summary

This document provides a comprehensive technical architecture for the Flutter Shopping List & Meal Planning App, detailing the system design, data architecture, application structure, infrastructure, and deployment strategy. The architecture prioritizes offline-first functionality, data privacy, scalability, and maintainability.

### Architecture Principles

1. **Offline-First** - Local data is source of truth, cloud is secondary
2. **Clean Architecture** - Clear separation of concerns, testable code
3. **Platform Agnostic** - Single codebase for iOS and Android
4. **Progressive Enhancement** - Core features work everywhere, advanced features when available
5. **Privacy by Design** - Minimal data collection, user control, encryption
6. **Scalable Foundation** - Handle 10K+ recipes, 1000+ pantry items per user
7. **Maintainable** - Clear structure, comprehensive testing, documentation

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Patterns](#architecture-patterns)
3. [Application Architecture](#application-architecture)
4. [Data Architecture](#data-architecture)
5. [Sync Architecture](#sync-architecture)
6. [Infrastructure Architecture](#infrastructure-architecture)
7. [Security Architecture](#security-architecture)
8. [API Design](#api-design)
9. [Performance Architecture](#performance-architecture)
10. [Testing Strategy](#testing-strategy)
11. [Deployment Architecture](#deployment-architecture)
12. [Monitoring & Observability](#monitoring--observability)

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile Client (Flutter)                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Presentation Layer (UI)                    │ │
│  │  Widgets, Pages, State Management (Riverpod)           │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │            Application Layer (Use Cases)                │ │
│  │  Business Logic, Validation, Orchestration             │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Domain Layer (Entities)                    │ │
│  │  Core Models, Value Objects, Business Rules            │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │               Data Layer (Repository)                   │ │
│  │  ┌───────────────────┐    ┌──────────────────────┐    │ │
│  │  │ Local Data Source │    │ Remote Data Source   │    │ │
│  │  │ (Drift/SQLite)    │◄──►│ (Firebase/Supabase)  │    │ │
│  │  │    [MVP]          │    │     [Post-MVP]       │    │ │
│  │  └───────────────────┘    └──────────────────────┘    │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │ HTTPS/WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Cloud Backend (Firebase/Supabase)          │
│  ┌────────────┐  ┌───────────┐  ┌─────────────┐           │
│  │ Firestore/ │  │   Auth    │  │   Storage   │           │
│  │ PostgreSQL │  │ (OAuth)   │  │  (Images)   │           │
│  └────────────┘  └───────────┘  └─────────────┘           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           Cloud Functions / Edge Functions              │ │
│  │  Recipe Import, Image Processing, Sync Logic           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Third-Party Services                       │
│  [Recipe APIs] [ML Kit] [Push Notifications] [Analytics]   │
└─────────────────────────────────────────────────────────────┘
```

---

### Component Responsibilities

| Component            | Responsibilities                             | Technologies         |
| -------------------- | -------------------------------------------- | -------------------- |
| **Mobile Client**    | UI, local storage, offline logic, sync queue | Flutter, Dart        |
| **Local Database**   | Persistent storage, offline data (MVP)       | Drift (SQLite)       |
| **Backend Services** | Authentication, cloud sync (Post-MVP)        | Firebase or Supabase |
| **Cloud Functions**  | Recipe import, image processing (Post-MVP)   | Node.js, TypeScript  |
| **Storage**          | Recipe images, user photos (Post-MVP)        | Cloud Storage        |
| **External APIs**    | Recipe data, nutrition info (Post-MVP)       | REST APIs            |

---

## Architecture Patterns

### 1. Clean Architecture (Uncle Bob)

**Layer Isolation:**

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │ ← UI, State Management
│    (Flutter Widgets, Providers)             │   (No business logic)
├─────────────────────────────────────────────┤
│        Application Layer                    │ ← Use Cases, Orchestration
│         (Use Cases)                         │   (Platform agnostic)
├─────────────────────────────────────────────┤
│          Domain Layer                       │ ← Core Business Logic
│   (Entities, Value Objects)                 │   (Pure Dart, no dependencies)
├─────────────────────────────────────────────┤
│          Data Layer                         │ ← Data Access, External APIs
│  (Repositories, Data Sources)               │   (Implementation details)
└─────────────────────────────────────────────┘
```

**Dependency Rule:**

- Dependencies point inward only
- Inner layers know nothing about outer layers
- Domain layer has zero external dependencies

---

### 2. Repository Pattern

**Abstract Data Access:**

```dart
// Domain Layer - Repository Interface (abstract)
abstract class RecipeRepository {
  Future<Result<List<Recipe>>> getAllRecipes();
  Future<Result<Recipe>> getRecipeById(String id);
  Future<Result<Recipe>> saveRecipe(Recipe recipe);
  Future<Result<void>> deleteRecipe(String id);
  Stream<List<Recipe>> watchRecipes();
}

// Data Layer - Repository Implementation
class RecipeRepositoryImpl implements RecipeRepository {
  final LocalRecipeDataSource localDataSource;
  final RemoteRecipeDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncQueue syncQueue;

  RecipeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncQueue,
  });

  @override
  Future<Result<List<Recipe>>> getAllRecipes() async {
    // 1. Always return local data first (offline-first)
    final localRecipes = await localDataSource.getAllRecipes();

    // 2. Attempt background sync if online
    if (await networkInfo.isConnected) {
      _syncInBackground();
    }

    return Success(localRecipes);
  }

  @override
  Future<Result<Recipe>> saveRecipe(Recipe recipe) async {
    // 1. Write to local database immediately
    await localDataSource.saveRecipe(recipe);

    // 2. Queue for sync
    await syncQueue.enqueue(
      SyncOperation.createOrUpdate(
        entityType: 'recipe',
        entityId: recipe.id,
        data: recipe.toJson(),
      ),
    );

    // 3. Attempt sync if online
    if (await networkInfo.isConnected) {
      syncQueue.processPending();
    }

    return Success(recipe);
  }
}
```

---

### 3. Offline-First Pattern

**Write Path:**

```
User Action (e.g., Add Item to Shopping List)
    ↓
[UI Layer] - Optimistic Update (instant visual feedback)
    ↓
[Use Case] - Validate & Execute
    ↓
[Repository] - Write to Local DB (< 50ms)
    ↓
[Local DB] - Immediate persist
    ↓
[Sync Queue] - Add operation to queue
    ↓
[Network Check] - Is online?
    ├─ Yes: Process sync queue immediately
    │   ↓
    │   [Remote Sync] - Send to backend
    │   ↓
    │   [Conflict Check] - Any conflicts?
    │   ├─ No: Mark synced ✓
    │   └─ Yes: Resolve conflict
    │
    └─ No: Queue persists until online
        ↓
        [Background Job] - Retry when connected
```

**Read Path:**

```
User Opens Screen
    ↓
[UI Layer] - Show loading skeleton
    ↓
[Use Case] - Request data
    ↓
[Repository] - Get from local DB
    ↓
[Local DB] - Return cached data (< 50ms)
    ↓
[UI Layer] - Display data immediately
    ↓
[Background Sync] - Check for updates
    ├─ Online: Fetch latest from backend
    │   ↓
    │   Compare with local data
    │   ├─ Same: No update needed
    │   └─ Different: Merge changes
    │       ↓
    │       Update local DB
    │       ↓
    │       Notify UI to refresh
    │
    └─ Offline: Stay with cached data
```

---

### 4. MVVM with Riverpod Pattern

**State Management Architecture:**

```
┌─────────────────────────────────────────────┐
│              View (Widget)                  │
│  - Stateless/Stateful Widget                │
│  - Observes Riverpod Providers              │
│  - Renders UI based on state                │
└──────────────────┬──────────────────────────┘
                   │ User Actions (events)
                   ▼
┌─────────────────────────────────────────────┐
│        StateNotifier / Provider             │
│  - Holds UI state                           │
│  - Handles user interactions                │
│  - Calls use cases                          │
│  - Transforms data for UI                   │
└──────────────────┬──────────────────────────┘
                   │ Execute business logic
                   ▼
┌─────────────────────────────────────────────┐
│            Use Case (Interactor)            │
│  - Single responsibility                    │
│  - Coordinates repositories                 │
│  - Enforces business rules                  │
└──────────────────┬──────────────────────────┘
                   │ Data operations
                   ▼
┌─────────────────────────────────────────────┐
│              Repository                     │
│  - Abstracts data sources                   │
│  - Handles offline/online logic             │
└─────────────────────────────────────────────┘
```

**Example: Shopping List Feature with Riverpod**

```dart
// View (ConsumerWidget)
class ShoppingListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shoppingListProvider);

    return state.when(
      loading: () => LoadingSkeleton(),
      loaded: (list) => ShoppingListView(list: list),
      error: (error) => ErrorView(error: error),
    );
  }
}

// ViewModel/Provider (Riverpod)
final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, ShoppingListState>(
  (ref) => ShoppingListNotifier(
    getShoppingList: ref.watch(getShoppingListUseCaseProvider),
    addItem: ref.watch(addShoppingListItemUseCaseProvider),
    toggleItem: ref.watch(toggleShoppingListItemUseCaseProvider),
  ),
);

class ShoppingListNotifier extends StateNotifier<ShoppingListState> {
  final GetShoppingListUseCase getShoppingList;
  final AddShoppingListItemUseCase addItem;
  final ToggleShoppingListItemUseCase toggleItem;

  ShoppingListNotifier({
    required this.getShoppingList,
    required this.addItem,
    required this.toggleItem,
  }) : super(ShoppingListState.loading());

  Future<void> loadList(String listId) async {
    state = ShoppingListState.loading();

    final result = await getShoppingList(listId);

    result.fold(
      (failure) => state = ShoppingListState.error(failure.message),
      (list) => state = ShoppingListState.loaded(list),
    );
  }

  Future<void> addItemToList(String itemName, {double? quantity, String? unit}) async {
    final result = await addItem(
      listId: state.list!.id,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
    );

    result.fold(
      (failure) => _showError(failure.message),
      (updatedList) => state = ShoppingListState.loaded(updatedList),
    );
  }
}

// Use Case
class AddShoppingListItemUseCase {
  final ShoppingListRepository repository;

  Future<Result<ShoppingList>> call({
    required String listId,
    required String itemName,
    double? quantity,
    String? unit,
  }) async {
    // Validation
    if (itemName.trim().isEmpty) {
      return Failure(ValidationError('Item name cannot be empty'));
    }

    // Business logic
    final item = ShoppingItem(
      id: Uuid().v4(),
      name: itemName.trim(),
      quantity: quantity,
      unit: unit,
      isPurchased: false,
      category: _inferCategory(itemName), // Smart categorization
      createdAt: DateTime.now(),
    );

    // Execute
    return await repository.addItemToList(listId, item);
  }

  String? _inferCategory(String itemName) {
    // Simple ML-based categorization
    final lower = itemName.toLowerCase();
    if (lower.contains(RegExp(r'milk|cheese|yogurt|butter'))) return 'dairy';
    if (lower.contains(RegExp(r'apple|banana|orange|berry'))) return 'produce';
    // ... more categories
    return null;
  }
}
```

---

## Application Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
├── core/                              # Shared core functionality
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── storage_constants.dart
│   ├── error/
│   │   ├── failures.dart              # Error types
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── network_info.dart          # Connectivity check
│   │   └── api_client.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── string_utils.dart
│   │   └── validators.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── typography.dart
│   └── providers/
│       └── core_providers.dart        # Core Riverpod providers
│
├── features/                          # Feature-based modules
│   ├── shopping/                      # Shopping List feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── shopping_list.dart
│   │   │   │   └── shopping_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── shopping_list_repository.dart  # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── get_shopping_list.dart
│   │   │       ├── add_item_to_list.dart
│   │   │       ├── toggle_item.dart
│   │   │       └── generate_list_from_meal_plan.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── shopping_list_model.dart      # JSON serialization
│   │   │   │   └── shopping_item_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── shopping_list_local_data_source.dart
│   │   │   │   └── shopping_list_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── shopping_list_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── shopping_list_provider.dart
│   │       ├── pages/
│   │       │   ├── shopping_lists_page.dart
│   │       │   └── shopping_list_detail_page.dart
│   │       └── widgets/
│   │           ├── shopping_list_card.dart
│   │           ├── shopping_item_tile.dart
│   │           └── add_item_sheet.dart
│   │
│   ├── recipes/                       # Recipe management feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── recipe.dart
│   │   │   │   └── ingredient.dart
│   │   │   ├── repositories/
│   │   │   │   └── recipe_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_all_recipes.dart
│   │   │       ├── save_recipe.dart
│   │   │       ├── import_recipe_from_url.dart
│   │   │       └── search_recipes.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── meal_planning/                 # Meal planning feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── meal_plan.dart
│   │   │   ├── repositories/
│   │   │   │   └── meal_plan_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_weekly_plan.dart
│   │   │       ├── assign_recipe_to_slot.dart
│   │   │       └── generate_shopping_list.dart
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── pantry/                        # Pantry inventory feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── pantry_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── pantry_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_all_pantry_items.dart
│   │   │       ├── add_pantry_item.dart
│   │   │       ├── get_expiring_items.dart
│   │   │       └── match_recipes_with_pantry.dart
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── auth/                          # Authentication (optional)
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── sync/                          # Sync engine
│       ├── domain/
│       │   ├── entities/
│       │   │   └── sync_operation.dart
│       │   └── repositories/
│       │       └── sync_repository.dart
│       ├── data/
│       │   ├── sync_queue.dart
│       │   ├── conflict_resolver.dart
│       │   └── sync_coordinator.dart
│       └── presentation/
│           └── widgets/
│               └── sync_indicator.dart
│
└── shared/                            # Shared widgets/utilities
    ├── widgets/
    │   ├── loading_skeleton.dart
    │   ├── error_view.dart
    │   └── empty_state.dart
    └── extensions/
        ├── context_extensions.dart
        └── string_extensions.dart
```

---

### Dependency Injection with Riverpod

**Using Riverpod Providers:**

```dart
// lib/core/providers/core_providers.dart

// External dependencies
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// Core services
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(connectivity: Connectivity());
});

// lib/features/shopping/data/providers/shopping_data_providers.dart

final shoppingListLocalDataSourceProvider = Provider<ShoppingListLocalDataSource>((ref) {
  return ShoppingListLocalDataSourceImpl(db: ref.watch(databaseProvider));
});

final shoppingListRemoteDataSourceProvider = Provider<ShoppingListRemoteDataSource>((ref) {
  return ShoppingListRemoteDataSourceImpl();
});

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepositoryImpl(
    localDataSource: ref.watch(shoppingListLocalDataSourceProvider),
    remoteDataSource: ref.watch(shoppingListRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    syncQueue: ref.watch(syncQueueProvider),
  );
});

// lib/features/shopping/domain/providers/shopping_usecase_providers.dart

final getShoppingListUseCaseProvider = Provider<GetShoppingListUseCase>((ref) {
  return GetShoppingListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final addShoppingListItemUseCaseProvider = Provider<AddShoppingListItemUseCase>((ref) {
  return AddShoppingListItemUseCase(ref.watch(shoppingListRepositoryProvider));
});

final toggleShoppingListItemUseCaseProvider = Provider<ToggleShoppingListItemUseCase>((ref) {
  return ToggleShoppingListItemUseCase(ref.watch(shoppingListRepositoryProvider));
});

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize external dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  // Database is initialized lazily by Drift provider

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        // databaseProvider creates AppDatabase instance automatically
      ],
      child: MyApp(),
    ),
  );
}
```

---

## Data Architecture

### Database Schema

#### Local Database (Drift/SQLite)

**Drift Tables:**

```dart
// core/database/tables/recipes_table.dart
import 'package:drift/drift.dart';

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get servings => integer()();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  TextColumn get ingredients => text()(); // JSON string
  TextColumn get instructions => text()(); // JSON array
  TextColumn get imageUrls => text().nullable()(); // JSON array
  TextColumn get tags => text()(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// core/database/tables/shopping_lists_table.dart
class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get linkedMealPlanId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// core/database/tables/shopping_items_table.dart
class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// core/database/tables/pantry_items_table.dart
class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// sync_queue (Drift Table for Post-MVP cloud sync)
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'recipe', 'shopping_list', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Drift Schema Features:**

```dart
// Database class with all tables
@DriftDatabase(
  tables: [
    Recipes,
    ShoppingLists,
    ShoppingItems,
    PantryItems,
    MealPlans,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Migrations
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema changes
      },
    );
  }
}
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  TextColumn get ingredientsJson => text()(); // JSON string
  TextColumn get instructionsJson => text()();
  TextColumn get imageUrlsJson => text().nullable()();
  TextColumn get tagsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShoppingList')
class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get itemsJson => text()(); // JSON array of items
  TextColumn get linkedMealPlanId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PantryItem')
class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Database class
@DriftDatabase(tables: [Recipes, ShoppingLists, PantryItems, SyncOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Complex queries
  Future<List<Recipe>> getRecipesWithIngredientsInPantry() async {
    // Join recipes with pantry items
    // Calculate match percentage
    // Return sorted list
  }

  Future<List<PantryItem>> getExpiringItems(int daysThreshold) {
    return (select(pantryItems)
      ..where((item) => item.expirationDate.isSmallerOrEqualValue(
        DateTime.now().add(Duration(days: daysThreshold))
      ))
      ..orderBy([(item) => OrderingTerm.asc(item.expirationDate)]))
      .get();
  }
}

static LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
```

---

### Cloud Database Schema

**Firestore Collections:**

```
users/
  {userId}/
    profile: {
      email: string,
      displayName: string,
      dietaryRestrictions: string[],
      blockedIngredients: string[],
      preferences: map,
      createdAt: timestamp,
      updatedAt: timestamp
    }

    recipes/
      {recipeId}/
        id: string,
        title: string,
        description: string,
        servings: number,
        prepTimeMinutes: number,
        cookTimeMinutes: number,
        ingredients: array<{
          id: string,
          quantity: number,
          unit: string,
          name: string,
          notes: string
        }>,
        instructions: string[],
        imageUrls: string[],
        tags: string[],
        createdAt: timestamp,
        updatedAt: timestamp,
        syncVersion: number,
        isDeleted: boolean

    shopping_lists/
      {listId}/
        id: string,
        name: string,
        items: array<{
          id: string,
          name: string,
          quantity: number,
          unit: string,
          category: string,
          isPurchased: boolean,
          notes: string
        }>,
        linkedMealPlanId: string,
        isCompleted: boolean,
        createdAt: timestamp,
        updatedAt: timestamp,
        syncVersion: number

    meal_plans/
      {planId}/
        id: string,
        weekStartDate: timestamp,
        meals: map<string, string>, // "monday_dinner" -> recipeId
        isLocked: boolean,
        createdAt: timestamp,
        updatedAt: timestamp,
        syncVersion: number

    pantry_items/
      {itemId}/
        id: string,
        name: string,
        quantity: number,
        unit: string,
        category: string,
        expirationDate: timestamp,
        addedAt: timestamp,
        updatedAt: timestamp,
        syncVersion: number
```

**Supabase (PostgreSQL) Schema:**

```sql
-- Users table (managed by Supabase Auth)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT,
  display_name TEXT,
  dietary_restrictions TEXT[],
  blocked_ingredients TEXT[],
  preferences JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Recipes table
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  servings INTEGER NOT NULL,
  prep_time_minutes INTEGER,
  cook_time_minutes INTEGER,
  ingredients JSONB NOT NULL, -- Array of ingredient objects
  instructions TEXT[] NOT NULL,
  image_urls TEXT[],
  tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  sync_version INTEGER DEFAULT 0,
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes for fast queries
CREATE INDEX idx_recipes_user_id ON recipes(user_id);
CREATE INDEX idx_recipes_tags ON recipes USING GIN(tags);
CREATE INDEX idx_recipes_updated_at ON recipes(updated_at);
CREATE INDEX idx_recipes_title ON recipes USING GIN(to_tsvector('english', title));

-- Full-text search index
CREATE INDEX idx_recipes_search ON recipes USING GIN(
  to_tsvector('english', title || ' ' || COALESCE(description, ''))
);

-- Shopping lists table
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  items JSONB NOT NULL, -- Array of shopping item objects
  linked_meal_plan_id UUID,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  sync_version INTEGER DEFAULT 0
);

CREATE INDEX idx_shopping_lists_user_id ON shopping_lists(user_id);
CREATE INDEX idx_shopping_lists_created_at ON shopping_lists(created_at);

-- Meal plans table
CREATE TABLE meal_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  meals JSONB NOT NULL, -- Map of meal slots to recipe IDs
  is_locked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  sync_version INTEGER DEFAULT 0
);

CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);
CREATE INDEX idx_meal_plans_week_start ON meal_plans(week_start_date);

-- Pantry items table
CREATE TABLE pantry_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity DECIMAL NOT NULL,
  unit TEXT NOT NULL,
  category TEXT,
  expiration_date DATE,
  added_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  sync_version INTEGER DEFAULT 0
);

CREATE INDEX idx_pantry_items_user_id ON pantry_items(user_id);
CREATE INDEX idx_pantry_items_expiration ON pantry_items(expiration_date);
CREATE INDEX idx_pantry_items_category ON pantry_items(category);

-- RLS (Row Level Security) policies
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE pantry_items ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY recipes_policy ON recipes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY shopping_lists_policy ON shopping_lists FOR ALL USING (auth.uid() = user_id);
CREATE POLICY meal_plans_policy ON meal_plans FOR ALL USING (auth.uid() = user_id);
CREATE POLICY pantry_items_policy ON pantry_items FOR ALL USING (auth.uid() = user_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON recipes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

### Data Models

**Domain Entity (Pure Dart):**

```dart
// lib/features/recipes/domain/entities/recipe.dart
class Recipe extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    required this.ingredients,
    required this.instructions,
    this.imageUrls = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic methods
  bool hasIngredient(String ingredientName) {
    return ingredients.any((ing) =>
      ing.name.toLowerCase().contains(ingredientName.toLowerCase())
    );
  }

  int get totalTimeMinutes {
    return (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
  }

  Recipe scaleServings(int newServings) {
    final scaleFactor = newServings / servings;
    return copyWith(
      servings: newServings,
      ingredients: ingredients.map((ing) => ing.scale(scaleFactor)).toList(),
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, servings, prepTimeMinutes, cookTimeMinutes,
    ingredients, instructions, imageUrls, tags, createdAt, updatedAt,
  ];

  Recipe copyWith({
    String? title,
    String? description,
    int? servings,
    List<Ingredient>? ingredients,
    // ... other fields
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      // ... other fields
    );
  }
}
```

**Data Model (JSON Serialization):**

```dart
// lib/features/recipes/data/models/recipe_model.dart
@freezed
class RecipeModel with _$RecipeModel {
  const factory RecipeModel({
    required String id,
    required String title,
    String? description,
    required int servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    required List<IngredientModel> ingredients,
    required List<String> instructions,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
    @Default(0) int syncVersion,
  }) = _RecipeModel;

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);

  // Convert to domain entity
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      ingredients: recipe.ingredients.map((e) => IngredientModel.fromEntity(e)).toList(),
      instructions: recipe.instructions,
      imageUrls: recipe.imageUrls,
      tags: recipe.tags,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
    );
  }
}

extension RecipeModelX on RecipeModel {
  Recipe toEntity() {
    return Recipe(
      id: id,
      title: title,
      description: description,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      ingredients: ingredients.map((e) => e.toEntity()).toList(),
      instructions: instructions,
      imageUrls: imageUrls,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

---

## Sync Architecture

### Sync Strategy

**Differential Sync with Conflict Resolution:**

```dart
class SyncCoordinator {
  final SyncQueue syncQueue;
  final NetworkInfo networkInfo;
  final List<SyncableRepository> repositories;

  // Periodic background sync
  Future<void> startPeriodicSync() async {
    Timer.periodic(Duration(minutes: 15), (_) async {
      if (await networkInfo.isConnected) {
        await syncAll();
      }
    });
  }

  // Manual sync triggered by user
  Future<SyncResult> syncAll() async {
    if (!await networkInfo.isConnected) {
      return SyncResult.offline();
    }

    final results = <String, SyncStatus>{};

    // Process sync queue (pending local changes)
    await _processSyncQueue();

    // Pull updates from server
    for (final repo in repositories) {
      try {
        final status = await repo.syncFromServer();
        results[repo.entityType] = status;
      } catch (e) {
        results[repo.entityType] = SyncStatus.error(e.toString());
      }
    }

    return SyncResult(results);
  }

  Future<void> _processSyncQueue() async {
    final pending = await syncQueue.getPendingOperations();

    for (final operation in pending) {
      try {
  final success = await _executeSyncOperation(operation);
        if (success) {
          await syncQueue.markCompleted(operation.id);
        } else {
          await syncQueue.incrementRetry(operation.id);
        }
      } catch (e) {
        await syncQueue.markFailed(operation.id, e.toString());
      }
    }
  }

  Future<bool> _executeSyncOperation(SyncOperation op) async {
    final repo = repositories.firstWhere((r) => r.entityType == op.entityType);

    switch (op.operation) {
      case 'create':
        return await repo.syncCreate(op.entityId, op.data);
      case 'update':
        return await repo.syncUpdate(op.entityId, op.data);
      case 'delete':
        return await repo.syncDelete(op.entityId);
      default:
        return false;
    }
  }
}
```

---

### Conflict Resolution

**Strategies:**

1. **Last-Write-Wins (LWW):**

```dart
class LastWriteWinsResolver implements ConflictResolver {
  @override
  Future<T> resolve<T>(T local, T remote) async {
    // Compare timestamps
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      return local;
    } else {
      return remote;
    }
  }
}
```

2. **Operational Transform (for Lists):**

```dart
class OperationalTransformResolver implements ConflictResolver {
  @override
  Future<ShoppingList> resolve(
    ShoppingList local,
    ShoppingList remote,
    ShoppingList base,
  ) async {
    // Find operations since base
    final localOps = _diffOperations(base, local);
    final remoteOps = _diffOperations(base, remote);

    // Transform operations
    final transformedOps = _transform(localOps, remoteOps);

    // Apply both sets of operations to base
    final merged = _apply(base, transformedOps);

    return merged;
  }

  List<Operation> _diffOperations(ShoppingList from, ShoppingList to) {
    final ops = <Operation>[];

    // Find added items
    for (final item in to.items) {
      if (!from.items.any((i) => i.id == item.id)) {
        ops.add(Operation.insert(item));
      }
    }

    // Find removed items
    for (final item in from.items) {
      if (!to.items.any((i) => i.id == item.id)) {
        ops.add(Operation.delete(item.id));
      }
    }

    // Find updated items
    for (final toItem in to.items) {
      final fromItem = from.items.firstWhereOrNull((i) => i.id == toItem.id);
      if (fromItem != null && fromItem != toItem) {
        ops.add(Operation.update(toItem));
      }
    }

    return ops;
  }
}
```

3. **Manual Resolution (Complex Cases):**

```dart
class ManualConflictResolver implements ConflictResolver {
  @override
  Future<T> resolve<T>(T local, T remote) async {
    // Show conflict resolution UI
    return await _showConflictResolutionDialog<T>(
      local: local,
      remote: remote,
      options: [
        ConflictOption.keepLocal,
        ConflictOption.useRemote,
        ConflictOption.merge,
      ],
    );
  }
}
```

---

### Sync Queue Management

```dart
class SyncQueue {
  final Box<SyncOperationModel> _box;

  Future<void> enqueue(SyncOperation operation) async {
    final model = SyncOperationModel.fromEntity(operation);
    await _box.put(operation.id, model);
  }

  Future<List<SyncOperation>> getPendingOperations() async {
    return _box.values
        .where((op) => op.retryCount < MAX_RETRIES)
        .map((m) => m.toEntity())
        .toList();
  }

  Future<void> markCompleted(String operationId) async {
    await _box.delete(operationId);
  }

  Future<void> incrementRetry(String operationId) async {
    final op = _box.get(operationId);
    if (op != null) {
      op.retryCount++;
      await op.save();
    }
  }

  Future<void> markFailed(String operationId, String error) async {
    final op = _box.get(operationId);
    if (op != null) {
      op.error = error;
      await op.save();
    }
  }

  Future<int> getPendingCount() async {
    return _box.values.where((op) => op.retryCount < MAX_RETRIES).length;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
```

---

## Infrastructure Architecture

### Development Environment

```
┌──────────────────────────────────────────────┐
│         Developer Workstation                │
│  - Flutter SDK 3.16+                         │
│  - Dart 3.2+                                 │
│  - VS Code / Android Studio                  │
│  - Git                                       │
└────────────────┬─────────────────────────────┘
                 │ Push code
                 ▼
┌──────────────────────────────────────────────┐
│         GitHub Repository                    │
│  - Source code                               │
│  - CI/CD workflows                           │
│  - Issue tracking                            │
└────────────────┬─────────────────────────────┘
                 │ Trigger build
                 ▼
┌──────────────────────────────────────────────┐
│         CI/CD (GitHub Actions)               │
│  1. Lint & Format Check                      │
│  2. Unit Tests                               │
│  3. Widget Tests                             │
│  4. Integration Tests                        │
│  5. Build iOS & Android                      │
│  6. Deploy to Beta                           │
└────────────────┬─────────────────────────────┘
                 │ Deploy
                 ▼
┌──────────────────────────────────────────────┐
│         Beta Distribution                    │
│  - TestFlight (iOS)                          │
│  - Firebase App Distribution (Android)       │
└──────────────────────────────────────────────┘
```

---

### Production Environment

**Cloud Services:**

```
┌─────────────────────────────────────────────────┐
│              Mobile Apps (Clients)              │
│  - iOS (App Store)                              │
│  - Android (Play Store)                         │
└───────────────────┬─────────────────────────────┘
                    │ HTTPS/WSS
                    ▼
┌─────────────────────────────────────────────────┐
│            CDN (Cloudflare/CloudFront)          │
│  - Static assets caching                        │
│  - DDoS protection                              │
│  - Geographic distribution                      │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│           Load Balancer (if needed)             │
└───────────────────┬─────────────────────────────┘
                    │
      ┌─────────────┴─────────────┐
      ▼                           ▼
┌─────────────────┐     ┌─────────────────────────┐
│  Firebase       │     │  Supabase (Alternative) │
│  ├─ Firestore   │     │  ├─ PostgreSQL          │
│  ├─ Auth        │     │  ├─ Auth                │
│  ├─ Storage     │     │  ├─ Storage             │
│  ├─ Functions   │     │  ├─ Edge Functions      │
│  └─ FCM         │     │  └─ Realtime            │
└─────────────────┘     └─────────────────────────┘
      │                           │
      └───────────────┬───────────┘
                      ▼
          ┌───────────────────────┐
          │   External Services   │
          │  - Sentry (Errors)    │
          │  - Analytics          │
          │  - Spoonacular API    │
          └───────────────────────┘
```

---

### Cloud Infrastructure (Firebase)

**Firebase Project Structure:**

```
firebase-project/
├── firestore.rules              # Security rules
├── firestore.indexes.json       # Composite indexes
├── storage.rules                # Storage security rules
├── functions/                   # Cloud Functions
│   ├── src/
│   │   ├── index.ts            # Function exports
│   │   ├── sync/
│   │   │   ├── syncRecipes.ts
│   │   │   └── resolveConflicts.ts
│   │   ├── recipes/
│   │   │   ├── importRecipe.ts  # URL scraping
│   │   │   └── parseRecipe.ts
│   │   └── images/
│   │       └── processImage.ts   # Resize, optimize
│   ├── package.json
│   └── tsconfig.json
└── firebase.json                # Firebase configuration
```

**Firebase Security Rules:**

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function hasValidTimestamp() {
      return request.resource.data.updatedAt is timestamp;
    }

    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /recipes/{recipeId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId) && hasValidTimestamp();
        allow update: if isOwner(userId)
                      && hasValidTimestamp()
                      && request.resource.data.syncVersion > resource.data.syncVersion;
        allow delete: if isOwner(userId);
      }

      match /shopping_lists/{listId} {
        allow read, write: if isOwner(userId);
      }

      match /meal_plans/{planId} {
        allow read, write: if isOwner(userId);
      }

      match /pantry_items/{itemId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

### Supabase Infrastructure (Alternative)

**Supabase Project:**

```
supabase/
├── migrations/
│   ├── 20260101000000_initial_schema.sql
│   ├── 20260102000000_add_indexes.sql
│   └── 20260103000000_add_rls_policies.sql
├── functions/
│   ├── import-recipe/
│   │   └── index.ts
│   ├── process-image/
│   │   └── index.ts
│   └── sync-resolver/
│       └── index.ts
└── config.toml
```

**Edge Functions Example:**

```typescript
// supabase/functions/import-recipe/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { url } = await req.json();

    // Fetch recipe page
    const response = await fetch(url);
    const html = await response.text();

    // Parse using recipe schema (JSON-LD or microdata)
    const recipe = parseRecipeFromHTML(html);

    return new Response(JSON.stringify({ recipe }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});

function parseRecipeFromHTML(html: string): Recipe {
  // Extract JSON-LD schema
  const jsonLdMatch = html.match(
    /<script type="application\/ld\+json">(.*?)<\/script>/s,
  );
  if (jsonLdMatch) {
    const data = JSON.parse(jsonLdMatch[1]);
    if (data["@type"] === "Recipe") {
      return {
        title: data.name,
        description: data.description,
        ingredients: data.recipeIngredient,
        instructions: data.recipeInstructions.map((step) => step.text),
        prepTime: parseDuration(data.prepTime),
        cookTime: parseDuration(data.cookTime),
        servings: data.recipeYield,
        imageUrl: data.image,
      };
    }
  }

  // Fallback to manual parsing
  throw new Error("Could not parse recipe");
}
```

---

## Security Architecture

### Authentication Flow

```
┌──────────────┐
│  User Opens  │
│     App      │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ Check Local Auth │  ← Secure Storage (Keychain/Keystore)
│   Token Exists?  │
└──────┬───────────┘
       │
   ┌───┴───┐
   │  No   │  Yes
   ▼       ▼
┌─────┐  ┌──────────────┐
│Local│  │Validate Token│
│Mode │  │   (JWT)      │
└─────┘  └──────┬───────┘
              │
          ┌───┴────┐
    Expired│       │Valid
          ▼         ▼
    ┌───────────┐ ┌──────────┐
    │ Refresh   │ │ Proceed  │
    │  Token    │ │ with App │
    └───────────┘ └──────────┘
```

**Token Management:**

```dart
class AuthService {
  final FlutterSecureStorage secureStorage;
  final FirebaseAuth firebaseAuth;

  Future<AuthState> checkAuthState() async {
    // Check if user previously opted for cloud sync
    final hasToken = await secureStorage.read(key: 'auth_token');

    if (hasToken == null) {
      return AuthState.localOnly();
    }

    // Validate token
    final user = firebaseAuth.currentUser;
    if (user != null) {
      // Refresh token if needed
      final idToken = await user.getIdToken(forceRefresh: false);
      await secureStorage.write(key: 'auth_token', value: idToken);
      return AuthState.authenticated(user);
    }

    return AuthState.expired();
  }

  Future<void> signInWithEmail(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final token = await credential.user!.getIdToken();
    await secureStorage.write(key: 'auth_token', value: token);
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await secureStorage.delete(key: 'auth_token');
  }
}
```

---

### Data Encryption

**Local Data Encryption:**

```dart
// Encrypt sensitive fields with Drift
import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart';

class EncryptedDriftConverter extends TypeConverter<String, String> {
  final Encrypter encrypter;
  final IV iv;

  EncryptedDriftConverter(String encryptionKey)
      : encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey))),
        iv = IV.fromLength(16);

  @override
  String fromSql(String fromDb) {
    return encrypter.decrypt64(fromDb, iv: iv);
  }

  @override
  String toSql(String value) {
    return encrypter.encrypt(value, iv: iv).base64;
  }
}

// Usage in table definition
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get encryptedApiKey => text().map(EncryptedDriftConverter('your-key'))();

  @override
  Set<Column> get primaryKey => {id};
}
  }
}

// Generate encryption key from device ID + user PIN
Future<String> generateEncryptionKey() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  final deviceId = deviceInfo.id; // or use flutter_secure_storage

  // Derive key using PBKDF2
  final generator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  generator.init(Pbkdf2Parameters(
    utf8.encode(deviceId),
    1000, // iterations
    256, // key length
  ));

  final key = generator.process(utf8.encode('app_secret'));
  return base64.encode(key);
}
```

**Network Security:**

```dart
// Certificate pinning for API calls
class SecureHttpClient {
  late final HttpClient _client;

  SecureHttpClient() {
    _client = HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        // Pin certificates
        return _verifyCertificate(cert, host);
      };
  }

  bool _verifyCertificate(X509Certificate cert, String host) {
    // Check against pinned certificates
    const pinnedFingerprints = [
      'EXPECTED_CERTIFICATE_FINGERPRINT_1',
      'EXPECTED_CERTIFICATE_FINGERPRINT_2',
    ];

    final certFingerprint = _getFingerprint(cert);
    return pinnedFingerprints.contains(certFingerprint);
  }

  String _getFingerprint(X509Certificate cert) {
    return sha256.convert(cert.der).toString();
  }
}
```

---

### Privacy & GDPR Compliance

```dart
class PrivacyManager {
  final LocalDatabase database;
  final RemoteDataSource remoteDataSource;

  // Right to Access
  Future<Map<String, dynamic>> exportUserData() async {
    return {
      'recipes': await database.getAllRecipes(),
      'shopping_lists': await database.getAllShoppingLists(),
      'meal_plans': await database.getAllMealPlans(),
      'pantry_items': await database.getAllPantryItems(),
      'preferences': await database.getUserPreferences(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // Right to Deletion
  Future<void> deleteAllUserData() async {
    // Delete from cloud
    await remoteDataSource.deleteAccount();

    // Delete local data
    await database.clearAll();

    // Clear secure storage
    await FlutterSecureStorage().deleteAll();

    // Clear shared preferences
    await SharedPreferences.getInstance().clear();
  }

  // Selective Sync Controls
  Future<void> updateSyncPreferences(SyncPreferences prefs) async {
    await database.saveSyncPreferences(prefs);

    // Disable syncing for specific data types
    if (!prefs.syncRecipes) {
      await _stopSyncingRecipes();
    }
    if (!prefs.syncPantry) {
      await _stopSyncingPantry();
    }
  }
}
```

---

## API Design

### REST API Endpoints

**Base URL:** `https://api.shoppinglistapp.com/v1`

#### Authentication

```
POST   /auth/register          # Create account
POST   /auth/login             # Login with email/password
POST   /auth/refresh           # Refresh access token
POST   /auth/logout            # Logout
DELETE /auth/account           # Delete account
```

#### Recipes

```
GET    /recipes                # List all recipes
GET    /recipes/:id            # Get recipe details
POST   /recipes                # Create new recipe
PUT    /recipes/:id            # Update recipe
DELETE /recipes/:id            # Delete recipe (soft delete)
POST   /recipes/import         # Import from URL
GET    /recipes/search         # Search recipes
```

#### Shopping Lists

```
GET    /shopping-lists         # List all shopping lists
GET    /shopping-lists/:id     # Get list details
POST   /shopping-lists         # Create new list
PUT    /shopping-lists/:id     # Update list
DELETE /shopping-lists/:id     # Delete list
POST   /shopping-lists/:id/share  # Generate share link
```

#### Meal Plans

```
GET    /meal-plans             # List meal plans
GET    /meal-plans/:id         # Get meal plan
POST   /meal-plans             # Create meal plan
PUT    /meal-plans/:id         # Update meal plan
DELETE /meal-plans/:id         # Delete meal plan
POST   /meal-plans/:id/generate-shopping-list  # Generate list
```

#### Pantry

```
GET    /pantry                 # List pantry items
GET    /pantry/:id             # Get item details
POST   /pantry                 # Add item
PUT    /pantry/:id             # Update item
DELETE /pantry/:id             # Remove item
GET    /pantry/expiring        # Get expiring items
```

#### Sync

```
GET    /sync/:entity?since=timestamp     # Get updates
POST   /sync/:entity                     # Push changes
POST   /sync/resolve-conflict            # Manual conflict resolution
```

---

### API Request/Response Examples

**Create Recipe:**

```http
POST /recipes
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Chicken Pad Thai",
  "description": "Authentic Thai stir-fried noodles",
  "servings": 4,
  "prepTimeMinutes": 20,
  "cookTimeMinutes": 15,
  "ingredients": [
    {
      "quantity": 8,
      "unit": "oz",
      "name": "rice noodles"
    },
    {
      "quantity": 2,
      "unit": "whole",
      "name": "chicken breasts",
      "notes": "diced"
    }
  ],
  "instructions": [
    "Soak rice noodles in warm water for 20 minutes",
    "Heat wok over high heat..."
  ],
  "tags": ["thai", "noodles", "weeknight"]
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Chicken Pad Thai",
    "servings": 4,
    "createdAt": "2026-02-25T10:00:00Z",
    "updatedAt": "2026-02-25T10:00:00Z",
    "syncVersion": 1
  }
}
```

**Sync Request:**

```http
GET /sync/recipes?since=1708851600000
Authorization: Bearer {token}
```

**Sync Response:**

```json
{
  "success": true,
  "data": {
    "updates": [
      {
        "id": "recipe-123",
        "operation": "update",
        "data": {
          /* full recipe object */
        },
        "syncVersion": 5,
        "updatedAt": "2026-02-25T12:00:00Z"
      }
    ],
    "deletions": [
      {
        "id": "recipe-456",
        "deletedAt": "2026-02-25T11:00:00Z"
      }
    ],
    "conflicts": [
      {
        "id": "recipe-789",
        "localVersion": 3,
        "remoteVersion": 4,
        "local": {
          /* local data */
        },
        "remote": {
          /* remote data */
        }
      }
    ],
    "nextSync": 1708855200000
  }
}
```

---

## Performance Architecture

### Performance Optimization Strategies

#### 1. Lazy Loading

```dart
// Lazy load recipe images
class RecipeImageLoader {
  final Map<String, Image> _cache = {};

  Widget loadRecipeImage(String url, {bool thumbnail = false}) {
    return FutureBuilder<File>(
      future: _getCachedImage(url, thumbnail),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.file(snapshot.data!);
        }
        return ShimmerPlaceholder();
      },
    );
  }

  Future<File> _getCachedImage(String url, bool thumbnail) async {
    final cacheManager = DefaultCacheManager();
    final file = await cacheManager.getSingleFile(
      url,
      headers: thumbnail ? {'size': 'thumbnail'} : {},
    );
    return file;
  }
}
```

#### 2. Pagination

```dart
class PaginatedRecipeList extends ConsumerStatefulWidget {
  @override
  _PaginatedRecipeListState createState() => _PaginatedRecipeListState();
}

class _PaginatedRecipeListState extends ConsumerState<PaginatedRecipeList> {
  final scrollController = ScrollController();
  int page = 0;
  static const pageSize = 20;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    _loadMore();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    await ref.read(recipesProvider.notifier).loadPage(page, pageSize);
    page++;
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);

    return ListView.builder(
      controller: scrollController,
      itemCount: recipes.length + 1,
      itemBuilder: (context, index) {
        if (index == recipes.length) {
          return LoadingIndicator();
        }
        return RecipeCard(recipe: recipes[index]);
      },
    );
  }
}
```

#### 3. Database Query Optimization

```dart
// Use indexes for fast queries
class OptimizedRecipeQueries {
  final AppDatabase database;

  // Fast search with indexes using Drift
  Future<List<Recipe>> searchRecipes(String query) async {
    // Drift: Use SQL LIKE and indexed columns
    return (database.select(database.recipes)
      ..where((r) => r.title.like('%$query%') | r.tags.contains(query))
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)])
      ..limit(50)
    ).get();
  }

  // Optimized "What Can I Make?" query
  Future<List<RecipeMatch>> matchRecipesWithPantry() async {
    final pantryItems = await database.pantry.values.toList();
    final recipes = await database.recipes.values.toList();

    // Use isolate for heavy computation
    return compute(_computeMatches, {
      'pantry': pantryItems,
      'recipes': recipes,
    });
  }
}

// Run in separate isolate to avoid blocking UI
List<RecipeMatch> _computeMatches(Map<String, dynamic> data) {
  final pantry = data['pantry'] as List<PantryItem>;
  final recipes = data['recipes'] as List<Recipe>;

  return recipes.map((recipe) {
    final matchPercentage = _calculateMatch(recipe, pantry);
    return RecipeMatch(recipe, matchPercentage);
  }).where((m) => m.percentage >= 60).toList()
    ..sort((a, b) => b.percentage.compareTo(a.percentage));
}
```

#### 4. Image Optimization

```dart
class ImageOptimizationService {
  // Compress before upload
  Future<File> optimizeForUpload(File image) async {
    final bytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    // Resize to max dimensions
    final resized = img.copyResize(
      decodedImage!,
      width: 1200,
      height: 1200,
      maintainAspect: true,
    );

    // Compress to JPEG 85% quality
    final compressed = img.encodeJpg(resized, quality: 85);

    final optimizedFile = File('${image.path}_optimized.jpg');
    await optimizedFile.writeAsBytes(compressed);

    return optimizedFile;
  }

  // Generate thumbnail
  Future<File> generateThumbnail(File image) async {
    final bytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    final thumbnail = img.copyResize(
      decodedImage!,
      width: 300,
      height: 300,
      maintainAspect: true,
    );

    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

    final thumbnailFile = File('${image.path}_thumb.jpg');
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    return thumbnailFile;
  }
}
```

---

### Performance Monitoring

```dart
// Custom performance tracker
class PerformanceTracker {
  static final _instance = PerformanceTracker._();
  factory PerformanceTracker() => _instance;
  PerformanceTracker._();

  final Map<String, DateTime> _startTimes = {};

  void startTrace(String traceName) {
    _startTimes[traceName] = DateTime.now();
  }

  void stopTrace(String traceName) {
    final startTime = _startTimes.remove(traceName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logPerformance(traceName, duration);
    }
  }

  void _logPerformance(String traceName, Duration duration) {
    // Log to analytics
    FirebasePerformance.instance.newTrace(traceName)
      ..start()
      ..setMetric('duration_ms', duration.inMilliseconds)
      ..stop();

    // Log slow operations in debug mode
    if (kDebugMode && duration.inMilliseconds > 1000) {
      print('⚠️ Slow operation: $traceName took ${duration.inMilliseconds}ms');
    }
  }
}

// Usage
Future<List<Recipe>> getAllRecipes() async {
  PerformanceTracker().startTrace('load_recipes');
  try {
    final recipes = await _repository.getAllRecipes();
    return recipes;
  } finally {
    PerformanceTracker().stopTrace('load_recipes');
  }
}
```

---

## Testing Strategy

### Test Pyramid

```
           /\
          /  \          ← E2E Tests (5-10%)
         /────\           Integration with real services
        /      \
       /  Unit  \       ← Integration Tests (20-30%)
      /  Tests  \        Multiple components together
     /──────────\
    /            \     ← Unit Tests (60-70%)
   /  Widget Tests\      Individual components
  /────────────────\
```

### Unit Tests

```dart
// test/features/recipes/domain/usecases/add_shopping_list_item_test.dart
void main() {
  late AddShoppingListItemUseCase useCase;
  late MockShoppingListRepository mockRepository;

  setUp(() {
    mockRepository = MockShoppingListRepository();
    useCase = AddShoppingListItemUseCase(mockRepository);
  });

  group('AddShoppingListItemUseCase', () {
    test('should add item to shopping list successfully', () async {
      // Arrange
      const listId = 'list-123';
      const itemName = 'Milk';
      final expectedList = ShoppingList(/* with new item */);

      when(mockRepository.addItemToList(any, any))
          .thenAnswer((_) async => Success(expectedList));

      // Act
      final result = await useCase(
        listId: listId,
        itemName: itemName,
      );

      // Assert
      expect(result, isA<Success<ShoppingList>>());
      verify(mockRepository.addItemToList(listId, any)).called(1);
    });

    test('should return failure when item name is empty', () async {
      // Act
      final result = await useCase(
        listId: 'list-123',
        itemName: '',
      );

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).message, contains('empty'));
      verifyNever(mockRepository.addItemToList(any, any));
    });
  });
}
```

### Widget Tests

```dart
// test/features/shopping/presentation/widgets/shopping_item_tile_test.dart
void main() {
  testWidgets('ShoppingItemTile displays item details', (tester) async {
    // Arrange
    final item = ShoppingItem(
      id: '1',
      name: 'Milk',
      quantity: 1,
      unit: 'gallon',
      isPurchased: false,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemTile(item: item),
        ),
      ),
    );

    // Assert
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('1 gallon'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);
  });

  testWidgets('tapping checkbox toggles item state', (tester) async {
    // Arrange
    bool itemToggled = false;
    final item = ShoppingItem(/* ... */);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemTile(
            item: item,
            onToggle: () => itemToggled = true,
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Assert
    expect(itemToggled, true);
  });
}
```

### Integration Tests

```dart
// integration_test/shopping_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Shopping Flow Integration Test', () {
    testWidgets('complete shopping flow from meal plan to purchase', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 2. Navigate to meal planning
      await tester.tap(find.text('Meals'));
      await tester.pumpAndSettle();

      // 3. Add recipe to Monday dinner
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chicken Pad Thai'));
      await tester.pumpAndSettle();

      // 4. Generate shopping list
      await tester.tap(find.text('Generate Shopping List'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 5. Verify list was created
      expect(find.text('This Week\'s Meals'), findsOneWidget);
      expect(find.text('rice noodles'), findsOneWidget);

      // 6. Mark items as purchased
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // 7. Verify item is checked
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(checkbox.value, true);
    });
  });
}
```

---

## Deployment Architecture

### CI/CD Pipeline

**GitHub Actions Workflow:**

```yaml
# .github/workflows/main.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"
          channel: "stable"

      - name: Get dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build-ios:
    needs: analyze-and-test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Build iOS
        run: |
          flutter build ios --release --no-codesign

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: "build/ios/ipa/app.ipa"
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}

  build-android:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Build Android APK
        run: flutter build appbundle --release

      - name: Sign APK
        uses: r0adkll/sign-android-release@v1
        with:
          releaseDirectory: build/app/outputs/bundle/release
          signingKeyBase64: ${{ secrets.ANDROID_SIGNING_KEY }}
          alias: ${{ secrets.ANDROID_KEY_ALIAS }}
          keyStorePassword: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword: ${{ secrets.ANDROID_KEY_PASSWORD }}

      - name: Upload to Play Store (Internal Testing)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.shoppinglistapp
          releaseFiles: build/app/outputs/bundle/release/*.aab
          track: internal
```

---

### Deployment Stages

```
┌─────────────────────────────────────────────────┐
│         Stage 1: Development                    │
│  - Feature branches                             │
│  - Local testing                                │
│  - Unit tests on commit                         │
└────────────────┬────────────────────────────────┘
                 │ Pull Request
                 ▼
┌─────────────────────────────────────────────────┐
│         Stage 2: Code Review                    │
│  - Automated tests run                          │
│  - Code analysis                                │
│  - Peer review required                         │
└────────────────┬────────────────────────────────┘
                 │ Merge to develop
                 ▼
┌─────────────────────────────────────────────────┐
│         Stage 3: Internal Testing (Alpha)       │
│  - Auto-deploy to internal testers              │
│  - Firebase App Distribution                    │
│  - QA team testing                              │
└────────────────┬────────────────────────────────┘
                 │ Approval
                 ▼
┌─────────────────────────────────────────────────┐
│         Stage 4: Beta Testing                   │
│  - TestFlight (iOS)                             │
│  - Play Store Internal Testing (Android)        │
│  - 50-100 beta users                            │
│  - Crash monitoring                             │
└────────────────┬────────────────────────────────┘
                 │ Stable for 1 week
                 ▼
┌─────────────────────────────────────────────────┐
│         Stage 5: Production Release             │
│  - App Store (iOS)                              │
│  - Play Store (Android)                         │
│  - Phased rollout (10% → 50% → 100%)          │
│  - Monitor metrics closely                      │
└─────────────────────────────────────────────────┘
```

---

## Monitoring & Observability

### Error Tracking

```dart
// Initialize Sentry
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 0.1; // 10% of transactions
      options.beforeSend = (event, {hint}) {
        // Don't send errors during development
        if (kDebugMode) return null;

        // Filter sensitive data
        event = _filterSensitiveData(event);
        return event;
      };
    },
    appRunner: () => runApp(MyApp()),
  );
}

// Capture errors
Future<void> dangerousOperation() async {
  try {
    await riskyCode();
  } catch (e, stack) {
    await Sentry.captureException(
      e,
      stackTrace: stack,
      withScope: (scope) {
        scope.setTag('operation', 'risky_code');
        scope.setUser(SentryUser(id: currentUserId));
        scope.setContexts('additional_info', {
          'recipe_count': recipeCount,
          'network_status': isOnline ? 'online' : 'offline',
        });
      },
    );
    rethrow;
  }
}
```

---

### Analytics

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Track screen views
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track user actions
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Custom events
  Future<void> logRecipeViewed(String recipeId, String recipeTitle) async {
    await logEvent('recipe_viewed', {
      'recipe_id': recipeId,
      'recipe_title': recipeTitle,
    });
  }

  Future<void> logShoppingListCompleted(
    String listId,
    int itemCount,
    Duration timeSpent,
  ) async {
    await logEvent('shopping_list_completed', {
      'list_id': listId,
      'item_count': itemCount,
      'time_spent_seconds': timeSpent.inSeconds,
    });
  }

  Future<void> logMealPlanned(String recipeId, String mealSlot) async {
    await logEvent('meal_planned', {
      'recipe_id': recipeId,
      'meal_slot': mealSlot,
    });
  }
}
```

---

### Performance Monitoring

```dart
// Monitor app performance
class PerformanceMonitoring {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  Future<void> monitorRecipeLoad() async {
    final trace = await _performance.newTrace('load_recipes');
    await trace.start();

    try {
      final recipes = await _recipeRepository.getAllRecipes();
      trace.setMetric('recipe_count', recipes.length);
      await trace.stop();
    } catch (e) {
      trace.setMetric('failed', 1);
      await trace.stop();
      rethrow;
    }
  }

  // Monitor HTTP requests automatically
  void setupHttpMetrics() {
    final httpClient = FirebasePerformance.instance.httpClient;
    // All HTTP requests will be tracked automatically
  }
}
```

---

## Appendix

### Technology Stack Summary

| Layer                  | Technology         | Version  | Purpose                     |
| ---------------------- | ------------------ | -------- | --------------------------- |
| **Frontend**           | Flutter            | 3.16+    | Mobile app framework        |
| **Language**           | Dart               | 3.2+     | Programming language        |
| **State Management**   | Riverpod           | 2.x      | UI state management         |
| **Local DB**           | Drift (SQLite)     | 2.x      | Type-safe SQL storage       |
| **Backend (Option A)** | Firebase           | Latest   | Cloud services (Post-MVP)   |
| **Backend (Option B)** | Supabase           | Latest   | Open source alternative     |
| **Auth**               | Firebase Auth      | Latest   | Authentication (Post-MVP)   |
| **Storage**            | Cloud Storage      | Latest   | Image storage (Post-MVP)    |
| **Functions**          | Cloud Functions    | Node 18  | Serverless logic (Post-MVP) |
| **Push Notifications** | FCM                | Latest   | Push messaging (Post-MVP)   |
| **Analytics**          | Firebase Analytics | Latest   | User analytics (Post-MVP)   |
| **Crash Reporting**    | Sentry             | Latest   | Error tracking              |
| **Testing**            | Flutter Test       | Built-in | Unit & widget tests         |
| **CI/CD**              | GitHub Actions     | Latest   | Automation                  |

---

### Development Timeline

| Phase                    | Duration     | Deliverables                                     |
| ------------------------ | ------------ | ------------------------------------------------ |
| **Setup & Foundation**   | 2 weeks      | Project structure, CI/CD, core architecture      |
| **MVP Development**      | 12 weeks     | Core features (shopping, recipes, meal planning) |
| **Testing & QA**         | 2 weeks      | Bug fixes, performance optimization              |
| **Beta Release**         | 2 weeks      | Beta testing, feedback iteration                 |
| **Polish & Launch Prep** | 2 weeks      | Final touches, app store assets                  |
| **Total MVP**            | **20 weeks** | Public launch                                    |

---

### Open Questions

1. **Backend Choice (Post-MVP):** Firebase (faster setup) vs. Supabase (more control)?
2. **ML Integration:** On-device ML Kit or cloud-based?
3. **Recipe Import:** Build scraper or use Spoonacular API?
4. **Monetization:** When to introduce premium features?
5. **Cloud Sync Strategy:** Real-time vs. periodic sync for multi-device access?

---

### References

- [Flutter Architecture Guidelines](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Offline-First Architecture](https://offlinefirst.org/)

---

**Document End**

---

## Change Log

| Version | Date       | Changes                            | Author           |
| ------- | ---------- | ---------------------------------- | ---------------- |
| 1.0     | 2026-02-25 | Initial architecture specification | Engineering Team |

---

**Approval Required:**

- [ ] Tech Lead
- [ ] Senior Engineer
- [ ] DevOps Lead
- [ ] Product Manager
