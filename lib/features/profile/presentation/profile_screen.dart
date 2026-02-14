import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_repository.dart';
import '../models/health_condition.dart';
import '../models/lifestyle.dart';
import '../models/diet_type.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.profileSetup, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(profileRepositoryProvider);
                      await repo.createProfileIfNew();
                      ref.refresh(userProfileProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(l10n.createAccount),
                  ),
                ],
              ),
            );
          }

          // Compute lifestyle & diet labels
          final lifestyleLabel = profile.lifestyle.localizedName(l10n);
          final dietLabel = profile.dietType.localizedName(l10n);
          final healthLabels = profile.healthConditions
              .map((c) => c.localizedName(l10n))
              .toList();

          return Column(
            children: [
              // ── Fixed Top Profile Header ──
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top bar: Back | "My Profile" | Settings
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                l10n.profile,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings_outlined,
                                size: 24,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                // Navigate to settings
                              },
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                      ),

                      const SizedBox(height: 16),

                      // Profile row: Avatar | Name + Email + Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: const Color(0xFFF0F0F0),
                                    backgroundImage: AssetImage(
                                      profile.gender == 'Female'
                                          ? 'assets/img/girl.png'
                                          : 'assets/img/man.png',
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 16),

                            // Name, Email & Edit Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name ?? l10n.name,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.email,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => context.push('/profile/edit'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.editProfile,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable Content ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // ── Subscription Card ──
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Subscription icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الاشتراك الحالي',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'مجاني (مفتوح)',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              'ترقية',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Stats Row ──
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.qr_code_scanner_rounded,
                          value: '0',
                          label: 'عمليات المسح',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.cake_outlined,
                          value: profile.age != null ? '${profile.age}' : '--',
                          label: l10n.age,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.monitor_weight_outlined,
                          value: profile.weight != null
                              ? '${profile.weight!.toStringAsFixed(0)}'
                              : '--',
                          label: l10n.weight,
                          color: Colors.teal,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Quick Info Cards ──
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      label: l10n.gender,
                      value: profile.gender == 'Male'
                          ? l10n.male
                          : profile.gender == 'Female'
                          ? l10n.female
                          : '--',
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.straighten_rounded,
                      label: l10n.height,
                      value: profile.height != null
                          ? '${profile.height!.toStringAsFixed(0)} ${l10n.cm}'
                          : '--',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.directions_run_rounded,
                      label: l10n.lifestyleDiet,
                      value: '$lifestyleLabel · $dietLabel',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.favorite_border_rounded,
                      label: l10n.healthConditions,
                      value: healthLabels.isNotEmpty
                          ? healthLabels.join('، ')
                          : l10n.none,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 24),

                    // ── Menu Section ──
                    _buildSectionTitle('الإعدادات والدعم'),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      context,
                      items: [
                        _MenuItem(
                          icon: Icons.language_rounded,
                          title: l10n.language,
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          title: l10n.notifications,
                          color: Colors.amber,
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          title: l10n.helpSupport,
                          color: Colors.teal,
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          title: l10n.termsConditions,
                          color: Colors.grey,
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.shield_outlined,
                          title: l10n.privacyPolicy,
                          color: Colors.indigo,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Logout Button ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) context.go('/login');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.logout,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ: $err',
                style: GoogleFonts.tajawal(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: Text('إعادة المحاولة', style: GoogleFonts.tajawal()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat Card Widget ──
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Card Widget ──
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ── Menu Card ──
  Widget _buildMenuCard(
    BuildContext context, {
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(
                  item.title,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  indent: 65,
                  endIndent: 18,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });
}
