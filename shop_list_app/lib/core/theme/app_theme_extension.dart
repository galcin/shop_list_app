import 'package:flutter/material.dart';
import 'colors.dart';

/// Theme extension for custom app colors that are not exposed directly by
/// [ColorScheme]. This makes it easy to support multiple named themes and
/// switch values at runtime.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.accent,
    required this.error,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textBody,
    required this.textSecondary,
    required this.onPrimary,
    required this.divider,
    required this.border,
    required this.favourite,
    required this.rating,
  });

  final Color primary;
  final Color accent;
  final Color error;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textBody;
  final Color textSecondary;
  final Color onPrimary;
  final Color divider;
  final Color border;
  final Color favourite;
  final Color rating;

  static const AppThemeColors light = AppThemeColors(
    primary: AppColors.primary,
    accent: AppColors.accent,
    error: AppColors.error,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textBody: AppColors.textBody,
    textSecondary: AppColors.textSecondary,
    onPrimary: AppColors.onPrimary,
    divider: AppColors.divider,
    border: AppColors.border,
    favourite: AppColors.favourite,
    rating: AppColors.rating,
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: AppColors.primary,
    accent: AppColors.accent,
    error: AppColors.error,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFFFFFFF),
    textBody: Color(0xFFDDDDDD),
    textSecondary: Color(0xFFB0B0B0),
    onPrimary: AppColors.onPrimary,
    divider: Color(0xFF373737),
    border: Color(0xFF2F2F2F),
    favourite: AppColors.favourite,
    rating: AppColors.rating,
  );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? accent,
    Color? error,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textBody,
    Color? textSecondary,
    Color? onPrimary,
    Color? divider,
    Color? border,
    Color? favourite,
    Color? rating,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      onPrimary: onPrimary ?? this.onPrimary,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      favourite: favourite ?? this.favourite,
      rating: rating ?? this.rating,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      favourite: Color.lerp(favourite, other.favourite, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
    );
  }
}
