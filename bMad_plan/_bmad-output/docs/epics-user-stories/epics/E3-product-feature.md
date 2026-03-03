# E3: Product Feature

**Story Count:** 3 | **Total Points:** 15 | **Priority:** P0 | **Sprint:** 2

---

## Epic Goal

Users can manage the product catalogue — individual products that belong to categories. Products are the building blocks of shopping lists and pantry entries.

> **Note:** Table, entity, repository, and UI pages for `Product` already exist in the project. Stories focus on correct wiring, use cases, and full end-to-end testability.

---

## Existing Files to Wire Up

| File                                                              | Status     |
| ----------------------------------------------------------------- | ---------- |
| `core/database/tables/product_table.dart`                         | ✅ Exists  |
| `features/shopping/domain/entities/product.dart`                  | ✅ Exists  |
| `features/shopping/domain/repositories/i_product_repository.dart` | ✅ Exists  |
| `features/shopping/data/repositories/product_repository.dart`     | ✅ Exists  |
| `features/shopping/presentation/pages/product_view_page.dart`     | ✅ Exists  |
| `features/shopping/presentation/pages/product_detail_page.dart`   | ✅ Exists  |
| Use Cases                                                         | ❌ Missing |
| Riverpod Providers                                                | ❌ Missing |
| State Notifier                                                    | ❌ Missing |
| `ProductSearchNotifier`                                           | ❌ Missing |
| `CreateProductBottomSheet`                                        | ❌ Missing |

---

## Stories

### US-E3.1: View & Create Products

**As a** user
**I want to** browse all products and add new ones with a name, unit, and category
**So that** I can build a reusable product catalogue

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E2.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                         |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| DB        | `ProductTable` (exists) — verify: `id`, `name`, `defaultUnit`, `categoryId` (FK), `barcode?`, `imageUrl?`, `createdAt`, `updatedAt` |
| Domain    | `Product` entity (exists) — verify business methods and `Equatable`                                                                 |
| Domain    | `IProductRepository` — `watchAll()`, `watchByCategory(id)`, `save()`                                                                |
| Data      | `ProductDataSource` (Drift DAO) + `ProductRepositoryImpl`                                                                           |
| Use Cases | `WatchProductsUseCase`, `CreateProductUseCase(name, unit, categoryId)`                                                              |
| Providers | `productRepositoryProvider`, `watchProductsProvider`, `createProductProvider`                                                       |
| State     | `ProductListNotifier extends AsyncNotifier<List<Product>>`                                                                          |
| UI        | `ProductViewPage` (exists) — wire to Riverpod stream; products grouped by category                                                  |
| UI        | `CreateProductBottomSheet` — name field, unit dropdown, category picker                                                             |
| Tests     | Unit: `CreateProductUseCase` validates non-empty name and valid `categoryId`                                                        |
| Tests     | Widget: `ProductViewPage` renders products grouped by category                                                                      |
| Tests     | Integration: create product → appears in correct category group                                                                     |

**Acceptance Criteria:**

- [ ] Products grouped by category in the list
- [ ] Empty state per category group when no products exist
- [ ] FAB opens create form
- [ ] Category picker shows existing categories from E2
- [ ] Created product appears in correct group immediately (reactive stream)
- [ ] Integration test: create → verify grouping

**UI Specification:**

`ProductViewPage` (dark, products grouped by category):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Products                         [🔍] [⋮]     │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  Search products...                    │  │  ← pill search bar bg #2A2A2A
│  └───────────────────────────────────────────┘  │
│  [All] [🥛 Dairy] [🥬 Produce] [🥩 Meat]      │  ← category filter chips, orange active
├─────────────────────────────────────────────────┤
│  🥛 Dairy  (8 products)                         │  ← sticky section label
│  ┌───────────────────────────────────────────┐  │
│  │  Milk          default: L       🥛 Dairy  │  │  ← item row bg #1E1E1E
│  ├───────────────────────────────────────────┤  │
│  │  Cheddar       default: g       🥛 Dairy  │  │
│  └───────────────────────────────────────────┘  │
│  🥬 Produce  (12 products)                      │
│  ...                                            │
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange
    └─────┘

