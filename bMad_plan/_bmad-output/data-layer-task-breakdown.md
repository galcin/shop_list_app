# Data Layer Technical Task Breakdown

## Flutter Shopping List & Meal Planning App

**Document Version:** 1.0  
**Date:** February 26, 2026  
**Author:** BMad Master  
**Status:** Development Ready  
**Related Documents:** [Revised Epics](revised-epics-database-first.md), [Architecture](architecture-shopping-list-app.md)

---

## Document Purpose

This document provides **step-by-step technical implementation tasks** for building the data layer (Phase 1) of the app. Each task is granular enough to be assigned, estimated, and tracked independently.

### How to Use This Document

1. **Sequential Execution:** Tasks are ordered by dependency (must complete Task 1 before Task 2, etc.)
2. **Estimation:** Each task includes time estimate (hours) for developer reference
3. **Acceptance Criteria:** Clear checklist to mark task complete
4. **Code Examples:** Starter templates for key components
5. **Testing Requirements:** Unit test expectations per task

---

## Table of Contents

1. [Phase 0: Foundation Tasks](#phase-0-foundation-tasks)
2. [Recipe Data Layer Tasks](#recipe-data-layer-tasks)
3. [Shopping List Data Layer Tasks](#shopping-list-data-layer-tasks)
4. [Meal Plan Data Layer Tasks](#meal-plan-data-layer-tasks)
5. [Pantry Data Layer Tasks](#pantry-data-layer-tasks)
6. [Sync Engine Data Layer Tasks](#sync-engine-data-layer-tasks)
7. [Integration & Testing Tasks](#integration--testing-tasks)

---

## Phase 0: Foundation Tasks

### Task F-001: Initialize Flutter Project with Clean Architecture

**Epic:** E0 - Foundation  
**Story:** US-E0.1  
**Estimate:** 2 hours  
**Priority:** P0 (Blocking)  
**Assignee:** TBD

**Steps:**

1. Create new Flutter project:

   ```bash
   flutter create shop_list_app
   cd shop_list_app
   ```

2. Configure `pubspec.yaml` with initial dependencies:

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
     connectivity_plus: ^5.0.2
     uuid: ^4.0.0

   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^3.0.0
     build_runner: ^2.4.6
     drift_dev: ^2.14.0
     mockito: ^5.4.2
   ```

3. Create folder structure:

   ```bash
   mkdir -p lib/core/{constants,error,network,utils,theme,providers}
   mkdir -p lib/features/{shopping,recipes,meal_planning,pantry,sync}/{domain,data,presentation}
   mkdir -p lib/features/{shopping,recipes,meal_planning,pantry,sync}/domain/{entities,repositories,usecases}
   mkdir -p lib/features/{shopping,recipes,meal_planning,pantry,sync}/data/{models,datasources,repositories}
   mkdir -p lib/features/{shopping,recipes,meal_planning,pantry,sync}/presentation/{providers,pages,widgets}
   mkdir -p lib/shared/widgets
   mkdir -p test/helpers
   ```

4. Configure linting (`analysis_options.yaml`):

   ```yaml
   include: package:flutter_lints/flutter.yaml

   linter:
     rules:
       prefer_const_constructors: true
       prefer_const_literals_to_create_immutables: true
       avoid_print: true
       prefer_single_quotes: true
       always_declare_return_types: true

   analyzer:
     exclude:
       - "**/*.g.dart"
       - "**/*.freezed.dart"
   ```

5. Create `.gitignore` additions:

   ```
   # App-specific
   *.sqlite
   *.sqlite-shm
   *.sqlite-wal

   # Generated files
   *.g.dart
   *.freezed.dart
   ```

6. Update `README.md` with architecture overview

**Acceptance Criteria:**

- [ ] Project builds without errors: `flutter run`
- [ ] Linter runs clean: `flutter analyze`
- [ ] All folders created as specified
- [ ] Dependencies resolve: `flutter pub get`
- [ ] Git repository initialized with initial commit

**Testing:**

- Manual: Run `flutter doctor` - all checks pass
- Automated: N/A (setup task)

---

### Task F-002: Implement Core Error Handling

**Epic:** E0  
**Story:** US-E0.2  
**Estimate:** 3 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `lib/core/error/failures.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}
```

2. Create `lib/core/error/exceptions.dart`:

```dart
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error']);

  @override
  String toString() => 'NetworkException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
```

3. Create `lib/core/utils/result.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';

typedef Result<T> = Either<Failure, T>;

// Helper extensions
extension ResultExtension<T> on Result<T> {
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return this.fold(onFailure, onSuccess);
  }

  T? getOrNull() {
    return fold(
      (failure) => null,
      (success) => success,
    );
  }

  Failure? getFailureOrNull() {
    return fold(
      (failure) => failure,
      (success) => null,
    );
  }
}
```

4. Create test file `test/core/error/failures_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure should extend Failure', () {
      expect(const ServerFailure(), isA<Failure>());
    });

    test('ServerFailure should have custom message', () {
      const failure = ServerFailure('Custom error');
      expect(failure.message, 'Custom error');
    });

    test('Failures with same message should be equal', () {
      const failure1 = ServerFailure('Error');
      const failure2 = ServerFailure('Error');
      expect(failure1, failure2);
    });
  });
}
```

**Acceptance Criteria:**

- [ ] All failure classes created
- [ ] All exception classes created
- [ ] Result type defined
- [ ] Unit tests pass (`flutter test test/core/error/`)
- [ ] No analyzer warnings

**Testing:**

- Unit tests: 90%+ coverage for failure types
- Test equality and message propagation

---

### Task F-003: Setup Drift Database

**Epic:** E0  
**Story:** US-E0.3  
**Estimate:** 4 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `lib/core/database/app_database.dart`:

```dart
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
```

2. Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Drift database initializes lazily via provider

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

3. Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List & Meal Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Shopping List App - Foundation Ready'),
        ),
      ),
    );
  }
}
```

