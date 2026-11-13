import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/main.dart';
import 'package:food_tracker/open_food_facts_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _nutella = {
  'status': 1,
  'product': {
    'product_name': 'Nutella',
    'brands': 'Ferrero',
    'nutriscore_grade': 'e',
    'nutriments': {
      'energy-kcal_100g': 539,
      'fat_100g': 30.9,
      'saturated-fat_100g': 10.6,
      'sugars_100g': 56.3,
      'salt_100g': 0.1075,
    },
  },
};

Widget appWith(MockClient client) =>
    FoodTrackerApp(api: OpenFoodFactsApi(client: client));

void main() {
  testWidgets('Nummer eintippen zeigt das Produkt', (tester) async {
    // Schaltet die Screenreader-Infos ein, damit wir sie prüfen können.
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      appWith(
        MockClient(
          (_) async =>
              http.Response.bytes(utf8.encode(jsonEncode(_nutella)), 200),
        ),
      ),
    );

    expect(find.textContaining('Tippe die Nummer'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3017624010701');
    await tester.tap(find.text('Suchen'));
    await tester.pumpAndSettle();

    expect(find.text('Nutella'), findsOneWidget);
    expect(find.text('Ferrero'), findsOneWidget);
    expect(find.text('539 kcal'), findsOneWidget);
    expect(find.text('30,9 g'), findsOneWidget);
    expect(find.text('56,3 g'), findsOneWidget);
    expect(find.text('0,1 g'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Nutri-Score E')), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('unbekanntes Produkt zeigt eine Meldung', (tester) async {
    await tester.pumpWidget(
      appWith(MockClient((_) async => http.Response('{"status":0}', 404))),
    );

    await tester.enterText(find.byType(TextField), '12345678');
    await tester.tap(find.text('Suchen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('nicht gefunden'), findsOneWidget);
  });

  testWidgets('Buchstaben lassen sich gar nicht eintippen', (tester) async {
    await tester.pumpWidget(
      appWith(MockClient((_) async => http.Response('{}', 200))),
    );

    await tester.enterText(find.byType(TextField), '12ab34');

    expect(find.text('1234'), findsOneWidget);
  });

  test('formatAmount', () {
    expect(formatAmount(30.9, 'g'), '30,9 g');
    expect(formatAmount(539, 'kcal', decimals: 0), '539 kcal');
    expect(formatAmount(null, 'g'), '–');
  });
}
