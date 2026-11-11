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
- **Colors**: always theme via `Theme.of(context).colorScheme.*` (or the `context.colorScheme` /
  `context.theme` extensions) in widget code — **never** raw hex `Color(0xFF...)` literals and
  **never** the legacy `AppColors.*` constants from `lib/core/theme/colors.dart` (those are fixed,
  single-theme values left over from an early dark-only design and do **not** react to the
  Dark/Light/Green theme switch; using them is a recurring bug class — see the 2026-11-11 session
  log entry for a real instance). `AppColors` should be treated as deprecated for new/edited UI
  code; prefer `colorScheme.surface`, `onSurface`, `onSurfaceVariant`, `primary`, `error`, etc.
- **Text style**: `fontFamily: 'Poppins'` is used throughout for consistency.
- **User feedback**: errors surfaced via `ScaffoldMessenger.of(context).showSnackBar(...)`.
- Context/theme access commonly goes through extension helpers in
  `lib/shared/extensions/context_extensions.dart` (e.g. `context.colorScheme`, `context.theme`).
- **Detail page pattern** (established by `RecipeDetailPage`; also applied to
  `ProductCategoryDetailPage` and `ProductDetailPage`): entity "detail" screens should be a
  `Scaffold` → `CustomScrollView` with:
  - A pinned `SliverAppBar` (`expandedHeight: ~220-260`, `pinned: true`,
    `backgroundColor: theme.colorScheme.surface`) whose `flexibleSpace` is a `Stack` hero: a
    background tint/image (accent-coloured tint or the entity's photo/emoji inside a rounded
    card), then a `DecoratedBox` gradient from `Colors.transparent` to `theme.colorScheme.surface`
    (stops `[0.6, 1.0]`) so the hero fades into the content below instead of hard-cutting.
    Back/edit/delete actions live in the app bar's `leading`/`actions`, not duplicated as buttons
    further down the page.
  - Below the hero: the entity title (Poppins, w700, ~22px), then a `Wrap` of small pill/badge
    chips (bordered with the entity's accent colour, small leading `Icon`, 12-13px label text in
    `onSurfaceVariant`) for secondary metadata (category, unit, tags, servings, "Catalogue
    product", etc.) — this replaces older stacked `InfoRow`/`ListTile`-style metadata blocks.
  - **Never surface raw internal/database identifiers** in this UI (no "Product #12",
    "Category #2", raw hex colour strings, etc.) — if an id-like value is useful for
    debugging, it belongs in logs/diagnostics, not the user-facing detail page.
  - Any feature-specific sections below (ingredients list, products list, etc.) are separate
    `ConsumerWidget`s that take the parent's resolved accent colour so nested list tiles (e.g.
    `CategoryProductTile`) stay visually consistent with the header.
  - List tiles that open a detail page should also follow the "round avatar overlapping a card"
    look (`AccentCircleListCard` + `CircleAccentAvatar` + the entity's image widget), be tappable
    (`onTap` → push the detail page), long-press to edit, and swipe (`Dismissible`) to delete —
    see `CategoryProductTile` / `ProductViewPage`'s product rows as the reference implementation.

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
- 2026-10-02: Audited implementation status against
  `../../bMad_plan/_bmad-output/docs/epics-user-stories/epics/` (E0-E15, v5.0 vertical-slice
  plan). Summary — **MVP epics E0-E7 are essentially complete** (full domain/data/presentation
  vertical slices exist for product_category, products, shopping_lists, recipes, meal_planning,
  pantry, plus app shell/navigation and core empty/error/loading widgets). **E8 (Settings & Data
  Management) is the biggest MVP gap**: `SettingsView` only has a Dark/Light/Green theme toggle,
  a "manage categories" link, "Clear Pantry", and a diagnostics link — missing `AppSettings`
  domain object, household-size setting (and its recipe/shopping-list scaling wiring), JSON
  export/import, "Clear All Data", multi-language/localization, and the Buy-Me-a-Coffee link (all
  of US-E8.2 through US-E8.7). Minor gaps in E3-E7: no explicit `UpdateProductCategoryUseCase`/etc
  confirmed wired end-to-end in UI for a couple of edit flows, and category-reorder (US-E2.3,
  P2) not verified. Post-MVP epics **E9-E12 (sync engine, cloud backend, auth, family sharing)
  are not started** beyond the `SyncQueueTable` schema stub from E0. **E13 (Smart Features/AI)**
  is partially started: `FindRecipesByPantryUseCase` (pantry-based recipe matching, ~US-E13.2)
  exists, but smart text parsing (US-E13.1) and predictive list generation (US-E13.3) do not.
  **E14 (performance)** and **E15 (testing)** have no dedicated indexing/pagination/golden-test
  infra yet, though substantial inline unit/widget tests already exist per-feature under
  `test/features/`. Full story-by-story breakdown was given directly to the user in chat rather
  than a new markdown doc.
- 2026-09-29: Ran [tool/generate_recipe_image_ai.dart](../tool/generate_recipe_image_ai.dart)
  (`--all --no-json`, repeated 4x) to backfill real AI-generated photos for all 44 recipes in
  [assets/data/recipes.json](../assets/data/recipes.json) into
  [assets/images/recipes_ai/](../assets/images/recipes_ai/) (recipes.json's `imageUrl` fields were
  left untouched, still pointing at `assets/images/recipes/`). Along the way found and fixed two
  bugs in the script: (1) Pollinations.ai now returns HTTP 402 for anonymous requests that include
  `nologo=true` (that flag now requires a registered account) — removed the param from the image
  request URL; (2) added retry-with-backoff (4 attempts, 5/10/15s) for transient 402/429/5xx
  responses and a 16s inter-request delay in `--all` mode to respect Pollinations' anonymous
  ~1-req/15s rate limit — the first `response.drain<List<int>>()` attempt at implementing this had
  a bug (drain's generic is the _return_ type, not an element-stream cast, so passing `List<int>`
  with no `futureValue` threw `type 'Null' is not a subtype of type 'List<int>'`); fixed by using
  `response.drain<void>()`. After the fixes, 4 sequential `--all --no-json` runs (each one only
  retrying files still missing) got all 44 images generated successfully.
- 2026-11-09: Removed the Pollinations.ai-based image generator scripts
  (`tool/generate_recipe_image_ai.dart`, `tool/generate_product_image_ai.dart`) — Pollinations'
  anonymous endpoint now requires payment (HTTP 402), making them unusable without an API key.
  The fal.ai/Flux-based scripts (`tool/generate_recipe_image_flux.dart`,
  [tool/generate_product_image_flux.dart](../tool/generate_product_image_flux.dart),
  [tool/generate_category_image_flux.dart](../tool/generate_category_image_flux.dart) — all
  require a `FAL_KEY`, see [tool/.env.example](../tool/.env.example)) are now the sole AI-photo
  path; the deterministic placeholder generator
  [tool/generate_recipe_image.dart](../tool/generate_recipe_image.dart) remains as the no-API-key
  fallback. Updated stale comments/docs that referenced the removed scripts in
  [tool/convert_images_to_webp.dart](../tool/convert_images_to_webp.dart),
  [tool/generate_recipe_image_flux.dart](../tool/generate_recipe_image_flux.dart),
  [tool/generate_product_image_flux.dart](../tool/generate_product_image_flux.dart), and
  [tool/seed/README.md](../tool/seed/README.md).
- 2026-11-09: Merged `assets/images/recipes_ai/` into `assets/images/recipes/` (no filename
  collisions; 43 + 449 = 492 files, one per recipe in
  [assets/data/recipes.json](../assets/data/recipes.json)) — there was never a meaningful
  distinction between the two, `recipes_ai` had just become the default output dir for the Flux
  generator. Updated all `imageUrl` values in recipes.json from `assets/images/recipes_ai/...` to
  `assets/images/recipes/...`, removed the now-nonexistent `assets/images/recipes_ai/` asset entry
  from [pubspec.yaml](../pubspec.yaml), changed
  [tool/generate_recipe_image_flux.dart](../tool/generate_recipe_image_flux.dart)'s default
  `--dir` to `assets/images/recipes`, and dropped the second recipe dir from
  [tool/convert_images_to_webp.dart](../tool/convert_images_to_webp.dart)'s `_recipeDirs` list.
  Verified with `dart run tool/seed/validate_seed.dart` (492 recipes, seed data OK).
- 2026-11-09: Bug: after the "removed some images and converted jpeg to webp" commit, recipes,
  products and categories all lost their images in already-seeded databases (fresh installs were
  fine). Root cause: that commit rewrote every `image`/`imageUrl`/`imageName` path in
  [assets/data/products.json](../assets/data/products.json),
  [assets/data/product_categories.json](../assets/data/product_categories.json) and
  [assets/data/recipes.json](../assets/data/recipes.json) from `.jpg`/`.png` to `.webp`, but
  [`SeedService.run()`](../lib/core/database/seeder/seed_service.dart) only re-applies the bundled
  seed when `assets/data/seed_manifest.json`'s `version` is _higher_ than the value already stored
  in `app_meta.seed_version` — and the manifest's version hadn't been bumped, so existing
  databases kept their old (now-deleted) image paths forever. Fix: ran
  `dart run tool/seed/validate_seed.dart --write-manifest --bump-version`, which validated the
  seed data (no missing files) and bumped `seed_manifest.json` to `version: 2`. On next launch
  `SeedService` will update the `photo`/`imageUrl` columns on every `is_built_in` row to the new
  `.webp` paths. **Lesson: any edit to the bundled seed JSON files (image paths, content, etc.)
  that should reach already-seeded devices/users must be paired with
  `--write-manifest --bump-version`** (or a manual version bump), otherwise it silently never
  applies to upgraded installs. Verified via
  `flutter test test/core/database/seeder/seed_service_test.dart` (3/3 passing).- 2026-11-09: Fixed a follow-on bug from the v2 bump above: on a real device, upgrading an
  already-seeded db to seed v2 (re-touching all ~447 built-in products / ~492 built-in recipes)
  reproducibly caused "I/Choreographer: Skipped N frames" then "Lost connection to device" (the
  app got killed, presumably ANR'd) right after the "[Seed] Applying seed v2" log line. Root
  cause: [`SeedService`](../lib/core/database/seeder/seed_service.dart)'s update path (used when
  a built-in row already exists) issued **one awaited `UPDATE`/`DELETE`/`INSERT` per row** inside
  the single `_db.transaction`, i.e. ~1,900 sequential isolate round-trips (products: 447 updates;
  recipes: 492 × update+delete-ingredients+insert-ingredients) — fine against an in-memory test db
  (confirmed <250ms with a throwaway repro test) but apparently slow/bursty enough against a real
  on-device SQLite file + `NativeDatabase.createInBackground` isolate to starve the splash
  screen's frame pump and risk an ANR-style kill. Fix: batched all three hot paths
  (`_seedCategories`, `_seedProducts`, `_seedRecipes`) using drift's `Batch.update`/`deleteWhere`/
  `insertAll`, cutting the v1→v2 re-seed down to ~5 round-trips total regardless of row count
  (measured ~100-250ms for the full 16 categories / 447 products / 492 recipes dataset). Removed
  the now-dead `_insertIngredients` helper. Verified: `flutter analyze` on
  [lib/core/database](../lib/core/database) clean, and the full `flutter test` suite (258 tests)
  passes, including all three `seed_service_test.dart` cases.
- 2026-11-11: Codified the **"Detail page pattern"** (pinned `SliverAppBar` hero →
  gradient-faded title + accent-bordered badge chips → feature sections) as a documented
  convention above, generalising from `RecipeDetailPage`. Brought
  [ProductCategoryDetailPage](../lib/features/product_category/presentation/pages/product_category_detail_page.dart)
  and [ProductDetailPage](../lib/features/products/presentation/pages/product_detail_page.dart)
  in line with it (both previously used a flat `AppBar` + `ListView`/`SingleChildScrollView`,
  hardcoded hex colours ignoring the Dark/Light/Green theme switch, and surfaced raw IDs like
  "Category #2" / "#66BB6A" / "Product ID: 12" directly in the UI — all now removed). Deleted the
  now-unused `category_detail_thumbnail.dart`, `category_detail_header_poster.dart`, and
  `category_detail_header.dart` widgets (logic inlined into the page, matching how
  `RecipeDetailPage` is structured) and the unused `DetailRow`/`StatusBadge` imports from
  `ProductDetailPage`. Also fixed
  [category_product_tile.dart](../lib/features/product_category/presentation/widgets/custom_controls/category_product_tile.dart)
  (the per-category products list): it rendered square images with hardcoded `AppColors` and had
  no tap-to-detail handler — rewired to the round `AccentCircleListCard` +
  `CircleAccentAvatar` + `ProductImageWidget` stack (same visual language as `ProductViewPage`'s
  rows), themed via `colorScheme`, and wired `onTap` → `ProductDetailPage`, long-press → edit
  sheet, swipe → delete. While doing this, also theme-ified the shared
  [info_row.dart](../lib/shared/widgets/display/info_row.dart) and
  [detail_row.dart](../lib/shared/widgets/display/detail_row.dart) widgets (no more hardcoded hex
  defaults) even though they're currently unused by the rewritten `ProductDetailPage`. Verified
  `flutter analyze` clean across `lib/`.
