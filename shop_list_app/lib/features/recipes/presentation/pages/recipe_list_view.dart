import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/feedback/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/loading_state_widget.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

enum _RecipeFilter { all, favorites, recent, quickPrep }

const List<String> _categories = [
  'All Categories',
  'Breakfast',
  'Soups',
  'Salads',
  'Main Courses',
  'Side Dishes',
];

class RecipeListView extends ConsumerStatefulWidget {
  const RecipeListView({super.key});

  @override
  ConsumerState<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends ConsumerState<RecipeListView> {
  bool _searchExpanded = false;
  _RecipeFilter _filter = _RecipeFilter.all;
  String _selectedCategory = 'All Categories';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Backfill/repair recipe categories on first build via the use case
    // (never touch the database directly from presentation).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ref.read(fixRecipeCategoriesUseCaseProvider).call();
      result.fold(
        (failure) => AppLogger.instance.error(
            '[RecipeListView] Category backfill failed: ${failure.message}'),
        (_) {
          // Refresh the list after a successful backfill.
          if (mounted) {
            ref.invalidate(recipeListProvider);
          }
        },
      );
    });
  }

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
    // First apply the category filter
    var filtered = recipes;
    if (_selectedCategory != 'All Categories') {
      filtered = recipes.where((r) => r.category == _selectedCategory).toList();
    }

    // Then apply the quick filter
    switch (_filter) {
      case _RecipeFilter.favorites:
        return filtered.where((r) => r.favorite == true).toList();
      case _RecipeFilter.recent:
        // Recent = last 10 by id (descending)
        final sorted = [...filtered]..sort((a, b) => (b.id ?? 0) - (a.id ?? 0));
        return sorted.take(10).toList();
      case _RecipeFilter.quickPrep:
        // Quick prep = recipes with prep time <= 20 minutes
        return filtered.where((r) => (r.prepTime ?? 0) <= 20).toList();
      case _RecipeFilter.all:
        return filtered;
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
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      title: Text(
        'Recipes',
        style: TextStyle(
          color: context.colorScheme.onSurface,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      centerTitle: false,
      actions: [
        // Temporary: Fix categories button
        IconButton(
          icon: const Icon(Icons.build, color: Colors.orange),
          tooltip: 'Fix Categories',
          onPressed: () async {
            final result =
                await ref.read(fixRecipeCategoriesUseCaseProvider).call();
            if (!mounted) return;
            result.fold(
              (failure) {
                AppLogger.instance.error(
                    '[RecipeListView] Manual category fix failed: ${failure.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to update categories: ${failure.message}')),
                );
              },
              (_) {
                ref.invalidate(recipeListProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Categories updated.')),
                );
              },
            );
          },
        ),
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
          hintText: 'Search recipes…',
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
            value: _selectedCategory,
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
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
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
        child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
            ? _buildImage(recipe.imageUrl!, context)
            : _fallbackBg(context),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 58, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recipe name — slightly bigger than the description.
            Text(
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
                if (recipe.rating != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    recipe.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl, BuildContext context) {
    // Debug: Print the image URL to console
    debugPrint('Loading image from: $imageUrl');

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        cacheHeight: 400, // Limit decoded image height to save memory
        cacheWidth: 400, // Limit decoded image width to save memory
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $imageUrl - $error');
          return _fallbackBg(context);
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading network image: $imageUrl - $error');
          return _fallbackBg(context);
        },
      );
    }
  }

  Widget _fallbackBg(BuildContext context) {
    return Container(
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.restaurant_menu,
            color: context.colorScheme.onSurfaceVariant, size: 36),
      ),
    );
  }
}
