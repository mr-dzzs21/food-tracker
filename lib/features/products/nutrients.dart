import 'package:flutter/foundation.dart';

import '../../data/database.dart';

/// The eight nutrients the app tracks, in the order the UI shows them.
enum Nutrient { kcal, fat, saturatedFat, carbs, sugars, fibre, protein, salt }

/// Nutrient values of a food or a diary entry.
///
/// Every value is `null` when it is unknown. Unknown is **not** 0: a product
/// without a sugar value may still contain sugar, so the app must never add
/// it as 0 g and pretend the total is complete.
///
/// Values are per 100 g (or 100 ml) for foods, and absolute amounts after
/// [scaled].
@immutable
class Nutrients {
  const Nutrients({
    this.kcal,
    this.fat,
    this.saturatedFat,
    this.carbs,
    this.sugars,
    this.fibre,
    this.protein,
    this.salt,
  });

  /// Nothing known.
  static const unknown = Nutrients();

  final double? kcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbs;
  final double? sugars;
  final double? fibre;
  final double? protein;
  final double? salt;

  /// The value of one [nutrient], so code can loop over all of them.
  double? operator [](Nutrient nutrient) => switch (nutrient) {
    Nutrient.kcal => kcal,
    Nutrient.fat => fat,
    Nutrient.saturatedFat => saturatedFat,
    Nutrient.carbs => carbs,
    Nutrient.sugars => sugars,
    Nutrient.fibre => fibre,
    Nutrient.protein => protein,
    Nutrient.salt => salt,
  };

  /// The values for [amount] g (or ml), when this object holds values per
  /// 100 g: `per100 × amount / 100`. Unknown values stay unknown.
  ///
  /// Not rounded – only the display rounds (see core/format.dart).
  Nutrients scaled(double amount) {
    double? scale(double? per100) =>
        per100 == null ? null : per100 * amount / 100;
    return Nutrients(
      kcal: scale(kcal),
      fat: scale(fat),
      saturatedFat: scale(saturatedFat),
      carbs: scale(carbs),
      sugars: scale(sugars),
      fibre: scale(fibre),
      protein: scale(protein),
      salt: scale(salt),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Nutrients && Nutrient.values.every((n) => other[n] == this[n]);

  @override
  int get hashCode => Object.hashAll(Nutrient.values.map((n) => this[n]));

  @override
  String toString() =>
      'Nutrients(${Nutrient.values.map((n) => '${n.name}: ${this[n]}').join(', ')})';
}

/// How much is known about a sum of several entries.
enum TotalState {
  /// Every entry had a value (also true for "no entries at all" = 0).
  complete,

  /// Some entries had no value: show "mind. 15 g" / "at least 15 g".
  partial,

  /// No entry had a value: show "–".
  unknown,
}

/// The sum of one nutrient over several entries.
@immutable
class NutrientTotal {
  const NutrientTotal({required this.value, required this.missingCount});

  /// Sum of the known values (0 when nothing is known).
  final double value;

  /// How many entries had no value for this nutrient.
  final int missingCount;

  TotalState stateFor(int entryCount) {
    if (missingCount == 0) return TotalState.complete;
    if (missingCount < entryCount) return TotalState.partial;
    return TotalState.unknown;
  }

  @override
  bool operator ==(Object other) =>
      other is NutrientTotal &&
      other.value == value &&
      other.missingCount == missingCount;

  @override
  int get hashCode => Object.hash(value, missingCount);

  @override
  String toString() =>
      'NutrientTotal(value: $value, missingCount: $missingCount)';
}

/// Adds up nutrients of several entries (for example all entries of a day),
/// remembering for each nutrient how many entries did not know it.
@immutable
class NutrientTotals {
  const NutrientTotals._(this.entryCount, this._totals);

  /// Sums [items]. An empty list gives complete totals of 0.
  factory NutrientTotals.sum(Iterable<Nutrients> items) {
    final list = items.toList();
    return NutrientTotals._(list.length, {
      for (final nutrient in Nutrient.values)
        nutrient: NutrientTotal(
          value: list.fold<double>(
            0,
            (sum, item) => sum + (item[nutrient] ?? 0),
          ),
          missingCount: list.where((item) => item[nutrient] == null).length,
        ),
    });
  }

  /// How many entries were added up.
  final int entryCount;
  final Map<Nutrient, NutrientTotal> _totals;

  /// The total of one [nutrient].
  NutrientTotal operator [](Nutrient nutrient) => _totals[nutrient]!;

  /// Whether the UI can show the plain value, "mind. …" or only "–".
  TotalState stateOf(Nutrient nutrient) => this[nutrient].stateFor(entryCount);
}

/// Nutrients per 100 g/ml of a stored food.
extension FoodNutrients on Food {
  Nutrients get nutrients => Nutrients(
    kcal: kcal,
    fat: fat,
    saturatedFat: saturatedFat,
    carbs: carbs,
    sugars: sugars,
    fibre: fibre,
    protein: protein,
    salt: salt,
  );
}

/// Nutrients of a diary entry.
extension DiaryEntryNutrients on DiaryEntry {
  /// The snapshot per 100 g/ml, taken when the entry was made.
  Nutrients get nutrientsPer100 => Nutrients(
    kcal: kcal,
    fat: fat,
    saturatedFat: saturatedFat,
    carbs: carbs,
    sugars: sugars,
    fibre: fibre,
    protein: protein,
    salt: salt,
  );

  /// What was actually eaten: the snapshot scaled to [amount].
  Nutrients get nutrients => nutrientsPer100.scaled(amount);
}
