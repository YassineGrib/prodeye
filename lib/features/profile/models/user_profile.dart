import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_condition.dart';
import 'lifestyle.dart';
import 'diet_type.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final int? age;
  final String? gender; // 'Male', 'Female', 'Other'
  final double? height; // in cm
  final double? weight; // in kg
  final List<HealthCondition> healthConditions;
  final Lifestyle lifestyle;
  final DietType dietType;
  final String role; // 'user' or 'admin'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.healthConditions = const [],
    this.lifestyle = Lifestyle.sedentary,
    this.dietType = DietType.balanced,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  // Create an empty profile for a new user
  factory UserProfile.empty({required String uid, required String email}) {
    return UserProfile(
      uid: uid,
      email: email,
      role: 'user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    List<HealthCondition>? healthConditions,
    Lifestyle? lifestyle,
    DietType? dietType,
    String? role,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      healthConditions: healthConditions ?? this.healthConditions,
      lifestyle: lifestyle ?? this.lifestyle,
      dietType: dietType ?? this.dietType,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'healthConditions': healthConditions.map((e) => e.name).toList(),
      'lifestyle': lifestyle.name,
      'dietType': dietType.name,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      healthConditions:
          (map['healthConditions'] as List<dynamic>?)
              ?.map((e) => HealthConditionExtension.fromString(e.toString()))
              .toList() ??
          [],
      lifestyle: LifestyleExtension.fromString(
        map['lifestyle'] as String? ?? '',
      ),
      dietType: DietTypeExtension.fromString(map['dietType'] as String? ?? ''),
      role: map['role'] as String? ?? 'user',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }
}
