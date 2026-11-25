import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'simple_foods.dart';

// Loading and searching the simple foods bundled with the app. Opening one
// (saving it on the device) is ProductRepository.saveSimpleFood, because that
// class owns the Foods table.

/// The bundled files, one per licence (see assets/data/README.md).
const simpleFoodsAssets = [
  'assets/data/simple_foods_bls.tsv',
  'assets/data/simple_foods_off.tsv',
];

/// Reads both bundled files. About 400 short lines – fast enough for the UI
/// thread, no background isolate needed (unlike the 7,000 BLS foods).
Future<SimpleFoodIndex> loadBundledSimpleFoods() async {
  final foods = <SimpleFood>[
    for (final asset in simpleFoodsAssets)
      ...parseSimpleFoods(await rootBundle.loadString(asset, cache: false)),
  ];
  return SimpleFoodIndex(foods);
}

typedef SimpleFoodsLoader = Future<SimpleFoodIndex> Function();

/// How the simple foods are loaded. Tests override it with a few foods
/// (`testOverrides(simpleFoods: …)` in test/helpers/pump_app.dart).
final simpleFoodsLoaderProvider = Provider<SimpleFoodsLoader>(
  (ref) => loadBundledSimpleFoods,
);

/// All simple foods with their search index. Loaded on first use and then
/// kept for as long as the app runs.
final simpleFoodsProvider = FutureProvider<SimpleFoodIndex>(
  (ref) => ref.watch(simpleFoodsLoaderProvider)(),
);

/// Key for [simpleFoodSearchProvider]. Use
/// `AppLocalizations.of(context).localeName` as the language.
typedef SimpleFoodSearch = ({String query, String languageCode});

/// Simple foods matching a search text, best first (see [SimpleFoodIndex]).
///
/// Empty while the foods are still loading. Not a FutureProvider on purpose:
/// once loaded, the results of a new text are there in the same frame, so
/// the list does not flicker while the user types.
final simpleFoodSearchProvider = Provider.autoDispose
    .family<List<SimpleFood>, SimpleFoodSearch>((ref, key) {
      final index = ref.watch(simpleFoodsProvider).value;
      if (index == null) return const [];
      return index.search(key.query, languageCode: key.languageCode);
    });
