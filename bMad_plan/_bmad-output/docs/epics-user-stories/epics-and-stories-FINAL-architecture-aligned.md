# Epics and User Stories  Vertical Slice Approach

## Flutter Shopping List & Meal Planning App

**Document Version:** 5.0
**Date:** March 3, 2026
**Author:** BMad Team
**Status:** Development Ready  Vertical Slice Redesign
**Approach:** Clean Architecture + Offline-First + Riverpod + Drift + **Vertical Slices**
**Related Documents:** [Architecture](architecture-shopping-list-app.md), [PRD](prd-shopping-list-app.md), [UX Design](ux-design-shopping-list-app.md)

---

## Why Vertical Slices?

The previous document organised work into **horizontal layers** (Data Layer  Domain Layer  Presentation Layer). Each layer epic had to be completed before the next, and no story produced a UI-testable result.

This revision adopts **vertical slices**: every story cuts through **all layers** (Database  Domain Entity  Repository  Use Case  State Provider  UI Page) for a single feature or workflow. The result is that each completed story can be:

-  **Demo'd in the running app** immediately
-  **Tested from the UI** (widget tests, integration tests, manual QA)
-  **Integrated end-to-end** without waiting for other layers

### Vertical Slice Anatomy

Every story follows this delivery checklist:

```
1. Drift Table / Migration (if new entity)
2. Domain Entity + business methods
3. Repository Interface (domain layer)
4. Data Model (freezed / drift DAO)
5. Local Data Source (Drift queries)
6. Repository Implementation
7. Riverpod Providers (all layers wired)
8. Use Case(s) for this slice
9. State Notifier / AsyncNotifier (presentation)
10. UI Page(s) + Widgets
11. Tests: unit + widget + integration
```

---

## Technical Architecture Quick Reference

```

       Presentation Layer                   Pages, Widgets, Riverpod StateNotifiers

      Application Layer (Use Cases)         Business operations, validation

        Domain Layer                        Entities, Repository Interfaces
    (pure Dart, zero dependencies)       

         Data Layer                         Drift tables, Models, DataSources, Repo Impl

        Each story delivers ALL four layers
```

---

## Story Point Scale

| Points | Effort          |
|--------|-----------------|
| 1      | 12 hours       |
| 2      | Half day        |
| 3      | Full day        |
| 5      | 23 days        |
| 8      | 35 days        |
| 13     | Needs splitting |

## Priority Levels

| Level | Meaning                         |
|-------|---------------------------------|
| P0    | MVP blocker                     |
| P1    | Core feature for product fit    |
| P2    | Important enhancement           |
| P3    | Nice-to-have, future release    |

---

## Current Implementation Status (March 2026)

| Area                          | Status                                                                          |
|-------------------------------|---------------------------------------------------------------------------------|
| E0  Foundation               |  ~90% Done  skip re-implementation                                           |
| Product Category (data+UI)    |  Partial  table, entity, repo, pages exist; no use cases; no Riverpod wiring |
| Product (data+UI)             |  Partial  table, entity, repo, pages exist; no use cases; no Riverpod wiring |
| Recipes (data+partial UI)     |  Partial  table, entity, repo, list UI exist; no use cases                  |
| Meal Planning                 |  UI skeleton only  no data layer yet                                         |
| Shopping Lists                |  Not started                                                                   |
| Pantry                        |  Not started                                                                   |

---

## Epic Summary

| Epic | Name                            | Stories | Points | Priority | Sprint     |
|------|---------------------------------|---------|--------|----------|------------|
| E0   | Foundation & Infrastructure     | 7       | 34     | P0       |  Done    |
| E1   | App Shell & Navigation          | 2       | 7      | P0       | Sprint 1   |
| E2   | Product Category Feature        | 3       | 14     | P0       | Sprint 1   |
| E3   | Product Feature                 | 3       | 15     | P0       | Sprint 2   |
| E4   | Shopping List Feature           | 5       | 24     | P0       | Sprint 23 |
| E5   | Recipe Management Feature       | 5       | 26     | P0       | Sprint 34 |
| E6   | Meal Planning Feature           | 4       | 22     | P0       | Sprint 45 |
| E7   | Pantry Inventory Feature        | 3       | 16     | P0       | Sprint 5   |
| E8   | Settings & Data Management      | 4       | 17     | P0       | Sprint 6   |
| E9   | Sync Engine & Queue             | 7       | 35     | P1       | Sprint 78 |
| E10  | Cloud Backend Integration       | 8       | 40     | P1       | Sprint 810|
| E11  | Authentication & Security       | 6       | 29     | P1       | Sprint 1011|
| E12  | Family & Collaboration          | 6       | 27     | P2       | Sprint 1112|
| E13  | Smart Features & AI             | 7       | 38     | P2       | Sprint 1214|
| E14  | Performance & Optimisation      | 6       | 26     | P1       | Sprint 1415|
| E15  | Testing & Quality Assurance     | 8       | 32     | P0       | Ongoing    |

**MVP (E1E8):** ~141 story points  67 sprints (2 devs, 2-week sprints)

---

## EPIC E0: Foundation & Infrastructure ( NEARLY COMPLETE  SKIP)

Core architecture, Drift setup, error handling, theme, utils, and CI/CD are already implemented.
Complete any remaining gaps (e.g., CI/CD pipeline) as minor tasks, not new stories.
Refer to the original document version 4.0 for E0 story details if needed.

---

## EPIC E1: App Shell & Core Navigation

**Goal:** A running, navigable app shell with bottom navigation and reusable core UI components. All subsequent epics plug UI pages into this shell.

**Story Count:** 2 | **Total Points:** 7 | **Priority:** P0

---

### US-E1.1: App Shell with Bottom Navigation

**As a** user
**I want to** see a persistent navigation bar at the bottom of the app
**So that** I can switch between Shopping, Recipes, Meal Planning, Pantry, and Settings at any time

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** E0

**Vertical Slice Deliverables:**

| Layer   | Deliverable                                                                   |
|---------|-------------------------------------------------------------------------------|
| Domain  | `AppRoute` enum: `shopping`, `recipes`, `mealPlanning`, `pantry`, `settings` |
| State   | `NavigationNotifier` (Riverpod `StateNotifier`) holding current route         |
| UI      | `MainShell` widget with `NavigationBar` + `IndexedStack` children             |
| Routes  | GoRouter wiring all top-level pages                                           |
| Tests   | Widget test: tapping each nav item shows correct page                         |

**Acceptance Criteria:**

- [ ] Bottom navigation shows 5 tabs with icons and labels
- [ ] Active tab is highlighted
- [ ] Switching tabs preserves the state of each tab (no reload)
- [ ] Deep links to each tab work
- [ ] Works on Android, iOS, and web
- [ ] Widget test verifies navigation changes

---

### US-E1.2: Core UI Components (Empty, Error, Loading)

