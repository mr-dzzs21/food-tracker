import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// One tab of the [AppNavBar].
@immutable
class AppNavDestination {
  const AppNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The app's own bottom navigation bar (replaces Material's NavigationBar).
///
/// A white bar with round top corners and a soft upward shadow. The tab at
/// [raisedIndex] (Scannen) is a big green square that sticks out [raise] px
/// above the bar. The selected tab is shown in the brand colour.
///
/// Use it with `Scaffold(extendBody: true)`, so the page is visible behind
/// the transparent strip next to the raised button (see `HomeShell`).
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.raisedIndex,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int? raisedIndex;

  /// How far the raised button sticks out above the bar.
  static const double raise = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    // Tab labels grow with the text size, but only up to 1.4×: the bar must
    // not cover half of the screen (iOS does not scale them at all).
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: Stack(
        children: [
          Positioned.fill(
            top: raise,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Radii.sheet),
                ),
                boxShadow: colors.barShadow,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: safeBottom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      raised: i == raisedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.raised,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final bool raised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = selected ? colors.brand : colors.navInactive;
    final label = Text(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: color),
    );

    final Widget content;
    if (raised) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: colors.scanGradient,
              borderRadius: BorderRadius.circular(Radii.scanButton),
              boxShadow: [
                BoxShadow(
                  color: colors.heroMid.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(destination.icon, color: colors.onHero, size: 28),
          ),
          const SizedBox(height: 6),
          label,
          const SizedBox(height: Spacing.s),
        ],
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(destination.icon, color: color, size: 26),
            const SizedBox(height: 2),
            label,
            const SizedBox(height: Spacing.s),
          ],
        ),
      );
    }

    final item = Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: content,
      ),
    );
    // Normal tabs start below the strip the raised button sticks into, so
    // taps in that strip reach the page behind it.
    return raised
        ? item
        : Padding(
            padding: const EdgeInsets.only(top: AppNavBar.raise),
            child: item,
          );
  }
}
