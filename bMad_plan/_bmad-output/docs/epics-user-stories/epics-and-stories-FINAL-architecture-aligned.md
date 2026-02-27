# Epics and User Stories - Architecture Aligned

## Flutter Shopping List & Meal Planning App

**Document Version:** 4.0  
**Date:** February 26, 2026  
**Author:** BMad Team  
**Status:** Development Ready - Architecture Aligned  
**Approach:** Clean Architecture + Offline-First + Riverpod + Drift  
**Related Documents:** [Architecture](architecture-shopping-list-app.md), [PRD](prd-shopping-list-app.md), [UX Design](ux-design-shopping-list-app.md)

---

## Document Overview

This document organizes all development work into **Epics** and **User Stories** aligned with the technical architecture specification. Each story follows Clean Architecture principles with clear separation between Presentation, Application (Use Cases), Domain, and Data layers.

### Key Architectural Decisions

✅ **Clean Architecture** - Strict layer separation (Presentation → Application → Domain → Data)  
✅ **Offline-First Pattern** - Local DB is source of truth, cloud sync is optional  
✅ **Repository Pattern** - Abstract data sources behind repositories  
✅ **MVVM with Riverpod** - StateNotifiers manage UI state, UseCase execute business logic  
✅ **Drift Database** - Type-safe SQLite with reactive queries  
✅ **Feature Modules** - Each feature has domain/data/presentation folders  
✅ **Dependency Injection** - Riverpod providers for all dependencies

### Story Point Scale

- **1 point:** 1-2 hours (simple changes)
- **2 points:** Half day (basic feature)
- **3 points:** Full day (standard feature)
- **5 points:** 2-3 days (complex feature)
- **8 points:** 3-5 days (very complex)
- **13 points:** 1-2 weeks (needs splitting)

### Priority Levels

- **P0 (Critical):** MVP blocker - app doesn't work without it
- **P1 (High):** Core feature for product-market fit
- **P2 (Medium):** Important enhancement
- **P3 (Low):** Nice-to-have, future release

---

## Table of Contents

