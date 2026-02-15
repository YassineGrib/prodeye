import 'package:cloud_firestore/cloud_firestore.dart';

enum FavoriteType { product, company }

class FavoriteItem {
  final String id;
  final FavoriteType type;
  final String name;
  final String? subtitle; // Brand for products, Location/Desc for companies
  final String? barcode; // Product only
  final String? imageUrl;
  final String? companyId; // Product only
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    this.type = FavoriteType.product,
    required this.name,
    this.subtitle,
    this.barcode,
    this.imageUrl,
    this.companyId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'subtitle': subtitle, // Brand or Location
      'barcode': barcode,
      'imageUrl': imageUrl,
      'companyId': companyId,
      'addedAt': Timestamp.fromDate(addedAt),
      // Backward compatibility for existing product favorites
      if (type == FavoriteType.product) ...{
        'productId': id,
        'productName': name,
        'brand': subtitle,
      },
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map, String docId) {
    final typeStr = map['type'] as String? ?? 'product';
    final type = FavoriteType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => FavoriteType.product,
    );

    return FavoriteItem(
      id: docId,
      type: type,
      name: map['name'] ?? map['productName'] ?? '',
      subtitle: map['subtitle'] ?? map['brand'],
      barcode: map['barcode'],
      imageUrl: map['imageUrl'],
      companyId: map['companyId'],
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
