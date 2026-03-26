import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_list_app/core/constants/app_constants.dart';
import 'package:shop_list_app/shared/widgets/feedback/skeleton_card.dart';

/// A shimmer skeleton loader for card-shaped content.
///
/// Shows an image placeholder followed by title and metadata shimmer bars.
/// Uses the `shimmer` package with grey-300/grey-100 colours as specified.
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    this.itemCount = 4,
    super.key,
  });

  /// How many skeleton cards to render (default 4).
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: itemCount,
        itemBuilder: (_, __) => const SkeletonCard(),
      ),
    );
  }
}
