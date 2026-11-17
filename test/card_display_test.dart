import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:kards/l10n/generated/app_localizations.dart';
import 'package:kards/l10n/generated/app_localizations_en.dart';
import 'package:kards/pages/card_display.dart';

import 'package:kards/loyalty_card.dart';

void main() {
  testWidgets('displays a QR card with checkout guidance', (tester) async {
    await tester.pumpWidget(_app(_card('QR')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Market')),
      findsOneWidget,
    );
    expect(find.byType(bw.BarcodeWidget), findsOneWidget);
    final l10n = AppLocalizationsEn();
    expect(find.text(l10n.qrCode), findsOneWidget);
    expect(find.text(l10n.showCodeAtCheckout), findsOneWidget);
  });

  testWidgets('uses the barcode label for non-QR cards', (tester) async {
    await tester.pumpWidget(_app(_card('BARCODE')));
    await tester.pumpAndSettle();

    final l10n = AppLocalizationsEn();
    expect(find.byType(bw.BarcodeWidget), findsOneWidget);
    expect(find.text(l10n.barcode), findsOneWidget);
    expect(find.text(l10n.qrCode), findsNothing);
  });
}

Widget _app(LoyaltyCard card) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CardDisplayPage(card: card),
  );
}

LoyaltyCard _card(String cardType) {
  return LoyaltyCard(
    id: '1',
    storeName: 'Market',
    cardData: '123456',
    cardType: cardType,
    dateAdded: DateTime.utc(2025, 1, 1),
  );
}
