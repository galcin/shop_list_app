import 'package:flutter/material.dart';

/// A simple horizontal key/value row used inside detail or info panels.
///
/// Label is left-aligned in grey; value is right-aligned in near-black bold.
class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF7C7C7C),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181725),
            ),
          ),
        ],
      ),
    );
  }
}
