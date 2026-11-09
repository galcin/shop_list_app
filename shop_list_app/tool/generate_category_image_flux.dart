// ignore_for_file: avoid_print
//
// Product-category AI image generator — Flux (via fal.ai) edition.
//
// Companion to tool/generate_product_image_flux.dart. Generates a square
// "poster" photo for each product category in
// assets/data/product_categories.json that doesn't yet have an `imageName`
// (e.g. "Herbs & Spices", "Fish & Seafood", …), via Black Forest Labs' Flux
// model hosted on fal.ai (https://fal.ai), and compresses the result to fit
// the project's 50KB image budget.
//
// Setup (one-time): same as generate_product_image_flux.dart —
//   1. Create a free fal.ai account: https://fal.ai
//   2. Create an API key: https://fal.ai/dashboard/keys
//   3. Copy tool/.env.example to tool/.env and paste your key into it, or
//      set the FAL_KEY environment variable.
//
// Models (pass via --model, default flux/schnell):
//   flux/schnell  — fastest & cheapest (~$0.003/image). Good default.
//   flux/dev      — higher quality, slower (~$0.025/image).
//   flux-pro/v1.1 — best quality, slowest/most expensive.
//
// Images are written directly under assets/images/ (no subfolder) as
// `<slug>_category.webp`, matching the convention of the 6 existing
// hand-picked category images (e.g. `dairy_category.png`), so no pubspec.yaml
// changes or extra asset declarations are needed.
//
// Run from the project root:
//
//   dart run tool/generate_category_image_flux.dart --all
//   dart run tool/generate_category_image_flux.dart --all --force --model flux/dev
//   dart run tool/generate_category_image_flux.dart --name "Herbs & Spices"
//
// Use --help for full usage details.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Hard size budget every generated category image must respect.
const int _maxBytes = 50 * 1024;

const String _categoriesJsonPath = 'assets/data/product_categories.json';

/// Bare directory (relative to the project root) images are written to.
/// `imageName` in product_categories.json is resolved by the app as
/// `assets/images/$imageName`, so this must stay `assets/images`.
const String _imagesDir = 'assets/images';

const Map<String, String> _modelSlugs = {
  'flux-schnell': 'fal-ai/flux/schnell',
  'flux/schnell': 'fal-ai/flux/schnell',
  'flux-dev': 'fal-ai/flux/dev',
  'flux/dev': 'fal-ai/flux/dev',
  'flux-pro': 'fal-ai/flux-pro/v1.1',
  'flux-pro/v1.1': 'fal-ai/flux-pro/v1.1',
};

/// Short, human-written hints describing representative contents for each
/// known category, used to steer the prompt beyond just the raw name.
/// Categories not listed here fall back to using the name/emoji alone.
const Map<String, String> _categoryHints = {
  'Fruits': 'a colorful assortment of fresh whole fruits like apples, '
      'bananas and oranges',
  'Vegetables': 'a colorful assortment of fresh vegetables like carrots, '
      'tomatoes, peppers and broccoli',
  'Herbs & Spices': 'fresh herb sprigs and small bowls of ground spices '
      'like basil, parsley, paprika and cinnamon',
  'Dairy': 'a selection of dairy products: a glass bottle of milk, a wedge '
      'of cheese, butter and eggs',
  'Meat': 'raw cuts of meat such as steak, chicken breast and ground beef '
      'on butcher paper',
  'Fish & Seafood': 'fresh fish fillets, shrimp and seafood arranged on ice',
  'Bakery': 'fresh baked bread loaves, rolls and a baguette',
  'Grains & Pasta': 'dried pasta shapes, rice and grains in bowls',
  'Canned & Jarred': 'neatly arranged canned goods and glass jars of '
      'preserved food',
  'Oils & Condiments': 'bottles of olive oil and jars of condiments like '
      'mustard and ketchup',
  'Baking': 'baking ingredients: flour, sugar, a whisk and a mixing bowl',
  'Nuts & Dried Fruit': 'a mix of whole nuts and dried fruits like almonds, '
      'walnuts, raisins and apricots',
  'Frozen': 'frozen vegetables and food in a frosty, icy package',
  'Beverages': 'glass bottles and cans of refreshing drinks like juice and '
      'soda with condensation',
  'Snacks': 'a mix of snack foods like potato chips, pretzels and crackers',
  'Household': 'household cleaning and paper supplies like detergent, '
      'sponges and paper towels',
};

