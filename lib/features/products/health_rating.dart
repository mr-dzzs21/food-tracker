import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/database.dart';
import 'food_source.dart';
import 'nutrients.dart';

// The per-nutrient "traffic light" of the product page – pure logic.
//
// Thresholds: UK front-of-pack guidance (Department of Health / FSA, 2016,
// Annex 3), per 100 g for foods and per 100 ml for drinks. There is no
// overall score on purpose: each nutrient is shown on its own, always with an
// icon and a word, never only with a colour.
//
// Rules R1–R7: .notes/research/health-nutrition.md

/// The four nutrients that get a level.
enum RatedNutrient {
  fat(Nutrient.fat),
  saturatedFat(Nutrient.saturatedFat),
  sugars(Nutrient.sugars),
  salt(Nutrient.salt);

  const RatedNutrient(this.nutrient);

  /// The same nutrient in [Nutrients].
  final Nutrient nutrient;
}

/// "niedrig", "mittel", "hoch". `null` in a result means "keine Angabe".
enum Level { low, medium, high }

/// Which thresholds were used: per 100 g (food) or per 100 ml (drink).
enum RatingBasis { food, drink }

enum PlusPointNutrient { fibre, protein }

/// "Quelle" (source of) or "hoher Gehalt" (high in), as defined in
/// EU Regulation 1924/2006.
enum PlusPointStrength { source, high }

/// Something positive about a product, for example "high in fibre".
@immutable
class PlusPoint {
  const PlusPoint(this.nutrient, this.strength, this.value);

  final PlusPointNutrient nutrient;
  final PlusPointStrength strength;

  /// Grams per 100 g (or 100 ml), for the text "Ballaststoffe 10 g".
  final double value;

  @override
  bool operator ==(Object other) =>
      other is PlusPoint &&
      other.nutrient == nutrient &&
      other.strength == strength &&
      other.value == value;

  @override
  int get hashCode => Object.hash(nutrient, strength, value);

  @override
  String toString() => 'PlusPoint(${nutrient.name}, ${strength.name}, $value)';
}

/// Why a product gets no traffic light.
enum NotRatedReason {
  /// No category at Open Food Facts, so food vs drink (and whether a rating
  /// makes sense at all) is unknown.
  unknownType,

  /// Water, coffee, tea, spices, baby food, alcohol, … – the traffic light is
  /// not meant for these.
  excludedType,
}

/// The result of [rateProduct]: either [NotRated] or [Rated].
sealed class RatingResult {
  const RatingResult();
}

class NotRated extends RatingResult {
  const NotRated(this.reason, {this.category});

  final NotRatedReason reason;

  /// The category tag that excluded the product, for example `en:waters`.
  final String? category;

  @override
  String toString() => 'NotRated(${reason.name}, $category)';
}

class Rated extends RatingResult {
  const Rated({
    required this.basis,
    required this.levels,
    required this.plusPoints,
    required this.suspicious,
  });

  final RatingBasis basis;

  /// A level for every [RatedNutrient]; `null` = "keine Angabe" (unknown).
  final Map<RatedNutrient, Level?> levels;
  final List<PlusPoint> plusPoints;

  /// True when the values contradict each other: show the hint
  /// "Diese Angaben wirken unstimmig".
  final bool suspicious;

  @override
  String toString() =>
      'Rated(${basis.name}, $levels, $plusPoints, suspicious: $suspicious)';
}

/// Upper limits of LOW and MEDIUM. Both limits belong to the lower level:
/// exactly 3.0 g fat is still LOW.
@immutable
class LevelBounds {
  const LevelBounds(this.lowMax, this.mediumMax);

  /// LOW if value ≤ lowMax.
  final double lowMax;

  /// MEDIUM if lowMax < value ≤ mediumMax, otherwise HIGH.
  final double mediumMax;
}

/// Per 100 g of food (UK FoP 2016, Annex 3, Table 2).
const foodBounds = {
  RatedNutrient.fat: LevelBounds(3.0, 17.5),
  RatedNutrient.saturatedFat: LevelBounds(1.5, 5.0),
  RatedNutrient.sugars: LevelBounds(5.0, 22.5),
  RatedNutrient.salt: LevelBounds(0.3, 1.5),
};

