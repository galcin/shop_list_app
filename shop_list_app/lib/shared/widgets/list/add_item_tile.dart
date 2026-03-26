import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';

/// A generic "add new item" placeholder tile, suitable for use inside grids
/// or lists. Renders a centred icon plus [label] with the app's primary colour.
class AddItemTile extends StatelessWidget {
  const AddItemTile({
    super.key,
    required this.onTap,
    this.label = 'New Item',
    this.icon = Icons.add_circle_outline,
  });

  final VoidCallback onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.45),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 52),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
