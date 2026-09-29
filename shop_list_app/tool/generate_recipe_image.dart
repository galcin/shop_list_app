// ignore_for_file: avoid_print
//
// Recipe placeholder image generator.
//
// This dev-tool script is the fallback engine used by the "Recipe Image
// Agent" chat mode (see .github/chatmodes/recipe-image-agent.chatmode.md)
// whenever no AI image-generation tool is available in the current chat
// session. It creates a deterministic, lightweight placeholder JPEG for a
// recipe (colored gradient background seeded from the recipe's
// name/category, a category badge, the recipe title, and an ingredients
// preview) and guarantees the output file stays at or under 50KB by
// iteratively lowering JPEG quality and, if necessary, downscaling the
// image.
//
// Run from the project root:
//
//   dart run tool/generate_recipe_image.dart --all
//   dart run tool/generate_recipe_image.dart --name "Egg Omelet" --category "Breakfast" --ingredients "Eggs,Butter,Salt"
//
// Use --help for full usage details.
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

/// Hard size budget every generated recipe image must respect.
const int _maxBytes = 50 * 1024;

const int _defaultWidth = 640;
const int _defaultHeight = 480;

const String _recipesJsonPath = 'assets/data/recipes.json';
const String _imagesDir = 'assets/images/recipes';

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

  final bytes = _generateRecipeImageBytes(
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
}

/// Scans [_recipesJsonPath] and generates a placeholder image for every
/// recipe whose referenced image file doesn't exist on disk yet (or for all
/// recipes when [force] is true). Recipes without an `imageUrl` get one
/// assigned automatically (`assets/images/recipes/<slug>.jpg`) and the JSON
/// file is rewritten with the new values.
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
      // Not touching recipes.json — always resolve against the requested
      // output directory regardless of the existing imageUrl field.
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

    final bytes = _generateRecipeImageBytes(
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
  }

  if (updateJson && changedJson && !dryRun) {
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString('${encoder.convert(decoded)}\n');
    stdout.writeln('Updated $_recipesJsonPath with new imageUrl entries.');
  }

  stdout.writeln(
    'Done. Generated: $generatedCount, skipped (already existed): $skippedCount.',
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

/// Builds the placeholder image for [name]/[category]/[ingredients] and
/// compresses it so the encoded JPEG bytes stay within [_maxBytes].
List<int> _generateRecipeImageBytes({
  required String name,
  required String category,
  required List<String> ingredients,
}) {
  final image = _buildPlaceholderImage(
    name: name,
    category: category,
    ingredients: ingredients,
  );
  return _compressToBudget(image);
}

/// Draws a deterministic, food-card-styled placeholder: a gradient
/// background seeded by hashing the category (falling back to the name),
/// a couple of translucent decorative circles, a category badge, the
/// (wrapped) recipe title, and a short ingredients preview.
img.Image _buildPlaceholderImage({
  required String name,
  required String category,
  required List<String> ingredients,
  int width = _defaultWidth,
  int height = _defaultHeight,
}) {
  final image = img.Image(width: width, height: height);

  final seed = category.trim().isNotEmpty ? category : name;
  final hue = (_hash(seed).abs() % 360) / 360.0;

  final topRgb = <int>[0, 0, 0];
  img.hslToRgb(hue, 0.55, 0.58, topRgb);
  final bottomRgb = <int>[0, 0, 0];
  img.hslToRgb(hue, 0.60, 0.28, bottomRgb);

  for (var y = 0; y < image.height; y++) {
    final t = y / (image.height - 1);
    final r = (topRgb[0] + (bottomRgb[0] - topRgb[0]) * t).round();
    final g = (topRgb[1] + (bottomRgb[1] - topRgb[1]) * t).round();
    final b = (topRgb[2] + (bottomRgb[2] - topRgb[2]) * t).round();
    img.drawLine(
      image,
      x1: 0,
      y1: y,
      x2: image.width - 1,
      y2: y,
      color: img.ColorRgb8(r, g, b),
    );
  }

  final accentRgb = <int>[0, 0, 0];
  img.hslToRgb((hue + 0.5) % 1.0, 0.5, 0.6, accentRgb);
  final accent = img.ColorRgba8(
    accentRgb[0],
    accentRgb[1],
    accentRgb[2],
    45,
  );
  img.fillCircle(
    image,
    x: image.width - 80,
    y: 80,
    radius: 140,
    color: accent,
  );
  img.fillCircle(
    image,
    x: 50,
    y: image.height - 50,
    radius: 100,
    color: accent,
  );

  img.drawRect(
    image,
    x1: 0,
    y1: 0,
    x2: image.width - 1,
    y2: image.height - 1,
    color: img.ColorRgb8(255, 255, 255),
    thickness: 3,
  );

  if (category.trim().isNotEmpty) {
    final badgeText = category.trim().toUpperCase();
    final badgeWidth = 24 + badgeText.length * 9;
    img.fillRect(
      image,
      x1: 24,
      y1: 24,
      x2: 24 + badgeWidth,
      y2: 56,
      color: img.ColorRgba8(0, 0, 0, 100),
      radius: 10,
    );
    img.drawString(
      image,
      badgeText,
      font: img.arial14,
      x: 36,
      y: 32,
      color: img.ColorRgb8(255, 255, 255),
    );
  }

  final titleFont = name.length <= 16 ? img.arial48 : img.arial24;
  img.drawString(
    image,
    name,
    font: titleFont,
    x: 40,
    y: (image.height / 2 - 60).round(),
    color: img.ColorRgb8(255, 255, 255),
    wrap: true,
  );

  if (ingredients.isNotEmpty) {
    final preview = ingredients.take(4).join('  •  ');
    img.drawString(
      image,
      preview,
      font: img.arial14,
      x: 40,
      y: image.height - 60,
      color: img.ColorRgb8(255, 255, 255),
      wrap: true,
    );
  }

  return image;
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

/// Simple string hash (djb2-like) used to deterministically seed colors.
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
Recipe placeholder image generator
-----------------------------------
Generates a deterministic, lightweight (<=50KB) placeholder JPEG image for a
recipe and saves it under assets/images/recipes/. Run from the project root.

Usage:
  dart run tool/generate_recipe_image.dart --all [--force] [--dry-run]
      Scan assets/data/recipes.json; generate an image for every recipe whose
      imageUrl file is missing (or all of them with --force), and backfill
      the imageUrl field for recipes that don't have one yet.

  dart run tool/generate_recipe_image.dart --name "Recipe Name" [--category "Category"] [--ingredients "a,b,c"] [--out path]
      Generate a single image for the given recipe. Defaults to
      assets/images/recipes/<slug>.jpg if --out is omitted.

Options:
  --all           Process every recipe in assets/data/recipes.json.
  --force         Regenerate images even if a file already exists (with --all).
  --dry-run       Show what would be generated without writing files (with --all).
  --dir           Output directory for generated images (default: assets/images/recipes).
  --no-json       With --all, don't read/write imageUrl in recipes.json; resolve
                  every recipe's output path against --dir instead.
  --name          Recipe name (required unless --all is given).
  --category      Recipe category, used for the badge + color seed.
  --ingredients   Comma-separated ingredient names, shown as a short preview.
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
