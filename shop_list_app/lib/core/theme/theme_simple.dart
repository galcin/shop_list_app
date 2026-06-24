import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class AppThemeNotifier extends StateNotifier<AppThemeType> {
  static const _prefKey = 'app_theme_type';

  AppThemeNotifier(AppThemeType initial) : super(initial) {
    print('[NOTIFIER] Created with state: $state');
  }

  Future<void> setTheme(AppThemeType themeType) async {
    print('[NOTIFIER] setTheme: $themeType (was: $state)');

    state = themeType;
    print('[NOTIFIER] State is now: $state');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, themeType.name);
      print('[NOTIFIER] Saved: ${themeType.name}');
    } catch (e) {
      print('[NOTIFIER] Save error: $e');
    }
  }

  static Future<AppThemeType> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);

      if (saved != null) {
        final idx = AppThemeType.values.indexWhere((t) => t.name == saved);
        if (idx >= 0) {
          print('[NOTIFIER] Loaded: $saved');
          return AppThemeType.values[idx];
        }
      }
    } catch (e) {
      print('[NOTIFIER] Load error: $e');
    }

    return AppThemeType.light;
  }
}

// Store the initial theme - initialize with default to prevent late initialization errors
AppThemeType _initialTheme = AppThemeType.light;

// This MUST be called in main() before ProviderScope
Future<void> initializeTheme() async {
  print('[INIT] Loading theme...');
  _initialTheme = await AppThemeNotifier.loadSavedTheme();
  print('[INIT] Theme loaded: $_initialTheme');
}

/// The theme provider - returns the same notifier instance
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, AppThemeType>(
  (ref) {
    print('[PROVIDER] Creating notifier with: $_initialTheme');
    return AppThemeNotifier(_initialTheme);
  },
);