**As a** user
**I want to** see consistent empty states, error messages, and loading indicators
**So that** I always understand what is happening in the app

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                           |
|-------|-----------------------------------------------------------------------|
| UI    | `EmptyStateWidget(icon, title, subtitle, action?)` component          |
| UI    | `ErrorStateWidget(message, onRetry?)` component                       |
| UI    | `LoadingStateWidget` (shimmer skeleton)                               |
| UI    | `AsyncValueWidget<T>` helper that wraps Riverpod `AsyncValue`         |
| Tests | Widget tests for each component covering all states                   |

**Acceptance Criteria:**

- [ ] `AsyncValueWidget` renders loading, error, and data states correctly
- [ ] Empty state has optional call-to-action button
- [ ] Error state has optional retry button
- [ ] All components use `AppTheme` tokens (no hard-coded colours or sizes)
- [ ] Widget test covers all three states

---

## EPIC E2: Product Category Feature

**Goal:** Users can manage product categories (e.g., "Dairy", "Produce"). This is the first complete vertical slice  from Drift table through to CRUD UI.

**Story Count:** 3 | **Total Points:** 14 | **Priority:** P0

> **Note:** Table, entity, repository, and UI pages for `ProductCategory` already exist. These stories focus on **wiring everything together correctly**  adding use cases, Riverpod providers, proper state management  so the feature is fully testable end-to-end.

---

### US-E2.1: View & Create Product Categories

**As a** user
**I want to** see all my product categories and add new ones
**So that** I can organise my shopping items

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer      | Deliverable                                                                                     |
|------------|-------------------------------------------------------------------------------------------------|
| DB         | `ProductCategoryTable` (exists)  verify: `id`, `name`, `colorHex`, `iconName`, `sortOrder`, `createdAt`, `updatedAt` |
| Domain     | `ProductCategory` entity (exists)  verify `copyWith`, `Equatable`                             |
| Domain     | `IProductCategoryRepository` (exists)  verify `watchAll()`, `save()`                          |
| Data       | `ProductCategoryDataSource` (Drift DAO)  verify `watchAll()`, `insert()`                      |
| Data       | `ProductCategoryRepositoryImpl`  verify exception  Failure conversion                         |
| Use Cases  | `WatchProductCategoriesUseCase`  `Stream<Either<Failure, List<ProductCategory>>>`              |
| Use Cases  | `CreateProductCategoryUseCase(name, colorHex?, iconName?)`  validates non-empty name, generates UUID, saves |
| Providers  | `productCategoryRepositoryProvider`, `watchCategoriesProvider`, `createCategoryProvider`        |
| State      | `ProductCategoryListNotifier extends AsyncNotifier<List<ProductCategory>>`                      |
| UI         | `ProductCategoryViewPage`  list via `AsyncValueWidget` + FAB to add                           |
| UI         | `CreateCategoryBottomSheet`  text field + colour picker + save button                          |
| Tests      | Unit: `CreateProductCategoryUseCase` with empty name  `ValidationFailure`                     |
| Tests      | Unit: repository `save()` calls data source and returns entity                                  |
| Tests      | Widget: `ProductCategoryViewPage` renders 3 mocked categories                                  |
| Tests      | Integration: create category via UI  appears in list                                           |

**Acceptance Criteria:**

- [ ] Opening the Shopping tab shows category list
- [ ] Empty state shown when no categories exist, with "Add Category" action
- [ ] Tapping FAB opens `CreateCategoryBottomSheet`
- [ ] Submitting an empty name shows inline validation error (no toast)
- [ ] Created category appears at bottom of list immediately (reactive stream)
- [ ] Integration test: create  verify in list  pass

---

### US-E2.2: Edit & Delete Product Category

**As a** user
**I want to** rename or delete a product category
**So that** I can keep my categories up to date

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E2.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                              |
|-----------|------------------------------------------------------------------------------------------|
| Use Cases | `UpdateProductCategoryUseCase(id, name, colorHex?, iconName?)`  validates, updates      |
| Use Cases | `DeleteProductCategoryUseCase(id)`  checks if products use this category, warns or blocks |
| Providers | `updateCategoryProvider`, `deleteCategoryProvider`                                        |
| UI        | Swipe-to-delete on list tile (with undo snackbar, 4 seconds)                             |
| UI        | Long-press or trailing icon opens `EditCategoryBottomSheet` (pre-filled form)            |
| UI        | Confirmation dialog if category has products assigned                                     |
| Tests     | Unit: `DeleteProductCategoryUseCase` with products assigned  `ConflictFailure`          |
| Tests     | Widget: swipe tile  confirmation dialog appears                                         |
| Tests     | Integration: edit name  updated in list; delete  removed from list                    |

**Acceptance Criteria:**

- [ ] Swiping a category left reveals delete action
- [ ] Delete prompts confirmation dialog showing category name
- [ ] Deleting a category with products warns the user ("Delete anyway?")
- [ ] Deleted category disappears from list; undo snackbar shown for 4 seconds
- [ ] Tapping edit icon opens pre-filled form
- [ ] Saving updates the name and colour in the list immediately

---

### US-E2.3: Product Category Reordering

**As a** user
**I want to** drag and drop categories to reorder them
**So that** my most-used categories appear at the top

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** US-E2.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                |
|-----------|----------------------------------------------------------------------------|
| DB        | Ensure `sortOrder` column exists on `ProductCategoryTable`                 |
| Use Cases | `ReorderProductCategoriesUseCase(orderedIds)`  bulk updates `sortOrder`   |
| Providers | `reorderCategoriesProvider`                                                |
| UI        | `ReorderableListView` in `ProductCategoryViewPage` with drag handles       |
| Tests     | Unit: reorder use case assigns correct sort indices                        |
| Tests     | Widget: drag tile  list reorders visually                                 |

**Acceptance Criteria:**

- [ ] Drag handle visible on each category row
- [ ] Dragging updates order immediately (optimistic UI)
- [ ] Sort order persisted  reopening app shows same order
- [ ] Works on touch (mobile) and mouse (desktop/web)

---

## EPIC E3: Product Feature

**Goal:** Users can manage the product catalogue  individual products that belong to categories. Products are the building blocks of shopping lists and pantry entries.

**Story Count:** 3 | **Total Points:** 15 | **Priority:** P0

> **Note:** Table, entity, repository, and UI pages for `Product` already exist. Stories focus on correct wiring, use cases, and full end-to-end testability.

---

### US-E3.1: View & Create Products

