import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/errors.dart';
import 'package:food_tracker/features/products/off_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/off_fixtures.dart';

const userAgent =
    'FoodTracker/0.1.0-test (https://github.com/mr-dzzs21/food-tracker)';

/// A client with a fake HTTP layer, a clock we can move forward, and
/// recorded (instant) waits.
class Harness {
  Harness(Future<http.Response> Function(http.Request request) handler) {
    client = OpenFoodFactsClient(
      MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
      userAgent: userAgent,
      clock: Clock(() => now),
      delay: (duration) async => delays.add(duration),
    );
  }

  late final OpenFoodFactsClient client;
  final requests = <http.Request>[];
  final delays = <Duration>[];
  DateTime now = DateTime(2026, 11, 14, 12);
}

Matcher throwsFailure<T extends AppFailure>() => throwsA(isA<T>());

http.Response htmlResponse(int status) => http.Response(
  '<html><body>Page temporarily unavailable</body></html>',
  status,
  headers: {'content-type': 'text/html; charset=utf-8'},
);

void main() {
  group('lookup', () {
    test('success: v3.4 URL, fields list, User-Agent', () async {
      final h = Harness((_) async => jsonResponse(fixtureText('crisps.json')));
      final product = await h.client.lookup('4003586100313');

      expect(product.name, 'chipsfrisch ungarisch');
      expect(product.nutrients.kcal, 533);
      final request = h.requests.single;
      expect(request.url.host, 'world.openfoodfacts.org');
      expect(request.url.path, '/api/v3.4/product/4003586100313');
      expect(
        request.url.queryParameters['fields'],
        OpenFoodFactsClient.productFields,
      );
      expect(request.url.queryParameters['lc'], 'de');
      expect(request.headers['User-Agent'], userAgent);
      expect(h.delays, isEmpty);
    });

    test('the UI language picks the name', () async {
      final h = Harness((_) async => jsonResponse(fixtureText('crisps.json')));
      final product = await h.client.lookup(
        '4003586100313',
        languageCode: 'en',
      );
      expect(product.name, 'Chipsfrisch ungarisch');
      expect(h.requests.single.url.queryParameters['lc'], 'en');
    });

    test('404 product_not_found → ProductNotFound, no retry', () async {
      final h = Harness(
        (_) async => jsonResponse(fixtureText('not_found.json'), status: 404),
      );
      // The recorded code 4099999999994 has a wrong check digit (OFF does
      // not check it, the app does), so a valid unknown code is used here.
      await expectLater(
        h.client.lookup('4099999999996'),
        throwsFailure<ProductNotFound>(),
      );
      expect(h.requests, hasLength(1));
    });

    test('a product of another type → NotFood', () async {
      final h = Harness(
        (_) async => jsonResponse(
          '{"code":"3600523614455","status":"failure",'
          '"result":{"id":"product_found_with_a_different_product_type"}}',
          status: 404,
        ),
      );
      await expectLater(
        h.client.lookup('3600523614455'),
        throwsFailure<NotFood>(),
      );
    });

    test('product_type other than food → NotFood', () async {
      final h = Harness(
        (_) async => jsonResponse(
          '{"code":"3600523614455","status":"success",'
          '"product":{"code":"3600523614455","product_type":"beauty"}}',
        ),
      );
      await expectLater(
        h.client.lookup('3600523614455'),
        throwsFailure<NotFood>(),
      );
    });

    test('invalid barcode → InvalidBarcode without any request', () async {
      final h = Harness((_) async => jsonResponse('{}'));
      await expectLater(
        h.client.lookup('3017624010702'),
        throwsFailure<InvalidBarcode>(),
      );
      await expectLater(
        h.client.lookup('abc'),
        throwsFailure<InvalidBarcode>(),
      );
      expect(h.requests, isEmpty);
    });

    test('UPC-E is looked up as the expanded UPC-A', () async {
      final h = Harness((_) async => jsonResponse(fixtureText('crisps.json')));
      await h.client.lookup('04252614');
      expect(h.requests.single.url.path, '/api/v3.4/product/0042100005264');
    });

    test('a valid EAN-8 is sent as it is', () async {
      final h = Harness((_) async => jsonResponse(fixtureText('water.json')));
      final product = await h.client.lookup('42376095');
      expect(h.requests.single.url.path, '/api/v3.4/product/42376095');
      expect(product.nutrients.kcal, 0);
    });
  });

  group('errors and retry', () {
    test('500 is retried exactly once after 1–2 s', () async {
      final h = Harness((_) async => jsonResponse('{}', status: 500));
      await expectLater(
        h.client.lookup('5449000000996'),
        throwsA(
          isA<ServerUnavailable>().having(
            (f) => f.maintenance,
            'maint.',
            false,
          ),
        ),
      );
      expect(h.requests, hasLength(2));
      expect(h.delays, hasLength(1));
      expect(h.delays.single.inMilliseconds, inInclusiveRange(1000, 2000));
    });

    test('the retry can succeed', () async {
      var calls = 0;
      final h = Harness((_) async {
        calls++;
        return calls == 1
            ? jsonResponse('{}', status: 502)
            : jsonResponse(fixtureText('soft_drink.json'));
      });
      final product = await h.client.lookup('5449000000996');
      expect(product.name, 'Coca-Cola');
      expect(h.requests, hasLength(2));
    });

    test('timeout → RequestTimeout after one retry', () async {
      final h = Harness((_) async => throw TimeoutException('slow'));
      await expectLater(
        h.client.lookup('5449000000996'),
        throwsFailure<RequestTimeout>(),
      );
      expect(h.requests, hasLength(2));
    });

    test('ClientException and SocketException → Offline', () async {
      final a = Harness((_) async => throw http.ClientException('no network'));
      await expectLater(
        a.client.lookup('5449000000996'),
        throwsFailure<Offline>(),
      );
      expect(a.requests, hasLength(2));

      final b = Harness((_) async => throw const SocketException('down'));
      await expectLater(
        b.client.lookup('5449000000996'),
        throwsFailure<Offline>(),
      );
    });

    test('retry: false sends only one request', () async {
      final h = Harness((_) async => throw http.ClientException('no network'));
      await expectLater(
        h.client.lookup('5449000000996', retry: false),
        throwsFailure<Offline>(),
      );
      expect(h.requests, hasLength(1));
      expect(h.delays, isEmpty);
    });

    test('broken JSON → ServerUnavailable, not retried', () async {
      final h = Harness((_) async => jsonResponse('{"code": '));
      await expectLater(
        h.client.lookup('5449000000996'),
        throwsFailure<ServerUnavailable>(),
      );
      expect(h.requests, hasLength(1));
    });

    test('an HTML page with status 200 → maintenance', () async {
      final h = Harness((_) async => htmlResponse(200));
      await expectLater(
        h.client.lookup('5449000000996'),
        throwsA(
          isA<ServerUnavailable>().having((f) => f.maintenance, 'maint.', true),
        ),
      );
    });

    test('429 → RateLimited and a 60 s pause without requests', () async {
      final h = Harness((_) async => jsonResponse('{}', status: 429));
      await expectLater(
        h.client.lookup('5449000000996'),
        throwsFailure<RateLimited>(),
      );
      // No retry: it would break the pause.
      expect(h.requests, hasLength(1));

      h.now = h.now.add(const Duration(seconds: 59));
      await expectLater(
        h.client.lookup('4003586100313'),
        throwsFailure<RateLimited>(),
      );
      expect(h.requests, hasLength(1));

      h.now = h.now.add(const Duration(seconds: 2));
      await expectLater(
        h.client.lookup('4003586100313'),
        throwsFailure<RateLimited>(),
      );
      expect(h.requests, hasLength(2));
    });

    test('503 HTML → maintenance and a 60 s pause', () async {
      final h = Harness((_) async => htmlResponse(503));
      final maintenance = throwsA(
        isA<ServerUnavailable>().having((f) => f.maintenance, 'maint.', true),
      );
      await expectLater(h.client.lookup('5449000000996'), maintenance);
      expect(h.requests, hasLength(1));

      // The pause also blocks searches.
      await expectLater(h.client.search('cola'), maintenance);
      expect(h.requests, hasLength(1));
    });
  });

  group('search', () {
    test('Search-a-licious URL with query, page and fields', () async {
      final h = Harness(
        (_) async => jsonResponse(fixtureText('search_haferflocken.json')),
      );
      final page = await h.client.search(' Haferflocken & Milch ', page: 2);

      expect(page.products, hasLength(3));
      final url = h.requests.single.url;
      expect(url.host, 'search.openfoodfacts.org');
      expect(url.path, '/search');
      expect(url.queryParameters['q'], 'Haferflocken & Milch');
      expect(url.queryParameters['langs'], 'de,en');
      expect(url.queryParameters['page'], '2');
      expect(url.queryParameters['page_size'], '20');
      expect(url.queryParameters['fields'], OpenFoodFactsClient.searchFields);
      expect(h.requests.single.headers['User-Agent'], userAgent);
    });

    test('English UI prefers English names', () async {
      final h = Harness(
        (_) async => jsonResponse(fixtureText('search_haferflocken.json')),
      );
      await h.client.search('oats', languageCode: 'en');
      expect(h.requests.single.url.queryParameters['langs'], 'en,de');
    });

    test('an empty query sends nothing', () async {
      final h = Harness((_) async => jsonResponse('{}'));
      final page = await h.client.search('   ');
      expect(page.products, isEmpty);
      expect(h.requests, isEmpty);
    });

    test('two quick searches are spaced 2 s apart', () async {
      final h = Harness(
        (_) async => jsonResponse(fixtureText('search_haferflocken.json')),
      );
      await h.client.search('hafer');
      h.now = h.now.add(const Duration(milliseconds: 500));
      await h.client.search('milch');
      expect(h.delays, [const Duration(milliseconds: 1500)]);
      expect(h.requests, hasLength(2));
    });

    test('a 404 from the search server is a server problem', () async {
      final h = Harness((_) async => jsonResponse('{}', status: 404));
      await expectLater(
        h.client.search('hafer'),
        throwsFailure<ServerUnavailable>(),
      );
    });
  });
}
