import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/models/user_profile.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(firestore: FirebaseFirestore.instance);
});

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get total user count
  Future<int> getUserCount() async {
    final snapshot = await _usersCollection.count().get();
    return snapshot.count ?? 0;
  }

  /// Get all users
  Future<List<UserProfile>> getAllUsers() async {
    final results = await _usersCollection.get();
    return results.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Ensure uid is in the data
      if (!data.containsKey('uid')) {
        data['uid'] = doc.id;
      }
      if (!data.containsKey('email')) {
        data['email'] = '';
      }
      return UserProfile.fromMap(data);
    }).toList();
  }

  /// Search users by name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return getAllUsers();

    // Search by email (exact prefix match)
    final results = await _usersCollection
        .orderBy('email')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return results.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('uid')) data['uid'] = doc.id;
      if (!data.containsKey('email')) data['email'] = '';
      return UserProfile.fromMap(data);
    }).toList();
  }

  /// Update user role
  Future<void> updateUserRole(String uid, String role) async {
    await _usersCollection.doc(uid).update({'role': role});
  }
}