**As a** user
**I want to** browse all products and add new ones with a name, unit, and category
**So that** I can build a reusable product catalogue

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E2.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                |
|-----------|--------------------------------------------------------------------------------------------|
| DB        | `ProductTable` (exists)  verify: `id`, `name`, `defaultUnit`, `categoryId` (FK), `barcode?`, `imageUrl?`, `createdAt`, `updatedAt` |
| Domain    | `Product` entity (exists)  verify business methods and `Equatable`                       |
| Domain    | `IProductRepository`  `watchAll()`, `watchByCategory(id)`, `save()`                      |
| Data      | `ProductDataSource` (Drift DAO) + `ProductRepositoryImpl`                                 |
| Use Cases | `WatchProductsUseCase`, `CreateProductUseCase(name, unit, categoryId)`                    |
| Providers | `productRepositoryProvider`, `watchProductsProvider`, `createProductProvider`             |
| State     | `ProductListNotifier extends AsyncNotifier<List<Product>>`                                |
| UI        | `ProductViewPage` (exists)  wire to Riverpod stream; products grouped by category        |
| UI        | `CreateProductBottomSheet`  name field, unit dropdown, category picker                   |
| Tests     | Unit: `CreateProductUseCase` validates non-empty name and valid `categoryId`              |
| Tests     | Widget: `ProductViewPage` renders products grouped by category                            |
| Tests     | Integration: create product  appears in correct category group                           |

**Acceptance Criteria:**

- [ ] Products grouped by category in the list
- [ ] Empty state per category group when no products exist
- [ ] FAB opens create form
- [ ] Category picker shows existing categories from E2
- [ ] Created product appears in correct group immediately (reactive stream)
- [ ] Integration test: create  verify grouping

---

### US-E3.2: Edit & Delete Product

**As a** user
**I want to** edit a product's name, unit, or category and delete products I no longer need
**So that** my product catalogue stays accurate

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                     |
|-----------|---------------------------------------------------------------------------------|
| Use Cases | `UpdateProductUseCase(id, name?, unit?, categoryId?)`                           |
| Use Cases | `DeleteProductUseCase(id)`  soft delete                                        |
| UI        | `ProductDetailPage` (exists)  wire edit/delete actions                         |
| UI        | Edit form pre-filled; save updates list reactively                               |
| UI        | Swipe-to-delete with undo snackbar                                               |
| Tests     | Unit: `UpdateProductUseCase` merges only provided fields                        |
| Tests     | Integration: edit  delete  verify state                                       |

**Acceptance Criteria:**

- [ ] Tapping a product opens detail page with edit option
- [ ] Saving changes updates the product in the list immediately
- [ ] Deleting removes the product (undo available for 4 seconds)
- [ ] If product is in an active shopping list, user sees a warning

---

### US-E3.3: Product Search & Category Filter

**As a** user
**I want to** search for products by name and filter by category
**So that** I can quickly find items in a large catalogue

**Story Points:** 6 | **Priority:** P1 | **Dependencies:** US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                   |
|-----------|-------------------------------------------------------------------------------|
| Data      | `searchProducts(query)` Drift query  case-insensitive LIKE on `name`        |
| Use Cases | `SearchProductsUseCase(query)`                                                |
| Use Cases | `FilterProductsByCategoryUseCase(categoryId?)`                                |
| State     | `ProductSearchNotifier`  `query` + `selectedCategory` + debounce 300 ms     |
| UI        | Search bar at top of `ProductViewPage`                                        |
| UI        | Category filter chips below search bar                                        |
| UI        | Results update in real time as user types                                     |
| Tests     | Unit: search use case returns correct subset                                  |
| Tests     | Widget: typing "mil" filters to "Milk"                                        |

**Acceptance Criteria:**

- [ ] Search filters products as user types (300 ms debounce)
- [ ] Category chip toggles filter on/off
- [ ] Search + category combination works correctly
- [ ] "No results" empty state shown
- [ ] Clearing search restores full list
- [ ] Widget test: type "mil"  only "Milk" visible

---

## EPIC E4: Shopping List Feature

**Goal:** Users can create and manage shopping lists, add items from the product catalogue, check off items as they shop, and track their progress.

**Story Count:** 5 | **Total Points:** 24 | **Priority:** P0

---

### US-E4.1: Shopping Lists Overview  Create & Delete Lists

**As a** user
**I want to** see all my shopping lists and create new ones
**So that** I can manage separate lists for different occasions

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                    |
|-----------|------------------------------------------------------------------------------------------------|
| DB        | `ShoppingListsTable`: `id`, `name`, `createdAt`, `updatedAt`, `isSynced`, `isDeleted`         |
| Domain    | `ShoppingList` entity: `id`, `name`, `items List<ShoppingItem>`, `createdAt`; computed `completionPercent` |
| Domain    | `IShoppingListRepository`: `watchAll()`, `save()`, `delete(id)`, `watchById(id)`              |
| Data      | `ShoppingListDataSource` (Drift DAO) + `ShoppingListRepositoryImpl`                           |
| Use Cases | `WatchShoppingListsUseCase`, `CreateShoppingListUseCase(name)`, `DeleteShoppingListUseCase(id)` |
| Providers | `shoppingListRepositoryProvider`, `shoppingListsProvider` (StreamProvider)                    |
| State     | `ShoppingListsNotifier`                                                                       |
| UI        | `ShoppingListsPage`  card per list showing name, item count, completion bar                  |
| UI        | FAB  `CreateListDialog` (single name text field)                                             |
| UI        | Long-press card  context menu: Rename / Delete                                               |
| UI        | Delete confirmation showing item count                                                        |
| Tests     | Unit: `CreateShoppingListUseCase` rejects empty name                                          |
| Tests     | Widget: list card shows completion percentage bar                                             |
| Tests     | Integration: create list  card appears; delete list  card removed                          |

**Acceptance Criteria:**

- [ ] Shopping tab shows all lists as cards
- [ ] Each card shows name, item count, and completion bar
- [ ] FAB opens inline dialog to name the new list
- [ ] New list card appears immediately
- [ ] Long-press  context menu with Rename and Delete
- [ ] Delete shows confirmation with item count; undo available for 5 seconds
- [ ] Empty state shown when no lists exist
- [ ] Integration test: create  delete  verify state

---

### US-E4.2: Add & Manage Items in a Shopping List

**As a** user
**I want to** add products to a shopping list with quantities and units
**So that** I know exactly what to buy

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E4.1, US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                    |
|-----------|------------------------------------------------------------------------------------------------|
| DB        | `ShoppingItemsTable`: `id`, `listId` (FK), `productId` (FK nullable), `name`, `quantity`, `unit`, `isChecked`, `categoryId`, `sortOrder`, `createdAt` |
| Domain    | `ShoppingItem` entity + `toggleChecked()`, `copyWith()`                                        |
| Domain    | `IShoppingListRepository` extended with add/remove/update item methods                        |
| Data      | `ShoppingItemDataSource` with JOIN queries                                                    |
| Use Cases | `AddItemToListUseCase(listId, name, qty, unit, categoryId?)`, `RemoveItemFromListUseCase(listId, itemId)`, `UpdateItemUseCase(listId, itemId, qty?, unit?)` |
| State     | `ShoppingListDetailNotifier(listId)`  streams items in real time                            |
| UI        | `ShoppingListDetailPage`  item list; FAB opens `AddItemBottomSheet`                         |
| UI        | `AddItemBottomSheet`  product catalogue picker OR free-text, quantity + unit                 |
| UI        | Swipe-to-delete item with undo                                                                |
| Tests     | Unit: `AddItemUseCase` handles product reference and free-text correctly                      |
| Tests     | Widget: `ShoppingListDetailPage` renders items from stream                                   |
| Tests     | Integration: open list  add item  item appears in list                                     |

