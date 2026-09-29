# Copilot Instructions — Shop List App

This file is automatically loaded as context by GitHub Copilot Chat for every conversation
in this workspace. Keep it updated with durable facts, conventions, and decisions so future
sessions don't need to be re-explained from scratch.

## Project Summary

Flutter Shopping List & Meal Planning app using **Clean Architecture**, **Riverpod**, and
**Drift (SQLite)**. Offline-first: Drift is the source of truth, cloud sync is optional/post-MVP.

## Tech Stack

- State management: `flutter_riverpod` (^2.6.1)
- Local DB: `drift` + `sqlite3_flutter_libs`, code-gen via `drift_dev`
- Functional error handling: `dartz` (`Either<Failure, T>`)
- Value equality: `equatable`
- Models/serialization: `freezed` + `json_serializable`
- Navigation: `go_router`
- Connectivity: `connectivity_plus`; Prefs: `shared_preferences`; IDs: `uuid`; Locale: `intl`
- Dart SDK: >=3.6.0 <4.0.0

## Architecture (strict layering, inner layers never depend on outer layers)

```
Presentation → Application (Use Cases) → Domain → Data
```

| Layer        | Responsibility                                                  |
| ------------ | --------------------------------------------------------------- |
| Presentation | Widgets, Pages, Riverpod Providers / StateNotifiers             |
| Application  | Use Cases — orchestrate domain logic                            |
| Domain       | Entities, Repository interfaces — pure Dart, no Flutter imports |
| Data         | Repository implementations, Drift DAOs, data sources            |

Each feature under `lib/features/<feature>/` owns its own `domain/`, `data/`, `presentation/`
subfolders. Current features: `shopping_lists`, `products`, `product_category`, `recipes`,
`meal_planning`, `pantry`, plus a `sync/` module (post-MVP cloud sync).

### `lib/` structure

```
lib/
├── main.dart              # Entry point — ProviderScope wraps App
├── app.dart
├── core/
│   ├── database/          # Drift AppDatabase + tables
│   ├── constants/
│   ├── error/             # Failures & Exceptions
│   ├── network/           # NetworkInfo, ApiClient
│   ├── utils/
│   ├── theme/              # AppColors, typography
│   ├── navigation/
│   ├── annotations/
│   └── providers/          # Core Riverpod providers (databaseProvider, …)
├── features/<feature>/{domain,data,presentation}/
└── shared/{widgets,extensions}/
```

## Conventions

- **Use cases** return `Future<Either<Failure, T>>`. Validate inputs first, return
  `Left(ValidationFailure(...))` on invalid input, wrap repository calls in try/catch returning
  `Left(DatabaseFailure(e.toString()))` on error, `Right(result)` on success.
- **Providers**: one `Provider` per use case in `<feature>_providers.dart`, wiring the repository
  provider. UI-only filter/selection state uses `StateProvider.autoDispose`.
- **Repositories**: abstract interface `I<Feature>Repository` in `domain/`, implementation in
  `data/` querying Drift tables directly (e.g. `_database.select(_database.pantryItems)`).
- **Async UI state**: use `AsyncValue.when(loading:, error:, data:)` for rendering and
  `state = await AsyncValue.guard(_fetchUpdatedData)` for mutations.
- **Colors**: always use `AppColors.*` constants from `lib/core/theme/colors.dart`, never raw hex
  literals in widget code.
- **Text style**: `fontFamily: 'Poppins'` is used throughout for consistency.
- **User feedback**: errors surfaced via `ScaffoldMessenger.of(context).showSnackBar(...)`.
- Context/theme access commonly goes through extension helpers in
  `lib/shared/extensions/context_extensions.dart` (e.g. `context.colorScheme`, `context.theme`).

