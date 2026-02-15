import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/data/profile_repository.dart';
import '../models/favorite_item.dart';

// Provider for the repository
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(FirebaseFirestore.instance, ref);
});

// Stream provider for the list of favorites
final favoritesStreamProvider = StreamProvider<List<FavoriteItem>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavorites();
});

// Provider to check if a specific product is favorite
final isFavoriteProvider = StreamProvider.family<bool, String>((
  ref,
  productId,
) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isFavorite(productId);
});

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FavoritesRepository(this._firestore, this._ref);

  Future<String?> get _userId async {
    final user = await _ref.read(userProfileProvider.future);
    return user?.uid;
  }

  // Collection reference: users/{userId}/favorites
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final uid = await _userId;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  // Get all favorites as a stream
  Stream<List<FavoriteItem>> getFavorites() async* {
    final uid = await _userId;
    if (uid == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return FavoriteItem.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Check if a product or company is in favorites
  Stream<bool> isFavorite(String id) async* {
    final uid = await _userId;
    if (uid == null) {
      yield false;
      return;
    }

    yield* _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Add item to favorites
  Future<void> addToFavorites(FavoriteItem item) async {
    final collection = await _getCollection();
    await collection.doc(item.id).set(item.toMap());
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String id) async {
    final collection = await _getCollection();
    await collection.doc(id).delete();
  }
}
