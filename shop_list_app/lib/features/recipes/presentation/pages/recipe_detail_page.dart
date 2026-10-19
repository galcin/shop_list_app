import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/features/recipes/presentation/widgets/recipe_image.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';
import 'package:shop_list_app/shared/widgets/shopping_list_picker_sheet.dart';

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
  bool _addingToList = false;

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
  int _servingCount(int original) {
    final override = ref.watch(servingCountProvider(widget.recipeId));
    return override == 0 ? original : override;
  }

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

  Future<void> _toggleFavorite(Recipe recipe) async {
    final result =
        await ref.read(recipeListProvider.notifier).toggleFavorite(recipe);
    if (!mounted) return;
    result.fold(
      (f) => context.showSnackBar(f.message, isError: true),
      (_) {},
    );
  }

  Future<void> _addToShoppingList(Recipe recipe, int servings) async {
    final target = await showShoppingListPickerSheet(
      context,
      defaultNewListName: recipe.name ?? 'Shopping list',
    );
    if (target == null || !mounted) return;

    setState(() => _addingToList = true);
    final result = await ref.read(addRecipeToListUseCaseProvider).call(
          recipeId: widget.recipeId,
          listId: target.listId,
          newListName: target.newListName,
          servings: servings,
        );
    if (!mounted) return;
    setState(() => _addingToList = false);

    result.fold(
      (f) => context.showSnackBar(f.message, isError: true),
      (listId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              '${recipe.ingredients.length} ingredients added to your list',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => GoRouter.of(context).go('/shopping/$listId'),
            ),
          ),
        );
      },
    );
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
      if (!mounted) return;
      result.fold(
        (f) => context.showSnackBar(f.message, isError: true),
        (_) => GoRouter.of(context).pop(),
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
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(recipe),
              SliverToBoxAdapter(
                  child: _buildContent(context, recipe, scaled,
                      originalServings, currentServings)),
            ],
          ),
          floatingActionButton: recipe.ingredients.isEmpty
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'recipe-add-to-list',
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  onPressed: _addingToList
                      ? null
                      : () => _addToShoppingList(recipe, currentServings),
                  icon: _addingToList
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colorScheme.onPrimary),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: const Text(
                    'Add to list',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: context.colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.colorScheme.onSurface),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      actions: [
        IconButton(
          tooltip: recipe.favorite ? 'Remove from favourites' : 'Favourite',
          icon: Icon(
            recipe.favorite ? Icons.star : Icons.star_border,
            color: context.colorScheme.secondary,
          ),
          onPressed: () => _toggleFavorite(recipe),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: context.colorScheme.onSurface),
          color: context.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (v) {
            if (v == 'edit') {
              GoRouter.of(context)
                  .push('/recipes/${recipe.id}/edit', extra: recipe);
            }
            if (v == 'delete') _confirmDelete(recipe);
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined,
                    size: 18, color: ctx.colorScheme.onSurface),
                const SizedBox(width: 10),
                const Text('Edit', style: TextStyle(fontFamily: 'Poppins')),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline,
                    size: 18, color: ctx.colorScheme.error),
                const SizedBox(width: 10),
                Text('Delete',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: ctx.colorScheme.error)),
              ]),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            RecipeImage(recipe: recipe, cacheSize: 800, iconSize: 72),
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

  Widget _buildContent(BuildContext context, Recipe recipe, Recipe scaled,
      int originalServings, int currentServings) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: context.colorScheme.onSurface,
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
                  const Icon(Icons.star, color: AppColors.rating, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recipe.rating!.toStringAsFixed(1),
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurfaceVariant),
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
                if (recipe.category != null && recipe.category!.isNotEmpty)
                  _badge(Icons.local_offer_outlined, recipe.category!),
                if (recipe.totalTime > 0)
                  _badge(Icons.access_time, '${recipe.totalTime} min'),
                if (recipe.servings != null)
                  _badge(
                      Icons.restaurant_outlined, '$currentServings servings'),
                for (final tag in recipe.tags.take(3))
                  _badge(Icons.tag, tag),
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
                icon: Icon(Icons.refresh,
                    size: 16, color: context.colorScheme.onSurfaceVariant),
                label: Text(
                  'Reset to $originalServings',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: context.colorScheme.primary,
            unselectedLabelColor: context.colorScheme.onSurfaceVariant,
            indicatorColor: context.colorScheme.primary,
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
    final primary = context.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: primary),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_outlined, size: 14, color: primary),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _decrementServings(current, original),
            child: Icon(Icons.remove, size: 18, color: primary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$current',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface),
            ),
          ),
          GestureDetector(
            onTap: () => _incrementServings(current),
            child: Icon(Icons.add, size: 18, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, {int maxChars = 24}) {
    final text =
        label.length > maxChars ? '${label.substring(0, maxChars)}…' : label;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe scaled) {
    final ingredients = scaled.ingredients;
    if (ingredients.isEmpty) {
      return Center(
        child: Text(
          'No ingredients added yet.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 96),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (_, i) {
        final ing = ingredients[i];
        final showNote = ing.note != null && ing.quantity != null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                ing.productId != null ? Icons.circle : Icons.circle_outlined,
                size: 8,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ing.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (showNote)
                      Text(
                        ing.note!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                ing.quantityLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontStyle:
                      ing.isOptional ? FontStyle.italic : FontStyle.normal,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
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
      return Center(
        child: Text(
          'No instructions added yet.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 96),
      itemCount: steps.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
      return Center(
        child: Text(
          'No notes added yet.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 96),
      child: Text(
        desc,
        style: TextStyle(
            fontFamily: 'Poppins',
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.6),
      ),
    );
  }
}
