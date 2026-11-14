import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database.dart';

// Colour and icon of a meal. They live in the diary feature (not in core),
// because they depend on the stored MealSlot.

/// Which of the six meal palettes ([AppColors.mealPalettes]) a meal uses.
///
/// The four built-in meals always keep their colour (breakfast peach, lunch
/// mint, dinner lavender, snacks butter); the user's own meals continue the
/// cycle by their position (sky, rose, peach, …).
int mealPaletteIndex(MealSlot slot) => switch (slot.builtIn) {
  'breakfast' => 0,
  'lunch' => 1,
  'dinner' => 2,
  'snacks' => 3,
  _ => slot.position,
};

/// The tile colours of [slot] in the current theme.
MealPalette mealPaletteOf(MealSlot slot, AppColors colors) {
  final palettes = colors.mealPalettes;
  return palettes[mealPaletteIndex(slot) % palettes.length];
}

/// The drawn (no emoji) icon of [slot].
IconData mealIconOf(MealSlot slot) => switch (slot.builtIn) {
  'breakfast' => Icons.free_breakfast_rounded,
  'lunch' => Icons.lunch_dining_rounded,
  'dinner' => Icons.dinner_dining_rounded,
  'snacks' => Icons.cookie_rounded,
  _ => Icons.restaurant_rounded,
};
