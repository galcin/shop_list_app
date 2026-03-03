# E2: Product Category Feature

**Story Count:** 3 | **Total Points:** 14 | **Priority:** P0 | **Sprint:** 1

---

## Epic Goal

Users can manage product categories (e.g., "Dairy", "Produce"). This is the first complete vertical slice — from Drift table through to CRUD UI.

> **Note:** Table, entity, repository, and UI pages for `ProductCategory` already exist in the project. These stories focus on **wiring everything together correctly** — adding use cases, Riverpod providers, proper state management — so the feature is fully testable end-to-end.

---

## Existing Files to Wire Up

| File                                                                       | Status     |
| -------------------------------------------------------------------------- | ---------- |
| `core/database/tables/product_category_table.dart`                         | ✅ Exists  |
| `features/shopping/domain/entities/product_category.dart`                  | ✅ Exists  |
| `features/shopping/domain/repositories/i_product_category_repository.dart` | ✅ Exists  |
| `features/shopping/data/repositories/product_category_repository.dart`     | ✅ Exists  |
| `features/shopping/presentation/pages/product_category_view_page.dart`     | ✅ Exists  |
| `features/shopping/presentation/pages/product_category_detail_page.dart`   | ✅ Exists  |
| Use Cases                                                                  | ❌ Missing |
| Riverpod Providers                                                         | ❌ Missing |
| State Notifier                                                             | ❌ Missing |
| Create/Edit Bottom Sheet                                                   | ❌ Missing |

---

## Stories

### US-E2.1: View & Create Product Categories

**As a** user
**I want to** see all my product categories and add new ones
**So that** I can organise my shopping items

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                           |
| --------- | --------------------------------------------------------------------------------------------------------------------- |
| DB        | `ProductCategoryTable` (exists) — verify: `id`, `name`, `colorHex`, `iconName`, `sortOrder`, `createdAt`, `updatedAt` |
| Domain    | `ProductCategory` entity (exists) — verify `copyWith`, `Equatable`                                                    |
| Domain    | `IProductCategoryRepository` (exists) — verify `watchAll()`, `save()`                                                 |
| Data      | `ProductCategoryDataSource` (Drift DAO) — verify `watchAll()`, `insert()`                                             |
| Data      | `ProductCategoryRepositoryImpl` — verify exception → Failure conversion                                               |
| Use Cases | `WatchProductCategoriesUseCase` → `Stream<Either<Failure, List<ProductCategory>>>`                                    |
| Use Cases | `CreateProductCategoryUseCase(name, colorHex?, iconName?)` — validates non-empty name, generates UUID, saves          |
| Providers | `productCategoryRepositoryProvider`, `watchCategoriesProvider`, `createCategoryProvider`                              |
| State     | `ProductCategoryListNotifier extends AsyncNotifier<List<ProductCategory>>`                                            |
| UI        | `ProductCategoryViewPage` (exists) — wire to `AsyncValueWidget` + FAB to add                                          |
| UI        | `CreateCategoryBottomSheet` — text field + colour picker + save button                                                |
| Tests     | Unit: `CreateProductCategoryUseCase` with empty name → `ValidationFailure`                                            |
| Tests     | Unit: repository `save()` calls data source and returns entity                                                        |
| Tests     | Widget: `ProductCategoryViewPage` renders 3 mocked categories                                                         |
| Tests     | Integration: create category via UI → appears in list                                                                 |

**Acceptance Criteria:**

- [ ] Opening the Shopping tab shows category list
- [ ] Empty state shown when no categories exist, with "Add Category" action
- [ ] Tapping FAB opens `CreateCategoryBottomSheet`
- [ ] Submitting an empty name shows inline validation error (no toast)
- [ ] Created category appears at bottom of list immediately (reactive stream)
- [ ] Integration test: create → verify in list → pass

**UI Specification:**

`ProductCategoryViewPage` (dark tile grid):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Categories                       [⋮]           │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │ 🥛        │  │ 🥬        │  │ 🥩        │  │  ← tile bg = category colorHex (dark tint)
│  │ Dairy     │  │ Produce   │  │ Meat      │  │  ← white Poppins Medium, icon top-left
│  │ 8 items   │  │ 12 items  │  │ 5 items   │  │  ← item count textSecondary
│  └───────────┘  └───────────┘  └───────────┘  │
│  ┌───────────┐  ┌───────────┐  ┌─ ─ ─ ─ ─ ┐  │
│  │ 🧂        │  │ 🍞        │  │    +      │  │  ← dashed-border "New Category" tile
│  │ Pantry    │  │ Bakery    │  │  New      │  │
│  │ 10 items  │  │ 3 items   │  │           │  │
│  └───────────┘  └───────────┘  └─ ─ ─ ─ ─ ┘  │
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange #FF6B35
    └─────┘

