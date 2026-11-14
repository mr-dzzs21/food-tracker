import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app.dart';
import 'core/app_info.dart';
import 'core/licenses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();
  final info = await PackageInfo.fromPlatform();

  runApp(
    ProviderScope(
      // No automatic retries: when something fails, the screen shows an error
      // with a "Nochmal versuchen" button instead.
      retry: (_, _) => null,
      overrides: [appVersionProvider.overrideWithValue(info.version)],
      child: const FoodTrackerApp(),
    ),
  );
}