**Acceptance Criteria:**

- [ ] Tapping a list card opens detail page
- [ ] AddItem sheet shows product catalogue picker AND free-text fallback
- [ ] Added item appears at bottom of list immediately
- [ ] Quantity and unit visible on each item row
- [ ] Swipe-left deletes item (with undo for 4 seconds)
- [ ] Integration test: add  delete  verify

---

### US-E4.3: Check Items Off While Shopping

**As a** user
**I want to** tap items to mark them as collected
**So that** I can track what I have already put in my basket

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E4.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                     |
|-----------|---------------------------------------------------------------------------------|
| Use Cases | `ToggleItemCheckedUseCase(listId, itemId)`  flips `isChecked`, updates DB     |
| State     | `ShoppingListDetailNotifier` handles optimistic toggle                          |
| UI        | Animated checkbox on each list tile (check + strikethrough text + fade)        |
| UI        | Checked items collapse to a "Done (N)" section at the bottom                   |
| UI        | App bar counter "3 / 7 items" updates live                                     |
| Tests     | Unit: toggle use case flips `isChecked`                                         |
| Tests     | Widget: tap checkbox  text is struck-through                                   |
| Tests     | Integration: check 2 of 4 items  completion bar shows 50%                     |

**Acceptance Criteria:**

- [ ] Tapping checkbox toggles checked state with smooth animation
- [ ] Checked items move to a collapsed "Done" section at the bottom
- [ ] App bar shows item counter and updates live
- [ ] Tapping a checked item unchecks it and moves it back to the main list
- [ ] Integration test: check items  verify completion %

---

### US-E4.4: Category-Grouped Shopping View

**As a** user
**I want to** see my shopping items grouped by category
**So that** I can shop efficiently by aisle

**Story Points:** 4 | **Priority:** P1 | **Dependencies:** US-E4.3

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                           |
|-----------|---------------------------------------------------------------------------------------|
| Use Cases | `GetItemsGroupedByCategoryUseCase(listId)`  `Map<String, List<ShoppingItem>>`       |
| State     | Toggle `flat` / `grouped` view mode in `ShoppingListDetailNotifier`                  |
| UI        | Segmented button (Flat / By Category) in app bar                                     |
| UI        | Grouped view: sticky section header per category                                      |
| UI        | Uncategorised items under "Other"                                                     |
| Tests     | Unit: grouping use case organises mixed-category items correctly                      |
| Tests     | Widget: grouped view renders section headers                                          |

**Acceptance Criteria:**

- [ ] Toggle in app bar switches flat  grouped views
- [ ] Grouped view shows category names as sticky section headers
- [ ] Items without a category appear under "Other"
- [ ] Checking items works identically in both views
- [ ] View preference persisted per list

---

### US-E4.5: Rename Shopping List

**As a** user
**I want to** rename a shopping list
**So that** I can keep my lists descriptively named as my needs change

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E4.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                           |
|-----------|-----------------------------------------------------------------------|
| Use Cases | `RenameShoppingListUseCase(id, newName)`  validates non-empty        |
| UI        | Rename dialog pre-filled with current name (triggered from context menu) |
| Tests     | Unit: rename use case rejects empty name                              |
| Tests     | Integration: rename  verify new name on card in overview             |

**Acceptance Criteria:**

- [ ] Rename option accessible from list card context menu
- [ ] Dialog shows current name pre-filled
- [ ] Empty name shows validation error
- [ ] Saving updates card name immediately
- [ ] Integration test: rename  verify new label on card

---

## EPIC E5: Recipe Management Feature

**Goal:** Users can create, browse, edit, and use recipes with ingredients and step-by-step instructions.

**Story Count:** 5 | **Total Points:** 26 | **Priority:** P0

> **Note:** Recipe table, entity, and a repository implementation exist. Stories wire in use cases, Riverpod providers, and build full UI for complete end-to-end testability.

---

### US-E5.1: Recipe List & Detail View

**As a** user
**I want to** browse all my recipes and tap one to see full details
**So that** I can find and review a recipe before cooking

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                  |
|-----------|----------------------------------------------------------------------------------------------|
| DB        | `RecipesTable` (exists)  verify all columns; `IngredientsTable` as child table or JSON column |
| Domain    | `Recipe` entity (exists)  verify `Ingredient` value object, `scaleServings()`, `totalTime` |
| Domain    | `IRecipeRepository`  `watchAll()`, `getById(id)`, `save()`, `delete(id)`, `search(query)`  |
| Data      | `RecipeDataSource` (Drift DAO) + `RecipeRepositoryImpl` (exists  verify exception mapping) |
| Use Cases | `WatchRecipesUseCase`, `GetRecipeByIdUseCase(id)`                                           |
| Providers | `recipeRepositoryProvider`, `recipesProvider` (StreamProvider), `recipeDetailProvider(id)` |
| State     | `RecipeListNotifier`                                                                         |
| UI        | `RecipeListPage` (exists)  wire to Riverpod stream                                         |
| UI        | `RecipeDetailPage`  title, image, time badges, ingredient list, instruction steps          |
| Tests     | Widget: `RecipeListPage` renders 3 mocked recipes                                           |
| Tests     | Widget: `RecipeDetailPage` shows ingredients and instruction steps                          |
| Tests     | Integration: open Recipes tab  tap recipe  verify detail page                            |

**Acceptance Criteria:**

- [ ] Recipe list shows title, thumbnail, total time, and serving count
- [ ] Tapping a recipe navigates to detail page
- [ ] Detail page shows ingredients with quantities and units
- [ ] Detail page shows numbered instruction steps
- [ ] Loading state shown while recipes load from DB
- [ ] Integration test: launch app  Recipes tab  tap recipe  verify detail

---

### US-E5.2: Create & Edit Recipe

**As a** user
**I want to** add new recipes and edit existing ones with full details
**So that** I can build my personal recipe collection

**Story Points:** 8 | **Priority:** P0 | **Dependencies:** US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                        |
|-----------|----------------------------------------------------------------------------------------------------|
| Use Cases | `SaveRecipeUseCase(recipe)`  validates non-empty title + at least 1 ingredient, generates UUID, sets timestamps |
| Use Cases | `ValidateRecipeUseCase(recipe)`  `Either<ValidationFailure, Recipe>`                             |
| State     | `RecipeFormNotifier`  manages multi-section form draft state                                      |
| UI        | `RecipeFormPage`  3 sections: (1) basics, (2) ingredients, (3) instructions                      |
| UI        | `IngredientInputRow`  name typeahead from product catalogue, quantity, unit selector             |
| UI        | `InstructionStepList`  numbered, reorderable, add/remove steps                                   |
| UI        | Save button in app bar  spinner while saving                                                     |
| UI        | Edit mode: `RecipeDetailPage` "Edit" button  `RecipeFormPage` pre-filled                        |
| Tests     | Unit: `SaveRecipeUseCase` rejects empty title                                                     |
| Tests     | Unit: `SaveRecipeUseCase` sets `createdAt` on new recipe                                         |
| Tests     | Widget: ingredient typeahead suggests matching products                                            |
| Tests     | Integration: fill form  save  appears in recipe list  open detail                             |

