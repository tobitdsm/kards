// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Kards';

  @override
  String get sortCards => 'Kaarten sorteren';

  @override
  String get storeName => 'Winkelnaam';

  @override
  String get dateAdded => 'Datum toegevoegd';

  @override
  String get cardType => 'Kaarttype';

  @override
  String get ascendingOrder => 'Oplopende volgorde';

  @override
  String get done => 'Gereed';

  @override
  String get searchCards => 'Kaarten zoeken...';

  @override
  String get sortCardsTooltip => 'Kaarten sorteren';

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get noLoyaltyCards => 'Nog geen klantenkaarten';

  @override
  String get scanFirstCard => 'Tik op de + knop om je eerste kaart te scannen';

  @override
  String get noCardsFound => 'Geen kaarten gevonden';

  @override
  String get adjustSearch => 'Pas je zoekopdracht aan';

  @override
  String addedDate(String date) {
    return 'Toegevoegd: $date';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteCard => 'Kaart verwijderen';

  @override
  String confirmDeleteCard(String storeName) {
    return 'Weet je zeker dat je de kaart \'$storeName\' wilt verwijderen?';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get scanLoyaltyCard => 'Klantenkaart scannen';

  @override
  String get addLoyaltyCard => 'Klantenkaart toevoegen';

  @override
  String get storeNameHint => 'bijv. Starbucks, Target, enz.';

  @override
  String scannedFormat(String format) {
    return 'Gescand: $format';
  }

  @override
  String get saveCard => 'Kaart opslaan';

  @override
  String get qrCode => 'QR-code';

  @override
  String get barcode => 'Barcode';

  @override
  String get showCodeAtCheckout => 'Laat deze code zien bij het afrekenen';

  @override
  String get invalidBarcodeData => 'Ongeldige barcodegegevens';

  @override
  String get toggleFlash => 'Zaklamp in-/uitschakelen';

  @override
  String get switchCamera => 'Camera wisselen';

  @override
  String get switchLanguage => 'Taal wisselen';
}
