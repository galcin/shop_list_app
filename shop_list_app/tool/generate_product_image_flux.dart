// ignore_for_file: avoid_print
//
// Product AI image generator — Flux (via fal.ai) edition.
//
// Alternative to tool/generate_product_image_ai.dart (which uses
// Pollinations.ai). Uses Black Forest Labs' Flux model hosted on
// fal.ai (https://fal.ai) for noticeably better prompt adherence /
// photorealism than Pollinations, at a small per-image cost.
//
// Setup (one-time):
//   1. Create a free fal.ai account: https://fal.ai
//   2. Create an API key: https://fal.ai/dashboard/keys
//      (keys look like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:hex...")
//   3. Copy tool/.env.example to tool/.env and paste your key into it:
//        FAL_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//      (tool/.env is gitignored — it will never be committed.)
//      Alternatively, set the FAL_KEY environment variable instead of
//      using a file; the env var always takes priority.
//
// Models (pass via --model, default flux/schnell):
//   flux/schnell  — fastest & cheapest (~$0.003/image). Good default.
//   flux/dev      — higher quality, slower (~$0.025/image).
//   flux-pro/v1.1 — best quality, slowest/most expensive.
//
// Run from the project root:
//
//   dart run tool/generate_product_image_flux.dart --all
//   dart run tool/generate_product_image_flux.dart --all --force --model flux/dev
//   dart run tool/generate_product_image_flux.dart --name "Apples" --category "Fruits"
//
// Use --help for full usage details.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Hard size budget every generated product image must respect.
const int _maxBytes = 50 * 1024;

const String _imagesDir = 'assets/images/products_ai';

const Map<String, String> _modelSlugs = {
  'flux-schnell': 'fal-ai/flux/schnell',
  'flux/schnell': 'fal-ai/flux/schnell',
  'flux-dev': 'fal-ai/flux/dev',
  'flux/dev': 'fal-ai/flux/dev',
  'flux-pro': 'fal-ai/flux-pro/v1.1',
  'flux-pro/v1.1': 'fal-ai/flux-pro/v1.1',
};

