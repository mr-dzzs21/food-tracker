// Text helpers shared by the two food searches on the device: the simple
// foods (simple_foods.dart) and the basic foods from the BLS
// (basic_foods.dart). Pure Dart.

/// One searchable word part of a name.
///
/// [inMainPart] is false after the first comma, bracket or linking word like
/// "mit" ("Reis poliert, roh": "roh" is not in the main part), because names
/// say what the food is first and what it is made with later. [isHead] is
/// false for the parts before a hyphen ("apfel" in "Apfel-Streuselkuchen"),
/// which only describe the last part.
typedef SearchToken = ({String text, bool inMainPart, bool isHead});

/// Words that start the description after the main part of a name.
const _linkingWords = {
  'mit', 'ohne', 'in', 'im', 'aus', 'und', 'auf', 'fur', 'zum', 'zur', //
  'with', 'without', 'from', 'and', 'on', 'for', 'made',
};

/// The words of [text] for searching: lower case, umlauts as plain letters
/// ([foldSearchText]), split at spaces, `/` (alternatives like
/// "Weizenbrot/Weißbrot") and `-`.
List<SearchToken> searchTokens(String text) {
  final tokens = <SearchToken>[];
  var inMainPart = true;
  for (final word in foldSearchText(text).split(RegExp(r'\s+'))) {
    if (word.startsWith('(') || _linkingWords.contains(word)) {
      inMainPart = false;
    }
    for (final alternative in word.split('/')) {
      final parts = alternative.split('-');
      for (final (index, part) in parts.indexed) {
        for (final text in part.split(RegExp(r'[^a-z0-9]+'))) {
          if (text.isEmpty) continue;
          tokens.add((
            text: text,
            inMainPart: inMainPart,
            isHead: index == parts.length - 1,
          ));
        }
      }
    }
    // "Reis poliert, roh": the main part ends with the comma.
    if (word.endsWith(',') || word.endsWith(')')) inMainPart = false;
  }
  return tokens;
}

const _folded = {
  'ä': 'a',
  'ö': 'o',
  'ü': 'u',
  'ß': 'ss',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ç': 'c',
  'ñ': 'n',
  'ô': 'o',
  'î': 'i',
  'ï': 'i',
};

/// Lower case, umlauts and accents as plain letters, ß as "ss" – so
/// "Möhre", "mohre" and "MÖHRE" are the same word for the search.
String foldSearchText(String text) {
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    buffer.write(_folded[char] ?? char);
  }
  return buffer.toString();
}
