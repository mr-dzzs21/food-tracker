import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'goal_enums.dart';

// The calorie-needs calculator: pure maths, no Flutter widgets, no database.
//
// Sources (see .notes/research/health-nutrition.md, R9–R13):
// - Basal metabolic rate: Mifflin-St Jeor (1990).
// - Total need = basal rate × activity factor (PAL, EFSA 2013).
// - 1 kg body weight ≈ 7700 kcal (a rough rule; the body adapts over time).
// - Macros: protein 0.8 g per kg (1.0 g from 65 years, DGE), fat 30 % of
//   the energy, carbohydrates the rest, fibre at least 30 g (DGE).
//
// All results are estimates for healthy adults. The app shows them with
// "ca." and a disclaimer.

/// Accepted input ranges. Everything outside is most likely a typo.
const minAge = 1;
const maxAge = 120;
const minHeightCm = 100.0;
const maxHeightCm = 250.0;
const minWeightKg = 30.0;
const maxWeightKg = 300.0;

/// From this age on, the formula's study group applies (adults). Younger
/// people still get a result, but the app shows an extra hint (owner's
/// decision: no age limit).
const adultAge = 18;

/// From this age on, the protein default rises to 1.0 g per kg (DGE).
const seniorAge = 65;

/// Energy in one kilogram of body weight (approximation of 3500 kcal/lb).
const kcalPerKg = 7700.0;

/// The calculator never suggests less than this (an app convention; there is
/// no single official "never below" value).
const minimumGoalKcal = 1200.0;

/// Fibre goal in grams per day (DGE guideline value: at least 30 g).
const fibreGoalGrams = 30.0;

bool isValidAge(int age) => age >= minAge && age <= maxAge;

bool isValidHeightCm(double cm) => cm >= minHeightCm && cm <= maxHeightCm;

bool isValidWeightKg(double kg) => kg >= minWeightKg && kg <= maxWeightKg;

/// Younger than 18: the formula was made for adults, the app shows a hint.
bool isMinor(int age) => age < adultAge;

/// Basal metabolic rate in kcal per day (energy used at complete rest).
///
/// Mifflin-St Jeor: 10 × kg + 6.25 × cm − 5 × age, plus +5 for men and
/// −161 for women. For "keine Angabe" the app uses −78, the exact average of
/// both (an app choice, not from the paper).
double basalMetabolicRate({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int age,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return base +
      switch (sex) {
        Sex.male => 5,
        Sex.female => -161,
        Sex.unspecified => -78,
      };
}

/// Total energy need per day: basal rate × activity factor.
double totalEnergyNeed(double bmr, ActivityLevel activity) =>
    bmr * activity.pal;

/// The lowest goal the app suggests: 1200 kcal, or the basal rate if that is
/// higher (eating less than the body needs at rest is not suggested).
double floorKcal(double bmr) => math.max(minimumGoalKcal, bmr);

/// Daily grams for the three macro nutrients (plus the fibre goal).
@immutable
class MacroGoals {
  const MacroGoals({
    required this.protein,
    required this.fat,
    required this.carbs,
    this.fibre = fibreGoalGrams,
  });

  final double protein;
  final double fat;
  final double carbs;
  final double fibre;

  /// Share of the energy that comes from protein, in percent.
  double proteinPercentOf(double kcal) => protein * 4 / kcal * 100;

  /// Share of the energy that comes from carbohydrates, in percent.
  double carbsPercentOf(double kcal) => carbs * 4 / kcal * 100;
}

/// Macro goals for a calculated goal of [kcal]: protein from body weight
/// (0.8 g per kg, 1.0 g from 65 years), fat 30 % of the energy and the rest
/// as carbohydrates.
MacroGoals defaultMacros({
  required double kcal,
  required double weightKg,
  required int age,
}) {
  final protein = (age >= seniorAge ? 1.0 : 0.8) * weightKg;
  final fat = kcal * 0.30 / 9;
  return MacroGoals(
    protein: protein,
    fat: fat,
    carbs: _restAsCarbs(kcal, protein: protein, fat: fat),
  );
}

/// Macro goals for a goal typed in by hand. Without a body weight the app
/// uses 15 % of the energy for protein, 30 % for fat and the rest for
/// carbohydrates. Values the user entered ([protein], [fat], [carbs]) are
/// kept; only the missing ones are filled in.
MacroGoals manualMacros(
  double kcal, {
  double? protein,
  double? fat,
  double? carbs,
}) {
  final p = protein ?? kcal * 0.15 / 4;
  final f = fat ?? kcal * 0.30 / 9;
  return MacroGoals(
    protein: p,
    fat: f,
    carbs: carbs ?? _restAsCarbs(kcal, protein: p, fat: f),
  );
}

/// Carbohydrates fill the energy that protein (4 kcal/g) and fat (9 kcal/g)
/// leave. Never negative, even if the user typed very high values.
double _restAsCarbs(
  double kcal, {
  required double protein,
  required double fat,
}) => math.max(0, (kcal - protein * 4 - fat * 9) / 4);

/// What the calculator needs to know.
@immutable
class CalculatorInput {
  const CalculatorInput({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.goalType,
  });

  final Sex sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final GoalType goalType;

  /// All numbers are inside the accepted ranges.
  bool get isValid =>
      isValidAge(age) && isValidHeightCm(heightCm) && isValidWeightKg(weightKg);
}

/// The result of [calculateGoal]. All values are exact; the UI rounds them.
@immutable
class GoalResult {
  const GoalResult({
    required this.bmr,
    required this.totalNeed,
    required this.rawKcal,
    required this.floor,
    required this.macros,
    required this.isMinor,
  });

  /// Basal metabolic rate ("Grundumsatz").
  final double bmr;

  /// Total need per day ("Gesamtbedarf").
  final double totalNeed;

  /// Total need plus/minus the planned weight change, before the floor.
  final double rawKcal;

  /// The lowest goal the app suggests (see [floorKcal]).
  final double floor;

  final MacroGoals macros;

  /// The person is younger than 18 (see [isMinor]).
  final bool isMinor;

  /// The suggested daily goal: never below [floor].
  double get kcal => math.max(rawKcal, floor);

  /// The goal would have been lower than [floor] and was raised to it.
  bool get wasClamped => rawKcal < floor;
}

/// Calculates the daily goal for [input].
///
/// goal = total need + kg per week × 7700 / 7, but at least [floorKcal].
/// Throws an [ArgumentError] when an input is outside the accepted ranges.
GoalResult calculateGoal(CalculatorInput input) {
  if (!input.isValid) {
    throw ArgumentError.value(input, 'input', 'outside the accepted ranges');
  }
  final bmr = basalMetabolicRate(
    sex: input.sex,
    weightKg: input.weightKg,
    heightCm: input.heightCm,
    age: input.age,
  );
  final totalNeed = totalEnergyNeed(bmr, input.activity);
  final rawKcal = totalNeed + input.goalType.kgPerWeek * kcalPerKg / 7;
  final floor = floorKcal(bmr);
  return GoalResult(
    bmr: bmr,
    totalNeed: totalNeed,
    rawKcal: rawKcal,
    floor: floor,
    macros: defaultMacros(
      kcal: math.max(rawKcal, floor),
      weightKg: input.weightKg,
      age: input.age,
    ),
    isMinor: isMinor(input.age),
  );
}

/// Rounds to the nearest 10 for "ca." values (1784 → 1780), so the UI does
/// not pretend more precision than the formula has.
double roundToTen(double kcal) => (kcal / 10).round() * 10.0;
