import 'package:flutter/material.dart';
import 'package:shop_list_app/core/constants/app_constants.dart';

/// A centred empty-state placeholder.
///
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.receipt_long_outlined,
///   title: 'No recipes yet',
///   subtitle: 'Tap + to add your first recipe',
///   actionLabel: '+ Add Recipe',
///   onAction: () => _showCreateSheet(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Large icon shown at 50 % opacity.
  final IconData icon;

  /// Primary heading text — rendered as `titleLarge`.
  final String title;

  /// Optional supporting text — rendered as `bodyMedium` in `textSecondary`.
  final String? subtitle;

  /// Label for the optional CTA button. Requires [onAction].
  final String? actionLabel;

  /// Callback for the optional CTA button.
  final VoidCallback? onAction;

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
            Opacity(
              opacity: 0.5,
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
