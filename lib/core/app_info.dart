import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// The app version from pubspec.yaml, for example `0.1.0`.
///
/// `main()` reads the real value with package_info_plus and overrides this
/// provider. Tests keep the default.
final appVersionProvider = Provider<String>((ref) => 'dev');

/// Link to the public source code. Also sent to Open Food Facts so they know
/// which app makes the requests.
const repositoryUrl = 'https://github.com/mr-dzzs21/food-tracker';

/// One shared HTTP client for the whole app (closed when the app ends).
/// Tests override it with `MockClient` from `package:http/testing.dart`.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});
