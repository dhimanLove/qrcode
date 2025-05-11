import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  String qrData = 'Scanned Data will appear here';
  bool isScanning = true;
  bool isProcessing = false;
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode], // Restrict to QR codes only
    autoStart: true,
    detectionSpeed: DetectionSpeed.normal, // Prioritize accuracy
    returnImage: true, // Useful for debugging
  );

  Future<void> pickImage() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        final result = await controller.analyzeImage(image.path);
        setState(() {
          qrData = result?.barcodes.first.displayValue ?? 'No QR Code detected!';
          isScanning = false;
          isProcessing = false;
        });
      } else {
        setState(() {
          qrData = 'No image selected!';
          isScanning = false;
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        qrData = 'Error processing image: $e';
        isScanning = false;
        isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, exception, child) {
              return Center(
                child: Text(
                  'Scanner error: ${exception.errorCode}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            },
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && mounted) {
                setState(() {
                  qrData = barcodes.first.displayValue ?? 'No data found!';
                  isScanning = false;
                });
                controller.stop(); // Stop scanning after detection
              }
            },
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isProcessing
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Align QR Code Here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: isProcessing ? null : pickImage,
                  icon: const Icon(Icons.image, color: Colors.black),
                  label: const Text(
                    'Scan from Gallery',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
          if (!isScanning)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  qrData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        elevation: 6,
        tooltip: 'Restart Scan',
        heroTag: 'restartScan',
        mini: true,
        onPressed: () {
          setState(() {
            isScanning = true;
            qrData = 'Scanned Data will appear here';
            isProcessing = false;
          });
          controller.start();
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        splashColor: Colors.black.withOpacity(0.2),
        child: const Icon(Icons.refresh, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}