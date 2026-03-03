# E6: Meal Planning Feature

**Story Count:** 4 | **Total Points:** 22 | **Priority:** P0 | **Sprint:** 4–5

---

## Epic Goal

Users can plan weekly meals by assigning recipes to breakfast/lunch/dinner slots, then generate a shopping list from the plan.

> **Note:** A UI skeleton (calendar, menu views) already exists under `features/meal_planning/presentation/`. Stories add the full data layer, domain, use cases, and wire everything together.

---

## Existing Files to Wire Up

| File                                                                                       | Status     |
| ------------------------------------------------------------------------------------------ | ---------- |
| `features/meal_planning/presentation/pages/menu_view.dart`                                 | ✅ Exists  |
| `features/meal_planning/presentation/pages/menu_composer_view.dart`                        | ✅ Exists  |
| `features/meal_planning/presentation/widgets/calendar_component.dart`                      | ✅ Exists  |
| `features/meal_planning/presentation/widgets/menu_container_component.dart`                | ✅ Exists  |
| `features/meal_planning/presentation/widgets/carousel/` (date_selector, filter_item, etc.) | ✅ Exists  |
| DB tables (`MealPlansTable`, `MealSlotsTable`)                                             | ❌ Missing |
| Domain entities (`MealPlan`, `MealSlot`)                                                   | ❌ Missing |
| Repository interface + implementation                                                      | ❌ Missing |
| Use Cases                                                                                  | ❌ Missing |
| Riverpod Providers + State Notifier                                                        | ❌ Missing |

---

## Stories

### US-E6.1: Weekly Meal Plan View

**As a** user
**I want to** see a weekly calendar with meal slots (breakfast, lunch, dinner) for each day
**So that** I can plan my meals for the week ahead

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                 |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| DB        | `MealPlansTable`: `id`, `weekStartDate`, `createdAt`                                                                                        |
| DB        | `MealSlotsTable`: `id`, `planId` (FK), `date`, `mealType` (enum: breakfast/lunch/dinner), `recipeId` (FK nullable), `customName` (nullable) |
| Domain    | `MealPlan` entity + `MealSlot` value object                                                                                                 |
| Domain    | `IMealPlanRepository`: `watchByWeek(weekStart)`, `save()`, `clearSlot(slotId)`                                                              |
| Data      | `MealPlanDataSource` + `MealPlanRepositoryImpl`                                                                                             |
| Use Cases | `GetOrCreateWeeklyPlanUseCase(weekStart)` — creates plan if none exists for that week                                                       |
| Use Cases | `WatchWeeklyPlanUseCase(weekStart)`                                                                                                         |
| Providers | `mealPlanRepositoryProvider`, `weeklyPlanProvider(weekStart)`                                                                               |
| State     | `MealPlanNotifier(weekStart)`                                                                                                               |
| UI        | Wire existing `MenuView` / `CalendarComponent` to Riverpod stream                                                                           |
| UI        | Week navigation (prev/next week arrows)                                                                                                     |
| UI        | Empty slot shows "+" placeholder; filled slot shows recipe name + thumbnail                                                                 |
| Tests     | Unit: `GetOrCreateWeeklyPlanUseCase` creates plan for a new week                                                                            |
| Tests     | Widget: calendar shows 7 days × 3 meal types grid                                                                                           |
| Tests     | Integration: navigate to Meal Planning tab → see empty week grid                                                                            |

**Acceptance Criteria:**

- [ ] Meal Planning tab shows current week by default
- [ ] 7 columns (days) × 3 rows (breakfast/lunch/dinner) grid
- [ ] Empty slots show "+" tap target
- [ ] Week header shows date range (e.g., "Mar 3 – Mar 9")
- [ ] Prev/Next arrows navigate between weeks
- [ ] Integration test: open tab → grid renders correctly

**UI Specification:**

