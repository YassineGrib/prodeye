import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promo_ad.dart';

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository(firestore: FirebaseFirestore.instance);
});

/// Provider for active promo ads (client-facing) - usage of StreamProvider for real-time updates
final activePromosProvider = StreamProvider<List<PromoAd>>((ref) {
  return ref.watch(promoRepositoryProvider).getActivePromosStream();
});

/// Provider for all promos (admin-facing) - usage of StreamProvider for real-time updates
final allPromosProvider = StreamProvider<List<PromoAd>>((ref) {
  return ref.watch(promoRepositoryProvider).getAllPromosStream();
});

class PromoRepository {
  final FirebaseFirestore _firestore;

  PromoRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _collection => _firestore.collection('promos');

  /// Get only active promos within their date range, ordered by [order]
  Stream<List<PromoAd>> getActivePromosStream() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PromoAd.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .where((ad) => ad.isCurrentlyActive)
              .toList();
        });
  }

  /// Get all promos (for admin)
  Stream<List<PromoAd>> getAllPromosStream() {
    return _collection.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                PromoAd.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
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
