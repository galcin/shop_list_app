import 'package:flutter/material.dart';
import 'package:shop_list_app/core/constants/app_constants.dart';

/// A centred error-state widget with an optional retry action.
///
/// ```dart
/// ErrorStateWidget(
///   message: e.toString(),
///   onRetry: () => ref.refresh(myProvider),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.message,
    this.onRetry,
    super.key,
  });

  /// Human-readable error description.
  final String message;

  /// When provided, a "Try again" button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
