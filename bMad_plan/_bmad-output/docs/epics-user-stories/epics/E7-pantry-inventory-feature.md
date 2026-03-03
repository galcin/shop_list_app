# E7: Pantry Inventory Feature

**Story Count:** 3 | **Total Points:** 16 | **Priority:** P0 | **Sprint:** 5

---

## Epic Goal

Users can track what they already have at home, update quantities, and see what is about to expire.

> **Note:** Pantry feature is not yet started. This epic creates it from scratch, all layers.

---

## Stories

### US-E7.1: Pantry Item CRUD

**As a** user
**I want to** add, view, and remove items from my pantry inventory
**So that** I know what I already have and can avoid buying duplicates

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                                                                                       |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DB        | `PantryItemsTable`: `id`, `productId` (FK nullable), `name`, `quantity`, `unit`, `categoryId`, `expiryDate` (nullable), `purchasedDate`, `location` (nullable), `createdAt`, `updatedAt`, `isSynced`, `isDeleted` |
| Domain    | `PantryItem` entity: `isExpired`, `daysUntilExpiry`, `copyWith()`                                                                                                                                                 |
| Domain    | `IPantryRepository`: `watchAll()`, `save()`, `delete(id)`, `watchExpiringSoon(days)`                                                                                                                              |
| Data      | `PantryDataSource` + `PantryRepositoryImpl`                                                                                                                                                                       |
| Use Cases | `WatchPantryItemsUseCase`, `AddPantryItemUseCase(name, qty, unit, categoryId?, expiryDate?)`                                                                                                                      |
| Use Cases | `DeletePantryItemUseCase(id)`                                                                                                                                                                                     |
| Providers | `pantryRepositoryProvider`, `pantryItemsProvider`                                                                                                                                                                 |
| State     | `PantryNotifier`                                                                                                                                                                                                  |
| UI        | `PantryPage` — items grouped by category; FAB to add                                                                                                                                                              |
| UI        | `AddPantryItemBottomSheet` — name (from catalogue or free-text), qty, unit, expiry date picker                                                                                                                    |
| UI        | Swipe-to-delete with undo                                                                                                                                                                                         |
| Tests     | Unit: `AddPantryItemUseCase` rejects quantity ≤ 0                                                                                                                                                                 |
| Tests     | Widget: pantry page renders items grouped by category                                                                                                                                                             |
| Tests     | Integration: add item → appears in pantry list                                                                                                                                                                    |

**Acceptance Criteria:**

- [ ] Pantry tab shows items grouped by category
- [ ] FAB opens add-item form with optional expiry date picker
- [ ] Item row shows: name, quantity + unit, expiry date (if set)
- [ ] Swipe-to-delete with undo snackbar
- [ ] Integration test: add → verify → delete → verify removed

**UI Specification:**

Pantry Inventory page (dark):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Pantry                          [🔍] [⋮]      │
├─────────────────────────────────────────────────┤
│  🥛 Dairy                                  [▾] │  ← collapsible section, white label
│  ┌───────────────────────────────────────────┐  │
│  │  🥛  Milk (2L)                  🔴 1.5L   │  │  ← item card bg #1E1E1E, radius 12px
│  │       Exp: Feb 28 (2 days)  [− 1.5 +]    │  │  ← red dot urgent; inline qty stepper
│  ├───────────────────────────────────────────┤  │
│  │  🧀  Cheddar                    🟡 250g   │  │  ← amber dot = use soon
│  │       Exp: Mar 5 (7 days)   [− 250g +]   │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange
    └─────┘

