import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A small rounded square with an icon on a tinted background – used at the
/// start of list rows and on meal cards.
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 34,
    this.iconSize = 20,
    this.radius = Radii.m,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;

  /// Corner radius; bigger squares look better with a bigger one.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: foreground),
    );
  }
}
