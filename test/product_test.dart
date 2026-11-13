import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/product.dart';

void main() {
  group('Product.fromJson', () {
    test('liest ganze Zahlen und Kommazahlen (wie bei Nutella)', () {
      final product = Product.fromJson('3017624010701', {
        'product_name': 'Nutella',
        'brands': 'Ferrero,Ferrero GmbH',
        'nutriscore_grade': 'e',
        'nutriments': {
          'energy-kcal_100g': 539, // int
          'fat_100g': 30.9, // double
          'saturated-fat_100g': 10.6,
          'sugars_100g': 56.3,
          'salt_100g': 0.1075,
        },
      });

      expect(product.barcode, '3017624010701');
      expect(product.name, 'Nutella');
      expect(product.brand, 'Ferrero');
      expect(product.nutriScore, 'E');
      expect(product.kcal, 539.0);
      expect(product.fat, 30.9);
      expect(product.saturatedFat, 10.6);
      expect(product.sugar, 56.3);
      expect(product.salt, 0.1075);
    });

    test('liest Zahlen, die als Text kommen', () {
      final product = Product.fromJson('1', {
        'nutriments': {'fat_100g': '12.5', 'sugars_100g': 'kaputt'},
      });

      expect(product.fat, 12.5);
      expect(product.sugar, isNull);
    });

    test('kommt mit fehlenden Daten klar', () {
      final product = Product.fromJson('1', {});

      expect(product.name, 'Unbekanntes Produkt');
      expect(product.brand, isNull);
      expect(product.kcal, isNull);
      expect(product.fat, isNull);
      expect(product.nutriScore, isNull);
    });

    test('leerer Name zählt als fehlend', () {
      final product = Product.fromJson('1', {'product_name': '   '});
      expect(product.name, 'Unbekanntes Produkt');
    });

    test('nutriments mit falschem Typ stürzt nicht ab', () {
      final product = Product.fromJson('1', {'nutriments': []});
      expect(product.fat, isNull);
    });

    test('nur A bis E ist ein gültiger Nutri-Score', () {
      expect(Product.fromJson('1', {'nutriscore_grade': 'a'}).nutriScore, 'A');
      expect(
        Product.fromJson('1', {'nutriscore_grade': 'unknown'}).nutriScore,
        isNull,
      );
      expect(
        Product.fromJson('1', {
          'nutriscore_grade': 'not-applicable',
        }).nutriScore,
        isNull,
      );
    });
  });
}