4. Create test helper `test/helpers/database_test_helper.dart`:

```dart
import 'package:drift/native.dart';
import 'package:shop_list_app/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  // Create in-memory database for testing
  return AppDatabase.test(NativeDatabase.memory());
}

extension AppDatabaseTest on AppDatabase {
  static AppDatabase test(QueryExecutor executor) {
    return AppDatabase._test(executor);
  }

  AppDatabase._test(QueryExecutor executor) : super._internal(executor);
}

// Add to AppDatabase class:
extension AppDatabaseTestConstructor on AppDatabase {
  AppDatabase._internal(QueryExecutor executor) : super.connect(executor);
}
import 'package:hive_flutter/hive_flutter.dart';

class HiveTestHelper {
  static Future<void> setupTestHive() async {
    await Hive.initFlutter();
  }

  static Future<void> teardownTestHive() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  }

  static Future<Box<T>> createMockBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }
}
```

**Acceptance Criteria:**

- [ ] Hive initializes successfully
- [ ] App runs without errors
- [ ] HiveSetup class created with box constants
- [ ] Test helper created
- [ ] Documentation added for adding new models

**Testing:**

- Manual: App launches with "Foundation Ready" message
- Unit: Test helper can open/close test boxes

---

### Task F-004: Implement Network Connectivity Detection

**Epic:** E0  
**Story:** US-E0.4  
**Estimate:** 2 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `lib/core/network/network_info.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

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
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(_isConnectedResult);
  }

  bool _isConnectedResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
}
```

2. Create provider `lib/core/providers/core_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shop_list_app/core/network/network_info.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

// Stream provider for real-time connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
```

3. Create test file `test/core/network/network_info_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shop_list_app/core/network/network_info.dart';

@GenerateMocks([Connectivity])
import 'network_info_test.mocks.dart';

void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test('should return true when connected to wifi', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, true);
    });

    test('should return false when not connected', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, false);
    });
  });
}
```

4. Run code generation for mocks:
   ```bash
   flutter pub run build_runner build
   ```

**Acceptance Criteria:**

- [ ] NetworkInfo interface defined
- [ ] Implementation created
- [ ] Providers configured
- [ ] Unit tests pass with >80% coverage
- [ ] Mocks generated successfully

**Testing:**

- Mock Connectivity for unit tests
- Test all ConnectivityResult states

---

### Task F-005: Create Design System (Theme)