Weekly Meal Calendar page (dark):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Meal Plan           Feb 26 – Mar 4    ← →   │  ← white Poppins SemiBold + week arrows
├─────────────────────────────────────────────────┤
│  [Mon] [Tue] [Wed] [Thu] [Fri] [Sat] [Sun]   │  ← day pills; active = orange #FF6B35
├─────────────────────────────────────────────────┤
│  Monday, Feb 26                                 │
│  🌅 Breakfast  [+ Tap to add]                  │  ← dashed orange border empty slot
│  🌞 Lunch      [+ Tap to add]                  │
│  🌙 Dinner     [+ Tap to add]                  │
└─────────────────────────────────────────────────┘
```

Design tokens: day chip active bg `#FF6B35`; empty slot border = dashed `#FF6B35` 1px; meal-type label `#9CA3AF`; filled slot card bg `#1E1E1E` radius 14 px.

---

### US-E6.2: Assign Recipe to Meal Slot

**As a** user
**I want to** assign a recipe to a meal slot by tapping on it
**So that** I can plan what I will cook each day

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E6.1, US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                        |
| --------- | ---------------------------------------------------------------------------------- |
| Use Cases | `AssignRecipeToSlotUseCase(slotId, recipeId)` — upserts slot with recipe reference |
| Use Cases | `ClearMealSlotUseCase(slotId)` — sets recipeId to null                             |
| UI        | Tapping empty slot opens `RecipePickerBottomSheet` (searchable recipe list)        |
| UI        | Tapping filled slot shows context menu: "Change Recipe" / "Clear Slot"             |
| UI        | After assignment, slot shows recipe thumbnail and name                             |
| Tests     | Unit: `AssignRecipeToSlotUseCase` stores `recipeId` on correct slot                |
| Tests     | Widget: recipe picker renders recipes from stream                                  |
| Tests     | Integration: tap slot → pick recipe → slot shows recipe name                       |

**Acceptance Criteria:**

- [ ] Tapping an empty slot opens recipe picker
- [ ] Picker has a search bar to filter recipes
- [ ] Tapping a recipe in the picker assigns it and closes the sheet
- [ ] Slot immediately shows assigned recipe name (+ thumbnail if available)
- [ ] Tapping a filled slot shows context menu (Change / Clear)
- [ ] Clearing a slot resets it to the "+" placeholder
- [ ] Integration test: assign → verify slot displays recipe name

**UI Specification:**

Filled slot card + Recipe Picker Bottom Sheet:

```
Filled slot:
│  🌙 Dinner                                     │
│  ┌───────────────────────────────────────────┐  │
│  │ [img] Chicken Tacos                        │  │  ← card bg #1E1E1E radius 14px
│  │       🕐 30 min  •  ⚠️ 2 missing ingred.  │  │  ← ⚠️ in orange
│  └───────────────────────────────────────────┘  │

Recipe Picker Bottom Sheet (dark):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  Select — Monday Dinner                    │  ← drag handle + white title
│  🔍  Search recipes...  (pill, bg #2A2A2A)     │
│  [All] [⭐] [🔥 Trending] [⏰ <30min]          │  ← orange-active pill chips
│  🧑‍🍳 What Can I Make? (23)  ← orange icon      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │[Full img] │  │  ← same full-bleed cards
│  │▓ Chicken  │  │▓ Pasta    │  │▓ Salmon   │  │
│  └───────────┘  └───────────┘  └───────────┘  │
└─────────────────────────────────────────────────┘
```

Filled-slot context menu (dark `#1E1E1E`): **Change Recipe** / **Clear Slot** / Cancel.

---

### US-E6.3: Generate Shopping List from Meal Plan

**As a** user
**I want to** generate a shopping list from my weekly meal plan
**So that** I don't have to copy ingredient lists manually from each recipe

