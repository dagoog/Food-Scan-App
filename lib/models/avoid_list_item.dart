/// Represents an item in the user's avoid list
class AvoidListItem {
  final String id;
  final String ingredientName;
  final String? description;
  final String? category; // e.g., 'allergen', 'additive', 'preservative'
  final DateTime createdAt;
  final DateTime? lastUsed;
  int usageCount;
  String? userNotes;

  AvoidListItem({
    required this.id,
    required this.ingredientName,
    this.description,
    this.category,
    DateTime? createdAt,
    this.lastUsed,
    this.usageCount = 0,
    this.userNotes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AvoidListItem.fromJson(Map<String, dynamic> json) {
    return AvoidListItem(
      id: json['id'],
      ingredientName: json['ingredient_name'],
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      lastUsed: json['last_used'] != null
          ? DateTime.parse(json['last_used'])
          : null,
      usageCount: json['usage_count'] ?? 0,
      userNotes: json['user_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_name': ingredientName,
      'description': description,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'last_used': lastUsed?.toIso8601String(),
      'usage_count': usageCount,
      'user_notes': userNotes,
    };
  }

  AvoidListItem copyWith({
    String? id,
    String? ingredientName,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
    String? userNotes,
  }) {
    return AvoidListItem(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      userNotes: userNotes ?? this.userNotes,
    );
  }

  /// Increment usage count and update last used date
  AvoidListItem incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }
}
