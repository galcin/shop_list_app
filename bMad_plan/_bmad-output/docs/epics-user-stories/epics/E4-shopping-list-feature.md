# E4: Shopping List Feature

**Story Count:** 5 | **Total Points:** 24 | **Priority:** P0 | **Sprint:** 2–3

---

## Epic Goal

Users can create and manage shopping lists, add items from the product catalogue, check off items as they shop, and track their progress.

> **Note:** Shopping list feature is not yet started. This epic creates it from scratch, all layers.

---

## Stories

### US-E4.1: Shopping Lists Overview — Create & Delete Lists

**As a** user
**I want to** see all my shopping lists and create new ones
**So that** I can manage separate lists for different occasions

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                |
| --------- | ---------------------------------------------------------------------------------------------------------- |
| DB        | `ShoppingListsTable`: `id`, `name`, `createdAt`, `updatedAt`, `isSynced`, `isDeleted`                      |
| Domain    | `ShoppingList` entity: `id`, `name`, `items List<ShoppingItem>`, `createdAt`; computed `completionPercent` |
| Domain    | `IShoppingListRepository`: `watchAll()`, `save()`, `delete(id)`, `watchById(id)`                           |
| Data      | `ShoppingListDataSource` (Drift DAO) + `ShoppingListRepositoryImpl`                                        |
| Use Cases | `WatchShoppingListsUseCase`, `CreateShoppingListUseCase(name)`, `DeleteShoppingListUseCase(id)`            |
| Providers | `shoppingListRepositoryProvider`, `shoppingListsProvider` (StreamProvider)                                 |
| State     | `ShoppingListsNotifier`                                                                                    |
| UI        | `ShoppingListsPage` — card per list showing name, item count, completion bar                               |
| UI        | FAB → `CreateListDialog` (single name text field)                                                          |
| UI        | Long-press card → context menu: Rename / Delete                                                            |
| UI        | Delete confirmation showing item count                                                                     |
| Tests     | Unit: `CreateShoppingListUseCase` rejects empty name                                                       |
| Tests     | Widget: list card shows completion percentage bar                                                          |
| Tests     | Integration: create list → card appears; delete list → card removed                                        |

**Acceptance Criteria:**

- [ ] Shopping tab shows all lists as cards
- [ ] Each card shows name, item count, and completion bar
- [ ] FAB opens inline dialog to name the new list
- [ ] New list card appears immediately
- [ ] Long-press → context menu with Rename and Delete
- [ ] Delete shows confirmation with item count; undo available for 5 seconds
- [ ] Empty state shown when no lists exist
- [ ] Integration test: create → delete → verify state

**UI Specification:**

Shopping Lists overview page — dark theme (`#121212` bg, `#1E1E1E` cards):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Shopping Lists                   [🔍] [⋮]     │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  🛒  Weekly Groceries           7/12 done  │  │  ← card bg #1E1E1E, radius 12px
│  │  ━━━━━━━━━━━━━━━━━━░░░░░░░░░░              │  │  ← orange progress bar #FF6B35
│  │  12 items  •  Created Mar 5               │  │  ← textSecondary #9CA3AF
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  🛒  Party supplies             0/8 done   │  │
│  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░             │  │
│  │  8 items                                   │  │
│  └───────────────────────────────────────────┘  │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│      +  New list                               │  │  ← dashed border card, tap = create dialog
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
└─────────────────────────────────────────────────┘
```

Key design tokens:

- Card bg: `#1E1E1E`, radius 12 px, slight elevation shadow
- Progress bar: filled = `#FF6B35`, track = `#2A2A2A`, height 4 px, radius 2 px
- Long-press card → context menu: Rename / Delete (dark menu `#1E1E1E`)
- Empty state: shopping cart icon + "No lists yet" + "Create your first list" orange CTA button

---

### US-E4.2: Add & Manage Items in a Shopping List

