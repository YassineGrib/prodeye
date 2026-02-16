import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../product/data/product_repository.dart';
import '../../companies/data/company_repository.dart';
import '../data/admin_repository.dart';

// ── Providers for stats ──
final adminProductCountProvider = FutureProvider<int>((ref) {
  return ref.watch(productRepositoryProvider).getProductCount();
});
final adminCompanyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(companyRepositoryProvider).getCompanyCount();
});
final adminUserCountProvider = FutureProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).getUserCount();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productCount = ref.watch(adminProductCountProvider);
    final companyCount = ref.watch(adminCompanyCountProvider);
    final userCount = ref.watch(adminUserCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Compact Hero Header (same style as client) ──
            SliverToBoxAdapter(child: _HeroHeader()),

            // ── 2. Stats Row (compact, like quick actions) ──
            SliverToBoxAdapter(
              child: _StatsRow(
                userCount: userCount,
                productCount: productCount,
                companyCount: companyCount,
              ),
            ),

            // ── 3. Management Section ──
            SliverToBoxAdapter(
              child: _SectionTitle(
                icon: Icons.dashboard_customize_rounded,
                iconColor: AppColors.primary,
                title: 'الإدارة',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ManageCard(
                      icon: Icons.people_rounded,
                      title: 'المستخدمين',
                      subtitle: 'عرض حسابات المستخدمين',
                      color: AppColors.info,
                      onTap: () => context.pushNamed('admin-users'),
                    ),
                    const SizedBox(height: 8),
                    _ManageCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'المنتجات',
                      subtitle: 'إضافة وتعديل وحذف المنتجات',
                      color: AppColors.primary,
                      onTap: () => context.pushNamed('admin-products'),
                    ),
                    const SizedBox(height: 8),
                    _ManageCard(
                      icon: Icons.business_rounded,
                      title: 'الشركات',
                      subtitle: 'إضافة وتعديل وحذف الشركات',
                      color: AppColors.secondary,
                      onTap: () => context.pushNamed('admin-companies'),
                    ),
                    const SizedBox(height: 8),
                    _ManageCard(
                      icon: Icons.campaign_rounded,
                      title: 'الإعلانات',
                      subtitle: 'إدارة مساحة العروض (Pub Zone)',
                      color: Colors.purple,
                      onTap: () => context.pushNamed('admin-promos'),
                    ),
                  ],
                ),
              ),
            ),

            // ── 4. Quick Actions ──
            SliverToBoxAdapter(
              child: _SectionTitle(
                icon: Icons.flash_on_rounded,
                iconColor: AppColors.secondary,
                title: 'إجراءات سريعة',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionChip(
                        icon: Icons.add_box_rounded,
                        label: 'منتج جديد',
                        color: AppColors.primary,
                        onTap: () => context.pushNamed('admin-product-form'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionChip(
                        icon: Icons.add_business_rounded,
                        label: 'شركة جديدة',
                        color: AppColors.secondary,
                        onTap: () => context.pushNamed('admin-company-form'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 1. Compact Hero Header (matches client home_tab style) ──
class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          child: Row(
            children: [
              // Admin icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'لوحة التحكم 🛡️',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'إدارة ProdEye',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Logout
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.goNamed('login');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 2. Stats Card (single unified card) ──
class _StatsRow extends StatelessWidget {
  final AsyncValue<int> userCount;
  final AsyncValue<int> productCount;
  final AsyncValue<int> companyCount;

  const _StatsRow({
    required this.userCount,
    required this.productCount,
    required this.companyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _StatColumn(
                  icon: Icons.people_rounded,
                  label: 'المستخدمين',
                  value: userCount,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _StatColumn(
                  icon: Icons.inventory_2_rounded,
                  label: 'المنتجات',
                  value: productCount,
                  color: const Color(0xFF059669),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _StatColumn(
                  icon: Icons.business_rounded,
                  label: 'الشركات',
                  value: companyCount,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final AsyncValue<int> value;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        value.when(
          data: (v) => Text(
            v.toString(),
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          loading: () => SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          error: (_, __) => Text(
            '—',
            style: GoogleFonts.tajawal(fontSize: 18, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

// ── Section Title (matches client style) ──
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Manage Card (compact row card) ──
class _ManageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Action Chip (compact, matches client style) ──
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
