import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';

// Provider for the repository
final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository(firestore: FirebaseFirestore.instance);
});

class CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _companiesCollection =>
      _firestore.collection('companies');

  /// Get a company by its ID
  Future<Company?> getCompanyById(String id) async {
    final doc = await _companiesCollection.doc(id).get();
    if (doc.exists) {
      return Company.fromFirestore(doc);
    }
    return null;
  }

  /// Search companies by name
  Future<List<Company>> searchCompanies(String query, {int limit = 10}) async {
    if (query.isEmpty) return [];

    // Search in name (simple startAt/endAt search)
    // For production, Algolia or Typesense is recommended for fuzzy search
    final results = await _companiesCollection
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(limit)
        .get();
    return results.docs.map((doc) => Company.fromFirestore(doc)).toList();
  }

  /// Get all companies (paginated)
  Future<List<Company>> getAllCompanies({int limit = 20}) async {
    final results = await _companiesCollection.limit(limit).get();
    return results.docs.map((doc) => Company.fromFirestore(doc)).toList();
  }
}
