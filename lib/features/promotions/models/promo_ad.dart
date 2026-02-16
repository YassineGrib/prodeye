import 'package:cloud_firestore/cloud_firestore.dart';

class PromoAd {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? companyName;
  final String? targetProductBarcode; // tap to navigate to this product
  final String? externalUrl;
  final int order; // display order
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;

  const PromoAd({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.companyName,
    this.targetProductBarcode,
    this.externalUrl,
    this.order = 0,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.createdAt,
  });

  factory PromoAd.fromMap(String id, Map<String, dynamic> map) {
    return PromoAd(
      id: id,
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      imageUrl: map['imageUrl'] as String?,
      companyName: map['companyName'] as String?,
      targetProductBarcode: map['targetProductBarcode'] as String?,
      externalUrl: map['externalUrl'] as String?,
      order: map['order'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      startsAt: (map['startsAt'] as Timestamp?)?.toDate(),
      endsAt: (map['endsAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'companyName': companyName,
      'targetProductBarcode': targetProductBarcode,
      'externalUrl': externalUrl,
      'order': order,
      'isActive': isActive,
      'startsAt': startsAt != null ? Timestamp.fromDate(startsAt!) : null,
      'endsAt': endsAt != null ? Timestamp.fromDate(endsAt!) : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Check if the ad is currently within its active date range
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }
}
