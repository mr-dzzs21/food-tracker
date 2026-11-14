import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon.dart';

/// Open Food Facts text search results for [query].
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key, required this.query});

  /// What the user typed.
  final String query;

  @override
  Widget build(BuildContext context) =>
      const ComingSoon(title: 'SearchResultsPage');
}
