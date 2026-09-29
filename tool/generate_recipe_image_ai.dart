// ignore_for_file: avoid_print
//
// Recipe AI image generator using Together AI.
//
// This dev-tool script generates realistic, appetizing recipe images using
// Together AI's image generation models. It reads recipes from
// assets/data/recipes.json and generates high-quality food photography-style
// images based on recipe names and ingredients.
//
// Setup:
//   1. Get a Together AI API key from https://api.together.ai
//   2. Set it as an environment variable: export TOGETHER_API_KEY="your-key-here"
//   3. Run: dart run tool/generate_recipe_image_ai.dart --all [--dir output-dir]
//
// Usage:
//   dart run tool/generate_recipe_image_ai.dart --all
//   dart run tool/generate_recipe_image_ai.dart --all --dir assets/images/recipes_ai
//   dart run tool/generate_recipe_image_ai.dart --name "Egg Omelet" --category "Breakfast" --ingredients "Eggs,Butter,Salt,Black Pepper"
//   dart run tool/generate_recipe_image_ai.dart --name "Chicken Soup" --dir assets/images/recipes_ai
//
// Use --help for full usage details.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String _recipesJsonPath = 'assets/data/recipes.json';
const String _defaultOutputDir = 'assets/images/recipes_ai';

// Together AI API endpoint and model
const String _togetherApiUrl = 'https://api.together.xyz/v1/images/generations';
const String _togetherModel = 'black-forest-labs/FLUX.1-pro';

Future<void> main(List<String> arguments) async {
  final args = _Args.parse(arguments);

  if (args.showHelp) {
    _printUsage();
    return;
  }

  final apiKey = Platform.environment['TOGETHER_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln(
      'Error: TOGETHER_API_KEY environment variable not set.\n'
      'Get your API key from https://api.together.ai\n'
      'Then run: export TOGETHER_API_KEY="your-key-here"',
    );
    exitCode = 1;
    return;
  }

  if (args.processAll) {
    await _processAllRecipes(
      apiKey: apiKey,
      outputDir: args.dir ?? _defaultOutputDir,
      dryRun: args.dryRun,
    );
    return;
  }

  if (args.name == null || args.name!.trim().isEmpty) {
    stderr.writeln('Error: --name is required unless --all is used.\n');
    _printUsage();
    exitCode = 64;
    return;
  }

  await _generateSingleRecipe(
    apiKey: apiKey,
    name: args.name!,
    category: args.category ?? '',
    ingredients: args.ingredients,
    outputDir: args.dir ?? _defaultOutputDir,
    dryRun: args.dryRun,
  );
}

Future<void> _processAllRecipes({
  required String apiKey,
  required String outputDir,
  required bool dryRun,
}) async {
  final jsonFile = File(_recipesJsonPath);
  if (!jsonFile.existsSync()) {
    stderr.writeln(
      'Error: could not find $_recipesJsonPath '
      '(run this script from the project root).',
    );
    exitCode = 66;
    return;
  }

  final raw = await jsonFile.readAsString();
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    stderr.writeln(
      'Error: expected $_recipesJsonPath to contain a JSON array of recipes.',
    );
    exitCode = 65;
    return;
  }

  var generatedCount = 0;
  var failedCount = 0;
  var skippedCount = 0;

  stdout.writeln('Processing ${decoded.length} recipes...\n');

  for (final entry in decoded) {
    if (entry is! Map) continue;
    final map = entry.cast<String, dynamic>();
    final name = map['name'] as String?;
    if (name == null || name.trim().isEmpty) continue;

    final category = (map['category'] as String?) ?? '';
    final ingredients = _ingredientNamesFrom(map['ingredients']);
    final slug = _slugify(name);
    final outputPath = '$outputDir/$slug.jpg';
    final outputFile = File(outputPath);

    if (outputFile.existsSync()) {
      stdout.writeln('⊘ Skipped $name (file already exists)');
      skippedCount++;
      continue;
    }

    if (dryRun) {
      stdout.writeln('[dry-run] would generate $outputPath for "$name"');
      generatedCount++;
      continue;
    }

    try {
      await _generateSingleRecipe(
        apiKey: apiKey,
        name: name,
        category: category,
        ingredients: ingredients,
        outputDir: outputDir,
        dryRun: false,
      );
      generatedCount++;
    } catch (e) {
      stderr.writeln('✗ Failed to generate image for "$name": $e');
      failedCount++;
    }

    // Add a small delay between requests to respect rate limits
    await Future.delayed(Duration(milliseconds: 500));
  }

  stdout.writeln('\n---');
  stdout.writeln('Done. Generated: $generatedCount, skipped: $skippedCount, failed: $failedCount.');
}

Future<void> _generateSingleRecipe({
  required String apiKey,
  required String name,
  required String category,
  required List<String> ingredients,
  required String outputDir,
  required bool dryRun,
}) async {
  final slug = _slugify(name);
  final outputPath = '$outputDir/$slug.jpg';

  final prompt = _buildPrompt(name, category, ingredients);

  if (dryRun) {
    stdout.writeln('[dry-run] would generate "$name" with prompt:\n  $prompt');
    return;
  }

  stdout.writeln('⟳ Generating image for "$name"...');

  try {
    final imageBytes = await _fetchImageFromTogetherAI(apiKey, prompt);

    final outputDir_ = Directory(outputDir);
    if (!outputDir_.existsSync()) {
      await outputDir_.create(recursive: true);
    }

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(imageBytes);

    stdout.writeln(
      '✓ Generated $outputPath (${_formatBytes(imageBytes.length)})',
    );
  } catch (e) {
    stderr.writeln('✗ Failed to generate image for "$name": $e');
    rethrow;
  }
}

