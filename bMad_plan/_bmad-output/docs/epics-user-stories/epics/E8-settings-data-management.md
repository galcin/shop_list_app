# E8: Settings & Data Management

**Story Count:** 7 | **Total Points:** 30 | **Priority:** P0 | **Sprint:** 6

---

## Epic Goal

Users can configure the app, export their data to a JSON backup, and restore from a backup.

> **Note:** `settings_view_page.dart` exists but is not yet wired to any providers. Stories complete the settings feature end-to-end.

---

## Existing Files to Wire Up

| File                                                              | Status                 |
| ----------------------------------------------------------------- | ---------------------- |
| `shared/widgets/settings_view_page.dart`                          | ✅ Exists (shell only) |
| `SettingsDataSource`                                              | ❌ Missing             |
| `AppSettings` domain object                                       | ❌ Missing             |
| `SaveSettingsUseCase`                                             | ❌ Missing             |
| `settingsProvider`                                                | ❌ Missing             |
| `ExportDataUseCase` / `ImportDataUseCase` / `ClearAllDataUseCase` | ❌ Missing             |

---

## Stories

### US-E8.1: Settings & Theme Preferences

**As a** user
**I want to** switch between light and dark mode and configure basic preferences
**So that** the app works comfortably in my environment

**Story Points:** 4 | **Priority:** P0 | **Dependencies:** US-E1.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                 |
| --------- | --------------------------------------------------------------------------- |
| Data      | `SharedPreferences`-based `SettingsDataSource` with typed getters/setters   |
| Domain    | `AppSettings` value object: `themeMode`, `defaultServings`, `currency`      |
| Use Cases | `SaveSettingsUseCase(AppSettings)`                                          |
| Providers | `settingsProvider` (persisted `StateNotifier`)                              |
| UI        | `SettingsPage` (exists as `settings_view_page.dart`) — wire it to providers |
| UI        | Theme toggle (System / Light / Dark) — applies immediately                  |
| UI        | Default servings number picker                                              |
| UI        | About section (app version, open-source licences)                           |
| Tests     | Unit: `SaveSettingsUseCase` persists and reads correctly                    |
| Tests     | Widget: toggling dark mode updates theme immediately in widget tree         |

**Acceptance Criteria:**

- [ ] Settings tab accessible from nav bar
- [ ] Theme picker applies the theme change immediately
- [ ] Settings persist across app restarts
- [ ] About section shows app version

**UI Specification:**

Settings Page (dark):

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Settings                                       │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  Appearance                                     │  ← section label textSecondary
│  ┌───────────────────────────────────────────┐  │
│  │  Theme    [System ▾]  or  ○ ● ○           │  │  ← segmented: System/Light/Dark
│  │           Light  Dark  System             │  │  ← active segment bg orange #FF6B35
│  └───────────────────────────────────────────┘  │
│  Cooking                                        │
│  ┌───────────────────────────────────────────┐  │
│  │  Default servings     [−]  4  [+]         │  │  ← inline stepper
│  └───────────────────────────────────────────┘  │
│  About                                          │
│  ┌───────────────────────────────────────────┐  │
│  │  Version            1.0.0 (build 42)      │  │  ← textSecondary value
│  ├───────────────────────────────────────────┤  │
│  │  Open Source Licences               [→]   │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

All rows use `#1E1E1E` card background, `#2A2A2A` input/control bg, orange accent for active states.

---

### US-E8.2: Export Data to JSON

**As a** user
**I want to** export all my data to a JSON file
**So that** I have a backup I can restore or transfer to another device

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E8.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                 |
| --------- | ------------------------------------------------------------------------------------------- |
| Use Cases | `ExportDataUseCase()` — queries all repositories, builds `AppExportDto` with schema version |
| Data      | `AppExportDto` (freezed model containing all top-level entities)                            |
| Use Cases | Serialises dto to JSON; writes file to `getApplicationDocumentsDirectory()`                 |
| UI        | "Export Data" row in Settings — triggers export + shows share/save dialog                   |
| UI        | Progress indicator during export                                                            |
| UI        | Success: "Exported 42 recipes, 15 lists..." snackbar + OS share sheet                       |
| Tests     | Unit: export dto serialises all entities to valid JSON                                      |
| Tests     | Integration: export → read JSON file → verify recipe count matches DB                       |

