import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'section_header.dart';

/// A white card holding several [CardRow]s, separated by thin lines – the
/// app's replacement for plain Material list tiles (settings, food lists).
class CardGroup extends StatelessWidget {
  const CardGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              const Divider(height: 1, indent: Spacing.l, endIndent: Spacing.l),
            child,
          ],
        ],
      ),
    );
  }
}

/// One row inside a [CardGroup] (or alone in an `AppCard`): an optional
/// [leading] icon square, a [title] (15/800), a [subtitle] (13/700 muted) and
/// a [trailing] widget. With [onTap] and no [trailing] it shows a chevron.
///
/// The whole row is one button for screen readers.
class CardRow extends StatelessWidget {
  const CardRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Another title colour, e.g. the rating colour of "Alle Daten löschen".
  final Color? titleColor;

  /// False hides the chevron of a tappable row (e.g. rows that open a sheet
  /// instead of a page).
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final subtitle = this.subtitle;
    final leading = this.leading;
    final onTap = this.onTap;
    final trailing =
        this.trailing ??
        (onTap != null && showChevron
            ? Icon(Icons.chevron_right_rounded, color: colors.inkMuted)
            : null);
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.l,
          Spacing.m,
          Spacing.m,
          Spacing.m,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: Spacing.m)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Spacing.s),
              trailing,
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// A section title ([SectionHeader] style) with a white card below it, both
/// with the page's side padding. Most screens are a list of these.
class CardSection extends StatelessWidget {
  const CardSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(Spacing.l),
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  /// Inner padding of the card ([EdgeInsets.zero] for a [CardGroup]-like
  /// list of rows).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title, trailing: trailing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: AppCard(padding: padding, child: child),
        ),
      ],
    );
  }
}
