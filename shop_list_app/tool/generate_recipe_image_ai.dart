// ignore_for_file: avoid_print
//
// Recipe AI image generator.
//
// Unlike tool/generate_recipe_image.dart (which draws a deterministic
// placeholder card), this script requests an actual AI-generated food photo
// for a recipe from Pollinations.ai (https://pollinations.ai) — a free,
// no-API-key-required text-to-image HTTP endpoint — then compresses the
// result to fit the project's 50KB image budget before saving it to disk.
//
// Requires internet access. If the request fails (no network, service
// down, etc.) the script reports the error and does not write a file.
//
// Run from the project root:
//
//   dart run tool/generate_recipe_image_ai.dart --name "Egg Omelet" --category "Breakfast" --ingredients "Eggs,Butter,Salt,Black Pepper"
//   dart run tool/generate_recipe_image_ai.dart --all --dir assets/images/recipes_ai --no-json
//
// Use --help for full usage details.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Hard size budget every generated recipe image must respect.
const int _maxBytes = 50 * 1024;

const int _requestSize = 768;

const String _recipesJsonPath = 'assets/data/recipes.json';
const String _imagesDir = 'assets/images/recipes_ai';

Future<void> main(List<String> arguments) async {
  final args = _Args.parse(arguments);

  if (args.showHelp) {
    _printUsage();
    return;
  }

  if (args.processAll) {
    await _processAllRecipes(
      force: args.force,
      dryRun: args.dryRun,
      imagesDir: args.dir ?? _imagesDir,
      updateJson: !args.noJson,
    );
    return;
  }

  if (args.name == null || args.name!.trim().isEmpty) {
    stderr.writeln('Error: --name is required unless --all is used.\n');
    _printUsage();
    exitCode = 64;
    return;
  }

  final name = args.name!;
  final slug = _slugify(name);
  final outPath = args.out ?? '${args.dir ?? _imagesDir}/$slug.jpg';

  try {
    final bytes = await _generateRecipeImageBytes(
      name: name,
      category: args.category ?? '',
      ingredients: args.ingredients,
    );

    final file = File(outPath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);

    stdout.writeln(
      'Generated ${file.path} (${_formatBytes(bytes.length)}, budget ${_formatBytes(_maxBytes)})',
    );
  } catch (e) {
    stderr.writeln('Error generating image for "$name": $e');
    exitCode = 1;
  }
}