**Acceptance Criteria:**

- [ ] "Export Data" option in Settings
- [ ] Progress indicator shown while export runs
- [ ] On success, OS share sheet opens with the exported JSON file
- [ ] JSON file is human-readable and includes `"export_version": 1`
- [ ] Integration test: export → read file → verify recipe count matches

**UI Specification:**

Export Data row + OS share sheet trigger:

```
│  Data                                           │
│  ┌───────────────────────────────────────────┐  │
│  │  Export Data                        [→]   │  │  ← tapping shows progress indicator
│  └───────────────────────────────────────────┘  │

Export progress (modal overlay):
┌──────────────────────────────┐  bg #1E1E1E radius 16px
│  ○  Exporting data...        │  ← circular orange indicator
└──────────────────────────────┘

Success snackbar (dark):
│  ✓  Exported 42 recipes, 15 lists  [Share]     │  ← green ✓, orange "Share" action
```

---

### US-E8.3: Import Data from JSON

**As a** user
**I want to** import a previously exported JSON file
**So that** I can restore a backup or transfer data from another device

**Story Points:** 5 | **Priority:** P0 | **Dependencies:** US-E8.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                |
| --------- | ------------------------------------------------------------------------------------------ |
| Use Cases | `ImportDataUseCase(filePath)` — reads JSON, validates schema version, upserts all entities |
| Use Cases | Conflict rule: existing record not overwritten when import has an older `updatedAt`        |
| UI        | "Import Data" row in Settings → file picker (JSON files only)                              |
| UI        | Preview sheet: "Found 42 recipes, 15 lists. Import will merge with existing data."         |
| UI        | Confirm → progress indicator → success summary                                             |
| Tests     | Unit: `ImportDataUseCase` rejects invalid JSON schema gracefully                           |
| Tests     | Unit: existing record not overwritten when import data has older `updatedAt`               |
| Tests     | Integration: export → wipe DB → import → verify all data restored                          |

**Acceptance Criteria:**

- [ ] "Import Data" opens file picker filtered to JSON
- [ ] Preview sheet shows entity counts before committing
- [ ] Import merges (upserts) without duplicating unchanged records
- [ ] Invalid file shows user-friendly error (no crash)
- [ ] Integration test: export → import → verify data

**UI Specification:**

Import preview sheet + progress (dark):

```
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  Import Backup                             │
│  app-export-2024-03-05.json                     │  ← file name
│  ─────────────────────────────────────────      │
│  📚  42 recipes found                           │
│  🛒  15 shopping lists found                    │
│  🥫  87 pantry items found                     │
│  ⚠️  Existing records will be merged.           │  ← amber note
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Import & Merge                            │  │  ← orange full-width button
│  └───────────────────────────────────────────┘  │
│  [Cancel]  ← grey text                          │
└─────────────────────────────────────────────────┘
```

---

### US-E8.4: Clear All Data

**As a** user
**I want to** delete all my data with a single action
**So that** I can reset the app to a clean state

**Story Points:** 2 | **Priority:** P0 | **Dependencies:** US-E8.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                           |
| --------- | --------------------------------------------------------------------- |
| Use Cases | `ClearAllDataUseCase()` — truncates all tables respecting FK order    |
| UI        | "Danger Zone" section in Settings with a red "Clear All Data" button  |
| UI        | Two-step confirmation: first dialog + second requires typing "DELETE" |
| Tests     | Unit: clear use case deletes records from all tables                  |
| Tests     | Integration: add data → clear → verify empty states on all tabs       |

**Acceptance Criteria:**

- [ ] "Clear All Data" is in a clearly marked "Danger Zone" section
- [ ] Two confirmation steps prevent accidental deletion
- [ ] After clearing, all tabs show empty states
- [ ] App preferences (theme, etc.) are NOT cleared

**UI Specification:**

Danger Zone section + two-step confirmation:

