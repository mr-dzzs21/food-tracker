import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../data/database.dart';
import 'basic_foods.dart';
import 'food_source.dart';
import 'gtin.dart';
import 'nutrients.dart';
import 'off_client.dart';
import 'off_product_mapper.dart';
import 'simple_foods.dart';

/// All access to foods: products from Open Food Facts (cached on the device),
/// simple foods and basic foods (bundled, stored once opened) and the user's
/// own foods.
/// The UI never touches the `Foods` table directly.
class ProductRepository {
  ProductRepository(this._db, this._client, this._clock);

  /// Cached products older than this are refreshed when they are opened.
  static const cacheMaxAge = Duration(days: 30);

  /// A cached product without calories is asked for again after this time,
  /// while the user waits: someone may have added them at Open Food Facts.
  static const incompleteMaxAge = Duration(days: 1);

  /// Length of the "Zuletzt gegessen" and "Zuletzt angesehen" lists.
  static const recentLimit = 20;

  final AppDatabase _db;
  final OpenFoodFactsClient _client;
  final Clock _clock;

  // ---------------------------------------------------------------------------
  // Barcode lookup and online search

  /// The food with this [barcode]: from the device if possible, otherwise
  /// from Open Food Facts (then stored on the device).
  ///
  /// - Stored less than [cacheMaxAge] ago (or an own food): returned at once.
  /// - Older: returned at once, and refreshed in the background. A failed
  ///   refresh is ignored – old data is better than an error.
  /// - Stored without calories more than [incompleteMaxAge] ago: downloaded
  ///   again (the user waits).
  /// - Unknown: downloaded and stored.
  ///
  /// A scanned or typed [barcode] is checked like on the package
  /// ([lookupCodeFor]). With [trusted] – a code from Open Food Facts itself,
  /// for example a search hit – it is only normalised ([trustedLookupCode]).
  ///
  /// Throws [InvalidBarcode], the failures of [OpenFoodFactsClient.lookup],
  /// and [IncompleteProduct] when the calories are unknown. Such a product is
  /// still stored, so the form can be prefilled ([getFoodByBarcode]).
  Future<Food> lookupBarcode(
    String barcode, {
    String languageCode = 'de',
    bool trusted = false,
  }) async {
    final code = trusted ? trustedLookupCode(barcode) : lookupCodeFor(barcode);
    if (code == null) throw InvalidBarcode(barcode);

    final cached = await _foodByCode(code);
    if (cached != null) {
      if (_isIncompleteForLong(cached)) {
        return _downloadAgain(code, languageCode);
      }
      if (_isStale(cached)) {
        unawaited(_refreshInBackground(code, languageCode));
      }
      return _requireKcal(cached, code);
    }

    // The code is checked (or trusted) above, so the client must not apply
    // the scanner rules a second time.
    final product = await _client.lookup(
      code,
      languageCode: languageCode,
      trusted: true,
    );
    return _requireKcal(await _saveOffProduct(product), code);
  }

  /// Text search at Open Food Facts (online only; see
  /// [OpenFoodFactsClient.search], also for [cancel]).
  Future<OffSearchPage> search(
    String query, {
    int page = 1,
    String languageCode = 'de',
    Future<void>? cancel,
  }) {
    return _client.search(
      query,
      page: page,
      languageCode: languageCode,
      cancel: cancel,
    );
  }

  bool _isStale(Food food) {
    if (food.source == FoodSource.user) return false; // never overwritten
    final fetchedAt = food.fetchedAt;
    return fetchedAt == null ||
        _clock.now().difference(fetchedAt) >= cacheMaxAge;
  }

  /// An Open Food Facts product stored without calories, checked more than
  /// [incompleteMaxAge] ago.
  bool _isIncompleteForLong(Food food) {
    if (food.source != FoodSource.openFoodFacts || food.kcal != null) {
      return false;
    }
    final fetchedAt = food.fetchedAt;
    return fetchedAt == null ||
        _clock.now().difference(fetchedAt) >= incompleteMaxAge;
  }

  Food _requireKcal(Food food, String code) {
    if (food.kcal == null) throw IncompleteProduct(code);
    return food;
  }

