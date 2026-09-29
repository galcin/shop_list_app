import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_type.dart';
import 'package:shop_list_app/features/meal_planning/presentation/providers/meal_plan_providers.dart';
import 'package:shop_list_app/features/meal_planning/presentation/widgets/recipe_picker_bottom_sheet.dart';
import 'package:shop_list_app/features/meal_planning/presentation/widgets/recipes_by_pantry_modal.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedDate = ref.watch(selectedWeekProvider);
    final mealPlanAsync = ref.watch(weeklyMealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Meal Plan',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: () {
                final today = DateTime.now();
                final todayOnly = DateTime(today.year, today.month, today.day);
                return selectedDate.isAfter(todayOnly)
                    ? colors.onSurface
                    : colors.onSurface.withValues(alpha: 0.38);
              }(),
              size: 18,
            ),
            onPressed: () {
              final today = DateTime.now();
              final todayOnly = DateTime(today.year, today.month, today.day);
              if (selectedDate.isAfter(todayOnly)) {
                ref.read(selectedWeekProvider.notifier).goToPreviousDay();
              }
            },
          ),
          Center(
            child: Text(
              _getDateString(selectedDate),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: colors.onSurface, size: 18),
            onPressed: () {
              ref.read(selectedWeekProvider.notifier).goToNextDay();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.onSurface),
            color: colors.surface,
            onSelected: (value) async {
              if (value == 'duplicate') {
                try {
                  await ref
                      .read(weeklyMealPlanProvider.notifier)
                      .duplicatePreviousWeek();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Could not copy previous week: $e')),
                    );
                  }
                }
              } else if (value == 'clear') {
                _showClearDayDialog(
                  context,
                  ref,
                  mealPlanAsync.value,
                  selectedDate,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Copy from Previous Week', style: TextStyle()),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Day', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          const threshold = 100.0;
          final dx = details.primaryVelocity ?? 0;
          final today = DateTime.now();
          final todayOnly = DateTime(today.year, today.month, today.day);
          if (dx < -threshold) {
            ref.read(selectedWeekProvider.notifier).goToNextDay();
          } else if (dx > threshold && selectedDate.isAfter(todayOnly)) {
            ref.read(selectedWeekProvider.notifier).goToPreviousDay();
          }
        },
        child: mealPlanAsync.when(
          data: (plan) {
            if (plan == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              );
            }
            return _buildDayView(context, ref, plan, selectedDate);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayView(
      BuildContext context, WidgetRef ref, MealPlan plan, DateTime date) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Meal slots for the selected day
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildDaySection(context, ref, plan, date),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: plan.assignedRecipeCount > 0
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => showRecipesByPantryModal(context),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('What can I cook?'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showGenerateListDialog(context, ref, plan),
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Generate List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF53B175),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showRecipesByPantryModal(context),
                    icon: const Icon(Icons.search),
                    label: const Text('What can I cook?'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
        ),
      ],
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
    final colors = Theme.of(context).colorScheme;
    final isEmpty = slot.isEmpty;
    final icon = _getMealIcon(mealType);
    final label = _getMealLabel(mealType);
    final accentColor = _getMealAccentColor(mealType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          if (isEmpty) {
            _showRecipePicker(context, ref, slot);
          } else {
            _showSlotContextMenu(context, ref, slot);
          }
        },
        child: isEmpty
            ? _buildEmptySlot(icon, label, accentColor)
            : AccentCircleListCard(
                height: 84,
                accentColor: accentColor,
                circleChild: CircleAccentAvatar(
                  accentColor: accentColor,
                  size: 84,
                  child: Container(
                    color: accentColor.withOpacity(0.08),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 50, right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        slot.displayName ?? '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptySlot(String icon, String label, Color accentColor) {
    return AccentCircleListCard(
      height: 84,
      accentColor: accentColor,
      circleChild: CircleAccentAvatar(
        accentColor: accentColor,
        size: 84,
        child: Container(
          color: accentColor.withOpacity(0.08),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 40)),
          ),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '+ Tap to add',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: accentColor,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealAccentColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFFFB84D); // Warm orange for morning
      case MealType.lunch:
        return const Color(0xFF53B175); // Green for lunch
      case MealType.dinner:
        return const Color(0xFF9C27B0); // Purple for dinner
    }
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

  String _getDateString(DateTime date) {
    return '${_getShortDayName(date)}, ${_formatDate(date)}';
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
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: colors.onSurface),
              title: Text('Change Recipe',
                  style: TextStyle(color: colors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showRecipePicker(context, ref, slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.red),
              title:
                  const Text('Clear Slot', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ref
                      .read(weeklyMealPlanProvider.notifier)
                      .clearSlot(slot.id!);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not clear slot: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showClearDayDialog(
      BuildContext context, WidgetRef ref, MealPlan? plan, DateTime date) {
    if (plan == null) return;
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text('Clear this day?', style: TextStyle(color: colors.onSurface)),
        content: Text(
          'All recipe assignments for ${_getDateString(date)} will be removed. Shopping lists are not affected.',
          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                    TextStyle(color: colors.onSurface.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(weeklyMealPlanProvider.notifier).clearDay(
                      planId: plan.id!,
                      date: date,
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not clear day: $e')),
                  );
                }
              }
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
    final colors = Theme.of(context).colorScheme;

    final listName = 'Week of ${_formatDate(plan.weekStartDate)}';
    final recipeCount = plan.assignedRecipeCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                listName,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              Divider(
                  height: 24, color: colors.onSurface.withValues(alpha: 0.3)),
              Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '$recipeCount recipes assigned',
                    style: TextStyle(color: colors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('🔗', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Duplicates will be merged automatically',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
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
                child: Text('Cancel',
                    style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7))),
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
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  SizedBox(height: 16),
                  Text(
                    'Building your list…',
                    style: TextStyle(),
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
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Shopping list "$listName" created!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                messenger.hideCurrentSnackBar();
                if (context.mounted) {
                  context.go('/shopping/$listId');
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
