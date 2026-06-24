import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_simple.dart';
import 'shared/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(appThemeProvider);
    final selectedTheme = AppTheme.of(themeType);

    // Determine theme mode based on selected theme
    ThemeMode themeMode;
    if (themeType == AppThemeType.light) {
      themeMode = ThemeMode.light;
    } else {
      // For dark and green themes, use dark mode
      themeMode = ThemeMode.dark;
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeType == AppThemeType.light ? AppTheme.light : selectedTheme,
      darkTheme: selectedTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