/// Scans [_recipesJsonPath] and generates an AI image for every recipe
/// whose output file doesn't exist yet under [imagesDir] (or for all
/// recipes when [force] is true). When [updateJson] is true, recipes
/// without an `imageUrl` get one assigned automatically and the JSON file
/// is rewritten.
Future<void> _processAllRecipes({
  required bool force,
  required bool dryRun,
  String imagesDir = _imagesDir,
  bool updateJson = true,
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

  var changedJson = false;
  var generatedCount = 0;
  var skippedCount = 0;
  var failedCount = 0;
  var isFirstRequest = true;

  for (final entry in decoded) {
    if (entry is! Map) continue;
    final map = entry.cast<String, dynamic>();
    final name = map['name'] as String?;
    if (name == null || name.trim().isEmpty) continue;

    final category = (map['category'] as String?) ?? '';
    final ingredients = _ingredientNamesFrom(map['ingredients']);
    final slug = _slugify(name);

    final targetImageUrl = '$imagesDir/$slug.jpg';
    var imageUrl = (map['imageUrl'] as String?)?.trim();
    if (updateJson) {
      if (imageUrl == null || imageUrl.isEmpty) {
        imageUrl = targetImageUrl;
        map['imageUrl'] = imageUrl;
        changedJson = true;
      }
    } else {
      imageUrl = targetImageUrl;
    }

    final imageFile = File(imageUrl);
    if (imageFile.existsSync() && !force) {
      skippedCount++;
      continue;
    }

    if (dryRun) {
      stdout.writeln('[dry-run] would generate $imageUrl for "$name"');
      generatedCount++;
      continue;
    }

    // Anonymous Pollinations.ai requests are rate-limited to roughly one
    // per 15 seconds; space requests out to avoid tripping that limit.
    if (!isFirstRequest) {
      await Future<void>.delayed(const Duration(seconds: 16));
    }
    isFirstRequest = false;

    try {
      final bytes = await _generateRecipeImageBytes(
        name: name,
        category: category,
        ingredients: ingredients,
      );
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(bytes);
      generatedCount++;
      stdout.writeln(
        'Generated $imageUrl (${_formatBytes(bytes.length)}) for "$name"',
      );
    } catch (e) {
      failedCount++;
      stderr.writeln('Failed to generate image for "$name": $e');
    }
  }

  if (updateJson && changedJson && !dryRun) {
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString('${encoder.convert(decoded)}\n');
    stdout.writeln('Updated $_recipesJsonPath with new imageUrl entries.');
  }

  stdout.writeln(
    'Done. Generated: $generatedCount, skipped (already existed): '
    '$skippedCount, failed: $failedCount.',
  );
}

List<String> _ingredientNamesFrom(dynamic ingredients) {
  if (ingredients is! List) return const [];
  return ingredients
      .whereType<Map>()
      .map((e) => e['name']?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Requests an AI-generated food photo for [name]/[category]/[ingredients]
/// from Pollinations.ai and compresses it to fit [_maxBytes].
Future<List<int>> _generateRecipeImageBytes({
  required String name,
  required String category,
  required List<String> ingredients,
}) async {
  final prompt = _buildPrompt(
    name: name,
    category: category,
    ingredients: ingredients,
  );
  final rawBytes = await _fetchImage(prompt: prompt, seed: _hash(name).abs());

  final image = img.decodeImage(Uint8List.fromList(rawBytes));
  if (image == null) {
    throw StateError('Could not decode image returned by the AI service.');
  }

  return _compressToBudget(image);
}

/// Builds a food-photography style prompt describing the dish.
String _buildPrompt({
  required String name,
  required String category,
  required List<String> ingredients,
}) {
  final buffer = StringBuffer(
    'professional food photography of $name, appetizing plated dish',
  );
  if (category.trim().isNotEmpty) {
    buffer.write(', ${category.trim()} category');
  }
  if (ingredients.isNotEmpty) {
    buffer.write(', made with ${ingredients.take(6).join(', ')}');
  }
  buffer.write(
    ', on a rustic table, natural lighting, shallow depth of field, '
    'high detail, 4k, no text, no watermark',
  );
  return buffer.toString();
}

/// Fetches an image from the Pollinations.ai text-to-image endpoint.
/// No API key is required. Throws on network/HTTP errors.
Future<List<int>> _fetchImage({
  required String prompt,
  required int seed,
}) async {
  final encodedPrompt = Uri.encodeComponent(prompt);
  // Note: `nologo=true` is intentionally omitted — Pollinations.ai now
  // requires a registered/paid account for that flag and responds with
  // HTTP 402 (Payment Required) for anonymous requests that include it.
  final uri = Uri.parse(
    'https://image.pollinations.ai/prompt/$encodedPrompt'
    '?width=$_requestSize&height=$_requestSize&seed=$seed',
  );

  const maxAttempts = 4;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
            const Duration(seconds: 90),
          );

      if (response.statusCode != 200) {
        // Drain the response body so the connection can be reused/closed.
        await response.drain<void>();
        final retryable = response.statusCode == 402 ||
            response.statusCode == 429 ||
            response.statusCode >= 500;
        if (retryable && attempt < maxAttempts) {
          final backoff = Duration(seconds: 5 * attempt);
          stdout.writeln(
            '  (status ${response.statusCode}, retrying in '
            '${backoff.inSeconds}s, attempt $attempt/$maxAttempts)',
          );
          await Future<void>.delayed(backoff);
          continue;
        }
        throw HttpException(
          'Request failed with status ${response.statusCode}',
          uri: uri,
        );
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      if (bytes.isEmpty) {
        throw StateError('Received an empty response body.');
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }

  // Unreachable: the loop above always returns or throws.
  throw StateError('Failed to fetch image after $maxAttempts attempts.');
}

/// Encodes [image] as JPEG, stepping down quality and (if that's not
/// enough) image dimensions until the result is at or under [maxBytes].
List<int> _compressToBudget(img.Image image, {int maxBytes = _maxBytes}) {
  const qualities = [92, 85, 78, 70, 62, 54, 46, 38, 30, 22, 15];
  var current = image;

  for (var pass = 0; pass < 5; pass++) {
    for (final quality in qualities) {
      final bytes = img.encodeJpg(current, quality: quality);
      if (bytes.length <= maxBytes) {
        return bytes;
      }
    }

    final newWidth = (current.width * 0.8).round();
    final newHeight = (current.height * 0.8).round();
    if (newWidth < 120 || newHeight < 90) break;
    current = img.copyResize(current, width: newWidth, height: newHeight);
  }

  // Last resort: whatever we could produce at the smallest size/quality.
  return img.encodeJpg(current, quality: 12);
}

/// Simple string hash (djb2-like) used to deterministically seed the
/// image request so re-runs for the same recipe tend to produce a
/// consistent-ish result.
int _hash(String s) {
  var h = 0;
  for (final codeUnit in s.codeUnits) {
    h = 0x1fffffff & (h + codeUnit);
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    h ^= (h >> 6);
  }
  h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
  h ^= (h >> 11);
  h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
  return h;
}

/// Converts a recipe name into the lowercase, hyphen-separated filename
/// convention used throughout `assets/images/recipes/` (e.g. "Egg Omelet"
/// -> "egg-omelet").
String _slugify(String input) {
  final lower = input.toLowerCase().trim();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

void _printUsage() {
  stdout.writeln('''
Recipe AI image generator
--------------------------
Requests a real AI-generated food photo for a recipe from Pollinations.ai
(free, no API key needed) and compresses it to fit the project's 50KB
image budget. Requires internet access. Run from the project root.

Usage:
  dart run tool/generate_recipe_image_ai.dart --all [--dir path] [--force] [--dry-run] [--no-json]
      Scan assets/data/recipes.json; generate an AI image for every recipe
      whose output file is missing (or all of them with --force).

  dart run tool/generate_recipe_image_ai.dart --name "Recipe Name" [--category "Category"] [--ingredients "a,b,c"] [--dir path] [--out path]
      Generate a single AI image for the given recipe. Defaults to
      assets/images/recipes_ai/<slug>.jpg if --out/--dir are omitted.

Options:
  --all           Process every recipe in assets/data/recipes.json.
  --force         Regenerate images even if a file already exists (with --all).
  --dry-run       Show what would be generated without writing files (with --all).
  --dir           Output directory for generated images (default: assets/images/recipes_ai).
  --no-json       With --all, don't read/write imageUrl in recipes.json; resolve
                  every recipe's output path against --dir instead.
  --name          Recipe name (required unless --all is given).
  --category      Recipe category, used to steer the prompt.
  --ingredients   Comma-separated ingredient names, included in the prompt.
  --out           Output file path (single-recipe mode only).
  -h, --help      Show this help message.
''');
}

class _Args {
  _Args({
    this.name,
    this.category,
    this.ingredients = const [],
    this.out,
    this.dir,
    this.processAll = false,
    this.force = false,
    this.dryRun = false,
    this.noJson = false,
    this.showHelp = false,
  });

  final String? name;
  final String? category;
  final List<String> ingredients;
  final String? out;
  final String? dir;
  final bool processAll;
  final bool force;
  final bool dryRun;
  final bool noJson;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    String? name;
    String? category;
    var ingredients = const <String>[];
    String? out;
    String? dir;
    var processAll = false;
    var force = false;
    var dryRun = false;
    var noJson = false;
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
      } else if (arg == '--out' && i + 1 < arguments.length) {
        out = arguments[++i];
      } else if (arg == '--dir' && i + 1 < arguments.length) {
        dir = arguments[++i];
      } else if (arg == '--all') {
        processAll = true;
      } else if (arg == '--force') {
        force = true;
      } else if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--no-json') {
        noJson = true;
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
      out: out,
      dir: dir,
      processAll: processAll,
      force: force,
      dryRun: dryRun,
      noJson: noJson,
      showHelp: showHelp,
    );
  }
}
