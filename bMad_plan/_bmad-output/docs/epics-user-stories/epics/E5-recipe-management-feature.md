# E5: Recipe Management Feature

**Story Count:** 5 | **Total Points:** 26 | **Priority:** P0 | **Sprint:** 3–4

---

## Epic Goal

Users can create, browse, edit, and use recipes with ingredients and step-by-step instructions.

> **Note:** Recipe table, entity, and a repository implementation already exist. Stories wire in use cases, Riverpod providers, and build full UI for complete end-to-end testability.

---

## Existing Files to Wire Up

| File                                                             | Status     |
| ---------------------------------------------------------------- | ---------- |
| `core/database/tables/recipe_table.dart`                         | ✅ Exists  |
| `features/recipes/domain/entities/recipe.dart`                   | ✅ Exists  |
| `features/recipes/domain/repositories/i_recipe_repository.dart`  | ✅ Exists  |
| `features/recipes/data/repositories/recipe_repository.dart`      | ✅ Exists  |
| `features/recipes/presentation/pages/recipe_list_view.dart`      | ✅ Exists  |
| `features/recipes/presentation/widgets/list_tile_component.dart` | ✅ Exists  |
| Use Cases                                                        | ❌ Missing |
| Riverpod Providers                                               | ❌ Missing |
| `RecipeDetailPage`                                               | ❌ Missing |
| `RecipeFormPage`                                                 | ❌ Missing |

---

## Stories

### US-E5.1: Recipe List & Detail View

**As a** user
**I want to** browse all my recipes and tap one to see full details
**So that** I can find and review a recipe before cooking

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                    |
| --------- | ---------------------------------------------------------------------------------------------- |
| DB        | `RecipesTable` (exists) — verify all columns; `IngredientsTable` as child table or JSON column |
| Domain    | `Recipe` entity (exists) — verify `Ingredient` value object, `scaleServings()`, `totalTime`    |
| Domain    | `IRecipeRepository` — `watchAll()`, `getById(id)`, `save()`, `delete(id)`, `search(query)`     |
| Data      | `RecipeDataSource` (Drift DAO) + `RecipeRepositoryImpl` (exists — verify exception mapping)    |
| Use Cases | `WatchRecipesUseCase`, `GetRecipeByIdUseCase(id)`                                              |
| Providers | `recipeRepositoryProvider`, `recipesProvider` (StreamProvider), `recipeDetailProvider(id)`     |
| State     | `RecipeListNotifier`                                                                           |
| UI        | `RecipeListPage` (exists) — wire to Riverpod stream                                            |
| UI        | `RecipeDetailPage` — title, image, time badges, ingredient list, instruction steps             |
| Tests     | Widget: `RecipeListPage` renders 3 mocked recipes                                              |
| Tests     | Widget: `RecipeDetailPage` shows ingredients and instruction steps                             |
| Tests     | Integration: open Recipes tab → tap recipe → verify detail page                                |

**Acceptance Criteria:**

- [ ] Recipe list shows title, thumbnail, total time, and serving count
- [ ] Tapping a recipe navigates to detail page
- [ ] Detail page shows ingredients with quantities and units
- [ ] Detail page shows numbered instruction steps
- [ ] Loading state shown while recipes load from DB
- [ ] Integration test: launch app → Recipes tab → tap recipe → verify detail

**UI Specification:**

Recipe List Page (dark grid):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Recipes                       [🔍] [⋮]        │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  [All] [⭐ Faves] [🕐 Recent] [🥗 Healthy]    │  ← pill chips; active = orange #FF6B35
├─────────────────────────────────────────────────┤
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │[Full img] │  │  ← full-bleed 4:3, radius 16px
│  │▓ Chicken  │  │▓ Pasta    │  │▓ Salmon   │  │  ← gradient + title overlaid bottom
│  │   Tacos   │  │   Carbonar│  │   Teriyaki│  │
│  │ ⭐4.8 30m │  │ ⭐4.5 20m │  │ ⭐4.7 40m │  │
│  └───────────┘  └───────────┘  └───────────┘  │
└─────────────────────────────────────────────────┘
    ┌────────────────┐
    │  + New Recipe  │  ← Extended FAB, orange bg #FF6B35
    └────────────────┘
