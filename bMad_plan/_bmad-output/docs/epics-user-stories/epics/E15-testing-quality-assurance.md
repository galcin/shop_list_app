# E15: Testing & Quality Assurance

**Story Count:** 3 | **Total Points:** 18 | **Priority:** P1 | **Sprint:** Continuous

---

## Epic Goal

Establish a comprehensive test suite covering unit, widget, integration, and end-to-end tests to maintain quality throughout the project lifecycle.

**Note:** Each E2–E14 epic already includes inline unit and widget tests. This epic adds the cross-cutting concerns: integration test harness, golden tests, and CI quality gates.

---

## Test Coverage Targets

| Type              | Target Coverage                                                          |
| ----------------- | ------------------------------------------------------------------------ |
| Unit tests        | ≥ 80% line coverage on use cases and repositories                        |
| Widget tests      | All pages + reusable components                                          |
| Integration tests | All critical user journeys (create → read → update → delete per feature) |
| Golden tests      | Design system components (stable visual baseline)                        |

---

## Stories

### US-E15.1: Integration Test Harness

**As a** developer
**I want to** have a reusable integration test harness with a pre-seeded in-memory database
**So that** integration tests are isolated, repeatable, and fast

**Story Points:** 6 | **Priority:** P1 | **Dependencies:** E0–E8

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                                                                                                                                                                       |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Test  | `TestDatabaseFactory` — creates an in-memory `AppDatabase` for tests                                                                                                                                                              |
| Test  | `TestProviderContainer` — overrides `databaseProvider`, `networkInfoProvider`, `authRepositoryProvider` with test doubles                                                                                                         |
| Test  | `AppSeeder` — seeds predictable test data (3 categories, 10 products, 5 recipes, 2 shopping lists, 1 pantry)                                                                                                                      |
| Test  | `AppDriver` wrapper around `flutter_driver` / `integration_test`                                                                                                                                                                  |
| CI    | `integration_test/` directory with one critical-path test per epic (E1–E8)                                                                                                                                                        |
| Tests | Critical path integration tests: E1 (navigation), E2 (category CRUD), E3 (product CRUD), E4 (shopping list CRUD + check items), E5 (recipe CRUD), E6 (meal plan + generate list), E7 (pantry CRUD + expiry), E8 (export + import) |

**Acceptance Criteria:**

- [ ] `TestDatabaseFactory` creates fresh in-memory DB per test
- [ ] `AppSeeder` seeds consistent baseline data
- [ ] Integration test for each epic's critical path passes
- [ ] Tests run in < 60 seconds total on CI
- [ ] No shared state between integration tests

---

### US-E15.2: Golden Tests for Design System

**As a** developer
**I want to** have golden (screenshot) tests for core UI components
**So that** unintentional visual regressions are caught automatically

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** US-E1.2

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                                        |
| ----- | -------------------------------------------------------------------------------------------------- |
| Tests | Golden tests for: `EmptyStateWidget`, `ErrorStateWidget`, `LoadingStateWidget`, `AsyncValueWidget` |
| Tests | Golden tests for: shopping list card (empty / partial / complete)                                  |
| Tests | Golden tests for: recipe list tile (no image / with image)                                         |
| Tests | Golden tests for: pantry item row (fresh / expiring soon / expired variants)                       |
| CI    | `flutter test --update-goldens` triggered on designated "golden update" PRs only                   |

**Acceptance Criteria:**

- [ ] Golden images committed to repo under `test/goldens/`
- [ ] Golden tests fail CI on unexpected pixel changes
- [ ] Both light and dark theme variants captured
- [ ] Updating goldens requires an intentional CI flag

---

### US-E15.3: CI Quality Gate

**As a** developer
**I want to** have a CI pipeline that enforces code quality on every pull request
**So that** regressions are caught before code is merged

**Story Points:** 7 | **Priority:** P1 | **Dependencies:** US-E15.1

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                     |
| ----- | --------------------------------------------------------------- |
| CI    | GitHub Actions workflow: `flutter analyze` (zero warnings)      |
| CI    | `flutter test` — unit + widget tests with coverage report       |
| CI    | Coverage gate: use case coverage must be ≥ 80%                  |
| CI    | `flutter build apk --release` must succeed                      |
| CI    | Integration tests run on Android emulator in CI                 |
| CI    | PR status checks: all CI jobs must pass before merge is allowed |

**Acceptance Criteria:**

- [ ] CI runs on every push and pull request
- [ ] `flutter analyze` with zero warnings is a required check
- [ ] Coverage report generated and attached to each CI run
- [ ] Use case line coverage ≥ 80% enforced
- [ ] Failed integration tests block PR merge
- [ ] Release build successfully compiles on CI

---

_See [\_index.md](_index.md) for the full epic list._
