# Setup Guide

Everything you need to run the Shop List App after cloning.

---

## Required Tools

| Tool               | Version               | Purpose                  | Download                                                             |
| ------------------ | --------------------- | ------------------------ | -------------------------------------------------------------------- |
| **Flutter SDK**    | >= 3.x                | Framework + Dart bundled | [flutter.dev](https://docs.flutter.dev/get-started/install)          |
| **Dart SDK**       | >= 3.6.0              | Bundled with Flutter     | —                                                                    |
| **JDK**            | 17 (LTS)              | Android builds           | [adoptium.net](https://adoptium.net/temurin/releases/?version=17)    |
| **Android Studio** | Latest                | Android SDK + Emulator   | [developer.android.com/studio](https://developer.android.com/studio) |
| **Xcode**          | Latest _(macOS only)_ | iOS builds               | Mac App Store                                                        |

> **Minimum Flutter version:** `3.x` with Dart `>=3.6.0 <4.0.0`

---

## Quick Start

### Windows

```powershell
git clone <repo-url>
cd shop_list_app
.\setup.ps1
```

### Linux / macOS

```bash
git clone <repo-url>
cd shop_list_app
chmod +x setup.sh && ./setup.sh
```

The scripts will:

1. Verify Flutter, Dart, Java, and Android SDK are installed
2. Run `flutter doctor` to check your environment
3. Run `flutter pub get` to install all Dart/Flutter packages
4. Run `build_runner` to generate code (Drift DB, Freezed models, JSON serialization)

---

## Manual Setup (step by step)

If you prefer to run each step yourself:

```bash
# 1. Install packages
cd shop_list_app
flutter pub get

# 2. Generate code (must run before building)
dart run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

---

## Flutter Packages Used

### Runtime Dependencies

| Package                | Version | Purpose                                |
| ---------------------- | ------- | -------------------------------------- |
| `flutter_riverpod`     | ^2.6.1  | State management                       |
| `drift`                | ^2.15.0 | Type-safe SQLite ORM                   |
| `sqlite3_flutter_libs` | ^0.5.0  | SQLite native binaries                 |
| `path_provider`        | ^2.1.0  | File system paths                      |
| `path`                 | ^1.8.3  | Path utilities                         |
| `dartz`                | ^0.10.1 | Functional programming (Either)        |
| `equatable`            | ^2.0.5  | Value equality                         |
| `go_router`            | ^14.0.0 | Declarative navigation                 |
| `shimmer`              | ^3.0.0  | Loading skeleton UI                    |
| `uuid`                 | ^4.5.1  | UUID generation                        |
| `intl`                 | ^0.19.0 | Internationalization & date formatting |
| `connectivity_plus`    | ^6.1.0  | Network connectivity checks            |
| `shared_preferences`   | ^2.3.0  | Lightweight key-value storage          |
| `image_picker`         | ^1.1.2  | Camera & gallery image selection       |
| `freezed_annotation`   | ^2.4.1  | Freezed code-gen annotations           |
| `json_annotation`      | ^4.9.0  | JSON serialization annotations         |

### Dev Dependencies (code generation & testing)

| Package             | Version | Purpose                           |
| ------------------- | ------- | --------------------------------- |
| `build_runner`      | ^2.4.8  | Code generation runner            |
| `drift_dev`         | ^2.14.0 | Drift DB code generator           |
| `freezed`           | ^2.4.5  | Immutable model code generator    |
| `json_serializable` | ^6.8.0  | JSON serialization code generator |
| `mockito`           | ^5.4.2  | Mocking for unit tests            |
| `flutter_lints`     | ^4.0.0  | Recommended lint rules            |

---

## Notes

- **Code generation is required.** The app will not compile without running `build_runner`. Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from version control.
- **Android target SDK:** Configured in `android/app/build.gradle.kts`.
- **Assets:** Images are in `assets/images/` and declared in `pubspec.yaml`.
