import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanySeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedCompanies() async {
    final List<Map<String, dynamic>> companies = [
      // ──── Companies linked to seed products ────
      {
        'id': 'hamoud_boualem',
        'name': 'Hamoud Boualem',
        'nameAr': 'حمود بوعلام',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Hamoud_Boualem_logo.svg/1200px-Hamoud_Boualem_logo.svg.png',
        'description':
            'Iconic Algerian beverage brand founded in 1878. Famous for Selecto, the national soda, and a wide range of soft drinks cherished across generations.',
        'descriptionAr':
            'علامة تجارية جزائرية أيقونية في المشروبات تأسست عام 1878. مشهورة بـ«سيلكتو»، المشروب الغازي الوطني، ومجموعة واسعة من المشروبات الغازية المحبوبة عبر الأجيال.',
        'website': 'https://www.hamoud-boualem.com',
        'location': 'Belouizdad, Algiers',
        'email': 'contact@hamoud-boualem.com',
        'phone': '+213 21 67 22 33',
        'ratings': {'health': 2.5, 'quality': 4.5, 'taste': 4.8, 'price': 4.0},
      },
      {
        'id': 'ifri',
        'name': 'Ifri',
        'nameAr': 'إيفري',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Logo_Ifri.svg/1200px-Logo_Ifri.svg.png',
        'description':
            'Leading Algerian mineral water and soft drink producer from Kabylie. Known for natural purity and a diverse product line including sparkling water and fruit drinks.',
        'descriptionAr':
            'أبرز منتج جزائري للمياه المعدنية والمشروبات الغازية من منطقة القبائل. معروف بالنقاء الطبيعي وخط إنتاج متنوع يشمل المياه الغازية ومشروبات الفاكهة.',
        'website': 'https://www.ifri.dz',
        'location': 'Ighzer Amokrane, Bejaia',
        'email': 'contact@ifri.dz',
        'phone': '+213 34 20 15 00',
        'ratings': {'health': 4.8, 'quality': 4.7, 'taste': 4.0, 'price': 4.5},
      },
      {
        'id': 'ngaous',
        'name': 'N\'Gaous Conserves',
        'nameAr': 'نقاوس للمصبرات',
        'logoUrl': null,
        'description':
            'Historic Algerian fruit juice and conserve producer from Batna. Known for traditional 100% natural juices with no preservatives, a staple on Algerian tables since the 1960s.',
        'descriptionAr':
            'منتج جزائري تاريخي لعصائر الفاكهة والمصبرات من باتنة. معروف بالعصائر التقليدية الطبيعية 100% بدون مواد حافظة، حاضر على الموائد الجزائرية منذ الستينيات.',
        'website': null,
        'location': 'N\'Gaous, Batna',
        'email': 'info@ngaous-conserves.dz',
        'phone': '+213 33 86 50 00',
        'ratings': {'health': 3.8, 'quality': 4.2, 'taste': 4.6, 'price': 4.5},
      },
      {
        'id': 'bel_algerie',
        'name': 'Bel Algérie',
        'nameAr': 'بيل الجزائر',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Logo_Groupe_Bel.svg/1200px-Logo_Groupe_Bel.svg.png',
        'description':
            'Algerian subsidiary of Groupe Bel, producing the beloved La Vache Qui Rit processed cheese. A trusted name in Algerian households for decades.',
        'descriptionAr':
            'الفرع الجزائري لمجموعة بيل، ينتج جبنة البقرة الضاحكة المحبوبة. اسم موثوق في البيوت الجزائرية منذ عقود.',
        'website': 'https://www.bel-group.com',
        'location': 'Koléa, Tipaza',
        'email': 'contact@bel-algerie.com',
        'phone': '+213 24 38 40 00',
        'ratings': {'health': 3.0, 'quality': 4.5, 'taste': 4.5, 'price': 3.0},
      },
      {
        'id': 'amor_benamor',
        'name': 'Amor Benamor',
        'nameAr': 'عمر بن عمر',
        'logoUrl': null,
        'description':
            'Largest pasta, couscous, and tomato concentrate producer in Algeria. A household name for quality durum wheat pasta and traditional Algerian food staples.',
        'descriptionAr':
            'أكبر منتج للمعجنات والكسكس ومعجون الطماطم في الجزائر. اسم مألوف مرادف للجودة في المعكرونة وأساسيات المطبخ الجزائري التقليدي.',
        'website': 'https://www.benamor.com.dz',
        'location': 'Guelma, Algeria',
        'email': 'contact@benamor.com.dz',
        'phone': '+213 37 20 10 00',
        'ratings': {'health': 4.0, 'quality': 4.6, 'taste': 4.2, 'price': 4.8},
      },
      {
        'id': 'cevital',
        'name': 'Cevital',
        'nameAr': 'سيفيتال',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/thumb/5/52/Logo_Cevital.svg/1200px-Logo_Cevital.svg.png',
        'description':
            'Algeria\'s largest private conglomerate and leading agri-food company. Produces cooking oils, sugar, margarine, and mineral water under various well-known brands.',
        'descriptionAr':
            'أكبر مجمع خاص في الجزائر وشركة رائدة في الصناعات الغذائية. تنتج زيوت الطهي والسكر والسمن والمياه المعدنية تحت علامات تجارية معروفة.',
        'website': 'https://www.cevital.com',
        'location': 'Bejaia, Algeria',
        'email': 'info@cevital.com',
        'phone': '+213 34 21 50 00',
        'ratings': {'health': 3.5, 'quality': 4.5, 'taste': 4.0, 'price': 3.0},
      },
      {
        'id': 'biscuiterie_atlas',
        'name': 'Biscuiterie de l\'Atlas',
        'nameAr': 'بسكويت الأطلس',
        'logoUrl': null,
        'description':
            'Algerian biscuit and wafer manufacturer. Known for affordable, tasty chocolate wafers and cookies popular with families and children.',
        'descriptionAr':
            'مصنع جزائري للبسكويت والغوفريت. معروف بالغوفريت بالشوكولاتة اللذيذة وبسعر مناسب، محبوب لدى العائلات والأطفال.',
        'website': null,
        'location': 'Blida, Algeria',
        'email': 'contact@biscuiterie-atlas.dz',
        'phone': '+213 25 43 10 00',
        'ratings': {'health': 2.2, 'quality': 3.5, 'taste': 4.3, 'price': 5.0},
      },
      {
        'id': 'tchin_lait',
        'name': 'Tchin Lait (Candia)',
        'nameAr': 'تشين لاي (كانديا)',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/thumb/9/9d/Logo_Candia.svg/1200px-Logo_Candia.svg.png',
        'description':
            'Algerian dairy company operating under Candia license. Algeria\'s largest UHT milk producer, offering a full range of milk, flavored drinks, and dairy products.',
        'descriptionAr':
            'شركة ألبان جزائرية تعمل بترخيص كانديا. أكبر منتج للحليب المعقم في الجزائر، تقدم مجموعة كاملة من الحليب والمشروبات المنكهة ومنتجات الألبان.',
        'website': 'https://www.tchinlait.com',
        'location': 'Bejaia, Algeria',
        'email': 'info@tchinlait.com',
        'phone': '+213 34 20 20 00',
        'ratings': {'health': 4.3, 'quality': 4.4, 'taste': 4.2, 'price': 3.0},
      },

      // ──── Additional well-known Algerian brands ────
      {
        'id': 'rouiba',
        'name': 'Rouiba',
        'nameAr': 'رويبة',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/e/e9/Logo_Rouiba.png',
        'description':
            'Popular Algerian fruit juice brand offering a wide variety of flavors. Market leader in juices and nectars, exported across North Africa and the Middle East.',
        'descriptionAr':
            'علامة تجارية جزائرية مشهورة لعصائر الفاكهة تقدم نكهات متنوعة. رائدة السوق في العصائر والرحيق، تصدر إلى شمال أفريقيا والشرق الأوسط.',
        'website': 'https://rouiba.com',
        'location': 'Rouiba, Algiers',
        'email': 'contact@rouiba.com',
        'phone': '+213 21 85 10 00',
        'ratings': {'health': 3.0, 'quality': 4.0, 'taste': 4.8, 'price': 4.0},
      },
      {
        'id': 'soummam',
        'name': 'Soummam',
        'nameAr': 'صومام',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/fr/0/06/Logo_Soummam.png',
        'description':
            'One of Algeria\'s largest dairy producers, specializing in yogurt, lben, and cheese. Known for high-quality products at competitive prices.',
        'descriptionAr':
            'واحدة من أكبر منتجي الألبان في الجزائر، متخصصة في الزبادي واللبن والجبن. معروفة بمنتجات عالية الجودة بأسعار تنافسية.',
        'website': 'https://soummam.com',
        'location': 'Akbou, Bejaia',
        'email': 'contact@soummam.com',
        'phone': '+213 34 34 50 00',
        'ratings': {'health': 4.2, 'quality': 4.6, 'taste': 4.5, 'price': 3.5},
      },
      {
        'id': 'palmary',
        'name': 'Palmary',
        'nameAr': 'بالماري',
        'logoUrl':
            'https://palmary-food.com/wp-content/uploads/2020/06/logo-palmary-1.png',
        'description':
            'Known for biscuits, cakes, and other confectionery products. A family favorite for snack time across Algeria.',
        'descriptionAr':
            'معروفة بالبسكويت والكعك ومنتجات الحلويات الأخرى. خيار العائلات المفضل لوقت الوجبات الخفيفة في الجزائر.',
        'website': 'https://palmary-food.com',
        'location': 'Blida, Algeria',
        'email': 'info@palmary-food.com',
        'phone': '+213 25 43 20 00',
        'ratings': {'health': 2.5, 'quality': 4.0, 'taste': 4.5, 'price': 4.5},
      },
      {
        'id': 'bimo',
        'name': 'Bimo',
        'nameAr': 'بيمو',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/6/69/Logo_bimo.png',
        'description':
            'Historical biscuit and chocolate manufacturer in Algeria. Known for Choco Prince and other iconic treats loved since childhood.',
        'descriptionAr':
            'مصنع تاريخي للبسكويت والشوكولاتة في الجزائر. معروف بـ«شوكو برانس» وحلويات أيقونية أخرى محبوبة منذ الطفولة.',
        'website': 'https://bimo-dz.com',
        'location': 'Baba Ali, Algiers',
        'email': 'contact@bimo-dz.com',
        'phone': '+213 21 52 80 00',
        'ratings': {'health': 2.8, 'quality': 3.8, 'taste': 4.2, 'price': 5.0},
      },
    ];

    final collection = _firestore.collection('companies');

    for (final data in companies) {
      final id = data['id'];
      final docData = Map<String, dynamic>.from(data)..remove('id');

      await collection.doc(id).set(docData, SetOptions(merge: true));
      debugPrint('✅ Seeded company: ${data['name']}');
    }

    debugPrint('🎉 All ${companies.length} companies seeded successfully!');
  }
}
