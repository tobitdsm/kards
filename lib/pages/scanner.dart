import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../loyalty_card.dart';
import '../l10n/generated/app_localizations.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanLoyaltyCard),
        backgroundColor: colorScheme.inversePrimary,
        foregroundColor: colorScheme.inverseSurface,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (isScanning && capture.barcodes.isNotEmpty) {
                  final barcode = capture.barcodes.first;
                  if (barcode.rawValue != null || barcode.rawBytes != null) {
                    final cardDataBytes =
                        barcode.rawBytes ??
                        Uint8List.fromList(utf8.encode(barcode.rawValue!));
                    setState(() {
                      isScanning = false;
                    });
                    _showCardDetailsDialog(
                      barcode.rawValue ?? base64Encode(cardDataBytes),
                      barcode.format,
                      cardDataBytes,
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              padding: EdgeInsets.all(50),
              child: ListTile(
                leading: IconButton(
                  color: colorScheme.onSurface,
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController,
                    builder: (context, state, child) {
                      switch (state.torchState) {
                        case TorchState.off:
                          return Icon(
                            Icons.flash_off,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          );
                        case TorchState.on:
                          return Icon(Icons.flash_on, color: Colors.yellow);
                        case TorchState.unavailable:
                          return Icon(
                            Icons.flash_off,
                            color: colorScheme.onSurface,
                          );
                        case TorchState.auto:
                          return Icon(
                            Icons.flash_auto,
                            color: colorScheme.onSurface,
                          );
                      }
                    },
                  ),
                  iconSize: 32.0,
                  tooltip: l10n.toggleFlash,
                  onPressed: () => cameraController.toggleTorch(),
                ),
                trailing: IconButton(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController,
                    builder: (context, state, child) {
                      switch (state.cameraDirection) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_front);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_rear);
                      }
                    },
                  ),
                  iconSize: 32.0,
                  tooltip: l10n.switchCamera,
                  onPressed: () => cameraController.switchCamera(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetailsDialog(
    String cardData,
    BarcodeFormat format,
    List<int> cardDataBytes,
  ) {
    final TextEditingController storeNameController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.addLoyaltyCard),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: storeNameController,
                  decoration: InputDecoration(
                    labelText: l10n.storeName,
                    hintText: l10n.storeNameHint,
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                Text(
                  l10n.scannedFormat(
                    _getCardType(format) == 'QR' ? l10n.qrCode : l10n.barcode,
                  ),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isScanning = true;
                  });
                },
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (storeNameController.text.isNotEmpty) {
                    final card = LoyaltyCard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      storeName: storeNameController.text,
                      cardData: cardData,
                      cardDataBytes: Uint8List.fromList(cardDataBytes),
                      cardType: _getCardType(format),
                      dateAdded: DateTime.now(),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context, card);
                  }
                },
                child: Text(l10n.saveCard),
              ),
            ],
          ),
    );
  }

  String _getCardType(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR';
      default:
        return 'BARCODE';
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