```
│  ─────────────  Danger Zone  ──────────────     │  ← red divider label
│  ┌───────────────────────────────────────────┐  │
│  │  🗑  Clear All Data             [→]        │  │  ← red text, red icon
│  └───────────────────────────────────────────┘  │

Step 1 — warning dialog:
┌──────────────────────────────────┐  bg #1E1E1E radius 16px
│  ⚠️  This will delete everything  │
│  All recipes, lists, pantry and  │
│  meal plans will be permanently  │
│  deleted. This cannot be undone. │
│         [Cancel]  [Continue →]    │  ← Continue = red text
└──────────────────────────────────┘

Step 2 — type to confirm:
┌──────────────────────────────────┐
│  Type DELETE to confirm           │
│  ┌──────────────────────────┐    │
│  │                          │    │  ← input bg #2A2A2A; remains disabled until "DELETE" typed
│  └──────────────────────────┘    │
│  [Erase All Data]  ← enabled only when text = "DELETE", red bg    │
└──────────────────────────────────┘
```

---

### US-E8.5: Household Size & Smart Ingredient Scaling

**As a** user
**I want to** set how many people I usually cook for as a global setting
**So that** recipe ingredients and generated shopping-list quantities automatically scale to my household without me adjusting every recipe by hand

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E8.1, US-E5.5

> **Note:** This story upgrades the "Default servings number picker" added in US-E8.1 into a first-class `householdSize` setting that actively drives recipe scaling (US-E5.5) and meal-plan shopping-list generation (US-E6.3), instead of only being a cosmetic default.

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                                                          |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Domain    | `AppSettings.householdSize` (int, replaces/renames `defaultServings`; validated range 1–12)                                                                                          |
| Use Cases | `SaveSettingsUseCase` — persists `householdSize` (existing use case, extended)                                                                                                       |
| Use Cases | `ScaleRecipeToHouseholdUseCase(recipe)` — thin wrapper over `ScaleRecipeUseCase` (US-E5.5) using `householdSize` as target serving count                                             |
| Providers | `householdSizeProvider` — derived from `settingsProvider`                                                                                                                            |
| Providers | `servingCountProvider(recipeId)` (US-E5.5) — default initial value changed from `recipe.servings` to `householdSize` unless the user manually overrides it in-session                |
| UI        | Settings row relabelled **"Household size"** — stepper (`−` / count / `+`), min 1 / max 12, helper text explaining its effect                                                        |
| UI        | `RecipeDetailPage` header — serving stepper opens pre-set to household size; small badge shown when scaled: _"Scaled for 6 · recipe default 4"_                                      |
| UI        | `RecipeDetailPage` — "Reset" restores the recipe's **authored** default (not the household size); new "Use my household size (6)" quick action reappears if the user changed it away |
| UI        | "Generate Shopping List" sheet (US-E6.3) — adds a toggle **"Scale to my household size (6)"**, on by default; off uses each recipe's authored quantities                             |
| Tests     | Unit: `ScaleRecipeToHouseholdUseCase` scales a 4-serving recipe to the configured household size                                                                                     |
| Tests     | Unit: `GenerateShoppingListFromPlanUseCase` aggregates household-scaled quantities when the toggle is on                                                                             |
| Tests     | Widget: opening a recipe authored for 4 servings with household size = 6 shows scaled quantities and the "Scaled for 6" badge                                                        |
| Tests     | Integration: set household size → open recipe → verify auto-scaled ingredients → generate shopping list → verify scaled totals                                                       |

**Acceptance Criteria:**

- [ ] Settings has a "Household size" stepper (default 4, min 1, max 12) with explanatory helper text
- [ ] Household size persists across app restarts (same mechanism as other settings)
- [ ] Opening any recipe detail page automatically scales ingredient quantities to the household size instead of the recipe's authored serving count
- [ ] A small inline badge indicates when quantities have been auto-scaled, showing both the current and the recipe's original serving count
- [ ] The user can still manually override the serving count for a single viewing session (US-E5.5); doing so surfaces a "Use my household size" quick action to revert
- [ ] "Reset" always restores the recipe's original authored quantities, never silently re-applies the household size
- [ ] Generating a shopping list from a meal plan (US-E6.3) scales ingredient quantities to the household size by default, with an explicit toggle to fall back to each recipe's original authored quantities
- [ ] Changing household size in Settings affects scaling immediately for anything opened afterwards — no recipe data is rewritten in the DB (scaling stays computed client-side, per US-E5.5)
- [ ] Integration test: change household size → open a recipe → verify scaled quantities → generate a shopping list → verify aggregated quantities reflect the household size

