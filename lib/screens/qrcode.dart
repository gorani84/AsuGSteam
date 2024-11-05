import 'package:asugs/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  BarcodeCapture? result;
  final MobileScannerController controller = MobileScannerController();
  bool isNavigating = false; // Add a flag to track navigation state

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        surfaceTintColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Image.asset(
          'assets/images/banner_logo_maroon.png',
          fit: BoxFit.contain,
          height: 40,
        ),
      ),
      body: Stack(
        children: [
          // Camera view for scanning QR code
          MobileScanner(
            controller: controller,
            onDetect: (barcode) {
              // Check if already navigating, to avoid repeated navigation
              if (!isNavigating) {
                setState(() {
                  result = barcode;
                  isNavigating = true; // Set flag to true when navigating
                });
                String? res = barcode.barcodes.first.rawValue;

                Navigator.pushNamed(context, '/data_entry', arguments: {
                  'qr': res,
                }).then((_) {
                  // Reset the navigation flag when returning to QR screen
                  setState(() {
                    isNavigating = false;
                  });
                });
              }
            },
          ),
          // Overlay at the bottom displaying QR code data
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8.0,
              ),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                result != null && result!.barcodes.isNotEmpty
                    ? 'Scanned Data: ${result!.barcodes.first.rawValue}'
                    : 'Scan a QR Code',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.toggleTorch(); // Toggle flashlight on or off
        },
        child: Icon(Icons.flash_on),
      ),
    );
  }
}