**Acceptance Criteria:**

- [ ] FAB on recipe list opens new recipe form
- [ ] Form has 3 clearly labelled sections
- [ ] Ingredient input suggests from product catalogue with free-text fallback
- [ ] Can add, remove, and reorder ingredients and instruction steps
- [ ] Saving with empty title shows inline error on title field
- [ ] Must have at least 1 ingredient (or warning shown)
- [ ] After save, navigates back to list; new recipe appears
- [ ] Integration test: full form fill  save  verify in list  check detail

---

### US-E5.3: Delete Recipe

**As a** user
**I want to** delete recipes I no longer need
**So that** my collection stays manageable

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E5.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                          |
|-----------|--------------------------------------------------------------------------------------|
| Use Cases | `DeleteRecipeUseCase(id)`  soft delete; returns `ConflictFailure` if in a meal plan |
| UI        | Delete option in `RecipeDetailPage` overflow menu                                    |
| UI        | Confirmation dialog: "Remove [name] from your recipes?"                              |
| UI        | If recipe is in meal plan: "This recipe is in your meal plan. Delete anyway?"        |
| Tests     | Unit: delete use case returns `ConflictFailure` when recipe is in an active meal plan |
| Tests     | Integration: delete recipe  no longer in list                                       |

**Acceptance Criteria:**

- [ ] Recipe detail has "Delete" in the overflow menu
- [ ] Confirmation dialog shows recipe name
- [ ] Recipe removed from list after deletion
- [ ] Warning shown if recipe appears in meal plan slots

---

### US-E5.4: Recipe Search & Tag Filter

**As a** user
**I want to** search recipes by name and filter by tags
**So that** I can quickly find the right recipe

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                          |
|-----------|--------------------------------------------------------------------------------------|
| Data      | `searchRecipes(query)` Drift query  searches title + description                   |
| Data      | `filterByTags(tags)`  JSON contains search on `tagsJson` column                    |
| Use Cases | `SearchRecipesUseCase(query, tags?)`  combined search + filter                     |
| State     | `RecipeSearchNotifier`  query + tag filters + 300 ms debounce                      |
| UI        | Search bar in `RecipeListPage` (collapses by default, expands on search icon tap)   |
| UI        | Tag filter chips below search bar (filled from `WatchAllTagsUseCase`)               |
| Tests     | Unit: search returns only recipes whose title contains query                        |
| Tests     | Widget: typing "pasta" filters to pasta recipes                                     |

**Acceptance Criteria:**

- [ ] Search bar expands on tapping the search icon
- [ ] Recipes filter as user types (300 ms debounce)
- [ ] Tag chips toggle on/off; active chips shown as filled
- [ ] Combined name + tag filter works
- [ ] "No recipes found" empty state with hint to clear filters
- [ ] Clearing all filters restores full list

---

### US-E5.5: Recipe Serving Scaler

**As a** user
**I want to** adjust the serving count on a recipe and see scaled ingredient quantities
**So that** I can cook for different group sizes without manual calculation

**Story Points:** 3 | **Priority:** P1 | **Dependencies:** US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                          |
|-----------|--------------------------------------------------------------------------------------|
| Domain    | `Recipe.scaleServings(newServings)` (verify on entity)                              |
| Use Cases | `ScaleRecipeUseCase(recipe, newServings)`  scaled `Recipe` in memory (not saved)   |
| State     | `servingCountProvider(recipeId)`  session-only overridable state                   |
| UI        | Serving stepper (`` / count / `+`) in `RecipeDetailPage` header                   |
| UI        | Ingredient quantities update live as serving count changes                           |
| UI        | Reset button restores original serving count                                         |
| Tests     | Unit: `ScaleRecipeUseCase`  2 cups flour for 4 servings  3 cups for 6           |
| Tests     | Widget: tap `+`  ingredient quantities update                                      |

**Acceptance Criteria:**

- [ ] Serving counter in recipe detail header
- [ ] `+` / `` adjusts serving count (minimum 1)
- [ ] All ingredient quantities scale proportionally, displayed as readable fractions
- [ ] Reset button restores original defaults
- [ ] Scaled quantities are NOT persisted to DB (session only)

---

## EPIC E6: Meal Planning Feature

**Goal:** Users can plan weekly meals by assigning recipes to breakfast/lunch/dinner slots, then generate a shopping list from the plan.

**Story Count:** 4 | **Total Points:** 22 | **Priority:** P0

> **Note:** UI skeleton (calendar, menu views) already exists. Stories add the data layer, domain, use cases, and wire everything together.

---

### US-E6.1: Weekly Meal Plan View

**As a** user
**I want to** see a weekly calendar with meal slots (breakfast, lunch, dinner) for each day
**So that** I can plan my meals for the week ahead

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                   |
|-----------|-----------------------------------------------------------------------------------------------|
| DB        | `MealPlansTable`: `id`, `weekStartDate`, `createdAt`                                         |
| DB        | `MealSlotsTable`: `id`, `planId` (FK), `date`, `mealType` (enum: breakfast/lunch/dinner), `recipeId` (FK nullable), `customName` (nullable) |
| Domain    | `MealPlan` entity + `MealSlot` value object                                                  |
| Domain    | `IMealPlanRepository`: `watchByWeek(weekStart)`, `save()`, `clearSlot(slotId)`              |
| Data      | `MealPlanDataSource` + `MealPlanRepositoryImpl`                                              |
| Use Cases | `GetOrCreateWeeklyPlanUseCase(weekStart)`  creates plan if none exists for that week        |
| Use Cases | `WatchWeeklyPlanUseCase(weekStart)`                                                          |
| Providers | `mealPlanRepositoryProvider`, `weeklyPlanProvider(weekStart)`                                |
| State     | `MealPlanNotifier(weekStart)`                                                                |
| UI        | Wire existing `MenuView` / `CalendarComponent` to Riverpod stream                           |
| UI        | Week navigation (prev/next week arrows)                                                      |
| UI        | Empty slot shows "+" placeholder; filled slot shows recipe name + thumbnail                  |
| Tests     | Unit: `GetOrCreateWeeklyPlanUseCase` creates plan for a new week                            |
| Tests     | Widget: calendar shows 7 days  3 meal types grid                                           |
| Tests     | Integration: navigate to Meal Planning tab  see empty week grid                            |

**Acceptance Criteria:**

