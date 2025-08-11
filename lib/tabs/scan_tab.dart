import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilltongapp/models/prescription.dart';
import 'package:pilltongapp/services/firestore_service.dart';
import 'package:pilltongapp/services/ocr_service.dart';
import 'package:pilltongapp/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final OcrService _ocrService = OcrService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isProcessing = false;

  /// Handles the entire process of picking, uploading, and processing an image.
  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      final imageFile = File(image.path);

      // 1. Upload image to Firebase Storage
      print('Uploading image to Firebase Storage...');
      final imageUrl = await _storageService.uploadPrescriptionImage(imageFile);
      if (imageUrl == null) {
        _showError('Failed to upload image.');
        return;
      }
      print('Image uploaded successfully: $imageUrl');

      // 2. Recognize text from the image
      print('Recognizing text from image...');
      final recognizedText = await _ocrService.recognizeText(imageFile);
      print('Text recognized: $recognizedText');

      // 3. Save the data to Firestore
      print('Saving prescription to Firestore...');
      final newPrescription = Prescription(
        id: '', // Firestore will generate this
        imageUrl: imageUrl,
        recognizedText: recognizedText,
        createdAt: Timestamp.now(),
      );
      
      await _firestoreService.addPrescription(newPrescription);
      print('Prescription saved successfully');

      _showSuccess('Prescription saved successfully!');
    } catch (e) {
      print('Error in _pickAndProcessImage: $e');
      _showError('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스캔하기'),
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('처리 중...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR 코드로 약물 추가'),
                    onPressed: () {
                      _showError('QR Code scanning is not implemented yet.');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('카메라로 처방전 촬영'),
                    onPressed: () => _pickAndProcessImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('갤러리에서 처방전 선택'),
                    onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
