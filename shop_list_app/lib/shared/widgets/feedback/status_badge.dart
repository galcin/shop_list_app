import 'package:flutter/material.dart';

/// A compact coloured badge with an icon and label.
///
/// Used to signal status conditions such as "Expired" or "Expiring Soon".
/// Pass [color] to control the border, background tint, icon and text colour.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    this.icon = Icons.warning_amber_rounded,
    super.key,
  });

  final String label;
  final Color color;

  /// Leading icon. Defaults to a warning triangle.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
