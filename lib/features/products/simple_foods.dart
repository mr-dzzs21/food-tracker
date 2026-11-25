import 'dart:math';

import 'package:flutter/foundation.dart';

import 'food_source.dart';
import 'nutrients.dart';
import 'search_text.dart';

// Simple foods ("Lebensmittel"): about 400 everyday foods with short names
// ("Skyr natur", "Reis gekocht"), search words and a typical portion – what
// the search shows first. Made by tool/simple_foods/build_simple_foods.py
// from tool/simple_foods/foods.tsv, in two bundled files (one per licence,
// see assets/data/README.md):
//
// - simple_foods_bls.tsv: values from the BLS (CC BY 4.0), stored as
//   FoodSource.bls with the BLS code, like the basic foods.
// - simple_foods_off.tsv: medians of Open Food Facts products (ODbL) for
//   foods the BLS does not have, stored as FoodSource.offAverage.
//
// Pure Dart: reading the files and the search ranking. Loading the assets
// and the providers live in simple_foods_repository.dart.

/// One simple food, for example "Skyr natur".
@immutable
class SimpleFood {
  const SimpleFood({
    required this.key,
    required this.nameDe,
    required this.nameEn,
    required this.nutrients,
    this.order = 0,
    this.synonymsDe = const [],
    this.synonymsEn = const [],
    this.isLiquid = false,
    this.category,
    this.portionGrams,
    this.portionDe,
    this.portionEn,
    this.blsCode,
    this.offProductCount,
  });

  /// Stable key of the list, for example "skyr-natur".
  final String key;

  /// Position in tool/simple_foods/foods.tsv: equally good search hits keep
  /// this order (basic foods first, dishes last).
  final int order;
  final String nameDe;
  final String nameEn;

  /// Other words people type for this food ("Nudeln" → "Pasta", "Spaghetti").
  final List<String> synonymsDe;
  final List<String> synonymsEn;

  /// Values per 100 g (per 100 ml for drinks, 1 ml counted as 1 g).
  final Nutrients nutrients;
  final bool isLiquid;

  /// An Open Food Facts category tag for kinds of food without a traffic
  /// light (from the BLS, for example `en:waters`), otherwise `null`.
  final String? category;

  /// A typical portion in g (or ml), for example 120 for one banana.
  final double? portionGrams;

  /// Name of that portion, for example "1 Banane".
  final String? portionDe;
  final String? portionEn;

  /// The BLS code when the values come from the BLS, otherwise `null`.
  final String? blsCode;

  /// For Open Food Facts medians: how many products went into them.
  final int? offProductCount;

  /// Where the food is stored on the device: BLS values share the row of
  /// the BLS food (same code), the others get their own kind.
  FoodSource get source =>
      blsCode == null ? FoodSource.offAverage : FoodSource.bls;

  /// The key of the stored food within its [source].
  String get externalId => blsCode ?? key;

  /// The name in the UI language (German unless it is English).
  String nameFor(String languageCode) => languageCode == 'en' ? nameEn : nameDe;

  /// "1 Banane" in the UI language, or `null` without a typical portion.
  String? portionFor(String languageCode) =>
      languageCode == 'en' ? portionEn : portionDe;
}

/// Reads one of the bundled files: tab-separated, a header line with the
/// column names first, lines starting with `#` are comments. Search words
/// are separated by `|`.
///
/// Throws a [FormatException] for a broken file (it is bundled with the
/// app, so that is a bug the tests catch).
List<SimpleFood> parseSimpleFoods(String text) {
  final lines = [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty && !line.startsWith('#'))
        line.replaceAll('\r', ''),
  ];
  if (lines.isEmpty) return const [];

  final header = lines.first.split('\t');
  int column(String name) {
    final index = header.indexOf(name);
    if (index < 0) throw FormatException('Simple foods: no column "$name"');
    return index;
  }

  final order = column('order');
  final key = column('key');
  final nameDe = column('name_de');
  final nameEn = column('name_en');
  final synonymsDe = column('synonyms_de');
  final synonymsEn = column('synonyms_en');
  final kcal = column('kcal');
  final fat = column('fat');
  final saturatedFat = column('saturated_fat');
  final carbs = column('carbs');
  final sugars = column('sugars');
  final fibre = column('fibre');
  final protein = column('protein');
  final salt = column('salt');
  final liquid = column('liquid');
  final category = column('category');
  final portionGrams = column('portion_g');
  final portionDe = column('portion_de');
  final portionEn = column('portion_en');
  final blsCode = column('bls_code');
  final offProducts = column('off_products');

  final foods = <SimpleFood>[];
  for (final line in lines.skip(1)) {
    final fields = line.split('\t');
    if (fields.length != header.length) {
      throw FormatException('Simple foods: wrong number of columns in "$line"');
    }
    double? number(int column) {
      final field = fields[column];
      if (field.isEmpty) return null; // unknown, never 0
      final value = double.tryParse(field);
      if (value == null) {
        throw FormatException('Simple foods: "$field" is no number in "$line"');
      }
      return value;
    }

    String? text(int column) =>
        fields[column].trim().isEmpty ? null : fields[column].trim();
    List<String> words(int column) => [
      for (final word in fields[column].split('|'))
        if (word.trim().isNotEmpty) word.trim(),
    ];

    foods.add(
      SimpleFood(
        order: number(order)?.toInt() ?? 0,
        key: fields[key],
        nameDe: fields[nameDe],
        nameEn: fields[nameEn],
        synonymsDe: words(synonymsDe),
        synonymsEn: words(synonymsEn),
        nutrients: Nutrients(
          kcal: number(kcal),
          fat: number(fat),
          saturatedFat: number(saturatedFat),
          carbs: number(carbs),
          sugars: number(sugars),
          fibre: number(fibre),
          protein: number(protein),
          salt: number(salt),
        ),
        isLiquid: fields[liquid] == '1',
        category: text(category),
        portionGrams: number(portionGrams),
        portionDe: text(portionDe),
        portionEn: text(portionEn),
        blsCode: text(blsCode),
        offProductCount: number(offProducts)?.toInt(),
      ),
    );
  }
  return foods;
}

