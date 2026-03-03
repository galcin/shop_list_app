# E8: Settings & Data Management

**Story Count:** 4 | **Total Points:** 17 | **Priority:** P0 | **Sprint:** 6

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

_See [\_index.md](_index.md) for the full epic list._
