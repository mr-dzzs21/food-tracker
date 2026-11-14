import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// Opens [uri] outside the app (browser, phone app, …).
///
/// Shows a SnackBar "Der Link konnte nicht geöffnet werden." when that is not
/// possible, for example `tel:` links on a device without a phone app.
Future<void> openLink(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = AppLocalizations.of(context).linkOpenFailed;
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
}
