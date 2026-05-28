# ============================================================
# Shop List App - Windows Setup Script
# Run this script after cloning the repo to get started fast.
# Usage: .\setup.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "   [!!] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "   [X]  $msg" -ForegroundColor Red }

# ─── 1. Flutter ───────────────────────────────────────────────────────────────
Write-Step "Checking Flutter SDK..."
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter"
    Write-Ok "Flutter found: $flutterVersion"
} else {
    Write-Fail "Flutter not found in PATH."
    Write-Host ""
    Write-Host "   Install Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "   Minimum version required: 3.x (Dart >= 3.6.0)" -ForegroundColor White
    Write-Host ""
    Write-Warn "After installing Flutter, re-run this script."
    exit 1
}

# ─── 2. Dart SDK (bundled with Flutter) ───────────────────────────────────────
Write-Step "Checking Dart SDK..."
if (Get-Command dart -ErrorAction SilentlyContinue) {
    $dartVersion = dart --version 2>&1
    Write-Ok "Dart found: $dartVersion"
} else {
    Write-Fail "Dart not found. It should come bundled with Flutter."
    exit 1
}

# ─── 3. Java / JDK (required for Android builds) ─────────────────────────────
Write-Step "Checking Java (JDK)..."
if (Get-Command java -ErrorAction SilentlyContinue) {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Ok "Java found: $javaVersion"
} else {
    Write-Warn "Java not found. Required for Android builds."
    Write-Host "   Install JDK 17 from: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor White
}

# ─── 4. Android SDK / ADB ─────────────────────────────────────────────────────
Write-Step "Checking Android SDK (adb)..."
if (Get-Command adb -ErrorAction SilentlyContinue) {
    Write-Ok "Android SDK found (adb is available)."
} else {
    Write-Warn "adb not found. Install Android Studio to get the Android SDK."
    Write-Host "   Download: https://developer.android.com/studio" -ForegroundColor White
}

# ─── 5. Flutter Doctor ────────────────────────────────────────────────────────
Write-Step "Running flutter doctor..."
flutter doctor

# ─── 6. Install Pub Dependencies ──────────────────────────────────────────────
Write-Step "Installing Flutter/Dart packages (flutter pub get)..."
Set-Location "$PSScriptRoot\shop_list_app"
flutter pub get
Write-Ok "Packages installed."

# ─── 7. Code Generation ───────────────────────────────────────────────────────
Write-Step "Running code generation (build_runner)..."
Write-Host "   This generates Drift DB, Freezed models, and JSON serialization." -ForegroundColor Gray
dart run build_runner build --delete-conflicting-outputs
Write-Ok "Code generation complete."

# ─── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Setup complete! You can now run the app:" -ForegroundColor Green
Write-Host ""
Write-Host "    cd shop_list_app" -ForegroundColor White
Write-Host "    flutter run" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
