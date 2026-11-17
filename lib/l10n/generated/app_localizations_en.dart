// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kards';

  @override
  String get sortCards => 'Sort Cards';

  @override
  String get storeName => 'Store Name';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get cardType => 'Card Type';

  @override
  String get ascendingOrder => 'Ascending Order';

  @override
  String get done => 'Done';

  @override
  String get searchCards => 'Search cards...';

  @override
  String get sortCardsTooltip => 'Sort cards';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noLoyaltyCards => 'No loyalty cards yet';

  @override
  String get scanFirstCard => 'Tap the + button to scan your first card';

  @override
  String get noCardsFound => 'No cards found';

  @override
  String get adjustSearch => 'Try adjusting your search';

  @override
  String addedDate(String date) {
    return 'Added: $date';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String confirmDeleteCard(String storeName) {
    return 'Are you sure you want to delete the $storeName loyalty card?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get scanLoyaltyCard => 'Scan Loyalty Card';

  @override
  String get addLoyaltyCard => 'Add Loyalty Card';

  @override
  String get storeNameHint => 'e.g., Starbucks, Target, etc.';

  @override
  String scannedFormat(String format) {
    return 'Scanned: $format';
  }

  @override
  String get saveCard => 'Save Card';

  @override
  String get qrCode => 'QR Code';

  @override
  String get barcode => 'Barcode';

  @override
  String get showCodeAtCheckout => 'Show this code at checkout';

  @override
  String get invalidBarcodeData => 'Invalid barcode data';

  @override
  String get toggleFlash => 'Toggle flashlight';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get switchLanguage => 'Switch language';
}
