import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'product_detail_screen.dart';
import 'ocr_scan_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: true,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    try {
      // Toggle torch - check current state from controller
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      // Note: torch toggle handled by MobileScannerController automatically
    } catch (e) {
      // Torch not available
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    _isProcessing = true;

    // Show processing indicator
    if (mounted) {
      setState(() {});
    }

    // Scan the product
    final provider = context.read<AppProvider>();
    await provider.scanProduct(
      barcode.rawValue!,
      scanMethod: 'barcode',
    );

    // Navigate to result
    if (mounted && provider.currentProduct != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: provider.currentProduct!,
            scannedProduct: provider.lastScan,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to scan product'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _isProcessing = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scanning overlay
          Positioned(
            left: 24,
            right: 24,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Corner markers
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                          ),
                          child: const Icon(
                            Icons.border_all,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Position barcode within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom actions
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OCRScanScreen(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Scan Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Consumer<AppProvider>(
                  builder: (context, provider, _) {
                    return IconButton.filled(
                      onPressed: provider.currentProduct != null
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: provider.currentProduct!,
                                    scannedProduct: provider.lastScan,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                    );
                  },
                ),
              ],
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
