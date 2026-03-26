import 'package:flutter/material.dart';

/// A labelled info row with a tinted icon on the left and a two-line
/// label/value column on the right.
///
/// Used on detail pages to display a single piece of metadata (e.g. category,
/// quantity, expiry date) in a consistent style.
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Colour applied to the icon and its background tint. Defaults to grey.
  final Color? iconColor;

  /// Colour applied to the value text. Defaults to near-black.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? const Color(0xFF7C7C7C);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: resolvedIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: resolvedIconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF181725),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
