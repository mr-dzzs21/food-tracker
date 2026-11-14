import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// One tab of the [AppNavBar].
@immutable
class AppNavDestination {
  const AppNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The app's own bottom navigation bar (replaces Material's NavigationBar):
/// a dark pill that floats 18 px above the bottom edge (and the safe area).
///
/// The selected tab becomes a mint pill with icon and label; the other tabs
/// show only their icon (with a tooltip). When the selection changes, the
/// pills grow and shrink smoothly (no animation with reduced motion).
///
/// Use it as `Scaffold.bottomNavigationBar`: the page then ends above it.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Height of the dark bar.
  static const double height = 62;

  /// Space between the bar and the screen edges.
  static const double margin = 18;

  /// The share of the bar's width the selected tab gets.
  static const double selectedShare = 0.4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : shortAnimationDuration;
    // The label grows with the text size, but only up to 1.4×: the bar
    // keeps its height (iOS does not scale tab labels at all).
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: margin),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: margin),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
            decoration: BoxDecoration(
              color: colors.navBar,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: colors.navShadow,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = destinations.length;
                final otherShare = (1 - selectedShare) / (count - 1);
                return Row(
                  children: [
                    for (var i = 0; i < count; i++)
                      // The share of the width animates (not the width
                      // itself), so the tabs follow a new screen width at
                      // once. Both shares change with the same curve, so
                      // the tabs always fill the bar exactly.
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: i == selectedIndex ? selectedShare : otherShare,
                        ),
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        builder: (context, share, child) => SizedBox(
                          width: constraints.maxWidth * share,
                          child: child,
                        ),
                        child: _NavItem(
                          destination: destinations[i],
                          selected: i == selectedIndex,
                          duration: duration,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? colors.onNavActive : colors.navInactive;
    final pill = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected
            ? colors.navActive
            : colors.navActive.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(destination.icon, color: foreground, size: 22),
          if (selected) ...[
            const SizedBox(width: Spacing.s),
            Flexible(
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge!
                    .copyWith(fontSize: 13, color: foreground),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
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
        child: Center(
          // The other tabs show only their icon: the tooltip names them.
          child: Tooltip(
            message: destination.label,
            excludeFromSemantics: true,
            child: pill,
          ),
        ),
      ),
    );
  }
}