## Codegen & Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift + Freezed codegen
flutter run
flutter test
```

## Testing Checklist (for new feature work)

- Unit tests for new use cases (validation + happy path)
- Unit tests for computed entity properties
- Widget tests for new screens/major widgets
- Error-case handling (empty states, failures)

## Notes / Related Docs

- [PANTRY_DEVELOPMENT_GUIDE.md](../PANTRY_DEVELOPMENT_GUIDE.md) — patterns for extending the
  Pantry feature (use cases, repository methods, filters, computed properties).
- [PANTRY_IMPLEMENTATION_SUMMARY.md](../PANTRY_IMPLEMENTATION_SUMMARY.md) and
  [PANTRY_ERRORS_FIXED.md](../PANTRY_ERRORS_FIXED.md) — history of pantry feature work and fixes.

## Session Log (append notable decisions/changes here)

- 2026-09-18: Created this instructions file to persist workspace context across chat sessions.
- 2026-09-29: Added five custom chat modes under `.github/chatmodes/`: **Code Writer**
  (implements features only), **Code Reviewer** (bugs/security/perf/quality, review-only),
  **Architecture Reviewer** (Clean Architecture/layering compliance, review-only), **Test Writer**
  (unit/widget/integration tests only), **Feature Pipeline** (orchestrates: Code Writer →
  Architecture Reviewer + Code Reviewer → loop-on-critical → Test Writer, for a single story), and
  **Project Audit Pipeline** (whole-codebase sweep: audit each feature unit → route clean units to
  Test Writer, flagged units to Code Writer → fix → re-audit → test).
- 2026-09-29: Ran the Project Audit Pipeline across the whole project (`pantry`, `shopping_lists`,
  `products`, `product_category`, `recipes`, `meal_planning`, `core`, `shared`). Findings fixed:
  - `pantry`: `pantry_providers.dart` now uses the shared `databaseProvider` instead of
    `AppDatabase.instance` directly (DI consistency).
  - `recipes`: presentation (`recipe_list_view.dart`) no longer touches `AppDatabase`/
    `ForceCategoryUpdate` directly — added `IRecipeRepository.fixMissingCategories()` +
    `FixRecipeCategoriesUseCase`, wired via `fixRecipeCategoriesUseCaseProvider`. Removed the dead,
    architecturally-broken `list_tile_component.dart` widget. Replaced `debugPrint`-only error
    handling with `SnackBar` feedback.
  - `meal_planning`: moved `MealType` enum out of
    `core/database/tables/meal_slot_table.dart` into `domain/entities/meal_type.dart` (domain was
    depending on a Drift table file). Refactored all 8 meal-planning use cases to follow the
    project's `Future<Either<Failure, T>>` convention (previously threw raw exceptions). Updated
    `WeeklyMealPlanNotifier` and 4 widget call sites (`menu_view.dart`,
    `recipe_picker_bottom_sheet.dart`) to surface failures via `SnackBar` instead of failing
    silently.
  - Added tests: `fix_recipe_categories_use_case_test.dart`, `save_recipe_use_case_test.dart`,
    `clear_meal_slot_use_case_test.dart`, `get_or_create_weekly_plan_use_case_test.dart`,
    `meal_slot_test.dart`, `add_product_use_case_test.dart`, `delete_product_use_case_test.dart`.
  - Verified: `dart run build_runner build --delete-conflicting-outputs` succeeded,
    `flutter analyze` has zero errors (only pre-existing lint infos/warnings unrelated to this
    work), and the full test suite passes (214/214).
  - Not fixed (flagged for a future pass, out of scope of that sweep): likely-dead prototype files
    `lib/core/theme/theme_providers.dart` / `theme_providers_new.dart` / `theme_simple.dart` and
    `lib/features/meal_planning/presentation/widgets/carousel/test_file.dart`; `Product` entity
    doesn't extend `Equatable` unlike other entities; several `withOpacity` deprecation lints; one
    unused variable in `recipe_detail_page.dart`; one `use_build_context_synchronously` warning in
    `settings_view_page.dart`.
- 2026-09-29: Added a sixth custom chat mode, **Recipe Image Agent**
  (`.github/chatmodes/recipe-image-agent.chatmode.md`), whose sole job is generating an image for
  a recipe (based on its name/category/ingredients) and saving it under
  `assets/images/recipes/<slug>.jpg`, wiring the `imageUrl` field in
  `assets/data/recipes.json`. Hard requirement: output file must be ≤50KB. It prefers an
  AI image-generation tool if one is available in the session (always run through the
  compression step afterwards), otherwise falls back to the new dev-tool script
  [tool/generate_recipe_image.dart](../tool/generate_recipe_image.dart) — a deterministic
  placeholder-image generator built on the `image` package (added as a dev dependency) that draws
  a gradient card seeded from the recipe's category/name, a category badge, the recipe title, and
  an ingredients preview, then iteratively lowers JPEG quality/dimensions until the file is under
  budget. Supports `--all` (backfill every recipe missing an image, updating `imageUrl` as needed),
  `--force`, `--dry-run`, and single-recipe `--name/--category/--ingredients/--out` modes.
  Verified: `flutter pub get` resolved `image: ^4.2.0` (got 4.8.0), and a manual test run
  (`dart run tool/generate_recipe_image.dart --name "Test Recipe Image" ...`) produced a 33.8KB
  JPEG, comfortably under the 50KB budget.