// -----------------------------------------------------------------------------
// Search

/// Finds simple foods by name and search words, best match first.
///
/// Every word of the query must be found. How well a query word fits a word
/// (same points as the BLS search, see `BasicFoodIndex`):
///
/// 1. the whole word, also in another form ("kartoffel" = "Kartoffeln",
///    "nudeln" = "Nudel": a German ending like -n, -e, -en is ignored),
/// 2. the end of a compound word ("reis" → "Vollkornreis"),
/// 3. the start of a word ("reis" → "Reiswaffeln").
///
/// Unlike the BLS search there is no match inside a word: in this short
/// list it only finds accidents ("cola" in "Rucola" or "chocolate").
///
/// A match in the main part of the name in the UI language counts 4 points
/// more, so the food that *is* "Skyr" comes before one that is only found
/// by a search word. A search word (or the name in the other language) that
/// matches completely counts 3 points more – "huhn" finds "Hähnchenbrust"
/// (search word "Huhn") before "Hühnersuppe" (name only starts with it).
/// An English user typing "Brötchen" still finds "Bread roll". Equally good
/// hits keep the order of the list – it starts with basic foods, so
/// "Reis gekocht" comes before "Milchreis".
class SimpleFoodIndex {
  SimpleFoodIndex(List<SimpleFood> foods)
    : foods = [...foods]..sort((a, b) => a.order.compareTo(b.order));

  /// How many results [search] returns by default: enough for one screen,
  /// the brand products follow below.
  static const defaultLimit = 10;

  final List<SimpleFood> foods;

  /// The prepared words of every food, per language (built on first use).
  final _entries = <String, List<_SimpleEntry>>{};

  /// The food stored as ([source], [externalId]), or `null`.
  SimpleFood? find(FoodSource source, String externalId) {
    for (final food in foods) {
      if (food.source == source && food.externalId == externalId) return food;
    }
    return null;
  }

  List<SimpleFood> search(
    String query, {
    required String languageCode,
    int limit = defaultLimit,
  }) {
    final queryWords = [for (final token in searchTokens(query)) token.text];
    if (queryWords.isEmpty) return const [];

    final entries = _entries.putIfAbsent(
      languageCode,
      () => [for (final food in foods) _SimpleEntry(food, languageCode)],
    );
    final hits = <({SimpleFood food, int score, int index})>[];
    for (final (index, entry) in entries.indexed) {
      var score = 0;
      for (final word in queryWords) {
        final wordScore = entry.score(word);
        if (wordScore == 0) {
          score = 0;
          break; // every query word must match
        }
        score += wordScore;
      }
      if (score > 0) hits.add((food: entry.food, score: score, index: index));
    }
    // Equal scores keep the list order.
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.index.compareTo(b.index);
    });
    return [for (final hit in hits.take(limit)) hit.food];
  }
}

// Points for one query word, as in BasicFoodIndex.
const _wholeWord = 4;
const _compoundEnd = 3;
const _wordStart = 2;
const _mainPartBonus = 4;
const _wholeSearchWordBonus = 3;

/// A simple food prepared for searching in one language.
class _SimpleEntry {
  _SimpleEntry(this.food, String languageCode)
    : nameTokens = searchTokens(food.nameFor(languageCode)),
      otherTokens = [
        for (final text in [
          languageCode == 'en' ? food.nameDe : food.nameEn,
          ...food.synonymsDe,
          ...food.synonymsEn,
        ])
          ...searchTokens(text),
      ];

  final SimpleFood food;

  /// The words of the name in the UI language (they get the bonus).
  final List<SearchToken> nameTokens;

  /// Search words and the name in the other language.
  final List<SearchToken> otherTokens;

  /// 0 when [queryWord] is not found, otherwise the points of its best match.
  int score(String queryWord) {
    final stem = _stem(queryWord);
    var best = 0;
    for (final token in nameTokens) {
      final kind = _matchKind(token, queryWord, stem);
      final points = kind > 0 && token.inMainPart
          ? kind + _mainPartBonus
          : kind;
      best = max(best, points);
    }
    for (final token in otherTokens) {
      final kind = _matchKind(token, queryWord, stem);
      final points = kind == _wholeWord ? kind + _wholeSearchWordBonus : kind;
      best = max(best, points);
    }
    return best;
  }
}

int _matchKind(SearchToken token, String word, String stem) {
  final text = token.text;
  if (token.isHead && (text == word || _stem(text) == stem)) return _wholeWord;
  if (token.isHead &&
      (_endsCompound(text, word) || _endsCompound(_stem(text), stem))) {
    return _compoundEnd;
  }
  if (text.startsWith(stem)) return _wordStart;
  return 0;
}

/// Whether [text] is a compound word ending with [end]: the first part has
/// at least 3 letters ("Mager|milch"), so "Rucola" does not end with "cola".
bool _endsCompound(String text, String end) =>
    text.length - end.length >= 3 && text.endsWith(end);

/// [word] without a German plural or case ending, so "kartoffeln" and
/// "kartoffel", "tomaten" and "tomate" become the same. At least four
/// letters stay, so short words ("reis", "eier") are left alone.
String _stem(String word) {
  for (final ending in const ['en', 'er', 'n', 'e', 's']) {
    if (word.endsWith(ending) && word.length - ending.length >= 4) {
      return word.substring(0, word.length - ending.length);
    }
  }
  return word;
}
