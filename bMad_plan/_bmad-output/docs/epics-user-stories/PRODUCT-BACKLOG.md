# Product Backlog - Shopping List App

**Last Updated:** February 26, 2026  
**Total Epics:** 22 (E0-E21)  
**Architecture:** Clean Architecture (Offline-First)  
**Framework:** Flutter 3.16+, Dart 3.2+  
**Database:** Drift (SQLite)

---

## Overview

This backlog follows a phased approach aligned with Clean Architecture principles:

- **Phase 0:** Foundation & Infrastructure (Week 1-2)
- **Phase 1:** Data Layer (Week 2-4)
- **Phase 2:** Domain Layer (Week 4-7)
- **Phase 3:** Presentation Layer (Week 7-11)
- **Phase 4:** Cloud Sync & Collaboration (Week 12-17, Post-MVP)
- **Phase 5:** Performance & Polish (Week 17-20)

### Labels & Categorization

**Priority:**

- P0: Critical - MVP blocker
- P1: High - Core feature for product-market fit
- P2: Medium - Important enhancement
- P3: Low - Nice-to-have

**Size (Story Points):**

- 1 point: 1-2 hours
- 2 points: Half day
- 3 points: Full day
- 5 points: 2-3 days
- 8 points: 3-5 days
- 13 points: 1-2 weeks (needs splitting)

**Releases:**

- MVP-v1.0: Offline-First Release
- v1.1: Cloud Sync Release
- v1.2: Smart Features Release

---

## PHASE 0: Foundation & Infrastructure

**Epic E0: Foundation & Infrastructure**  
7 stories • 34 points • Week 1-2

### US-E0.1: Project Setup with Clean Architecture

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want to set up Flutter project with Clean Architecture structure so that code is maintainable, testable, and scalable.

**Acceptance Criteria:**

- [ ] Flutter project initialized (3.16+, Dart 3.2+)
- [ ] Clean Architecture folder structure created (domain/data/presentation)
- [ ] Feature-based modules created (shopping, recipes, meal_planning, pantry)
- [ ] Core shared modules configured
- [ ] Git repository initialized with `.gitignore`
- [ ] README with architecture overview
- [ ] All dependencies configured in `pubspec.yaml`

