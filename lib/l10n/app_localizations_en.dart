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
  String get mealUnnamed => 'Meal';

  @override
  String mealAddTooltip(String slot, String meal) {
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
  String get dayTodayBadge => 'Today';

  @override
  String get todayGoalCardTitle => 'Set your daily goal';

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
  String todayRingSemanticsEaten(String eaten, String reference) {
    return '$eaten kcal eaten of a reference intake of $reference kcal. No daily goal set.';
  }

  @override
  String todayRingOfReference(String reference) {
    return 'of $reference kcal (reference)';
  }

  @override
  String todayEatenGoalLine(String eaten, String goal) {
    return 'Eaten $eaten · goal $goal kcal';
  }

  @override
  String get todayReferenceNote =>
      'Without a goal, the ring and bars show the EU reference intakes for adults.';

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
  String todayMacroOfReference(String eaten, String reference) {
    return '$eaten of $reference g (reference)';
  }

  @override
  String todayMacroCompact(String eaten, String goal) {
    return '$eaten/$goal g';
  }

  @override
  String todayMealEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'Nothing yet',
    );
    return '$_temp0';
  }

  @override
  String todayMealTileSemantics(String meal, String entries, String kcal) {
    return '$meal: $entries, $kcal kcal';
  }

  @override
  String get todayMealTileHint => 'Show entries';

  @override
  String get mealSheetEmpty => 'Nothing logged here yet.';

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
  String foodPortionLabel(String portion, String amount) {
    return '$portion ($amount)';
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
  String productAdded(String slot, String meal) {
    return 'Added to $meal';
  }

  @override
  String productAddToMeal(
    String amount,
    String slot,
    String meal,
    String kcal,
  ) {
    return 'Add $amount to $meal · $kcal';
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
  String get blsAttribution =>
      'Data: Bundeslebensmittelschlüssel 4.0, Max Rubner-Institut (CC BY 4.0)';

  @override
  String get blsOpenWebsite => 'Open blsdb.de';

  @override
  String get productBlsAverages =>
      'Average values for this kind of food. Individual products can differ.';

  @override
  String get productAverageChip => 'Average values';

  @override
  String productOffAverages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Average of $count products from Open Food Facts.',
      one: 'Average of 1 product from Open Food Facts.',
    );
    return '$_temp0 Individual products can differ.';
  }

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
  String get searchFoodsTitle => 'Foods';

  @override
  String get searchFoodsAttribution =>
      'Average values: Bundeslebensmittelschlüssel 4.0, Max Rubner-Institut (CC BY 4.0), and Open Food Facts (ODbL)';

  @override
  String get searchMoreFoods => 'More foods (BLS)';

  @override
  String get searchFewerFoods => 'Hide more foods';

  @override
  String get searchOnlineTitle => 'Brand products (Germany)';

  @override
  String get searchNoOnlineResults => 'No results at Open Food Facts.';

  @override
  String get searchNoResultsHint =>
      'Check the spelling or add the food yourself.';

  @override
  String get searchLoadMore => 'Load more';

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

  @override
  String get linkOpenFailed => 'The link could not be opened.';

  @override
  String get disclaimerGoals =>
      'These are estimates for healthy adults. If you are ill, pregnant, breastfeeding or unsure, talk to a doctor or a registered dietitian.';

  @override
  String get helpEdTitle => 'Help with eating disorders';

  @override
  String get helpEdText =>
      'If food or weight is weighing heavily on you, talk to someone you trust or a doctor. In Germany, the eating disorder helpline of the BIÖG (Federal Institute for Public Health) gives anonymous advice in German:';

  @override
  String helpEdCall(String number) {
    return 'Call $number';
  }

  @override
  String get helpEdHours =>
      'Mon–Thu 10 am–10 pm, Fri–Sun 10 am–6 pm (German time)';

  @override
  String helpEdWebsite(String address) {
    return 'Website: $address';
  }

  @override
  String get goalTitle => 'Daily goal';

  @override
  String get goalModeCalculate => 'Calculate';

  @override
  String get goalModeManual => 'Enter myself';

  @override
  String get goalSexLabel => 'Sex';

  @override
  String get goalSexMale => 'male';

  @override
  String get goalSexFemale => 'female';

  @override
  String get goalSexUnspecified => 'not specified';

  @override
  String get goalAgeLabel => 'Age';

  @override
  String get goalAgeSuffix => 'years';

  @override
  String get goalHeightLabel => 'Height';

  @override
  String get goalWeightLabel => 'Weight';

  @override
  String get goalAgeInvalid => 'Please enter an age from 1 to 120 years.';

  @override
  String get goalHeightInvalid => 'Please enter a height from 100 to 250 cm.';

  @override
  String get goalWeightInvalid => 'Please enter a weight from 30 to 300 kg.';

  @override
  String get goalActivityLabel => 'How active are you?';

  @override
  String get goalActivityLow => 'Not very active';

  @override
  String get goalActivityLowText =>
      'Mostly sitting, little exercise in your free time';

  @override
  String get goalActivityLight => 'Somewhat active';

  @override
  String get goalActivityLightText =>
      'Sitting, but regularly walking or cycling, or sport 1–2 times a week';

  @override
  String get goalActivityActive => 'Active';

  @override
  String get goalActivityActiveText =>
      'A lot of standing or walking at work, or sport 3–5 times a week';

  @override
  String get goalActivityVeryActive => 'Very active';

  @override
  String get goalActivityVeryActiveText =>
      'Hard physical work or a lot of sport';

  @override
  String get goalTypeLabel => 'Your goal';

  @override
  String get goalTypeMaintain => 'Keep my weight';

  @override
  String get goalTypeLoseSlow => 'Lose slowly (0.25 kg/week)';

  @override
  String get goalTypeLose => 'Lose weight (0.5 kg/week)';

  @override
  String get goalTypeGainSlow => 'Gain slowly (0.25 kg/week)';

  @override
  String get goalResultTitle => 'Your result';

  @override
  String get goalResultMissing =>
      'Fill in age, height and weight to see your result here.';

  @override
  String get goalResultBmr => 'Basal metabolic rate';

  @override
  String get goalResultTotal => 'Total need';

  @override
  String get goalResultGoal => 'Daily goal';

  @override
  String goalApprox(String kcal) {
    return 'approx. $kcal kcal';
  }

  @override
  String get goalEstimateNote =>
      'These are estimates. Your body adapts over time, so your weight usually changes more slowly than calculated.';

  @override
  String goalFloorNote(String kcal) {
    return 'We do not suggest less than $kcal kcal per day.';
  }

  @override
  String get goalMinorTitle => 'Note for under-18s';

  @override
  String get goalMinorText =>
      'The formula was developed for adults. While you are still growing, you often need more energy. If you have questions, talk to your paediatrician or family doctor.';

  @override
  String get goalApply => 'Use this goal';

  @override
  String get goalSaved => 'Your daily goal has been saved.';

  @override
  String get goalManualKcal => 'Calories per day';

  @override
  String goalManualKcalInvalid(String max) {
    return 'Please enter a value from 1 to $max kcal.';
  }

  @override
  String get goalManualMacrosTitle => 'Macronutrients (optional)';

  @override
  String get goalManualMacrosHint =>
      'Empty fields are filled with defaults: 15 % protein, 30 % fat and the rest carbohydrates.';

  @override
  String goalMacroInvalid(String max) {
    return 'Please enter a value from 0 to $max g.';
  }

  @override
  String goalBelowFloorTitle(String kcal) {
    return 'Less than $kcal kcal?';
  }

  @override
  String goalBelowFloorText(String kcal) {
    return 'Your goal is below $kcal kcal per day. Eating this little for a longer time is best done with medical support. Do you want to save it anyway?';
  }

  @override
  String get goalBelowFloorChange => 'Change';

  @override
  String get goalBelowFloorSave => 'Save anyway';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileInfoTitle => 'Help & info';

  @override
  String get profileGoalTitle => 'Your daily goal';

  @override
  String get profileGoalNone => 'No goal yet';

  @override
  String get profileGoalNoneText =>
      'With a goal, the ring on “Today” shows how much is left.';

  @override
  String get profileGoalSet => 'Set a goal';

  @override
  String get profileGoalChange => 'Change goal';

  @override
  String profileGoalKcal(String kcal) {
    return '$kcal kcal per day';
  }

  @override
  String get profileTheme => 'Appearance';

  @override
  String get profileLanguage => 'Language';

  @override
  String get settingSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileAbout => 'About the app & licences';

  @override
  String get profileDeleteAll => 'Delete all data';

  @override
  String get profileDeleteAllTitle => 'Delete all data?';

  @override
  String get profileDeleteAllText =>
      'Your diary, your own and saved foods, your goal and your settings will be deleted, and the meals are reset. This cannot be undone.';

  @override
  String get profileDeleteAllConfirm => 'Delete everything';

  @override
  String get profileDeleteAllDone => 'All data has been deleted.';

  @override
  String get mealsTitle => 'Meals';

  @override
  String get mealsSubtitle => 'Rename, hide, reorder';

  @override
  String get mealsHint =>
      'Drag the handle to change the order. The time decides which meal is suggested when you add food.';

  @override
  String mealsStartTime(String time) {
    return 'from $time';
  }

  @override
  String get mealsNoStartTime => 'no time';

  @override
  String get mealsHidden => 'hidden';

  @override
  String mealsShow(String meal) {
    return 'Show $meal';
  }

  @override
  String mealsMove(String meal) {
    return 'Move $meal';
  }

  @override
  String get mealsAdd => 'Add meal';

  @override
  String get mealsEditTitle => 'Edit meal';

  @override
  String get mealsNewTitle => 'New meal';

  @override
  String get mealsNameLabel => 'Name';

  @override
  String mealsNameDefaultHint(String name) {
    return 'Leave empty for “$name”';
  }

  @override
  String get mealsNameMissing => 'Please enter a name.';

  @override
  String get mealsStartTimeLabel => 'Suggested from';

  @override
  String get mealsPickTime => 'Choose time';

  @override
  String get mealsClearTime => 'No time';

  @override
  String get mealsLastVisible => 'At least one meal must stay visible.';

  @override
  String mealsDeleteTitle(String meal) {
    return 'Delete “$meal”?';
  }

  @override
  String get mealsDeleteText =>
      'This meal has no diary entries and will be removed.';

  @override
  String mealsDeleted(String meal) {
    return '“$meal” deleted';
  }

  @override
  String get mealsInUseTitle => 'This meal is in use';

  @override
  String mealsInUseText(String meal) {
    return 'Your diary has entries in “$meal”. So that past days stay complete, it cannot be deleted – but you can hide it.';
  }

  @override
  String get mealsInUseHide => 'Hide';

  @override
  String get myFoodsTitle => 'My foods';

  @override
  String get myFoodsEmpty => 'No own foods yet';

  @override
  String get myFoodsEmptyText =>
      'Create foods that Open Food Facts does not know – for example something you cooked yourself.';

  @override
  String get myFoodsCreate => 'Create own food';

  @override
  String myFoodsMore(String name) {
    return 'More for $name';
  }

  @override
  String get aboutTitle => 'About the app';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOpenSource => 'Open source (MIT)';

  @override
  String get aboutOpenSourceText =>
      'The source code is public. You may read it, improve it and share it.';

  @override
  String get aboutSourceCode => 'Source code on GitHub';

  @override
  String get aboutDataSourceTitle => 'Data sources';

  @override
  String get aboutDataSourceText =>
      'Product data comes from Open Food Facts (openfoodfacts.org) and is available under the Open Database License (ODbL); individual contents under the Database Contents License (DbCL), product photos under Creative Commons BY-SA. The data is maintained by volunteers and may be incomplete or wrong – when in doubt, check the package.';

  @override
  String get aboutOpenOff => 'Open openfoodfacts.org';

  @override
  String get aboutBlsText =>
      'Most foods with average values come from the Bundeslebensmittelschlüssel (BLS), the German nutrient database of the Max Rubner-Institut. Source: Max Rubner-Institut (2025): Bundeslebensmittelschlüssel (BLS), Version 4.0 — Deutsche Nährstoffdatenbank. Karlsruhe. DOI: 10.25826/Data20251217-134202-0. Licence: CC BY 4.0. For the app, selected nutrients were taken over, rounded and converted into a different file format; common foods got short names and typical portions for the search.';

  @override
  String get aboutBlsLicence => 'Licence CC BY 4.0';

  @override
  String get aboutOffAveragesText =>
      'For some simple foods that the BLS does not contain (for example “Skyr Vanille”), the app shows typical values: the median of many products sold in Germany from Open Food Facts. These values are also available under the Open Database License (ODbL).';

  @override
  String get aboutNotesTitle => 'Good to know';

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacyText =>
      'All data stays on your device. The app has no account, no ads and no tracking. Only product searches are sent to Open Food Facts.';

  @override
  String get aboutLicenses => 'Open-source licences';

  @override
  String get statsThisWeek => 'This week';

  @override
  String statsWeekTitle(String week, String range) {
    return 'Week $week · $range';
  }

  @override
  String statsWeekTitleWithYear(String week, String year, String range) {
    return 'Week $week/$year · $range';
  }

  @override
  String statsRangeSameMonth(String first, String last, String month) {
    return '$month $first–$last';
  }

  @override
  String statsRangeTwoMonths(String first, String last) {
    return '$first – $last';
  }

  @override
  String get statsPreviousWeek => 'Previous week';

  @override
  String get statsNextWeek => 'Next week';

  @override
  String get statsChartTitle => 'Calories per day';

  @override
  String statsGoalLine(String goal) {
    return 'Line: your daily goal ($goal kcal)';
  }

  @override
  String statsChartSemantics(String days) {
    return 'Calories per day: $days.';
  }

  @override
  String statsChartSemanticsGoal(String goal) {
    return 'Daily goal: $goal kcal.';
  }

  @override
  String statsDayKcal(String day, String kcal) {
    return '$day $kcal kcal';
  }

  @override
  String statsDayNoEntries(String day) {
    return '$day no entries';
  }

  @override
  String statsDayKcalUnknown(String day) {
    return '$day kcal unknown';
  }

  @override
  String get statsAverageKcalTitle => 'Ø kcal per day';

  @override
  String statsAverageKcalSemantics(String value) {
    return 'Average: $value kcal per day';
  }

  @override
  String get statsDaysLoggedTitle => 'Days with entries';

  @override
  String statsDaysLoggedValue(String count) {
    return '$count of 7';
  }

  @override
  String get statsAverageMacrosTitle => 'Ø per day';

  @override
  String statsAverageMacroSemantics(String nutrient, String value) {
    return 'Average $nutrient: $value per day';
  }

  @override
  String get statsAverageNote => 'Averages only count the days with entries.';

  @override
  String get statsEmptyTitle => 'No entries this week';

  @override
  String get statsEmptyText =>
      'As soon as you log something, you\'ll see your week here.';
}
