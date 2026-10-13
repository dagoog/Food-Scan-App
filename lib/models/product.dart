import 'ingredient.dart';

/// Represents a food product from OpenFoodFacts
class Product {
  final String barcode;
  final String? productName;
  final String? brand;
  final List<String>? brands;
  final String? quantity;
  final List<Ingredient>? ingredients;
  final String? ingredientsText;
  final List<String>? ingredientsTags;
  final String? imageUrl;
  final double? nutriscore;
  final String? ecodes;
  final bool? noNuts;
  final String? allergens;
  final DateTime? lastModified;

  Product({
    required this.barcode,
    this.productName,
    this.brand,
    this.brands,
    this.quantity,
    this.ingredients,
    this.ingredientsText,
    this.ingredientsTags,
    this.imageUrl,
    this.nutriscore,
    this.ecodes,
    this.noNuts,
    this.allergens,
    this.lastModified,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['code'] ?? '',
      productName: json['product_name'],
      brand: json['brands'] ?? json['brand'],
      brands: json['brands_tags'] != null
          ? List<String>.from(json['brands_tags'])
          : null,
      quantity: json['quantity'],
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => Ingredient.fromJson(i))
          .toList(),
      ingredientsText: json['ingredients_text_en'],
      ingredientsTags: json['ingredients_tags'] != null
          ? List<String>.from(json['ingredients_tags'])
          : null,
      imageUrl: json['image_url'],
      nutriscore: json['nutriscore_grade'] != null
          ? _parseNutriscore(json['nutriscore_grade'])
          : null,
      ecodes: json['ecoscore_grade'],
      noNuts: json['no_nuts'],
      allergens: json['allergens_tags_en'] != null
          ? _formatAllergens(json['allergens_tags_en'])
          : null,
      lastModified: json['last_modified_t'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['last_modified_t'] * 1000).toInt())
          : null,
    );
  }

  static double _parseNutriscore(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return 1.0;
      case 'b':
        return 2.0;
      case 'c':
        return 3.0;
      case 'd':
        return 4.0;
      case 'e':
        return 5.0;
      default:
        return 0.0;
    }
  }

  static String _formatAllergens(List<String> tags) {
    return tags
        .where((t) => !t.contains('may') && !t.contains('traces'))
        .map((t) => t.replaceAll('-', ' '))
        .join(', ');
  }

  factory Product.empty(String barcode) {
    return Product(barcode: barcode);
  }

  Map<String, dynamic> toJson() {
    return {
      'code': barcode,
      'product_name': productName,
      'brands': brand,
      'quantity': quantity,
      'ingredients': ingredients?.map((i) => i.toJson()).toList(),
      'ingredients_text_en': ingredientsText,
      'ingredients_tags': ingredientsTags,
      'image_url': imageUrl,
      'nutriscore_grade': nutriscore != null ? _nutriscoreToGrade(nutriscore!) : null,
      'ecoscore_grade': ecodes,
      'last_modified_t': lastModified != null
          ? lastModified!.millisecondsSinceEpoch / 1000
          : null,
    };
  }

  static String _nutriscoreToGrade(double grade) {
    switch (grade.toInt()) {
      case 1:
        return 'a';
      case 2:
        return 'b';
      case 3:
        return 'c';
      case 4:
        return 'd';
      case 5:
        return 'e';
      default:
        return '';
    }
  }

  /// Check if product has any allergens listed
  bool get hasAllergens => allergens != null && allergens!.isNotEmpty;

  /// Get safety status based on nutriscore
  String get safetyRating {
    if (nutriscore == null) return 'unknown';
    if (nutriscore! <= 2) return 'good';
    if (nutriscore! <= 3) return 'moderate';
    return 'poor';
  }
}
