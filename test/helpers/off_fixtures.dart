import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Recorded (and trimmed) Open Food Facts responses in test/fixtures/off/.
///
/// `flutter test` runs in the project folder, so a relative path works.
String fixtureText(String name) =>
    File('test/fixtures/off/$name').readAsStringSync();

/// A fixture as a JSON object.
Map<String, Object?> fixtureJson(String name) =>
    jsonDecode(fixtureText(name)) as Map<String, Object?>;

/// The `product` object of a recorded product response.
Map<String, Object?> fixtureProduct(String name) =>
    fixtureJson(name)['product']! as Map<String, Object?>;

/// An HTTP response with a JSON body, like Open Food Facts sends it.
http.Response jsonResponse(String body, {int status = 200}) => http.Response(
  body,
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