Future<void> main(List<String> arguments) async {
  final args = _Args.parse(arguments);

  if (args.showHelp) {
    _printUsage();
    return;
  }

  final token = _resolveApiToken();
  if (token == null || token.trim().isEmpty || token.contains('your_fal_key')) {
    stderr.writeln(
      'Error: no fal.ai API key found.\n'
      '  Set the FAL_KEY environment variable, or copy tool/.env.example '
      'to tool/.env and fill in your key.\n'
      '  Get a key at https://fal.ai/dashboard/keys',
    );
    exitCode = 78; // EX_CONFIG
    return;
  }

  final model = _modelSlugs[args.model] ?? _modelSlugs['flux-schnell']!;

  if (args.processAll) {
    await _processAllCategories(
      token: token,
      model: model,
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
  final outPath = args.out ?? '${args.dir ?? _imagesDir}/${slug}_category.webp';

  try {
    final bytes = await _generateCategoryImageBytes(
      token: token,
      model: model,
      name: name,
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

/// Scans [_categoriesJsonPath] and generates a Flux image for every
/// category that doesn't have an `imageName` yet (or for all categories
/// when [force] is true). When [updateJson] is true, each category's
/// `imageName` field is set to the newly generated file's bare name (and
/// the JSON file is rewritten) after a successful generation.
Future<void> _processAllCategories({
  required String token,
  required String model,
  required bool force,
  required bool dryRun,
  String imagesDir = _imagesDir,
  bool updateJson = true,
}) async {
  final jsonFile = File(_categoriesJsonPath);
  if (!jsonFile.existsSync()) {
    stderr.writeln(
      'Error: could not find $_categoriesJsonPath '
      '(run this script from the project root).',
    );
    exitCode = 66;
    return;
  }

  final raw = await jsonFile.readAsString();
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    stderr.writeln(
      'Error: expected $_categoriesJsonPath to contain a JSON array of categories.',
    );
    exitCode = 65;
    return;
  }

  await Directory(imagesDir).create(recursive: true);

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

    final slug = _slugify(name);
    final fileName = '${slug}_category.webp';
    final targetPath = '$imagesDir/$fileName';

    final existingImageName = map['imageName'] as String?;
    if (existingImageName != null &&
        existingImageName.trim().isNotEmpty &&
        !force) {
      skippedCount++;
      continue;
    }

    final imageFile = File(targetPath);
    if (imageFile.existsSync() && !force) {
      skippedCount++;
      if (updateJson && map['imageName'] != fileName) {
        map['imageName'] = fileName;
        changedJson = true;
      }
      continue;
    }

    if (dryRun) {
      stdout.writeln('[dry-run] would generate $targetPath for "$name"');
      generatedCount++;
      continue;
    }

    // Be a polite API citizen; a small gap between requests avoids
    // tripping any burst rate limits.
    if (!isFirstRequest) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    isFirstRequest = false;

    try {
      final bytes = await _generateCategoryImageBytes(
        token: token,
        model: model,
        name: name,
      );
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(bytes);
      generatedCount++;
      if (updateJson && map['imageName'] != fileName) {
        map['imageName'] = fileName;
        changedJson = true;
      }
      stdout.writeln(
        'Generated $targetPath (${_formatBytes(bytes.length)}) for "$name"',
      );
    } catch (e) {
      failedCount++;
      stderr.writeln('Failed to generate image for "$name": $e');
    }
  }

  if (updateJson && changedJson && !dryRun) {
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString('${encoder.convert(decoded)}\n');
    stdout.writeln('Updated $_categoriesJsonPath with new imageName entries.');
  }

  stdout.writeln(
    'Done. Generated: $generatedCount, skipped (already had an image): '
    '$skippedCount, failed: $failedCount.',
  );
}

/// Requests a Flux-generated category "poster" photo for [name] from
/// fal.ai and compresses it to fit [_maxBytes].
Future<List<int>> _generateCategoryImageBytes({
  required String token,
  required String model,
  required String name,
}) async {
  final prompt = _buildPrompt(name: name);
  final rawBytes = await _runFluxPrediction(
    token: token,
    model: model,
    prompt: prompt,
  );

  final image = img.decodeImage(Uint8List.fromList(rawBytes));
  if (image == null) {
    throw StateError('Could not decode image returned by fal.ai.');
  }

  return _compressToBudget(image);
}

/// Builds a clean product-photography style prompt for a category "poster".
String _buildPrompt({required String name}) {
  final hint = _categoryHints[name];
  final subject = hint ?? 'a representative assortment of $name items';
  return 'Professional product photograph of $subject, isolated on a '
      'plain white seamless background, soft studio lighting, centered, '
      'top-down flat-lay composition, accurate realistic colors. Sharp '
      'focus, high detail, e-commerce catalog style, no text, no '
      'watermark, no hands.';
}

/// Calls fal.ai's synchronous `fal.run` endpoint for [model] with
/// [prompt] and downloads the resulting image bytes. Throws on API
/// errors or a response with no image.
Future<List<int>> _runFluxPrediction({
  required String token,
  required String model,
  required String prompt,
}) async {
  final uri = Uri.parse('https://fal.run/$model');

  const maxAttempts = 3;
  Map<String, dynamic>? result;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Key $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(
          jsonEncode({
            'prompt': prompt,
            'image_size': 'square_hd',
            'num_images': 1,
          }),
        ),
      );

      final response = await request.close().timeout(
            const Duration(seconds: 90),
          );
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        final retryable =
            response.statusCode == 429 || response.statusCode >= 500;
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
          'fal.ai request failed with status ${response.statusCode}: $body',
          uri: uri,
        );
      }

      result = jsonDecode(body) as Map<String, dynamic>;
      break;
    } finally {
      client.close(force: true);
    }
  }

  if (result == null) {
    throw StateError('Failed to reach fal.ai after $maxAttempts attempts.');
  }

  final images = result['images'];
  String? imageUrl;
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is Map) {
      imageUrl = first['url'] as String?;
    }
  }
  if (imageUrl == null || imageUrl.isEmpty) {
    throw StateError('fal.ai response had no output image URL: $result');
  }

  return _downloadBytes(imageUrl);
}

