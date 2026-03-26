import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/navigation/app_route.dart';
import 'package:shop_list_app/shared/widgets/layout/main_shell.dart';

/// Builds a lightweight [GoRouter] that routes directly to the shell so tests
/// do not need the splash screen or real feature pages.
GoRouter _buildTestRouter({int initialIndex = 1}) {
  final initialPath = AppRoute.values[initialIndex].path;
  return GoRouter(
    initialLocation: initialPath,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.mealPlanning.path,
              builder: (_, __) => const Scaffold(body: Text('Plan Page')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.shopping.path,
              builder: (_, __) => const Scaffold(body: Text('Shop Page')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.recipes.path,
              builder: (_, __) => const Scaffold(body: Text('Recipes Page')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.pantry.path,
              builder: (_, __) => const Scaffold(body: Text('Pantry Page')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.settings.path,
              builder: (_, __) => const Scaffold(body: Text('Settings Page')),
            ),
          ]),
        ],
      ),
    ],
  );
}

Widget _buildTestApp(GoRouter router) {
  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('MainShell – bottom navigation', () {
    testWidgets('shows 5 navigation destinations', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('starts on the Shop tab (index 1)', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter(initialIndex: 1)));
      await tester.pumpAndSettle();

      expect(find.text('Shop Page'), findsOneWidget);
    });

    testWidgets('tapping Plan tab shows Plan page', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_plan')));
      await tester.pumpAndSettle();

      expect(find.text('Plan Page'), findsOneWidget);
    });

    testWidgets('tapping Recipes tab shows Recipes page', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_recipes')));
      await tester.pumpAndSettle();

      expect(find.text('Recipes Page'), findsOneWidget);
    });

    testWidgets('tapping Pantry tab shows Pantry page', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_pantry')));
      await tester.pumpAndSettle();

      expect(find.text('Pantry Page'), findsOneWidget);
    });

    testWidgets('tapping Settings tab shows Settings page', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_settings')));
      await tester.pumpAndSettle();

      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('switching tabs preserves previous tab state', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      // Navigate to Recipes
      await tester.tap(find.byKey(const Key('nav_recipes')));
      await tester.pumpAndSettle();
      expect(find.text('Recipes Page'), findsOneWidget);

      // Navigate away then back – IndexedStack preserves state
      await tester.tap(find.byKey(const Key('nav_plan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav_recipes')));
      await tester.pumpAndSettle();
      expect(find.text('Recipes Page'), findsOneWidget);
    });

    testWidgets('tapping all 5 tabs each shows correct page', (tester) async {
      await tester.pumpWidget(_buildTestApp(_buildTestRouter()));
      await tester.pumpAndSettle();

      final tabs = [
        (const Key('nav_plan'), 'Plan Page'),
        (const Key('nav_shop'), 'Shop Page'),
        (const Key('nav_recipes'), 'Recipes Page'),
        (const Key('nav_pantry'), 'Pantry Page'),
        (const Key('nav_settings'), 'Settings Page'),
      ];

      for (final (key, content) in tabs) {
        await tester.tap(find.byKey(key));
        await tester.pumpAndSettle();
        expect(find.text(content), findsOneWidget,
            reason: 'Expected $content when tapping $key');
      }
    });
  });
}
