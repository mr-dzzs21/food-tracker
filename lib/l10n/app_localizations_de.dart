// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Food Tracker';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabScan => 'Scannen';

  @override
  String get tabStats => 'Statistik';

  @override
  String get tabProfile => 'Profil';

  @override
  String get actionRetry => 'Nochmal versuchen';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionOk => 'OK';

  @override
  String get mealBreakfast => 'Frühstück';

  @override
  String get mealLunch => 'Mittagessen';

  @override
  String get mealDinner => 'Abendessen';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String get failureInvalidBarcode =>
      'Dieser Barcode sieht ungültig aus. Scanne ihn bitte noch einmal.';

  @override
  String get failureNotFound =>
      'Dieses Produkt kennen wir noch nicht. Du kannst es selbst eintragen.';

  @override
  String get failureNotFood => 'Das scheint kein Lebensmittel zu sein.';

  @override
  String get failureIncomplete =>
      'Für dieses Produkt fehlen Nährwerte. Du kannst sie selbst ergänzen.';

  @override
  String get failureOffline =>
      'Du bist offline. Dein Tagebuch funktioniert weiter – für die Produktsuche brauchst du Internet.';

  @override
  String get failureTimeout =>
      'Open Food Facts antwortet gerade nicht. Versuch es gleich noch mal.';

  @override
  String get failureRateLimited =>
      'Zu viele Anfragen in kurzer Zeit. Warte eine Minute und versuch es dann noch mal.';

  @override
  String get failureServer =>
      'Bei Open Food Facts gibt es gerade ein Problem. Versuch es später noch mal.';

  @override
  String get failureMaintenance =>
      'Open Food Facts ist gerade nicht erreichbar (Wartung oder Überlastung). Versuch es später noch mal.';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen.';

  @override
  String get productUnknownName => 'Unbekanntes Produkt';

  @override
  String get placeholderComingSoon => 'Dieser Bildschirm entsteht gerade.';

  @override
  String get mealUnnamed => 'Mahlzeit';

  @override
  String mealAddTooltip(String meal) {
    return 'Zu $meal hinzufügen';
  }

  @override
  String dayTitleToday(String date) {
    return 'Heute, $date';
  }

  @override
  String dayTitleYesterday(String date) {
    return 'Gestern, $date';
  }

  @override
  String dayTitleTomorrow(String date) {
    return 'Morgen, $date';
  }

  @override
  String get dayPrevious => 'Vorheriger Tag';

  @override
  String get dayNext => 'Nächster Tag';

  @override
  String get dayPick => 'Tag auswählen';

  @override
  String get dayJumpToday => 'Heute';

  @override
  String get todayGoalCardTitle => 'Ziel festlegen';

  @override
  String get todayGoalCardText =>
      'Mit einem Tagesziel zeigt dir der Ring, wie viel heute noch übrig ist.';

  @override
  String get todayGoalCardButton => 'Ziel festlegen';

  @override
  String get todayGoalCardDismiss => 'Hinweis ausblenden';

  @override
  String get todayRingLeft => 'kcal übrig';

  @override
  String get todayRingEaten => 'kcal gegessen';

  @override
  String get todayRingOver => 'kcal über deinem Ziel';

  @override
  String todayRingOfGoal(String goal) {
    return 'von $goal';
  }

  @override
  String todayRingSemanticsLeft(String left, String goal, String eaten) {
    return '$left kcal übrig von $goal kcal. Gegessen: $eaten kcal.';
  }

  @override
  String todayRingSemanticsOver(String over, String goal, String eaten) {
    return '$over kcal über deinem Ziel von $goal kcal. Gegessen: $eaten kcal.';
  }

  @override
  String todayRingSemanticsEaten(String eaten) {
    return '$eaten kcal gegessen. Kein Tagesziel festgelegt.';
  }

  @override
  String todayEatenLine(String eaten) {
    return 'Gegessen: $eaten kcal';
  }

  @override
  String todayMissingValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Für $count Einträge fehlen Angaben',
      one: 'Für 1 Eintrag fehlen Angaben',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyDay =>
      'Noch nichts eingetragen. Tippe bei einer Mahlzeit auf +, um etwas hinzuzufügen.';

  @override
  String todayMacroOfGoal(String eaten, String goal) {
    return '$eaten von $goal g';
  }

  @override
  String nutrientWithValue(String nutrient, String value) {
    return '$nutrient: $value';
  }

  @override
  String totalAtLeast(String value) {
    return 'mind. $value';
  }

  @override
  String totalAtMost(String value) {
    return 'höchstens $value';
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
  String get diaryEntryDeleted => 'Eintrag gelöscht';

  @override
  String get entryAmountLabel => 'Menge';

  @override
  String get entryMealLabel => 'Mahlzeit';

  @override
  String get amountInvalid => 'Bitte gib eine Menge zwischen 0 und 10.000 ein.';

  @override
  String get nutrientKcal => 'Energie';

  @override
  String get nutrientFat => 'Fett';

  @override
  String get nutrientSaturatedFat => 'gesättigte Fettsäuren';

  @override
  String get nutrientCarbs => 'Kohlenhydrate';

  @override
  String get nutrientSugars => 'Zucker';

  @override
  String get nutrientFibre => 'Ballaststoffe';

  @override
  String get nutrientProtein => 'Eiweiß';

  @override
  String get nutrientSalt => 'Salz';

  @override
  String get ratingLevelLow => 'niedrig';

  @override
  String get ratingLevelMedium => 'mittel';

  @override
  String get ratingLevelHigh => 'hoch';

  @override
  String get ratingNoData => 'keine Angabe';

  @override
  String get ratingTitle => 'Bewertung';

  @override
  String get ratingTitleFood => 'Bewertung pro 100 g';

  @override
  String get ratingTitleDrink => 'Bewertung pro 100 ml';

  @override
  String ratingRowSemantics(String nutrient, String level, String value) {
    return '$nutrient: $level, $value';
  }

  @override
  String get ratingNotRated =>
      'Für diese Produktart gibt es keine Ampel-Bewertung (z. B. Wasser, Kaffee, Tee, Gewürze, Babynahrung, Alkohol). Die Nährwerte siehst du unten.';

  @override
  String get ratingNoCategory =>
      'Die Produktart ist unbekannt, deshalb gibt es keine Ampel-Bewertung.';

  @override
  String get ratingSuspicious =>
      'Diese Angaben wirken unstimmig und könnten fehlerhaft sein.';

  @override
  String get plusFibreSource => 'Ballaststoffquelle';

  @override
  String get plusFibreHigh => 'hoher Ballaststoffgehalt';

  @override
  String get plusProteinSource => 'Proteinquelle';

  @override
  String get plusProteinHigh => 'hoher Proteingehalt';

  @override
  String plusPointRow(String label, String value) {
    return '$label · $value';
  }

  @override
  String productNutriScore(String grade) {
    return 'Nutri-Score: $grade (laut Open Food Facts)';
  }

  @override
  String get productImageCaption =>
      'Foto: Open Food Facts-Mitwirkende, CC BY-SA';

  @override
  String get productFavouriteAdd => 'Zu Favoriten hinzufügen';

  @override
  String get productFavouriteRemove => 'Aus Favoriten entfernen';

  @override
  String get productAmountTitle => 'Wie viel?';

  @override
  String productServingChip(String amount) {
    return '1 Portion ($amount)';
  }

  @override
  String productLastAmountChip(String amount) {
    return 'Zuletzt: $amount';
  }

  @override
  String productDay(String day) {
    return 'Tag: $day';
  }

  @override
  String productAdded(String meal) {
    return 'Zu $meal hinzugefügt';
  }

  @override
  String get productNutritionTitle => 'Nährwerte';

  @override
  String get productPer100g => 'pro 100 g';

  @override
  String get productPer100ml => 'pro 100 ml';

  @override
  String productPerServing(String amount) {
    return 'pro Portion ($amount)';
  }

  @override
  String get productAttribution => 'Daten: Open Food Facts (ODbL)';

  @override
  String get productCorrectHint =>
      'Daten falsch? Auf Open Food Facts kannst du sie korrigieren.';

  @override
  String get productOpenOff => 'Auf Open Food Facts ansehen';

  @override
  String get productCreateOwn => 'Selbst eintragen';

  @override
  String get productCompleteValues => 'Werte ergänzen';

  @override
  String get productGone => 'Dieses Lebensmittel gibt es nicht mehr.';

  @override
  String get disclaimerShort =>
      'Daten von Open Food Facts. Werte können fehlerhaft sein. Die Bewertung ist eine Orientierung und keine medizinische Beratung.';

  @override
  String get disclaimerRating =>
      'Die Bewertung ist eine Orientierung und keine medizinische Beratung.';

  @override
  String get searchFieldHint => 'Produkt suchen';

  @override
  String get searchSubmit => 'Suchen';

  @override
  String get scanRecentlyViewedTitle => 'Zuletzt angesehen';

  @override
  String get scanRecentlyViewedEmpty =>
      'Hier erscheinen Produkte, die du gescannt oder gesucht hast.';

  @override
  String get scannerTitle => 'Barcode scannen';

  @override
  String get scannerHint => 'Halte die Kamera auf einen Barcode.';

  @override
  String get scannerPreviewLabel => 'Kamera zum Scannen von Barcodes';

  @override
  String get scannerTorchOn => 'Licht einschalten';

  @override
  String get scannerTorchOff => 'Licht ausschalten';

  @override
  String get scannerPermissionTitle => 'Kein Zugriff auf die Kamera';

  @override
  String get scannerPermissionText =>
      'Zum Scannen erlaube den Kamerazugriff in den Einstellungen deines Geräts (Einstellungen › Food Tracker › Kamera). Bis dahin kannst du die Suche nutzen.';

  @override
  String get scannerUnsupported =>
      'Hier gibt es keine Kamera. Nutze die Suche.';

  @override
  String get scannerError =>
      'Die Kamera konnte nicht starten. Versuch es noch mal oder nutze die Suche.';

  @override
  String searchResultsTitle(String query) {
    return 'Suche: $query';
  }

  @override
  String get searchEmptyQuery => 'Gib ein, was du suchst.';

  @override
  String get searchLocalTitle => 'Auf deinem Gerät';

  @override
  String get searchOnlineTitle => 'Online-Ergebnisse';

  @override
  String get searchNoOnlineResults => 'Keine Treffer bei Open Food Facts.';

  @override
  String get searchNoResultsHint =>
      'Prüf die Schreibweise oder trag das Lebensmittel selbst ein.';

  @override
  String get searchLoadMore => 'Mehr laden';

  @override
  String searchNutriScore(String grade) {
    return 'Nutri-Score: $grade';
  }

  @override
  String foodKcalPer100g(String kcal) {
    return '$kcal kcal pro 100 g';
  }

  @override
  String foodKcalPer100ml(String kcal) {
    return '$kcal kcal pro 100 ml';
  }

  @override
  String get foodKcalUnknown => 'Kalorien unbekannt';

  @override
  String addFoodTitle(String meal, String day) {
    return '$meal · $day';
  }

  @override
  String get addFoodSearchHint => 'Lebensmittel suchen';

  @override
  String get addFoodScan => 'Scannen';

  @override
  String get addFoodCreateOwn => 'Eigenes Lebensmittel';

  @override
  String get addFoodSegmentRecent => 'Zuletzt';

  @override
  String get addFoodSegmentFavourites => 'Favoriten';

  @override
  String get addFoodSegmentOwn => 'Eigene';

  @override
  String get addFoodRecentEmpty =>
      'Noch leer. Was du in dein Tagebuch einträgst, erscheint hier.';

  @override
  String get addFoodFavouritesEmpty =>
      'Noch keine Favoriten. Tippe auf einer Produktseite auf den Stern.';

  @override
  String get addFoodOwnEmpty =>
      'Noch keine eigenen Lebensmittel. Leg eins mit „Eigenes Lebensmittel“ an.';

  @override
  String get addFoodNoLocalMatches =>
      'Auf deinem Gerät nichts gefunden. Tippe auf der Tastatur auf „Suchen“, um online zu suchen.';

  @override
  String get foodFormNewTitle => 'Neues Lebensmittel';

  @override
  String get foodFormEditTitle => 'Lebensmittel bearbeiten';

  @override
  String foodFormRequired(String label) {
    return '$label *';
  }

  @override
  String get foodFormRequiredHint => '* Pflichtfeld';

  @override
  String get foodFormName => 'Name';

  @override
  String get foodFormBrand => 'Marke (optional)';

  @override
  String get foodFormBarcode => 'Barcode';

  @override
  String get foodFormIsLiquid => 'Getränk (pro 100 ml)';

  @override
  String get foodFormNutrientsPer100g => 'Nährwerte pro 100 g';

  @override
  String get foodFormNutrientsPer100ml => 'Nährwerte pro 100 ml';

  @override
  String get foodFormPortionTitle => 'Portion (optional)';

  @override
  String get foodFormPortionSize => 'Menge einer Portion';

  @override
  String get foodFormPortionLabel => 'Bezeichnung der Portion';

  @override
  String get foodFormPortionLabelHint => 'z. B. 1 Scheibe';

  @override
  String get foodFormNameMissing => 'Bitte gib einen Namen ein.';

  @override
  String get foodFormKcalMissing => 'Bitte gib die Kalorien ein.';

  @override
  String get foodFormNotANumber => 'Bitte gib eine Zahl ein.';

  @override
  String foodFormOutOfRange(String max) {
    return 'Erlaubt: 0 bis $max';
  }

  @override
  String get foodFormSaturatesAboveFat => 'Kann nicht mehr sein als Fett.';

  @override
  String get foodFormSugarsAboveCarbs =>
      'Kann nicht mehr sein als Kohlenhydrate.';

  @override
  String get foodFormPortionSizeMissing =>
      'Gib dazu auch die Menge einer Portion an.';

  @override
  String foodFormDeleteTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get foodFormDeleteText =>
      'Einträge in deinem Tagebuch bleiben erhalten.';

  @override
  String foodFormDeleted(String name) {
    return '„$name“ gelöscht';
  }

  @override
  String get linkOpenFailed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get disclaimerGoals =>
      'Die Werte sind Schätzungen für gesunde Erwachsene. Bei Krankheit, Schwangerschaft, Stillzeit oder wenn du unsicher bist, sprich mit einer Ärztin, einem Arzt oder einer Ernährungsfachkraft.';

  @override
  String get helpEdTitle => 'Hilfe bei Essstörungen';

  @override
  String get helpEdText =>
      'Wenn Essen oder Gewicht dich stark belasten: Das Info-Telefon des BIÖG zu Essstörungen hilft anonym.';

  @override
  String helpEdCall(String number) {
    return '$number anrufen';
  }

  @override
  String get helpEdHours => 'Mo–Do 10–22 Uhr, Fr–So 10–18 Uhr';

  @override
  String helpEdWebsite(String address) {
    return 'Webseite: $address';
  }

  @override
  String get goalTitle => 'Tagesziel';

  @override
  String get goalModeCalculate => 'Berechnen';

  @override
  String get goalModeManual => 'Selbst eingeben';

  @override
  String get goalSexLabel => 'Geschlecht';

  @override
  String get goalSexMale => 'männlich';

  @override
  String get goalSexFemale => 'weiblich';

  @override
  String get goalSexUnspecified => 'keine Angabe';

  @override
  String get goalAgeLabel => 'Alter';

  @override
  String get goalAgeSuffix => 'Jahre';

  @override
  String get goalHeightLabel => 'Größe';

  @override
  String get goalWeightLabel => 'Gewicht';

  @override
  String get goalAgeInvalid => 'Bitte gib ein Alter von 1 bis 120 Jahren ein.';

  @override
  String get goalHeightInvalid =>
      'Bitte gib eine Größe von 100 bis 250 cm ein.';

  @override
  String get goalWeightInvalid =>
      'Bitte gib ein Gewicht von 30 bis 300 kg ein.';

  @override
  String get goalActivityLabel => 'Wie aktiv bist du?';

  @override
  String get goalActivityLow => 'Wenig aktiv';

  @override
  String get goalActivityLowText =>
      'Meist sitzend, kaum Bewegung in der Freizeit';

  @override
  String get goalActivityLight => 'Etwas aktiv';

  @override
  String get goalActivityLightText =>
      'Sitzend, aber regelmäßig zu Fuß/Rad oder 1–2× Sport pro Woche';

  @override
  String get goalActivityActive => 'Aktiv';

  @override
  String get goalActivityActiveText =>
      'Viel Stehen/Gehen im Job oder 3–5× Sport pro Woche';

  @override
  String get goalActivityVeryActive => 'Sehr aktiv';

  @override
  String get goalActivityVeryActiveText =>
      'Körperlich harte Arbeit oder sehr viel Sport';

  @override
  String get goalTypeLabel => 'Dein Ziel';

  @override
  String get goalTypeMaintain => 'Gewicht halten';

  @override
  String get goalTypeLoseSlow => 'Langsam abnehmen (0,25 kg/Woche)';

  @override
  String get goalTypeLose => 'Abnehmen (0,5 kg/Woche)';

  @override
  String get goalTypeGainSlow => 'Langsam zunehmen (0,25 kg/Woche)';

  @override
  String get goalResultTitle => 'Dein Ergebnis';

  @override
  String get goalResultMissing =>
      'Fülle Alter, Größe und Gewicht aus, dann siehst du hier dein Ergebnis.';

  @override
  String get goalResultBmr => 'Grundumsatz';

  @override
  String get goalResultTotal => 'Gesamtbedarf';

  @override
  String get goalResultGoal => 'Tagesziel';

  @override
  String goalApprox(String kcal) {
    return 'ca. $kcal kcal';
  }

  @override
  String get goalEstimateNote =>
      'Das sind Schätzungen. Dein Körper passt sich mit der Zeit an, deshalb ändert sich dein Gewicht meist langsamer als berechnet.';

  @override
  String goalFloorNote(String kcal) {
    return 'Wir schlagen nicht weniger als $kcal kcal pro Tag vor.';
  }

  @override
  String get goalMinorTitle => 'Hinweis für unter 18-Jährige';

  @override
  String get goalMinorText =>
      'Die Formel wurde für Erwachsene entwickelt. Solange du noch wächst, brauchst du oft mehr Energie. Sprich bei Fragen mit deiner Kinder- oder Hausarztpraxis.';

  @override
  String get goalApply => 'Ziel übernehmen';

  @override
  String get goalSaved => 'Dein Tagesziel ist gespeichert.';

  @override
  String get goalManualKcal => 'Kalorien pro Tag';

  @override
  String goalManualKcalInvalid(String max) {
    return 'Bitte gib einen Wert von 1 bis $max kcal ein.';
  }

  @override
  String get goalManualMacrosTitle => 'Makronährstoffe (optional)';

  @override
  String get goalManualMacrosHint =>
      'Leere Felder füllen wir mit Standardwerten: 15 % Eiweiß, 30 % Fett und der Rest Kohlenhydrate.';

  @override
  String goalMacroInvalid(String max) {
    return 'Bitte gib einen Wert von 0 bis $max g ein.';
  }

  @override
  String goalBelowFloorTitle(String kcal) {
    return 'Weniger als $kcal kcal?';
  }

  @override
  String goalBelowFloorText(String kcal) {
    return 'Dein Ziel liegt unter $kcal kcal pro Tag. So wenig solltest du länger nur mit ärztlicher Begleitung essen. Möchtest du es trotzdem speichern?';
  }

  @override
  String get goalBelowFloorChange => 'Ändern';

  @override
  String get goalBelowFloorSave => 'Trotzdem speichern';

  @override
  String get profileSettingsTitle => 'Einstellungen';

  @override
  String get profileInfoTitle => 'Hilfe & Info';

  @override
  String get profileGoalTitle => 'Dein Tagesziel';

  @override
  String get profileGoalNone => 'Noch kein Ziel';

  @override
  String get profileGoalNoneText =>
      'Mit einem Ziel zeigt dir der Ring auf „Heute“, wie viel noch übrig ist.';

  @override
  String get profileGoalSet => 'Ziel festlegen';

  @override
  String get profileGoalChange => 'Ziel ändern';

  @override
  String profileGoalKcal(String kcal) {
    return '$kcal kcal pro Tag';
  }

  @override
  String get profileTheme => 'Darstellung';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get settingSystem => 'Wie das System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileAbout => 'Über die App & Lizenzen';

  @override
  String get profileDeleteAll => 'Alle Daten löschen';

  @override
  String get profileDeleteAllTitle => 'Alle Daten löschen?';

  @override
  String get profileDeleteAllText =>
      'Dein Tagebuch, deine eigenen und gespeicherten Lebensmittel, dein Ziel und deine Einstellungen werden gelöscht, und die Mahlzeiten werden zurückgesetzt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get profileDeleteAllConfirm => 'Alles löschen';

  @override
  String get profileDeleteAllDone => 'Alle Daten wurden gelöscht.';

  @override
  String get mealsTitle => 'Mahlzeiten';

  @override
  String get mealsSubtitle => 'Umbenennen, ausblenden, sortieren';

  @override
  String get mealsHint =>
      'Zieh am Griff, um die Reihenfolge zu ändern. Die Uhrzeit bestimmt, welche Mahlzeit beim Hinzufügen vorgeschlagen wird.';

  @override
  String mealsStartTime(String time) {
    return 'ab $time';
  }

  @override
  String get mealsNoStartTime => 'keine Uhrzeit';

  @override
  String get mealsHidden => 'ausgeblendet';

  @override
  String mealsShow(String meal) {
    return '$meal anzeigen';
  }

  @override
  String mealsMove(String meal) {
    return '$meal verschieben';
  }

  @override
  String get mealsAdd => 'Mahlzeit hinzufügen';

  @override
  String get mealsEditTitle => 'Mahlzeit bearbeiten';

  @override
  String get mealsNewTitle => 'Neue Mahlzeit';

  @override
  String get mealsNameLabel => 'Name';

  @override
  String mealsNameDefaultHint(String name) {
    return 'Leer lassen für „$name“';
  }

  @override
  String get mealsNameMissing => 'Bitte gib einen Namen ein.';

  @override
  String get mealsStartTimeLabel => 'Vorgeschlagen ab';

  @override
  String get mealsPickTime => 'Uhrzeit wählen';

  @override
  String get mealsClearTime => 'Keine Uhrzeit';

  @override
  String get mealsLastVisible =>
      'Mindestens eine Mahlzeit muss sichtbar bleiben.';

  @override
  String mealsDeleteTitle(String meal) {
    return '„$meal“ löschen?';
  }

  @override
  String get mealsDeleteText =>
      'Diese Mahlzeit hat keine Einträge im Tagebuch und wird entfernt.';

  @override
  String mealsDeleted(String meal) {
    return '„$meal“ gelöscht';
  }

  @override
  String get mealsInUseTitle => 'Diese Mahlzeit wird verwendet';

  @override
  String mealsInUseText(String meal) {
    return 'In deinem Tagebuch gibt es Einträge bei „$meal“. Damit alte Tage vollständig bleiben, kannst du sie nicht löschen – aber ausblenden.';
  }

  @override
  String get mealsInUseHide => 'Ausblenden';

  @override
  String get myFoodsTitle => 'Eigene Lebensmittel';

  @override
  String get myFoodsEmpty => 'Noch keine eigenen Lebensmittel';

  @override
  String get myFoodsEmptyText =>
      'Lege Lebensmittel an, die Open Food Facts nicht kennt – zum Beispiel selbst Gekochtes.';

  @override
  String get myFoodsCreate => 'Eigenes Lebensmittel anlegen';

  @override
  String myFoodsMore(String name) {
    return 'Mehr zu $name';
  }

  @override
  String get aboutTitle => 'Über die App';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOpenSource => 'Open Source (MIT)';

  @override
  String get aboutOpenSourceText =>
      'Der Quellcode ist öffentlich. Du darfst ihn lesen, verbessern und weitergeben.';

  @override
  String get aboutSourceCode => 'Quellcode auf GitHub';

  @override
  String get aboutDataSourceTitle => 'Datenquelle';

  @override
  String get aboutDataSourceText =>
      'Produktdaten stammen von Open Food Facts (openfoodfacts.org) und stehen unter der Open Database License (ODbL); einzelne Inhalte unter der Database Contents License (DbCL), Produktfotos unter Creative Commons BY-SA. Die Daten werden von Freiwilligen gepflegt und können unvollständig oder fehlerhaft sein – prüf im Zweifel die Verpackung.';

  @override
  String get aboutOpenOff => 'openfoodfacts.org öffnen';

  @override
  String get aboutNotesTitle => 'Gut zu wissen';

  @override
  String get aboutPrivacyTitle => 'Datenschutz';

  @override
  String get aboutPrivacyText =>
      'Alle Daten bleiben auf deinem Gerät. Die App hat kein Konto, keine Werbung und kein Tracking. Nur Produktsuchen werden an Open Food Facts gesendet.';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';
}
