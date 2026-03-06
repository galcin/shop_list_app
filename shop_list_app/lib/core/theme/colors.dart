import 'package:flutter/material.dart';

/// Colour tokens taken from the "Online Groceries App UI" Figma community
/// design (node-id 1-2). All hex values are as defined in that file.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────────────────────
  /// Main brand green – used for CTAs, active states, FAB, etc.
  static const Color primary = Color(0xFF53B175);

  /// Warm orange – used for sale/discount badges and accent elements.
  static const Color accent = Color(0xFFF8A44C);

  /// Soft red – used for error and destructive actions.
  static const Color error = Color(0xFFF3603F);

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  /// Page background – near-white.
  static const Color background = Color(0xFFFCFCFC);

  /// Card / container surface.
  static const Color surface = Color(0xFFFFFFFF);

  /// Light grey section background.
  static const Color surfaceVariant = Color(0xFFF2F3F2);

  // ── Text ────────────────────────────────────────────────────────────────────
  /// Primary text – dark navy.
  static const Color textPrimary = Color(0xFF181725);

  /// Body text – dark charcoal.
  static const Color textBody = Color(0xFF4C4F4D);

  /// Hint / secondary text – medium grey.
  static const Color textSecondary = Color(0xFF7C7C7C);

  /// Text on coloured buttons (white).
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Borders & Dividers ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E2E2);
  static const Color border = Color(0xFFDBDBDB);

  // ── Misc ────────────────────────────────────────────────────────────────────
  /// Favourite / wishlist red.
  static const Color favourite = Color(0xFFEB5757);

  /// Star rating yellow.
  static const Color rating = Color(0xFFF3603F);
}
