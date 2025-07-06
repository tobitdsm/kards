import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../loyalty_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Loyalty Card'),
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
                  if (barcode.rawValue != null) {
                    setState(() {
                      isScanning = false;
                    });
                    _showCardDetailsDialog(
                      barcode.rawValue!,
                      barcode
                          .format,
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
                    valueListenable: cameraController.torchState,
                    builder: (context, state, child) {
                      switch (state) {
                        case TorchState.off:
                          return Icon(
                            Icons.flash_off,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          );
                        case TorchState.on:
                          return Icon(Icons.flash_on, color: Colors.yellow);
                      }
                    },
                  ),
                  iconSize: 32.0,
                  onPressed: () => cameraController.toggleTorch(),
                ),
                trailing: IconButton(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.cameraFacingState,
                    builder: (context, state, child) {
                      switch (state) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_front);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_rear);
                      }
                    },
                  ),
                  iconSize: 32.0,
                  onPressed: () => cameraController.switchCamera(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetailsDialog(String cardData, BarcodeFormat format) {
    final TextEditingController storeNameController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Add Loyalty Card'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: storeNameController,
                  decoration: InputDecoration(
                    labelText: 'Store Name',
                    hintText: 'e.g., Starbucks, Target, etc.',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                Text(
                  'Scanned: ${format.name.toUpperCase()}',
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
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (storeNameController.text.isNotEmpty) {
                    final card = LoyaltyCard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      storeName: storeNameController.text,
                      cardData: cardData,
                      cardType: _getCardType(format),
                      dateAdded: DateTime.now(),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context, card);
                  }
                },
                child: Text('Save Card'),
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
