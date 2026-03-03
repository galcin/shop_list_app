# E1: App Shell & Core Navigation

**Story Count:** 2 | **Total Points:** 7 | **Priority:** P0 | **Sprint:** 1

---

## Epic Goal

A running, navigable app shell with bottom navigation and reusable core UI components. All subsequent epics plug their UI pages into this shell.

---

## Stories

### US-E1.1: App Shell with Bottom Navigation

**As a** user
**I want to** see a persistent navigation bar at the bottom of the app
**So that** I can switch between Shopping, Recipes, Meal Planning, Pantry, and Settings at any time

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** E0

**Vertical Slice Deliverables:**

| Layer  | Deliverable                                                                  |
| ------ | ---------------------------------------------------------------------------- |
| Domain | `AppRoute` enum: `shopping`, `recipes`, `mealPlanning`, `pantry`, `settings` |
| State  | `NavigationNotifier` (Riverpod `StateNotifier`) holding current route        |
| UI     | `MainShell` widget with `NavigationBar` + `IndexedStack` children            |
| Routes | GoRouter wiring all top-level pages                                          |
| Tests  | Widget test: tapping each nav item shows correct page                        |

**Acceptance Criteria:**

- [ ] Bottom navigation shows 5 tabs with icons and labels
- [ ] Active tab is highlighted
- [ ] Switching tabs preserves the state of each tab (no reload)
- [ ] Deep links to each tab work
- [ ] Works on Android, iOS, and web
- [ ] Widget test verifies navigation changes

**UI Specification:**

Bottom navigation structure (5 tabs, Material Design 3):

```
┌─────────────────────────────────────────────────┐
│                                                 │
│            [ACTIVE SCREEN CONTENT]              │
│                                                 │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │
│  Plan   Shop  Recipes Pantry Settings          │
│   ●                                             │ ← Active indicator
└─────────────────────────────────────────────────┘
```

| Icon | Label    | Route        | Primary Action             | Badge          |
| ---- | -------- | ------------ | -------------------------- | -------------- |
| 🗓️   | Plan     | `/meal-plan` | Assign recipe to meal slot | None           |
| 🛒   | Shop     | `/shopping`  | Add item to list           | Item count     |
| 📚   | Recipes  | `/recipes`   | Add new recipe             | None           |
| 🥫   | Pantry   | `/pantry`    | Add pantry item            | Expiring count |
| ⚙️   | Settings | `/settings`  | N/A                        | None           |

Navigation state uses `StateProvider<int>` (`navigationIndexProvider`) — index 0–4. `IndexedStack` wraps all tab pages so each tab's scroll position and state survive switching. Tapping the active tab scrolls to top.

**Technical Notes:**

- Use `NavigationBar` (Material 3)
- `IndexedStack` preserves widget state across tab switches
- `NavigationNotifier` is the single source of truth for active tab

---

### US-E1.2: Core UI Components (Empty, Error, Loading)

**As a** user
**I want to** see consistent empty states, error messages, and loading indicators
**So that** I always understand what is happening in the app

**Story Points:** 3 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                   |
| ----- | ------------------------------------------------------------- |
| UI    | `EmptyStateWidget(icon, title, subtitle, action?)` component  |
| UI    | `ErrorStateWidget(message, onRetry?)` component               |
| UI    | `LoadingStateWidget` (shimmer skeleton)                       |
| UI    | `AsyncValueWidget<T>` helper that wraps Riverpod `AsyncValue` |
| Tests | Widget tests for each component covering all states           |

**Acceptance Criteria:**

- [ ] `AsyncValueWidget` renders loading, error, and data states correctly
- [ ] Empty state has optional call-to-action button
- [ ] Error state has optional retry button
- [ ] All components use `AppTheme` tokens (no hard-coded colours or sizes)
- [ ] Widget test covers all three states

**UI Specification:**

Empty state layout — centred, 64 px icon at 50 % opacity, `titleLarge` heading, `bodyMedium` message, optional CTA button with 24 px top gap:

```
        ┌─────────────────────┐
        │                     │
        │       [Icon]        │  ← 64px icon (50% opacity)
        │                     │
        │   No recipes yet    │  ← titleLarge
        │                     │
        │  Tap + to add your  │  ← bodyMedium (textSecondary)
        │   first recipe      │
        │                     │
        │  [+ Add Recipe]     │  ← Optional CTA button
        │                     │
        └─────────────────────┘
```

Skeleton / shimmer loader for cards — image placeholder (height 150) then two shimmer bars (full-width title, 100 px metadata), using `shimmer` package with `Colors.grey[300]` base and `Colors.grey[100]` highlight:

```
┌─────────────────────┐
│ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │  ← Shimmering image placeholder
│ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │
├─────────────────────┤
│ ▒▒▒▒▒▒▒▒▒▒▒▒       │  ← Title placeholder
│ ▒▒▒▒▒▒             │  ← Metadata placeholder
└─────────────────────┘
```

All spacing uses `AppSpacing` tokens (`xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32) — no hard-coded values.

**Usage Pattern:**

```dart
AsyncValueWidget<List<ProductCategory>>(
  value: ref.watch(watchCategoriesProvider),
  loading: () => LoadingStateWidget(),
  error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(watchCategoriesProvider)),
  data: (categories) => categories.isEmpty
      ? EmptyStateWidget(title: 'No categories yet', action: () => _showCreateSheet())
      : CategoryListView(categories: categories),
)
```

---

_See [\_index.md](_index.md) for the full epic list._