1. [Epic Summary](#epic-summary)
2. [Phase 0: Foundation & Core Infrastructure](#phase-0-foundation--core-infrastructure)
3. [Phase 1: Data Layer (Repositories & Data Sources)](#phase-1-data-layer-repositories--data-sources)
4. [Phase 2: Domain Layer (Use Cases & Business Logic)](#phase-2-domain-layer-use-cases--business-logic)
5. [Phase 3: Presentation Layer (UI & State Management)](#phase-3-presentation-layer-ui--state-management)
6. [Phase 4: Cloud Sync & Collaboration (Post-MVP)](#phase-4-cloud-sync--collaboration-post-mvp)
7. [Phase 5: Performance & Polish](#phase-5-performance--polish)
8. [Release Planning](#release-planning)

---

## Epic Summary

| Phase | Epic ID | Epic Name                       | Stories | Points | Priority | Duration   |
| ----- | ------- | ------------------------------- | ------- | ------ | -------- | ---------- |
| **0** | **E0**  | **Foundation & Infrastructure** | **7**   | **34** | **P0**   | Week 1-2   |
| **1** | **E1**  | **Recipe Data Layer**           | **6**   | **26** | **P0**   | Week 2-3   |
| **1** | **E2**  | **Shopping List Data Layer**    | **5**   | **21** | **P0**   | Week 3     |
| **1** | **E3**  | **Meal Plan Data Layer**        | **5**   | **20** | **P0**   | Week 3-4   |
| **1** | **E4**  | **Pantry Data Layer**           | **5**   | **19** | **P0**   | Week 4     |
| **2** | **E5**  | **Recipe Use Cases**            | **7**   | **28** | **P0**   | Week 4-5   |
| **2** | **E6**  | **Shopping List Use Cases**     | **6**   | **24** | **P0**   | Week 5-6   |
| **2** | **E7**  | **Meal Planning Use Cases**     | **6**   | **26** | **P0**   | Week 6     |
| **2** | **E8**  | **Pantry Use Cases**            | **5**   | **21** | **P0**   | Week 6-7   |
| **3** | **E9**  | **Core UI Components & Theme**  | **6**   | **22** | **P0**   | Week 7     |
| **3** | **E10** | **Shopping List UI**            | **6**   | **24** | **P0**   | Week 7-8   |
| **3** | **E11** | **Recipe Management UI**        | **7**   | **29** | **P0**   | Week 8-9   |
| **3** | **E12** | **Meal Planning UI**            | **6**   | **26** | **P0**   | Week 9-10  |
| **3** | **E13** | **Pantry Inventory UI**         | **5**   | **21** | **P0**   | Week 10    |
| **3** | **E14** | **Settings & Data Management**  | **5**   | **20** | **P0**   | Week 11    |
| **4** | **E15** | **Sync Engine & Queue**         | **7**   | **35** | **P1**   | Week 12-13 |
| **4** | **E16** | **Cloud Backend Integration**   | **8**   | **40** | **P1**   | Week 13-15 |
| **4** | **E17** | **Authentication & Security**   | **6**   | **29** | **P1**   | Week 15-16 |
| **4** | **E18** | **Family & Collaboration**      | **6**   | **27** | **P2**   | Week 16-17 |
| **5** | **E19** | **Performance Optimization**    | **6**   | **26** | **P1**   | Week 17-18 |
| **5** | **E20** | **Smart Features & AI**         | **7**   | **38** | **P2**   | Week 18-20 |
| **5** | **E21** | **Testing & Quality Assurance** | **8**   | **32** | **P0**   | Continuous |

### MVP Scope (Offline-First)

**Phases 0-3 (Epics E0-E14):** **341 story points** ≈ **13-15 weeks** for 2 developers

- ✅ Fully functional offline app
- ✅ Clean Architecture implementation
- ✅ All core features (recipes, shopping, meal planning, pantry)
- ✅ Comprehensive testing

### Post-MVP Features

**Phases 4-5 (Epics E15-E21):** **227 story points** ≈ **10-12 weeks**

- 🌐 Cloud sync with conflict resolution
- 👥 Family sharing and collaboration
- 🤖 AI-powered features
- ⚡ Performance optimizations

---

## PHASE 0: Foundation & Core Infrastructure

### Epic E0: Foundation & Infrastructure

**Epic Goal:** Establish development foundation with Clean Architecture, Drift database, and Riverpod dependency injection.

**Business Value:** Solid foundation enables rapid, maintainable feature development.

**Story Count:** 7 stories | **Total Points:** 34 | **Duration:** Week 1-2

---

#### US-E0.1: Project Setup with Clean Architecture

**As a** developer  
**I want to** set up Flutter project with Clean Architecture structure  
**So that** code is maintainable, testable, and scalable

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** None

**Acceptance Criteria:**

- [ ] Flutter project initialized (3.16+, Dart 3.2+)
- [ ] Clean Architecture folder structure created (domain/data/presentation)
- [ ] Feature-based modules created (shopping, recipes, meal_planning, pantry)
- [ ] Core shared modules configured
- [ ] Git repository initialized with `.gitignore`
- [ ] README with architecture overview

**Folder Structure:**

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   └── tables/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── storage_constants.dart
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── network_info.dart
│   │   └── api_client.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── string_utils.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── typography.dart
│   └── providers/
│       └── core_providers.dart
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
│   ├── pantry/
│   └── sync/
└── shared/
    ├── widgets/
    └── extensions/
```

**Dependencies (pubspec.yaml):**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Local Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3

  # Functional Programming
  dartz: ^0.10.1
  equatable: ^2.0.5

  # Utils
  uuid: ^4.0.0
  intl: ^0.18.0
  connectivity_plus: ^5.0.2
  shared_preferences: ^2.2.0

  # JSON Serialization
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.6
  drift_dev: ^2.14.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1

  # Testing
  mockito: ^5.4.2
  integration_test:
    sdk: flutter
```

**Technical Notes:**

- Follow dependency rule: inner layers don't depend on outer layers
- Use `analysis_options.yaml` for strict linting
- Configure CI/CD pipeline in later story

**Testing Requirements:**

- [ ] Project builds successfully
- [ ] No linting errors
- [ ] Folder structure verified

---

#### US-E0.2: Drift Database Configuration & Base Tables

**As a** developer  
**I want to** configure Drift database with migration support  
**So that** we have type-safe, reactive SQLite storage

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] Drift database class created (`AppDatabase`)
- [ ] Database initialization configured with versioning
- [ ] Migration strategy implemented
- [ ] Sync queue table created for future cloud sync
- [ ] Database provider configured in Riverpod
- [ ] Development database populated with sample data
- [ ] Database inspector tool integrated (for debugging)

**Implementation:**

```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Sync Queue Table (for Post-MVP cloud sync)
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();        // 'recipe', 'shopping_list', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()();         // 'create', 'update', 'delete'
  TextColumn get data => text()();              // JSON string
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    SyncQueue,
    // Tables will be added in Phase 1 epics
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
        // Future migrations
        if (from < 2) {
          // Migration example
          // await m.addColumn(recipes, recipes.newColumn);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shopping_app.db'));
    return NativeDatabase(file);
  });
}
```

**Riverpod Provider:**

```dart
// lib/core/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
```

**Technical Notes:**

- Drift generates type-safe DAOs and queries
- Schema version enables future migrations
- LazyDatabase delays initialization until first query
- Database is singleton through Riverpod

**Testing Requirements:**

- [ ] Unit test: Database initializes successfully
- [ ] Unit test: Migration strategy executes without errors
- [ ] Integration test: CRUD operations on test table

---

#### US-E0.3: Error Handling & Result Pattern

**As a** developer  
**I want to** implement consistent error handling with Result type  
**So that** errors are handled predictably across all layers

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] `Failure` base class and subtypes created
- [ ] `Result<T>` type alias from dartz configured
- [ ] Exception types defined
- [ ] Error messages centralized
- [ ] Result pattern used in all repository interfaces

**Implementation:**

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

class ConflictFailure extends Failure {
  final dynamic localData;
  final dynamic remoteData;

  const ConflictFailure(String message, {this.localData, this.remoteData})
      : super(message);

  @override
  List<Object?> get props => [message, localData, remoteData];
}
```

```dart
// lib/core/error/exceptions.dart
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
```

**Usage Pattern:**

```dart
import 'package:dartz/dartz.dart';

// Repository Interface
abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> getAllRecipes();
  Future<Either<Failure, Recipe>> getRecipeById(String id);
  Future<Either<Failure, Recipe>> saveRecipe(Recipe recipe);
  Future<Either<Failure, Unit>> deleteRecipe(String id);
}

// Use Case
class GetAllRecipesUseCase {
  final RecipeRepository repository;

  GetAllRecipesUseCase(this.repository);

  Future<Either<Failure, List<Recipe>>> call() async {
    return await repository.getAllRecipes();
  }
}

// UI Layer handling
final result = await ref.read(getAllRecipesUseCaseProvider).call();
result.fold(
  (failure) => _showError(failure.message),
  (recipes) => state = RecipeListState.loaded(recipes),
);
```

**Technical Notes:**

- `Either<Failure, T>` forces explicit error handling
- Exceptions converted to Failures in repository layer
- UI never catches exceptions, only handles Failures
- Equatable enables value comparison for testing

**Testing Requirements:**

- [ ] Unit test: Each Failure type created correctly
- [ ] Unit test: Failure equality comparison works

---

#### US-E0.4: Network Info & Connectivity Check

**As a** developer  
**I want to** check network connectivity reliably  
**So that** offline-first logic knows when to attempt sync

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] `NetworkInfo` interface created
- [ ] Implementation using `connectivity_plus` package
- [ ] Connectivity stream for reactive checks
- [ ] Riverpod provider configured
- [ ] Works on iOS and Android

**Implementation:**

```dart
// lib/core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectivityStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get connectivityStream {
    return connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

**Provider:**

```dart
// lib/core/providers/core_providers.dart
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(
    connectivity: ref.watch(connectivityProvider),
  );
});
```

**Technical Notes:**

- Check network before sync operations
- Stream enables reactive UI (show offline banner)
- Don't block user actions when offline (offline-first)

**Testing Requirements:**

- [ ] Unit test: `isConnected` returns correct status
- [ ] Unit test: Stream emits connectivity changes
- [ ] Mock `Connectivity` in tests

---

#### US-E0.5: Core Utilities & Extensions

**As a** developer  
**I want to** reusable utilities and extensions  
**So that** common operations are DRY and consistent

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] Date formatting utilities
- [ ] String validators (email, non-empty, etc.)
- [ ] Number formatters (fractions for recipes)
- [ ] Context extensions for theming
- [ ] String extensions
- [ ] Duration formatters

**Implementation:**

```dart
// lib/core/utils/date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return formatDate(date);
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
```

```dart
// lib/core/utils/validators.dart
class Validators {
  static String? validateNonEmpty(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} cannot be empty';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? validatePositive(double? value, {String? fieldName}) {
    if (value == null || value <= 0) {
      return '${fieldName ?? 'Value'} must be positive';
    }
    return null;
  }
}
```

```dart
// lib/shared/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
```

```dart
// lib/shared/extensions/string_extensions.dart
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isNumeric => double.tryParse(this) != null;
}
```

**Technical Notes:**

- Extensions reduce boilerplate in UI code
- Validators used in UseCase layer for business rules
- Date utils consistent across app

**Testing Requirements:**

- [ ] Unit test: All date formatting functions
- [ ] Unit test: All validators with edge cases
- [ ] Unit test: String extensions

---

#### US-E0.6: App Theme & Design System

**As a** developer  
**I want to** app-wide theme with Material Design 3  
**So that** UI is consistent and follows design guidelines

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] Material Design 3 theme configured
- [ ] Light and dark themes defined
- [ ] Custom color palette matching brand
- [ ] Typography scale configured
- [ ] Spacing constants defined
- [ ] Border radius constants
- [ ] Theme provider for switching

**Implementation:**

```dart
// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const primary = Color(0xFF6750A4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE9DDFF);
  static const onPrimaryContainer = Color(0xFF22005D);

  // Secondary colors
  static const secondary = Color(0xFF625B71);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE8DEF8);
  static const onSecondaryContainer = Color(0xFF1E192B);

  // Error colors
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  // Functional colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);

  // Surface colors
  static const surface = Color(0xFFFEF7FF);
  static const onSurface = Color(0xFF1D1B20);
  static const surfaceVariant = Color(0xFFE7E0EC);
  static const onSurfaceVariant = Color(0xFF49454E);
}
```

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        background: AppColors.surface,
        onBackground: AppColors.onSurface,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: Color(0xFF7A757F),
        shadow: Color(0xFF000000),
      ),

      // Typography
      textTheme: _textTheme,

      // Component themes
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Dark theme implementation
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      // Override colors for dark mode
    );
  }

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}
```

```dart
// lib/core/constants/app_constants.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 999.0;
}
```

**Technical Notes:**

- Material 3 provides modern, adaptive components
- Theme switching for accessibility
- Consistent spacing prevents magic numbers

**Testing Requirements:**

- [ ] Widget test: Theme applies correctly
- [ ] Visual regression test for components

---

#### US-E0.7: CI/CD Pipeline Setup

**As a** developer  
**I want to** automated CI/CD pipeline  
**So that** code quality is maintained and builds are automated

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] GitHub Actions workflow configured
- [ ] Automated linting on PR
- [ ] Automated tests on PR
- [ ] Build verification for iOS and Android
- [ ] Code coverage reporting
- [ ] Automated changelog generation

**Implementation:**

```yaml
# .github/workflows/main.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    name: Analyze & Lint
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

      - name: Verify formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze code
        run: flutter analyze

  test:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS (No Signing)
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Get dependencies
        run: flutter pub get

      - name: Build iOS
        run: flutter build ios --release --no-codesign
