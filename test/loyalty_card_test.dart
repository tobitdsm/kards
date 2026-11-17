import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kards/loyalty_card.dart';

void main() {
  test('serializes all card fields and omits absent raw bytes', () {
    final card = LoyaltyCard(
      id: '1',
      storeName: 'Store',
      cardData: 'display value',
      cardType: 'QR',
      dateAdded: DateTime.utc(2025, 1, 1),
    );

    expect(card.toJson(), {
      'id': '1',
      'storeName': 'Store',
      'cardData': 'display value',
      'cardType': 'QR',
      'dateAdded': '2025-01-01T00:00:00.000Z',
    });
  });

  test('preserves scanned bytes through JSON serialization', () {
    final card = LoyaltyCard(
      id: '1',
      storeName: 'Store',
      cardData: 'display value',
      cardDataBytes: Uint8List.fromList([0, 1, 127, 255]),
      cardType: 'BARCODE',
      dateAdded: DateTime.utc(2025, 1, 1),
    );

    final restored = LoyaltyCard.fromJson(card.toJson());

    expect(restored.cardData, card.cardData);
    expect(restored.cardDataBytes, orderedEquals(card.cardDataBytes!));
    expect(restored.id, card.id);
    expect(restored.storeName, card.storeName);
    expect(restored.cardType, card.cardType);
    expect(restored.dateAdded, card.dateAdded);
  });

  test(
    'preserves an empty scanned byte payload through JSON serialization',
    () {
      final card = LoyaltyCard(
        id: '1',
        storeName: 'Store',
        cardData: '',
        cardDataBytes: Uint8List(0),
        cardType: 'BARCODE',
        dateAdded: DateTime.utc(2025, 1, 1),
      );

      final restored = LoyaltyCard.fromJson(card.toJson());

      expect(restored.cardDataBytes, isEmpty);
    },
  );

  test('loads cards saved before raw bytes were persisted', () {
    final card = LoyaltyCard.fromJson({
      'id': '1',
      'storeName': 'Store',
      'cardData': 'legacy value',
      'cardType': 'QR',
      'dateAdded': '2025-01-01T00:00:00.000Z',
    });

    expect(card.cardData, 'legacy value');
    expect(card.cardDataBytes, isNull);
  });

  test('rejects cards with missing required fields', () {
    expect(
      () => LoyaltyCard.fromJson({
        'id': '1',
        'storeName': 'Store',
        'cardData': 'value',
        'cardType': 'QR',
      }),
      throwsA(anything),
    );
  });

  test('rejects cards with an invalid date', () {
    expect(
      () => LoyaltyCard.fromJson({
        'id': '1',
        'storeName': 'Store',
        'cardData': 'value',
        'cardType': 'QR',
        'dateAdded': 'not-a-date',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