Future<List<int>> _fetchImageFromTogetherAI(
  String apiKey,
  String prompt,
) async {
  final response = await http.post(
    Uri.parse(_togetherApiUrl),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': _togetherModel,
      'prompt': prompt,
      'width': 1024,
      'height': 1024,
      'steps': 20,
      'n': 1,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Together AI API error ${response.statusCode}: ${response.body}',
    );
  }

  final data = jsonDecode(response.body);
  if (data is! Map || data['data'] is! List || data['data'].isEmpty) {
    throw Exception('Unexpected API response format: $data');
  }

  final imageUrl = data['data'][0]['url'] as String?;
  if (imageUrl == null) {
    throw Exception('No image URL in response: $data');
  }

  // Download the image
  final imageResponse = await http.get(Uri.parse(imageUrl));
  if (imageResponse.statusCode != 200) {
    throw Exception('Failed to download image: ${imageResponse.statusCode}');
  }

  return imageResponse.bodyBytes;
}

String _buildPrompt(String name, String category, List<String> ingredients) {
  final ingredientList =
      ingredients.isNotEmpty ? ingredients.join(', ') : 'delicious ingredients';

  return '''
Professional food photography of a beautifully plated $name dish.
Category: $category
Ingredients: $ingredientList

The image should show:
- A finished, appetizing presentation of the dish
- Professional lighting and composition
- High-quality, detailed food photography style
- Clean, modern plating
- Shallow depth of field with blurred background
- Vibrant, natural colors
- 4K food photography quality

Style: Professional culinary photography, appetizing, high-end restaurant quality
''';
}

List<String> _ingredientNamesFrom(dynamic ingredients) {
  if (ingredients is! List) return const [];
  return ingredients
      .whereType<Map>()
      .map((e) => e['name']?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

String _slugify(String input) {
  final lower = input.toLowerCase().trim();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

void _printUsage() {
  stdout.writeln('''
Together AI Recipe Image Generator
-----------------------------------
Generates realistic food photography-style images for recipes using Together AI.
Requires TOGETHER_API_KEY environment variable to be set.

Setup:
  1. Get an API key: https://api.together.ai
  2. Set environment: export TOGETHER_API_KEY="your-key"
  3. Optionally install http: flutter pub add http

Usage:
  dart run tool/generate_recipe_image_ai.dart --all [--dir OUTPUT_DIR]
      Process all recipes in assets/data/recipes.json
      Default output: assets/images/recipes_ai/

  dart run tool/generate_recipe_image_ai.dart --name "Recipe Name" [options]
      Generate a single recipe image

Options:
  --all               Process every recipe in assets/data/recipes.json.
  --name TEXT         Recipe name (required unless --all is given).
  --category TEXT     Recipe category (used in the prompt).
  --ingredients TEXT  Comma-separated ingredient names (e.g., "Eggs,Butter,Salt").
  --dir PATH          Output directory for generated images.
                      Default: assets/images/recipes_ai/
  --dry-run           Show what would be generated without calling the API.
  -h, --help          Show this help message.

Environment:
  TOGETHER_API_KEY    Your Together AI API key (required).

Example:
  export TOGETHER_API_KEY="sk-xxxx..."
  dart run tool/generate_recipe_image_ai.dart --all --dir assets/images/recipes_ai
  dart run tool/generate_recipe_image_ai.dart --name "Pasta Carbonara" --category "Main Courses"

Cost estimate:
  Each image generation costs credits on Together AI.
  Check your account dashboard for current pricing.
  Use --dry-run to preview without cost.
''');
}

class _Args {
  _Args({
    this.name,
    this.category,
    this.ingredients = const [],
    this.dir,
    this.processAll = false,
    this.dryRun = false,
    this.showHelp = false,
  });

  final String? name;
  final String? category;
  final List<String> ingredients;
  final String? dir;
  final bool processAll;
  final bool dryRun;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    String? name;
    String? category;
    var ingredients = const <String>[];
    String? dir;
    var processAll = false;
    var dryRun = false;
    var showHelp = false;

    var i = 0;
    while (i < arguments.length) {
      final arg = arguments[i];
      if (arg == '--name' && i + 1 < arguments.length) {
        name = arguments[++i];
      } else if (arg == '--category' && i + 1 < arguments.length) {
        category = arguments[++i];
      } else if (arg == '--ingredients' && i + 1 < arguments.length) {
        ingredients = arguments[++i]
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (arg == '--dir' && i + 1 < arguments.length) {
        dir = arguments[++i];
      } else if (arg == '--all') {
        processAll = true;
      } else if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else {
        stderr.writeln('Warning: unrecognized argument "$arg" ignored.');
      }
      i++;
    }

    return _Args(
      name: name,
      category: category,
      ingredients: ingredients,
      dir: dir,
      processAll: processAll,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}
