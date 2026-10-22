import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/scanning_service.dart';
import '../utils/theme.dart';

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({super.key});

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  final ScanningService _scanningService = ScanningService();
  bool _isProcessing = false;
  String? _extractedText;
  File? _capturedImage;
  String? _errorMessage;

  @override
  void dispose() {
    _scanningService.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final image = await _scanningService.captureImage();
      if (image == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No image captured';
        });
        return;
      }

      setState(() => _capturedImage = image);

      final result = await _scanningService.processOCR(image);
      if (result == null || !result.isValid) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No text detected. Try again with better lighting.';
        });
        return;
      }

      setState(() {
        _extractedText = result.text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image: ${e.toString()}';
      });
    }
  }

  Future<void> _pickAndProcess() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final image = await _scanningService.pickImage();
      if (image == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No image selected';
        });
        return;
      }

      setState(() => _capturedImage = image);

      final result = await _scanningService.processOCR(image);
      if (result == null || !result.isValid) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No text detected. Try again with a clearer image.';
        });
        return;
      }

      setState(() {
        _extractedText = result.text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image: ${e.toString()}';
      });
    }
  }

  void _copyText() {
    if (_extractedText != null) {
      Clipboard.setData(ClipboardData(text: _extractedText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearResult() {
    setState(() {
      _extractedText = null;
      _capturedImage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredients'),
        actions: [
          if (_extractedText != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyText,
              tooltip: 'Copy text',
            ),
          if (_extractedText != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearResult,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_extractedText != null)
            _buildResultView()
          else
            _buildInitialView(),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text(
              'Ingredient Text Scanner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Capture or select an image of ingredient list to extract the text',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null) _buildErrorBanner(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _captureAndProcess,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture from Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _pickAndProcess,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_capturedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _capturedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Extracted Text:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _extractedText!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Next Steps:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildActionCard(
            icon: Icons.edit,
            title: 'Manually Enter Ingredients',
            description: 'Copy the text and paste it into a note or document',
            onTap: _copyText,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.camera_alt,
            title: 'Scan Another Image',
            description: 'Try scanning a different product',
            onTap: _clearResult,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text(
              'Processing text...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