**Story Points:** 6 | **Priority:** P0 | **Dependencies:** US-E6.2, US-E4.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                                                             |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Use Cases | `GenerateShoppingListFromPlanUseCase(planId, listName)` — collects ingredients from all assigned recipes, aggregates quantities by ingredient name + unit, creates a new `ShoppingList` |
| Domain    | Aggregation rule: same name + same unit → sum quantities; different units kept separate                                                                                                 |
| State     | `GenerateListNotifier` — loading / error / success states                                                                                                                               |
| UI        | "Generate Shopping List" button at bottom of meal plan screen                                                                                                                           |
| UI        | Confirmation sheet: shows recipe count + estimated item count                                                                                                                           |
| UI        | On success: navigate to the newly created shopping list detail page                                                                                                                     |
| Tests     | Unit: aggregation merges "2 cups flour" + "1 cup flour" → "3 cups flour"                                                                                                                |
| Tests     | Unit: "2 cups" + "1 tsp" kept as separate items (different units)                                                                                                                       |
| Tests     | Integration: plan with 2 recipes → generate → shopping list created with all ingredients                                                                                                |

**Acceptance Criteria:**

- [ ] "Generate Shopping List" button visible on meal plan screen
- [ ] Confirmation sheet shows recipe count and estimated item count before creating
- [ ] Generated list is named after the week (e.g., "Week of Mar 3")
- [ ] Duplicate ingredients (same name + unit) are combined
- [ ] After generation, navigation goes to the new shopping list detail page
- [ ] Integration test: assign recipes → generate list → verify aggregated items

**UI Specification:**

Generate Shopping List — confirmation sheet (dark):

```
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  Generate Shopping List                    │  ← drag handle + Poppins SemiBold
│  Week of Feb 26 – Mar 4                         │
│  ─────────────────────────────────────────      │
│  📚  5 recipes assigned                         │
│  📝  Estimated 28 ingredients                   │
│  🔗  Duplicates will be merged automatically    │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  📋  Create "Week of Feb 26" list          │  │  ← orange full-width button
│  └───────────────────────────────────────────┘  │
│  [Cancel]  ← grey text button                   │
└─────────────────────────────────────────────────┘
```

Progress bottom sheet shown during generation: circular orange indicator + "Building your list…" text.

---

### US-E6.4: Meal Plan Duplication & Clearing

**As a** user
**I want to** duplicate a past week's plan into the current week and clear individual days or the entire week
**So that** I can reuse meal combinations I enjoyed

**Story Points:** 4 | **Priority:** P2 | **Dependencies:** US-E6.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                            |
| --------- | -------------------------------------------------------------------------------------- |
| Use Cases | `DuplicateMealPlanUseCase(sourceWeekStart, targetWeekStart)` — copies slot assignments |
| Use Cases | `ClearDayUseCase(planId, date)` — removes all 3 slot assignments for a given day       |
| Use Cases | `ClearWeekUseCase(planId)` — removes all assignments for the week                      |
| UI        | Week header overflow menu: "Copy from Previous Week" / "Clear Week"                    |
| UI        | Day column long-press: "Clear Day"                                                     |
| Tests     | Unit: duplicate use case copies all slot assignments to target week                    |
| Tests     | Integration: duplicate previous plan → current week shows same recipes                 |

**Acceptance Criteria:**

- [ ] Overflow menu on week header has duplicate and clear options
- [ ] Duplicating copies recipe assignments (does not generate a shopping list)
- [ ] Clearing a day removes all 3 slots for that day
- [ ] Clearing the week removes all assignments; does not delete shopping lists
- [ ] Confirmation dialog shown before "Clear Week"

**UI Specification:**

Week header overflow menu + confirmation dialog (dark):

```
Week header:  Meal Plan  Feb 26 – Mar 4  ← →  [⋮]
                                         ┌──────────────────────┐
                                         │  Copy from Prev. Week │  ← menu bg #1E1E1E
                                         │  Clear Week           │  ← red text
                                         └──────────────────────┘

Confirmation dialog:
┌──────────────────────────────────┐  bg #1E1E1E radius 16px
│  Clear the entire week?          │
│  All recipe assignments for      │
│  Feb 26 – Mar 4 will be removed. │
│  Shopping lists are not affected. │
│              [Cancel]  [Clear]    │  ← Clear = red #EF4444 text
└──────────────────────────────────┘
```

---

_See [\_index.md](_index.md) for the full epic list._
