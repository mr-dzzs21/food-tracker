import 'package:material_ui/material_ui.dart';

/// The calm green the whole colour scheme is generated from.
const seedColor = Color(0xFF2E7D5B);

/// Spacing steps. Use these instead of random numbers so the app looks even.
abstract final class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii for cards, buttons and sheets.
abstract final class Radii {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

/// Colours the Material [ColorScheme] does not have: the traffic light of the
/// health rating and one colour per macro nutrient.
///
/// Rating colours are only an *extra* hint. The app always shows an icon and a
/// word as well, so colour-blind people get the same information.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ratingLow,
    required this.ratingMedium,
    required this.ratingHigh,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  /// Text/icon colours for "low", "medium" and "high". Each has at least 4.5:1
  /// contrast on the theme's surface colours (checked in a test).
  final Color ratingLow;
  final Color ratingMedium;
  final Color ratingHigh;

  /// Bar colours for the three macro nutrients.
  final Color protein;
  final Color carbs;
  final Color fat;

  static const light = AppColors(
    ratingLow: Color(0xFF2A7230),
    ratingMedium: Color(0xFF8A5300),
    ratingHigh: Color(0xFFB3261E),
    protein: Color(0xFF2B6CB0),
    carbs: Color(0xFFB7791F),
    fat: Color(0xFF8E44AD),
  );

  static const dark = AppColors(
    ratingLow: Color(0xFF8BD68F),
    ratingMedium: Color(0xFFFFC857),
    ratingHigh: Color(0xFFFFA59E),
    protein: Color(0xFF8AB8F0),
    carbs: Color(0xFFF2C14E),
    fat: Color(0xFFD7A6EB),
  );

  @override
  AppColors copyWith({
    Color? ratingLow,
    Color? ratingMedium,
    Color? ratingHigh,
    Color? protein,
    Color? carbs,
    Color? fat,
  }) {
    return AppColors(
      ratingLow: ratingLow ?? this.ratingLow,
      ratingMedium: ratingMedium ?? this.ratingMedium,
      ratingHigh: ratingHigh ?? this.ratingHigh,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ratingLow: Color.lerp(ratingLow, other.ratingLow, t)!,
      ratingMedium: Color.lerp(ratingMedium, other.ratingMedium, t)!,
      ratingHigh: Color.lerp(ratingHigh, other.ratingHigh, t)!,
      protein: Color.lerp(protein, other.protein, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
    );
  }
}

/// Builds the light or dark theme of the app.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      brightness == Brightness.light ? AppColors.light : AppColors.dark,
    ],
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide.none,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Short access to the app colours: `context.appColors.ratingHigh`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
