import 'package:equatable/equatable.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';

/// A weekly meal plan containing meal slots for each day.
class MealPlan extends Equatable {
  final int? id;
  final DateTime weekStartDate;
  final List<MealSlot> slots;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MealPlan({
    this.id,
    required this.weekStartDate,
    this.slots = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Get the end date of the week (6 days after start).
  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  /// Get a formatted week range string (e.g., "Mar 3 – Mar 9").
  String get weekRangeString {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final start = weekStartDate;
    final end = weekEndDate;
    return '${monthNames[start.month - 1]} ${start.day} – ${monthNames[end.month - 1]} ${end.day}';
  }

  /// Get all slots for a specific date.
  List<MealSlot> getSlotsForDate(DateTime date) {
    return slots.where((s) => isSameDay(s.date, date)).toList()
      ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));
  }

  /// Get all recipe IDs assigned in this plan (non-null).
  List<int> get assignedRecipeIds {
    return slots
        .where((s) => s.recipeId != null)
        .map((s) => s.recipeId!)
        .toList();
  }

  /// Count total assigned recipes.
  int get assignedRecipeCount => assignedRecipeIds.length;

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  MealPlan copyWith({
    int? id,
    DateTime? weekStartDate,
    List<MealSlot>? slots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      slots: slots ?? this.slots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        weekStartDate,
        slots,
        createdAt,
        updatedAt,
      ];
}
