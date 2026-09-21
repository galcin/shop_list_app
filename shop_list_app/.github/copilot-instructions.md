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
