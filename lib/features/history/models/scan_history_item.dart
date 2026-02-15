import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistoryItem {
  final String id; // Document ID (usually the barcode)
  final String productId;
  final String barcode;
  final String productName;
  final String brand;
  final String? imageUrl;
  final DateTime scannedAt;
  final double? healthScore; // Optional: store cached score if available

  const ScanHistoryItem({
    required this.id,
    required this.productId,
    required this.barcode,
    required this.productName,
    required this.brand,
    this.imageUrl,
    required this.scannedAt,
    this.healthScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'imageUrl': imageUrl,
      'scannedAt': FieldValue.serverTimestamp(),
      'healthScore': healthScore,
    };
  }

  factory ScanHistoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanHistoryItem(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      barcode: data['barcode'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      healthScore: (data['healthScore'] as num?)?.toDouble(),
    );
  }
}