**Epic:** E0  
**Story:** US-E0.5  
**Estimate:** 5 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF2E7D32);      // Green 800
  static const Color primaryLight = Color(0xFF4CAF50); // Green 500
  static const Color primaryDark = Color(0xFF1B5E20);  // Green 900

  static const Color secondary = Color(0xFFFF6F00);      // Orange 900
  static const Color secondaryLight = Color(0xFFFF9800); // Orange 500

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Expiration states
  static const Color fresh = Color(0xFF4CAF50);
  static const Color useSoon = Color(0xFFFFC107);
  static const Color urgent = Color(0xFFF44336);
  static const Color neutral = Color(0xFF9E9E9E);

  // Surface colors (Light)
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);

  // Surface colors (Dark)
  static const Color surfaceDark = Color(0xFF121212);
  static const Color backgroundDark = Color(0xFF000000);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
}
```

2. Create `lib/core/theme/app_spacing.dart`:

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppSizes {
  static const double minTouchTarget = 48.0;
  static const double comfortableTap = 56.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 999.0;
}

class AppElevation {
  static const double level0 = 0;
  static const double level1 = 2;
  static const double level2 = 4;
  static const double level3 = 8;
  static const double level4 = 12;
  static const double level5 = 16;
}
```

3. Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
      ),

      cardTheme: CardTheme(
        elevation: AppElevation.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppElevation.level2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.circular),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
      ),

      cardTheme: CardTheme(
        elevation: AppElevation.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }
}
```

4. Update `lib/app.dart` to use theme:

```dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List & Meal Planner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Placeholder(), // Will be replaced with navigation
    );
  }
}
```

**Acceptance Criteria:**

- [ ] All color constants defined
- [ ] Spacing and size constants created
- [ ] Light and dark themes configured
- [ ] App switches theme based on system setting
- [ ] No hardcoded colors in widgets (use theme)

**Testing:**

- Manual: Toggle device dark mode, verify theme switches
- Visual: Compare colors to design spec

---

### Task F-006: Setup Testing Infrastructure

**Epic:** E0  
**Story:** US-E0.6  
**Estimate:** 4 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `test/helpers/test_helpers.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class TestHelpers {
  /// Setup test environment
  static Future<void> setupTests() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _setupHiveForTests();
  }

  /// Teardown test environment
  static Future<void> teardownTests() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  }

  static Future<void> _setupHiveForTests() async {
    await Hive.initFlutter();
  }

  /// Create mock Hive box for testing
  static Future<Box<T>> createTestBox<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e) {
      // Box might already be open
      return Hive.box<T>(name);
    }
  }

  /// Clear all test boxes
  static Future<void> clearAllBoxes() async {
    for (var box in Hive.box.values) {
      await box.clear();
    }
  }
}
```

2. Create `test/helpers/mock_factories.dart`:

```dart
// Will be populated as models are created
// Example:
// class MockRecipeFactory {
//   static Recipe createTestRecipe({String? id}) {
//     return Recipe(
//       id: RecipeId(id ?? 'test-recipe-1'),
//       title: 'Test Recipe',
//       // ... other fields
//     );
//   }
// }
```

3. Create test configuration `test/test_config.dart`:

```dart
const String testDatabasePath = 'test/test_data/';
const Duration testTimeout = Duration(seconds: 5);
```

4. Update `.vscode/settings.json` (if using VS Code):

```json
{
  "dart.flutterTestAdditionalArgs": ["--coverage"]
}
```

5. Create script to run tests with coverage `scripts/test_with_coverage.sh`:

```bash
#!/bin/bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

6. Make script executable:
   ```bash
   chmod +x scripts/test_with_coverage.sh
   ```

**Acceptance Criteria:**

- [ ] Test helpers created
- [ ] Mock factories structure ready
- [ ] Test configuration defined
- [ ] Coverage script working
- [ ] Sample test runs successfully

**Testing:**

- Run `flutter test` - should pass
- Run coverage script - generates report

---

## Recipe Data Layer Tasks

### Task R-001: Create Recipe Domain Entity

**Epic:** E1 - Recipe Data Layer  
**Story:** US-E1.1  
**Estimate:** 3 hours  
**Priority:** P0  
**Assignee:** TBD

**Steps:**

1. Create `lib/features/recipes/domain/entities/recipe_id.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class RecipeId extends Equatable {
  final String value;

  const RecipeId(this.value);

  factory RecipeId.generate() {
    return RecipeId(const Uuid().v4());
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => value;
}
```

2. Create `lib/features/recipes/domain/entities/ingredient.dart`:

