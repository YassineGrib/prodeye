import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanySeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedCompanies() async {
    final List<Map<String, dynamic>> companies = [
      {
        'id': 'cevital',
        'name': 'Cevital',
        'nameAr': 'سيفيتال',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/thumb/5/52/Logo_Cevital.svg/1200px-Logo_Cevital.svg.png',
        'description':
            'Leading Algerian agri-food company known for sugar, oil, and margarine.',
        'descriptionAr':
            'شركة جزائرية رائدة في مجال الصناعات الغذائية معروفة بالسكر والزيت والسمن.',
        'website': 'https://www.cevital.com',
        'location': 'Bejaia, Algeria',
        'ratings': {'health': 3.5, 'quality': 4.5, 'taste': 4.0, 'price': 3.0},
      },
      {
        'id': 'rouiba',
        'name': 'Rouiba',
        'nameAr': 'رويبة',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/e/e9/Logo_Rouiba.png',
        'description':
            'Popular Algerian fruit juice brand offering various flavors.',
        'descriptionAr':
            'علامة تجارية جزائرية مشهورة لعصائر الفاكهة تقدم نكهات متنوعة.',
        'website': 'https://rouiba.com',
        'location': 'Rouiba, Algiers',
        'ratings': {'health': 3.0, 'quality': 4.0, 'taste': 4.8, 'price': 4.0},
      },
      {
        'id': 'soummam',
        'name': 'Soummam',
        'nameAr': 'صومام',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/0/06/Logo_Soummam.png',
        'description':
            'One of the largest dairy producers in Algeria, specializing in yogurt and cheese.',
        'descriptionAr':
            'واحدة من أكبر منتجي الألبان في الجزائر، متخصصة في الزبادي والجبن.',
        'website': 'https://soummam.com',
        'location': 'Akbou, Bejaia',
        'ratings': {'health': 4.2, 'quality': 4.6, 'taste': 4.5, 'price': 3.5},
      },
      {
        'id': 'candia_dz',
        'name': 'Candia Algeria',
        'nameAr': 'كانديا الجزائر',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/thumb/9/9d/Logo_Candia.svg/1200px-Logo_Candia.svg.png',
        'description':
            'Provide high-quality milk and dairy products suited for Algerian families.',
        'descriptionAr':
            'توفير حليب ومنتجات ألبان عالية الجودة تناسب العائلات الجزائرية.',
        'website': 'https://candia-dz.com',
        'location': 'Bejaia, Algeria',
        'ratings': {'health': 4.5, 'quality': 4.4, 'taste': 4.2, 'price': 2.5},
      },
      {
        'id': 'palmary',
        'name': 'Palmary',
        'nameAr': 'بالماري',
        'logoUrl':
            'https://palmary-food.com/wp-content/uploads/2020/06/logo-palmary-1.png',
        'description':
            'Known for biscuits, cakes, and other confectionery products.',
        'descriptionAr': 'معروفة بالبسكويت والكعك ومنتجات الحلويات الأخرى.',
        'website': 'https://palmary-food.com',
        'location': 'Blida, Algeria',
        'ratings': {'health': 2.5, 'quality': 4.0, 'taste': 4.5, 'price': 4.5},
      },
      {
        'id': 'bimo',
        'name': 'Bimo',
        'nameAr': 'بيمو',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/6/69/Logo_bimo.png',
        'description':
            'Historical biscuit and chocolate manufacturer in Algeria.',
        'descriptionAr': 'مصنع تاريخي للبسكويت والشوكولاتة في الجزائر.',
        'website': 'https://bimo-dz.com',
        'location': 'Baba Ali, Algiers',
        'ratings': {'health': 2.8, 'quality': 3.8, 'taste': 4.2, 'price': 5.0},
      },
    ];

    final collection = _firestore.collection('companies');

    for (final data in companies) {
      final id = data['id'];
      // Convert map to object-like structure just for saving? No, firestore accepts Map.
      // But we need to remove 'id' from map if we use it as doc ID.
      // Actually, typically clean to verify structure.
      final docData = Map<String, dynamic>.from(data)..remove('id');

      await collection.doc(id).set(docData, SetOptions(merge: true));
      debugPrint('Seeded company: ${data['name']}');
    }
  }
}
