import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';

/// The header of every page: on the page background (no bar, no gradient),
/// a round back button when there is a page to go back to, an optional
/// [overline] (small muted capitals, e.g. the weekday) above a bold [title],
/// and [actions] on the right (use [RoundIconButton]s).
///
/// Use it as `Scaffold.appBar` for a header that stays while the page
/// scrolls (only with a one-line title, no [overline]). With an [overline]
/// put it at the top of the scrolling content instead, so it can grow with
/// large text.
///
/// [large] = the 26/800 title of a tab ("Scannen") or a product; otherwise
/// the 20/800 title of a sub-page. [titleWidget] replaces the title text
/// (e.g. the tappable date on "Heute").
class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.overline,
    this.actions = const [],
    this.large = false,
  });

  final String? title;
  final Widget? titleWidget;
  final String? overline;
  final List<Widget> actions;
  final bool large;

  /// The height as `Scaffold.appBar` (without the status bar).
  @override
  Size get preferredSize => Size.fromHeight(large ? 72 : 64);

  /// The style of [title] (also for a [titleWidget]).
  static TextStyle titleStyle(BuildContext context, {required bool large}) {
    final textTheme = Theme.of(context).textTheme;
    return (large ? textTheme.headlineSmall : textTheme.titleLarge)!;
  }

  /// The small capitals above the title.
  static TextStyle overlineStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!
          .copyWith(color: context.appColors.inkMuted, letterSpacing: 0.96);

  @override
  Widget build(BuildContext context) {
    // The same rule as the Material AppBar: a back button when this page
    // can be closed.
    final route = ModalRoute.of(context);
    final canGoBack =
        (route?.impliesAppBarDismissal ?? false) || (route?.canPop ?? false);
    final title = this.title;
    final overline = this.overline;
    final titleWidget =
        this.titleWidget ??
        (title == null
            ? null
            : Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle(context, large: large),
              ));

    return ColoredBox(
      color: context.appColors.background,
      child: SafeArea(
        bottom: false,
        // A header must not take half of the screen: its texts grow with the
        // text size only up to 1.6×.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.6,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              canGoBack ? Spacing.s : Spacing.page,
              Spacing.xs,
              Spacing.s,
              Spacing.xs,
            ),
            child: Row(
              children: [
                if (canGoBack) ...[
                  const AppBackButton(),
                  const SizedBox(width: Spacing.xs),
                ],
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (overline != null)
                          Text(
                            overline.toUpperCase(),
                            // Screen readers would spell out capitals.
                            semanticsLabel: overline,
                            style: overlineStyle(context),
                          ),
                        if (titleWidget != null)
                          Semantics(header: true, child: titleWidget),
                      ],
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
