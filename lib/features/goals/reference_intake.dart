/// Reference intakes for an average adult, used on "Heute" while no daily
/// goal is set: the ring and the macro bars fill relative to these values
/// and say "(Richtwert)".
///
/// Source: Regulation (EU) No 1169/2011 on food information to consumers,
/// Annex XIII Part B ("Reference intakes for energy and selected nutrients
/// other than vitamins and minerals (adults)"). They are the same values that
/// appear as "% RI" on food packages in the EU – a general orientation, not a
/// personal goal.
abstract final class ReferenceIntake {
  /// Energy in kcal (8 400 kJ).
  static const int kcal = 2000;

  /// Protein in g.
  static const double protein = 50;

  /// Carbohydrate in g.
  static const double carbs = 260;

  /// Total fat in g.
  static const double fat = 70;
}