- [ ] Meal Planning tab shows current week by default
- [ ] 7 columns (days)  3 rows (breakfast/lunch/dinner) grid
- [ ] Empty slots show "+" tap target
- [ ] Week header shows date range (e.g., "Mar 3  Mar 9")
- [ ] Prev/Next arrows navigate between weeks
- [ ] Integration test: open tab  grid renders correctly

---

### US-E6.2: Assign Recipe to Meal Slot

**As a** user
**I want to** assign a recipe to a meal slot by tapping on it
**So that** I can plan what I will cook each day

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E6.1, US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                               |
|-----------|-------------------------------------------------------------------------------------------|
| Use Cases | `AssignRecipeToSlotUseCase(slotId, recipeId)`  upserts slot with recipe reference       |
| Use Cases | `ClearMealSlotUseCase(slotId)`  sets recipeId to null                                   |
| UI        | Tapping empty slot opens `RecipePickerBottomSheet` (searchable recipe list)              |
| UI        | Tapping filled slot shows context menu: "Change Recipe" / "Clear Slot"                   |
| UI        | After assignment, slot shows recipe thumbnail and name                                    |
| Tests     | Unit: `AssignRecipeToSlotUseCase` stores `recipeId` on correct slot                     |
| Tests     | Widget: recipe picker renders recipes from stream                                        |
| Tests     | Integration: tap slot  pick recipe  slot shows recipe name                            |

**Acceptance Criteria:**

- [ ] Tapping an empty slot opens recipe picker
- [ ] Picker has a search bar to filter recipes
- [ ] Tapping a recipe in the picker assigns it and closes the sheet
- [ ] Slot immediately shows assigned recipe name (+ thumbnail if available)
- [ ] Tapping a filled slot shows context menu (Change / Clear)
- [ ] Clearing a slot resets it to the "+" placeholder
- [ ] Integration test: assign  verify slot displays recipe name

---

### US-E6.3: Generate Shopping List from Meal Plan

**As a** user
**I want to** generate a shopping list from my weekly meal plan
**So that** I don't have to copy ingredient lists manually from each recipe

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E6.2, US-E4.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                          |
|-----------|------------------------------------------------------------------------------------------------------|
| Use Cases | `GenerateShoppingListFromPlanUseCase(planId, listName)`  collects ingredients from all assigned recipes, aggregates quantities by ingredient name + unit, creates a new `ShoppingList` |
| Domain    | Aggregation rule: same name + same unit  sum quantities; different units kept separate             |
| State     | `GenerateListNotifier`  loading / error / success states                                           |
| UI        | "Generate Shopping List" button at bottom of meal plan screen                                       |
| UI        | Confirmation sheet: shows recipe count + estimated item count                                       |
| UI        | On success: navigate to the newly created shopping list detail page                                 |
| Tests     | Unit: aggregation merges "2 cups flour" + "1 cup flour"  "3 cups flour"                          |
| Tests     | Unit: "2 cups" + "1 tsp" kept as separate items (different units)                                  |
| Tests     | Integration: plan with 2 recipes  generate  shopping list created with all ingredients           |

**Acceptance Criteria:**

- [ ] "Generate Shopping List" button visible on meal plan screen
- [ ] Confirmation sheet shows recipe count and estimated item count before creating
- [ ] Generated list is named after the week (e.g., "Week of Mar 3")
- [ ] Duplicate ingredients (same name + unit) are combined
- [ ] After generation, navigation goes to the new shopping list detail page
- [ ] Integration test: assign recipes  generate list  verify aggregated items

---

### US-E6.4: Meal Plan Duplication & Clearing

**As a** user
**I want to** duplicate a past week's plan into the current week and clear individual days or the entire week
**So that** I can reuse meal combinations I enjoyed

**Story Points:** 4 | **Priority:** P2 | **Dependencies:** US-E6.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                              |
|-----------|------------------------------------------------------------------------------------------|
| Use Cases | `DuplicateMealPlanUseCase(sourceWeekStart, targetWeekStart)`  copies slot assignments  |
| Use Cases | `ClearDayUseCase(planId, date)`  removes all 3 slot assignments for a given day        |
| Use Cases | `ClearWeekUseCase(planId)`  removes all assignments for the week                       |
| UI        | Week header overflow menu: "Copy from Previous Week" / "Clear Week"                     |
| UI        | Day column long-press: "Clear Day"                                                       |
| Tests     | Unit: duplicate use case copies all slot assignments to target week                     |
| Tests     | Integration: duplicate previous plan  current week shows same recipes                  |

**Acceptance Criteria:**

- [ ] Overflow menu on week header has duplicate and clear options
- [ ] Duplicating copies recipe assignments (does not generate a shopping list)
- [ ] Clearing a day removes all 3 slots for that day
- [ ] Clearing the week removes all assignments; does not delete shopping lists
- [ ] Confirmation dialog shown before "Clear Week"

---

## EPIC E7: Pantry Inventory Feature

**Goal:** Users can track what they already have at home, update quantities, and see what is about to expire.

**Story Count:** 3 | **Total Points:** 16 | **Priority:** P0

---

### US-E7.1: Pantry Item CRUD

**As a** user
**I want to** add, view, and remove items from my pantry inventory
**So that** I know what I already have and can avoid buying duplicates

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                   |
|-----------|-----------------------------------------------------------------------------------------------|
| DB        | `PantryItemsTable`: `id`, `productId` (FK nullable), `name`, `quantity`, `unit`, `categoryId`, `expiryDate` (nullable), `purchasedDate`, `location` (nullable), `createdAt`, `updatedAt`, `isSynced`, `isDeleted` |
| Domain    | `PantryItem` entity: `isExpired`, `daysUntilExpiry`, `copyWith()`                            |
| Domain    | `IPantryRepository`: `watchAll()`, `save()`, `delete(id)`, `watchExpiringSoon(days)`         |
| Data      | `PantryDataSource` + `PantryRepositoryImpl`                                                  |
| Use Cases | `WatchPantryItemsUseCase`, `AddPantryItemUseCase(name, qty, unit, categoryId?, expiryDate?)` |
| Use Cases | `DeletePantryItemUseCase(id)`                                                                |
| Providers | `pantryRepositoryProvider`, `pantryItemsProvider`                                            |
| State     | `PantryNotifier`                                                                              |
| UI        | `PantryPage`  items grouped by category; FAB to add                                         |
| UI        | `AddPantryItemBottomSheet`  name (from catalogue or free-text), qty, unit, expiry date picker |
| UI        | Swipe-to-delete with undo                                                                     |
| Tests     | Unit: `AddPantryItemUseCase` rejects quantity  0                                           |
| Tests     | Widget: pantry page renders items grouped by category                                        |
| Tests     | Integration: add item  appears in pantry list                                               |

**Acceptance Criteria:**

- [ ] Pantry tab shows items grouped by category
- [ ] FAB opens add-item form with optional expiry date picker
- [ ] Item row shows: name, quantity + unit, expiry date (if set)
- [ ] Swipe-to-delete with undo snackbar
- [ ] Integration test: add  verify  delete  verify removed

---

### US-E7.2: Quick Quantity Adjustment