Add Pantry Item Bottom Sheet (dark):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  Add Pantry Item                           │
│  🔍  Search or enter item name...  (#2A2A2A)   │
│  [Qty: 1.0]  [Unit: kg ▾]                      │
│  📅  Expiry date (optional)  → date picker      │  ← orange calendar icon
│  [+ Add to Pantry]  ← orange full-width button  │
└─────────────────────────────────────────────────┘
```

Swipe-left on item → **Delete** (red bg `#EF4444`) with undo snackbar.

---

### US-E7.2: Quick Quantity Adjustment

**As a** user
**I want to** quickly update the quantity of a pantry item by tapping + or −
**So that** I can update my pantry without opening a full edit form

**Story Points:** 4 | **Priority:** P1 | **Dependencies:** US-E7.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| Use Cases | `UpdatePantryItemQuantityUseCase(id, newQuantity)` — clamps to minimum 0       |
| State     | Optimistic update in `PantryNotifier`                                          |
| UI        | Inline stepper (`−` / qty / `+`) on each pantry item row                       |
| UI        | Quantity = 0 → item dims with "Out of stock" badge (not deleted automatically) |
| UI        | Tapping item row (not stepper) → `EditPantryItemPage` (full edit form)         |
| Tests     | Unit: update use case clamps quantity to 0 minimum                             |
| Tests     | Widget: tap `+` increases displayed quantity; tap `−` decreases                |

**Acceptance Criteria:**

- [ ] Each pantry row has visible `−` and `+` buttons
- [ ] Quantity updates instantly (optimistic)
- [ ] Quantity cannot go below 0
- [ ] Items at 0 show a visual "Out of stock" indicator
- [ ] Full edit (name, unit, expiry) accessible by tapping the row

**UI Specification:**

Inline quantity stepper on pantry rows:

```
│  🥛  Milk (2L)                  🔴 1.5L   │  ← red dot
│  Exp: Feb 28 (2 days)    [−]  1.5L  [+]  │  ← stepper; − / + = white on #2A2A2A bg

Quantity = 0 state:
│  🥛  Milk (2L)             ⚪ Out of stock │  ← grey dot, item dims to 50% opacity
│  Exp: Feb 28 (2 days)    [−]   0   [+]   │
```

Tapping anywhere else on the row (not the stepper buttons) → opens `EditPantryItemPage` (full edit form) — same dark theme as Add sheet.

---

### US-E7.3: Expiry Tracking & Alerts

**As a** user
**I want to** see which pantry items are expiring soon
**So that** I can use them before they go to waste

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E7.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                        |
| --------- | ---------------------------------------------------------------------------------- |
| Domain    | `PantryItem.expiryStatus` enum: `fresh`, `expiringSoon` (< 3 days), `expired`      |
| Use Cases | `WatchExpiringSoonUseCase(withinDays: 3)` → stream of items expiring within N days |
| Providers | `expiringSoonProvider`                                                             |
| UI        | Badge on Pantry nav tab showing count of expiring items                            |
| UI        | "Expiring Soon" collapsible banner at top of pantry page                           |
| UI        | Colour-coded expiry chips on item rows: yellow = expiring soon, red = expired      |
| UI        | "Show expiring only" filter chip                                                   |
| Tests     | Unit: `WatchExpiringSoonUseCase` returns only items within threshold               |
| Tests     | Widget: badge shows correct count                                                  |
| Tests     | Integration: add item with expiry tomorrow → badge shows 1                         |

**Acceptance Criteria:**

- [ ] Nav tab badge shows expiring item count (hidden when 0)
- [ ] "Expiring Soon" banner appears when ≥ 1 item expires within 3 days
- [ ] Item rows show colour-coded expiry chip
- [ ] "Show expiring only" filter chip toggles filtered view
- [ ] Integration test: add item expiring tomorrow → badge shows 1

**UI Specification:**

Expiry alert banner + freshness dots:

```
Alert banner (shown when ≥1 expiring within 3 days):
┌───────────────────────────────────────────────┐
│  ⚠️  3 items expiring within 3 days           │  ← bg #2A1F16, left stripe orange, radius 12px
│       Tap to view →                           │
└───────────────────────────────────────────────┘

Freshness dot key:
  🔴  Urgent < 3 days
  🟡  Use soon 3–7 days
  🟢  Fresh 8+ days
  ⚪  No expiry date

Nav tab badge (Pantry icon):
  ┌───┐
  │🥫 │  ← badge = orange pill with white count
  │ 3 │
  └───┘

"Show expiring only" filter chips row:
  [All] [🚨 Expiring] [🟢 Fresh]  ← orange active chip
```

Expiring Soon detail page: item cards with mini full-bleed recipe suggestion thumbnails below each expiring item (see Pantry Screens wireframe in `ui-wireframes-specification.md`).

---

_See [\_index.md](_index.md) for the full epic list._