/// The default products seeded in lib/core/database/seeder/product_seeder.dart
/// that currently only have an emoji "icon" (no real photo). Kept in sync
/// manually with that file's `name` / `productCategoryId` (mapped to the
/// category name for prompt context) pairs.
const List<Map<String, String>> _defaultProducts = [
  {'name': 'Apples', 'category': 'Fruits'},
  {'name': 'Bananas', 'category': 'Fruits'},
  {'name': 'Carrots', 'category': 'Vegetables'},
  {'name': 'Tomatoes', 'category': 'Vegetables'},
  {'name': 'Milk', 'category': 'Dairy'},
  {'name': 'Cheese', 'category': 'Dairy'},
  {'name': 'Bread', 'category': 'Bakery'},
  {'name': 'Chicken Breast', 'category': 'Meat'},
  {'name': 'Orange Juice', 'category': 'Beverages'},
  {'name': 'Potato Chips', 'category': 'Snacks'},
  {'name': 'Eggs', 'category': 'Dairy'},
  {'name': 'Butter', 'category': 'Dairy'},
  {'name': 'Sour Cream', 'category': 'Dairy'},
  {'name': 'Cooking Cream', 'category': 'Dairy'},
  {'name': 'Fresh Mozzarella', 'category': 'Dairy'},
  {'name': 'Parmesan', 'category': 'Dairy'},
  {'name': 'Minced Beef', 'category': 'Meat'},
  {'name': 'Bacon', 'category': 'Meat'},
  {'name': 'Turkey Breast', 'category': 'Meat'},
  {'name': 'Pressed Ham', 'category': 'Meat'},
  {'name': 'Onion', 'category': 'Vegetables'},
  {'name': 'Garlic', 'category': 'Vegetables'},
  {'name': 'Celery', 'category': 'Vegetables'},
  {'name': 'Zucchini', 'category': 'Vegetables'},
  {'name': 'Potatoes', 'category': 'Vegetables'},
  {'name': 'Bell Peppers', 'category': 'Vegetables'},
  {'name': 'Broccoli', 'category': 'Vegetables'},
  {'name': 'Lettuce', 'category': 'Vegetables'},
  {'name': 'Cucumber', 'category': 'Vegetables'},
  {'name': 'Cherry Tomatoes', 'category': 'Vegetables'},
  {'name': 'Mushrooms', 'category': 'Vegetables'},
  {'name': 'Frozen Vegetables', 'category': 'Vegetables'},
  {'name': 'Lemon', 'category': 'Fruits'},
  {'name': 'Flatbread', 'category': 'Bakery'},
  {'name': 'Puff Pastry Dough', 'category': 'Bakery'},
  {'name': 'Spaghetti', 'category': 'Snacks'},
  {'name': 'Pasta', 'category': 'Snacks'},
  {'name': 'Noodles', 'category': 'Snacks'},
  {'name': 'Rice', 'category': 'Snacks'},
  {'name': 'Flour', 'category': 'Snacks'},
  {'name': 'Rolled Oats', 'category': 'Snacks'},
  {'name': 'Honey', 'category': 'Snacks'},
  {'name': 'Olive Oil', 'category': 'Snacks'},
  {'name': 'Vegetable Oil', 'category': 'Snacks'},
  {'name': 'Soy Sauce', 'category': 'Snacks'},
  {'name': 'Oyster Sauce', 'category': 'Snacks'},
  {'name': 'Tomato Sauce', 'category': 'Snacks'},
  {'name': 'Tomato Paste', 'category': 'Snacks'},
  {'name': 'Crushed Tomatoes', 'category': 'Snacks'},
  {'name': 'Vegetable Broth', 'category': 'Snacks'},
  {'name': 'Canned Tuna', 'category': 'Snacks'},
  {'name': 'Canned Corn', 'category': 'Snacks'},
  {'name': 'Canned Mushrooms', 'category': 'Snacks'},
  {'name': 'Olives', 'category': 'Snacks'},
];

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
    await _processAllProducts(
      token: token,
      model: model,
      force: args.force,
      dryRun: args.dryRun,
      imagesDir: args.dir ?? _imagesDir,
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
    final bytes = await _generateProductImageBytes(
      token: token,
      model: model,
      name: name,
      category: args.category ?? '',
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

/// Generates a Flux image for every entry in [_defaultProducts] whose
/// output file doesn't exist yet under [imagesDir] (or for all products
/// when [force] is true).
Future<void> _processAllProducts({
  required String token,
  required String model,
  required bool force,
  required bool dryRun,
  String imagesDir = _imagesDir,
}) async {
  await Directory(imagesDir).create(recursive: true);

  var generatedCount = 0;
  var skippedCount = 0;
  var failedCount = 0;
  var isFirstRequest = true;

  for (final entry in _defaultProducts) {
    final name = entry['name']!;
    final category = entry['category'] ?? '';
    final slug = _slugify(name);
    final imageUrl = '$imagesDir/$slug.jpg';

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

    // Be a polite API citizen; a small gap between requests avoids
    // tripping any burst rate limits.
    if (!isFirstRequest) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    isFirstRequest = false;

    try {
      final bytes = await _generateProductImageBytes(
        token: token,
        model: model,
        name: name,
        category: category,
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

  stdout.writeln(
    'Done. Generated: $generatedCount, skipped (already existed): '
    '$skippedCount, failed: $failedCount.',
  );
}

/// Requests a Flux-generated product photo for [name]/[category] from
/// Replicate and compresses it to fit [_maxBytes].
Future<List<int>> _generateProductImageBytes({
  required String token,
  required String model,
  required String name,
  required String category,
}) async {
  final prompt = _buildPrompt(name: name, category: category);
  final rawBytes = await _runFluxPrediction(
    token: token,
    model: model,
    prompt: prompt,
  );

  final image = img.decodeImage(Uint8List.fromList(rawBytes));
  if (image == null) {
    throw StateError('Could not decode image returned by Replicate.');
  }

  return _compressToBudget(image);
}

/// Builds a clean product-photography style prompt describing the item.
String _buildPrompt({required String name, required String category}) {
  final buffer = StringBuffer(
    'Professional product photograph of $name, a single real grocery '
    'item, isolated on a plain white seamless background, soft studio '
    'lighting, centered, accurate realistic colors and shape',
  );
  if (category.trim().isNotEmpty) {
    buffer.write(', from the ${category.trim()} category');
  }
  buffer.write(
    '. Sharp focus, high detail, e-commerce catalog style, no text, '
    'no watermark, no props, no hands.',
  );
  return buffer.toString();
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

/// Converts a product name into the lowercase, hyphen-separated filename
/// convention used throughout `assets/images/` (e.g. "Chicken Breast" ->
/// "chicken-breast").
String _slugify(String input) {
  final lower = input.toLowerCase().trim();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

void _printUsage() {
  stdout.writeln('''
Product AI image generator — Flux (via fal.ai) edition
---------------------------------------------------------
Requests a Flux-generated product photo for each default seeded product
that currently only has an emoji icon, via fal.ai's hosted Flux models,
and compresses it to fit the project's 50KB image budget.

Setup: copy tool/.env.example to tool/.env and paste in a fal.ai API key
(https://fal.ai/dashboard/keys), or set the FAL_KEY environment variable.

Usage:
  dart run tool/generate_product_image_flux.dart --all [--dir path] [--force] [--dry-run] [--model flux/schnell|flux/dev|flux-pro/v1.1]
      Generate an image for every product in the built-in list whose
      output file is missing (or all of them with --force).

  dart run tool/generate_product_image_flux.dart --name "Product Name" [--category "Category"] [--dir path] [--out path] [--model flux/schnell|flux/dev|flux-pro/v1.1]
      Generate a single image for the given product. Defaults to
      assets/images/products_ai/<slug>.jpg if --out/--dir are omitted.

Options:
  --all           Process every product in the built-in list.
  --force         Regenerate images even if a file already exists (with --all).
  --dry-run       Show what would be generated without writing files (with --all).
  --dir           Output directory for generated images (default: assets/images/products_ai).
  --model         flux/schnell (default, cheapest/fastest), flux/dev, or flux-pro/v1.1.
  --name          Product name (required unless --all is given).
  --category      Product category, used to steer the prompt.
  --out           Output file path (single-product mode only).
  -h, --help      Show this help message.
''');
}

class _Args {
  _Args({
    this.name,
    this.category,
    this.out,
    this.dir,
    this.model = 'flux/schnell',
    this.processAll = false,
    this.force = false,
    this.dryRun = false,
    this.showHelp = false,
  });

  final String? name;
  final String? category;
  final String? out;
  final String? dir;
  final String model;
  final bool processAll;
  final bool force;
  final bool dryRun;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    String? name;
    String? category;
    String? out;
    String? dir;
    var model = 'flux/schnell';
    var processAll = false;
    var force = false;
    var dryRun = false;
    var showHelp = false;

    var i = 0;
    while (i < arguments.length) {
      final arg = arguments[i];
      if (arg == '--name' && i + 1 < arguments.length) {
        name = arguments[++i];
      } else if (arg == '--category' && i + 1 < arguments.length) {
        category = arguments[++i];
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
      out: out,
      dir: dir,
      model: model,
      processAll: processAll,
      force: force,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}
