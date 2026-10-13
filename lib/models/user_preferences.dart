/// User preferences for the app
class UserPreferences {
  bool enableNotifications;
  bool darkMode;
  bool autoFlashlight;
  bool vibrationFeedback;
  bool soundFeedback;
  int maxCachedProducts;
  String language;
  bool premium;
  DateTime? premiumExpiry;

  UserPreferences({
    this.enableNotifications = true,
    this.darkMode = false,
    this.autoFlashlight = true,
    this.vibrationFeedback = true,
    this.soundFeedback = true,
    this.maxCachedProducts = 50,
    this.language = 'en',
    this.premium = false,
    this.premiumExpiry,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      enableNotifications: json['enable_notifications'] ?? true,
      darkMode: json['dark_mode'] ?? false,
      autoFlashlight: json['auto_flashlight'] ?? true,
      vibrationFeedback: json['vibration_feedback'] ?? true,
      soundFeedback: json['sound_feedback'] ?? true,
      maxCachedProducts: json['max_cached_products'] ?? 50,
      language: json['language'] ?? 'en',
      premium: json['premium'] ?? false,
      premiumExpiry: json['premium_expiry'] != null
          ? DateTime.parse(json['premium_expiry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_notifications': enableNotifications,
      'dark_mode': darkMode,
      'auto_flashlight': autoFlashlight,
      'vibration_feedback': vibrationFeedback,
      'sound_feedback': soundFeedback,
      'max_cached_products': maxCachedProducts,
      'language': language,
      'premium': premium,
      'premium_expiry': premiumExpiry?.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    bool? enableNotifications,
    bool? darkMode,
    bool? autoFlashlight,
    bool? vibrationFeedback,
    bool? soundFeedback,
    int? maxCachedProducts,
    String? language,
    bool? premium,
    DateTime? premiumExpiry,
  }) {
    return UserPreferences(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      darkMode: darkMode ?? this.darkMode,
      autoFlashlight: autoFlashlight ?? this.autoFlashlight,
      vibrationFeedback: vibrationFeedback ?? this.vibrationFeedback,
      soundFeedback: soundFeedback ?? this.soundFeedback,
      maxCachedProducts: maxCachedProducts ?? this.maxCachedProducts,
      language: language ?? this.language,
      premium: premium ?? this.premium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
    );
  }

  bool get isPremium => premium &&
      (premiumExpiry == null || premiumExpiry!.isAfter(DateTime.now()));
}
