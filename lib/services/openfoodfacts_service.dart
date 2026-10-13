import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Service for interacting with OpenFoodFacts API
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// Fetch product by barcode
  Future<Product?> getProduct(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v0/product/$barcode.json'),
        headers: {
          'User-Agent': 'FoodIngredientScanner/0.1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return Product.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Search products by query
  Future<List<Product>> searchProducts(String query, {int pageSize = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=$pageSize'),
        headers: {
          'User-Agent': 'FoodIngredientScanner/0.1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productsJson = data['products'] as List?;
        if (productsJson != null) {
          return productsJson
              .where((p) => p['code'] != null)
              .map((p) => Product.fromJson(p))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get ingredient information by ID
  Future<Map<String, dynamic>?> getIngredientInfo(String ingredientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cgi/ingredients.pl?code=$ingredientId&json=1'),
        headers: {
          'User-Agent': 'FoodIngredientScanner/0.1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if product exists
  Future<bool> productExists(String barcode) async {
    final product = await getProduct(barcode);
    return product != null && product.productName != null;
  }

  /// Get popular allergens list
  static const List<String> commonAllergens = [
    'Cereals containing gluten',
    'Crustaceans',
    'Eggs',
    'Fish',
    'Peanuts',
    'Soybeans',
    'Milk',
    'Nuts',
    'Celery',
    'Mustard',
    'Sesame',
    'Lupin',
    'Molluscs',
    'Sulphur dioxide and sulphites',
  ];
}