CreateCategoryBottomSheet (dark):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  New Category                              │
│  ┌───────────────────────────────────────────┐  │
│  │  Category name *  e.g. "Dairy"            │  │  ← input bg #2A2A2A
│  └───────────────────────────────────────────┘  │
│  Colour   ● ● ● ● ● ●  (6 swatches)           │  ← circle swatches; selected = orange ring
│  Icon     🥛 🥬 🥩 🧂 🍞 🧴  (emoji picker)    │
│  [+ Create Category]  ← orange full-width btn   │
└─────────────────────────────────────────────────┘
```

---

### US-E2.2: Edit & Delete Product Category

**As a** user
**I want to** rename or delete a product category
**So that** I can keep my categories up to date

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E2.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                |
| --------- | ------------------------------------------------------------------------------------------ |
| Use Cases | `UpdateProductCategoryUseCase(id, name, colorHex?, iconName?)` — validates, updates        |
| Use Cases | `DeleteProductCategoryUseCase(id)` — checks if products use this category, warns or blocks |
| Providers | `updateCategoryProvider`, `deleteCategoryProvider`                                         |
| UI        | Swipe-to-delete on list tile (with undo snackbar, 4 seconds)                               |
| UI        | Long-press or trailing icon opens `EditCategoryBottomSheet` (pre-filled form)              |
| UI        | Confirmation dialog if category has products assigned                                      |
| Tests     | Unit: `DeleteProductCategoryUseCase` with products assigned → `ConflictFailure`            |
| Tests     | Widget: swipe tile → confirmation dialog appears                                           |
| Tests     | Integration: edit name → updated in list; delete → removed from list                       |

**Acceptance Criteria:**

- [ ] Swiping a category left reveals delete action
- [ ] Delete prompts confirmation dialog showing category name
- [ ] Deleting a category with products warns the user ("Delete anyway?")
- [ ] Deleted category disappears from list; undo snackbar shown for 4 seconds
- [ ] Tapping edit icon opens pre-filled form
- [ ] Saving updates the name and colour in the list immediately

**UI Specification:**

Swipe actions on category tiles (list view, not grid):

- Swipe left → **Delete** (red `#EF4444` bg, trash icon) → confirmation dialog
- Trailing edit icon → opens pre-filled `EditCategoryBottomSheet` (same dark sheet as Create, pre-populated)

Confirmation dialog when category has products:

```
┌──────────────────────────────────┐  bg #1E1E1E radius 16px
│  Delete "Dairy"?                 │
│  This category has 8 products.   │
│  They will become uncategorised. │
│         [Cancel]  [Delete]        │  ← Delete = red #EF4444 text
└──────────────────────────────────┘
```

---

### US-E2.3: Product Category Reordering

**As a** user
**I want to** drag and drop categories to reorder them
**So that** my most-used categories appear at the top

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** US-E2.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                              |
| --------- | ------------------------------------------------------------------------ |
| DB        | Ensure `sortOrder` column exists on `ProductCategoryTable`               |
| Use Cases | `ReorderProductCategoriesUseCase(orderedIds)` — bulk updates `sortOrder` |
| Providers | `reorderCategoriesProvider`                                              |
| UI        | `ReorderableListView` in `ProductCategoryViewPage` with drag handles     |
| Tests     | Unit: reorder use case assigns correct sort indices                      |
| Tests     | Widget: drag tile — list reorders visually                               |

**Acceptance Criteria:**

- [ ] Drag handle visible on each category row
- [ ] Dragging updates order immediately (optimistic UI)
- [ ] Sort order persisted — reopening app shows same order
- [ ] Works on touch (mobile) and mouse (desktop/web)

**UI Specification:**

Reorderable list view (activated via "Reorder" in overflow menu):

```
│  ≡  🥬 Produce    12 items    ● orange badge   │  ← drag handle left; lifted = shadow
│  ≡  🥛 Dairy      8 items                      │
│  ≡  🥩 Meat       5 items                      │  ← dragged tile elevates with shadow
```

Drag handle: `≡` icon in `#9CA3AF`; lifted tile bg brightens from `#1E1E1E` → `#2A2A2A`; drop zone = orange dashed horizontal line.

---

_See [\_index.md](_index.md) for the full epic list._
