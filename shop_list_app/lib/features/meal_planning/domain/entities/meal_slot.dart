import 'package:equatable/equatable.dart';
import 'package:shop_list_app/core/database/tables/meal_slot_table.dart';

/// A single meal slot (breakfast, lunch, or dinner) for a specific day.
class MealSlot extends Equatable {
  final int? id;
  final int planId;
  final DateTime date;
  final MealType mealType;
  final int? recipeId;
  final String? recipeName; // Denormalized for display
  final String? recipeImageUrl; // Denormalized for display
  final String? customName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MealSlot({
    this.id,
    required this.planId,
    required this.date,
    required this.mealType,
    this.recipeId,
    this.recipeName,
    this.recipeImageUrl,
    this.customName,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if this slot is empty (no recipe and no custom name).
  bool get isEmpty => recipeId == null && (customName?.trim().isEmpty ?? true);

  /// Get display name for this slot.
  String? get displayName => recipeName ?? customName;

  MealSlot copyWith({
    int? id,
    int? planId,
    DateTime? date,
    MealType? mealType,
    int? recipeId,
    String? recipeName,
    String? recipeImageUrl,
    String? customName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealSlot(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeImageUrl: recipeImageUrl ?? this.recipeImageUrl,
      customName: customName ?? this.customName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Clear the recipe assignment, keeping the slot empty.
  MealSlot clear() {
    return MealSlot(
      id: id,
      planId: planId,
      date: date,
      mealType: mealType,
      recipeId: null,
      recipeName: null,
      recipeImageUrl: null,
      customName: null,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        planId,
        date,
        mealType,
        recipeId,
        recipeName,
        recipeImageUrl,
        customName,
        createdAt,
        updatedAt,
      ];
}
