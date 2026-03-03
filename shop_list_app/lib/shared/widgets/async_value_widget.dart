import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'error_state_widget.dart';
import 'loading_state_widget.dart';

/// Convenience widget that maps a Riverpod [AsyncValue] to the three standard
/// states: loading, error, and data.
///
/// ```dart
/// AsyncValueWidget<List<ProductCategory>>(
///   value: ref.watch(watchCategoriesProvider),
///   loading: () => LoadingStateWidget(),
///   error: (e, st) => ErrorStateWidget(
///     message: e.toString(),
///     onRetry: () => ref.refresh(watchCategoriesProvider),
///   ),
///   data: (categories) => categories.isEmpty
///       ? EmptyStateWidget(title: 'No categories yet')
///       : CategoryListView(categories: categories),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  /// The async value to display.
  final AsyncValue<T> value;

  /// Builder called when data is available.
  final Widget Function(T data) data;

  /// Builder called while loading. Defaults to [LoadingStateWidget].
  final Widget Function()? loading;

  /// Builder called on error. Defaults to [ErrorStateWidget].
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: loading ?? () => const LoadingStateWidget(),
      error: error ?? (err, st) => ErrorStateWidget(message: err.toString()),
      data: data,
    );
  }
}