**As a** user
**I want to** add products to a shopping list with quantities and units
**So that** I know exactly what to buy

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E4.1, US-E3.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                           |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| DB        | `ShoppingItemsTable`: `id`, `listId` (FK), `productId` (FK nullable), `name`, `quantity`, `unit`, `isChecked`, `categoryId`, `sortOrder`, `createdAt` |
| Domain    | `ShoppingItem` entity + `toggleChecked()`, `copyWith()`                                                                                               |
| Domain    | `IShoppingListRepository` extended with add/remove/update item methods                                                                                |
| Data      | `ShoppingItemDataSource` with JOIN queries                                                                                                            |
| Use Cases | `AddItemToListUseCase(listId, name, qty, unit, categoryId?)`                                                                                          |
| Use Cases | `RemoveItemFromListUseCase(listId, itemId)`                                                                                                           |
| Use Cases | `UpdateItemUseCase(listId, itemId, qty?, unit?)`                                                                                                      |
| State     | `ShoppingListDetailNotifier(listId)` — streams items in real time                                                                                     |
| UI        | `ShoppingListDetailPage` — item list; FAB opens `AddItemBottomSheet`                                                                                  |
| UI        | `AddItemBottomSheet` — product catalogue picker OR free-text, quantity + unit                                                                         |
| UI        | Swipe-to-delete item with undo                                                                                                                        |
| Tests     | Unit: `AddItemUseCase` handles product reference and free-text correctly                                                                              |
| Tests     | Widget: `ShoppingListDetailPage` renders items from stream                                                                                            |
| Tests     | Integration: open list → add item → item appears in list                                                                                              |

**Acceptance Criteria:**

- [ ] Tapping a list card opens detail page
- [ ] AddItem sheet shows product catalogue picker AND free-text fallback
- [ ] Added item appears at bottom of list immediately
- [ ] Quantity and unit visible on each item row
- [ ] Swipe-left deletes item (with undo for 4 seconds)
- [ ] Integration test: add → delete → verify

**UI Specification:**

Shopping List Detail page + Add Item Bottom Sheet:

```
┌─────────────────────────────────────────────────┐  bg #121212
│  ←  Weekly Groceries          [Flat|Category]   │  ← app bar, segmented control
│     5 / 12 items  ━━━━━━░░░░░░░░ 42%           │  ← progress row
├─────────────────────────────────────────────────┤
│  [All] [🥬 Produce] [🧀 Dairy] [🥩 Meat]      │  ← category filter chips, orange active
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  □  Chicken breast        500g  🥩 Meat  │  │  ← item card bg #1E1E1E, radius 10px
│  ├───────────────────────────────────────────┤  │
│  │  □  Lettuce               1 head  🥬      │  │
│  ├───────────────────────────────────────────┤  │
│  │  ✓  Milk (2L)        ~~  2 pcs  🧀~~      │  │  ← checked: strikethrough, 40% opacity
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange #FF6B35
    └─────┘

Add Item Bottom Sheet (dark):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···                                            │  ← drag handle
│  Add Item                                       │  ← white Poppins SemiBold
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  Search catalogue or type freely...    │  │  ← pill input bg #2A2A2A
│  └───────────────────────────────────────────┘  │
│  [Chicken] [Milk] [Bread]  ← recent items       │  ← amber chips
│  ┌──────────────────┐  ┌────────────────────┐  │
│  │ Qty:  [  1.0   ] │  │ Unit: [ kg  ▾ ]    │  │  ← inputs bg #2A2A2A
│  └──────────────────┘  └────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │            Add to List                    │  │  ← orange full-width button
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

Swipe gestures on items:

- Swipe right → **Edit** (blue bg `#3B82F6`, pencil icon)
- Swipe left → **Delete** (red bg `#EF4444`, trash icon) — snackbar undo 4 s

---

### US-E4.3: Check Items Off While Shopping

**As a** user
**I want to** tap items to mark them as collected
**So that** I can track what I have already put in my basket

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E4.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                |
| --------- | -------------------------------------------------------------------------- |
| Use Cases | `ToggleItemCheckedUseCase(listId, itemId)` — flips `isChecked`, updates DB |
| State     | `ShoppingListDetailNotifier` handles optimistic toggle                     |
| UI        | Animated checkbox on each list tile (check + strikethrough text + fade)    |
| UI        | Checked items collapse to a "Done (N)" section at the bottom               |
| UI        | App bar counter "3 / 7 items" updates live                                 |
| Tests     | Unit: toggle use case flips `isChecked`                                    |
| Tests     | Widget: tap checkbox → text is struck-through                              |
| Tests     | Integration: check 2 of 4 items → completion bar shows 50%                 |

**Acceptance Criteria:**