```

Recipe Detail Page (dark):

```
┌─────────────────────────────────────────────────┐
│  ← (transparent)                    ⭐  [⋮]   │  ← over hero image
│  [Full-bleed 16:9 hero image]                   │
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ← gradient to #CC000000  │
├─────────────────────────────────────────────────┤  content card #1E1E1E top-radius 24px
│  Chicken Tacos              [− 4 servings +]    │  ← serving scaler inline
│  ⭐ 4.5  (12 ratings)                          │
│  [🕐30m] [🍽️4 serv.] [🔥Medium]             │  ← orange-bordered badge chips
│  [Ingredients] [Instructions] [Notes]           │  ← orange underline active tab
│  🥬 Produce  ○ Lettuce 1hd  ○ Tomatoes 2pcs   │
│  🥩 Meat     ○ Chicken 500g                    │
│  [Add to Meal Plan]  [Start Cooking 🔥]        │  ← outlined / orange buttons
└─────────────────────────────────────────────────┘
```

---

### US-E5.2: Create & Edit Recipe

**As a** user
**I want to** add new recipes and edit existing ones with full details
**So that** I can build my personal recipe collection

**Story Points:** 8 | **Priority:** P0 | **Dependencies:** US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                      |
| --------- | ---------------------------------------------------------------------------------------------------------------- |
| Use Cases | `SaveRecipeUseCase(recipe)` — validates non-empty title + at least 1 ingredient, generates UUID, sets timestamps |
| Use Cases | `ValidateRecipeUseCase(recipe)` → `Either<ValidationFailure, Recipe>`                                            |
| State     | `RecipeFormNotifier` — manages multi-section form draft state                                                    |
| UI        | `RecipeFormPage` — 3 sections: (1) basics, (2) ingredients, (3) instructions                                     |
| UI        | `IngredientInputRow` — name typeahead from product catalogue, quantity, unit selector                            |
| UI        | `InstructionStepList` — numbered, reorderable, add/remove steps                                                  |
| UI        | Save button in app bar — spinner while saving                                                                    |
| UI        | Edit mode: `RecipeDetailPage` "Edit" button → `RecipeFormPage` pre-filled                                        |
| Tests     | Unit: `SaveRecipeUseCase` rejects empty title                                                                    |
| Tests     | Unit: `SaveRecipeUseCase` sets `createdAt` on new recipe                                                         |
| Tests     | Widget: ingredient typeahead suggests matching products                                                          |
| Tests     | Integration: fill form → save → appears in recipe list → open detail                                             |

**Acceptance Criteria:**

- [ ] FAB on recipe list opens new recipe form
- [ ] Form has 3 clearly labelled sections
- [ ] Ingredient input suggests from product catalogue with free-text fallback
- [ ] Can add, remove, and reorder ingredients and instruction steps
- [ ] Saving with empty title shows inline error on title field
- [ ] Must have at least 1 ingredient (or warning shown)
- [ ] After save, navigates back to list; new recipe appears
- [ ] Integration test: full form fill → save → verify in list → check detail

**UI Specification:**

Recipe Form Page — 3-section dark form:

```
┌─────────────────────────────────────────────────┐  bg #121212
│  ←   New Recipe                        [Save]   │  ← Save = orange text
├─────────────────────────────────────────────────┤
│  ━━━━━━━━░░░░░░░░  Step 1 of 3: Basics          │  ← orange step progress bar
│  ┌──────────────────────────────────────────┐   │
│  │  Recipe name *                           │   │  ← input bg #2A2A2A, orange cursor
│  └──────────────────────────────────────────┘   │
│  [+ Add cover photo]                            │  ← dashed orange border upload zone
│  🕐 Prep  [ 15 min ]   🕐 Cook  [ 30 min ]    │
│  🍽️ Servings  [−  4  +]                        │
├─────────────────────────────────────────────────┤
│  ━━━━━━━━━━━━░░░░  Step 2 of 3: Ingredients     │
│  🔍 Search or type ingredient name...           │  ← pill input #2A2A2A
│  ┌───────────────────────────────────────────┐  │
│  │  Chicken breast  [500] [g ▾]    [🗑]       │  │  ← ingredient row, trash = orange
│  │  Lettuce         [1]   [head ▾] [🗑]       │  │
│  └───────────────────────────────────────────┘  │
│  [+ Add ingredient]  ← orange text button       │
├─────────────────────────────────────────────────┤
│  ━━━━━━━━━━━━━━━━  Step 3 of 3: Instructions    │
│  ┌───────────────────────────────────────────┐  │
│  │  ● 1  Heat oil in skillet...       [🗑]   │  │  ← step card bg #2A2A2A
│  │  ● 2  Add seasoning...             [🗑]   │  │  ← ● = orange circle
│  └───────────────────────────────────────────┘  │
│  [+ Add step]  ← orange text button             │
└─────────────────────────────────────────────────┘
```

---

### US-E5.3: Delete Recipe

**As a** user
**I want to** delete recipes I no longer need
**So that** my collection stays manageable

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E5.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                           |
| --------- | ------------------------------------------------------------------------------------- |
| Use Cases | `DeleteRecipeUseCase(id)` — soft delete; returns `ConflictFailure` if in a meal plan  |
| UI        | Delete option in `RecipeDetailPage` overflow menu                                     |
| UI        | Confirmation dialog: "Remove [name] from your recipes?"                               |
| UI        | If recipe is in meal plan: "This recipe is in your meal plan. Delete anyway?"         |
| Tests     | Unit: delete use case returns `ConflictFailure` when recipe is in an active meal plan |
| Tests     | Integration: delete recipe → no longer in list                                        |

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

| Layer     | Deliverable                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| Data      | `searchRecipes(query)` Drift query — searches title + description                 |
| Data      | `filterByTags(tags)` — JSON contains search on `tagsJson` column                  |
| Use Cases | `SearchRecipesUseCase(query, tags?)` — combined search + filter                   |
| State     | `RecipeSearchNotifier` — query + tag filters + 300 ms debounce                    |
| UI        | Search bar in `RecipeListPage` (collapses by default, expands on search icon tap) |
| UI        | Tag filter chips below search bar (filled from `WatchAllTagsUseCase`)             |
| Tests     | Unit: search returns only recipes whose title contains query                      |
| Tests     | Widget: typing "pasta" filters to pasta recipes                                   |

**Acceptance Criteria:**

- [ ] Search bar expands on tapping the search icon
- [ ] Recipes filter as user types (300 ms debounce)
- [ ] Tag chips toggle on/off; active chips shown as filled
- [ ] Combined name + tag filter works
- [ ] "No recipes found" empty state with hint to clear filters
- [ ] Clearing all filters restores full list

**UI Specification:**

Expanded search bar + tag chips (collapses when not active):

```
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  pasta                             [✕]│  │  ← expanded pill input bg #2A2A2A
│  └───────────────────────────────────────────┘  │
│  [Quick] [🌱 Vegan] [🔥 Spicy] [❤️ Healthy]   │  ← tag chips; active = orange fill
├─────────────────────────────────────────────────┤
│  Showing 3 of 24 recipes                        │  ← textSecondary helper text
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │           │  │
│  │▓ Pasta    │  │▓ Pasta    │  │  No more  │  │
│  │   Carbonar│  │   Bake    │  │           │  │
│  └───────────┘  └───────────┘  └───────────┘  │
```

300 ms debounce on text input; no results state shows magnifying glass icon + "Try different keywords".

---

### US-E5.5: Recipe Serving Scaler

**As a** user
**I want to** adjust the serving count on a recipe and see scaled ingredient quantities
**So that** I can cook for different group sizes without manual calculation

**Story Points:** 3 | **Priority:** P1 | **Dependencies:** US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| Domain    | `Recipe.scaleServings(newServings)` (verify on entity)                            |
| Use Cases | `ScaleRecipeUseCase(recipe, newServings)` → scaled `Recipe` in memory (not saved) |
| State     | `servingCountProvider(recipeId)` — session-only overridable state                 |
| UI        | Serving stepper (`−` / count / `+`) in `RecipeDetailPage` header                  |
| UI        | Ingredient quantities update live as serving count changes                        |
| UI        | Reset button restores original serving count                                      |
| Tests     | Unit: `ScaleRecipeUseCase` — 2 cups flour for 4 servings → 3 cups for 6           |
| Tests     | Widget: tap `+` → ingredient quantities update                                    |

**Acceptance Criteria:**

- [ ] Serving counter in recipe detail header
- [ ] `+` / `−` adjusts serving count (minimum 1)
- [ ] All ingredient quantities scale proportionally, displayed as readable fractions
- [ ] Reset button restores original defaults
- [ ] Scaled quantities are NOT persisted to DB (session only)

**UI Specification:**

Serving scaler inline in Recipe Detail header:

```
│  Chicken Tacos                                  │
│  ⭐ 4.5  (12 ratings)                          │
│  ┌────────────────────────────────────┐        │
│  │  [🍽️ Servings]   [−]  6  [+]     │        │  ← badge chip with inline stepper
│  └────────────────────────────────────┘        │  ← border orange #FF6B35
```

Ingredient list updates live (no animation needed, just instant rerender):

```
│  ○  Chicken breast   750g  (was 500g)           │  ← scaled qty in white; "was X" textSecondary
│  ○  Taco seasoning   3 tbsp (was 2 tbsp)        │
```

Reset button: small grey text button `↺ Reset to 4` visible when count ≠ original.

---

_See [\_index.md](_index.md) for the full epic list._
