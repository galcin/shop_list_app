import 'package:flutter/material.dart';
import 'package:shop_list_app/core/constants/app_constants.dart';

/// A generic shimmer-ready skeleton card placeholder.
///
/// Renders an image placeholder followed by title and metadata shimmer bars.
/// The dimensions can be customised via [imageHeight] and [metadataWidth]
/// to fit different list contexts.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    this.imageHeight = 150,
    this.metadataWidth = 100,
    super.key,
  });

  /// Height of the image placeholder area.
  final double imageHeight;

  /// Width of the secondary metadata shimmer bar.
  final double metadataWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: imageHeight,
            width: double.infinity,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder — full width
                Container(
                  height: AppSpacing.md,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Metadata placeholder — configurable width
                Container(
                  height: AppSpacing.md,
                  width: metadataWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
