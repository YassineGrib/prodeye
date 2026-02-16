import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../promotions/data/promo_repository.dart';
import '../../promotions/models/promo_ad.dart';

class AdminPromosScreen extends ConsumerWidget {
  const AdminPromosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(allPromosProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            'إدارة الإعلانات',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to form to add new promo
            // For now, we'll just show a snackbar or seed if empty
          },
          backgroundColor: Colors.purple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'إضافة إعلان',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: promosAsync.when(
          data: (promos) {
            if (promos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إعلانات حالياً',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _seedPromos(ref);
                      },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        'إضافة إعلانات تجريبية',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final promo = promos[index];
                return _PromoListItem(
                  promo: promo,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'حذف الإعلان',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'هل أنت متأكد من حذف "${promo.title}"؟',
                          style: GoogleFonts.tajawal(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('إلغاء', style: GoogleFonts.tajawal()),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'حذف',
                              style: GoogleFonts.tajawal(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(promoRepositoryProvider)
                          .deletePromo(promo.id);
                      ref.invalidate(allPromosProvider);
                    }
                  },
                  onToggleActive: () async {
                    await ref.read(promoRepositoryProvider).updatePromo(
                      promo.id,
                      {'isActive': !promo.isActive},
                    );
                    ref.invalidate(allPromosProvider);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  Future<void> _seedPromos(WidgetRef ref) async {
    final repo = ref.read(promoRepositoryProvider);
    final promos = [
      PromoAd(
        id: '', // Firestore will assign ID
        title: 'مياه إيفري – نقاء الطبيعة',
        subtitle: 'اكتشف المصدر الأنقى للمياه المعدنية',
        companyName: 'Ifri',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/e0/Ifri_Logo.png', // Placeholder URL
        order: 1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      PromoAd(
        id: '',
        title: 'حمود بوعلام – طعم الأصالة',
        subtitle: 'المشروب الجزائري الأصيل منذ 1878',
        companyName: 'Hamoud Boualem',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Hamoud_Boualem_Logo.svg/1200px-Hamoud_Boualem_Logo.svg.png',
        order: 2,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      PromoAd(
        id: '',
        title: 'عمر بن عمر – جودة بلا حدود',
        subtitle: 'أفضل منتجات غذائية جزائرية',
        companyName: 'Amor Benamor',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Logo_Amor_Benamor.svg/2560px-Logo_Amor_Benamor.svg.png',
        order: 3,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (final promo in promos) {
      await repo.addPromo(promo);
    }
    ref.invalidate(allPromosProvider);
  }
}

class _PromoListItem extends StatelessWidget {
  final PromoAd promo;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _PromoListItem({
    required this.promo,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon/Image Placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_rounded, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  promo.subtitle ?? 'لا يوجد وصف',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      promo.companyName ?? '--',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status switch
          Switch(
            value: promo.isActive,
            onChanged: (_) => onToggleActive(),
            activeColor: Colors.purple,
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
