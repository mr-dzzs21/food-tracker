import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A small heading above a group of content, with an optional widget on the
/// right (for example a button).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.l,
        Spacing.xl,
        Spacing.l,
        Spacing.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          // `?trailing` adds the widget only when it is not null.
          ?trailing,
        ],
      ),
    );
  }
}
