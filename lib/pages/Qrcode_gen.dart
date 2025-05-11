import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:io';

class Generate extends StatefulWidget {
  const Generate({super.key});

  @override
  State<Generate> createState() => _GenerateState();
}

class _GenerateState extends State<Generate> {
  final TextEditingController urlController = TextEditingController();
  String qrData = '';
  bool isSaving = false;
  bool isSharing = false;
  final GlobalKey qrKey = GlobalKey();
  int permissionDenialCount = 0;

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  void generateQRCode() {
    if (urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter text or URL')),
      );
      return;
    }
    setState(() {
      qrData = urlController.text.trim();
    });
  }

  Future captureQRCode() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> requestGalleryPermission() async {
    final status = Platform.isAndroid
        ? await Permission.storage.request()
        : await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      permissionDenialCount = 0;
      saveQRCodeToGallery();
    } else if (status.isDenied && mounted) {
      permissionDenialCount++;
      if (permissionDenialCount == 1) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Please allow access to save QR codes to your gallery.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  requestGalleryPermission();
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text('Please enable gallery access in settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      }
    } else if (status.isPermanentlyDenied && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Please enable gallery access in settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> saveQRCodeToGallery() async {
    if (qrData.isEmpty || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code to save')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final status = Platform.isAndroid
          ? await Permission.storage.status
          : await Permission.photos.status;
      if (!status.isGranted && !status.isLimited) {
        requestGalleryPermission();
        return;
      }

      final buffer = await captureQRCode();
      if (buffer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture QR code')),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = urlController.text.isNotEmpty
          ? '${urlController.text}_${DateTime.now().millisecondsSinceEpoch}.png'
          : 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(buffer);

      final success = await GallerySaver.saveImage(file.path, albumName: 'QR Codes');
      if (success == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to gallery: $fileName')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save to gallery')),
        );
      }

      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> shareQRCode() async {
    if (qrData.isEmpty || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code to share')),
      );
      return;
    }

    setState(() {
      isSharing = true;
    });

    try {
      final buffer = await captureQRCode();
      if (buffer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture QR code')),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = urlController.text.isNotEmpty
          ? '${urlController.text}_${DateTime.now().millisecondsSinceEpoch}.png'
          : 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(buffer);

      await Share.shareXFiles([XFile(file.path)], text: 'Your QR code');

      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        shadowColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: qrData.isEmpty ? Colors.grey[300] : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: qrData.isEmpty
                    ? const Center(
                        child: Text(
                          'No QR Code Generated',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                    : RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(
                          data: qrData,
                          size: 200,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          padding: const EdgeInsets.all(20),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              if (qrData.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isSaving || isSharing ? null : saveQRCodeToGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green[900],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            isSaving ? 'Saving...' : 'Save',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isSaving || isSharing ? null : shareQRCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.blue[900],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSharing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.share, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            isSharing ? 'Sharing...' : 'Share',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Enter text or URL',
                    labelStyle: TextStyle(color: Colors.blue[800]),
                    hintText: 'e.g., https://example.com',
                    hintStyle: TextStyle(color: Colors.blue[300]),
                    prefixIcon: const Icon(Icons.link, color: Colors.blueAccent),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: TextStyle(color: Colors.blue[900]),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: generateQRCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blue[900],
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
      backgroundColor: Colors.white,
    );
  }
}