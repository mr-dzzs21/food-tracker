import 'dart:math';

import 'package:flutter/foundation.dart';

import 'nutrients.dart';
import 'search_text.dart';

// Basic foods ("Grundnahrungsmittel") with average values: the
// Bundeslebensmittelschlüssel (BLS) 4.0 of the Max Rubner-Institut, bundled
// as assets/data/bls_4_0.tsv (made by tool/bls/convert_bls.py, licence CC BY
// 4.0, see assets/data/README.md).
//
// Pure Dart: reading the file and the search ranking. Loading the asset and
// the providers live in basic_foods_repository.dart.

/// Website of the BLS (shown on the product page and the About page).
final blsWebsite = Uri.https('www.blsdb.de');

/// The licence of the BLS data (Creative Commons Attribution 4.0).
final ccByLicence = Uri.https('creativecommons.org', '/licenses/by/4.0/');

/// One food of the BLS, for example "Weizenfladenbrot".
@immutable
class BasicFood {
  const BasicFood({
    required this.code,
    required this.nameDe,
    required this.nameEn,
    required this.nutrients,
    this.isLiquid = false,
    this.category,
  });

  /// The BLS code, for example "B782100". Stored as `Foods.externalId`.
  final String code;
  final String nameDe;
  final String nameEn;

  /// Average values per 100 g. For drinks the app reads them as per 100 ml
  /// (1 ml counted as 1 g, like everywhere in the app).
  final Nutrients nutrients;

  /// True for drinks (amounts in ml, drink thresholds in the rating).
  final bool isLiquid;

  /// An Open Food Facts category tag for kinds of food that get no traffic
  /// light (for example `en:spices` or `en:waters`), otherwise `null`. The
  /// rules are in tool/bls/README.md.
  final String? category;

  /// The name in the UI language (German unless it is English).
  String nameFor(String languageCode) => languageCode == 'en' ? nameEn : nameDe;
}

/// Reads the bundled BLS file: tab-separated, one food per line, a header
/// line with the column names first. Lines starting with `#` are comments.
///
/// Throws a [FormatException] for a broken file (it is bundled with the app,
/// so that is a bug the tests catch).
List<BasicFood> parseBasicFoods(String text) {
  final lines = [
    for (final line in text.split('\n'))
      // Without '\r' (Windows line ends); an empty last column stays.
      if (line.trim().isNotEmpty && !line.startsWith('#'))
        line.replaceAll('\r', ''),
  ];
  if (lines.isEmpty) return const [];

  final header = lines.first.split('\t');
  int column(String name) {
    final index = header.indexOf(name);
    if (index < 0) throw FormatException('BLS file: no column "$name"');
    return index;
  }

  final code = column('code');
  final nameDe = column('name_de');
  final nameEn = column('name_en');
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

  final foods = <BasicFood>[];
  for (final line in lines.skip(1)) {
    final fields = line.split('\t');
    if (fields.length != header.length) {
      throw FormatException('BLS file: wrong number of columns in "$line"');
    }
    double? number(int column) {
      final field = fields[column];
      if (field.isEmpty) return null; // unknown, never 0
      final value = double.tryParse(field);
      if (value == null) {
        throw FormatException('BLS file: "$field" is no number in "$line"');
      }
      return value;
    }

    final tag = fields[category];
    foods.add(
      BasicFood(
        code: fields[code],
        nameDe: fields[nameDe],
        nameEn: fields[nameEn],
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
        category: tag.isEmpty ? null : tag,
      ),
    );
  }
  return foods;
}

// -----------------------------------------------------------------------------
// Search

/// Finds basic foods by name, best match first.
///
/// Every word of the query must be found in the name (in the UI language).
/// How well a query word fits a word of the name:
///
/// 1. the whole word ("reis" → "Reis poliert, roh"),
/// 2. the end of a compound word – in German the end names the thing itself
///    ("fladenbrot" → "Weizenfladenbrot", "milch" → "Vollmilch"),
/// 3. the start of a word ("reis" → "Reisdrink"),
/// 4. somewhere inside a word – a weak fallback, because it is often
///    unrelated ("reis" in "Vordereisbein").
///
/// Matches 1–3 count much more in the *main part* of the name: the words
/// before the first comma, bracket or linking word like "mit". The BLS names
/// the food itself there and what it is made with later ("Reis poliert, roh"
/// vs. "Paprika gefüllt mit Reis"). In a word with hyphens only the last part
/// names the thing ("Apfel-Streuselkuchen" is a cake, so "apfel" only counts
/// as the start of a word there).
///
/// Ties go to raw foods ("roh"), then to the shorter name up to its first
/// comma or bracket, then to the shorter name – the more basic food comes
/// first ("Reis gekocht" before "Reis mit Tomatenmark").
///
/// Upper/lower case and umlauts do not matter ("Möhre" = "mohre"), names the
/// BLS writes as two words are found as one word, too ("haferflocken" →
/// "Hafer Flocken"), and a few everyday words find the BLS term ([synonyms]).
class BasicFoodIndex {
  BasicFoodIndex(this.foods);