- [ ] Tapping checkbox toggles checked state with smooth animation
- [ ] Checked items move to a collapsed "Done" section at the bottom
- [ ] App bar shows item counter and updates live
- [ ] Tapping a checked item unchecks it and moves it back to the main list
- [ ] Integration test: check items → verify completion %

**UI Specification:**

Checked-item visual states and "Done" section:

```
Unchecked:
│  □  Chicken breast        500g  🥩 Meat     │  ← white text, full opacity

Checking (animation):
│  ✓  ~~Chicken breast~~    500g  🥩 Meat     │  ← orange checkbox, strikethrough, 60% opacity

"Done (3)" collapsed section at bottom:
│  ▾  Done (3)                                 │  ← collapsible amber label
│     ✓  ~~Milk~~            2 pcs             │  ← dimmed items, white 40%
│     ✓  ~~Bread~~           1 loaf            │
│     ✓  ~~Eggs~~            12 pcs            │
```

App bar counter updates live — e.g. **5 / 12 items** — orange progress bar advances.

---

### US-E4.4: Category-Grouped Shopping View

**As a** user
**I want to** see my shopping items grouped by category
**So that** I can shop efficiently by aisle

**Story Points:** 4 | **Priority:** P1 | **Dependencies:** US-E4.3

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| Use Cases | `GetItemsGroupedByCategoryUseCase(listId)` → `Map<String, List<ShoppingItem>>` |
| State     | Toggle `flat` / `grouped` view mode in `ShoppingListDetailNotifier`            |
| UI        | Segmented button (Flat / By Category) in app bar                               |
| UI        | Grouped view: sticky section header per category                               |
| UI        | Uncategorised items under "Other"                                              |
| Tests     | Unit: grouping use case organises mixed-category items correctly               |
| Tests     | Widget: grouped view renders section headers                                   |

**Acceptance Criteria:**

- [ ] Toggle in app bar switches flat ↔ grouped views
- [ ] Grouped view shows category names as sticky section headers
- [ ] Items without a category appear under "Other"
- [ ] Checking items works identically in both views
- [ ] View preference persisted per list

**UI Specification:**

Category-grouped view with sticky section headers:

```
├─────────────────────────────────────────────────┤
│  🥬 Produce  (3 items)                          │  ← sticky header bg #1A1A1A, orange left stripe
│  ┌───────────────────────────────────────────┐  │
│  │  □  Lettuce               1 head          │  │  ← item card #1E1E1E
│  ├───────────────────────────────────────────┤  │
│  │  □  Tomatoes              4 pcs           │  │
│  └───────────────────────────────────────────┘  │
│  🥩 Meat  (2 items)                             │  ← next sticky header
│  ┌───────────────────────────────────────────┐  │
│  │  □  Chicken breast        500g            │  │
│  └───────────────────────────────────────────┘  │
│  ⚪ Other  (1 item)                              │  ← uncategorised items
│  ...                                            │
```

Toggle control: segmented button in app bar — `[Flat]  [By Category]`. Active segment has orange bg and white text.

---

### US-E4.5: Rename Shopping List

**As a** user
**I want to** rename a shopping list
**So that** I can keep my lists descriptively named as my needs change

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E4.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                              |
| --------- | ------------------------------------------------------------------------ |
| Use Cases | `RenameShoppingListUseCase(id, newName)` — validates non-empty           |
| UI        | Rename dialog pre-filled with current name (triggered from context menu) |
| Tests     | Unit: rename use case rejects empty name                                 |
| Tests     | Integration: rename → verify new name on card in overview                |

**Acceptance Criteria:**

- [ ] Rename option accessible from list card context menu
- [ ] Dialog shows current name pre-filled
- [ ] Empty name shows validation error
- [ ] Saving updates card name immediately
- [ ] Integration test: rename → verify new label on card

**UI Specification:**

Rename dialog — dark Material 3 alert dialog:

```
┌────────────────────────────────┐  bg #1E1E1E, radius 16px
│  Rename List                   │  ← white Poppins SemiBold
│  ┌──────────────────────────┐  │
│  │  Weekly Groceries        │  │  ← pre-filled input bg #2A2A2A, orange cursor
│  └──────────────────────────┘  │
│                  [Cancel] [Save]│  ← Save = orange text button
└────────────────────────────────┘
```

Validation: empty name shows red underline on input + helper text "Name cannot be empty".

---

_See [\_index.md](_index.md) for the full epic list._
