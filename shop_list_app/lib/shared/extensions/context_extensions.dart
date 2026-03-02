import 'package:flutter/material.dart';

/// Convenience getters on [BuildContext] to reduce boilerplate in widgets.
extension ContextExtensions on BuildContext {
  // ── Theme ─────────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // ── Screen size ───────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// True on devices wider than 600 logical pixels (tablet-class).
  bool get isTablet => screenWidth >= 600;

  // ── Feedback ──────────────────────────────────────────────────────────────

  /// Shows a standard [SnackBar]. Pass [isError] to use the error colour.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Removes the current focus (hides the keyboard).
  void hideKeyboard() => FocusScope.of(this).unfocus();

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Pushes a new [route] onto the navigator stack.
  Future<T?> push<T>(Route<T> route) => Navigator.of(this).push(route);

  /// Pops the current route.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Returns `true` when there is at least one route that can be popped.
  bool get canPop => Navigator.of(this).canPop();
}
