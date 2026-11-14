import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/format.dart';
import 'package:food_tracker/features/goals/calculator.dart';
import 'package:food_tracker/features/goals/goal_enums.dart';
import 'package:food_tracker/features/products/off_product_mapper.dart';

// The maths vectors M(2) from .notes/research/health-nutrition.md, ported 1:1.
// Vectors that belong to other modules are tested there:
// N10, N11, N14 → nutrients_test.dart; N15 → health_rating_test.dart;
// N16 → off_product_mapper_test.dart; N19 → health_rating_test.dart (R15b, R26).
// N13 and N17 are repeated below because they are plain numbers.
// N12 (kcal → kJ) has no code: the app never derives kJ (brief R8).

/// The brief's three example people.
const male80 = (sex: Sex.male, kg: 80.0, cm: 180.0, age: 30);
const female65 = (sex: Sex.female, kg: 65.0, cm: 165.0, age: 30);
const unspecified72 = (sex: Sex.unspecified, kg: 72.0, cm: 172.0, age: 30);

double bmrOf(({Sex sex, double kg, double cm, int age}) p) =>
    basalMetabolicRate(sex: p.sex, weightKg: p.kg, heightCm: p.cm, age: p.age);

CalculatorInput inputOf(
  ({Sex sex, double kg, double cm, int age}) p, {
  ActivityLevel activity = ActivityLevel.light,
  GoalType goalType = GoalType.maintain,
}) => CalculatorInput(
  sex: p.sex,
  age: p.age,
  heightCm: p.cm,
  weightKg: p.kg,
  activity: activity,
  goalType: goalType,
);

