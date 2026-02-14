import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

// Provider for the repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

// Stream provider for the current user's profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.userProfileStream();
});

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  CollectionReference get _usersCollection => _firestore.collection('users');

  // Stream of the current user's profile
  Stream<UserProfile?> userProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _usersCollection.doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get user profile once
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _usersCollection.doc(user.uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }

  // Connect authentication with profile creation
  Future<void> createProfileIfNew() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _usersCollection.doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create new empty profile
      final newProfile = UserProfile.empty(
        uid: user.uid,
        email: user.email ?? '',
      ).toMap(); // Convert to map for saving

      // Fix: toMap includes createdAt and updatedAt logic inside.
      // But for initial create we might want to ensure server timestamps if using FieldValue

      await docRef.set(newProfile);
    }
  }

  // Update specific fields
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");
    if (user.uid != profile.uid) throw Exception("User ID mismatch");

    await _usersCollection.doc(user.uid).update(profile.toMap());
  }
}
