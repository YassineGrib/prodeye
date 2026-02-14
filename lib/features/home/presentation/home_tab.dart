import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../profile/data/profile_repository.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Compact Welcome Hero ──
          SliverToBoxAdapter(
            child: _WelcomeHero(
              l10n: l10n,
              userName: userAsync.whenOrNull(data: (profile) => profile?.name),
              userGender: userAsync.whenOrNull(
                data: (profile) => profile?.gender,
              ),
            ),
          ),

          // ── 2. Search Bar (separate section) ──
          SliverToBoxAdapter(child: _SearchBarSection(l10n: l10n)),

          // ── 3. Quick Actions Row (compact icons) ──
          SliverToBoxAdapter(child: _QuickActionsRow(l10n: l10n)),

          // ── 4. Complete Profile Banner (conditional) ──
          SliverToBoxAdapter(
            child:
                userAsync.whenOrNull(
                  data: (profile) {
                    if (profile == null ||
                        profile.height == null ||
                        profile.weight == null ||
                        profile.age == null) {
                      return _CompleteProfileBanner(l10n: l10n);
                    }
                    return const SizedBox.shrink();
                  },
                ) ??
                const SizedBox.shrink(),
          ),

          // ── 5. Daily Insight Card (compact) ──
          SliverToBoxAdapter(child: _DailyInsightCard(l10n: l10n)),

          // ── 6. Health Tips (compact) ──
          SliverToBoxAdapter(child: _HealthTipsSection(l10n: l10n)),

          // ── 7. Popular Products ──
          SliverToBoxAdapter(child: _PopularProductsSection(l10n: l10n)),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 1. Compact Welcome Hero (no app name/logo, avatar at top)
// ─────────────────────────────────────────────────
class _WelcomeHero extends StatelessWidget {
  final AppLocalizations l10n;
  final String? userName;
  final String? userGender;

  const _WelcomeHero({required this.l10n, this.userName, this.userGender});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 18) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: ClipOval(
                  child: Image.asset(
                    userGender == 'Female'
                        ? 'assets/img/girl.png'
                        : 'assets/img/man.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_getGreeting()} 👋',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      userName ?? l10n.welcomeBack,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Notification icon (plain, no decoration)
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {},
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

// ─────────────────────────────────────────────────
// 2. Search Bar (separate section with QR icon)
// ─────────────────────────────────────────────────
class _SearchBarSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _SearchBarSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.06),
          //     blurRadius: 10,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Container(width: 1, height: 24, color: Colors.grey.shade200),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/scan'),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 3. Quick Actions (single row, small icon cards)
// ─────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _QuickActionsRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAction(
        Icons.qr_code_scanner_rounded,
        l10n.scanProduct,
        const Color(0xFF059669),
        () => context.push('/scan'),
      ),
      _QAction(
        Icons.search_rounded,
        l10n.searchProduct,
        const Color(0xFF3B82F6),
        () {},
      ),
      _QAction(
        Icons.favorite_rounded,
        l10n.myFavorites,
        const Color(0xFFEF4444),
        () {},
      ),
      _QAction(
        Icons.history_rounded,
        l10n.scanHistory,
        const Color(0xFFD97706),
        () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: a.onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(a.icon, color: a.color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QAction(this.icon, this.label, this.color, this.onTap);
}

// ─────────────────────────────────────────────────
// Section Header (with icon)
// ─────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onViewAll;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 4. Complete Profile Banner
// ─────────────────────────────────────────────────
class _CompleteProfileBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _CompleteProfileBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.amber.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.completeProfile,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  Text(
                    l10n.completeProfileDesc,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.amber.shade600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 5. Daily Insight Card (compact)
// ─────────────────────────────────────────────────
class _DailyInsightCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _DailyInsightCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Colors.amber,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.dailyInsight} 💡',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade300,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.insightText,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 6. Health Tips (compact horizontal cards)
// ─────────────────────────────────────────────────
class _HealthTipsSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _HealthTipsSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final tips = [
      _TipData(
        Icons.label_important_rounded,
        l10n.tip1Title,
        l10n.tip1Desc,
        const Color(0xFF059669),
        const Color(0xFFD1FAE5),
      ),
      _TipData(
        Icons.no_food_rounded,
        l10n.tip2Title,
        l10n.tip2Desc,
        const Color(0xFFEF4444),
        const Color(0xFFFEE2E2),
      ),
      _TipData(
        Icons.water_drop_rounded,
        l10n.tip3Title,
        l10n.tip3Desc,
        const Color(0xFF3B82F6),
        const Color(0xFFDBEAFE),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.tips_and_updates_rounded,
          iconColor: const Color(0xFFD97706),
          title: l10n.healthTips,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips.map((tip) {
              return Container(
                width: 200,
                margin: const EdgeInsetsDirectional.only(end: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tip.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(tip.icon, color: tip.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tip.title,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tip.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.desc,
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TipData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final Color bgColor;
  const _TipData(this.icon, this.title, this.desc, this.color, this.bgColor);
}

// ─────────────────────────────────────────────────
// 7. Popular Products
// ─────────────────────────────────────────────────
class _PopularProductsSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _PopularProductsSection({required this.l10n});

  static const _products = [
    _PopularProduct(
      'مياه إيفري',
      'Ifri',
      95,
      Icons.water_drop_rounded,
      Color(0xFF3B82F6),
    ),
    _PopularProduct(
      'حمود بوعلام',
      'Hamoud Boualem',
      52,
      Icons.local_drink_rounded,
      Color(0xFFD97706),
    ),
    _PopularProduct(
      'سباغيتي عمر بن عمر',
      'Amor Benamor',
      78,
      Icons.restaurant_rounded,
      Color(0xFF059669),
    ),
    _PopularProduct(
      'البقرة الضاحكة',
      'Bel Algérie',
      42,
      Icons.egg_rounded,
      Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.primary,
          title: l10n.popularProducts,
          onViewAll: () {},
        ),
        ...List.generate(_products.length, (index) {
          final p = _products[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(p.icon, color: p.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          p.brand,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _scoreColor(p.score).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${p.score}',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(p.score),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade300,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _PopularProduct {
  final String name;
  final String brand;
  final int score;
  final IconData icon;
  final Color color;
  const _PopularProduct(
    this.name,
    this.brand,
    this.score,
    this.icon,
    this.color,
  );
}
