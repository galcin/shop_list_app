// product_image_widget.dart
//
// Renders a product photo (local file path) or emoji icon, falling back to a
// default shopping-bag icon when the photo field is empty.
import 'dart:io';
import 'package:flutter/material.dart';

class ProductImageWidget extends StatelessWidget {
  final String? photo;

  /// Side length in logical pixels.
  final double size;

  /// Corner radius of the container.
  final double borderRadius;

  /// Background color of the container.
  final Color? backgroundColor;

  const ProductImageWidget({
    super.key,
    this.photo,
    this.size = 64,
    this.borderRadius = 12,
    this.backgroundColor,
  });

  bool get _isFilePath =>
      photo != null && (photo!.startsWith('/') || photo!.startsWith('file://'));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF2F3F2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (photo == null || photo!.isEmpty) {
      return Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: size * 0.5,
          color: const Color(0xFFDBDBDB),
        ),
      );
    }

    if (_isFilePath) {
      final filePath = photo!.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
        );
      }
      return _fallbackIcon();
    }

    // Emoji / text icon
    return Center(
      child: Text(
        photo!,
        style: TextStyle(fontSize: size * 0.45),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: size * 0.5,
        color: const Color(0xFFDBDBDB),
      ),
    );
  }
}
