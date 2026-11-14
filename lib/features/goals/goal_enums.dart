// Choices in the calorie calculator.
//
// The order of each enum matters: drift stores the index (0, 1, …).
// Only add new values at the end.

/// Sex for the energy formula. `unspecified` uses the average of both.
enum Sex { male, female, unspecified }

/// How active someone is. [pal] is the "physical activity level" factor
/// (EFSA 2013): total energy need = basal metabolic rate × PAL.
enum ActivityLevel {
  low(1.4),
  light(1.6),
  active(1.8),
  veryActive(2.0);

  const ActivityLevel(this.pal);
  final double pal;
}

/// What the user wants: keep, lose or gain weight. [kgPerWeek] is the planned
/// change; negative means losing weight.
enum GoalType {
  maintain(0),
  loseSlow(-0.25),
  lose(-0.5),
  gainSlow(0.25);

  const GoalType(this.kgPerWeek);
  final double kgPerWeek;
}
