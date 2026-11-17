import 'dart:convert';
import 'dart:typed_data';

class LoyaltyCard {
  final String id;
  final String storeName;
  final String cardData;
  final Uint8List? cardDataBytes;
  final String cardType;
  final DateTime dateAdded;

  LoyaltyCard({
    required this.id,
    required this.storeName,
    required this.cardData,
    this.cardDataBytes,
    required this.cardType,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'cardData': cardData,
      if (cardDataBytes != null) 'cardDataBytes': base64Encode(cardDataBytes!),
      'cardType': cardType,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      storeName: json['storeName'],
      cardData: json['cardData'],
      cardDataBytes:
          json['cardDataBytes'] == null
              ? null
              : base64Decode(json['cardDataBytes'] as String),
      cardType: json['cardType'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}
