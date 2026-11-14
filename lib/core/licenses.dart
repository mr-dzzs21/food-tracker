import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the licences of bundled files that are not Dart packages to the
/// licence page (`showLicensePage`). Call once at app start.
///
/// The Manrope font is under the SIL Open Font License, which asks that its
/// licence text ships with the app.
void registerAppLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/Manrope-OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Manrope'], text);
  });
}
