/// Ein Lebensmittel mit Nährwerten pro 100 g.
///
/// Alle Nährwerte sind optional (`double?`), weil die Daten von
/// Open Food Facts von Freiwilligen kommen und oft unvollständig sind.
class Product {
  final String barcode;
  final String name;
  final String? brand;
  final double? kcal;
  final double? fat;
  final double? saturatedFat;
  final double? sugar;
  final double? salt;

  /// Nutri-Score als Großbuchstabe von 'A' bis 'E', oder null wenn unbekannt.
  final String? nutriScore;

  const Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.kcal,
    this.fat,
    this.saturatedFat,
    this.sugar,
    this.salt,
    this.nutriScore,
  });

  /// Baut ein Product aus dem `product`-Teil der Open-Food-Facts-Antwort.
  factory Product.fromJson(String barcode, Map<String, dynamic> json) {
    final rawNutriments = json['nutriments'];
    final nutriments = rawNutriments is Map<String, dynamic>
        ? rawNutriments
        : const <String, dynamic>{};

    return Product(
      barcode: barcode,
      name: _text(json['product_name']) ?? 'Unbekanntes Produkt',
      brand: _firstBrand(json['brands']),
      kcal: _toDouble(nutriments['energy-kcal_100g']),
      fat: _toDouble(nutriments['fat_100g']),
      saturatedFat: _toDouble(nutriments['saturated-fat_100g']),
      sugar: _toDouble(nutriments['sugars_100g']),
      salt: _toDouble(nutriments['salt_100g']),
      nutriScore: _nutriScore(json['nutriscore_grade']),
    );
  }
}

/// Gibt den Text zurück, oder null wenn er fehlt oder leer ist.
String? _text(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Open Food Facts liefert Marken als Liste mit Kommas ("Ferrero,Ferrero GmbH").
/// Wir zeigen nur die erste an.
String? _firstBrand(Object? value) => _text(_text(value)?.split(',').first);

/// Macht aus einer Zahl (oder einem Text wie "30.9") eine Kommazahl.
/// Gibt null zurück, wenn der Wert fehlt.
double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Nur 'a' bis 'e' ist ein echter Nutri-Score. Open Food Facts schickt
/// sonst z. B. "unknown" oder "not-applicable".
String? _nutriScore(Object? value) {
  final grade = _text(value)?.toLowerCase();
  if (grade == null || !const ['a', 'b', 'c', 'd', 'e'].contains(grade)) {
    return null;
  }
  return grade.toUpperCase();
}
