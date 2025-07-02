class LoyaltyCard {
  final String id;
  final String storeName;
  final String cardData;
  final String cardType; // 'QR' or 'BARCODE'
  final DateTime dateAdded;

  LoyaltyCard({
    required this.id,
    required this.storeName,
    required this.cardData,
    required this.cardType,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'cardData': cardData,
      'cardType': cardType,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      storeName: json['storeName'],
      cardData: json['cardData'],
      cardType: json['cardType'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}
