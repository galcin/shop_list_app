import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/features/recipes/presentation/widgets/recipe_image.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/feedback/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

enum _RecipeFilter { all, favorites, recent, quickPrep }

const String _kAllCategories = 'All Categories';

class RecipeListView extends ConsumerStatefulWidget {
  const RecipeListView({super.key});

  @override
  ConsumerState<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends ConsumerState<RecipeListView> {
  bool _searchExpanded = false;
  _RecipeFilter _filter = _RecipeFilter.all;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _searchController.clear();
        ref.read(recipeSearchQueryProvider.notifier).state = '';
      }
    });
  }

  List<Recipe> _applyFilter(List<Recipe> recipes) {
    switch (_filter) {
      case _RecipeFilter.favorites:
        return recipes.where((r) => r.favorite).toList();
      case _RecipeFilter.recent:
        // Recent = last 10 by id (descending)
        final sorted = [...recipes]..sort((a, b) => (b.id ?? 0) - (a.id ?? 0));
        return sorted.take(10).toList();
      case _RecipeFilter.quickPrep:
        // Quick prep = recipes with total time <= 20 minutes
        return recipes
            .where((r) => r.totalTime > 0 && r.totalTime <= 20)
            .toList();
      case _RecipeFilter.all:
        return recipes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recipes-fab',
        backgroundColor: context.colorScheme.primary,
        onPressed: () => GoRouter.of(context).push('/recipes/new'),
        child: Icon(Icons.add, color: context.colorScheme.onPrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchExpanded) _buildSearchBar(context),
          _buildCategoryDropdown(context),
          _buildFilterChips(context),
          Expanded(
            child: filteredAsync.when(
              loading: () => const LoadingStateWidget(),
              error: (e, st) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(recipeListProvider),
              ),
              data: (recipes) {
                final visible = _applyFilter(recipes);
                if (visible.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.menu_book_outlined,
                    title: 'No recipes found',
                    subtitle: recipes.isEmpty
                        ? 'Tap + to add your first recipe'
                        : 'Try different keywords or clear the filter',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) => _RecipeCard(
                    recipe: visible[i],
                    onTap: () =>
                        GoRouter.of(ctx).push('/recipes/${visible[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final count = ref.watch(recipeListProvider).asData?.value.length;
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Recipes',
            style: TextStyle(
              color: context.colorScheme.onSurface,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$count',
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            _searchExpanded ? Icons.search_off : Icons.search,
            color: context.colorScheme.onSurface,
          ),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(
            fontFamily: 'Poppins', color: context.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search recipes or ingredients…',
          hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: context.colorScheme.onSurfaceVariant),
          prefixIcon:
              Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: context.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(recipeSearchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: context.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onChanged: (v) {
          ref.read(recipeSearchQueryProvider.notifier).state = v;
          setState(() {}); // Refresh clear button visibility.
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final categories =
        ref.watch(recipeCategoriesProvider).asData?.value ?? const <String>[];
    final selected = ref.watch(recipeCategoryFilterProvider);
    final items = [_kAllCategories, ...categories];
    final value = selected != null && categories.contains(selected)
        ? selected
        : _kAllCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down,
                color: context.colorScheme.onSurface),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: context.colorScheme.onSurface,
              fontSize: 14,
            ),
            dropdownColor: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            items: items
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (newValue) {
              ref.read(recipeCategoryFilterProvider.notifier).state =
                  newValue == null || newValue == _kAllCategories
                      ? null
                      : newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    const chips = [
      (_RecipeFilter.all, 'All'),
      (_RecipeFilter.favorites, '⭐ Faves'),
      (_RecipeFilter.recent, '🕐 Recent'),
      (_RecipeFilter.quickPrep, '⚡ Quick (<20m)'),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: chips.map((entry) {
          final active = _filter == entry.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                entry.$2,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: active
                      ? context.colorScheme.onPrimary
                      : context.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              selected: active,
              selectedColor: context.colorScheme.primary,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              shape: const StadiumBorder(),
              side: BorderSide.none,
              onSelected: (_) => setState(() => _filter = entry.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Recipe List Card (circle avatar + rectangle body) ─────────────────────────

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = context.colorScheme.primary;

    return AccentCircleListCard(
      accentColor: accentColor,
      onTap: onTap,
      height: 112,
      circleChild: CircleAccentAvatar(
        accentColor: accentColor,
        size: 112,
        child: RecipeImage(
          recipe: recipe,
          width: 112,
          height: 112,
          cacheSize: 400,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 58, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name ?? 'Untitled',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: context.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (recipe.favorite)
                  Icon(Icons.star,
                      size: 16, color: context.colorScheme.secondary),
              ],
            ),
            if ((recipe.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                recipe.description!,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                if (recipe.totalTime > 0) ...[
                  Icon(Icons.access_time,
                      size: 13, color: context.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    '${recipe.totalTime}m',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (recipe.servings != null) ...[
                  Icon(Icons.restaurant_outlined,
                      size: 13, color: context.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    '${recipe.servings}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (recipe.ingredients.isNotEmpty)
                  Text(
                    '${recipe.ingredients.length} ingredients',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
