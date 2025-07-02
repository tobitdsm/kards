import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';

import '../loyalty_card.dart';

class CardDisplayPage extends StatelessWidget {
  final LoyaltyCard card;

  const CardDisplayPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(card.storeName),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      card.storeName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: _buildBarcode(context),
                    ),
                    SizedBox(height: 20),
                    Text(
                      card.cardType == 'QR' ? 'QR Code' : 'Barcode',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Show this code at checkout',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcode(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    try {
      if (card.cardType == 'QR') {
        return bw.BarcodeWidget(
          barcode: bw.Barcode.qrCode(),
          data: card.cardData,
          width: 250,
          height: 250,
        );
      } else {
        return bw.BarcodeWidget(
          barcode: bw.Barcode.code128(),
          data: card.cardData,
          width: 250,
          height: 100,
        );
      }
    } catch (e) {
      return Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: colorScheme.error, size: 32),
              SizedBox(height: 8),
              Text(
                'Invalid barcode data',
                style: TextStyle(color: colorScheme.error),
              ),
              SizedBox(height: 8),
              Text(
                card.cardData,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
