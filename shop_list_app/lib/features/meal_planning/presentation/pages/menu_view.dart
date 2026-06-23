import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/database/tables/meal_slot_table.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';
import 'package:shop_list_app/features/meal_planning/presentation/providers/meal_plan_providers.dart';
import 'package:shop_list_app/features/meal_planning/presentation/widgets/recipe_picker_bottom_sheet.dart';

class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final mealPlanAsync = ref.watch(combinedSevenDayPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Meal Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            onPressed: () {
              ref.read(selectedWeekProvider.notifier).goToPreviousWeek();
            },
          ),
          Center(
            child: Text(
              _getWeekRangeString(selectedWeek),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 18),
            onPressed: () {
              ref.read(selectedWeekProvider.notifier).goToNextWeek();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1E1E1E),
            onSelected: (value) {
              if (value == 'duplicate') {
                ref
                    .read(weeklyMealPlanProvider.notifier)
                    .duplicatePreviousWeek();
              } else if (value == 'clear') {
                _showClearWeekDialog(context, ref, mealPlanAsync.value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Copy from Previous Week',
                    style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Week', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: mealPlanAsync.when(
        data: (plan) {
          if (plan == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            );
          }
          return _buildWeekView(context, ref, plan, selectedWeek);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: mealPlanAsync.when(
        data: (plan) {
          if (plan == null || plan.assignedRecipeCount == 0) return null;
          return FloatingActionButton(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            onPressed: () => _showGenerateListDialog(context, ref, plan),
            child: const Icon(Icons.shopping_cart),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildWeekView(
      BuildContext context, WidgetRef ref, MealPlan plan, DateTime weekStart) {
    return Column(
      children: [
        // Day selector row
        _buildDaySelector(context, weekStart),
        const SizedBox(height: 16),
        // Meal slots for the week
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              return _buildDaySection(context, ref, plan, date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(BuildContext context, DateTime weekStart) {
    final today = DateTime.now();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekStart.add(Duration(days: index));
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          // Get the short day name dynamically
          final shortDayName = _getShortDayName(date);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shortDayName,
                  style: TextStyle(
                    color: isToday ? const Color(0xFFFF6B35) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isToday ? const Color(0xFFFF6B35) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySection(
      BuildContext context, WidgetRef ref, MealPlan plan, DateTime date) {
    // Get slots for this date from the combined plan (which includes both weeks)
    final slots = plan.getSlotsForDate(date);
    final dayName = _getDayName(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '$dayName, ${_formatDate(date)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...MealType.values.map((mealType) {
          final slot = slots.firstWhere(
            (s) => s.mealType == mealType,
            orElse: () => MealSlot(
              planId: plan.id!,
              date: date,
              mealType: mealType,
            ),
          );
          return _buildMealSlot(context, ref, slot, mealType);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMealSlot(
      BuildContext context, WidgetRef ref, MealSlot slot, MealType mealType) {
    final isEmpty = slot.isEmpty;
    final icon = _getMealIcon(mealType);
    final label = _getMealLabel(mealType);

    return GestureDetector(
      onTap: () {
        if (isEmpty) {
          // TODO: Open recipe picker
          _showRecipePicker(context, ref, slot);
        } else {
          // Show context menu
          _showSlotContextMenu(context, ref, slot);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.transparent : const Color(0xFF1E1E1E),
          border: Border.all(
            color: isEmpty ? const Color(0xFFFF6B35) : Colors.transparent,
            width: 1,
            style: isEmpty ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEmpty ? '+ Tap to add' : slot.displayName ?? '',
                    style: TextStyle(
                      color: isEmpty ? const Color(0xFFFF6B35) : Colors.white,
                      fontSize: 14,
                      fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🌞';
      case MealType.dinner:
        return '🌙';
    }
  }

  String _getMealLabel(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  String _getDayName(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  String _getShortDayName(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getWeekRangeString(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${_formatDate(weekStart)} – ${_formatDate(weekEnd)}';
  }

  void _showRecipePicker(BuildContext context, WidgetRef ref, MealSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipePickerBottomSheet(slot: slot),
    );
  }

  void _showSlotContextMenu(
      BuildContext context, WidgetRef ref, MealSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Change Recipe',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showRecipePicker(context, ref, slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.red),
              title:
                  const Text('Clear Slot', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(weeklyMealPlanProvider.notifier).clearSlot(slot.id!);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showClearWeekDialog(
      BuildContext context, WidgetRef ref, MealPlan? plan) {
    if (plan == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear the entire week?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'All recipe assignments for ${plan.weekRangeString} will be removed. Shopping lists are not affected.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(weeklyMealPlanProvider.notifier).clearWeek(plan.id!);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGenerateListDialog(
      BuildContext context, WidgetRef ref, MealPlan plan) {
    if (plan.id == null) return;

    final listName = 'Week of ${_formatDate(plan.weekStartDate)}';
    final recipeCount = plan.assignedRecipeCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Generate Shopping List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                listName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Divider(height: 24, color: Colors.grey),
              Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '$recipeCount recipes assigned',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text('🔗', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Duplicates will be merged automatically',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _generateShoppingList(context, ref, plan, listName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart),
                    SizedBox(width: 8),
                    Text('Create Shopping List'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateShoppingList(BuildContext context, WidgetRef ref, MealPlan plan,
      String listName) async {
    if (plan.id == null) return;

    late BuildContext dialogContext;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const Center(
          child: Card(
            color: Color(0xFF1E1E1E),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  SizedBox(height: 16),
                  Text(
                    'Building your list…',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final int listId = await ref
          .read(weeklyMealPlanProvider.notifier)
          .generateShoppingList(planId: plan.id!, listName: listName)
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Shopping list generation took too long. Please try again.',
          );
        },
      );

      if (context.mounted && dialogContext.mounted) {
        Navigator.of(dialogContext).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shopping list "$listName" created!'),
            backgroundColor: const Color(0xFF4CAF50),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                if (context.mounted) {
                  Future.microtask(() {
                    if (context.mounted) {
                      GoRouter.of(context).push('/shopping/$listId');
                    }
                  });
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && dialogContext.mounted) {
        try {
          Navigator.of(dialogContext).pop(); // Close loading dialog
        } catch (_) {
          // Dialog already closed
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating list: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
