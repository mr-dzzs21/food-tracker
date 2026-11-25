import 'package:flutter/foundation.dart';

import 'gtin.dart';
import 'nutrients.dart';

// Turns Open Food Facts JSON into plain Dart objects – pure functions, no
// network, no database.
//
// All knowledge about the OFF JSON format lives in this one file, so a later
// move to a newer API version (which changes the nutrition structure) only
// touches this file. Rules: .notes/research/off-api.md, R3–R6 and F5.

/// A product as read from Open Food Facts (API v3.4 or a search hit).
///
/// Holds exactly what the app stores in its `Foods` table.
@immutable
class OffProduct {
  const OffProduct({
    required this.barcode,
    this.name,
    this.brand,
    this.quantityLabel,
    this.isLiquid = false,
    this.servingSize,
    this.servingLabel,
    this.nutrients = Nutrients.unknown,
    this.nutriScore,
    this.novaGroup,
    this.categories = const [],
    this.imageUrl,
    this.completeness,
    this.productType,
  });

  /// Normalised barcode (see [normalizeLikeOff]).
  final String barcode;

  /// Display name in the best available language, or `null` if the product
  /// has no name at all (the UI then shows "Unbekanntes Produkt").
  final String? name;

  /// Brands as one text, for example "Saskia, LIDL".
  final String? brand;

  /// Package size for display, for example "150g".
  final String? quantityLabel;

  /// True for drinks: values are per 100 ml.
  final bool isLiquid;

  /// One portion in g (or ml). `null` when unknown or 0.
  final double? servingSize;

  /// Portion text for display, for example "1 portion (330 ml)".
  final String? servingLabel;

  /// Values per 100 g (or 100 ml).
  final Nutrients nutrients;

  /// "A" … "E", or `null` when OFF has no grade.
  final String? nutriScore;

  /// NOVA group 1–4 (how processed a food is), or `null`.
  final int? novaGroup;

  /// OFF category tags, for example `en:beverages`.
  final List<String> categories;
  final String? imageUrl;

  /// How complete the OFF entry is (0.0 – 1.0).
  final double? completeness;

  /// `food`, `beauty`, `petfood`, … (`null` when OFF did not say).
  final String? productType;
}

/// One page of text-search results.
@immutable
class OffSearchPage {
  const OffSearchPage({
    required this.products,
    required this.count,
    required this.page,
    required this.pageCount,
  });

  static const empty = OffSearchPage(
    products: [],
    count: 0,
    page: 1,
    pageCount: 0,
  );

  final List<OffProduct> products;

  /// Number of matching products in total (all pages).
  final int count;

  /// This page's number, starting at 1.
  final int page;
  final int pageCount;

  /// Whether a "Mehr laden" (load more) button makes sense.
  bool get hasMore => page < pageCount;
}

/// Reads a product object from the OFF product API (`body['product']`) or a
/// search hit.
///
/// [languageCode] is the UI language (`de` or `en`); it decides which name is
/// picked. [requestedCode] is used when the JSON has no `code` field.
OffProduct parseOffProduct(
  Map<String, Object?> json, {
  required String languageCode,
  String? requestedCode,
}) {
  final categories = _readTextList(json['categories_tags']);
  final code = _readText(json['code']) ?? requestedCode ?? '';
  final nutriScoreData = _readMap(json['nutriscore_data']);
  final isLiquid =
      categories.contains('en:beverages') ||
      _readText(json['product_quantity_unit'])?.toLowerCase() == 'ml' ||
      _readText(json['serving_quantity_unit'])?.toLowerCase() == 'ml' ||
      // Search hits only have this hint (1 = drink).
      _readNum(nutriScoreData['is_beverage']) == 1;
  final servingSize = _readNum(json['serving_quantity']);

  return OffProduct(
    barcode: normalizeLikeOff(code),
    name: _pickName(json, languageCode),
    brand: _readBrands(json['brands']),
    quantityLabel: _readText(json['quantity']),
    isLiquid: isLiquid,
    servingSize: (servingSize != null && servingSize > 0) ? servingSize : null,
    servingLabel: _readText(json['serving_size']),
    nutrients: _readNutrients(
      json['nutriments'],
      categories,
      nutriScoreData: nutriScoreData,
    ),
    nutriScore: _readNutriScore(json['nutriscore_grade']),
    novaGroup: _readNovaGroup(json['nova_group']),
    categories: categories,
    imageUrl:
        _readText(json['image_front_small_url']) ??
        _readText(json['image_front_thumb_url']),
    completeness: _readNum(json['completeness']),
    productType: _readText(json['product_type']),
  );
}

/// Reads a response of search.openfoodfacts.org. Hits without a barcode are
/// skipped.
OffSearchPage parseOffSearchPage(
  Map<String, Object?> json, {
  required String languageCode,
}) {
  final hits = json['hits'];
  final products = <OffProduct>[
    if (hits is List)
      for (final hit in hits)
        if (hit is Map<String, Object?> && _readText(hit['code']) != null)
          parseOffProduct(hit, languageCode: languageCode),
  ];
  return OffSearchPage(
    products: products,
    count: _readNum(json['count'])?.toInt() ?? products.length,
    page: _readNum(json['page'])?.toInt() ?? 1,
    pageCount: _readNum(json['page_count'])?.toInt() ?? 1,
  );
}

// ---------------------------------------------------------------------------
// Small readers. OFF usually sends numbers as JSON numbers, but some APIs send
// them as text ("0.9"), so every number is read defensively.