/// Per 100 ml of a drink (UK FoP 2016, Annex 3, Table 3).
const drinkBounds = {
  RatedNutrient.fat: LevelBounds(1.5, 8.75),
  RatedNutrient.saturatedFat: LevelBounds(0.75, 2.5),
  RatedNutrient.sugars: LevelBounds(2.5, 11.25),
  RatedNutrient.salt: LevelBounds(0.3, 0.75),
};

/// Open Food Facts categories that get no traffic light.
///
/// `en:sweeteners` is missing on purpose: it also contains sugar and honey,
/// which should be rated. Only sugar *substitutes* are excluded.
const notRatedCategories = [
  'en:waters',
  'en:alcoholic-beverages',
  'en:baby-foods',
  'en:baby-milks',
  'en:dietary-supplements',
  'en:sugar-substitutes',
  'en:food-additives',
  'en:salts',
  'en:herbs',
  'en:spices',
  'en:vinegars',
  'en:coffees',
  'en:teas',
  'en:herbal-teas',
  'en:meal-replacements',
  'en:chewing-gums',
  'en:non-food-products',
];

/// Categories that are rated even though a parent category is in
/// [notRatedCategories] (flavoured water and iced coffee can contain sugar).
const ratedExceptions = [
  'en:flavored-waters',
  'en:vitamin-waters',
  'en:coffee-drinks',
  'en:tea-based-beverages',
  'en:herbal-tea-beverages',
];

/// Powders like instant soup: their values are for the dry powder, not for
/// what you eat, so a traffic light would mislead.
const _toBeRehydrated = 'en:dried-products-to-be-rehydrated';

/// Rates a food.
///
/// - Open Food Facts products ([source] `openFoodFacts`) use their
///   [categories]: drink thresholds for `en:beverages`, food thresholds
///   otherwise; no categories → [NotRated] (unknown type).
/// - Own foods and basic foods (BLS) have no Open Food Facts categories:
///   food thresholds, or drink thresholds when [isLiquid]. A basic food of a
///   kind without a traffic light (water, coffee, spices, alcohol, …) carries
///   the matching category tag (tool/bls/README.md) and is not rated.
RatingResult rateProduct({
  required Nutrients nutrients,
  required List<String> categories,
  required FoodSource source,
  required bool isLiquid,
}) {
  final RatingBasis basis;
  switch (source) {
    case FoodSource.openFoodFacts:
      final notRated = _notRatedReason(categories);
      if (notRated != null) return notRated;
      basis = categories.contains('en:beverages')
          ? RatingBasis.drink
          : RatingBasis.food;
    case FoodSource.user || FoodSource.bls:
      if (categories.isNotEmpty) {
        final notRated = _notRatedReason(categories);
        if (notRated != null) return notRated;
      }
      basis = isLiquid ? RatingBasis.drink : RatingBasis.food;
  }

  final bounds = basis == RatingBasis.drink ? drinkBounds : foodBounds;
  return Rated(
    basis: basis,
    levels: {
      for (final rated in RatedNutrient.values)
        rated: levelFor(nutrients[rated.nutrient], bounds[rated]!),
    },
    plusPoints: plusPointsFor(nutrients),
    suspicious: hasSuspiciousValues(nutrients),
  );
}

/// [rateProduct] for a stored food.
RatingResult rateFood(Food food) => rateProduct(
  nutrients: food.nutrients,
  categories: food.categories?.split(',') ?? const [],
  source: food.source,
  isLiquid: food.isLiquid,
);

NotRated? _notRatedReason(List<String> categories) {
  if (categories.isEmpty) return const NotRated(NotRatedReason.unknownType);
  if (categories.contains(_toBeRehydrated)) {
    return const NotRated(
      NotRatedReason.excludedType,
      category: _toBeRehydrated,
    );
  }
  if (categories.any(ratedExceptions.contains)) return null;
  for (final category in notRatedCategories) {
    if (categories.contains(category)) {
      return NotRated(NotRatedReason.excludedType, category: category);
    }
  }
  return null;
}

/// The level of one value, or `null` ("keine Angabe") when the value is
/// missing or impossible (below 0 or above 100 g). Missing is never LOW.
Level? levelFor(double? value, LevelBounds bounds) {
  final grams = _validGrams(value);
  if (grams == null) return null;
  final v = _round3(grams);
  if (v <= bounds.lowMax) return Level.low;
  if (v <= bounds.mediumMax) return Level.medium;
  return Level.high;
}

