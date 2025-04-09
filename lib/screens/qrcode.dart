<<<<<<< HEAD
import 'package:gridscout/constants.dart';
=======
import 'package:asugs/constants.dart';
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
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
<<<<<<< HEAD
=======
          // Camera view for scanning QR code
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
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

<<<<<<< HEAD
                Navigator.pushReplacementNamed(
                  context,
                  '/work_order',
                  arguments: {'qr': res},
                );
=======
                Navigator.pushNamed(context, '/data_entry', arguments: {
                  'qr': res,
                }).then((_) {
                  // Reset the navigation flag when returning to QR screen
                  setState(() {
                    isNavigating = false;
                  });
                });
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
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
<<<<<<< HEAD
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result != null && result!.barcodes.isNotEmpty
                        ? 'Scanned Data: ${result!.barcodes.first.rawValue}'
                        : 'Scan a QR Code',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Format: WorkOrder|EquipmentID|SerialNumber\nExample: 1|T1|ASU-GS123',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
=======
              child: Text(
                result != null && result!.barcodes.isNotEmpty
                    ? 'Scanned Data: ${result!.barcodes.first.rawValue}'
                    : 'Scan a QR Code',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
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
