import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kards/l10n/generated/app_localizations.dart';
import 'package:kards/l10n/generated/app_localizations_en.dart';
import 'package:kards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kards/loyalty_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the empty state when no cards are saved', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final l10n = AppLocalizationsEn();
    expect(find.text(l10n.noLoyaltyCards), findsOneWidget);
    expect(find.text(l10n.scanFirstCard), findsOneWidget);
  });

  testWidgets('loads saved cards and filters by store name', (tester) async {
    final cards = [
      _card('1', 'Coffee Shop', 'BARCODE'),
      _card('2', 'Book Store', 'QR'),
    ];
    SharedPreferences.setMockInitialValues({
      'loyalty_cards': cards.map((card) => json.encode(card.toJson())).toList(),
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Coffee Shop'), findsOneWidget);
    expect(find.text('Book Store'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump();

    expect(find.text('Coffee Shop'), findsOneWidget);
    expect(find.text('Book Store'), findsNothing);
    expect(find.text(AppLocalizationsEn().noCardsFound), findsNothing);
  });

  testWidgets('filters saved cards by card type', (tester) async {
    final cards = [
      _card('1', 'Coffee Shop', 'BARCODE'),
      _card('2', 'Book Store', 'QR'),
    ];
    SharedPreferences.setMockInitialValues({
      'loyalty_cards': cards.map((card) => json.encode(card.toJson())).toList(),
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'qr');
    await tester.pump();

    expect(find.text('Book Store'), findsOneWidget);
    expect(find.text('Coffee Shop'), findsNothing);
  });

  testWidgets('shows an empty state when the search has no matches', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'loyalty_cards': [
        json.encode(_card('1', 'Coffee Shop', 'BARCODE').toJson()),
      ],
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();

    final l10n = AppLocalizationsEn();
    expect(find.text(l10n.noCardsFound), findsOneWidget);
    expect(find.text(l10n.adjustSearch), findsOneWidget);
  });

  testWidgets('sorts saved cards by date in descending order', (tester) async {
    final older = _card('1', 'Older', 'BARCODE', DateTime.utc(2024));
    final newer = _card('2', 'Newer', 'BARCODE', DateTime.utc(2025));
    SharedPreferences.setMockInitialValues({
      'loyalty_cards': [
        json.encode(older.toJson()),
        json.encode(newer.toJson()),
      ],
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final l10n = AppLocalizationsEn();
    await tester.tap(find.byTooltip(l10n.sortCardsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.dateAdded));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.sortCardsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text(l10n.ascendingOrder),
        matching: find.byType(SwitchListTile),
      ),
    );
    await tester.pumpAndSettle();

    final olderPosition = tester.getTopLeft(find.text('Older')).dy;
    final newerPosition = tester.getTopLeft(find.text('Newer')).dy;
    expect(newerPosition, lessThan(olderPosition));
  });

  testWidgets('deletes a card and persists the remaining cards', (
    tester,
  ) async {
    final cards = [
      _card('1', 'Keep Me', 'BARCODE'),
      _card('2', 'Delete Me', 'QR'),
    ];
    SharedPreferences.setMockInitialValues({
      'loyalty_cards': cards.map((card) => json.encode(card.toJson())).toList(),
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final deleteCardTile = find.ancestor(
      of: find.text('Delete Me'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(
        of: deleteCardTile,
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().delete));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.widgetWithText(TextButton, AppLocalizationsEn().delete),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete Me'), findsNothing);
    expect(find.text('Keep Me'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('loyalty_cards')!;
    expect(saved, hasLength(1));
    expect(json.decode(saved.single)['storeName'], 'Keep Me');

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Delete Me'), findsNothing);
    expect(find.text('Keep Me'), findsOneWidget);
  });
}

Widget _app() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HomePage(onLocaleChanged: (_) {}),
  );
}

LoyaltyCard _card(
  String id,
  String storeName,
  String cardType, [
  DateTime? dateAdded,
]) {
  return LoyaltyCard(
    id: id,
    storeName: storeName,
    cardData: '123456',
    cardType: cardType,
    dateAdded: dateAdded ?? DateTime.utc(2025, 1, 1),
  );
}