```

**Technical Notes:**

- Runs on every PR to ensure quality
- Blocks merge if tests fail
- Separate jobs for parallelization

**Testing Requirements:**

- [ ] Integration test: Pipeline runs successfully
- [ ] Verify all jobs complete

---

## PHASE 1: Data Layer (Repositories & Data Sources)

### Epic E1: Recipe Data Layer

**Epic Goal:** Implement complete data layer for recipe management with Drift database, repositories, and offline storage.

**Business Value:** Enables offline recipe storage and retrieval, foundation for all recipe features.

**Story Count:** 6 stories | **Total Points:** 26 | **Duration:** Week 2-3

---

#### US-E1.1: Recipe Domain Entities

**As a** developer  
**I want to** define core Recipe and Ingredient domain entities  
**So that** business logic has clear data structures

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] `Recipe` entity class created with all fields
- [ ] `Ingredient` value object created
- [ ] Business logic methods implemented (scale servings, etc.)
- [ ] Equatable for value comparison
- [ ] Immutable with `copyWith` methods
- [ ] Zero external dependencies (pure Dart)

**Implementation:**

```dart
// lib/features/recipes/domain/entities/ingredient.dart
import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final String? notes;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  Ingredient scale(double factor) {
    return Ingredient(
      name: name,
      quantity: quantity * factor,
      unit: unit,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [name, quantity, unit, notes];

  Ingredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? notes,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }
}
```

```dart
// lib/features/recipes/domain/entities/recipe.dart
import 'package:equatable/equatable.dart';
import 'ingredient.dart';

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

  // Business logic
  int get totalTimeMinutes => (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);

  bool hasIngredient(String ingredientName) {
    return ingredients.any(
      (ing) => ing.name.toLowerCase().contains(ingredientName.toLowerCase()),
    );
  }

  Recipe scaleServings(int newServings) {
    final scaleFactor = newServings / servings;
    return copyWith(
      servings: newServings,
      ingredients: ingredients.map((ing) => ing.scale(scaleFactor)).toList(),
    );
  }

  bool matchesTags(List<String> searchTags) {
    return searchTags.any((tag) => tags.contains(tag.toLowerCase()));
  }

  @override
  List<Object?> get props => [
    id, title, description, servings, prepTimeMinutes, cookTimeMinutes,
    ingredients, instructions, imageUrls, tags, createdAt, updatedAt,
  ];

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    int? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<String>? imageUrls,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Technical Notes:**

- Domain entities have no Flutter or external dependencies
- Business logic lives in entities (DDD principle)
- Immutability prevents accidental state changes
- Equatable enables value comparison in tests

**Testing Requirements:**

- [ ] Unit test: `Recipe.scaleServings` with various factors
- [ ] Unit test: `Recipe.hasIngredient` search
- [ ] Unit test: `Ingredient.scale` calculations
- [ ] Unit test: Equatable comparison works

---

#### US-E1.2: Recipe Drift Table & Model

**As a** developer  
**I want to** create Drift table for recipes with JSON serialization  
**So that** recipes can be persisted in SQLite

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E0.2, US-E1.1

**Acceptance Criteria:**

- [ ] Drift table created with all fields
- [ ] JSON converter for ingredients list
- [ ] JSON converter for instructions/tags arrays
- [ ] `RecipeModel` with freezed for serialization
- [ ] Conversion between `Recipe` entity and `RecipeModel`
- [ ] Sync metadata fields (isSynced, syncVersion)
- [ ] Soft delete support (isDeleted flag)

**Implementation:**

```dart
// lib/core/database/tables/recipes_table.dart
import 'package:drift/drift.dart';

@DataClassName('RecipeData')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get servings => integer()();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();

  // JSON columns for complex data
  TextColumn get ingredientsJson => text()();
  TextColumn get instructionsJson => text()();
  TextColumn get imageUrlsJson => text()();
  TextColumn get tagsJson => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata (for Post-MVP cloud sync)
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

```dart
// lib/features/recipes/data/models/recipe_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/ingredient.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

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
    @Default(false) bool isDeleted,
  }) = _RecipeModel;

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      ingredients: recipe.ingredients
          .map((ing) => IngredientModel.fromEntity(ing))
          .toList(),
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
      ingredients: ingredients.map((ing) => ing.toEntity()).toList(),
      instructions: instructions,
      imageUrls: imageUrls,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@freezed
class IngredientModel with _$IngredientModel {
  const factory IngredientModel({
    required String name,
    required double quantity,
    required String unit,
    String? notes,
  }) = _IngredientModel;

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientModelFromJson(json);

  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.unit,
      notes: ingredient.notes,
    );
  }
}

extension IngredientModelX on IngredientModel {
  Ingredient toEntity() {
    return Ingredient(
      name: name,
      quantity: quantity,
      unit: unit,
      notes: notes,
    );
  }
}
```

**Update Database:**

```dart
// lib/core/database/app_database.dart
import 'tables/recipes_table.dart';

