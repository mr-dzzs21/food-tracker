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
}