  /// Downloads a product that was stored without calories once more. Still
  /// without calories or no answer (offline, …): [IncompleteProduct] as
  /// before, so the user can still fill in the values.
  Future<Food> _downloadAgain(String code, String languageCode) async {
    final OffProduct product;
    try {
      product = await _client.lookup(
        code,
        languageCode: languageCode,
        trusted: true,
      );
    } on AppFailure {
      throw IncompleteProduct(code);
    }
    return _requireKcal(await _saveOffProduct(product), code);
  }

  Future<void> _refreshInBackground(String code, String languageCode) async {
    try {
      // No automatic retry: nobody is waiting for this request. The code is
      // a stored one, so it is not checked again.
      final product = await _client.lookup(
        code,
        languageCode: languageCode,
        retry: false,
        trusted: true,
      );
      await _saveOffProduct(product);
    } on Object catch (error) {
      // Offline, rate limited, removed from OFF, an unexpected answer …: keep
      // the cached data. Nobody waits for this future, so nothing may escape
      // from it (it would be an uncaught error).
      debugPrint('Background refresh of $code failed: $error');
    }
  }

  /// Inserts or updates a downloaded product, keyed by its barcode.
  ///
  /// Keeps what belongs to the user (favourite, recently used/viewed) and
  /// never overwrites an own food with the same barcode.
  Future<Food> _saveOffProduct(OffProduct product) {
    return _db.transaction(() async {
      final existing = await _foodByCode(product.barcode);
      if (existing != null && existing.source == FoodSource.user) {
        return existing;
      }

      final nutrients = product.nutrients;
      final data = FoodsCompanion(
        source: const Value(FoodSource.openFoodFacts),
        barcode: Value(product.barcode),
        // Foods.name is required; '' means "no name" and the UI shows
        // "Unbekanntes Produkt" (l10n key productUnknownName).
        name: Value(product.name ?? ''),
        brand: Value(product.brand),
        quantityLabel: Value(product.quantityLabel),
        isLiquid: Value(product.isLiquid),
        servingSize: Value(product.servingSize),
        servingLabel: Value(product.servingLabel),
        kcal: Value(nutrients.kcal),
        fat: Value(nutrients.fat),
        saturatedFat: Value(nutrients.saturatedFat),
        carbs: Value(nutrients.carbs),
        sugars: Value(nutrients.sugars),
        fibre: Value(nutrients.fibre),
        protein: Value(nutrients.protein),
        salt: Value(nutrients.salt),
        nutriScore: Value(product.nutriScore),
        novaGroup: Value(product.novaGroup),
        categories: Value(
          product.categories.isEmpty ? null : product.categories.join(','),
        ),
        imageUrl: Value(product.imageUrl),
        completeness: Value(product.completeness),
        fetchedAt: Value(_clock.now()),
      );

      if (existing == null) {
        return _db
            .into(_db.foods)
            .insertReturning(data.copyWith(createdAt: Value(_clock.now())));
      }
      final updated = await (_db.update(
        _db.foods,
      )..where((f) => f.id.equals(existing.id))).writeReturning(data);
      return updated.single;
    });
  }

  // ---------------------------------------------------------------------------
  // Reading stored foods

  Future<Food?> getFood(int id) =>
      (_db.select(_db.foods)..where((f) => f.id.equals(id))).getSingleOrNull();

  /// The stored food with this barcode (any spelling, for example with or
  /// without leading zeros), or `null`.
  ///
  /// First the code as Open Food Facts stores it (a search hit can have a
  /// code the scanner rules refuse, see [trustedLookupCode]), then by the
  /// scanner rules ([lookupCodeFor]).
  Future<Food?> getFoodByBarcode(String barcode) async {
    final stored = trustedLookupCode(barcode);
    final food = stored == null ? null : await _foodByCode(stored);
    if (food != null) return food;
    final code = lookupCodeFor(barcode);
    return code == null ? null : _foodByCode(code);
  }

  Future<Food?> _foodByCode(String code) => (_db.select(
    _db.foods,
  )..where((f) => f.barcode.equals(code))).getSingleOrNull();

  /// The food with this [id]; emits again whenever it changes, and `null`
  /// after it was deleted.
  Stream<Food?> watchFood(int id) => (_db.select(
    _db.foods,
  )..where((f) => f.id.equals(id))).watchSingleOrNull();

