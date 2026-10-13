/// Represents a food ingredient
class Ingredient {
  final String id;
  final String name;
  final String? description;
  final String? germanName;
  final String? veganStatus;
  final String? vegetarianStatus;
  final String? allergenInfo;
  final List<String>? categories;
  final List<String>? additives;

  Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.germanName,
    this.veganStatus,
    this.vegetarianStatus,
    this.allergenInfo,
    this.categories,
    this.additives,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      germanName: json['german_name'],
      veganStatus: json['vegan_status'],
      vegetarianStatus: json['vegetarian_status'],
      allergenInfo: json['allergen_info'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      additives: json['additives'] != null
          ? List<String>.from(json['additives'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'german_name': germanName,
      'vegan_status': veganStatus,
      'vegetarian_status': vegetarianStatus,
      'allergen_info': allergenInfo,
      'categories': categories,
      'additives': additives,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
