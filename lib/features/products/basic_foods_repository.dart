import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'basic_foods.dart';

// Loading and searching the basic foods (BLS) bundled with the app. Opening
// one (saving it on the device) is ProductRepository.saveBasicFood, because
// that class owns the Foods table.

/// The bundled BLS file (see assets/data/README.md).
const basicFoodsAsset = 'assets/data/bls_4_0.tsv';

/// Reads the bundled file and builds the search index.
///
/// Parsing about 7,000 lines and preparing the search words takes a moment,
/// so it runs in a background isolate (`compute`) and the UI does not
/// stutter on the first key press.
Future<BasicFoodIndex> loadBundledBasicFoods() async {
  // cache: false – the text is only needed once; the index keeps the data.
  final text = await rootBundle.loadString(basicFoodsAsset, cache: false);
  return compute(_buildIndex, text);
}

BasicFoodIndex _buildIndex(String text) => BasicFoodIndex(parseBasicFoods(text))
  ..prepare('de')
  ..prepare('en');

typedef BasicFoodsLoader = Future<BasicFoodIndex> Function();

/// How the basic foods are loaded. Tests override it with a few foods
/// (`testOverrides(basicFoods: …)` in test/helpers/pump_app.dart).
final basicFoodsLoaderProvider = Provider<BasicFoodsLoader>(
  (ref) => loadBundledBasicFoods,
);

/// All basic foods with their search index. Loaded on first use (the first
/// search) and then kept for as long as the app runs.
final basicFoodsProvider = FutureProvider<BasicFoodIndex>(
  (ref) => ref.watch(basicFoodsLoaderProvider)(),
);

/// Key for [basicFoodSearchProvider]. Use
/// `AppLocalizations.of(context).localeName` as the language.
typedef BasicFoodSearch = ({String query, String languageCode});

/// Basic foods matching a search text, best first (see [BasicFoodIndex]).
///
/// Empty while the foods are still loading. Not a FutureProvider on purpose:
/// once loaded, the results of a new text are there in the same frame, so
/// the list does not flicker while the user types.
final basicFoodSearchProvider = Provider.autoDispose
    .family<List<BasicFood>, BasicFoodSearch>((ref, key) {
      final index = ref.watch(basicFoodsProvider).value;
      if (index == null) return const [];
      return index.search(key.query, languageCode: key.languageCode);
    });