**As a** user
**I want to** quickly update the quantity of a pantry item by tapping + or 
**So that** I can update my pantry without opening a full edit form

**Story Points:** 4 | **Priority:** P1 | **Dependencies:** US-E7.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                        |
|-----------|------------------------------------------------------------------------------------|
| Use Cases | `UpdatePantryItemQuantityUseCase(id, newQuantity)`  clamps to minimum 0          |
| State     | Optimistic update in `PantryNotifier`                                              |
| UI        | Inline stepper (`` / qty / `+`) on each pantry item row                          |
| UI        | Quantity = 0  item dims with "Out of stock" badge (not deleted automatically)    |
| UI        | Tapping item row (not stepper)  `EditPantryItemPage` (full edit form)            |
| Tests     | Unit: update use case clamps quantity to 0 minimum                                |
| Tests     | Widget: tap `+` increases displayed quantity; tap `` decreases                   |

**Acceptance Criteria:**

- [ ] Each pantry row has visible `` and `+` buttons
- [ ] Quantity updates instantly (optimistic)
- [ ] Quantity cannot go below 0
- [ ] Items at 0 show a visual "Out of stock" indicator
- [ ] Full edit (name, unit, expiry) accessible by tapping the row

---

### US-E7.3: Expiry Tracking & Alerts

**As a** user
**I want to** see which pantry items are expiring soon
**So that** I can use them before they go to waste

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E7.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                   |
|-----------|-----------------------------------------------------------------------------------------------|
| Domain    | `PantryItem.expiryStatus` enum: `fresh`, `expiringSoon` (< 3 days), `expired`                |
| Use Cases | `WatchExpiringSoonUseCase(withinDays: 3)`  stream of items expiring within N days           |
| Providers | `expiringSoonProvider`                                                                        |
| UI        | Badge on Pantry nav tab showing count of expiring items                                      |
| UI        | "Expiring Soon" collapsible banner at top of pantry page                                     |
| UI        | Colour-coded expiry chips on item rows: yellow = expiring soon, red = expired                |
| UI        | "Show expiring only" filter chip                                                              |
| Tests     | Unit: `WatchExpiringSoonUseCase` returns only items within threshold                         |
| Tests     | Widget: badge shows correct count                                                            |
| Tests     | Integration: add item with expiry tomorrow  badge shows 1                                   |

**Acceptance Criteria:**

- [ ] Nav tab badge shows expiring item count (hidden when 0)
- [ ] "Expiring Soon" banner appears when  1 item expires within 3 days
- [ ] Item rows show colour-coded expiry chip
- [ ] "Show expiring only" filter chip toggles filtered view
- [ ] Integration test: add item expiring tomorrow  badge shows 1

---

## EPIC E8: Settings & Data Management

**Goal:** Users can configure the app, export their data, and restore from a backup.

**Story Count:** 4 | **Total Points:** 17 | **Priority:** P0

---

### US-E8.1: Settings & Theme Preferences

**As a** user
**I want to** switch between light and dark mode and configure basic preferences
**So that** the app works comfortably in my environment

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                    |
|-----------|--------------------------------------------------------------------------------|
| Data      | `SharedPreferences`-based `SettingsDataSource` with typed getters/setters      |
| Domain    | `AppSettings` value object: `themeMode`, `defaultServings`, `currency`        |
| Use Cases | `SaveSettingsUseCase(AppSettings)`                                             |
| Providers | `settingsProvider` (persisted `StateNotifier`)                                 |
| UI        | `SettingsPage` (exists as `settings_view_page.dart`)  wire it to providers   |
| UI        | Theme toggle (System / Light / Dark)  applies immediately                    |
| UI        | Default servings number picker                                                 |
| UI        | About section (app version, open-source licences)                             |
| Tests     | Unit: `SaveSettingsUseCase` persists and reads correctly                       |
| Tests     | Widget: toggling dark mode updates theme immediately in widget tree            |

**Acceptance Criteria:**

- [ ] Settings tab accessible from nav bar
- [ ] Theme picker applies the theme change immediately
- [ ] Settings persist across app restarts
- [ ] About section shows app version

---

### US-E8.2: Export Data to JSON

**As a** user
**I want to** export all my data to a JSON file
**So that** I have a backup I can restore or transfer to another device

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E8.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                |
|-----------|--------------------------------------------------------------------------------------------|
| Use Cases | `ExportDataUseCase()`  queries all repositories, builds `AppExportDto` with schema version |
| Data      | `AppExportDto` (freezed model containing all top-level entities)                          |
| Use Cases | Serialises dto to JSON; writes file to `getApplicationDocumentsDirectory()`               |
| UI        | "Export Data" row in Settings  triggers export + shows share/save dialog                 |
| UI        | Progress indicator during export                                                           |
| UI        | Success: "Exported 42 recipes, 15 lists..." snackbar + OS share sheet                    |
| Tests     | Unit: export dto serialises all entities to valid JSON                                    |
| Tests     | Integration: export  read JSON file  verify recipe count matches DB                    |

**Acceptance Criteria:**

- [ ] "Export Data" option in Settings
- [ ] Progress indicator shown while export runs
- [ ] On success, OS share sheet opens with the exported JSON file
- [ ] JSON file is human-readable and includes `"export_version": 1`
- [ ] Integration test: export  read file  verify recipe count matches

---

### US-E8.3: Import Data from JSON

**As a** user
**I want to** import a previously exported JSON file
**So that** I can restore a backup or transfer data from another device

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E8.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                   |
|-----------|-----------------------------------------------------------------------------------------------|
| Use Cases | `ImportDataUseCase(filePath)`  reads JSON, validates schema version, upserts all entities   |
| Use Cases | Conflict rule: existing record not overwritten when import has an older `updatedAt`          |
| UI        | "Import Data" row in Settings  file picker (JSON files only)                                |
| UI        | Preview sheet: "Found 42 recipes, 15 lists. Import will merge with existing data."           |
| UI        | Confirm  progress indicator  success summary                                               |
| Tests     | Unit: `ImportDataUseCase` rejects invalid JSON schema gracefully                             |
| Tests     | Unit: existing record not overwritten when import data has older `updatedAt`                |
| Tests     | Integration: export  wipe DB  import  verify all data restored                           |

**Acceptance Criteria:**

- [ ] "Import Data" opens file picker filtered to JSON
- [ ] Preview sheet shows entity counts before committing
- [ ] Import merges (upserts) without duplicating unchanged records
- [ ] Invalid file shows user-friendly error (no crash)
- [ ] Integration test: export  import  verify data

---

### US-E8.4: Clear All Data

**As a** user
**I want to** delete all my data with a single action
**So that** I can reset the app to a clean state

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E8.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                               |
|-----------|---------------------------------------------------------------------------|
| Use Cases | `ClearAllDataUseCase()`  truncates all tables respecting FK order        |
| UI        | "Danger Zone" section in Settings with a red "Clear All Data" button      |
| UI        | Two-step confirmation: first dialog + second requires typing "DELETE"     |
| Tests     | Unit: clear use case deletes records from all tables                      |
| Tests     | Integration: add data  clear  verify empty states on all tabs           |

