import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// The sticky area at the bottom of a page for its main button (usually a
/// `CtaButton`, which brings its own soft glow): page background,
/// safe-area aware.
///
/// Use it as `Scaffold.bottomNavigationBar`, so the button is always
/// reachable however far the page is scrolled.
class BottomCtaBar extends StatelessWidget {
  const BottomCtaBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appColors.background,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.m,
          Spacing.l,
          Spacing.l,
        ),
        child: child,
      ),
    );
  }
}
