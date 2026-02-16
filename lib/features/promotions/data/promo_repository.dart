import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promo_ad.dart';

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository(firestore: FirebaseFirestore.instance);
});

/// Provider for active promo ads (client-facing)
final activePromosProvider = FutureProvider<List<PromoAd>>((ref) {
  return ref.watch(promoRepositoryProvider).getActivePromos();
});

/// Provider for all promos (admin-facing)
final allPromosProvider = FutureProvider<List<PromoAd>>((ref) {
  return ref.watch(promoRepositoryProvider).getAllPromos();
});

class PromoRepository {
  final FirebaseFirestore _firestore;

  PromoRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _collection => _firestore.collection('promos');

  /// Get only active promos within their date range, ordered by [order]
  Future<List<PromoAd>> getActivePromos() async {
    final snapshot = await _collection
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map(
          (doc) => PromoAd.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .where((ad) => ad.isCurrentlyActive)
        .toList();
  }

  /// Get all promos (for admin)
  Future<List<PromoAd>> getAllPromos() async {
    final snapshot = await _collection.orderBy('order').get();
    return snapshot.docs
        .map(
          (doc) => PromoAd.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Create a new promo
  Future<void> addPromo(PromoAd promo) async {
    await _collection.add(promo.toMap());
  }

  /// Update an existing promo
  Future<void> updatePromo(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  /// Delete a promo
  Future<void> deletePromo(String id) async {
    await _collection.doc(id).delete();
  }

  /// Get promo count
  Future<int> getPromoCount() async {
    final snapshot = await _collection.count().get();
    return snapshot.count ?? 0;
  }
}
