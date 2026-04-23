import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/shared/widgets/feedback/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';

enum _RecipeFilter { all, favorites, recent }

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
        return recipes.where((r) => r.favorite == true).toList();
      case _RecipeFilter.recent:
        // Recent = last 10 by id (descending)
        final sorted = [...recipes]..sort((a, b) => (b.id ?? 0) - (a.id ?? 0));
        return sorted.take(10).toList();
      case _RecipeFilter.all:
        return recipes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/recipes/new'),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchExpanded) _buildSearchBar(),
          _buildFilterChips(),
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
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) => _RecipeCard(
                    recipe: visible[i],
                    onTap: () => context.push('/recipes/${visible[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'Recipes',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            _searchExpanded ? Icons.search_off : Icons.search,
            color: AppColors.textPrimary,
          ),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(
            fontFamily: 'Poppins', color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search recipes…',
          hintStyle: const TextStyle(
              fontFamily: 'Poppins', color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(recipeSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
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

  Widget _buildFilterChips() {
    const chips = [
      (_RecipeFilter.all, 'All'),
      (_RecipeFilter.favorites, '⭐ Faves'),
      (_RecipeFilter.recent, '🕐 Recent'),
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
                  color: active ? AppColors.onPrimary : AppColors.textBody,
                  fontSize: 13,
                ),
              ),
              selected: active,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
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

// ── Recipe Grid Card ──────────────────────────────────────────────────────────

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or fallback colour.
            recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                ? Image.network(recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackBg())
                : _fallbackBg(),
            // Gradient overlay.
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
            // Text overlay at the bottom.
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.name ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (recipe.rating != null) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          recipe.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (recipe.totalTime > 0) ...[
                        const Icon(Icons.access_time,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.totalTime}m',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBg() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.restaurant_menu,
            color: AppColors.textSecondary, size: 40),
      ),
    );
  }
}
