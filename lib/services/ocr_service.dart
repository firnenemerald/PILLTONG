import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// A service to handle Optical Character Recognition (OCR).
class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.korean);

  /// Processes an image file and returns the recognized text.
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      print('Error recognizing text: $e');
      return 'Text recognition failed.';
    } finally {
      _textRecognizer.close();
    }
  }
}