**UI Specification:**

Settings row (replaces the "Default servings" row from US-E8.1):

```
│  Cooking                                        │
│  ┌───────────────────────────────────────────┐  │
│  │  Household size        [−]  6  [+]        │  │  ← inline stepper, orange controls
│  │  Used to scale recipe ingredients and     │  │  ← textSecondary helper line
│  │  shopping list quantities automatically   │  │
│  └───────────────────────────────────────────┘  │
```

Recipe Detail header — auto-scaled badge:

```
│  Chicken Tacos                                  │
│  ┌────────────────────────────────────┐        │
│  │  [🍽️ Servings]   [−]  6  [+]     │        │  ← stepper opens pre-set to household size
│  └────────────────────────────────────┘        │
│  Scaled for 6 · recipe default 4   ↺ Use 6     │  ← amber helper text; "↺" = reset to 4
```

Generate Shopping List sheet (US-E6.3) — added toggle:

```
│  📚  5 recipes assigned                         │
│  📝  Estimated 28 ingredients                   │
│  🔗  Duplicates will be merged automatically    │
│  ☑  Scale to my household size (6)             │  ← orange checked toggle, on by default
```

---

### US-E8.6: Multi-Language Support (Localization)

**As a** user
**I want to** use the app in my preferred language
**So that** I can read recipes, ingredients, and the whole interface in a language I'm comfortable with

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E8.1

> **Note:** The app is currently English-only with hardcoded strings scattered through widgets. This story introduces Flutter's standard localization pipeline (`flutter_localizations` + `intl`, ARB files) and migrates user-facing strings, then adds a language picker to Settings. Launch scope: **English, Spanish, Portuguese** (easy to extend — see "Future Languages" below); recipe/product seed data translation is out of scope for this story (tracked separately).

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                             |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Infra     | `flutter_localizations` SDK dependency + `intl` package; `generate: true` in `pubspec.yaml`; `l10n.yaml` config                                         |
| Infra     | `lib/l10n/app_en.arb` (source of truth), `app_es.arb`, `app_pt.arb` — generated `AppLocalizations` class via `flutter gen-l10n`                         |
| Domain    | `AppSettings.localeCode` (nullable String; `null` = "follow system")                                                                                    |
| Use Cases | `SaveSettingsUseCase` — persists `localeCode` (existing use case, extended)                                                                             |
| Providers | `localeProvider` — derived from `settingsProvider`; resolves `null` → `Localizations.localeOf(context)` / system locale                                 |
| App Shell | `MaterialApp.router` wired with `localizationsDelegates`, `supportedLocales`, and `locale:` bound to `localeProvider`                                   |
| Refactor  | Migrate hardcoded strings in app shell, navigation, Settings, Shopping List, Recipes, Meal Planning, Pantry UI to `AppLocalizations.of(context)!.<key>` |
| Refactor  | Date/number formatting routed through `intl` (`DateFormat`, `NumberFormat`) respecting the active locale, not hardcoded `en_US`                         |
| UI        | "Language" row in Settings → bottom sheet picker: System default / English / Español / Português                                                        |
| UI        | Changing language updates the UI immediately (no restart required)                                                                                      |
| Tests     | Unit: `SaveSettingsUseCase` persists and reads `localeCode` correctly                                                                                   |
| Tests     | Unit: `localeProvider` falls back to system locale when `localeCode` is `null`                                                                          |
| Tests     | Widget: switching to Spanish updates visible Settings page strings immediately                                                                          |
| Tests     | Golden/snapshot (optional): key screens render without overflow in the longest-string locale                                                            |

**Acceptance Criteria:**

- [ ] Settings has a "Language" row showing the current selection (e.g., "System default", "English", "Español", "Português")
- [ ] Tapping it opens a picker listing "System default" plus each supported language
- [ ] Selecting a language updates all currently-visible translated screens immediately, with no app restart
- [ ] Selected language persists across app restarts (same mechanism as other settings)
- [ ] "System default" follows the OS locale, including if the OS locale changes while the app is backgrounded
- [ ] All static UI strings (navigation, buttons, labels, empty states, dialogs, error/snackbar messages) are externalized to ARB files — no hardcoded English strings remain in migrated screens
- [ ] Dates and numbers (e.g., meal plan week ranges, quantities) format according to the active locale's conventions
- [ ] Falling back to an unsupported system locale defaults to English without crashing
- [ ] Integration test: switch language in Settings → navigate across tabs → verify translated strings appear

