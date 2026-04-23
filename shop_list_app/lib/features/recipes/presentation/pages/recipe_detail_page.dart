import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';

class RecipeDetailPage extends ConsumerStatefulWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Ingredients', 'Instructions', 'Notes'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Current serving count for this recipe session.
  int _servingCount(int original) => ref
      .watch(servingCountProvider(widget.recipeId))
      .let((v) => v == 0 ? original : v);

  void _incrementServings(int current) {
    ref.read(servingCountProvider(widget.recipeId).notifier).state =
        current + 1;
  }

  void _decrementServings(int current, int original) {
    if (current > 1) {
      ref.read(servingCountProvider(widget.recipeId).notifier).state =
          current - 1;
    }
  }

  void _resetServings() {
    ref.read(servingCountProvider(widget.recipeId).notifier).state = 0;
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Recipe',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${recipe.name}" from your recipes?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style:
                    TextStyle(fontFamily: 'Poppins', color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final result = await ref
          .read(recipeListProvider.notifier)
          .deleteRecipe(widget.recipeId);
      result.fold(
        (f) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(f.message)),
            );
          }
        },
        (_) {
          if (mounted) context.pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncRecipe = ref.watch(recipeDetailProvider(widget.recipeId));

    return asyncRecipe.when(
      loading: () => const Scaffold(body: LoadingStateWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(recipeDetailProvider(widget.recipeId)),
        ),
      ),
      data: (recipe) {
        final originalServings = recipe.servings ?? 1;
        final currentServings = _servingCount(originalServings);
        final scaled = currentServings != originalServings
            ? recipe.scaleServings(currentServings)
            : recipe;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(recipe),
              SliverToBoxAdapter(
                  child: _buildContent(
                      recipe, scaled, originalServings, currentServings)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            recipe.favorite == true ? Icons.star : Icons.star_border,
            color: AppColors.accent,
          ),
          onPressed: () async {
            final updated =
                recipe.copyWith(favorite: !(recipe.favorite ?? false));
            await ref.read(recipeListProvider.notifier).saveRecipe(updated);
            ref.invalidate(recipeDetailProvider(widget.recipeId));
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (v) {
            if (v == 'edit')
              context.push('/recipes/${recipe.id}/edit', extra: recipe);
            if (v == 'delete') _confirmDelete(recipe);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.textPrimary),
                SizedBox(width: 10),
                Text('Edit', style: TextStyle(fontFamily: 'Poppins')),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                SizedBox(width: 10),
                Text('Delete',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: AppColors.error)),
              ]),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                ? Image.network(recipe.imageUrl!,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) => _heroBg())
                : _heroBg(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBg() => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.restaurant_menu,
              color: AppColors.textSecondary, size: 64),
        ),
      );

  Widget _buildContent(
      Recipe recipe, Recipe scaled, int originalServings, int currentServings) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recipe.name ?? 'Recipe',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildServingsStepper(originalServings, currentServings),
              ],
            ),
          ),
          if (recipe.rating != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recipe.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBody),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Badge chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              children: [
                if (recipe.totalTime > 0)
                  _badge(Icons.access_time, '${recipe.totalTime} min'),
                if (recipe.servings != null)
                  _badge(
                      Icons.restaurant_outlined, '$currentServings servings'),
                if (recipe.description != null &&
                    recipe.description!.isNotEmpty)
                  _badge(Icons.info_outline, recipe.description!, maxChars: 20),
              ],
            ),
          ),
          // Reset button when scaled.
          if (currentServings != originalServings) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton.icon(
                onPressed: _resetServings,
                icon: const Icon(Icons.refresh,
                    size: 16, color: AppColors.textSecondary),
                label: Text(
                  '↺ Reset to $originalServings',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textSecondary,
                      fontSize: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientsTab(scaled),
                _buildInstructionsTab(recipe),
                _buildNotesTab(recipe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsStepper(int original, int current) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_outlined,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _decrementServings(current, original),
            child: const Icon(Icons.remove, size: 18, color: AppColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$current',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => _incrementServings(current),
            child: const Icon(Icons.add, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, {int maxChars = 999}) {
    final text =
        label.length > maxChars ? '${label.substring(0, maxChars)}…' : label;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12, color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe scaled) {
    final ingredients = scaled.ingredients ?? [];
    if (ingredients.isEmpty) {
      return const Center(
        child: Text(
          'No ingredients added yet.',
          style:
              TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, i) {
        final ing = ingredients[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ing.name,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: AppColors.textPrimary),
                ),
              ),
              Text(
                '${ing.quantity}${ing.unit.isNotEmpty ? ' ${ing.unit}' : ''}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionsTab(Recipe recipe) {
    final steps = recipe.instructionSteps;
    if (steps.isEmpty) {
      return const Center(
        child: Text(
          'No instructions added yet.',
          style:
              TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: steps.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  steps[i],
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textBody,
                      height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab(Recipe recipe) {
    final desc = recipe.description ?? '';
    if (desc.isEmpty) {
      return const Center(
        child: Text(
          'No notes added yet.',
          style:
              TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        desc,
        style: const TextStyle(
            fontFamily: 'Poppins', color: AppColors.textBody, height: 1.6),
      ),
    );
  }
}

extension _LetExtension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
