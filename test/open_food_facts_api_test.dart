import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/open_food_facts_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Eine Fake-Datenbank: antwortet immer mit [body] und [status],
/// ohne echtes Internet.
OpenFoodFactsApi fakeApi(String body, {int status = 200}) {
  return OpenFoodFactsApi(
    client: MockClient(
      (_) async => http.Response.bytes(
        utf8.encode(body),
        status,
        // Absichtlich ohne "charset=utf-8", um Umlaute zu prüfen.
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
}

Matcher throwsLookupError(String containing) => throwsA(
  isA<ProductLookupException>().having(
    (e) => e.message,
    'message',
    contains(containing),
  ),
);

void main() {
  test('findet ein Produkt', () async {
    final api = fakeApi(
      jsonEncode({
        'status': 1,
        'product': {
          'product_name': 'Nutella',
          'nutriments': {'fat_100g': 30.9},
        },
      }),
    );

    final product = await api.fetchProduct('3017624010701');

    expect(product.name, 'Nutella');
    expect(product.fat, 30.9);
  });

  test('schickt die richtige Adresse und einen User-Agent', () async {
    late http.Request sent;
    final api = OpenFoodFactsApi(
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"status":1,"product":{}}', 200);
      }),
    );

    await api.fetchProduct(' 3017624010701 ');

    expect(sent.url.path, '/api/v2/product/3017624010701.json');
    expect(sent.url.queryParameters['fields'], contains('nutriments'));
    expect(sent.headers['User-Agent'], startsWith('FoodTracker/'));
  });

  test('zeigt Umlaute richtig an', () async {
    final api = fakeApi(
      '{"status":1,"product":{"product_name":"Grüne Bohnen"}}',
    );

    final product = await api.fetchProduct('12345678');

    expect(product.name, 'Grüne Bohnen');
  });

  test('ungültige Nummer wird gar nicht erst abgeschickt', () async {
    var called = false;
    final api = OpenFoodFactsApi(
      client: MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(api.fetchProduct(''), throwsLookupError('gültige'));
    await expectLater(api.fetchProduct('123'), throwsLookupError('gültige'));
    await expectLater(
      api.fetchProduct('12a45678'),
      throwsLookupError('gültige'),
    );
    expect(called, isFalse);
  });

  test('Produkt nicht in der Datenbank (status 0)', () async {
    final api = fakeApi('{"status":0,"status_verbose":"product not found"}');
    await expectLater(
      api.fetchProduct('12345678'),
      throwsLookupError('nicht gefunden'),
    );
  });

  test('Produkt nicht in der Datenbank (HTTP 404)', () async {
    final api = fakeApi('{"status":0}', status: 404);
    await expectLater(
      api.fetchProduct('12345678'),
      throwsLookupError('nicht gefunden'),
    );
  });

  test('Server-Fehler', () async {
    final api = fakeApi('Internal Server Error', status: 500);
    await expectLater(api.fetchProduct('12345678'), throwsLookupError('500'));
  });

  test('kaputte Antwort', () async {
    final api = fakeApi('<html>kein JSON</html>');
    await expectLater(
      api.fetchProduct('12345678'),
      throwsLookupError('nicht lesbar'),
    );
  });

  test('kein Internet', () async {
    final api = OpenFoodFactsApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      api.fetchProduct('12345678'),
      throwsLookupError('online'),
    );
  });
}
