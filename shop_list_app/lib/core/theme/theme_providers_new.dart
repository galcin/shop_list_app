import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class AppThemeController extends StateNotifier<AppThemeType> {
  static const _prefKey = 'app_theme_type';
  static AppThemeType _savedTheme = AppThemeType.light;

  AppThemeController() : super(_savedTheme) {
    print('[THEME_INIT] Controller created with theme: ${state}');
  }

  Future<void> setTheme(AppThemeType themeType) async {
    print('[THEME] setTheme called: $themeType (current: $state)');

    // Update state - Riverpod will notify all listeners
    state = themeType;
    _savedTheme = themeType;
    print('[THEME] State changed to: $state');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, themeType.name);
      print('[THEME] Saved to SharedPreferences: ${themeType.name}');
    } catch (e) {
      print('[THEME] Error saving: $e');
    }
  }

  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefKey);

      if (stored != null) {
        final idx = AppThemeType.values.indexWhere((t) => t.name == stored);
        if (idx >= 0) {
          _savedTheme = AppThemeType.values[idx];
          print('[THEME] Loaded from storage: $_savedTheme');
          return;
        }
      }
      _savedTheme = AppThemeType.light;
      print('[THEME] Using default light theme');
    } catch (e) {
      print('[THEME] Error loading: $e');
      _savedTheme = AppThemeType.light;
    }
  }
}

// Global instance
late AppThemeController _themeController;

/// Initialize in main() - must be called before running the app
Future<void> initializeThemeProvider() async {
  await AppThemeController.loadTheme();
  _themeController = AppThemeController();
  print('[THEME_PROVIDER] Initialized with: ${_themeController.state}');
}

/// The app theme provider
final appThemeTypeProvider =
    StateNotifierProvider<AppThemeController, AppThemeType>((ref) {
  print('[PROVIDER_FACTORY] Building theme provider');
  return _themeController;
});

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(appThemeTypeProvider);
  return AppTheme.of(themeType);
});
