import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';

/// The top bar of every screen without a green hero: page background, the
/// rounded "‹" back button ([AppBackButton]) when there is a page to go back
/// to, a bold title and optional [actions] (use [SquareIconButton]).
///
/// [large] = the big 26/900 title of a tab ("Scannen"); otherwise the 20/900
/// title of a sub-page.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.actions = const [],
    this.large = false,
  });

  final String? title;
  final List<Widget> actions;
  final bool large;

  @override
  Size get preferredSize => Size.fromHeight(large ? 72 : 64);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // The same rule as the Material AppBar: a back button when this page
    // can be closed.
    final route = ModalRoute.of(context);
    final canGoBack =
        (route?.impliesAppBarDismissal ?? false) || (route?.canPop ?? false);
    final title = this.title;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      leading: canGoBack ? const Center(child: AppBackButton()) : null,
      leadingWidth: 64,
      titleSpacing: canGoBack ? Spacing.xs : Spacing.page,
      title: title == null
          ? null
          : Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: large ? textTheme.headlineSmall : textTheme.titleLarge,
            ),
      actions: [
        ...actions,
        const SizedBox(width: Spacing.m),
      ],
    );
  }
}
