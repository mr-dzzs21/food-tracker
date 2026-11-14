/// Where a food in the local database comes from.
///
/// The order matters: drift stores the index (0, 1, …). Only add new values
/// at the end.
enum FoodSource {
  /// Downloaded from Open Food Facts (cached on the device).
  openFoodFacts,

  /// Created by the user ("Eigenes Lebensmittel").
  user,
}
