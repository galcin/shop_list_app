import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected bottom navigation tab index (0–4).
///
/// Tab mapping:
///   0 = Plan (Meal Planning)
///   1 = Shop (Shopping)
///   2 = Recipes
///   3 = Pantry
///   4 = Settings
final navigationIndexProvider = StateProvider<int>((ref) => 0);
