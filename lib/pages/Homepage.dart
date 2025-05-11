import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrcode/pages/Qrcode_gen.dart';
import 'package:qrcode/pages/scanqr.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[900]!,
              Colors.indigo[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.5,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              'QR Elite',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Your Premium QR Code Companion',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Scan Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            child: ElevatedButton(
                              onPressed: () => Get.to(() => const ScanQR()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[600],
                                padding: const EdgeInsets.all(20),
                                minimumSize: const Size(double.infinity, 70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Expanded(
                                    child: Text(
                                      'Scan QR Code',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Generate Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            child: ElevatedButton(
                              onPressed: () => Get.to(() => const Generate()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[600],
                                padding: const EdgeInsets.all(20),
                                minimumSize: const Size(double.infinity, 70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Expanded(
                                    child: Text(
                                      'Generate QR Code',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}