import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String nameAr;
  final String? logoUrl;
  final String description;
  final String descriptionAr;
  final String? website;
  final String? location;
  final String? email;
  final String? phone;
  final Map<String, double> ratings; // e.g., {'health': 4.5, 'quality': 4.0}

  const Company({
    required this.id,
    required this.name,
    required this.nameAr,
    this.logoUrl,
    required this.description,
    required this.descriptionAr,
    this.website,
    this.location,
    this.email,
    this.phone,
    this.ratings = const {},
  });

  /// Overall average rating from all categories
  double get overallRating {
    if (ratings.isEmpty) return 0;
    return ratings.values.reduce((a, b) => a + b) / ratings.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'logoUrl': logoUrl,
      'description': description,
      'descriptionAr': descriptionAr,
      'website': website,
      'location': location,
      'email': email,
      'phone': phone,
      'ratings': ratings,
    };
  }

  factory Company.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String? ?? '',
      descriptionAr: data['descriptionAr'] as String? ?? '',
      website: data['website'] as String?,
      location: data['location'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      ratings:
          (data['ratings'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
    );
  }

  // Helper to get localized name
  String localizedName(String localeCode) {
    return localeCode == 'ar' && nameAr.isNotEmpty ? nameAr : name;
  }

  // Helper to get localized description
  String localizedDescription(String localeCode) {
    return localeCode == 'ar' && descriptionAr.isNotEmpty
        ? descriptionAr
        : description;
  }
}