**Acceptance Criteria:**

- [ ] "Clear All Data" is in a clearly marked "Danger Zone" section
- [ ] Two confirmation steps prevent accidental deletion
- [ ] After clearing, all tabs show empty states
- [ ] App preferences (theme, etc.) are NOT cleared

---

## PHASE 4 (Post-MVP): Cloud Sync & Collaboration

### Epic E9: Sync Engine & Queue

Each story is a vertical slice  sync logic change + UI indicator confirming it works:

- **US-E9.1:** Sync Queue Implementation (table + DAO + queue manager + status indicator in app bar)
- **US-E9.2:** Sync Coordinator (triggers sync + shows "Syncing" badge)
- **US-E9.3:** Conflict Resolver  Last-Write-Wins (engine + conflict notification toast)
- **US-E9.4:** Operational Transform for Lists (merge algorithm + live collaborative cursor)
- **US-E9.5:** Network Change Listener (offline banner appears/disappears on connectivity change)
- **US-E9.6:** Background Sync Job (platform background task + last-synced timestamp in Settings)
- **US-E9.7:** Sync Status UI Indicator (persistent icon showing sync state across all tabs)

---

### Epic E10: Cloud Backend Integration

Each story includes the data-source implementation AND a visible UI confirmation (synced badge, cloud icon):

- US-E10.1: Choose Backend (Firebase or Supabase)  ADR document + scaffolded remote client
- US-E10.2: Remote Data Sources for all Entities  recipe, shopping list, meal plan, pantry
- US-E10.3: Cloud Functions for Recipe Import
- US-E10.4: Image Upload & Optimisation  upload flow + progress indicator
- US-E10.5: API Client with Retry Logic
- US-E10.6: Database Migration to Cloud  migration wizard UI
- US-E10.7: Differential Sync Implementation
- US-E10.8: Real-time Updates  WebSocket/Stream + live "edited by" indicator

---

### Epic E11: Authentication & Security

- US-E11.1: Email/Password Authentication  full sign-up/sign-in/sign-out flow with UI
- US-E11.2: Google Sign-In  one-tap button + account avatar in Settings
- US-E11.3: Token Management  refresh logic + session expiry notification
- US-E11.4: Secure Storage  Keychain/Keystore integration
- US-E11.5: Row-Level Security Policies  backend policies + verified via integration test
- US-E11.6: Data Encryption for Sensitive Fields

---

### Epic E12: Family & Collaboration

- US-E12.1: Create Family Group  group creation form + shareable invite link
- US-E12.2: Invite Members  invite link flow + acceptance screen
- US-E12.3: Share Shopping List  share toggle on list detail + shared indicator chip
- US-E12.4: Real-time Collaborative Editing  live presence dots on shared list
- US-E12.5: User Roles & Permissions  role picker in group management screen
- US-E12.6: Activity Feed  feed page showing recent changes by family members

---

## PHASE 5 (Post-MVP): Smart Features

### Epic E13: Smart Features & AI

Each story is a full vertical slice from ML/API integration to UI exposure:

- **US-E13.1:** Recipe Import from URL  URL input field  scraper  new recipe pre-filled in form  save
- **US-E13.2:** Barcode Scanner for Pantry  camera scan  product lookup  pre-fill add-pantry-item form
- **US-E13.3:** Smart Category Inference  ML category suggestion chip on add-item forms (accept/reject)
- **US-E13.4:** Recipe Recommendations  recommendation engine  "Suggested for this week" section in meal plan
- **US-E13.5:** Nutrition Calculation  per-recipe nutrition API  nutrition card on recipe detail page
- **US-E13.6:** Voice Input for Items  mic button on AddItem sheet  speech-to-text fills name field
- **US-E13.7:** Ingredient Recognition from Image  camera button on recipe form  ML-parsed ingredient list pre-fill

---

### Epic E14: Performance Optimisation

- US-E14.1: Pagination for Recipe List (cursor-based, infinite scroll)
- US-E14.2: Image Caching with `cached_network_image`
- US-E14.3: Database Query Optimisation  add indexes, measure with `EXPLAIN QUERY PLAN`
- US-E14.4: Image Compression on Upload
- US-E14.5: Lazy Loading for Meal Calendar (load adjacent weeks on demand)
- US-E14.6: Performance Monitoring Integration (Firebase Performance or Sentry)

---

## EPIC E15: Testing & Quality Assurance (Ongoing)

- **US-E15.1:** Unit Test Suite  target 70% coverage across all use cases and entities
- **US-E15.2:** Widget Test Suite  all pages tested with mocked Riverpod providers
- **US-E15.3:** Integration Tests for Critical Flows: E2.1, E4.3, E5.2, E6.3
- **US-E15.4:** E2E Tests with `patrol` or `flutter_driver`
- **US-E15.5:** Accessibility Tests  screen reader labels, contrast ratios
- **US-E15.6:** Performance Regression Tests  DB with 1 000+ records
- **US-E15.7:** Beta Testing Programme
- **US-E15.8:** Crash Monitoring (Sentry)

---

## Release Planning

### MVP v1.0 (Epics E1E8)

**Scope:** Complete offline-first app, all core features testable end-to-end from the UI

| Sprint | Focus                                   | Epics        | Points |
|--------|-----------------------------------------|--------------|--------|
| 1      | App Shell + Product Categories          | E1, E2       | ~21    |
| 2      | Products + Shopping List foundation     | E3, E4 P0   | ~38    |
| 3      | Shopping List P1 features               | E4 P1P2     | ~12    |
| 4      | Recipes                                 | E5           | ~26    |
| 5      | Meal Planning                           | E6           | ~22    |
| 6      | Pantry + Settings                       | E7, E8       | ~33    |
| 7      | Bug fixes, polish, QA sprint            | E15          | ~20    |

**Estimated Duration:** 7 sprints  2 weeks = **14 weeks** for 2 developers

### v1.1  Cloud Sync & Auth (Epics E9E12)
### v1.2  Smart Features & Performance (Epics E13E14)

---

## Appendix: Technology Stack

| Concern           | Technology                                     |
|-------------------|------------------------------------------------|
| Framework         | Flutter 3.16+                                  |
| Language          | Dart 3.2+                                      |
| State Management  | Riverpod 2.x (`AsyncNotifier`, `StreamProvider`) |
| Local Database    | Drift 2.x (type-safe SQLite)                   |
| Functional        | Dartz (`Either<Failure, T>`)                   |
| JSON / Models     | freezed + json_serializable                    |
| Navigation        | GoRouter                                       |
| Settings          | shared_preferences                             |
| Testing           | flutter_test, mockito, integration_test, patrol |
| CI/CD             | GitHub Actions                                 |

---

**Document End  Version 5.0 (Vertical Slice Approach)**
