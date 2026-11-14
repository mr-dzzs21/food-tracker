import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A white (dark: surface) card with round corners and a soft shadow – the
/// basic container of every screen. With [onTap] the whole card is tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.l),
    this.radius = Radii.card,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Another background, e.g. a tinted note. Defaults to the surface colour.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderRadius = BorderRadius.circular(radius);
    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: color == null ? colors.cardShadow : null,
      ),
      child: Material(
        color: color ?? colors.surface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