  /// Own and cached foods whose name or brand contains every word of
  /// [query], ignoring upper/lower case. Favourites come first.
  ///
  /// Simple foods and basic foods (BLS) are left out: the search shows them
  /// in their own section ("Lebensmittel"), which finds them better.
  ///
  /// Filtered in Dart instead of with SQL `LIKE`, because SQLite's `LIKE`
  /// ignores case only for A–Z, not for umlauts ("Müsli" vs "müsli"). The
  /// table only holds foods this user has seen, so this stays fast.
  Future<List<Food>> searchLocal(String query, {int limit = 50}) async {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];

    final foods =
        await (_db.select(_db.foods)..orderBy([
              (f) => OrderingTerm.desc(f.isFavourite),
              (f) => OrderingTerm.asc(f.name.collate(Collate.noCase)),
            ]))
            .get();
    return foods
        .where((food) {
          if (food.source.isBundled) return false;
          final text = '${food.name} ${food.brand ?? ''}'.toLowerCase();
          return words.every(text.contains);
        })
        .take(limit)
        .toList();
  }

  /// "Zuletzt gegessen": foods added to the diary, newest first.
  Stream<List<Food>> watchRecentlyUsed({int limit = recentLimit}) =>
      (_db.select(_db.foods)
            ..where((f) => f.lastUsedAt.isNotNull())
            ..orderBy([(f) => OrderingTerm.desc(f.lastUsedAt)])
            ..limit(limit))
          .watch();

  /// "Zuletzt angesehen": product pages opened, newest first.
  Stream<List<Food>> watchRecentlyViewed({int limit = recentLimit}) =>
      (_db.select(_db.foods)
            ..where((f) => f.lastViewedAt.isNotNull())
            ..orderBy([(f) => OrderingTerm.desc(f.lastViewedAt)])
            ..limit(limit))
          .watch();

  /// Favourites, sorted by name.
  Stream<List<Food>> watchFavourites() =>
      (_db.select(_db.foods)
            ..where((f) => f.isFavourite.equals(true))
            ..orderBy([
              (f) => OrderingTerm.asc(f.name.collate(Collate.noCase)),
            ]))
          .watch();

  /// The user's own foods, sorted by name.
  Stream<List<Food>> watchOwnFoods() =>
      (_db.select(_db.foods)
            ..where((f) => f.source.equalsValue(FoodSource.user))
            ..orderBy([
              (f) => OrderingTerm.asc(f.name.collate(Collate.noCase)),
            ]))
          .watch();

  // ---------------------------------------------------------------------------
  // Changing stored foods

  /// Turns the favourite star on or off.
  Future<void> toggleFavourite(int id) {
    return (_db.update(_db.foods)..where((f) => f.id.equals(id))).write(
      // Flip the value inside SQLite, so no read is needed first.
      FoodsCompanion.custom(isFavourite: _db.foods.isFavourite.not()),
    );
  }

  /// Remembers that the product page was opened ("Zuletzt angesehen").
  Future<void> markViewed(int id) =>
      _setTimestamp(id, FoodsCompanion(lastViewedAt: Value(_clock.now())));

  /// Remembers that the food was added to the diary ("Zuletzt gegessen").
  Future<void> markUsed(int id) =>
      _setTimestamp(id, FoodsCompanion(lastUsedAt: Value(_clock.now())));

  Future<void> _setTimestamp(int id, FoodsCompanion data) =>
      (_db.update(_db.foods)..where((f) => f.id.equals(id))).write(data);

  /// Creates (no [id]) or updates an own food and returns its id.
  ///
  /// [nutrients] are per 100 g (or 100 ml when [isLiquid]). A [barcode] is
  /// checked and normalised ([InvalidBarcode] if wrong) – unless a product
  /// with this code is already stored (for example an incomplete OFF product
  /// the user now completes, maybe from a search hit with an unusual code):
  /// then that row becomes the own food, so favourites and recents stay and
  /// the barcode is not stored twice.
  Future<int> saveOwnFood({
    int? id,
    required String name,
    String? brand,
    String? barcode,
    bool isLiquid = false,
    double? servingSize,
    String? servingLabel,
    required Nutrients nutrients,
  }) async {
    String? code;
    if (barcode != null && barcode.trim().isNotEmpty) {
      code =
          (await getFoodByBarcode(barcode))?.barcode ?? lookupCodeFor(barcode);
      if (code == null) throw InvalidBarcode(barcode);
    }

    final data = FoodsCompanion(
      source: const Value(FoodSource.user),
      barcode: Value(code),
      name: Value(name.trim()),
      brand: Value(_textOrNull(brand)),
      isLiquid: Value(isLiquid),
      servingSize: Value(servingSize),
      servingLabel: Value(_textOrNull(servingLabel)),
      kcal: Value(nutrients.kcal),
      fat: Value(nutrients.fat),
      saturatedFat: Value(nutrients.saturatedFat),
      carbs: Value(nutrients.carbs),
      sugars: Value(nutrients.sugars),
      fibre: Value(nutrients.fibre),
      protein: Value(nutrients.protein),
      salt: Value(nutrients.salt),
      // Data that only Open Food Facts provides no longer fits the user's
      // values (a Nutri-Score for other nutrients would be wrong).
      quantityLabel: const Value(null),
      nutriScore: const Value(null),
      novaGroup: const Value(null),
      categories: const Value(null),
      imageUrl: const Value(null),
      completeness: const Value(null),
      fetchedAt: const Value(null),
    );

    return _db.transaction(() async {
      final targetId =
          id ?? (code == null ? null : (await _foodByCode(code))?.id);
      if (targetId != null) {
        await (_db.update(
          _db.foods,
        )..where((f) => f.id.equals(targetId))).write(data);
        return targetId;
      }
      return _db
          .into(_db.foods)
          .insert(data.copyWith(createdAt: Value(_clock.now())));
    });
  }

  /// Stores a basic food from the BLS on the device (or updates it) and
  /// returns its id, so the product page, favourites, "Zuletzt gegessen" and
  /// the diary work exactly as for any other food.
  ///
  /// Called when the user opens the food. The name is taken in the UI
  /// language ([languageCode]); the values are written again each time, so
  /// a newer BLS version in an app update reaches stored foods, too.
  /// Favourite and "recently used/viewed" stay as they are.
  Future<int> saveBasicFood(BasicFood food, {required String languageCode}) {
    final nutrients = food.nutrients;
    final data = FoodsCompanion(
      source: const Value(FoodSource.bls),
      externalId: Value(food.code),
      name: Value(food.nameFor(languageCode)),
      isLiquid: Value(food.isLiquid),
      kcal: Value(nutrients.kcal),
      fat: Value(nutrients.fat),
      saturatedFat: Value(nutrients.saturatedFat),
      carbs: Value(nutrients.carbs),
      sugars: Value(nutrients.sugars),
      fibre: Value(nutrients.fibre),
      protein: Value(nutrients.protein),
      salt: Value(nutrients.salt),
      // Only set for kinds of food without a traffic light (water, spices,
      // …); see health_rating.dart.
      categories: Value(food.category),
    );
    return _upsertBundledFood(FoodSource.bls, food.code, data);
  }

  /// Stores a simple food ("Skyr natur") on the device (or updates it) and
  /// returns its id – like [saveBasicFood], with the short name and the
  /// typical portion in the UI language ([languageCode]).
  ///
  /// Stored with the key of the list: [FoodSource.simpleBls] for BLS values,
  /// [FoodSource.offAverage] for the Open Food Facts medians. Never in the
  /// row of the BLS food with the same values – otherwise name, portion and
  /// "Zuletzt" amount would change with the list the food was opened from.
  Future<int> saveSimpleFood(SimpleFood food, {required String languageCode}) {
    final nutrients = food.nutrients;
    final portion = food.portionGrams;
    final data = FoodsCompanion(
      source: Value(food.source),
      externalId: Value(food.externalId),
      name: Value(food.nameFor(languageCode)),
      isLiquid: Value(food.isLiquid),
      servingSize: Value(portion),
      servingLabel: Value(
        portion == null ? null : food.portionFor(languageCode),
      ),
      kcal: Value(nutrients.kcal),
      fat: Value(nutrients.fat),
      saturatedFat: Value(nutrients.saturatedFat),
      carbs: Value(nutrients.carbs),
      sugars: Value(nutrients.sugars),
      fibre: Value(nutrients.fibre),
      protein: Value(nutrients.protein),
      salt: Value(nutrients.salt),
      categories: Value(food.category),
    );
    return _upsertBundledFood(food.source, food.externalId, data);
  }

  /// Inserts or updates the food bundled with the app that is stored as
  /// ([source], [externalId]); favourite and recents stay as they are.
  Future<int> _upsertBundledFood(
    FoodSource source,
    String externalId,
    FoodsCompanion data,
  ) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.foods)..where(
                (f) =>
                    f.source.equalsValue(source) &
                    f.externalId.equals(externalId),
              ))
              .getSingleOrNull();
      if (existing == null) {
        return _db
            .into(_db.foods)
            .insert(data.copyWith(createdAt: Value(_clock.now())));
      }
      await (_db.update(
        _db.foods,
      )..where((f) => f.id.equals(existing.id))).write(data);
      return existing.id;
    });
  }

  /// Deletes an own food. Diary entries keep their copy of name and values
  /// (their link to the food becomes NULL). Cached OFF products are not
  /// deleted by this method.
  Future<void> deleteOwnFood(int id) {
    return (_db.delete(_db.foods)..where(
          (f) => f.id.equals(id) & f.source.equalsValue(FoodSource.user),
        ))
        .go();
  }

  static String? _textOrNull(String? text) {
    final trimmed = text?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

// -----------------------------------------------------------------------------
// Providers

/// The Open Food Facts client. One instance for the whole app, so the
/// "wait a minute after too many requests" rule covers every screen.
final offClientProvider = Provider<OpenFoodFactsClient>((ref) {
  final version = ref.watch(appVersionProvider);
  return OpenFoodFactsClient(
    ref.watch(httpClientProvider),
    userAgent: 'FoodTracker/$version ($repositoryUrl)',
    clock: ref.watch(clockProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.watch(databaseProvider),
    ref.watch(offClientProvider),
    ref.watch(clockProvider),
  );
});

/// Key for [barcodeLookupProvider]. Use
/// `AppLocalizations.of(context).localeName` as the language. [trusted]: the
/// code comes from Open Food Facts itself (a search hit), see
/// [ProductRepository.lookupBarcode].
typedef BarcodeLookup = ({String barcode, String languageCode, bool trusted});

/// A product by barcode (cache first). Errors are [AppFailure]s.
final barcodeLookupProvider = FutureProvider.autoDispose
    .family<Food, BarcodeLookup>((ref, key) {
      return ref
          .watch(productRepositoryProvider)
          .lookupBarcode(
            key.barcode,
            languageCode: key.languageCode,
            trusted: key.trusted,
          );
    });

/// Key for [productSearchProvider]; [page] starts at 1.
typedef ProductSearch = ({String query, int page, String languageCode});

/// One page of Open Food Facts search results.
///
/// When no screen shows these results any more (the user typed on, so the
/// screen asks for another text), the search is cancelled: not sent if it
/// still waits for its turn, aborted if it runs.
final productSearchProvider = FutureProvider.autoDispose
    .family<OffSearchPage, ProductSearch>((ref, key) {
      final cancel = Completer<void>();
      ref.onDispose(cancel.complete);
      return ref
          .watch(productRepositoryProvider)
          .search(
            key.query,
            page: key.page,
            languageCode: key.languageCode,
            cancel: cancel.future,
          );
    });

/// Own and cached foods matching a text (no internet needed).
final localFoodSearchProvider = FutureProvider.autoDispose
    .family<List<Food>, String>((ref, query) {
      return ref.watch(productRepositoryProvider).searchLocal(query);
    });

/// One stored food by id; `null` when it does not exist (any more).
final foodProvider = StreamProvider.autoDispose.family<Food?, int>((ref, id) {
  return ref.watch(productRepositoryProvider).watchFood(id);
});

final recentlyUsedFoodsProvider = StreamProvider.autoDispose<List<Food>>(
  (ref) => ref.watch(productRepositoryProvider).watchRecentlyUsed(),
);

final recentlyViewedFoodsProvider = StreamProvider.autoDispose<List<Food>>(
  (ref) => ref.watch(productRepositoryProvider).watchRecentlyViewed(),
);

final favouriteFoodsProvider = StreamProvider.autoDispose<List<Food>>(
  (ref) => ref.watch(productRepositoryProvider).watchFavourites(),
);

final ownFoodsProvider = StreamProvider.autoDispose<List<Food>>(
  (ref) => ref.watch(productRepositoryProvider).watchOwnFoods(),
);
