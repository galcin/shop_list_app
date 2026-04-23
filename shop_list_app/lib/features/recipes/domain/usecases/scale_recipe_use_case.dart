import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

/// Returns a scaled copy of [recipe] for [newServings].
/// This is a pure/synchronous use case — no DB interaction.
class ScaleRecipeUseCase {
  const ScaleRecipeUseCase();

  Recipe call(Recipe recipe, int newServings) =>
      recipe.scaleServings(newServings);
}
