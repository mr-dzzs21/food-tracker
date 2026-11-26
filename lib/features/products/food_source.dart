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
  /// so favourites, recents and the diary work as for any other food. Its
  /// `externalId` is the BLS code (for example "B782100").
  ///
  /// Simple foods opened before [simpleBls] existed are stored like this
  /// too; they simply stay BLS foods.
  bls,

  /// A simple food with typical values: the median of many Open Food Facts
  /// products of one kind (for example "Skyr Vanille"), bundled with the app
  /// (assets/data/simple_foods_off.tsv). Its `externalId` is the key of the
  /// list (for example "skyr-vanille").
  offAverage,

  /// A simple food with values from the BLS (assets/data/simple_foods_bls.tsv),
  /// for example "Skyr natur". Its `externalId` is the key of the list
  /// ("skyr-natur"). It gets its own row – not the row of the BLS food with
  /// the same values – because name, portion and drink/food can differ
  /// ("Kefir" vs. "Kefir fettarm, mind. 1,5 % …").
  simpleBls;

  /// Values from a list bundled with the app (BLS or Open Food Facts
  /// averages) instead of a package: averages for a kind of food, without a
  /// brand.
  bool get isBundled => switch (this) {
    bls || offAverage || simpleBls => true,
    openFoodFacts || user => false,
  };

  /// Values from the BLS: the product page has to name it (CC BY 4.0).
  bool get isFromBls => this == bls || this == simpleBls;
}
