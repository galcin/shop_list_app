import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

/// The currently selected app theme. This can be expanded later with more
/// named themes for user selection.
final appThemeTypeProvider =
    StateProvider<AppThemeType>((_) => AppThemeType.light);

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(appThemeTypeProvider);
  return AppTheme.of(themeType);
});