void main() {
  group('basal metabolic rate (Mifflin-St Jeor)', () {
    test('N1 male 80 kg 180 cm 30 y → 1780 kcal', () {
      expect(bmrOf(male80), 1780.0);
    });

    test('N2 female 65 kg 165 cm 30 y → 1370.25 kcal', () {
      expect(bmrOf(female65), 1370.25);
      expect(formatKcal(bmrOf(female65), 'de'), '1.370');
    });

    test('N3 unspecified 72 kg 172 cm 30 y → 1567 kcal', () {
      expect(bmrOf(unspecified72), 1567.0);
    });

    test('N3b "keine Angabe" is the exact mean of male and female', () {
      const person = (kg: 65.0, cm: 165.0, age: 30);
      double bmr(Sex sex) => basalMetabolicRate(
        sex: sex,
        weightKg: person.kg,
        heightCm: person.cm,
        age: person.age,
      );
      expect(bmr(Sex.unspecified), 1453.25);
      expect((bmr(Sex.male) + bmr(Sex.female)) / 2, 1453.25);
    });
  });

  group('total energy need', () {
    test('N4 the N1 person with PAL 1.4 / 1.6 / 1.8 / 2.0', () {
      final bmr = bmrOf(male80);
      expect(totalEnergyNeed(bmr, ActivityLevel.low), closeTo(2492, 1e-9));
      expect(totalEnergyNeed(bmr, ActivityLevel.light), closeTo(2848, 1e-9));
      expect(totalEnergyNeed(bmr, ActivityLevel.active), closeTo(3204, 1e-9));
      expect(
        totalEnergyNeed(bmr, ActivityLevel.veryActive),
        closeTo(3560, 1e-9),
      );
    });
  });

  group('daily goal', () {
    test('N5 lose 0.5 kg/week: deficit 550 → 2298 kcal, not clamped', () {
      expect(0.5 * kcalPerKg / 7, 550);
      final result = calculateGoal(inputOf(male80, goalType: GoalType.lose));
      expect(result.kcal, closeTo(2298, 1e-9));
      expect(result.wasClamped, isFalse);
    });

    test('N6 lose 0.25 kg/week: deficit 275 → 2573 kcal', () {
      expect(0.25 * kcalPerKg / 7, 275);
      final result = calculateGoal(
        inputOf(male80, goalType: GoalType.loseSlow),
      );
      expect(result.kcal, closeTo(2573, 1e-9));
    });

    test('N7 gain 0.25 kg/week → 3123 kcal', () {
      final result = calculateGoal(
        inputOf(male80, goalType: GoalType.gainSlow),
      );
      expect(result.kcal, closeTo(3123, 1e-9));
    });

    test('maintain = total need', () {
      final result = calculateGoal(inputOf(male80));
      expect(result.bmr, 1780);
      expect(result.totalNeed, closeTo(2848, 1e-9));
      expect(result.kcal, closeTo(2848, 1e-9));
    });

    test('N8 lower bound: 860.85 kcal is raised to 1200 (clamped)', () {
      const small = (sex: Sex.female, kg: 50.0, cm: 155.0, age: 60);
      final result = calculateGoal(
        inputOf(small, activity: ActivityLevel.low, goalType: GoalType.lose),
      );
      expect(result.bmr, 1007.75);
      expect(result.totalNeed, closeTo(1410.85, 1e-9));
      expect(result.rawKcal, closeTo(860.85, 1e-9));
      expect(result.floor, 1200);
      expect(result.kcal, 1200);
      expect(result.wasClamped, isTrue);
    });

    test('floor = basal rate when that is above 1200 kcal', () {
      expect(floorKcal(1780), 1780);
      expect(floorKcal(1007.75), 1200);
      // Losing fast with little activity would go below the basal rate.
      const tall = (sex: Sex.male, kg: 120.0, cm: 190.0, age: 30);
      final result = calculateGoal(
        inputOf(tall, activity: ActivityLevel.low, goalType: GoalType.lose),
      );
      // BMR 2242.5; × 1.4 = 3139.5; − 550 = 2589.5 → above the floor.
      expect(result.wasClamped, isFalse);
      expect(result.floor, 2242.5);
    });

    test('macros come from the clamped goal', () {
      const small = (sex: Sex.female, kg: 50.0, cm: 155.0, age: 60);
      final result = calculateGoal(
        inputOf(small, activity: ActivityLevel.low, goalType: GoalType.lose),
      );
      expect(result.macros.fat, closeTo(1200 * 0.3 / 9, 1e-9));
    });
  });

  group('macro defaults (N9)', () {
    test('2000 kcal, 70 kg, 30 y → protein 56 g, fat 67 g, carbs 294 g', () {
      final m = defaultMacros(kcal: 2000, weightKg: 70, age: 30);
      expect(m.protein, closeTo(56, 1e-9));
      expect(roundHalfUp(m.proteinPercentOf(2000), 1), 11.2);
      expect(roundHalfUp(m.fat, 0), 67);
      expect(roundHalfUp(m.carbs, 0), 294);
      expect(roundHalfUp(m.carbsPercentOf(2000), 1), 58.8);
      expect(m.fibre, 30);
    });

    test('2000 kcal, 70 kg, 70 y → protein 70 g (1.0 g/kg from 65)', () {
      final m = defaultMacros(kcal: 2000, weightKg: 70, age: 70);
      expect(m.protein, closeTo(70, 1e-9));
      expect(roundHalfUp(m.proteinPercentOf(2000), 1), 14.0);
      expect(roundHalfUp(m.fat, 0), 67);
      expect(roundHalfUp(m.carbs, 0), 280);
      expect(roundHalfUp(m.carbsPercentOf(2000), 1), 56.0);
    });

    test('2298 kcal, 80 kg, 30 y → protein 64 g, fat 77 g, carbs 338 g', () {
      final m = defaultMacros(kcal: 2298, weightKg: 80, age: 30);
      expect(m.protein, closeTo(64, 1e-9));
      expect(roundHalfUp(m.proteinPercentOf(2298), 1), 11.1);
      expect(roundHalfUp(m.fat, 0), 77);
      expect(roundHalfUp(m.carbs, 0), 338);
      expect(roundHalfUp(m.carbsPercentOf(2298), 1), 58.9);
    });

    test('the 65th birthday switches to 1.0 g/kg', () {
      expect(defaultMacros(kcal: 2000, weightKg: 70, age: 64).protein, 56);
      expect(defaultMacros(kcal: 2000, weightKg: 70, age: 65).protein, 70);
    });

    test('calculateGoal uses the N5 goal for the macros', () {
      final result = calculateGoal(inputOf(male80, goalType: GoalType.lose));
      expect(roundHalfUp(result.macros.protein, 0), 64);
      expect(roundHalfUp(result.macros.fat, 0), 77);
      expect(roundHalfUp(result.macros.carbs, 0), 338);
    });
  });

  group('manual goal macros (15 %E protein, 30 %E fat, rest carbs)', () {
    test('all defaults', () {
      final m = manualMacros(2000);
      expect(m.protein, closeTo(75, 1e-9));
      expect(m.fat, closeTo(66.667, 0.001));
      expect(m.carbs, closeTo(275, 1e-9));
    });

    test('values typed by the user are kept, carbs fill the rest', () {
      final m = manualMacros(2000, protein: 100);
      expect(m.protein, 100);
      expect(m.fat, closeTo(66.667, 0.001));
      expect(m.carbs, closeTo((2000 - 400 - 600) / 4, 1e-9));
      expect(manualMacros(2000, carbs: 200).carbs, 200);
    });

    test('carbs never become negative', () {
      expect(manualMacros(1000, protein: 300, fat: 50).carbs, 0);
    });
  });

  group('input ranges (owner: no age limit, hint below 18)', () {
    test('age 1–120, height 100–250 cm, weight 30–300 kg', () {
      expect(isValidAge(0), isFalse);
      expect(isValidAge(1), isTrue);
      expect(isValidAge(120), isTrue);
      expect(isValidAge(121), isFalse);
      expect(isValidHeightCm(99.9), isFalse);
      expect(isValidHeightCm(100), isTrue);
      expect(isValidHeightCm(250), isTrue);
      expect(isValidHeightCm(250.1), isFalse);
      expect(isValidWeightKg(29.9), isFalse);
      expect(isValidWeightKg(30), isTrue);
      expect(isValidWeightKg(300), isTrue);
      expect(isValidWeightKg(300.5), isFalse);
    });

    test('minor = younger than 18', () {
      expect(isMinor(17), isTrue);
      expect(isMinor(18), isFalse);
    });

    test(
      'the brief refuses under 18; the owner wants a result plus a hint',
      () {
        const teen = (sex: Sex.female, kg: 55.0, cm: 165.0, age: 16);
        final result = calculateGoal(inputOf(teen));
        // 550 + 1031.25 − 80 − 161 = 1340.25
        expect(result.bmr, 1340.25);
        expect(result.isMinor, isTrue);
        expect(result.kcal, closeTo(1340.25 * 1.6, 1e-9));
        expect(calculateGoal(inputOf(male80)).isMinor, isFalse);
      },
    );

    test('ages above the brief\'s 100 are accepted', () {
      const old = (sex: Sex.male, kg: 70.0, cm: 170.0, age: 110);
      expect(calculateGoal(inputOf(old)).bmr, 700 + 1062.5 - 550 + 5);
    });

    test('invalid input throws', () {
      const tooLight = (sex: Sex.male, kg: 20.0, cm: 180.0, age: 30);
      expect(() => calculateGoal(inputOf(tooLight)), throwsArgumentError);
      expect(inputOf(tooLight).isValid, isFalse);
    });
  });

  group('other M(2) vectors', () {
    test('N13 kJ → kcal: 8400 kJ → 2008 kcal (exact 2007.648)', () {
      final product = parseOffProduct(
        {
          'nutriments': {'energy-kj_100g': 8400 / 10},
        },
        languageCode: 'de',
        requestedCode: '1',
      );
      // The mapper rejects kcal > 900 per 100 g, so a tenth is checked.
      expect(product.nutrients.kcal! * 10, closeTo(2007.648, 0.001));
      expect(formatKcal(8400 / 4.184, 'de'), '2.008');
    });

    test('N17 display rounding: 9.95 g / 0.25 g / 12.5 g / 160.5 kcal', () {
      expect(formatGrams(9.95, 'en'), '10');
      expect(formatGrams(0.25, 'en'), '0.3');
      expect(formatGrams(12.5, 'en'), '13');
      expect(formatKcal(160.5, 'en'), '161');
    });

    test('N18 7700 kcal/kg ≈ 3500 kcal/lb (7716.2)', () {
      expect(roundHalfUp(3500 / 0.45359237, 1), 7716.2);
      expect((kcalPerKg - 3500 / 0.45359237).abs(), lessThan(20));
    });
  });

  test('roundToTen for "ca." values', () {
    expect(roundToTen(1784), 1780);
    expect(roundToTen(1785), 1790);
    expect(roundToTen(2848), 2850);
  });
}
