import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/shared/widgets/feedback/async_value_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  // ──────────────────────────────────────────────────────────────
  // EmptyStateWidget
  // ──────────────────────────────────────────────────────────────
  group('EmptyStateWidget', () {
    testWidgets('renders icon, title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'No items yet',
          subtitle: 'Tap + to add one',
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Tap + to add one'), findsOneWidget);
    });

    testWidgets('does NOT show CTA button when onAction is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(
          title: 'Nothing here',
          actionLabel: 'Add',
          // onAction intentionally omitted
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('shows CTA button and calls onAction when provided',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        EmptyStateWidget(
          title: 'Nothing here',
          actionLabel: '+ Add Recipe',
          onAction: () => tapped = true,
        ),
      ));

      expect(find.text('+ Add Recipe'), findsOneWidget);
      await tester.tap(find.text('+ Add Recipe'));
      expect(tapped, isTrue);
    });

    testWidgets('subtitle is optional — omitted when not provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(title: 'Nothing here'),
      ));

      // Only titleLarge text expected, no body text
      expect(find.text('Nothing here'), findsOneWidget);
      // icon is rendered
      expect(find.byType(Opacity), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // ErrorStateWidget
  // ──────────────────────────────────────────────────────────────
  group('ErrorStateWidget', () {
    testWidgets('renders error icon, heading and message', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorStateWidget(message: 'Network unavailable'),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network unavailable'), findsOneWidget);
    });

    testWidgets('does NOT show retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorStateWidget(message: 'Oops'),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('shows retry button and calls onRetry when provided',
        (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(
        ErrorStateWidget(
          message: 'Oops',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // LoadingStateWidget
  // ──────────────────────────────────────────────────────────────
  group('LoadingStateWidget', () {
    testWidgets('renders shimmer and skeleton cards', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingStateWidget(itemCount: 2)));

      expect(find.byType(LoadingStateWidget), findsOneWidget);
      // The shimmer wraps a ListView; at least one card should be present
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('renders specified number of skeleton cards', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingStateWidget(itemCount: 3)));
      // 3 cards expected
      expect(find.byType(Card), findsNWidgets(3));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // AsyncValueWidget
  // ──────────────────────────────────────────────────────────────
  group('AsyncValueWidget', () {
    testWidgets('shows default LoadingStateWidget while loading',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncValueWidget<String>(
          value: const AsyncValue.loading(),
          data: (s) => Text(s),
        ),
      ));

      expect(find.byType(LoadingStateWidget), findsOneWidget);
    });

    testWidgets('shows default ErrorStateWidget on error', (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncValueWidget<String>(
          value: AsyncValue.error(Exception('boom'), StackTrace.empty),
          data: (s) => Text(s),
        ),
      ));

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows data widget when data is available', (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncValueWidget<String>(
          value: const AsyncValue.data('Hello'),
          data: (s) => Text(s),
        ),
      ));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('custom loading builder is used when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncValueWidget<String>(
          value: const AsyncValue.loading(),
          loading: () => const Text('Custom loading'),
          data: (s) => Text(s),
        ),
      ));

      expect(find.text('Custom loading'), findsOneWidget);
    });

    testWidgets('custom error builder is used when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncValueWidget<String>(
          value: AsyncValue.error(Exception('bad'), StackTrace.empty),
          error: (e, _) => Text('Err: $e'),
          data: (s) => Text(s),
        ),
      ));

      expect(find.textContaining('Err:'), findsOneWidget);
    });
  });
}
