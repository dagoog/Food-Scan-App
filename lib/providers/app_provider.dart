import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/ingredient.dart';
import '../models/avoid_list_item.dart';
import '../models/scanned_product.dart';
import '../models/user_preferences.dart';
import '../models/database_helper.dart';
import '../services/openfoodfacts_service.dart';

/// Main app state provider
class AppProvider with ChangeNotifier {
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // App state
  UserPreferences _preferences = UserPreferences();
  List<AvoidListItem> _avoidList = [];
  List<ScannedProduct> _scanHistory = [];
  Product? _currentProduct;
  ScannedProduct? _lastScan;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserPreferences get preferences => _preferences;
  List<AvoidListItem> get avoidList => _avoidList;
  List<ScannedProduct> get scanHistory => _scanHistory;
  Product? get currentProduct => _currentProduct;
  ScannedProduct? get lastScan => _lastScan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get avoidListCount => _avoidList.length;
  bool get isPremium => _preferences.isPremium;

  // Initialize app
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadAvoidList();
    notifyListeners();
  }

  // === Preferences ===

  Future<void> _loadPreferences() async {
    try {
      final prefsJson = await _dbHelper.getPreference('user_preferences');
      if (prefsJson != null) {
        _preferences = UserPreferences.fromJson(
          json.decode(prefsJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Silently fail - use defaults
    }
  }

  Future<void> updatePreferences(UserPreferences prefs) async {
    _preferences = prefs;
    await _dbHelper.savePreference(
      'user_preferences',
      json.encode(prefs.toJson()),
    );
    notifyListeners();
  }

  // === Avoid List ===

  Future<void> _loadAvoidList() async {
    try {
      _avoidList = await _dbHelper.getAllAvoidItems();
    } catch (e) {
      _avoidList = [];
    }
  }

  Future<void> addToAvoidList(AvoidListItem item) async {
    try {
      await _dbHelper.insertAvoidItem(item);
      _avoidList.add(item);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add item to avoid list';
      notifyListeners();
    }
  }

  Future<void> removeFromAvoidList(String id) async {
    try {
      await _dbHelper.deleteAvoidItem(id);
      _avoidList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updateAvoidList(AvoidListItem item) async {
    try {
      await _dbHelper.updateAvoidItem(item);
      final index = _avoidList.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _avoidList[index] = item;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Search avoid list for matching ingredients
  List<AvoidListItem> searchAvoidList(String query) {
    if (query.isEmpty) return _avoidList;
    final lowerQuery = query.toLowerCase();
    return _avoidList.where((item) {
      return item.ingredientName.toLowerCase().contains(lowerQuery) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // === Product Scanning ===

  /// Scan a product by barcode
  Future<void> scanProduct(String barcode, {String? scanMethod, double? confidence}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch product from API
      final product = await _apiService.getProduct(barcode);

      if (product == null) {
        _errorMessage = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Analyze ingredients against avoid list
      final matchedItems = _analyzeIngredients(product.ingredients ?? []);
      final safetyStatus = _determineSafetyStatus(product, matchedItems);

      _currentProduct = product;

      _lastScan = ScannedProduct(
        product: product,
        scanTime: DateTime.now(),
        matchedAvoidItems: matchedItems,
        safetyStatus: safetyStatus,
        scanMethod: scanMethod ?? 'barcode',
        confidence: confidence,
      );

      // Update scan history
      _scanHistory.insert(0, _lastScan!);
      if (_scanHistory.length > 50) {
        _scanHistory = _scanHistory.sublist(0, 50);
      }

      // Update usage counts for matched items
      for (final matchedId in matchedItems) {
        final index = _avoidList.indexWhere((item) => item.id == matchedId);
        if (index != -1) {
          final updated = _avoidList[index].incrementUsage();
          await updateAvoidList(updated);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to scan product';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Analyze product ingredients against avoid list
  List<String> _analyzeIngredients(List<Ingredient> ingredients) {
    final matchedIds = <String>{};

    for (final ingredient in ingredients) {
      // Check exact match
      final exactMatch = _avoidList.firstWhere(
        (item) => ingredient.id == item.id ||
            ingredient.name.toLowerCase() == item.ingredientName.toLowerCase(),
        orElse: () => AvoidListItem(id: '', ingredientName: ''),
      );

      if (exactMatch.id.isNotEmpty) {
        matchedIds.add(exactMatch.id);
        continue;
      }

      // Check partial match (ingredient name contains avoid item)
      for (final avoidItem in _avoidList) {
        if (ingredient.name.toLowerCase().contains(avoidItem.ingredientName.toLowerCase())) {
          matchedIds.add(avoidItem.id);
        }
        if (ingredient.description != null &&
            ingredient.description!.toLowerCase().contains(avoidItem.ingredientName.toLowerCase())) {
          matchedIds.add(avoidItem.id);
        }
      }
    }

    return matchedIds.toList();
  }

  /// Determine safety status based on product and matches
  SafetyStatus _determineSafetyStatus(Product product, List<String> matchedIds) {
    // If has allergens, mark as danger
    if (product.hasAllergens) {
      return SafetyStatus.danger;
    }

    // If matches with avoid list, mark based on match severity
    if (matchedIds.isNotEmpty) {
      // Check if any matches are high-severity (allergens)
      final hasAllergenMatch = matchedIds.any((id) {
        final item = _avoidList.firstWhere(
          (item) => item.id == id,
          orElse: () => AvoidListItem(id: '', ingredientName: ''),
        );
        return item.category == 'allergen';
      });

      return hasAllergenMatch ? SafetyStatus.danger : SafetyStatus.caution;
    }

    // Check nutriscore for general safety indication
    if (product.nutriscore != null) {
      if (product.nutriscore! <= 2) return SafetyStatus.safe;
      if (product.nutriscore! <= 3) return SafetyStatus.caution;
    }

    return SafetyStatus.unknown;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear current product
  void clearCurrentProduct() {
    _currentProduct = null;
    _lastScan = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
