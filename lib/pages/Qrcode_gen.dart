import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Generate extends StatefulWidget {
  const Generate({super.key});

  @override
  State<Generate> createState() => _GenerateState();
}

class _GenerateState extends State<Generate> {
  final TextEditingController urlController = TextEditingController();
  String qrData = '';

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  void generateQRCode() {
    setState(() {
      qrData = urlController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
        elevation: 4,
        shadowColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qrData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      size: 200,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                const SizedBox(height: 25),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurple[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    labelText: "Enter text or URL",
                    labelStyle: TextStyle(color: Colors.deepPurple[800]),
                    hintText: "e.g., https://example.com",
                    hintStyle: TextStyle(color: Colors.deepPurple[300]),
                    prefixIcon: const Icon(Icons.link, color: Colors.deepPurple),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: TextStyle(color: Colors.deepPurple[900]),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.deepPurple,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: generateQRCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code, size: 24),
                      SizedBox(width: 10),
                      Text('Generate QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
