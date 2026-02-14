import 'package:cloud_firestore/cloud_firestore.dart';

/// Nutrition data for a food product (values per 100g)
class NutritionInfo {
  final double calories; // kcal
  final double sugar; // g
  final double fat; // g
  final double saturatedFat; // g
  final double salt; // g
  final double protein; // g
  final double? fiber; // g (optional)
  final int additivesCount; // number of additives

  const NutritionInfo({
    required this.calories,
    required this.sugar,
    required this.fat,
    required this.saturatedFat,
    required this.salt,
    required this.protein,
    this.fiber,
    this.additivesCount = 0,
  });

  /// Convert per-100g values to per-serving values
  NutritionInfo perServing(double servingGrams) {
    final factor = servingGrams / 100.0;
    return NutritionInfo(
      calories: calories * factor,
      sugar: sugar * factor,
      fat: fat * factor,
      saturatedFat: saturatedFat * factor,
      salt: salt * factor,
      protein: protein * factor,
      fiber: fiber != null ? fiber! * factor : null,
      additivesCount: additivesCount, // count doesn't scale
    );
  }

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'sugar': sugar,
    'fat': fat,
    'saturatedFat': saturatedFat,
    'salt': salt,
    'protein': protein,
    'fiber': fiber,
    'additivesCount': additivesCount,
  };

  factory NutritionInfo.fromMap(Map<String, dynamic> map) => NutritionInfo(
    calories: (map['calories'] as num?)?.toDouble() ?? 0,
    sugar: (map['sugar'] as num?)?.toDouble() ?? 0,
    fat: (map['fat'] as num?)?.toDouble() ?? 0,
    saturatedFat: (map['saturatedFat'] as num?)?.toDouble() ?? 0,
    salt: (map['salt'] as num?)?.toDouble() ?? 0,
    protein: (map['protein'] as num?)?.toDouble() ?? 0,
    fiber: (map['fiber'] as num?)?.toDouble(),
    additivesCount: (map['additivesCount'] as num?)?.toInt() ?? 0,
  );
}

/// A food product that can be scanned and analyzed
class Product {
  final String id; // Firestore document ID (= barcode)
  final String barcode;
  final String name;
  final String nameAr; // Arabic name
  final String brand;
  final String? imageUrl;
  final String? category;
  final double servingSize; // in grams
  final NutritionInfo nutritionPer100g;
  final List<String> ingredients;
  final List<String> allergens; // e.g. ['lactose', 'gluten', 'nuts']
  final List<String> additives; // e.g. ['E621', 'E330']
  final String? companyId;
  final String? origin; // country of origin
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.barcode,
    required this.name,
    this.nameAr = '',
    required this.brand,
    this.imageUrl,
    this.category,
    this.servingSize = 100,
    required this.nutritionPer100g,
    this.ingredients = const [],
    this.allergens = const [],
    this.additives = const [],
    this.companyId,
    this.origin,
    this.createdAt,
    this.updatedAt,
  });

  /// Nutrition values for one serving
  NutritionInfo get nutritionPerServing =>
      nutritionPer100g.perServing(servingSize);

  Map<String, dynamic> toMap() => {
    'barcode': barcode,
    'name': name,
    'nameAr': nameAr,
    'brand': brand,
    'imageUrl': imageUrl,
    'category': category,
    'servingSize': servingSize,
    'nutritionPer100g': nutritionPer100g.toMap(),
    'ingredients': ingredients,
    'allergens': allergens,
    'additives': additives,
    'companyId': companyId,
    'origin': origin,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      barcode: data['barcode'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String?,
      servingSize: (data['servingSize'] as num?)?.toDouble() ?? 100,
      nutritionPer100g: data['nutritionPer100g'] != null
          ? NutritionInfo.fromMap(
              data['nutritionPer100g'] as Map<String, dynamic>,
            )
          : const NutritionInfo(
              calories: 0,
              sugar: 0,
              fat: 0,
              saturatedFat: 0,
              salt: 0,
              protein: 0,
            ),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      allergens: List<String>.from(data['allergens'] ?? []),
      additives: List<String>.from(data['additives'] ?? []),
      companyId: data['companyId'] as String?,
      origin: data['origin'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
