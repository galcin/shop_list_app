import 'package:flutter/material.dart';

/// Light and Dark theme color tokens for the Shop List App
class AppColors {
  AppColors._();

  // ── Brand (same for all themes) ────────────────────────────────────────────
  /// Soft red – used for error and destructive actions.
  static const Color error = Color(0xFFFF6B6B);

  /// Text on coloured buttons.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Favourite / wishlist red.
  static const Color favourite = Color(0xFFFF6B6B);

  // ────────────────────────────────────────────────────────────────────────────
  // ORANGE THEME (Default)
  // ────────────────────────────────────────────────────────────────────────────

  /// Main brand orange – used for CTAs, active states, FAB, etc.
  static const Color primary = Color(0xFFFF6B35);

  /// Warm secondary accent – used for highlights.
  static const Color accent = Color(0xFFFFA500);

  /// Star rating orange.
  static const Color rating = Color(0xFFFF6B35);

  // ────────────────────────────────────────────────────────────────────────────
  // GREEN THEME COLORS
  // ────────────────────────────────────────────────────────────────────────────

  /// Green theme: Primary green
  static const Color greenPrimary = Color(0xFF2E7D32);

  /// Green theme: Secondary green
  static const Color greenAccent = Color(0xFF4CAF50);

  /// Green theme: Light green background
  static const Color greenBackgroundLight = Color(0xFFF1F8E9);

  /// Green theme: Light green surface
  static const Color greenSurfaceLight = Color(0xFFFFFBFE);

  /// Green theme: Light green variant
  static const Color greenSurfaceVariantLight = Color(0xFFEFEAF0);

  /// Green theme: Dark green background
  static const Color greenBackgroundDark = Color(0xFF1B5E20);

  /// Green theme: Dark green surface
  static const Color greenSurfaceDark = Color(0xFF27463E);

  /// Green theme: Dark green variant
  static const Color greenSurfaceVariantDark = Color(0xFF2E5741);

  // ────────────────────────────────────────────────────────────────────────────
  // LIGHT THEME COLORS
  // ────────────────────────────────────────────────────────────────────────────

  /// Light theme: Page background
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Light theme: Card / container surface
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Light theme: Light grey section background
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  /// Light theme: Primary text
  static const Color textPrimaryLight = Color(0xFF212121);

  /// Light theme: Body text
  static const Color textBodyLight = Color(0xFF424242);

  /// Light theme: Hint / secondary text
  static const Color textSecondaryLight = Color(0xFF757575);

  /// Light theme: Borders & dividers
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFCCCCCC);

  // ────────────────────────────────────────────────────────────────────────────
  // DARK THEME COLORS (Original)
  // ────────────────────────────────────────────────────────────────────────────

  /// Dark theme: Page background
  static const Color background = Color(0xFF121212);

  /// Dark theme: Card / container surface
  static const Color surface = Color(0xFF1E1E1E);

  /// Dark theme: Light grey section background
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  /// Dark theme: Primary text
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Dark theme: Body text
  static const Color textBody = Color(0xFFE0E0E0);

  /// Dark theme: Hint / secondary text
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Dark theme: Borders & dividers
  static const Color divider = Color(0xFF3A3A3A);
  static const Color border = Color(0xFF404040);
}
