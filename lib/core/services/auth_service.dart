import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current user's role from Firestore.
/// Returns 'user' by default if role is not set.
final userRoleProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'user';

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return 'user';

  final data = doc.data() as Map<String, dynamic>;
  return data['role'] as String? ?? 'user';
});

/// Check if the current user is an admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role == 'admin';
});

/// Auth service for role-based operations
class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the role of the currently logged-in user
  Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'user';

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return 'user';

    final data = doc.data() as Map<String, dynamic>;
    return data['role'] as String? ?? 'user';
  }

  /// Ensure the current user has a Firestore document.
  /// Creates one if missing (for accounts created via Firebase Auth console).
  Future<void> ensureUserDocExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Update a user's role (admin operation)
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
