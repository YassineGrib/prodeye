// Seed script - can be run from a button or dev menu
// This file contains sample Algerian products for testing

import 'package:cloud_firestore/cloud_firestore.dart';

/// Sample Algerian products data for seeding Firestore
class SeedProducts {
  static Future<void> seedAll() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final collection = firestore.collection('products');

    for (final product in _sampleProducts) {
      final barcode = product['barcode'] as String;
      batch.set(collection.doc(barcode), {
        ...product,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  static final List<Map<String, dynamic>> _sampleProducts = [
    // ──── Hamoud Boualem ────
    {
      'barcode': '6111242000010',
      'name': 'Hamoud Boualem Selecto',
      'nameAr': 'حمود بوعلام سيلكتو',
      'brand': 'Hamoud Boualem',
      'category': 'beverages',
      'servingSize': 250,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'hamoud_boualem',
      'ingredients': [
        'water',
        'sugar',
        'carbon dioxide',
        'citric acid',
        'caramel color',
        'natural flavors',
      ],
      'allergens': [],
      'additives': ['E150d', 'E330'],
      'nutritionPer100g': {
        'calories': 42,
        'sugar': 10.5,
        'fat': 0,
        'saturatedFat': 0,
        'salt': 0.01,
        'protein': 0,
        'fiber': 0,
        'additivesCount': 2,
      },
    },
    // ──── Ifri Water ────
    {
      'barcode': '6130093010045',
      'name': 'Ifri Natural Mineral Water',
      'nameAr': 'مياه إيفري المعدنية الطبيعية',
      'brand': 'Ifri',
      'category': 'beverages',
      'servingSize': 500,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'ifri',
      'ingredients': ['natural mineral water'],
      'allergens': [],
      'additives': [],
      'nutritionPer100g': {
        'calories': 0,
        'sugar': 0,
        'fat': 0,
        'saturatedFat': 0,
        'salt': 0.005,
        'protein': 0,
        'fiber': 0,
        'additivesCount': 0,
      },
    },
    // ──── N'Gaous Juice ────
    {
      'barcode': '6130100000123',
      'name': 'N\'Gaous Orange Juice',
      'nameAr': 'عصير نقاوس برتقال',
      'brand': 'N\'Gaous',
      'category': 'beverages',
      'servingSize': 200,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'ngaous',
      'ingredients': [
        'orange juice concentrate',
        'water',
        'sugar',
        'citric acid',
        'vitamin C',
      ],
      'allergens': [],
      'additives': ['E330', 'E300'],
      'nutritionPer100g': {
        'calories': 46,
        'sugar': 10.8,
        'fat': 0.1,
        'saturatedFat': 0,
        'salt': 0.01,
        'protein': 0.5,
        'fiber': 0.2,
        'additivesCount': 2,
      },
    },
    // ──── Bel Milk (La Vache Qui Rit - Algeria) ────
    {
      'barcode': '6132001000215',
      'name': 'La Vache Qui Rit Processed Cheese',
      'nameAr': 'الجبن المطبوخ - البقرة الضاحكة',
      'brand': 'Bel Algérie',
      'category': 'dairy',
      'servingSize': 25,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'bel_algerie',
      'ingredients': [
        'cheese',
        'milk',
        'butter',
        'milk protein',
        'emulsifying salts',
        'salt',
      ],
      'allergens': ['milk', 'lactose', 'dairy'],
      'additives': ['E331', 'E452'],
      'nutritionPer100g': {
        'calories': 243,
        'sugar': 5.0,
        'fat': 18.0,
        'saturatedFat': 12.0,
        'salt': 3.0,
        'protein': 14.0,
        'fiber': 0,
        'additivesCount': 2,
      },
    },
    // ──── Amor Benamor Pasta ────
    {
      'barcode': '6120005000112',
      'name': 'Amor Benamor Spaghetti',
      'nameAr': 'سباغيتي عمر بن عمر',
      'brand': 'Amor Benamor',
      'category': 'grains',
      'servingSize': 100,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'amor_benamor',
      'ingredients': ['durum wheat semolina', 'water'],
      'allergens': ['gluten', 'wheat'],
      'additives': [],
      'nutritionPer100g': {
        'calories': 350,
        'sugar': 3.0,
        'fat': 1.5,
        'saturatedFat': 0.3,
        'salt': 0.01,
        'protein': 12.0,
        'fiber': 3.0,
        'additivesCount': 0,
      },
    },
    // ──── Cevital Cooking Oil ────
    {
      'barcode': '6140001000310',
      'name': 'Cevital Sunflower Oil',
      'nameAr': 'زيت عباد الشمس سيفيتال',
      'brand': 'Cevital',
      'category': 'oils',
      'servingSize': 15,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'cevital',
      'ingredients': ['refined sunflower oil', 'vitamin E'],
      'allergens': [],
      'additives': ['E306'],
      'nutritionPer100g': {
        'calories': 900,
        'sugar': 0,
        'fat': 100,
        'saturatedFat': 11.0,
        'salt': 0,
        'protein': 0,
        'fiber': 0,
        'additivesCount': 1,
      },
    },
    // ──── Saida Biscuits ────
    {
      'barcode': '6150002000416',
      'name': 'Biscuiterie de l\'Atlas Gaufrette Chocolat',
      'nameAr': 'غوفريت بالشوكولاتة - بسكويت الأطلس',
      'brand': 'Biscuiterie de l\'Atlas',
      'category': 'snacks',
      'servingSize': 30,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'biscuiterie_atlas',
      'ingredients': [
        'wheat flour',
        'sugar',
        'vegetable fat',
        'cocoa powder',
        'soy lecithin',
        'vanillin',
        'salt',
      ],
      'allergens': ['gluten', 'wheat'],
      'additives': ['E322', 'E150a'],
      'nutritionPer100g': {
        'calories': 520,
        'sugar': 35.0,
        'fat': 25.0,
        'saturatedFat': 14.0,
        'salt': 0.5,
        'protein': 5.0,
        'fiber': 1.5,
        'additivesCount': 2,
      },
    },
    // ──── Tchin Lait (Candia) ────
    {
      'barcode': '6160003000518',
      'name': 'Tchin Lait Candia Full Cream Milk',
      'nameAr': 'حليب كامل الدسم - تشين لاي كانديا',
      'brand': 'Tchin Lait Candia',
      'category': 'dairy',
      'servingSize': 200,
      'imageUrl': null,
      'origin': 'Algeria',
      'companyId': 'tchin_lait',
      'ingredients': ['whole milk', 'vitamin D'],
      'allergens': ['milk', 'lactose', 'dairy'],
      'additives': [],
      'nutritionPer100g': {
        'calories': 63,
        'sugar': 4.8,
        'fat': 3.5,
        'saturatedFat': 2.2,
        'salt': 0.11,
        'protein': 3.2,
        'fiber': 0,
        'additivesCount': 0,
      },
    },
  ];
}
