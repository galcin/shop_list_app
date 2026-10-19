# Seed data pipeline

The app ships its recipe catalogue inside the APK as JSON under `assets/data/`
and copies it into the local SQLite database once per **seed version**
(`SeedService`, `lib/core/database/seeder/`). Nothing is fetched from the
network.

| File | Purpose |
| --- | --- |
| `assets/data/seed_manifest.json` | `version` the app compares against `app_meta.seed_version`; counts for reference |
| `assets/data/product_categories.json` | Category names, emoji, colour, optional image |
| `assets/data/products.json` | Product catalogue: canonical `name`, `category`, default `unit`, `emoji`/`image`, `aliases` |
| `assets/data/recipes.json` | Recipes whose ingredients reference products **by name or alias** |

## Workflow

1. Edit the JSON files (or drop agent-written batch files in `tool/seed/batches/`
   and run `dart run tool/seed/merge_batches.dart`).
2. `dart run tool/seed/validate_seed.dart` — fails on unknown categories,
   unresolved ingredient products, unknown units, duplicates and missing images.
3. `dart run tool/seed/validate_seed.dart --write-manifest --bump-version` — bump the
   seed version so installed apps re-apply the data on next launch.

Rules the seeder follows at runtime:

* Built-in rows are matched by category/product **name** and recipe **`key`**, never by id.
* Only rows still flagged `is_built_in` are updated; anything the user created or
  edited is left alone.
* The first run on a database created before seed versions existed adopts rows
  that match by name, so old installs are upgraded rather than duplicated.

## Recipe schema

```json
{
  "key": "chicken-soup",
  "name": "Chicken Soup",
  "category": "Soups",
  "description": "One sentence, under 120 characters.",
  "instructions": ["Step one.", "Step two."],
  "prepTime": 15,
  "cookTime": 45,
  "servings": 4,
  "tags": ["comfort-food", "romanian"],
  "imageUrl": "assets/images/recipes/chicken-soup.jpg",
  "ingredients": [
    { "product": "Whole Chicken", "name": "Chicken", "quantity": 500, "unit": "g" },
    { "product": "Carrots", "quantity": 2, "unit": "pcs" },
    { "product": "Salt", "note": "to taste" }
  ]
}
```

* `product` must match a catalogue `name` or alias (case-insensitive, plural tolerant).
* `name` is an optional display override, e.g. `"Garlic (whole head)"`.
* Omit `quantity` for unmeasured lines and put the wording in `note`.
* `unit` is one of: `pcs g kg ml l tsp tbsp cup clove slice bunch sprig stalk leaf head pinch handful can pack jar bottle sheet`.
* `imageUrl` is optional. Recipes without one get a category-coloured placeholder in the app;
  `tool/generate_recipe_image_ai.dart` can fill in real photos later.

Recipe categories in use: Breakfast, Soups, Salads, Main Courses, Pasta & Rice,
Side Dishes, Desserts, Snacks & Appetizers, Sauces & Dips.

Tags vocabulary: quick, vegetarian, vegan, gluten-free, dairy-free, kid-friendly,
comfort-food, healthy, budget, romanian, italian, asian, mediterranean, mexican,
french, american, middle-eastern, spicy, one-pot, meal-prep, holiday, summer,
winter, baked, grilled, no-cook, high-protein, low-carb.

## Batch files (`tool/seed/batches/*.json`)

```json
{
  "category": "Soups",
  "recipes": [ ...recipe objects as above... ],
  "newProducts": [
    { "name": "Sorrel", "category": "Vegetables", "unit": "bunch", "emoji": "🌿", "aliases": ["macris"] }
  ]
}
```

`merge_batches.dart` appends recipes (skipping duplicate keys/names) and new
products (skipping names/aliases already in the catalogue), then you run the
validator.
