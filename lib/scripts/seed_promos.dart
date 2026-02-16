// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

/// Run this to seed sample promo ads into Firestore.
/// Execute via: flutter run -t lib/scripts/seed_promos.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('promos');

  final promos = [
    {
      'title': 'مياه إيفري – نقاء الطبيعة',
      'subtitle': 'اكتشف المصدر الأنقى للمياه المعدنية',
      'companyName': 'Ifri',
      'imageUrl': '',
      'targetProductBarcode': '',
      'order': 1,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'حمود بوعلام – طعم الأصالة',
      'subtitle': 'المشروب الجزائري الأصيل منذ 1878',
      'companyName': 'Hamoud Boualem',
      'imageUrl': '',
      'targetProductBarcode': '',
      'order': 2,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'عمر بن عمر – جودة بلا حدود',
      'subtitle': 'أفضل منتجات غذائية جزائرية',
      'companyName': 'Amor Benamor',
      'imageUrl': '',
      'targetProductBarcode': '',
      'order': 3,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  for (final promo in promos) {
    await collection.add(promo);
    print('✅ Added: ${promo['title']}');
  }

  print('\n🎉 Done! ${promos.length} promo ads seeded.');
  // Exit cleanly — in a real app, call this from admin dashboard instead
}
