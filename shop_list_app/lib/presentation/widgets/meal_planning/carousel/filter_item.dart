import 'package:flutter/widgets.dart';

class FilterItem extends StatelessWidget {
  final VoidCallback onFilterSelected;
  final String day;

  const FilterItem(
      {super.key, required this.onFilterSelected, required this.day});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilterSelected,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipOval(
            child: Text(day),
          ),
        ),
      ),
    );
  }
}
