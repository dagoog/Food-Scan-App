/// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'FoodScan';
  static const String appVersion = '0.1.0';

  // Colors
  static const int primaryColor = 0xFF4CAF50;
  static const int secondaryColor = 0xFF8BC34A;
  static const int dangerColor = 0xFFF44336;
  static const int cautionColor = 0xFFFFC107;
  static const int safeColor = 0xFF4CAF50;
  static const int unknownColor = 0xFF9E9E9E;

  // API
  static const int apiTimeoutSeconds = 10;
  static const int maxCachedProducts = 50;

  // Scanner
  static const double ocrMinConfidence = 0.5;
  static const int maxScanHistory = 50;

  // Freemium limits
  static const int freeAvoidListLimit = 10;
  static const double premiumPrice = 4.99;

  // Categories for avoid list items
  static const List<String> itemCategories = [
    'Allergen',
    'Additive',
    'Preservative',
    'Color',
    'Flavor',
    'Processing Aid',
    'Other',
  ];

  // Common allergens (from OpenFoodFacts)
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
