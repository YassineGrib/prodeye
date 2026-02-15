import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/models/product.dart';
import '../models/scan_history_item.dart';

// Provider for the history repository
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

// Stream provider for recent scans
final recentScansProvider = StreamProvider.autoDispose<List<ScanHistoryItem>>((
  ref,
) {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.watchRecentScans();
});

// Stream provider for all history
final historyProvider = StreamProvider.autoDispose<List<ScanHistoryItem>>((
  ref,
) {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.watchHistory();
});

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HistoryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  /// Add a product to the user's scan history
  Future<void> addToHistory(Product product, {double? healthScore}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final historyRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history');

    // Updates existing entry timestamp if exists, or creates new one
    await historyRef.doc(product.barcode).set({
      'productId': product.id,
      'barcode': product.barcode,
      'productName': product.name,
      'imageUrl': product.imageUrl,
      'brand': product.brand,
      'scannedAt': FieldValue.serverTimestamp(),
      if (healthScore != null) 'healthScore': healthScore,
    }, SetOptions(merge: true));
  }

  /// Watch recent scans for the current user
  Stream<List<ScanHistoryItem>> watchRecentScans({int limit = 10}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ScanHistoryItem.fromFirestore(doc))
              .toList();
        });
  }

  /// Watch scan history for the current user (paginated in UI, but here we can just stream all or limit to 50)
  Stream<List<ScanHistoryItem>> watchHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('scannedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ScanHistoryItem.fromFirestore(doc))
              .toList();
        });
  }

  /// Clear history
  Future<void> clearHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