/// Fibre and protein plus points (EU Regulation 1924/2006, Annex):
/// - fibre: source ≥ 3 g/100 g or ≥ 1.5 g/100 kcal; high ≥ 6 g or ≥ 3 g/100 kcal
/// - protein: source ≥ 12 %, high ≥ 20 % of the energy (1 g = 4 kcal)
List<PlusPoint> plusPointsFor(Nutrients nutrients) {
  // Energy-based rules need kcal above 0 (no division by zero).
  final kcal = _validKcal(nutrients.kcal);
  final energy = (kcal != null && kcal > 0) ? kcal : null;
  final fibre = _validGrams(nutrients.fibre);
  final protein = _validGrams(nutrients.protein);
  final points = <PlusPoint>[];

  if (fibre != null) {
    final grams = _round3(fibre);
    final per100kcal = energy == null ? null : _round3(fibre * 100 / energy);
    if (grams >= 6 || (per100kcal != null && per100kcal >= 3)) {
      points.add(
        PlusPoint(PlusPointNutrient.fibre, PlusPointStrength.high, fibre),
      );
    } else if (grams >= 3 || (per100kcal != null && per100kcal >= 1.5)) {
      points.add(
        PlusPoint(PlusPointNutrient.fibre, PlusPointStrength.source, fibre),
      );
    }
  }

  if (protein != null && energy != null) {
    final energyShare = _round3(protein * 4 * 100 / energy);
    if (energyShare >= 20) {
      points.add(
        PlusPoint(PlusPointNutrient.protein, PlusPointStrength.high, protein),
      );
    } else if (energyShare >= 12) {
      points.add(
        PlusPoint(PlusPointNutrient.protein, PlusPointStrength.source, protein),
      );
    }
  }
  return points;
}

/// Whether the values look wrong (brief R6). Only a hint – logging is never
/// blocked.
///
/// - an impossible value (below 0, over 100 g, over 900 kcal)
/// - more saturated fat than fat, or more sugars than carbohydrates
/// - fat + carbs + protein + fibre + salt over 105 g per 100 g
/// - declared kcal far from 9·fat + 4·carbs + 4·protein + 2·fibre
///   (more than 20 kcal and more than 20 %)
bool hasSuspiciousValues(Nutrients nutrients) {
  final gramsNutrients = Nutrient.values.where((n) => n != Nutrient.kcal);
  final impossible =
      gramsNutrients.any(
        (n) => nutrients[n] != null && _validGrams(nutrients[n]) == null,
      ) ||
      (nutrients.kcal != null && _validKcal(nutrients.kcal) == null);
  if (impossible) return true;

  final kcal = nutrients.kcal;
  final fat = nutrients.fat;
  final saturatedFat = nutrients.saturatedFat;
  final carbs = nutrients.carbs;
  final sugars = nutrients.sugars;
  final fibre = nutrients.fibre;
  final protein = nutrients.protein;

  if (fat != null &&
      saturatedFat != null &&
      _round3(saturatedFat) > _round3(fat + 0.1)) {
    return true;
  }
  if (carbs != null &&
      sugars != null &&
      _round3(sugars) > _round3(carbs + 0.1)) {
    return true;
  }
  final mass = [
    fat,
    carbs,
    protein,
    fibre,
    nutrients.salt,
  ].nonNulls.fold<double>(0, (sum, grams) => sum + grams);
  if (_round3(mass) > 105) return true;

  if (kcal != null && fat != null && carbs != null && protein != null) {
    // Missing fibre counts as 0 here.
    final computed = 9 * fat + 4 * carbs + 4 * protein + 2 * (fibre ?? 0);
    final tolerance = max(20.0, computed * 0.2);
    if (_round3((kcal - computed).abs()) > _round3(tolerance)) return true;
  }
  return false;
}

/// Rounds to 0.001 before comparing, so float noise cannot cross a limit:
/// in Dart `0.1 * 3` is 0.30000000000000004, which must still count as 0.3.
double _round3(double value) => (value * 1000).round() / 1000;

double? _validGrams(double? value) =>
    (value == null || value.isNaN || value < 0 || value > 100) ? null : value;

double? _validKcal(double? value) =>
    (value == null || value.isNaN || value < 0 || value > 900) ? null : value;