```dart
import 'package:equatable/equatable.dart';

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

  // Validation
  bool get isValid => name.isNotEmpty;

  // Display formatting
  String get displayText {
    final buffer = StringBuffer();
    if (quantity != null) {
      buffer.write('${_formatQuantity(quantity!)} ');
    }
    if (unit != null) {
      buffer.write('$unit ');
    }
    buffer.write(name);
    if (notes != null && notes!.isNotEmpty) {
      buffer.write(' ($notes)');
    }
    return buffer.toString();
  }

  String _formatQuantity(double quantity) {
    // Handle common fractions
    if (quantity == 0.25) return '1/4';
    if (quantity == 0.33) return '1/3';
    if (quantity == 0.5) return '1/2';
    if (quantity == 0.66) return '2/3';
    if (quantity == 0.75) return '3/4';

    // Handle whole numbers
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }

    // Otherwise show decimal
    return quantity.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [name, quantity, unit, notes];
}
```

3. Create `lib/features/recipes/domain/entities/instruction.dart`:

```dart
import 'package:equatable/equatable.dart';

class Instruction extends Equatable {
  final String text;
  final int stepNumber;

  const Instruction(this.text, {this.stepNumber = 0});

  bool get isValid => text.isNotEmpty;

  @override
  List<Object> get props => [text, stepNumber];
}
```

4. Create `lib/features/recipes/domain/entities/recipe.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe_id.dart';
import 'package:shop_list_app/features/recipes/domain/entities/ingredient.dart';
import 'package:shop_list_app/features/recipes/domain/entities/instruction.dart';

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
  final double? rating;

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
    this.rating,
  });

  // Validation
  bool get isValid {
    return title.isNotEmpty &&
           ingredients.isNotEmpty &&
           instructions.isNotEmpty &&
           servings > 0;
  }

  // Computed properties
  Duration? get totalTime {
    if (prepTime == null && cookTime == null) return null;
    return Duration(
      minutes: (prepTime?.inMinutes ?? 0) + (cookTime?.inMinutes ?? 0),
    );
  }

  bool get hasPhotos => photoUrls.isNotEmpty;

  // Copy with method
  Recipe copyWith({
    RecipeId? id,
    String? title,
    String? description,
    List<Ingredient>? ingredients,
    List<Instruction>? instructions,
    int? servings,
    Duration? prepTime,
    Duration? cookTime,
    List<String>? tags,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    double? rating,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      tags: tags ?? this.tags,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    ingredients,
    instructions,
    servings,
    prepTime,
    cookTime,
    tags,
    photoUrls,
    createdAt,
    updatedAt,
    isFavorite,
    rating,
  ];
}
```

5. Create tests `test/features/recipes/domain/entities/recipe_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe_id.dart';
import 'package:shop_list_app/features/recipes/domain/entities/ingredient.dart';
import 'package:shop_list_app/features/recipes/domain/entities/instruction.dart';

void main() {
  group('Recipe Entity', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        id: const RecipeId('test-1'),
        title: 'Test Recipe',
        ingredients: const [
          Ingredient(name: 'Flour', quantity: 2, unit: 'cups'),
        ],
        instructions: const [
          Instruction('Mix ingredients'),
        ],
        servings: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('should be valid when all required fields are present', () {
      expect(testRecipe.isValid, true);
    });

    test('should calculate total time correctly', () {
      final recipe = testRecipe.copyWith(
        prepTime: const Duration(minutes: 10),
        cookTime: const Duration(minutes: 20),
      );

      expect(recipe.totalTime!.inMinutes, 30);
    });

    test('should support equality', () {
      final recipe1 = Recipe(
        id: const RecipeId('test-1'),
        title: 'Test',
        ingredients: const [],
        instructions: const [],
        servings: 2,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final recipe2 = Recipe(
        id: const RecipeId('test-1'),
        title: 'Test',
        ingredients: const [],
        instructions: const [],
        servings: 2,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(recipe1, recipe2);
    });
  });
}
```

**Acceptance Criteria:**

- [ ] RecipeId value object created
- [ ] Ingredient value object created with display formatting
- [ ] Instruction value object created
- [ ] Recipe entity created with all fields
- [ ] Validation logic implemented
- [ ] copyWith method works
- [ ] Unit tests pass with >90% coverage

