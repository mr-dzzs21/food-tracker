// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Food Tracker';

  @override
  String get tabToday => 'Today';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabStats => 'Statistics';

  @override
  String get tabProfile => 'Profile';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String get failureInvalidBarcode =>
      'This barcode looks invalid. Please scan it again.';

  @override
  String get failureNotFound =>
      'We don\'t know this product yet. You can add it yourself.';

  @override
  String get failureNotFood => 'This doesn\'t seem to be a food product.';

  @override
  String get failureIncomplete =>
      'Nutrition values are missing for this product. You can fill them in yourself.';

  @override
  String get failureOffline =>
      'You\'re offline. Your diary still works – product search needs internet.';

  @override
  String get failureTimeout =>
      'Open Food Facts isn\'t responding right now. Try again in a moment.';

  @override
  String get failureRateLimited =>
      'Too many requests in a short time. Wait a minute, then try again.';

  @override
  String get failureServer =>
      'Open Food Facts has a problem right now. Try again later.';

  @override
  String get failureMaintenance =>
      'Open Food Facts is unavailable right now (maintenance or high load). Try again later.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get productUnknownName => 'Unknown product';

  @override
  String get placeholderComingSoon => 'This screen is being built.';

  @override
  String get mealUnnamed => 'Meal';

  @override
  String mealAddTooltip(String meal) {
    return 'Add to $meal';
  }

  @override
  String dayTitleToday(String date) {
    return 'Today, $date';
  }

  @override
  String dayTitleYesterday(String date) {
    return 'Yesterday, $date';
  }

  @override
  String dayTitleTomorrow(String date) {
    return 'Tomorrow, $date';
  }

  @override
  String get dayPrevious => 'Previous day';

  @override
  String get dayNext => 'Next day';

  @override
  String get dayPick => 'Choose a day';

  @override
  String get dayJumpToday => 'Today';

  @override
  String get todayGoalCardTitle => 'Set a goal';

  @override
  String get todayGoalCardText =>
      'With a daily goal, the ring shows how much is left for today.';

  @override
  String get todayGoalCardButton => 'Set goal';

  @override
  String get todayGoalCardDismiss => 'Hide this hint';

  @override
  String get todayRingLeft => 'kcal left';

  @override
  String get todayRingEaten => 'kcal eaten';

  @override
  String get todayRingOver => 'kcal above your goal';

  @override
  String todayRingOfGoal(String goal) {
    return 'of $goal';
  }

  @override
  String todayRingSemanticsLeft(String left, String goal, String eaten) {
    return '$left kcal left of $goal kcal. Eaten: $eaten kcal.';
  }

  @override
  String todayRingSemanticsOver(String over, String goal, String eaten) {
    return '$over kcal above your goal of $goal kcal. Eaten: $eaten kcal.';
  }

  @override
  String todayRingSemanticsEaten(String eaten) {
    return '$eaten kcal eaten. No daily goal set.';
  }

  @override
  String todayEatenLine(String eaten) {
    return 'Eaten: $eaten kcal';
  }

  @override
  String todayMissingValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Values are missing for $count entries',
      one: 'Values are missing for 1 entry',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyDay =>
      'Nothing logged yet. Tap + next to a meal to add food.';

  @override
  String todayMacroOfGoal(String eaten, String goal) {
    return '$eaten of $goal g';
  }

  @override
  String nutrientWithValue(String nutrient, String value) {
    return '$nutrient: $value';
  }

  @override
  String totalAtLeast(String value) {
    return 'at least $value';
  }

  @override
  String totalAtMost(String value) {
    return 'at most $value';
  }

  @override
  String unitGrams(String value) {
    return '$value g';
  }

  @override
  String unitKcal(String value) {
    return '$value kcal';
  }

  @override
  String get diaryEntryDeleted => 'Entry deleted';

  @override
  String get entryAmountLabel => 'Amount';

  @override
  String get entryMealLabel => 'Meal';

  @override
  String get amountInvalid => 'Please enter an amount between 0 and 10,000.';

  @override
  String get nutrientKcal => 'Energy';

  @override
  String get nutrientFat => 'Fat';

  @override
  String get nutrientSaturatedFat => 'Saturates';

  @override
  String get nutrientCarbs => 'Carbohydrate';

  @override
  String get nutrientSugars => 'Sugars';

  @override
  String get nutrientFibre => 'Fibre';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientSalt => 'Salt';

  @override
  String get ratingLevelLow => 'low';

  @override
  String get ratingLevelMedium => 'medium';

  @override
  String get ratingLevelHigh => 'high';

  @override
  String get ratingNoData => 'no data';

  @override
  String get ratingTitle => 'Rating';

  @override
  String get ratingTitleFood => 'Rating per 100 g';

  @override
  String get ratingTitleDrink => 'Rating per 100 ml';

  @override
  String ratingRowSemantics(String nutrient, String level, String value) {
    return '$nutrient: $level, $value';
  }

  @override
  String get ratingNotRated =>
      'This type of product gets no traffic-light rating (e.g. water, coffee, tea, spices, baby food, alcohol). You can see the nutrition values below.';

  @override
  String get ratingNoCategory =>
      'The product type is unknown, so there is no traffic-light rating.';

  @override
  String get ratingSuspicious =>
      'These values look inconsistent and may be wrong.';

  @override
  String get plusFibreSource => 'source of fibre';

  @override
  String get plusFibreHigh => 'high in fibre';

  @override
  String get plusProteinSource => 'source of protein';

  @override
  String get plusProteinHigh => 'high in protein';

  @override
  String plusPointRow(String label, String value) {
    return '$label · $value';
  }

  @override
  String productNutriScore(String grade) {
    return 'Nutri-Score: $grade (according to Open Food Facts)';
  }

  @override
  String get productImageCaption =>
      'Photo: Open Food Facts contributors, CC BY-SA';

  @override
  String get productFavouriteAdd => 'Add to favourites';

  @override
  String get productFavouriteRemove => 'Remove from favourites';

  @override
  String get productAmountTitle => 'How much?';

  @override
  String productServingChip(String amount) {
    return '1 serving ($amount)';
  }

  @override
  String productLastAmountChip(String amount) {
    return 'Last time: $amount';
  }

  @override
  String productDay(String day) {
    return 'Day: $day';
  }

  @override
  String productAdded(String meal) {
    return 'Added to $meal';
  }

  @override
  String get productNutritionTitle => 'Nutrition facts';

  @override
  String get productPer100g => 'per 100 g';

  @override
  String get productPer100ml => 'per 100 ml';

  @override
  String productPerServing(String amount) {
    return 'per serving ($amount)';
  }

  @override
  String get productAttribution => 'Data: Open Food Facts (ODbL)';

  @override
  String get productCorrectHint =>
      'Wrong data? You can correct it on Open Food Facts.';

  @override
  String get productOpenOff => 'View on Open Food Facts';

  @override
  String get productLinkFailed => 'The link could not be opened.';

  @override
  String get productCreateOwn => 'Add it yourself';

  @override
  String get productCompleteValues => 'Complete the values';

  @override
  String get productGone => 'This food no longer exists.';

  @override
  String get disclaimerShort =>
      'Data from Open Food Facts. Values can be wrong. The rating is for guidance only and is not medical advice.';

  @override
  String get disclaimerRating =>
      'The rating is for guidance only and is not medical advice.';

  @override
  String get searchFieldHint => 'Search for a product';

  @override
  String get searchSubmit => 'Search';

  @override
  String get scanRecentlyViewedTitle => 'Recently viewed';

  @override
  String get scanRecentlyViewedEmpty =>
      'Products you scan or search for appear here.';

  @override
  String get scannerTitle => 'Scan barcode';

  @override
  String get scannerHint => 'Point the camera at a barcode.';

  @override
  String get scannerPreviewLabel => 'Camera for scanning barcodes';

  @override
  String get scannerTorchOn => 'Turn on the light';

  @override
  String get scannerTorchOff => 'Turn off the light';

  @override
  String get scannerPermissionTitle => 'No access to the camera';

  @override
  String get scannerPermissionText =>
      'To scan, allow camera access in your device settings (Settings › Food Tracker › Camera). Until then you can use the search.';

  @override
  String get scannerUnsupported => 'There is no camera here. Use the search.';

  @override
  String get scannerError =>
      'The camera could not start. Try again or use the search.';

  @override
  String searchResultsTitle(String query) {
    return 'Search: $query';
  }

  @override
  String get searchEmptyQuery => 'Type what you are looking for.';

  @override
  String get searchLocalTitle => 'On your device';

  @override
  String get searchOnlineTitle => 'Online results';

  @override
  String get searchNoOnlineResults => 'No results at Open Food Facts.';

  @override
  String get searchNoResultsHint =>
      'Check the spelling or add the food yourself.';

  @override
  String get searchLoadMore => 'Load more';

  @override
  String searchNutriScore(String grade) {
    return 'Nutri-Score: $grade';
  }

  @override
  String foodKcalPer100g(String kcal) {
    return '$kcal kcal per 100 g';
  }

  @override
  String foodKcalPer100ml(String kcal) {
    return '$kcal kcal per 100 ml';
  }

  @override
  String get foodKcalUnknown => 'Calories unknown';

  @override
  String addFoodTitle(String meal, String day) {
    return '$meal · $day';
  }

  @override
  String get addFoodSearchHint => 'Search foods';

  @override
  String get addFoodScan => 'Scan';

  @override
  String get addFoodCreateOwn => 'Own food';

  @override
  String get addFoodSegmentRecent => 'Recent';

  @override
  String get addFoodSegmentFavourites => 'Favourites';

  @override
  String get addFoodSegmentOwn => 'My foods';

  @override
  String get addFoodRecentEmpty =>
      'Nothing here yet. Foods you add to your diary appear here.';

  @override
  String get addFoodFavouritesEmpty =>
      'No favourites yet. Tap the star on a product page.';

  @override
  String get addFoodOwnEmpty => 'No own foods yet. Create one with “Own food”.';

  @override
  String get addFoodNoLocalMatches =>
      'Nothing found on your device. Tap “Search” on the keyboard to search online.';

  @override
  String get foodFormNewTitle => 'New food';

  @override
  String get foodFormEditTitle => 'Edit food';

  @override
  String foodFormRequired(String label) {
    return '$label *';
  }

  @override
  String get foodFormRequiredHint => '* required';

  @override
  String get foodFormName => 'Name';

  @override
  String get foodFormBrand => 'Brand (optional)';

  @override
  String get foodFormBarcode => 'Barcode';

  @override
  String get foodFormIsLiquid => 'Drink (values per 100 ml)';

  @override
  String get foodFormNutrientsPer100g => 'Nutrition per 100 g';

  @override
  String get foodFormNutrientsPer100ml => 'Nutrition per 100 ml';

  @override
  String get foodFormPortionTitle => 'Portion (optional)';

  @override
  String get foodFormPortionSize => 'Size of one portion';

  @override
  String get foodFormPortionLabel => 'Portion name';

  @override
  String get foodFormPortionLabelHint => 'e.g. 1 slice';

  @override
  String get foodFormNameMissing => 'Please enter a name.';

  @override
  String get foodFormKcalMissing => 'Please enter the calories.';

  @override
  String get foodFormNotANumber => 'Please enter a number.';

  @override
  String foodFormOutOfRange(String max) {
    return 'Allowed: 0 to $max';
  }

  @override
  String get foodFormSaturatesAboveFat => 'Can\'t be more than fat.';

  @override
  String get foodFormSugarsAboveCarbs => 'Can\'t be more than carbohydrate.';

  @override
  String get foodFormPortionSizeMissing =>
      'Please also enter the size of one portion.';

  @override
  String foodFormDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get foodFormDeleteText => 'Entries in your diary are kept.';

  @override
  String foodFormDeleted(String name) {
    return '“$name” deleted';
  }
}