CreateProductBottomSheet (dark):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  New Product                               │
│  ┌───────────────────────────────────────────┐  │
│  │  Product name *   e.g. "Chicken breast"   │  │  ← input bg #2A2A2A
│  └───────────────────────────────────────────┘  │
│  [Default Unit: kg ▾]  [Category: Meat ▾]      │  ← dropdown selectors
│  [+ Add Product]  ← orange full-width button    │
└─────────────────────────────────────────────────┘
```

---

### US-E3.2: Edit & Delete Product

**As a** user
**I want to** edit a product's name, unit, or category and delete products I no longer need
**So that** my product catalogue stays accurate

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                              |
| --------- | -------------------------------------------------------- |
| Use Cases | `UpdateProductUseCase(id, name?, unit?, categoryId?)`    |
| Use Cases | `DeleteProductUseCase(id)` — soft delete                 |
| UI        | `ProductDetailPage` (exists) — wire edit/delete actions  |
| UI        | Edit form pre-filled; save updates list reactively       |
| UI        | Swipe-to-delete with undo snackbar                       |
| Tests     | Unit: `UpdateProductUseCase` merges only provided fields |
| Tests     | Integration: edit → delete → verify state                |

**Acceptance Criteria:**

- [ ] Tapping a product opens detail page with edit option
- [ ] Saving changes updates the product in the list immediately
- [ ] Deleting removes the product (undo available for 4 seconds)
- [ ] If product is in an active shopping list, user sees a warning

**UI Specification:**

`ProductDetailPage` (dark):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  ←  Chicken breast                      [Edit]  │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │  card bg #1E1E1E, radius 12px
│  │  Category:     🥩 Meat                    │  │
│  │  Default Unit: kg                         │  │
│  │  Used in:      3 shopping lists           │  │  ← textSecondary count
│  └───────────────────────────────────────────┘  │
│                                                 │
│  [Delete Product]  ← red text button            │
└─────────────────────────────────────────────────┘
```

Swipe-left on product row in list view → **Delete** (red bg). Warning: if product is in an active list, dialog shows "This product appears in 3 shopping lists. Delete anyway?" with red **Delete** button.

---

### US-E3.3: Product Search & Category Filter

**As a** user
**I want to** search for products by name and filter by category
**So that** I can quickly find items in a large catalogue

**Story Points:** 6 | **Priority:** P1 | **Dependencies:** US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                              |
| --------- | ------------------------------------------------------------------------ |
| Data      | `searchProducts(query)` Drift query — case-insensitive LIKE on `name`    |
| Use Cases | `SearchProductsUseCase(query)`                                           |
| Use Cases | `FilterProductsByCategoryUseCase(categoryId?)`                           |
| State     | `ProductSearchNotifier` — `query` + `selectedCategory` + debounce 300 ms |
| UI        | Search bar at top of `ProductViewPage`                                   |
| UI        | Category filter chips below search bar                                   |
| UI        | Results update in real time as user types                                |
| Tests     | Unit: search use case returns correct subset                             |
| Tests     | Widget: typing "mil" filters to "Milk"                                   |

**Acceptance Criteria:**

- [ ] Search filters products as user types (300 ms debounce)
- [ ] Category chip toggles filter on/off
- [ ] Search + category combination works correctly
- [ ] "No results" empty state shown
- [ ] Clearing search restores full list
- [ ] Widget test: type "mil" → only "Milk" visible

**UI Specification:**

Product search with category chip filter (always-visible search bar):

```
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  mil                               [✕]│  │  ← live filter, orange cursor
│  └───────────────────────────────────────────┘  │
│  [All] [🥛 Dairy] [🥬 Produce]                 │  ← orange active chip
│  Showing 1 of 24 products                       │  ← helper text textSecondary
│  ┌───────────────────────────────────────────┐  │
│  │  Milk          default: L       🥛 Dairy  │  │  ← single result
│  └───────────────────────────────────────────┘  │
```

No-results state: magnifying glass icon + "No products matching 'mil'" + "Clear search" orange link.

---

_See [\_index.md](_index.md) for the full epic list._