Map<String, Object?> _readMap(Object? value) =>
    value is Map<String, Object?> ? value : const {};

double? _readNum(Object? value) => switch (value) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s.trim().replaceAll(',', '.')),
  _ => null,
};

/// Text without surrounding spaces; empty text counts as missing.
String? _readText(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty ? null : text;
}

List<String> _readTextList(Object? value) => [
  if (value is List)
    // `?` leaves out items that are not text (or empty).
    for (final item in value) ?_readText(item),
];

/// The product API sends brands as one text, the search API as a list of
/// tags like "xx:Spielberger Mühle" or "xx:k-classic" (since 2026-11; "xx:"
/// = no language). The prefix is not shown.
String? _readBrands(Object? value) {
  if (value is List) {
    final brands = [
      for (final brand in _readTextList(value))
        ?_readText(brand.replaceFirst(_tagLanguage, '')),
    ];
    return brands.isEmpty ? null : brands.join(', ');
  }
  return _readText(value);
}

/// The language part of an OFF tag: "xx:", "en:", "de:".
final _tagLanguage = RegExp(r'^[a-z]{2}:');

/// Name fallback order from the brief (R3). OFF overwrites `product_name`
/// with the name in the product's *main* language, so the name in the UI
/// language (`product_name_de` / `_en`) must be asked for first.
String? _pickName(Map<String, Object?> json, String languageCode) =>
    _readText(json['product_name_$languageCode']) ??
    _readText(json['product_name']) ??
    _readText(json['product_name_en']) ??
    _readText(json['generic_name_$languageCode']) ??
    _readText(json['generic_name']) ??
    _readText(json['abbreviated_product_name']);

String? _readNutriScore(Object? value) {
  final grade = _readText(value)?.toLowerCase();
  // OFF also sends "unknown" and "not-applicable": no grade to show.
  return const ['a', 'b', 'c', 'd', 'e'].contains(grade)
      ? grade!.toUpperCase()
      : null;
}

int? _readNovaGroup(Object? value) {
  final group = _readNum(value);
  if (group == null || group != group.roundToDouble()) return null;
  return group >= 1 && group <= 4 ? group.toInt() : null;
}

/// 1 kcal = 4.184 kJ (thermochemical calorie, the usual nutrition factor).
const _kjPerKcal = 4.184;

/// Salt = sodium × 2.5 (EU Regulation 1169/2011, Annex I).
const _saltPerSodium = 2.5;

/// Waters with added sugar or vitamins may have calories, so the
/// "plain water has 0 kcal" rule must not apply to them.
const _waterExceptions = ['en:flavored-waters', 'en:vitamin-waters'];

/// Reads `nutriments`. [nutriScoreData] is only used for the calories of
/// search hits: since 2026-11 the search service no longer sends
/// `nutriments`, but still the energy the Nutri-Score was computed from.
Nutrients _readNutrients(
  Object? value,
  List<String> categories, {
  Map<String, Object?> nutriScoreData = const {},
}) {
  final n = _readMap(value);
  double? grams(String key) => _gramsOrNull(_readNum(n['${key}_100g']));

  // Calories: the label value, else converted from kJ, else from the
  // Nutri-Score data.
  var kcal =
      _kcalOrNull(_readNum(n['energy-kcal_100g'])) ??
      _kcalOrNull(_divide(_readNum(n['energy-kj_100g']), _kjPerKcal)) ??
      _kcalFromNutriScoreData(nutriScoreData);
  // Plain water often has no energy value at all, but surely 0 kcal.
  final isPlainWater =
      categories.contains('en:waters') &&
      !categories.any(_waterExceptions.contains);
  if (kcal == null && isPlainWater) kcal = 0;

  return Nutrients(
    kcal: kcal,
    fat: grams('fat'),
    saturatedFat: grams('saturated-fat'),
    carbs: grams('carbohydrates'),
    sugars: grams('sugars'),
    fibre: grams('fiber'),
    protein: grams('proteins'),
    salt:
        grams('salt') ??
        _gramsOrNull(_multiply(_readNum(n['sodium_100g']), _saltPerSodium)),
  );
}

/// The energy component of `nutriscore_data` (per 100 g/ml) in kcal, or
/// `null` when it is missing or impossible. Example of the JSON:
/// `{"components": {"negative": [{"id": "energy", "value": 2252, "unit": "kJ"}]}}`.
/// Fats, oils, nuts and seeds have "energy_from_saturated_fat" instead –
/// that is not the total energy, so those stay unknown.
double? _kcalFromNutriScoreData(Map<String, Object?> data) {
  final components = _readMap(data['components'])['negative'];
  if (components is! List) return null;
  for (final component in components) {
    if (component is! Map<String, Object?> || component['id'] != 'energy') {
      continue;
    }
    final value = _readNum(component['value']);
    final unit = _readText(component['unit'])?.toLowerCase();
    return _kcalOrNull(switch (unit) {
      'kj' => _divide(value, _kjPerKcal),
      'kcal' => value,
      _ => null,
    });
  }
  return null;
}

double? _divide(double? value, double by) => value == null ? null : value / by;

double? _multiply(double? value, double by) =>
    value == null ? null : value * by;

/// More than 100 g of something in 100 g is impossible: treat it as unknown.
double? _gramsOrNull(double? value) =>
    (value == null || value.isNaN || value < 0 || value > 100) ? null : value;

/// More than 900 kcal per 100 g (pure fat) is impossible.
double? _kcalOrNull(double? value) =>
    (value == null || value.isNaN || value < 0 || value > 900) ? null : value;
