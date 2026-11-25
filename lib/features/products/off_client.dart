import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;

import '../../core/errors.dart';
import 'gtin.dart';
import 'off_product_mapper.dart';

/// Waits for [duration]. Tests pass a function that returns at once.
typedef Delay = Future<void> Function(Duration duration);

/// A small client for the Open Food Facts API.
///
/// - Product lookup by barcode: `world.openfoodfacts.org/api/v3.4/…`
/// - Text search: `search.openfoodfacts.org` (the only working full-text
///   search of OFF today).
///
/// Every problem is thrown as an [AppFailure], so the UI can show a friendly
/// message. Rules: .notes/research/off-api.md, R1, R2, R8–R11.
class OpenFoodFactsClient {
  OpenFoodFactsClient(
    this._http, {
    required this.userAgent,
    Clock? clock,
    Delay? delay,
    Random? random,
  }) : _clock = clock ?? const Clock(),
       _delay = delay ?? Future<void>.delayed,
       _random = random ?? Random();

  /// API version for product lookups. v3.5 and later use a new nutrition
  /// format that OFF still calls "under development"; v3.4 is the newest
  /// version with the simple `nutriments` object. Change it only together
  /// with off_product_mapper.dart.
  static const productApiVersion = 'v3.4';

  /// The fields we ask for. Without this list a response can be 150 KB;
  /// with it, 2–4 KB.
  static const productFields =
      'code,product_name,product_name_de,product_name_en,generic_name,'
      'generic_name_de,abbreviated_product_name,brands,quantity,'
      'product_quantity,product_quantity_unit,serving_size,serving_quantity,'
      'serving_quantity_unit,nutrition_data_per,image_front_small_url,'
      'image_front_thumb_url,nutriments,nutrient_levels,nutriscore_grade,'
      'nutriscore_version,nova_group,categories_tags,lang,completeness,'
      'states_tags,product_type';

  /// Since 2026-11 the search service no longer returns `nutriments`;
  /// `nutriscore_data` still holds the energy (kcal for the result list).
  static const searchFields =
      'code,product_name,brands,quantity,image_front_small_url,'
      'nutriscore_grade,nutriscore_data,completeness';

  /// Text searches only find products sold in Germany (owner decision: the
  /// list was full of foreign brands). Barcode lookups stay worldwide – the
  /// user holds the product in their hand. The field is `countries` (the
  /// search service rejects `countries_tags`).
  static const searchCountryFilter = 'countries:"en:germany"';

  static const productHost = 'world.openfoodfacts.org';
  static const searchHost = 'search.openfoodfacts.org';

  /// Our own choice; OFF names no timeout.
  static const requestTimeout = Duration(seconds: 10);

  /// After "too many requests" (429) or "unavailable" (503) we leave OFF
  /// alone for a minute, as their rules ask.
  static const coolDown = Duration(seconds: 60);

  /// OFF allows only about 10 searches per minute, so searches are spaced
  /// out a little.
  static const minSearchInterval = Duration(seconds: 2);

  final http.Client _http;

  /// Tells OFF which app is asking, for example
  /// `FoodTracker/0.1.0 (https://github.com/mr-dzzs21/food-tracker)`.
  final String userAgent;
  final Clock _clock;
  final Delay _delay;
  final Random _random;

  DateTime? _blockedUntil;
  AppFailure? _blockedBecause;
  DateTime? _lastSearchAt;

  /// Looks up one product by [barcode].
  ///
  /// The barcode is checked first ([InvalidBarcode] without any request).
  /// [languageCode] decides which product name is picked. With [retry], a
  /// temporary problem (timeout, no network, server error) is tried once
  /// more after 1–2 seconds.
  ///
  /// Throws [ProductNotFound], [NotFood], [Offline], [RequestTimeout],
  /// [RateLimited] or [ServerUnavailable].
  Future<OffProduct> lookup(
    String barcode, {
    String languageCode = 'de',
    bool retry = true,
  }) async {
    final code = lookupCodeFor(barcode);
    if (code == null) throw InvalidBarcode(barcode);

    final uri = Uri.https(
      productHost,
      '/api/$productApiVersion/product/$code',
      {'lc': languageCode, 'fields': productFields},
    );
    final response = await _getJson(uri, retry: retry);
    final body = response.body;

    final result = body['result'];
    final resultId = result is Map<String, Object?> ? result['id'] : null;
    if (resultId == 'product_found_with_a_different_product_type') {
      throw NotFood(code);
    }
    final product = body['product'];
    if (response.statusCode == 404 ||
        body['status'] == 'failure' ||
        product is! Map<String, Object?>) {
      throw ProductNotFound(code);
    }

    final parsed = parseOffProduct(
      product,
      languageCode: languageCode,
      requestedCode: code,
    );
    final type = parsed.productType;
    if (type != null && type != 'food') throw NotFood(code);
    return parsed;
  }

