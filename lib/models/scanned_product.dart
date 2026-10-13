import 'product.dart';

/// Represents a scanned product with analysis results
class ScannedProduct {
  final Product product;
  final DateTime scanTime;
  final List<String> matchedAvoidItems;
  final SafetyStatus safetyStatus;
  final String? scanMethod; // 'barcode' or 'ocr'
  final double? confidence; // For OCR scans

  ScannedProduct({
    required this.product,
    required this.scanTime,
    this.matchedAvoidItems = const [],
    this.safetyStatus = SafetyStatus.unknown,
    this.scanMethod,
    this.confidence,
  });

  factory ScannedProduct.fromProduct(Product product, {
    required DateTime scanTime,
    List<String>? matchedAvoidItems,
    SafetyStatus? safetyStatus,
    String? scanMethod,
    double? confidence,
  }) {
    return ScannedProduct(
      product: product,
      scanTime: scanTime,
      matchedAvoidItems: matchedAvoidItems ?? [],
      safetyStatus: safetyStatus ?? SafetyStatus.unknown,
      scanMethod: scanMethod,
      confidence: confidence,
    );
  }

  bool get hasMatches => matchedAvoidItems.isNotEmpty;
  bool get isSafe => safetyStatus == SafetyStatus.safe;
  bool get needsAttention => safetyStatus == SafetyStatus.danger || hasMatches;
}

enum SafetyStatus {
  unknown,
  safe,
  caution,
  danger,
}

extension SafetyStatusExtension on SafetyStatus {
  String get displayName {
    switch (this) {
      case SafetyStatus.unknown:
        return 'Unknown';
      case SafetyStatus.safe:
        return 'Safe';
      case SafetyStatus.caution:
        return 'Caution';
      case SafetyStatus.danger:
        return 'Danger';
    }
  }

  String get color {
    switch (this) {
      case SafetyStatus.unknown:
        return '#9E9E9E';
      case SafetyStatus.safe:
        return '#4CAF50';
      case SafetyStatus.caution:
        return '#FFC107';
      case SafetyStatus.danger:
        return '#F44336';
    }
  }
}
