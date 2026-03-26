import 'package:flutter/material.dart';

/// A generic app navigation bar built on [NavigationBar].
///
/// Pass [destinations] to configure the tabs, [selectedIndex] to highlight
/// the active tab, and [onDestinationSelected] to handle tab changes.
/// This makes the bar reusable across different navigation shells.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.height = 65,
    this.labelBehavior = NavigationDestinationLabelBehavior.alwaysShow,
    super.key,
  });

  /// The list of destinations (tabs) to display.
  final List<NavigationDestination> destinations;

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// Called when the user taps a destination.
  final ValueChanged<int> onDestinationSelected;

  /// Height of the navigation bar.
  final double height;

  /// Controls how labels are shown for navigation destinations.
  final NavigationDestinationLabelBehavior labelBehavior;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: height,
      labelBehavior: labelBehavior,
      destinations: destinations,
    );
  }
}