Future<List<int>> _downloadBytes(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      await response.drain<void>();
      throw HttpException(
        'Downloading generated image failed with status ${response.statusCode}',
      );
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    return bytes;
  } finally {
    client.close(force: true);
  }
}

/// Resolves the fal.ai API key: environment variable takes priority,
/// falling back to a `tool/.env` file (simple KEY=VALUE lines) if present.
String? _resolveApiToken() {
  final fromEnv = Platform.environment['FAL_KEY'];
  if (fromEnv != null && fromEnv.trim().isNotEmpty) {
    return fromEnv.trim();
  }

  final envFile = File('tool/.env');
  if (!envFile.existsSync()) return null;

  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eqIndex = trimmed.indexOf('=');
    if (eqIndex == -1) continue;
    final key = trimmed.substring(0, eqIndex).trim();
    if (key != 'FAL_KEY') continue;
    var value = trimmed.substring(eqIndex + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    return value;
  }
  return null;
}

/// Encodes [image] as lossy WebP, stepping down quality and (if that's not
/// enough) image dimensions until the result is at or under [maxBytes].
List<int> _compressToBudget(img.Image image, {int maxBytes = _maxBytes}) {
  const qualities = [92, 85, 78, 70, 62, 54, 46, 38, 30, 22, 15];
  var current = image;

  for (var pass = 0; pass < 5; pass++) {
    for (final quality in qualities) {
      final bytes =
          img.encodeWebP(current, lossless: false, quality: quality, method: 4);
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
  return img.encodeWebP(current, lossless: false, quality: 10, method: 4);
}

/// Converts a category name into the lowercase, hyphen-separated slug used
/// to build filenames (e.g. "Herbs & Spices" -> "herbs-spices").
String _slugify(String input) {
  final lower = input.toLowerCase().trim();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

void _printUsage() {
  stdout.writeln('''
Product-category AI image generator — Flux (via fal.ai) edition
-----------------------------------------------------------------
Requests a Flux-generated "poster" photo for every category in
assets/data/product_categories.json that doesn't have an imageName yet,
via fal.ai's hosted Flux models, and compresses it to fit the project's
50KB image budget. Images are written directly under assets/images/ as
<slug>_category.webp, matching the existing hand-picked category images.

Setup: copy tool/.env.example to tool/.env and paste in a fal.ai API key
(https://fal.ai/dashboard/keys), or set the FAL_KEY environment variable.

Usage:
  dart run tool/generate_category_image_flux.dart --all [--dir path] [--force] [--dry-run] [--no-json] [--model flux/schnell|flux/dev|flux-pro/v1.1]
      Scan assets/data/product_categories.json; generate an image for every
      category that doesn't have an imageName yet (or all of them with
      --force).

  dart run tool/generate_category_image_flux.dart --name "Category Name" [--dir path] [--out path] [--model flux/schnell|flux/dev|flux-pro/v1.1]
      Generate a single image for the given category. Defaults to
      assets/images/<slug>_category.webp if --out/--dir are omitted.

Options:
  --all           Process every category in assets/data/product_categories.json.
  --force         Regenerate images even for categories that already have one (with --all).
  --dry-run       Show what would be generated without writing files (with --all).
  --dir           Output directory for generated images (default: assets/images).
  --no-json       With --all, don't update the `imageName` field in product_categories.json.
  --model         flux/schnell (default, cheapest/fastest), flux/dev, or flux-pro/v1.1.
  --name          Category name (required unless --all is given).
  --out           Output file path (single-category mode only).
  -h, --help      Show this help message.
''');
}

class _Args {
  _Args({
    this.name,
    this.out,
    this.dir,
    this.model = 'flux/schnell',
    this.processAll = false,
    this.force = false,
    this.dryRun = false,
    this.noJson = false,
    this.showHelp = false,
  });

  final String? name;
  final String? out;
  final String? dir;
  final String model;
  final bool processAll;
  final bool force;
  final bool dryRun;
  final bool noJson;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    String? name;
    String? out;
    String? dir;
    var model = 'flux/schnell';
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
      } else if (arg == '--out' && i + 1 < arguments.length) {
        out = arguments[++i];
      } else if (arg == '--dir' && i + 1 < arguments.length) {
        dir = arguments[++i];
      } else if (arg == '--model' && i + 1 < arguments.length) {
        model = arguments[++i];
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
      out: out,
      dir: dir,
      model: model,
      processAll: processAll,
      force: force,
      dryRun: dryRun,
      noJson: noJson,
      showHelp: showHelp,
    );
  }
}
