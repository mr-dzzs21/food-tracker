import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'status_view.dart';

/// Temporary page for screens that are still being built.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StatusView(
        icon: Icons.construction_outlined,
        title: AppLocalizations.of(context).placeholderComingSoon,
      ),
    );
  }
}