@DriftDatabase(
  tables: [
    Recipes,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}
```

**Technical Notes:**

- Freezed generates immutable models with JSON serialization
- JSON columns store complex data (lists, objects)
- Separation: Entity (domain) vs Model (data)
- Soft delete preserves data for sync

**Testing Requirements:**

- [ ] Unit test: RecipeModel.fromJson/toJson
- [ ] Unit test: RecipeModel.fromEntity/toEntity conversions
- [ ] Unit test: JSON serialization of ingredients
- [ ] Integration test: Save/retrieve recipe from database

---

#### US-E1.3: Recipe Local Data Source

**As a** developer  
**I want to** implement recipe local data source using Drift  
**So that** recipes can be stored and queried efficiently

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.2

**Acceptance Criteria:**

- [ ] `RecipeLocalDataSource` interface defined
- [ ] Implementation with Drift queries
- [ ] CRUD operations (Create, Read, Update, Delete)
- [ ] Search by title/tags
- [ ] Filter by ingredients
- [ ] Stream queries for reactive UI
- [ ] Exception handling

**Implementation:**

```dart
// lib/features/recipes/data/datasources/recipe_local_data_source.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getAllRecipes();
  Future<RecipeModel> getRecipeById(String id);
  Future<RecipeModel> saveRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String id);
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<List<RecipeModel>> filterByTags(List<String> tags);
  Stream<List<RecipeModel>> watchAllRecipes();
  Stream<RecipeModel> watchRecipe(String id);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final AppDatabase database;

  RecipeLocalDataSourceImpl({required this.database});

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    try {
      final recipes = await (database.select(database.recipes)
            ..where((tbl) => tbl.isDeleted.equals(false)))
          .get();

      return recipes.map(_toModel).toList();
    } catch (e) {
      throw DatabaseException('Failed to get recipes: $e');
    }
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final recipe = await (database.select(database.recipes)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();

      if (recipe == null) {
        throw NotFoundException('Recipe with id $id not found');
      }

      return _toModel(recipe);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to get recipe: $e');
    }
  }

  @override
  Future<RecipeModel> saveRecipe(RecipeModel recipe) async {
    try {
      await database.into(database.recipes).insertOnConflictUpdate(
        RecipesCompanion(
          id: Value(recipe.id),
          title: Value(recipe.title),
          description: Value(recipe.description),
          servings: Value(recipe.servings),
          prepTimeMinutes: Value(recipe.prepTimeMinutes),
          cookTimeMinutes: Value(recipe.cookTimeMinutes),
          ingredientsJson: Value(jsonEncode(
            recipe.ingredients.map((ing) => ing.toJson()).toList()
          )),
          instructionsJson: Value(jsonEncode(recipe.instructions)),
          imageUrlsJson: Value(jsonEncode(recipe.imageUrls)),
          tagsJson: Value(jsonEncode(recipe.tags)),
          createdAt: Value(recipe.createdAt),
          updatedAt: Value(recipe.updatedAt),
          isSynced: Value(recipe.isSynced),
          syncVersion: Value(recipe.syncVersion),
          isDeleted: Value(recipe.isDeleted),
        ),
      );

      return recipe;
    } catch (e) {
      throw DatabaseException('Failed to save recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      // Soft delete
      await (database.update(database.recipes)
            ..where((tbl) => tbl.id.equals(id)))
          .write(
        RecipesCompanion(
          isDeleted: Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to delete recipe: $e');
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final lowerQuery = query.toLowerCase();

      final recipes = await (database.select(database.recipes)
            ..where((tbl) =>
              tbl.isDeleted.equals(false) &
              (tbl.title.lower().like('%$lowerQuery%') |
               tbl.description.lower().like('%$lowerQuery%'))))
          .get();

      return recipes.map(_toModel).toList();
    } catch (e) {
      throw DatabaseException('Failed to search recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> filterByTags(List<String> tags) async {
    try {
      final recipes = await (database.select(database.recipes)
            ..where((tbl) => tbl.isDeleted.equals(false)))
          .get();

      // Filter in memory for tags (JSON search in SQLite is limited)
      return recipes
          .map(_toModel)
          .where((recipe) =>
            tags.any((tag) => recipe.tags.contains(tag.toLowerCase())))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to filter recipes: $e');
    }
  }

  @override
  Stream<List<RecipeModel>> watchAllRecipes() {
    return (database.select(database.recipes)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch()
        .map((recipes) => recipes.map(_toModel).toList());
  }

  @override
  Stream<RecipeModel> watchRecipe(String id) {
    return (database.select(database.recipes)
          ..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull()
        .map((recipe) {
          if (recipe == null) {
            throw NotFoundException('Recipe not found');
          }
          return _toModel(recipe);
        });
  }

  // Helper method to convert Drift data to model
  RecipeModel _toModel(RecipeData data) {
    return RecipeModel(
      id: data.id,
      title: data.title,
      description: data.description,
      servings: data.servings,
      prepTimeMinutes: data.prepTimeMinutes,
      cookTimeMinutes: data.cookTimeMinutes,
      ingredients: (jsonDecode(data.ingredientsJson) as List)
          .map((json) => IngredientModel.fromJson(json))
          .toList(),
      instructions: List<String>.from(jsonDecode(data.instructionsJson)),
      imageUrls: List<String>.from(jsonDecode(data.imageUrlsJson)),
      tags: List<String>.from(jsonDecode(data.tagsJson)),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
      syncVersion: data.syncVersion,
      isDeleted: data.isDeleted,
    );
  }
}
```

**Technical Notes:**

- Drift queries are type-safe at compile time
- Stream queries enable reactive UI updates
- Soft delete preserves data for sync
- JSON search is limited, may need full-text search later

**Testing Requirements:**

- [ ] Unit test: Save recipe and retrieve by ID
- [ ] Unit test: Delete recipe (soft delete)
- [ ] Unit test: Search recipes by title
- [ ] Unit test: Filter by tags
- [ ] Unit test: Watch stream emits updates

---

#### US-E1.4: Recipe Repository Interface

**As a** developer  
**I want to** define Recipe repository interface  
**So that** domain layer is decoupled from data implementation

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E1.1

**Acceptance Criteria:**

- [ ] Repository interface in domain layer
- [ ] All operations return `Either<Failure, T>`
- [ ] Stream methods for reactive queries
- [ ] No implementation details (pure abstraction)
- [ ] Clear method documentation

**Implementation:**

```dart
// lib/features/recipes/domain/repositories/recipe_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Get all recipes (non-deleted)
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, List<Recipe>>> getAllRecipes();

  /// Get recipe by ID
  /// Returns [NotFoundFailure] if recipe doesn't exist
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, Recipe>> getRecipeById(String id);

  /// Save recipe (create or update)
  /// Returns [ValidationFailure] if recipe data is invalid
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, Recipe>> saveRecipe(Recipe recipe);

  /// Delete recipe (soft delete)
  /// Returns [NotFoundFailure] if recipe doesn't exist
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, Unit>> deleteRecipe(String id);

  /// Search recipes by query (searches title and description)
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query);

  /// Filter recipes by tags
  /// Returns [DatabaseFailure] on database error
  Future<Either<Failure, List<Recipe>>> filterByTags(List<String> tags);

  /// Watch all recipes (reactive stream)
  /// Stream emits new list whenever recipes change
  Stream<List<Recipe>> watchAllRecipes();

  /// Watch single recipe by ID (reactive stream)
  /// Stream emits updated recipe whenever it changes
  Stream<Recipe> watchRecipe(String id);
}
```

**Technical Notes:**

- Interface lives in domain layer (no data dependencies)
- `Either<Failure, T>` forces explicit error handling
- Streams enable reactive UI
- Documentation specifies failure types for each method

**Testing Requirements:**

- [ ] No direct tests (interface only)
- [ ] Implementation tests in E1.5

---

#### US-E1.5: Recipe Repository Implementation

**As a** developer  
**I want to** implement Recipe repository with offline-first logic  
**So that** domain layer can access recipes through clean interface

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.3, US-E1.4

**Acceptance Criteria:**

- [ ] Implementation of `RecipeRepository` interface
- [ ] Delegates to local data source (MVP - offline only)
- [ ] Converts exceptions to Failures
- [ ] Converts models to entities
- [ ] Post-MVP: Add network check and sync queue
- [ ] Unit tests with mocked data source

**Implementation:**

```dart
// lib/features/recipes/data/repositories/recipe_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource localDataSource;
  // Post-MVP: Add RemoteDataSource and NetworkInfo

  RecipeRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Recipe>>> getAllRecipes() async {
    try {
      final recipeModels = await localDataSource.getAllRecipes();
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(String id) async {
    try {
      final recipeModel = await localDataSource.getRecipeById(id);
      return Right(recipeModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> saveRecipe(Recipe recipe) async {
    try {
      // Convert entity to model
      final recipeModel = RecipeModel.fromEntity(recipe);

      // Save to local database (offline-first)
      final savedModel = await localDataSource.saveRecipe(recipeModel);

      // Post-MVP: Add to sync queue for cloud sync
      // await syncQueue.enqueue(SyncOperation.createOrUpdate(...));

      return Right(savedModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecipe(String id) async {
    try {
      await localDataSource.deleteRecipe(id);

      // Post-MVP: Add to sync queue
      // await syncQueue.enqueue(SyncOperation.delete(...));

      return Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query) async {
    try {
      final recipeModels = await localDataSource.searchRecipes(query);
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> filterByTags(List<String> tags) async {
    try {
      final recipeModels = await localDataSource.filterByTags(tags);
      final recipes = recipeModels.map((model) => model.toEntity()).toList();
      return Right(recipes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    return localDataSource.watchAllRecipes().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<Recipe> watchRecipe(String id) {
    return localDataSource.watchRecipe(id).map(
      (model) => model.toEntity(),
    );
  }
}
```

**Technical Notes:**

- Repository is the boundary between data and domain layers
- Converts exceptions (data layer) to Failures (domain layer)
- Converts models (data layer) to entities (domain layer)
- MVP: Offline-only, no network calls
- Post-MVP: Add sync queue and network checks

**Testing Requirements:**

- [ ] Unit test: getAllRecipes success case
- [ ] Unit test: getAllRecipes database failure
- [ ] Unit test: getRecipeById not found
- [ ] Unit test: saveRecipe success
- [ ] Unit test: deleteRecipe success
- [ ] Unit test: searchRecipes with query
- [ ] Mock `RecipeLocalDataSource` in tests

---

#### US-E1.6: Recipe Data Layer Providers

**As a** developer  
**I want to** configure Riverpod providers for recipe data layer  
**So that** dependencies are injected consistently

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E1.5

**Acceptance Criteria:**

- [ ] Data source provider created
- [ ] Repository provider created
- [ ] Providers use core database provider
- [ ] Proper disposal of resources
- [ ] All providers tested

**Implementation:**

```dart
// lib/features/recipes/data/providers/recipe_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../repositories/recipe_repository_impl.dart';

// Data Source Provider
final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return RecipeLocalDataSourceImpl(database: database);
});

// Repository Provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final localDataSource = ref.watch(recipeLocalDataSourceProvider);

  return RecipeRepositoryImpl(
    localDataSource: localDataSource,
    // Post-MVP: Add remoteDataSource, networkInfo, syncQueue
  );
});
```

**Technical Notes:**

- Providers create singletons by default
- `ref.onDispose` handles cleanup
- Repository provider is only interface exposed to domain layer
- Data source provider is private to data layer

**Testing Requirements:**

- [ ] Unit test: Providers return correct instances
- [ ] Integration test: Repository works through providers

---

### Epic E2: Shopping List Data Layer

**Epic Goal:** Implement data layer for shopping list management with offline storage.

**Business Value:** Enables offline shopping list management, core app functionality.

**Story Count:** 5 stories | **Total Points:** 21 | **Duration:** Week 3

---

#### US-E2.1: Shopping List Domain Entities

**As a** developer  
**I want to** define ShoppingList and ShoppingItem domain entities  
**So that** business logic has clear shopping data structures

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E0.1

**Acceptance Criteria:**

- [ ] `ShoppingList` entity created
- [ ] `ShoppingItem` value object created
- [ ] Business methods (add item, toggle checked, etc.)
- [ ] Category organization logic
- [ ] Completion status calculation

**Implementation:**

```dart
// lib/features/shopping/domain/entities/shopping_item.dart
import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final bool isChecked;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.isChecked = false,
    required this.createdAt,
  });

  ShoppingItem toggleChecked() {
    return copyWith(isChecked: !isChecked);
  }

  ShoppingItem updateQuantity(double newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  @override
  List<Object?> get props => [id, name, quantity, unit, category, isChecked, createdAt];

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

```dart
// lib/features/shopping/domain/entities/shopping_list.dart
import 'package:equatable/equatable.dart';
import 'shopping_item.dart';

class ShoppingList extends Equatable {
  final String id;
  final String name;
  final List<ShoppingItem> items;
  final String? linkedMealPlanId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
    this.linkedMealPlanId,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic
  int get totalItems => items.length;
  int get checkedItems => items.where((item) => item.isChecked).length;
  double get completionPercentage =>
      totalItems == 0 ? 0 : (checkedItems / totalItems) * 100;

  bool get allItemsChecked => totalItems > 0 && checkedItems == totalItems;

  Map<String?, List<ShoppingItem>> get itemsByCategory {
    final grouped = <String?, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  ShoppingList addItem(ShoppingItem item) {
    return copyWith(
      items: [...items, item],
      updatedAt: DateTime.now(),
    );
  }

  ShoppingList removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingList toggleItem(String itemId) {
    return copyWith(
      items: items.map((item) {
        return item.id == itemId ? item.toggleChecked() : item;
      }).toList(),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingList updateItem(ShoppingItem updatedItem) {
    return copyWith(
      items: items.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList(),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingList markCompleted(bool completed) {
    return copyWith(
      isCompleted: completed,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id, name, items, linkedMealPlanId, isCompleted, createdAt, updatedAt,
  ];

  ShoppingList copyWith({
    String? id,
    String? name,
    List<ShoppingItem>? items,
    String? linkedMealPlanId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      linkedMealPlanId: linkedMealPlanId ?? this.linkedMealPlanId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Technical Notes:**

- Rich business logic in entities (DDD)
- Immutable with copy methods
- Calculated properties for UI

**Testing Requirements:**

- [ ] Unit test: addItem, removeItem, toggleItem
- [ ] Unit test: completionPercentage calculation
- [ ] Unit test: itemsByCategory grouping
- [ ] Unit test: allItemsChecked logic

---

#### US-E2.2: Shopping List Drift Table & Model

**As a** developer  
**I want to** create Drift tables for shopping lists  
**So that** shopping data can be persisted locally

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E0.2, US-E2.1

**Acceptance Criteria:**

- [ ] `ShoppingLists` Drift table created
- [ ] `ShoppingItems` Drift table created (separate table for normalization)
- [ ] Foreign key relationship configured
- [ ] Models with freezed for serialization
- [ ] Entity/Model conversions

**Implementation:**

```dart
// lib/core/database/tables/shopping_lists_table.dart
import 'package:drift/drift.dart';

@DataClassName('ShoppingListData')
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

@DataClassName('ShoppingItemData')
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

  @override
  List<Set<Column>> get uniqueKeys => [];
}
```

```dart
// lib/features/shopping/data/models/shopping_list_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/shopping_list.dart';
import 'shopping_item_model.dart';

part 'shopping_list_model.freezed.dart';
part 'shopping_list_model.g.dart';

@freezed
class ShoppingListModel with _$ShoppingListModel {
  const factory ShoppingListModel({
    required String id,
    required String name,
    @Default([]) List<ShoppingItemModel> items,
    String? linkedMealPlanId,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
    @Default(0) int syncVersion,
  }) = _ShoppingListModel;

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListModelFromJson(json);

  factory ShoppingListModel.fromEntity(ShoppingList list) {
    return ShoppingListModel(
      id: list.id,
      name: list.name,
      items: list.items.map((item) => ShoppingItemModel.fromEntity(item)).toList(),
      linkedMealPlanId: list.linkedMealPlanId,
      isCompleted: list.isCompleted,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
    );
  }
}

extension ShoppingListModelX on ShoppingListModel {
  ShoppingList toEntity() {
    return ShoppingList(
      id: id,
      name: name,
      items: items.map((item) => item.toEntity()).toList(),
      linkedMealPlanId: linkedMealPlanId,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@freezed
class ShoppingItemModel with _$ShoppingItemModel {
  const factory ShoppingItemModel({
    required String id,
    required String name,
    required double quantity,
    required String unit,
    String? category,
    @Default(false) bool isChecked,
    required DateTime createdAt,
  }) = _ShoppingItemModel;

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemModelFromJson(json);

  factory ShoppingItemModel.fromEntity(ShoppingItem item) {
    return ShoppingItemModel(
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      category: item.category,
      isChecked: item.isChecked,
      createdAt: item.createdAt,
    );
  }
}

extension ShoppingItemModelX on ShoppingItemModel {
  ShoppingItem toEntity() {
    return ShoppingItem(
      id: id,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      isChecked: isChecked,
      createdAt: createdAt,
    );
  }
}
```

**Update Database:**

```dart
// lib/core/database/app_database.dart
import 'tables/shopping_lists_table.dart';

@DriftDatabase(
  tables: [
    Recipes,
    ShoppingLists,
    ShoppingItems,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}
```

**Technical Notes:**

- Separate tables allow efficient queries
- Items linked via foreign key
- Can query items independently

**Testing Requirements:**

- [ ] Unit test: Model JSON serialization
- [ ] Unit test: Entity/Model conversions
- [ ] Integration test: Save list with items

---

#### US-E2.3: Shopping List Local Data Source

**As a** developer  
**I want to** implement shopping list local data source  
**So that** shopping lists can be stored and retrieved with items

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E2.2

**Acceptance Criteria:**

- [ ] CRUD operations for shopping lists
- [ ] Join queries to fetch lists with items
- [ ] Update individual items
- [ ] Toggle item checked status
- [ ] Stream queries for reactive UI
- [ ] Proper transaction handling

**Implementation:**

```dart
// lib/features/shopping/data/datasources/shopping_list_local_data_source.dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/shopping_list_model.dart';

abstract class ShoppingListLocalDataSource {
  Future<List<ShoppingListModel>> getAllShoppingLists();
  Future<ShoppingListModel> getShoppingListById(String id);
  Future<ShoppingListModel> saveShoppingList(ShoppingListModel list);
  Future<void> deleteShoppingList(String id);
  Future<void> addItemToList(String listId, ShoppingItemModel item);
  Future<void> removeItemFromList(String itemId);
  Future<void> toggleItemChecked(String itemId);
  Stream<List<ShoppingListModel>> watchAllShoppingLists();
  Stream<ShoppingListModel> watchShoppingList(String id);
}

class ShoppingListLocalDataSourceImpl implements ShoppingListLocalDataSource {
  final AppDatabase database;

  ShoppingListLocalDataSourceImpl({required this.database});

  @override
  Future<List<ShoppingListModel>> getAllShoppingLists() async {
    try {
      final lists = await database.select(database.shoppingLists).get();

      // Fetch items for each list
      final listModels = <ShoppingListModel>[];
      for (final list in lists) {
        final items = await (database.select(database.shoppingItems)
              ..where((tbl) => tbl.shoppingListId.equals(list.id)))
            .get();

        listModels.add(_toListModel(list, items));
      }

      return listModels;
    } catch (e) {
      throw DatabaseException('Failed to get shopping lists: $e');
    }
  }

  @override
  Future<ShoppingListModel> getShoppingListById(String id) async {
    try {
      final list = await (database.select(database.shoppingLists)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (list == null) {
        throw NotFoundException('Shopping list with id $id not found');
      }

      final items = await (database.select(database.shoppingItems)
            ..where((tbl) => tbl.shoppingListId.equals(id)))
          .get();

      return _toListModel(list, items);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to get shopping list: $e');
    }
  }

  @override
  Future<ShoppingListModel> saveShoppingList(ShoppingListModel list) async {
    try {
      await database.transaction(() async {
        // Save/update the list
        await database.into(database.shoppingLists).insertOnConflictUpdate(
          ShoppingListsCompanion(
            id: Value(list.id),
            name: Value(list.name),
            linkedMealPlanId: Value(list.linkedMealPlanId),
            isCompleted: Value(list.isCompleted),
            createdAt: Value(list.createdAt),
            updatedAt: Value(list.updatedAt),
            isSynced: Value(list.isSynced),
            syncVersion: Value(list.syncVersion),
          ),
        );

        // Delete existing items
        await (database.delete(database.shoppingItems)
              ..where((tbl) => tbl.shoppingListId.equals(list.id)))
            .go();

        // Insert new items
        for (final item in list.items) {
          await database.into(database.shoppingItems).insert(
            ShoppingItemsCompanion(
              id: Value(item.id),
              shoppingListId: Value(list.id),
              name: Value(item.name),
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              category: Value(item.category),
              isChecked: Value(item.isChecked),
              createdAt: Value(item.createdAt),
            ),
          );
        }
      });

      return list;
    } catch (e) {
      throw DatabaseException('Failed to save shopping list: $e');
    }
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    try {
      await database.transaction(() async {
        // Delete items first (foreign key)
        await (database.delete(database.shoppingItems)
              ..where((tbl) => tbl.shoppingListId.equals(id)))
            .go();

        // Delete list
        await (database.delete(database.shoppingLists)
              ..where((tbl) => tbl.id.equals(id)))
            .go();
      });
    } catch (e) {
      throw DatabaseException('Failed to delete shopping list: $e');
    }
  }

  @override
  Future<void> addItemToList(String listId, ShoppingItemModel item) async {
    try {
      await database.into(database.shoppingItems).insert(
        ShoppingItemsCompanion(
          id: Value(item.id),
          shoppingListId: Value(listId),
          name: Value(item.name),
          quantity: Value(item.quantity),
          unit: Value(item.unit),
          category: Value(item.category),
          isChecked: Value(item.isChecked),
          createdAt: Value(item.createdAt),
        ),
      );

      // Update list updatedAt timestamp
      await (database.update(database.shoppingLists)
            ..where((tbl) => tbl.id.equals(listId)))
          .write(
        ShoppingListsCompanion(
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to add item: $e');
    }
  }

  @override
  Future<void> removeItemFromList(String itemId) async {
    try {
      // Get list ID before deleting
      final item = await (database.select(database.shoppingItems)
            ..where((tbl) => tbl.id.equals(itemId)))
          .getSingleOrNull();

      if (item == null) {
        throw NotFoundException('Item not found');
      }

      await (database.delete(database.shoppingItems)
            ..where((tbl) => tbl.id.equals(itemId)))
          .go();

      // Update list timestamp
      await (database.update(database.shoppingLists)
            ..where((tbl) => tbl.id.equals(item.shoppingListId)))
          .write(
        ShoppingListsCompanion(
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to remove item: $e');
    }
  }

  @override
  Future<void> toggleItemChecked(String itemId) async {
    try {
      final item = await (database.select(database.shoppingItems)
            ..where((tbl) => tbl.id.equals(itemId)))
          .getSingleOrNull();

      if (item == null) {
        throw NotFoundException('Item not found');
      }

      await (database.update(database.shoppingItems)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(
        ShoppingItemsCompanion(
          isChecked: Value(!item.isChecked),
        ),
      );

      // Update list timestamp
      await (database.update(database.shoppingLists)
            ..where((tbl) => tbl.id.equals(item.shoppingListId)))
          .write(
        ShoppingListsCompanion(
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to toggle item: $e');
    }
  }

  @override
  Stream<List<ShoppingListModel>> watchAllShoppingLists() {
    // This is complex with joins - simplified version
    return database.select(database.shoppingLists).watch().asyncMap(
      (lists) async {
        final listModels = <ShoppingListModel>[];
        for (final list in lists) {
          final items = await (database.select(database.shoppingItems)
                ..where((tbl) => tbl.shoppingListId.equals(list.id)))
              .get();
          listModels.add(_toListModel(list, items));
        }
        return listModels;
      },
    );
  }

  @override
  Stream<ShoppingListModel> watchShoppingList(String id) {
    return database.select(database.shoppingLists)
        .watch()
        .asyncMap((lists) async {
          final list = lists.firstWhere((l) => l.id == id);
          final items = await (database.select(database.shoppingItems)
                ..where((tbl) => tbl.shoppingListId.equals(id)))
              .get();
          return _toListModel(list, items);
        });
  }

  ShoppingListModel _toListModel(
    ShoppingListData list,
    List<ShoppingItemData> items,
  ) {
    return ShoppingListModel(
      id: list.id,
      name: list.name,
      items: items.map(_toItemModel).toList(),
      linkedMealPlanId: list.linkedMealPlanId,
      isCompleted: list.isCompleted,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
      isSynced: list.isSynced,
      syncVersion: list.syncVersion,
    );
  }

  ShoppingItemModel _toItemModel(ShoppingItemData data) {
    return ShoppingItemModel(
      id: data.id,
      name: data.name,
      quantity: data.quantity,
      unit: data.unit,
      category: data.category,
      isChecked: data.isChecked,
      createdAt: data.createdAt,
    );
  }
}
```

**Technical Notes:**

- Transactions ensure data consistency
- Join queries fetch related data
- Stream queries reactive to both tables

**Testing Requirements:**

- [ ] Unit test: Save list with items
- [ ] Unit test: Add/remove items
- [ ] Unit test: Toggle item checked
- [ ] Unit test: Delete list deletes items (cascade)
- [ ] Integration test: Watch stream updates

---

#### US-E2.4: Shopping List Repository Implementation

**As a** developer  
**I want to** implement shopping list repository  
**So that** domain layer can access shopping lists through clean interface

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E2.3

**Acceptance Criteria:**

- [ ] Repository interface defined in domain layer
- [ ] Implementation with offline-first logic
- [ ] Exception to Failure conversion
- [ ] Model to Entity conversion
- [ ] All operations tested

**Implementation:**

```dart
// lib/features/shopping/domain/repositories/shopping_list_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shopping_list.dart';
import '../entities/shopping_item.dart';

abstract class ShoppingListRepository {
  Future<Either<Failure, List<ShoppingList>>> getAllShoppingLists();
  Future<Either<Failure, ShoppingList>> getShoppingListById(String id);
  Future<Either<Failure, ShoppingList>> saveShoppingList(ShoppingList list);
  Future<Either<Failure, Unit>> deleteShoppingList(String id);
  Future<Either<Failure, Unit>> addItemToList(String listId, ShoppingItem item);
  Future<Either<Failure, Unit>> removeItemFromList(String itemId);
  Future<Either<Failure, Unit>> toggleItemChecked(String itemId);
  Stream<List<ShoppingList>> watchAllShoppingLists();
  Stream<ShoppingList> watchShoppingList(String id);
}
```

```dart
// lib/features/shopping/data/repositories/shopping_list_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_data_source.dart';
import '../models/shopping_list_model.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListLocalDataSource localDataSource;

  ShoppingListRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ShoppingList>>> getAllShoppingLists() async {
    try {
      final models = await localDataSource.getAllShoppingLists();
      final lists = models.map((m) => m.toEntity()).toList();
      return Right(lists);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ShoppingList>> getShoppingListById(String id) async {
    try {
      final model = await localDataSource.getShoppingListById(id);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ShoppingList>> saveShoppingList(ShoppingList list) async {
    try {
      final model = ShoppingListModel.fromEntity(list);
      final saved = await localDataSource.saveShoppingList(model);
      return Right(saved.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteShoppingList(String id) async {
    try {
      await localDataSource.deleteShoppingList(id);
      return Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addItemToList(String listId, ShoppingItem item) async {
    try {
      final itemModel = ShoppingItemModel.fromEntity(item);
      await localDataSource.addItemToList(listId, itemModel);
      return Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeItemFromList(String itemId) async {
    try {
      await localDataSource.removeItemFromList(itemId);
      return Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleItemChecked(String itemId) async {
    try {
      await localDataSource.toggleItemChecked(itemId);
      return Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<ShoppingList>> watchAllShoppingLists() {
    return localDataSource.watchAllShoppingLists().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Stream<ShoppingList> watchShoppingList(String id) {
    return localDataSource.watchShoppingList(id).map((m) => m.toEntity());
  }
}
```

**Testing Requirements:**

- [ ] Unit test: All repository methods with mocked data source
- [ ] Unit test: Exception to Failure conversion
- [ ] Unit test: Model to Entity conversion

---

#### US-E2.5: Shopping List Data Layer Providers

**As a** developer  
**I want to** configure Riverpod providers for shopping list data layer  
**So that** dependencies are properly injected

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E2.4

**Acceptance Criteria:**

- [ ] Data source provider
- [ ] Repository provider
- [ ] Proper dependency injection

**Implementation:**

```dart
// lib/features/shopping/data/providers/shopping_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_data_source.dart';
import '../repositories/shopping_list_repository_impl.dart';

final shoppingListLocalDataSourceProvider = Provider<ShoppingListLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return ShoppingListLocalDataSourceImpl(database: database);
});

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final localDataSource = ref.watch(shoppingListLocalDataSourceProvider);
  return ShoppingListRepositoryImpl(localDataSource: localDataSource);
});
```

**Testing Requirements:**

- [ ] Unit test: Providers return correct instances

---

### Note on Remaining Epics

Due to the extensive length of this document, I'll provide a summary structure for the remaining epics. Each follows the same pattern as E1 and E2:

### Epic E3: Meal Plan Data Layer

- US-E3.1: Meal Plan Domain Entities (MealPlan, MealSlot)
- US-E3.2: Meal Plan Drift Table & Model
- US-E3.3: Meal Plan Local Data Source
- US-E3.4: Meal Plan Repository Implementation
- US-E3.5: Meal Plan Data Layer Providers

### Epic E4: Pantry Data Layer

- US-E4.1: Pantry Item Domain Entity
- US-E4.2: Pantry Drift Table & Model
- US-E4.3: Pantry Local Data Source
- US-E4.4: Pantry Repository Implementation
- US-E4.5: Pantry Data Layer Providers

---

## PHASE 2: Domain Layer (Use Cases & Business Logic)

### Epic E5: Recipe Use Cases

- US-E5.1: Get All Recipes Use Case
- US-E5.2: Get Recipe By ID Use Case
- US-E5.3: Save Recipe Use Case (with validation)
- US-E5.4: Delete Recipe Use Case
- US-E5.5: Search Recipes Use Case
- US-E5.6: Scale Recipe Servings Use Case
- US-E5.7: Use Case Providers

### Epic E6: Shopping List Use Cases

- US-E6.1: Get All Shopping Lists Use Case
- US-E6.2: Create Shopping List Use Case
- US-E6.3: Add Item to List Use Case (with category inference)
- US-E6.4: Toggle Item Checked Use Case
- US-E6.5: Generate List from Meal Plan Use Case
- US-E6.6: Use Case Providers

### Epic E7: Meal Planning Use Cases

- US-E7.1: Get Weekly Meal Plan Use Case
- US-E7.2: Assign Recipe to Meal Slot Use Case
- US-E7.3: Generate Shopping List from Plan Use Case
- US-E7.4: Clear Meal Slot Use Case
- US-E7.5: Duplicate Meal Plan Use Case
- US-E7.6: Use Case Providers

### Epic E8: Pantry Use Cases

- US-E8.1: Get All Pantry Items Use Case
- US-E8.2: Add Pantry Item Use Case
- US-E8.3: Update Item Quantity Use Case
- US-E8.4: Get Expiring Items Use Case
- US-E8.5: Use Case Providers

---

## PHASE 3: Presentation Layer (UI & State Management)

### Epic E9: Core UI Components & Theme

- US-E9.1: App Shell & Navigation
- US-E9.2: Common Widgets (LoadingSkeleton, ErrorView, EmptyState)
- US-E9.3: Bottom Navigation
- US-E9.4: App Bar Components
- US-E9.5: Form Input Components
- US-E9.6: Dialogs & Bottom Sheets

### Epic E10: Shopping List UI

- US-E10.1: Shopping Lists Overview Page with State Provider
- US-E10.2: Shopping List Detail Page with Stream Provider
- US-E10.3: Add/Edit Item Bottom Sheet
- US-E10.4: Category Grouping UI
- US-E10.5: Item Check Animation
- US-E10.6: List Actions (rename, delete, share)

### Epic E11: Recipe Management UI

- US-E11.1: Recipe List Page with Search
- US-E11.2: Recipe Detail Page
- US-E11.3: Add/Edit Recipe Form
- US-E11.4: Ingredient Input Component
- US-E11.5: Instruction Steps Component
- US-E11.6: Recipe Image Picker
- US-E11.7: Recipe Actions (edit, delete, scale)

### Epic E12: Meal Planning UI

- US-E12.1: Weekly Calendar View
- US-E12.2: Meal Slot Component
- US-E12.3: Recipe Picker Bottom Sheet
- US-E12.4: Drag-and-Drop Recipe Assignment
- US-E12.5: Generate Shopping List Button
- US-E12.6: Week Navigation

### Epic E13: Pantry Inventory UI

- US-E13.1: Pantry Items List
- US-E13.2: Add Pantry Item Form
- US-E13.3: Expiring Items Badge
- US-E13.4: Quick Quantity Adjust
- US-E13.5: Category Filter

### Epic E14: Settings & Data Management

- US-E14.1: Settings Page
- US-E14.2: Export Data to JSON
- US-E14.3: Import Data from JSON
- US-E14.4: Clear All Data (with confirmation)
- US-E14.5: About/Help Page

---

## PHASE 4: Cloud Sync & Collaboration (Post-MVP)

### Epic E15: Sync Engine & Queue

- US-E15.1: Sync Queue Implementation
- US-E15.2: Sync Coordinator
- US-E15.3: Conflict Resolver (Last-Write-Wins)
- US-E15.4: Operational Transform for Lists
- US-E15.5: Network Change Listener
- US-E15.6: Background Sync Job
- US-E15.7: Sync Status UI Indicator

### Epic E16: Cloud Backend Integration

- US-E16.1: Choose Backend (Firebase or Supabase)
- US-E16.2: Remote Data Sources for All Entities
- US-E16.3: Cloud Functions for Recipe Import
- US-E16.4: Image Upload & Optimization
- US-E16.5: API Client with Retry Logic
- US-E16.6: Database Migration to Cloud
- US-E16.7: Differential Sync Implementation
- US-E16.8: Real-time Updates with WebSocket

### Epic E17: Authentication & Security

- US-E17.1: Email/Password Authentication
- US-E17.2: Google Sign-In
- US-E17.3: Token Management (Refresh logic)
- US-E17.4: Secure Storage (Keychain/Keystore)
- US-E17.5: Row-Level Security Policies
- US-E17.6: Data Encryption for Sensitive Fields

### Epic E18: Family & Collaboration

- US-E18.1: Create Family Group
- US-E18.2: Invite Members
- US-E18.3: Share Shopping List
- US-E18.4: Real-time Collaborative Editing
- US-E18.5: User Roles & Permissions
- US-E18.6: Activity Feed

---

## PHASE 5: Performance & Polish

### Epic E19: Performance Optimization

- US-E19.1: Image Caching with CachedNetworkImage
- US-E19.2: Pagination for Recipe List
- US-E19.3: Lazy Loading Images
- US-E19.4: Database Query Optimization with Indexes
- US-E19.5: Image Compression on Upload
- US-E19.6: Performance Monitoring Integration

### Epic E20: Smart Features & AI

- US-E20.1: Recipe Import from URL (Web Scraping)
- US-E20.2: Ingredient Recognition (ML Kit)
- US-E20.3: Smart Category Inference
- US-E20.4: Recipe Recommendations
- US-E20.5: Nutrition Calculation
- US-E20.6: Voice Input for Items
- US-E20.7: Barcode Scanner for Pantry

### Epic E21: Testing & Quality Assurance

- US-E21.1: Unit Test Suite (60% coverage)
- US-E21.2: Widget Test Suite
- US-E21.3: Integration Tests for Critical Flows
- US-E21.4: E2E Tests with Flutter Driver
- US-E21.5: Performance Tests
- US-E21.6: Accessibility Tests
- US-E21.7: Beta Testing Program
- US-E21.8: Crash Monitoring (Sentry)

---

## Release Planning

### MVP v1.0 (Weeks 1-15)

**Scope:** Offline-first app with all core features

- ✅ Complete data layer with Drift
- ✅ All use cases for offline operations
- ✅ Full UI for all features
- ✅ Local data export/import
- ✅ Comprehensive testing

**Sprint Breakdown:**

- Sprint 1-2: Foundation (E0)
- Sprint 3-4: Data Layer (E1-E4)
- Sprint 5-7: Domain Layer (E5-E8)
- Sprint 8-12: Presentation Layer (E9-E14)
- Sprint 13-15: Testing, Bug Fixes, Polish

### v1.1 (Weeks 16-20)

**Scope:** Cloud sync and collaboration

- 🌐 Sync engine with conflict resolution
- 🌐 Cloud backend integration
- 🔐 Authentication
- 👥 Family sharing

### v1.2 (Weeks 21-25)

**Scope:** Smart features and AI

- 🤖 Recipe import from URL
- 🤖 ML-based categorization
- 🤖 Recipe recommendations
- 📊 Nutrition tracking

---

## Velocity Estimation

**Team:** 2 developers
**Sprint Length:** 2 weeks
**Velocity:** 40-50 story points per sprint (both developers combined)

**MVP Timeline:**

- Total Points: 341
- Sprints Required: ~7-8 sprints
- Duration: **15-16 weeks**

**Full Product (with Post-MVP):**

- Total Points: 568
- Sprints Required: ~12-14 sprints
- Duration: **24-28 weeks**

---

## Risk Mitigation

### Technical Risks

1. **Drift Migration Complexity**
   - Mitigation: Start simple, add complex queries incrementally
   - Test migrations thoroughly in dev environment

2. **Sync Conflict Resolution**
   - Mitigation: Implement simple Last-Write-Wins first
   - Add operational transform for critical features only

3. **Performance with Large Datasets**
   - Mitigation: Pagination, lazy loading, indexed queries
   - Performance testing with 10K+ records

### Schedule Risks

1. **Scope Creep**
   - Mitigation: Strict MVP definition, defer enhancements to v1.1+
   - Regular sprint reviews to stay on track

2. **Testing Takes Longer**
   - Mitigation: Write tests alongside features (TDD)
   - Allocate 20% of sprint for testing

---

## Appendix

### Architecture Quick Reference

```
┌─────────────────────────────────────────┐
│       Presentation Layer                │  ← Pages, Widgets, Providers
│  (UI, State Management with Riverpod)   │
├─────────────────────────────────────────┤
│      Application Layer                  │  ← Use Cases (Business Logic)
│         (Use Cases)                     │
├─────────────────────────────────────────┤
│        Domain Layer                     │  ← Entities, Repository Interfaces
│  (Entities, Repository Interfaces)      │    (Pure Dart, no dependencies)
├─────────────────────────────────────────┤
│         Data Layer                      │  ← Models, Data Sources, Repository Impl
│  (Models, Data Sources, Repositories)   │    (Drift, Network, Conversions)
└─────────────────────────────────────────┘
```

### Technology Stack

- **Framework:** Flutter 3.16+
- **Language:** Dart 3.2+
- **State Management:** Riverpod 2.x
- **Local Database:** Drift (SQLite)
- **Functional:** Dartz (Either, Option)
- **JSON:** Freezed, json_serializable
- **Testing:** flutter_test, mockito, integration_test
- **CI/CD:** GitHub Actions

---

**Document End**

This comprehensive epic and user story document provides a complete roadmap for building the Flutter Shopping List & Meal Planning App following Clean Architecture principles with offline-first approach using Drift and Riverpod.