  /// Searches products by text. Call it on submit or after the user stopped
  /// typing for a moment, never for every key press (OFF rules); searches
  /// are spaced out by [minSearchInterval].
  ///
  /// [page] starts at 1. An empty [query] gives an empty result without a
  /// request. Only products sold in Germany are found
  /// ([searchCountryFilter]).
  ///
  /// When [cancel] completes (nobody needs the results any more, for example
  /// because the user typed on), a search still waiting for its turn is not
  /// sent and a running request is aborted; both throw [SearchCancelled].
  Future<OffSearchPage> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    String languageCode = 'de',
    Future<void>? cancel,
  }) async {
    // Quotes and colons mean something in the search syntax ("field:value")
    // and would break the country filter, so they become spaces.
    final words = query
        .replaceAll(RegExp('[":]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    if (words.isEmpty) return OffSearchPage.empty;

    var cancelled = false;
    if (cancel != null) unawaited(cancel.then((_) => cancelled = true));
    await _waitForSearchSlot();
    // Waiting for the slot can take two seconds – the user may have typed on.
    if (cancelled) throw const SearchCancelled();
    _lastSearchAt = _clock.now();
    final uri = Uri.https(searchHost, '/search', {
      // Words and filter are combined with AND.
      'q': '$words $searchCountryFilter',
      // Names in the UI language are preferred.
      'langs': languageCode == 'en' ? 'en,de' : 'de,en',
      'page_size': '$pageSize',
      'page': '$page',
      'fields': searchFields,
    });
    final response = await _getJson(
      uri,
      retry: true,
      cancel: cancel,
      isCancelled: () => cancelled,
    );
    if (response.statusCode != 200) throw const ServerUnavailable();
    return parseOffSearchPage(response.body, languageCode: languageCode);
  }

  /// Sends a GET request and returns the JSON object, trying once more after
  /// a temporary problem when [retry] is true (not when [isCancelled] says
  /// the result is no longer needed).
  Future<_JsonResponse> _getJson(
    Uri uri, {
    required bool retry,
    Future<void>? cancel,
    bool Function()? isCancelled,
  }) async {
    _throwIfCoolingDown();
    try {
      return await _send(uri, cancel);
    } on _TemporaryFailure catch (first) {
      if (!retry) throw first.failure;
      // Wait 1–2 s. The random part ("jitter") keeps many phones from
      // retrying at exactly the same moment.
      await _delay(Duration(milliseconds: 1000 + _random.nextInt(1001)));
      if (isCancelled?.call() ?? false) throw const SearchCancelled();
      try {
        return await _send(uri, cancel);
      } on _TemporaryFailure catch (second) {
        throw second.failure;
      }
    }
  }

  /// One request; [cancel] aborts it. Throws [_TemporaryFailure] for
  /// problems worth one more try, and an [AppFailure] for everything else.
  Future<_JsonResponse> _send(Uri uri, [Future<void>? cancel]) async {
    final http.Response response;
    try {
      final request = http.AbortableRequest('GET', uri, abortTrigger: cancel)
        ..headers.addAll({
          'User-Agent': userAgent,
          'Accept': 'application/json',
        });
      response = await _http
          .send(request)
          .then(http.Response.fromStream)
          .timeout(requestTimeout);
    } on http.RequestAbortedException {
      // Must come before ClientException (its parent class): not "offline".
      throw const SearchCancelled();
    } on TimeoutException {
      throw const _TemporaryFailure(RequestTimeout());
    } on SocketException {
      throw const _TemporaryFailure(Offline());
    } on http.ClientException {
      throw const _TemporaryFailure(Offline());
    }

    final status = response.statusCode;
    final isJson = (response.headers['content-type'] ?? '').contains('json');
    if (status == 429) {
      _startCoolDown(const RateLimited());
    }
    if (status == 503) {
      // Often an HTML page "temporarily unavailable" (maintenance/overload).
      _startCoolDown(ServerUnavailable(maintenance: !isJson));
    }
    if (!isJson) {
      // An HTML page instead of data: maintenance, overload or a Wi-Fi
      // login page.
      const failure = ServerUnavailable(maintenance: true);
      throw status >= 500 ? const _TemporaryFailure(failure) : failure;
    }
    if (status >= 500) throw const _TemporaryFailure(ServerUnavailable());

    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ServerUnavailable();
    }
    // 404 is a normal answer of the product API ("not found").
    if (body is! Map<String, Object?> || (status != 200 && status != 404)) {
      throw const ServerUnavailable();
    }
    return (statusCode: status, body: body);
  }

  /// Blocks all requests for [coolDown] and throws [reason].
  ///
  /// No retry here on purpose: a retry 1–2 s later would break the
  /// "leave OFF alone for a minute" rule.
  Never _startCoolDown(AppFailure reason) {
    _blockedUntil = _clock.now().add(coolDown);
    _blockedBecause = reason;
    throw reason;
  }

  void _throwIfCoolingDown() {
    final until = _blockedUntil;
    if (until != null && _clock.now().isBefore(until)) {
      throw _blockedBecause ?? const RateLimited();
    }
  }

  /// Waits until [minSearchInterval] has passed since the last search that
  /// was sent.
  Future<void> _waitForSearchSlot() async {
    final last = _lastSearchAt;
    if (last != null) {
      final waited = _clock.now().difference(last);
      if (waited < minSearchInterval) await _delay(minSearchInterval - waited);
    }
  }
}

/// Thrown by [OpenFoodFactsClient.search] when its `cancel` future completed
/// before the answer arrived. Not an [AppFailure]: nobody shows it, the
/// screen already asks for another search.
class SearchCancelled implements Exception {
  const SearchCancelled();
}

typedef _JsonResponse = ({int statusCode, Map<String, Object?> body});

/// A problem that may go away by itself (timeout, no network, server error).
class _TemporaryFailure implements Exception {
  const _TemporaryFailure(this.failure);
  final AppFailure failure;
}