  /// How many results [search] returns by default.
  static const defaultLimit = 15;

  /// Everyday words the BLS does not use, and the word it uses instead
  /// (folded: lower case, no umlauts). Pasta is "Teigwaren" in the BLS.
  static const synonyms = {
    'nudel': 'teigwaren',
    'nudeln': 'teigwaren',
    'pasta': 'teigwaren',
    'spaghetti': 'teigwaren',
  };

  final List<BasicFood> foods;

  /// The searchable words of every food, per language (built on first use
  /// or by [prepare]).
  final _entries = <String, List<_Entry>>{};

  /// Builds the search words for [languageCode] now instead of at the first
  /// search (takes a moment for ~7,000 foods, so the app does it in the
  /// background while loading).
  void prepare(String languageCode) {
    _entries.putIfAbsent(
      languageCode,
      () => [for (final food in foods) _Entry(food, languageCode)],
    );
  }

  List<BasicFood> search(
    String query, {
    required String languageCode,
    int limit = defaultLimit,
  }) {
    final queryWords = [for (final token in searchTokens(query)) token.text];
    if (queryWords.isEmpty) return const [];

    prepare(languageCode);
    final hits = <({_Entry entry, int score})>[];
    for (final entry in _entries[languageCode]!) {
      var score = 0;
      for (final queryWord in queryWords) {
        final synonym = synonyms[queryWord];
        final wordScore = synonym == null
            ? entry.score(queryWord)
            : max(entry.score(queryWord), entry.score(synonym));
        if (wordScore == 0) {
          score = 0;
          break; // every query word must match
        }
        score += wordScore;
      }
      if (score > 0) hits.add((entry: entry, score: score));
    }

    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      if (a.entry.isRaw != b.entry.isRaw) return a.entry.isRaw ? -1 : 1;
      final byHead = a.entry.headLength.compareTo(b.entry.headLength);
      if (byHead != 0) return byHead;
      final byLength = a.entry.name.length.compareTo(b.entry.name.length);
      if (byLength != 0) return byLength;
      return a.entry.name.compareTo(b.entry.name);
    });
    return [for (final hit in hits.take(limit)) hit.entry.food];
  }
}

// Points for one query word (see BasicFoodIndex). A match in the main part
// of the name adds [_mainPartBonus], so it always beats a match further back.
const _wholeWord = 4;
const _compoundEnd = 3;
const _wordStart = 2;
const _insideWord = 1;
const _mainPartBonus = 4;

/// A food prepared for searching in one language.
class _Entry {
  _Entry(this.food, String languageCode) : name = food.nameFor(languageCode) {
    tokens = searchTokens(name);
    headLength = name.split(RegExp(r',(?!\d)|\(')).first.trim().length;
    // "Hafer Flocken" → "haferflocken": the BLS sometimes writes as two
    // words what everybody types as one.
    pairs = [
      for (var i = 0; i + 1 < tokens.length; i++)
        (
          text: tokens[i].text + tokens[i + 1].text,
          inMainPart: tokens[i].inMainPart,
          isHead: true,
        ),
    ];
    isRaw = tokens.any((token) => token.text == 'roh' || token.text == 'raw');
  }

  final BasicFood food;
  final String name;
  late final List<SearchToken> tokens;
  late final List<SearchToken> pairs;

  /// Length of the name up to the first comma or bracket.
  late final int headLength;
  late final bool isRaw;

  /// 0 when [queryWord] is not in the name, otherwise the points of its best
  /// match.
  int score(String queryWord) {
    var best = 0;
    for (final token in tokens) {
      final text = token.text;
      final kind = !text.contains(queryWord)
          ? 0
          : token.isHead && text == queryWord
          ? _wholeWord
          : token.isHead && text.endsWith(queryWord)
          ? _compoundEnd
          : text.startsWith(queryWord)
          ? _wordStart
          : _insideWord;
      final points = kind > _insideWord && token.inMainPart
          ? kind + _mainPartBonus
          : kind;
      if (points > best) best = points;
    }
    for (final pair in pairs) {
      // Only whole and starting matches: inside a pair of words they would
      // mostly be accidents ("poliert roh" contains "tro").
      final kind = pair.text == queryWord
          ? _wholeWord
          : pair.text.startsWith(queryWord)
          ? _wordStart
          : 0;
      final points = kind > 0 && pair.inMainPart ? kind + _mainPartBonus : kind;
      if (points > best) best = points;
    }
    return best;
  }
}
