/// Canonical measurement units shared by recipes, shopping lists and pantry.
///
/// Every unit is stored in the database as one of the lowercase codes below.
/// Free text coming from forms or seed files goes through [normalize] first so
/// that `cups`, `Cup` and `cup` all end up as the same code and can be
/// aggregated together.
class Units {
  Units._();

  /// No unit (used for "to taste" style ingredients).
  static const String none = '';
  static const String pcs = 'pcs';
  static const String g = 'g';
  static const String kg = 'kg';
  static const String ml = 'ml';
  static const String l = 'l';
  static const String tsp = 'tsp';
  static const String tbsp = 'tbsp';
  static const String cup = 'cup';
  static const String clove = 'clove';
  static const String slice = 'slice';
  static const String bunch = 'bunch';
  static const String sprig = 'sprig';
  static const String stalk = 'stalk';
  static const String leaf = 'leaf';
  static const String head = 'head';
  static const String pinch = 'pinch';
  static const String handful = 'handful';
  static const String can = 'can';
  static const String pack = 'pack';
  static const String jar = 'jar';
  static const String bottle = 'bottle';
  static const String sheet = 'sheet';

  /// Every valid unit code, including [none].
  static const List<String> all = [
    none,
    pcs,
    g,
    kg,
    ml,
    l,
    tsp,
    tbsp,
    cup,
    clove,
    slice,
    bunch,
    sprig,
    stalk,
    leaf,
    head,
    pinch,
    handful,
    can,
    pack,
    jar,
    bottle,
    sheet,
  ];

  /// Units offered in pickers, ordered by how often they are used.
  static const List<String> common = [
    pcs,
    g,
    kg,
    ml,
    l,
    tbsp,
    tsp,
    cup,
    clove,
    slice,
    bunch,
    can,
    pack,
    pinch,
    none,
  ];

  /// Units that are only meaningful as a whole-number count of items.
  static const Set<String> countable = {
    pcs,
    clove,
    slice,
    bunch,
    sprig,
    stalk,
    leaf,
    head,
    can,
    pack,
    jar,
    bottle,
    sheet,
  };

  static const Map<String, String> _plural = {
    pcs: 'pcs',
    g: 'g',
    kg: 'kg',
    ml: 'ml',
    l: 'l',
    tsp: 'tsp',
    tbsp: 'tbsp',
    cup: 'cups',
    clove: 'cloves',
    slice: 'slices',
    bunch: 'bunches',
    sprig: 'sprigs',
    stalk: 'stalks',
    leaf: 'leaves',
    head: 'heads',
    pinch: 'pinches',
    handful: 'handfuls',
    can: 'cans',
    pack: 'packs',
    jar: 'jars',
    bottle: 'bottles',
    sheet: 'sheets',
  };

  static const Map<String, String> _aliases = {
    // pieces
    'pc': pcs, 'pcs': pcs, 'piece': pcs, 'pieces': pcs, 'x': pcs,
    'buc': pcs, 'bucata': pcs, 'bucati': pcs, 'whole': pcs, 'unit': pcs,
    'units': pcs, 'item': pcs, 'items': pcs, 'egg': pcs, 'eggs': pcs,
    'lemon': pcs, 'lemons': pcs, 'fillet': pcs, 'fillets': pcs,
    // mass
    'g': g, 'gr': g, 'gram': g, 'grams': g, 'grame': g,
    'kg': kg, 'kilo': kg, 'kilos': kg, 'kilogram': kg, 'kilograms': kg,
    // volume
    'ml': ml, 'milliliter': ml, 'milliliters': ml, 'millilitre': ml,
    'millilitres': ml,
    'l': l, 'liter': l, 'liters': l, 'litre': l, 'litres': l, 'litru': l,
    'litri': l,
    'tsp': tsp, 'teaspoon': tsp, 'teaspoons': tsp, 'lingurita': tsp,
    'lingurite': tsp,
    'tbsp': tbsp, 'tablespoon': tbsp, 'tablespoons': tbsp, 'tbs': tbsp,
    'lingura': tbsp, 'linguri': tbsp,
    'cup': cup, 'cups': cup, 'cana': cup, 'cani': cup,
    // count-like
    'clove': clove, 'cloves': clove, 'catel': clove, 'catei': clove,
    'slice': slice, 'slices': slice, 'felie': slice, 'felii': slice,
    'bunch': bunch, 'bunches': bunch, 'legatura': bunch, 'legaturi': bunch,
    'sprig': sprig, 'sprigs': sprig,
    'stalk': stalk, 'stalks': stalk, 'rib': stalk, 'ribs': stalk,
    'leaf': leaf, 'leaves': leaf,
    'head': head, 'heads': head,
    'pinch': pinch, 'pinches': pinch, 'praf': pinch,
    'handful': handful, 'handfuls': handful,
    'can': can, 'cans': can, 'tin': can, 'tins': can, 'conserva': can,
    'pack': pack, 'packs': pack, 'package': pack, 'packages': pack,
    'packet': pack, 'packets': pack, 'bag': pack, 'bags': pack, 'box': pack,
    'boxes': pack,
    'jar': jar, 'jars': jar, 'borcan': jar,
    'bottle': bottle, 'bottles': bottle, 'sticla': bottle,
    'sheet': sheet, 'sheets': sheet, 'foaie': sheet, 'foi': sheet,
  };

  /// Returns the canonical code for [raw], or [pcs] when it cannot be
  /// recognised. An empty or null input maps to [none].
  static String normalize(String? raw) {
    if (raw == null) return none;
    final key = raw.trim().toLowerCase().replaceAll('.', '');
    if (key.isEmpty) return none;
    if (_aliases.containsKey(key)) return _aliases[key]!;
    // Accept already-canonical codes that have no alias entry of their own.
    if (all.contains(key)) return key;
    return pcs;
  }

  /// `true` when [raw] is recognised as a unit (including the empty unit).
  static bool isKnown(String? raw) {
    if (raw == null) return true;
    final key = raw.trim().toLowerCase().replaceAll('.', '');
    return key.isEmpty || _aliases.containsKey(key) || all.contains(key);
  }

  /// Human readable label for [code]. Pluralised when [quantity] is not 1.
  static String label(String code, [double? quantity]) {
    if (code == none) return '';
    if (quantity == null || quantity == 1) return code;
    return _plural[code] ?? code;
  }

  /// Label used inside pickers (shows a dash for the empty unit).
  static String pickerLabel(String code) => code == none ? '—' : code;
}
