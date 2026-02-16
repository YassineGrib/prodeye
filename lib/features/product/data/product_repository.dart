import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Provider for the repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(firestore: FirebaseFirestore.instance);
});

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  /// Look up a product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    // First, try direct document lookup (barcode as document ID)
    final doc = await _productsCollection.doc(barcode).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }

    // Fallback: query by barcode field
    final query = await _productsCollection
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Product.fromFirestore(query.docs.first);
    }

    return null;
  }

  /// Get a product by its document ID
  Future<Product?> getProductById(String id) async {
    final doc = await _productsCollection.doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  /// Add a new product (uses barcode as document ID)
  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.barcode).set(product.toMap());
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.barcode).update(product.toMap());
  }

  /// Delete a product by barcode
  Future<void> deleteProduct(String barcode) async {
    await _productsCollection.doc(barcode).delete();
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];

    final results = await _productsCollection
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(limit)
        .get();

    return results.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  /// Get all products by a company
  Future<List<Product>> getProductsByCompany(String companyId) async {
    final results = await _productsCollection
        .where('companyId', isEqualTo: companyId)
        .get();

    return results.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  /// Get recently added products
  Future<List<Product>> getRecentProducts({int limit = 10}) async {
    final results = await _productsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return results.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  /// Get all products (for admin)
  Future<List<Product>> getAllProducts() async {
    final results = await _productsCollection.get();
    return results.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  /// Get total product count
  Future<int> getProductCount() async {
    final snapshot = await _productsCollection.count().get();
    return snapshot.count ?? 0;
  }
}