**UI Specification:**

Settings row + language picker (dark):

```
│  General                                        │
│  ┌───────────────────────────────────────────┐  │
│  │  Language                  English   [→]  │  │  ← textSecondary current value
│  └───────────────────────────────────────────┘  │

Language picker (modal bottom sheet):
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···  Language                                  │
│  ─────────────────────────────────────────      │
│  ●  System default                              │  ← ● = orange selected radio
│  ○  English                                     │
│  ○  Español                                     │
│  ○  Português                                   │
└─────────────────────────────────────────────────┘
```

**Future Languages:** Adding a new language after this story is just a new `app_<code>.arb` file + entry in `supportedLocales` and the picker list — no code changes to screens required, since all strings already route through `AppLocalizations`.

---

### US-E8.7: "Buy Me a Coffee" Support Link

**As a** user who enjoys the app
**I want to** find a simple way to support its development
**So that** I can show appreciation and help fund continued work on the app

**Story Points:** 3 | **Priority:** P2 | **Dependencies:** US-E8.1

> **Note:** This is a lightweight, external-link-based donation entry point (e.g. Buy Me a Coffee / Ko-fi style page) — **no in-app payment processing, no IAP store integration, and no platform billing entitlements** are in scope. The app simply opens the creator's external donation page in the browser/OS. Keeps store review risk low and requires no backend.

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                 |
| --------- | --------------------------------------------------------------------------------------------------------------------------- |
| Core      | `AppLinks` / `AppConstants` entry for the support URL (e.g. `https://buymeacoffee.com/<handle>`), easily configurable       |
| Data      | `url_launcher` package dependency (if not already present)                                                                  |
| Use Cases | `OpenSupportLinkUseCase()` — thin wrapper that calls `url_launcher` and returns `Either<Failure, void>` on launch failure   |
| UI        | "Support the Developer" / "☕ Buy Me a Coffee" row in Settings, under a new "About & Support" section, with coffee-cup icon |
| UI        | Tapping opens the configured URL in an external browser / in-app custom tab (platform default)                              |
| UI        | Graceful failure: if no browser/handler available, shows a `SnackBar` ("Couldn't open the link") instead of crashing        |
| UI        | Optional: small one-line note in About section — "Enjoying the app? Consider supporting development ❤️"                     |
| Tests     | Unit: `OpenSupportLinkUseCase` returns `Left(LaunchFailure)` when `url_launcher` reports it can't launch the URL            |
| Tests     | Widget: tapping the Settings row triggers the launch call with the correct configured URL                                   |

**Acceptance Criteria:**

- [ ] Settings has a clearly visible "Buy Me a Coffee" / "Support the Developer" row (About & Support section)
- [ ] Tapping it opens the external donation page via the OS/browser; no payment is ever handled inside the app
- [ ] The destination URL is defined in one central constant, easy to update without touching UI code
- [ ] If the link cannot be opened (no browser available, invalid URL, etc.), the user sees a friendly error instead of a crash
- [ ] This entry point has no effect on app functionality, data, or any paywall/entitlement — purely informational/goodwill
- [ ] Works on both Android and iOS (and other supported platforms where a URL handler exists)

**UI Specification:**

Settings — About & Support section:

```
│  About & Support                                │  ← section label textSecondary
│  ┌───────────────────────────────────────────┐  │
│  │  Version            1.0.0 (build 42)      │  │
│  ├───────────────────────────────────────────┤  │
│  │  ☕  Buy Me a Coffee                [→]   │  │  ← orange icon/text, opens browser
│  ├───────────────────────────────────────────┤  │
│  │  Open Source Licences               [→]   │  │
│  └───────────────────────────────────────────┘  │
│  Enjoying the app? Consider supporting the      │  ← small textSecondary caption
│  developer ❤️                                   │
```

---

_See [\_index.md](_index.md) for the full epic list._
