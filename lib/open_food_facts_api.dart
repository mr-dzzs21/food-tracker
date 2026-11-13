import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'product.dart';

/// Ein Fehler beim Laden eines Produkts, mit einer Meldung für den Nutzer.
class ProductLookupException implements Exception {
  final String message;
  const ProductLookupException(this.message);

  @override
  String toString() => message;
}

/// Holt Produkte aus der freien Datenbank von Open Food Facts.
/// https://world.openfoodfacts.org
class OpenFoodFactsApi {
  OpenFoodFactsApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  /// Nur die Felder anfragen, die wir brauchen. Das macht die Antwort kleiner.
  static const _fields = 'product_name,brands,nutriments,nutriscore_grade';

  /// Open Food Facts bittet jede App, sich mit Namen zu melden.
  static const _userAgent =
      'FoodTracker/0.1 (https://github.com/mr-dzzs21/food-tracker)';

  static const _timeout = Duration(seconds: 10);

  /// Sucht ein Produkt anhand der Strichcode-Nummer.
  ///
  /// Wirft [ProductLookupException], wenn etwas schiefgeht.
  Future<Product> fetchProduct(String barcode) async {
    final code = barcode.trim();
    if (!RegExp(r'^\d{8,14}$').hasMatch(code)) {
      throw const ProductLookupException(
        'Bitte gib eine gültige Strichcode-Nummer ein (8 bis 14 Ziffern).',
      );
    }

    final uri = Uri.parse('$_baseUrl/$code.json?fields=$_fields');

    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
    } on TimeoutException {
      throw const ProductLookupException(
        'Die Anfrage hat zu lange gedauert. Versuch es nochmal.',
      );
    } on http.ClientException {
      throw const ProductLookupException(
        'Keine Verbindung zum Internet. Bist du online?',
      );
    }

    if (response.statusCode == 404) throw _notFound;
    if (response.statusCode != 200) {
      throw ProductLookupException(
        'Open Food Facts antwortet gerade nicht (Fehler ${response.statusCode}).',
      );
    }

    // utf8.decode statt response.body: Sonst werden Umlaute (ä, ö, ü)
    // kaputt angezeigt, wenn der Server keinen Zeichensatz mitschickt.
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ProductLookupException(
        'Die Antwort von Open Food Facts war nicht lesbar.',
      );
    }

    if (decoded is! Map<String, dynamic>) throw _notFound;
    final product = decoded['product'];
    if (decoded['status'] != 1 || product is! Map<String, dynamic>) {
      throw _notFound;
    }

    return Product.fromJson(code, product);
  }

  static const _notFound = ProductLookupException(
    'Produkt nicht gefunden. Es ist noch nicht in der Datenbank '
    'von Open Food Facts.',
  );
}