**Testing:**

- Test entity creation
- Test validation rules
- Test copyWith method
- Test equality

---

### Task R-002: Create Recipe Data Model with Hive Adapter

**Epic:** E1  
**Story:** US-E1.2  
**Estimate:** 5 hours  
**Priority:** P0  
**Assignee:** TBD  
**Dependencies:** R-001

**Steps:**

1. Create `lib/features/recipes/data/models/ingredient_model.dart`:

```dart
import 'package:hive/hive.dart';
import 'package:shop_list_app/features/recipes/domain/entities/ingredient.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: 1)
class IngredientModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  double? quantity;

  @HiveField(2)
  String? unit;

  @HiveField(3)
  String? notes;

  IngredientModel({
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
  });

  // Convert to domain entity
  Ingredient toEntity() {
    return Ingredient(
      name: name,
      quantity: quantity,
      unit: unit,
      notes: notes,
    );
  }

  // Create from domain entity
  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.unit,
      notes: ingredient.notes,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] as String,
      quantity: json['quantity'] as double?,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
```

2. Create `lib/features/recipes/data/models/recipe_model.dart`:

```dart
import 'package:hive/hive.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe_id.dart';
import 'package:shop_list_app/features/recipes/domain/entities/instruction.dart';
import 'package:shop_list_app/features/recipes/data/models/ingredient_model.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3  late List<IngredientModel> ingredients;

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
  double? rating;

  @HiveField(14)
  bool isDeleted = false;

  @HiveField(15)
  int syncVersion = 0;

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
    this.rating,
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
      instructions: instructions
          .asMap()
          .entries
          .map((e) => Instruction(e.value, stepNumber: e.key + 1))
          .toList(),
      servings: servings,
      prepTime: prepTimeMinutes != null
          ? Duration(minutes: prepTimeMinutes!)
          : null,
      cookTime: cookTimeMinutes != null
          ? Duration(minutes: cookTimeMinutes!)
          : null,
      tags: tags,
      photoUrls: photoUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      rating: rating,
    );
  }

  // Create from domain entity
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id.value,
      title: recipe.title,
      description: recipe.description,
      ingredients: recipe.ingredients
          .map((i) => IngredientModel.fromEntity(i))
          .toList(),
      instructions: recipe.instructions.map((i) => i.text).toList(),
      servings: recipe.servings,
      prepTimeMinutes: recipe.prepTime?.inMinutes,
      cookTimeMinutes: recipe.cookTime?.inMinutes,
      tags: recipe.tags,
      photoUrls: recipe.photoUrls,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      isFavorite: recipe.isFavorite,
      rating: recipe.rating,
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
      'rating': rating,
      'isDeleted': isDeleted,
      'syncVersion': syncVersion,
    };
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List)
          .map((i) => IngredientModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      instructions: List<String>.from(json['instructions'] as List),
      servings: json['servings'] as int,
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: json['rating'] as double?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      syncVersion: json['syncVersion'] as int? ?? 0,
    );
  }
}
```

3. Run build_runner to generate adapters:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Update `lib/core/database/hive_setup.dart` to register adapters:

```dart
// Add imports at top
import 'package:shop_list_app/features/recipes/data/models/recipe_model.dart';
import 'package:shop_list_app/features/recipes/data/models/ingredient_model.dart';

// In initialize() method, uncomment:
Hive.registerAdapter(RecipeModelAdapter());
Hive.registerAdapter(IngredientModelAdapter());

// In initialize(), open box:
await Hive.openBox<RecipeModel>(recipesBox);
```

