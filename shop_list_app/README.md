# Shop List App

A Flutter Shopping List & Meal Planning application built with **Clean Architecture**, **Riverpod**, and **Drift (SQLite)**.

---

## Architecture Overview

This project follows **Clean Architecture** with strict layer separation:

```
Presentation  →  Application (Use Cases)  →  Domain  →  Data
```

### Layer Responsibilities

| Layer            | Responsibility                                              |
| ---------------- | ----------------------------------------------------------- |
| **Presentation** | Flutter Widgets, Pages, Riverpod Providers / StateNotifiers |
| **Application**  | Use Cases — orchestrate domain logic                        |
| **Domain**       | Entities, Repository Interfaces — pure Dart, no Flutter     |
| **Data**         | Repository Implementations, Drift DAOs, Data Sources        |

### Key Architectural Decisions

- **Clean Architecture** — inner layers never depend on outer layers
- **Offline-First** — Drift (SQLite) is the source of truth; cloud sync is optional
- **Repository Pattern** — abstract data sources behind interfaces
- **MVVM with Riverpod** — `StateNotifier` manages UI state; Use Cases hold business logic
- **Drift Database** — type-safe reactive SQLite with code generation
- **Feature Modules** — each feature owns its `domain/`, `data/`, `presentation/` folders
- **Dependency Injection** — Riverpod `Provider` for all dependencies

---

## Project Structure

```
lib/
├── main.dart                   # Entry point — ProviderScope wraps App
├── app.dart
├── core/
│   ├── database/               # Drift AppDatabase + migrations
│   │   ├── app_database.dart
│   │   └── tables/
│   ├── constants/              # App, API, and storage constants
│   ├── error/                  # Failures & Exceptions
│   ├── network/                # NetworkInfo, ApiClient
│   ├── utils/                  # Shared utilities (date, string, validators)
│   ├── theme/                  # AppTheme, Colors, Typography
│   └── providers/              # Core Riverpod providers (databaseProvider, …)
├── features/
│   ├── shopping/               # Shopping list feature
│   │   ├── domain/             #   Entities, Repository interfaces, Use Cases
│   │   ├── data/               #   Models, Data Sources, Repository impls
│   │   └── presentation/       #   Providers, Pages, Widgets
│   ├── recipes/                # Recipe management feature
│   ├── meal_planning/          # Meal planning feature
│   ├── pantry/                 # Pantry inventory feature
│   └── sync/                   # Cloud sync engine (post-MVP)
└── shared/
    ├── widgets/                # Reusable widgets
    └── extensions/             # Dart extension methods
```

---

## Tech Stack

| Concern                | Package                          |
| ---------------------- | -------------------------------- |
| State Management       | `flutter_riverpod`               |
| Local Database         | `drift` + `sqlite3_flutter_libs` |
| Functional Programming | `dartz` (Either / Option)        |
| Value Equality         | `equatable`                      |
| Serialization          | `freezed` + `json_serializable`  |
| Connectivity           | `connectivity_plus`              |
| Preferences            | `shared_preferences`             |
| IDs                    | `uuid`                           |
| Localisation           | `intl`                           |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (Drift + Freezed)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Running Tests

```bash
flutter test
```
