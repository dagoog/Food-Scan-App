import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for handling barcode and OCR scanning
class ScanningService {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Scan barcode (called from mobile_scanner package)
  /// Returns the detected barcode string
  Future<String?> scanBarcode() async {
    // This is a placeholder - actual implementation uses MobileScanner widget
    // The widget will call this when a barcode is detected
    return null;
  }

  /// Process image with OCR to extract text
  Future<OCRResult?> processOCR(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = '';
      List<OCRBlock> blocks = [];

      for (TextBlock block in recognizedText.blocks) {
        String blockText = block.text;
        blocks.add(OCRBlock(
          text: blockText,
          boundingBox: block.boundingBox,
        ));
        fullText += '$blockText\n';
      }

      return OCRResult(
        text: fullText.trim(),
        blocks: blocks,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract potential ingredient keywords from OCR text
  Future<List<String>> extractIngredients(String ocrText) async {
    // Simple ingredient extraction - in production, use more sophisticated NLP
    final lines = ocrText.split('\n');
    final ingredients = <String>{};

    // Common ingredient keywords to look for
    final ingredientKeywords = [
      'ingredient',
      'contains',
      'ingrediente',
      'zutaten',
      'composi',
    ];

    for (final line in lines) {
      final lowerLine = line.toLowerCase();

      // Check if line mentions ingredients
      for (final keyword in ingredientKeywords) {
        if (lowerLine.contains(keyword)) {
          // Extract text after the keyword
          final index = lowerLine.indexOf(keyword);
          if (index != -1 && index + keyword.length < line.length) {
            final afterKeyword = line.substring(index + keyword.length);
            // Split by common separators
            final parts = afterKeyword.split(RegExp(r'[,,;]'));
            for (final part in parts) {
              final cleaned = part.trim();
              if (cleaned.length > 2 && cleaned.length < 50) {
                ingredients.add(cleaned);
              }
            }
          }
          break;
        }
      }
    }

    return ingredients.toList();
  }

  /// Capture image from camera
  Future<File?> captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if camera permission is available
  Future<bool> checkCameraPermission() async {
    // Platform-specific permission check
    if (Platform.isAndroid) {
      // Android permission check would go here
      return true;
    } else if (Platform.isIOS) {
      // iOS permission check would go here
      return true;
    }
    return false;
  }

  /// Clean up resources
  void dispose() {
    _textRecognizer.close();
  }
}

/// Result of OCR processing
class OCRResult {
  final String text;
  final List<OCRBlock> blocks;

  OCRResult({
    required this.text,
    required this.blocks,
  });

  bool get isValid => text.isNotEmpty;
}

/// A block of recognized text
class OCRBlock {
  final String text;
  final ui.Rect? boundingBox;

  OCRBlock({
    required this.text,
    this.boundingBox,
  });
}