5. Create test `test/features/recipes/data/models/recipe_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe_id.dart';
import 'package:shop_list_app/features/recipes/domain/entities/ingredient.dart';
import 'package:shop_list_app/features/recipes/domain/entities/instruction.dart';
import 'package:shop_list_app/features/recipes/data/models/recipe_model.dart';
import 'package:shop_list_app/features/recipes/data/models/ingredient_model.dart';

void main() {
  group('RecipeModel', () {
    late Recipe testRecipe;
    late RecipeModel testRecipeModel;

    setUp(() {
      testRecipe = Recipe(
        id: const RecipeId('test-1'),
        title: 'Test Recipe',
        description: 'Test description',
        ingredients: const [
          Ingredient(name: 'Flour', quantity: 2, unit: 'cups'),
        ],
        instructions: const [
          Instruction('Step 1', stepNumber: 1),
        ],
        servings: 4,
        prepTime: const Duration(minutes: 10),
        cookTime: const Duration(minutes: 20),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      testRecipeModel = RecipeModel.fromEntity(testRecipe);
    });

    test('should convert from entity to model correctly', () {
      expect(testRecipeModel.id, testRecipe.id.value);
      expect(testRecipeModel.title, testRecipe.title);
      expect(testRecipeModel.servings, testRecipe.servings);
      expect(testRecipeModel.prepTimeMinutes, 10);
      expect(testRecipeModel.cookTimeMinutes, 20);
    });

    test('should convert from model to entity correctly', () {
      final entity = testRecipeModel.toEntity();

      expect(entity.id.value, testRecipe.id.value);
      expect(entity.title, testRecipe.title);
      expect(entity.servings, testRecipe.servings);
      expect(entity.prepTime!.inMinutes, 10);
    });

    test('should serialize to JSON correctly', () {
      final json = testRecipeModel.toJson();

      expect(json['id'], testRecipeModel.id);
      expect(json['title'], testRecipeModel.title);
      expect(json['servings'], testRecipeModel.servings);
    });

    test('should deserialize from JSON correctly', () {
      final json = testRecipeModel.toJson();
      final fromJson = RecipeModel.fromJson(json);

      expect(fromJson.id, testRecipeModel.id);
      expect(fromJson.title, testRecipeModel.title);
      expect(fromJson.servings, testRecipeModel.servings);
    });

    test('should handle round-trip conversion (entity -> model -> entity)', () {
      final model = RecipeModel.fromEntity(testRecipe);
      final entity = model.toEntity();

      expect(entity.id, testRecipe.id);
      expect(entity.title, testRecipe.title);
      expect(entity.ingredients.length, testRecipe.ingredients.length);
    });
  });
}
```

**Acceptance Criteria:**

- [ ] IngredientModel created with Hive adapter
- [ ] RecipeModel created with all fields
- [ ] Hive type adapters generated successfully
- [ ] Entity conversion methods work bidirectionally
- [ ] JSON serialization works
- [ ] Models registered in HiveSetup
- [ ] Unit tests pass with >85% coverage

**Testing:**

- Test model creation
- Test entity conversion both ways
- Test JSON serialization/deserialization
- Test round-trip conversion

---

_[Continue with remaining tasks R-003 through R-005, and all other epics following the same detailed format...]_

---

## Summary: Complete Task List

### Phase 0: Foundation (6 tasks, ~20 hours)

- F-001: Initialize Project ✓
- F-002: Error Handling ✓
- F-003: Hive Setup ✓
- F-004: Network Detection ✓
- F-005: Design System ✓
- F-006: Testing Infrastructure ✓

### Recipe Data Layer (5 tasks, ~21 hours)

- R-001: Domain Entities ✓
- R-002: Data Models ✓
- R-003: Local Data Source (5h)
- R-004: Repository Implementation (5h)
- R-005: Provider Setup (3h)

### Shopping List Data Layer (4 tasks, ~16 hours)

- S-001: Domain Entities (3h)
- S-002: Data Models (5h)
- S-003: Local Data Source (5h)
- S-004: Repository & Providers (3h)

### Meal Plan Data Layer (4 tasks, ~18 hours)

- M-001: Domain Entities (3h)
- M-002: Data Models (5h)
- M-003: Local Data Source (5h)
- M-004: Repository & Providers (5h)

### Pantry Data Layer (4 tasks, ~17 hours)

- P-001: Domain Entities (3h)
- P-002: Data Models (5h)
- P-003: Local Data Source (5h)
- P-004: Repository & Providers (4h)

### Sync Engine Data Layer (5 tasks, ~29 hours)

- SY-001: Sync Operation Entities (3h)
- SY-002: Sync Queue Model (5h)
- SY-003: Sync Queue Data Source (8h)
- SY-004: Conflict Resolution (8h)
- SY-005: Sync Repository (5h)

---

**Total Estimated Hours:** ~121 hours (~15 working days for 1 developer, ~8 days for 2 developers)

**Next Phase:** After completing all data layer tasks, proceed to Domain Layer (Use Cases) as outlined in Revised Epics document.

---

**Document End**