**Folder Structure:**

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── database/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── utils/
│   ├── theme/
│   └── providers/
├── features/
│   ├── shopping/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── recipes/
│   ├── meal_planning/
│   ├── pantry/
│   └── sync/
└── shared/
```

**Dependencies:** None

---

### US-E0.2: Drift Database Configuration & Base Tables

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want to configure Drift database with migration support so that we have type-safe, reactive SQLite storage.

**Acceptance Criteria:**

- [ ] Drift database class created (`AppDatabase`)
- [ ] Database initialization configured with versioning
- [ ] Migration strategy implemented
- [ ] Sync queue table created for future cloud sync
- [ ] Database provider configured in Riverpod
- [ ] Development database populated with sample data
- [ ] Database inspector tool integrated (for debugging)

**Testing:**

- [ ] Unit test: Database initializes successfully
- [ ] Unit test: Migration strategy executes without errors
- [ ] Integration test: CRUD operations on test table

**Dependencies:** US-E0.1

---

### US-E0.3: Error Handling & Result Pattern

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want to implement consistent error handling with Result type so that errors are handled predictably across all layers.

**Acceptance Criteria:**

- [ ] `Failure` base class and subtypes created (DatabaseFailure, ValidationFailure, NetworkFailure, etc.)
- [ ] `Result<T>` type alias from dartz configured
- [ ] Exception types defined
- [ ] Error messages centralized
- [ ] Result pattern used in all repository interfaces
- [ ] Documentation for error handling patterns

**Implementation:**

- Use dartz `Either<Failure, T>` for all repository returns
- Exceptions thrown in data layer, converted to Failures in repository layer
- UI layer only handles Failures, never catches exceptions

**Testing:**

- [ ] Unit test: Each Failure type created correctly
- [ ] Unit test: Failure equality comparison works
- [ ] Unit test: Exception to Failure conversion

**Dependencies:** US-E0.1

---

### US-E0.4: Network Info & Connectivity Check

**Priority:** P0 | **Size:** 2 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want to check network connectivity reliably so that offline-first logic knows when to attempt sync.

**Acceptance Criteria:**

- [ ] `NetworkInfo` interface created
- [ ] Implementation using `connectivity_plus` package
- [ ] Connectivity stream for reactive checks
- [ ] Riverpod provider configured
- [ ] Works on iOS and Android

**Testing:**

- [ ] Unit test: `isConnected` returns correct status
- [ ] Unit test: Stream emits connectivity changes
- [ ] Mock `Connectivity` in tests

**Dependencies:** US-E0.1

---

### US-E0.5: Core Utilities & Extensions

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want reusable utilities and extensions so that common operations are DRY and consistent.

**Acceptance Criteria:**

- [ ] Date formatting utilities (`AppDateUtils`)
- [ ] String validators (email, non-empty, etc.)
- [ ] Number formatters (fractions for recipes)
- [ ] Context extensions for theming
- [ ] String extensions (capitalize, titleCase, etc.)
- [ ] Duration formatters

**Testing:**

- [ ] Unit test: All date formatting functions
- [ ] Unit test: All validators with edge cases
- [ ] Unit test: String extensions

**Dependencies:** US-E0.1

---

### US-E0.6: App Theme & Design System

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

**Description:**  
As a developer, I want app-wide theme with Material Design 3 so that UI is consistent and follows design guidelines.

**Acceptance Criteria:**

- [ ] Material Design 3 theme configured
- [ ] Light and dark themes defined
- [ ] Custom color palette matching brand
- [ ] Typography scale configured
- [ ] Spacing constants defined (AppSpacing)
- [ ] Border radius constants (AppBorderRadius)
- [ ] Theme provider for switching

**Testing:**

- [ ] Widget test: Theme applies correctly
- [ ] Visual regression test for components

**Dependencies:** US-E0.1

---

### US-E0.7: CI/CD Pipeline Setup

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Infrastructure

**Description:**  
As a developer, I want automated CI/CD pipeline so that code quality is maintained and builds are automated.

**Acceptance Criteria:**

- [ ] GitHub Actions workflow configured
- [ ] Automated linting on PR
- [ ] Automated tests on PR
- [ ] Build verification for iOS and Android
- [ ] Code coverage reporting
- [ ] Automated changelog generation

**Implementation:**  
Create `.github/workflows/main.yml` with jobs:

- Analyze & Lint
- Unit & Widget Tests
- Build Android APK
- Build iOS (No Signing)

**Dependencies:** US-E0.1, US-E0.2

---

## PHASE 1: Data Layer

### Epic E1: Recipe Data Layer

**6 stories • 26 points • Week 2-3**

#### US-E1.1: Recipe Domain Entities

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Description:**  
As a developer, I want to define core Recipe and Ingredient domain entities so that business logic has clear data structures.

**Acceptance Criteria:**

- [ ] `Recipe` entity class created with all fields
- [ ] `Ingredient` value object created
- [ ] Business logic methods implemented (scale servings, hasIngredient, etc.)
- [ ] Equatable for value comparison
- [ ] Immutable with `copyWith` methods
- [ ] Zero external dependencies (pure Dart)

**Testing:**

- [ ] Unit test: `Recipe.scaleServings` with various factors
- [ ] Unit test: `Recipe.hasIngredient` search
- [ ] Unit test: `Ingredient.scale` calculations
- [ ] Unit test: Equatable comparison works

**Dependencies:** US-E0.1

---

#### US-E1.2: Recipe Drift Table & Model

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want to create Drift table for recipes with JSON serialization so that recipes can be persisted in SQLite.

**Acceptance Criteria:**

- [ ] Drift `Recipes` table created with all fields
- [ ] JSON converter for ingredients list
- [ ] JSON converter for instructions/tags arrays
- [ ] `RecipeModel` with freezed for serialization
- [ ] Conversion between `Recipe` entity and `RecipeModel`
- [ ] Sync metadata fields (isSynced, syncVersion)
- [ ] Soft delete support (isDeleted flag)

**Testing:**

- [ ] Unit test: RecipeModel.fromJson/toJson
- [ ] Unit test: RecipeModel.fromEntity/toEntity conversions
- [ ] Unit test: JSON serialization of ingredients
- [ ] Integration test: Save/retrieve recipe from database

**Dependencies:** US-E0.2, US-E1.1

---

#### US-E1.3: Recipe Local Data Source

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want to implement recipe local data source using Drift so that recipes can be stored and queried efficiently.

**Acceptance Criteria:**

- [ ] `RecipeLocalDataSource` interface defined
- [ ] Implementation with Drift queries
- [ ] CRUD operations (Create, Read, Update, Delete)
- [ ] Search by title/tags
- [ ] Filter by ingredients
- [ ] Stream queries for reactive UI
- [ ] Exception handling

**Testing:**

- [ ] Unit test: Save recipe and retrieve by ID
- [ ] Unit test: Delete recipe (soft delete)
- [ ] Unit test: Search recipes by title
- [ ] Unit test: Filter by tags
- [ ] Unit test: Watch stream emits updates

**Dependencies:** US-E1.2

---

#### US-E1.4: Recipe Repository Interface

**Priority:** P0 | **Size:** 2 | **Type:** Feature | **Layer:** Domain

**Description:**  
As a developer, I want to define Recipe repository interface so that domain layer is decoupled from data implementation.

**Acceptance Criteria:**

- [ ] Repository interface in domain layer
- [ ] All operations return `Either<Failure, T>`
- [ ] Stream methods for reactive queries
- [ ] No implementation details (pure abstraction)
- [ ] Clear method documentation

**Dependencies:** US-E1.1, US-E0.3

---

#### US-E1.5: Recipe Repository Implementation

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want to implement Recipe repository with offline-first logic so that domain layer can access recipes through clean interface.

**Acceptance Criteria:**

- [ ] Implementation of `RecipeRepository` interface
- [ ] Delegates to local data source (MVP - offline only)
- [ ] Converts exceptions to Failures
- [ ] Converts models to entities
- [ ] Post-MVP: Add network check and sync queue
- [ ] Unit tests with mocked data source

**Testing:**

- [ ] Unit test: getAllRecipes success case
- [ ] Unit test: getAllRecipes database failure
- [ ] Unit test: getRecipeById not found
- [ ] Unit test: saveRecipe success
- [ ] Unit test: deleteRecipe success
- [ ] Unit test: searchRecipes with query
- [ ] Mock `RecipeLocalDataSource` in tests

**Dependencies:** US-E1.3, US-E1.4

---

#### US-E1.6: Recipe Data Layer Providers

**Priority:** P0 | **Size:** 2 | **Type:** Technical | **Layer:** Data

**Description:**  
As a developer, I want to configure Riverpod providers for recipe data layer so that dependencies are injected consistently.

**Acceptance Criteria:**

- [ ] Data source provider created
- [ ] Repository provider created
- [ ] Providers use core database provider
- [ ] Proper disposal of resources
- [ ] All providers tested

**Testing:**

- [ ] Unit test: Providers return correct instances
- [ ] Integration test: Repository works through providers

**Dependencies:** US-E1.5

---

### Epic E2: Shopping List Data Layer

**5 stories • 21 points • Week 3**

#### US-E2.1: Shopping List Domain Entities

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Description:**  
As a developer, I want to define ShoppingList and ShoppingItem entities so that shopping list business logic has clear data structures.

**Acceptance Criteria:**

- [ ] `ShoppingList` entity class created
- [ ] `ShoppingItem` entity class created
- [ ] Business methods (addItem, removeItem, toggleChecked, etc.)
- [ ] Calculation methods (totalItems, checkedItems, progress)
- [ ] Equatable for value comparison
- [ ] Immutable with `copyWith`

**Dependencies:** US-E0.1

---

#### US-E2.2: Shopping List Drift Tables & Models

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want Drift tables for shopping lists and items so that they can be persisted.

**Acceptance Criteria:**

- [ ] `ShoppingLists` table with metadata
- [ ] `ShoppingItems` table with foreign key
- [ ] Freezed models for serialization
- [ ] Entity/model conversions
- [ ] Sync metadata fields
- [ ] Soft delete support

**Dependencies:** US-E0.2, US-E2.1

---

#### US-E2.3: Shopping List Local Data Source

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want local data source for shopping lists with Drift queries.

**Acceptance Criteria:**

- [ ] CRUD operations for lists and items
- [ ] Query lists with items (JOIN)
- [ ] Filter by status (active/archived)
- [ ] Stream queries for reactive UI
- [ ] Batch operations (add multiple items)

**Dependencies:** US-E2.2

---

#### US-E2.4: Shopping List Repository Interface & Implementation

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain/Data

**Description:**  
As a developer, I want shopping list repository with offline-first logic.

**Acceptance Criteria:**

- [ ] Repository interface in domain
- [ ] Implementation delegates to local data source
- [ ] Exception to Failure conversion
- [ ] Model to entity conversion
- [ ] Stream methods for reactive queries

**Dependencies:** US-E2.3

---

#### US-E2.5: Shopping List Data Layer Providers

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Data

**Description:**  
As a developer, I want Riverpod providers for shopping list data layer.

**Acceptance Criteria:**

- [ ] Data source provider
- [ ] Repository provider
- [ ] All providers tested

**Dependencies:** US-E2.4

---

### Epic E3: Meal Plan Data Layer

**5 stories • 20 points • Week 3-4**

#### US-E3.1: Meal Plan Domain Entities

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Description:**  
As a developer, I want MealPlan and PlannedMeal entities for meal planning logic.

**Acceptance Criteria:**

- [ ] `MealPlan` entity with date range
- [ ] `PlannedMeal` entity with meal type
- [ ] Business methods (addMeal, removeMeal, getMealsForDate)
- [ ] Date range calculations
- [ ] Equatable and immutable

**Dependencies:** US-E0.1, US-E1.1

---

#### US-E3.2: Meal Plan Drift Tables & Models

**Priority:** P0 | **Size:** 4 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want Drift tables for meal plans.

**Acceptance Criteria:**

- [ ] `MealPlans` table
- [ ] `PlannedMeals` table with foreign keys to recipes
- [ ] Freezed models
- [ ] Entity/model conversions
- [ ] Sync metadata

**Dependencies:** US-E0.2, US-E3.1

---

#### US-E3.3: Meal Plan Local Data Source

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want local data source for meal plans.

**Acceptance Criteria:**

- [ ] CRUD operations
- [ ] Query by date range
- [ ] JOIN queries with recipes
- [ ] Stream queries

**Dependencies:** US-E3.2

---

#### US-E3.4: Meal Plan Repository Interface & Implementation

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain/Data

**Description:**  
As a developer, I want meal plan repository.

**Acceptance Criteria:**

- [ ] Repository interface
- [ ] Implementation with offline logic
- [ ] Exception/Failure conversion
- [ ] Model/entity conversion

**Dependencies:** US-E3.3

---

#### US-E3.5: Meal Plan Data Layer Providers

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Data

**Description:**  
As a developer, I want Riverpod providers for meal plan data layer.

**Dependencies:** US-E3.4

---

### Epic E4: Pantry Data Layer

**5 stories • 19 points • Week 4**

#### US-E4.1: Pantry Item Domain Entity

**Priority:** P1 | **Size:** 2 | **Type:** Feature | **Layer:** Domain

**Description:**  
As a developer, I want PantryItem entity for pantry inventory logic.

**Acceptance Criteria:**

- [ ] `PantryItem` entity with expiration tracking
- [ ] Business methods (isExpired, isExpiringSoon, hasStock)
- [ ] Equatable and immutable

**Dependencies:** US-E0.1

---

#### US-E4.2: Pantry Drift Table & Model

**Priority:** P1 | **Size:** 4 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want Drift table for pantry items.

**Acceptance Criteria:**

- [ ] `PantryItems` table
- [ ] Freezed model
- [ ] Entity/model conversions
- [ ] Sync metadata

**Dependencies:** US-E0.2, US-E4.1

---

#### US-E4.3: Pantry Local Data Source

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Data

**Description:**  
As a developer, I want local data source for pantry.

**Acceptance Criteria:**

- [ ] CRUD operations
- [ ] Filter by category
- [ ] Search by name
- [ ] Query expiring items
- [ ] Stream queries

**Dependencies:** US-E4.2

---

#### US-E4.4: Pantry Repository Interface & Implementation

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain/Data

**Description:**  
As a developer, I want pantry repository.

**Acceptance Criteria:**

- [ ] Repository interface
- [ ] Implementation
- [ ] Exception/Failure conversion

**Dependencies:** US-E4.3

---

#### US-E4.5: Pantry Data Layer Providers

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Data

**Description:**  
As a developer, I want Riverpod providers for pantry data layer.

**Dependencies:** US-E4.4

---

## PHASE 2: Domain Layer (Use Cases)

### Epic E5: Recipe Use Cases

**7 stories • 28 points • Week 4-5**

All use cases follow the pattern:

- Input validation
- Repository interaction
- Business logic orchestration
- Return `Either<Failure, T>`

#### US-E5.1: Get All Recipes Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.2: Get Recipe by ID Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.3: Save Recipe Use Case

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.4: Delete Recipe Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.5: Search Recipes Use Case

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.6: Scale Recipe Servings Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5

---

#### US-E5.7: Import Recipe from URL Use Case

**Priority:** P1 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E1.5, US-E0.4

---

### Epic E6: Shopping List Use Cases

**6 stories • 24 points • Week 5-6**

#### US-E6.1: Get Shopping Lists Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E2.4

---

#### US-E6.2: Create Shopping List Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E2.4

---

#### US-E6.3: Add Items to Shopping List Use Case

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E2.4

---

#### US-E6.4: Toggle Item Checked Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E2.4

---

#### US-E6.5: Generate Shopping List from Meal Plan Use Case

**Priority:** P0 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

**Description:**  
Complex use case that aggregates ingredients from planned meals and generates a shopping list.

**Dependencies:** US-E2.4, US-E3.4, US-E1.5

---

#### US-E6.6: Smart Categorization Use Case

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Description:**  
Auto-categorize shopping items by type (produce, dairy, etc.).

**Dependencies:** US-E2.4

---

### Epic E7: Meal Planning Use Cases

**6 stories • 26 points • Week 6**

#### US-E7.1: Get Meal Plans Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E3.4

---

#### US-E7.2: Create Meal Plan Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E3.4

---

#### US-E7.3: Add Meal to Plan Use Case

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E3.4, US-E1.5

---

#### US-E7.4: Remove Meal from Plan Use Case

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E3.4

---

#### US-E7.5: Get Meals for Date Range Use Case

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E3.4

---

#### US-E7.6: Suggest Meals Based on Pantry Use Case

**Priority:** P1 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

**Description:**  
Smart meal suggestions based on available pantry inventory.

**Dependencies:** US-E3.4, US-E4.4, US-E1.5

---

### Epic E8: Pantry Use Cases

**5 stories • 21 points • Week 6-7**

#### US-E8.1: Get Pantry Items Use Case

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E4.4

---

#### US-E8.2: Add Pantry Item Use Case

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E4.4

---

#### US-E8.3: Update Pantry Stock Use Case

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E4.4

---

#### US-E8.4: Get Expiring Items Use Case

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

**Dependencies:** US-E4.4

---

#### US-E8.5: Auto-Consume from Pantry Use Case

**Priority:** P1 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

**Description:**  
Automatically reduce pantry stock when meal plan items are checked off.

**Dependencies:** US-E4.4, US-E3.4

---

## PHASE 3: Presentation Layer (UI)

### Epic E9: Core UI Components & Theme

**6 stories • 22 points • Week 7**

#### US-E9.1: Reusable Form Widgets

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

**Description:**  
Create reusable form widgets (text fields, dropdowns, chips, etc.).

**Dependencies:** US-E0.6

---

#### US-E9.2: Card Components

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Description:**  
Recipe card, shopping list card, meal plan card components.

**Dependencies:** US-E0.6

---

#### US-E9.3: Bottom Navigation & App Bar

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E0.6

---

#### US-E9.4: Loading & Error States

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E0.6, US-E0.3

---

#### US-E9.5: Empty States

**Priority:** P0 | **Size:** 2 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E0.6

---

#### US-E9.6: Dialogs & Bottom Sheets

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E0.6

---

### Epic E10: Shopping List UI

**6 stories • 24 points • Week 7-8**

#### US-E10.1: Shopping List Home Screen

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Description:**  
List all shopping lists with create/delete actions.

**Dependencies:** US-E6.1, US-E9.1

---

#### US-E10.2: Shopping List Detail Screen

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Description:**  
Show items, allow check/uncheck, add/remove items.

**Dependencies:** US-E6.3, US-E6.4, US-E9.1

---

#### US-E10.3: Add Item Dialog

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E6.3, US-E9.6

---

#### US-E10.4: Shopping List State Management (Riverpod)

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

**Description:**  
StateNotifierProviders for shopping lists with async loading states.

**Dependencies:** US-E6.1, US-E6.2, US-E6.3, US-E6.4

---

#### US-E10.5: Swipe Actions & Gestures

**Priority:** P1 | **Size:** 3 | **Type:** Enhancement | **Layer:** Presentation

**Dependencies:** US-E10.2

---

#### US-E10.6: Generate from Meal Plan Button

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E6.5, US-E10.1

---

### Epic E11: Recipe Management UI

**7 stories • 29 points • Week 8-9**

#### US-E11.1: Recipe List Screen

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.1, US-E9.2

---

#### US-E11.2: Recipe Detail Screen

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.2, US-E9.1

---

#### US-E11.3: Add/Edit Recipe Form

**Priority:** P0 | **Size:** 8 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.3, US-E9.1

---

#### US-E11.4: Recipe Search & Filters

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.5, US-E9.1

---

#### US-E11.5: Recipe State Management

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E5.1, US-E5.2, US-E5.3

---

#### US-E11.6: Servings Scaler Widget

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.6, US-E11.2

---

#### US-E11.7: Import Recipe Dialog

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E5.7, US-E9.6

---

### Epic E12: Meal Planning UI

**6 stories • 26 points • Week 9-10**

#### US-E12.1: Meal Plan Calendar View

**Priority:** P0 | **Size:** 8 | **Type:** Feature | **Layer:** Presentation

**Description:**  
Weekly/monthly calendar showing planned meals.

**Dependencies:** US-E7.1, US-E7.5, US-E9.1

---

#### US-E12.2: Add Meal to Plan Dialog

**Priority:** P0 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E7.3, US-E9.6

---

#### US-E12.3: Meal Plan State Management

**Priority:** P0 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E7.1, US-E7.2, US-E7.3

---

#### US-E12.4: Drag & Drop Meal Rescheduling

**Priority:** P1 | **Size:** 5 | **Type:** Enhancement | **Layer:** Presentation

**Dependencies:** US-E12.1

---

#### US-E12.5: Smart Meal Suggestions Widget

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E7.6, US-E12.2

---

#### US-E12.6: Week Navigation & Date Picker

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E12.1

---

### Epic E13: Pantry Inventory UI

**5 stories • 21 points • Week 10**

#### US-E13.1: Pantry List Screen

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E8.1, US-E9.2

---

#### US-E13.2: Add/Edit Pantry Item Form

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E8.2, US-E9.1

---

#### US-E13.3: Expiring Items Widget

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E8.4, US-E13.1

---

#### US-E13.4: Pantry State Management

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

**Dependencies:** US-E8.1, US-E8.2, US-E8.3

---

#### US-E13.5: Quick Stock Update Gestures

**Priority:** P1 | **Size:** 3 | **Type:** Enhancement | **Layer:** Presentation

**Dependencies:** US-E8.3, US-E13.1

---

### Epic E14: Settings & Data Management

**5 stories • 20 points • Week 11**

#### US-E14.1: Settings Screen

**Priority:** P0 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

**Description:**  
Theme, units, notifications, account settings.

**Dependencies:** US-E0.6

---

#### US-E14.2: Export Data to JSON

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E1.5, US-E2.4, US-E3.4, US-E4.4

---

#### US-E14.3: Import Data from JSON

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E1.5, US-E2.4, US-E3.4, US-E4.4

---

#### US-E14.4: Clear All Data

**Priority:** P1 | **Size:** 2 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E0.2

---

#### US-E14.5: About & Help Screen

**Priority:** P1 | **Size:** 2 | **Type:** Feature | **Layer:** Presentation

**Dependencies:** US-E9.1

---

## PHASE 4: Cloud Sync & Collaboration (Post-MVP)

### Epic E15: Sync Engine & Queue

**7 stories • 35 points • Week 12-13 (Post-MVP)**

#### US-E15.1: Sync Queue Data Model

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E15.2: Conflict Resolution Strategy

**Priority:** P1 | **Size:** 8 | **Type:** Technical | **Layer:** Domain

---

#### US-E15.3: Sync Status Tracking

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Domain

---

#### US-E15.4: Background Sync Worker

**Priority:** P1 | **Size:** 8 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E15.5: Sync UI Indicators

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

---

#### US-E15.6: Manual Sync Trigger

**Priority:** P1 | **Size:** 2 | **Type:** Feature | **Layer:** Presentation

---

#### US-E15.7: Offline Queue Management

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

### Epic E16: Cloud Backend Integration

**8 stories • 40 points • Week 13-15 (Post-MVP)**

Backend integration with Firebase/Supabase/custom API.

#### US-E16.1: Remote Data Source Interfaces

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E16.2: Recipe Remote Data Source

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E16.3: Shopping List Remote Data Source

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E16.4: Meal Plan Remote Data Source

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E16.5: Pantry Remote Data Source

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E16.6: Repository Sync Logic

**Priority:** P1 | **Size:** 8 | **Type:** Technical | **Layer:** Data

**Description:**  
Update repositories to sync local + remote data.

---

#### US-E16.7: API Error Handling

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Data

---

#### US-E16.8: Network Retry Logic

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

---

### Epic E17: Authentication & Security

**6 stories • 29 points • Week 15-16 (Post-MVP)**

#### US-E17.1: User Authentication (Email/Password)

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Infrastructure

---

#### US-E17.2: Social Login (Google/Apple)

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Infrastructure

---

#### US-E17.3: User Profile Management

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

---

#### US-E17.4: Secure Token Storage

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E17.5: Login/Register UI

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

---

#### US-E17.6: Password Reset Flow

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

---

### Epic E18: Family & Collaboration

**6 stories • 27 points • Week 16-17 (Post-MVP)**

#### US-E18.1: Family Group Entity

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Domain

---

#### US-E18.2: Invite Family Members

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

---

#### US-E18.3: Shared Shopping Lists

**Priority:** P1 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

---

#### US-E18.4: Real-Time Sync for Shared Data

**Priority:** P1 | **Size:** 8 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E18.5: Family Settings UI

**Priority:** P1 | **Size:** 3 | **Type:** Feature | **Layer:** Presentation

---

#### US-E18.6: Activity Feed (Who checked what)

**Priority:** P2 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

---

## PHASE 5: Performance & Polish

### Epic E19: Performance Optimization

**6 stories • 26 points • Week 17-18**

#### US-E19.1: Database Query Optimization

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Data

---

#### US-E19.2: Lazy Loading & Pagination

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

---

#### US-E19.3: Image Caching Strategy

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E19.4: Build Time Optimization

**Priority:** P2 | **Size:** 3 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E19.5: Memory Profiling & Fixes

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Infrastructure

---

#### US-E19.6: Frame Rate Optimization

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

---

### Epic E20: Smart Features & AI

**7 stories • 38 points • Week 18-20 (Post-MVP)**

#### US-E20.1: ML-Based Recipe Recommendations

**Priority:** P2 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

---

#### US-E20.2: Ingredient Substitution Suggestions

**Priority:** P2 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

---

#### US-E20.3: Smart Meal Plan Generation

**Priority:** P2 | **Size:** 8 | **Type:** Feature | **Layer:** Domain

---

#### US-E20.4: Voice Input for Shopping Items

**Priority:** P2 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

---

#### US-E20.5: Barcode Scanning for Pantry

**Priority:** P2 | **Size:** 5 | **Type:** Feature | **Layer:** Presentation

---

#### US-E20.6: Nutrition Analysis

**Priority:** P2 | **Size:** 5 | **Type:** Feature | **Layer:** Domain

---

#### US-E20.7: Recipe Photo Recognition

**Priority:** P3 | **Size:** 8 | **Type:** Feature | **Layer:** Infrastructure

---

### Epic E21: Testing & Quality Assurance

**8 stories • 32 points • Continuous**

#### US-E21.1: Unit Test Coverage (80%+)

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** All

---

#### US-E21.2: Widget Test Coverage

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** Presentation

---

#### US-E21.3: Integration Tests

**Priority:** P0 | **Size:** 5 | **Type:** Technical | **Layer:** All

---

#### US-E21.4: E2E Tests (Key Flows)

**Priority:** P1 | **Size:** 8 | **Type:** Technical | **Layer:** All

---

#### US-E21.5: Performance Testing

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** All

---

#### US-E21.6: Accessibility Testing

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

---

#### US-E21.7: Security Audit

**Priority:** P1 | **Size:** 5 | **Type:** Technical | **Layer:** All

---

#### US-E21.8: Usability Testing

**Priority:** P1 | **Size:** 3 | **Type:** Technical | **Layer:** Presentation

---

## Summary Statistics

| Phase                 | Epics       | Stories | Total Points | Duration              |
| --------------------- | ----------- | ------- | ------------ | --------------------- |
| Phase 0: Foundation   | 1 (E0)      | 7       | 34           | Week 1-2              |
| Phase 1: Data Layer   | 4 (E1-E4)   | 21      | 86           | Week 2-4              |
| Phase 2: Domain Layer | 4 (E5-E8)   | 24      | 99           | Week 4-7              |
| Phase 3: Presentation | 6 (E9-E14)  | 35      | 142          | Week 7-11             |
| **MVP TOTAL**         | **15**      | **87**  | **361**      | **11 weeks**          |
| Phase 4: Cloud Sync   | 4 (E15-E18) | 27      | 131          | Week 12-17 (Post-MVP) |
| Phase 5: Polish       | 3 (E19-E21) | 21      | 96           | Week 17-20            |
| **FULL TOTAL**        | **22**      | **135** | **588**      | **20 weeks**          |

---

## Notes

1. **MVP Focus:** Epics E0-E14 constitute the Minimum Viable Product (offline-first)
2. **Dependencies:** Always complete dependencies before starting a story
3. **Testing:** Unit tests are required for all stories before marking complete
4. **Clean Architecture:** Maintain strict layer separation (domain → data → presentation)
5. **Offline-First:** All MVP features work without internet connection
6. **Post-MVP:** Cloud sync, collaboration, and AI features are enhancements

---

**This backlog serves as the single source of truth for development planning.**
