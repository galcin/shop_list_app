#!/usr/bin/env bash
# ============================================================
# Shop List App - Linux/macOS Setup Script
# Run this script after cloning the repo to get started fast.
# Usage: chmod +x setup.sh && ./setup.sh
# ============================================================

set -e

ok()   { echo -e "\033[32m   [OK] $1\033[0m"; }
warn() { echo -e "\033[33m   [!!] $1\033[0m"; }
fail() { echo -e "\033[31m   [X]  $1\033[0m"; }
step() { echo -e "\n\033[36m>> $1\033[0m"; }

# ─── 1. Flutter ───────────────────────────────────────────────────────────────
step "Checking Flutter SDK..."
if command -v flutter &>/dev/null; then
    ok "Flutter found: $(flutter --version 2>&1 | head -1)"
else
    fail "Flutter not found in PATH."
    echo "   Install Flutter: https://docs.flutter.dev/get-started/install"
    echo "   Minimum version: 3.x (Dart >= 3.6.0)"
    exit 1
fi

# ─── 2. Dart SDK ──────────────────────────────────────────────────────────────
step "Checking Dart SDK..."
if command -v dart &>/dev/null; then
    ok "Dart found: $(dart --version 2>&1)"
else
    fail "Dart not found. It should come bundled with Flutter."
    exit 1
fi

# ─── 3. Java / JDK ────────────────────────────────────────────────────────────
step "Checking Java (JDK)..."
if command -v java &>/dev/null; then
    ok "Java found: $(java -version 2>&1 | head -1)"
else
    warn "Java not found. Required for Android builds."
    echo "   Install JDK 17: https://adoptium.net/temurin/releases/?version=17"
fi

# ─── 4. Android SDK / ADB ─────────────────────────────────────────────────────
step "Checking Android SDK (adb)..."
if command -v adb &>/dev/null; then
    ok "Android SDK found (adb is available)."
else
    warn "adb not found. Install Android Studio to get the Android SDK."
    echo "   Download: https://developer.android.com/studio"
fi

# ─── 5. Flutter Doctor ────────────────────────────────────────────────────────
step "Running flutter doctor..."
flutter doctor

# ─── 6. Install Pub Dependencies ──────────────────────────────────────────────
step "Installing Flutter/Dart packages (flutter pub get)..."
cd "$(dirname "$0")/shop_list_app"
flutter pub get
ok "Packages installed."

# ─── 7. Code Generation ───────────────────────────────────────────────────────
step "Running code generation (build_runner)..."
echo "   Generates Drift DB, Freezed models, and JSON serialization."
dart run build_runner build --delete-conflicting-outputs
ok "Code generation complete."

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "\033[32m============================================================\033[0m"
echo -e "\033[32m  Setup complete! You can now run the app:\033[0m"
echo ""
echo "    cd shop_list_app"
echo "    flutter run"
echo -e "\033[32m============================================================\033[0m"
echo ""
