/// Where a food in the local database comes from.
///
/// The order matters: drift stores the index (0, 1, …). Only add new values
/// at the end.
enum FoodSource {
  /// Downloaded from Open Food Facts (cached on the device).
  openFoodFacts,

  /// Created by the user ("Eigenes Lebensmittel").
  user,

  /// A basic food from the Bundeslebensmittelschlüssel (BLS), the German
  /// nutrient database bundled with the app. Stored when the user opens it,
  /// so favourites, recents and the diary work as for any other food.
  bls,

  /// A simple food with typical values: the median of many Open Food Facts
  /// products of one kind (for example "Skyr Vanille"), bundled with the app
  /// (assets/data/simple_foods_off.tsv). Its `externalId` is the key of the
  /// list (for example "skyr-vanille"). Simple foods with BLS values are
  /// stored as [bls].
  offAverage,
}
