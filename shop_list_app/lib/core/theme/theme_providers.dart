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

// Global instance - nullable so it can be lazily created
AppThemeController? _themeController;
bool _themeInitialized = false;

/// Initialize in main() - MUST be called before creating ProviderScope
Future<void> initializeThemeProvider() async {
  if (_themeInitialized) return;
  _themeInitialized = true;

  print('[THEME_INIT] Loading theme from storage...');
  await AppThemeController.loadTheme();
  print(
      '[THEME_INIT] Creating controller with _savedTheme: ${AppThemeController._savedTheme}');
  _themeController = AppThemeController();
  print('[THEME_INIT] Done! Theme: ${_themeController!.state}');
}

/// The app theme provider - always returns the same instance
final appThemeTypeProvider =
    StateNotifierProvider<AppThemeController, AppThemeType>((ref) {
  print(
      '[PROVIDER] initialized=$_themeInitialized, hasController=${_themeController != null}');

  // If not initialized yet, initialize now (fallback in case initializeThemeProvider wasn't called)
  if (_themeController == null) {
    print('[PROVIDER] Creating controller (fallback)');
    _themeController = AppThemeController();
  }

  print(
      '[PROVIDER] Returning controller with state: ${_themeController!.state}');
  return _themeController!;
});

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(appThemeTypeProvider);
  return AppTheme.of(themeType);
});
