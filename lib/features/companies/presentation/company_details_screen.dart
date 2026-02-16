import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../data/company_repository.dart';
import '../models/company.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../favorites/models/favorite_item.dart';

final companyProvider = FutureProvider.family<Company?, String>((ref, id) {
  return ref.watch(companyRepositoryProvider).getCompanyById(id);
});

final companyProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  companyId,
) {
  return ref.watch(productRepositoryProvider).getProductsByCompany(companyId);
});

class CompanyDetailsScreen extends ConsumerWidget {
  final String companyId;

  const CompanyDetailsScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companyAsync = ref.watch(companyProvider(companyId));
    final productsAsync = ref.watch(companyProductsProvider(companyId));
    final isFavoriteAsync = ref.watch(isFavoriteProvider(companyId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: companyAsync.when(
        data: (company) {
          if (company == null) {
            return Center(child: Text(l10n.productNotFound));
          }

          final locale = Localizations.localeOf(context).languageCode;
          final name = company.localizedName(locale);
          final description = company.localizedDescription(locale);

          return Column(
            children: [
              // ═══════════════════════════════════════
              // FIXED TOP HEADER — Profile card style
              // ═══════════════════════════════════════
              _CompanyHeader(
                company: company,
                name: name,
                isFavoriteAsync: isFavoriteAsync,
                companyAsync: companyAsync,
                ref: ref,
                l10n: l10n,
              ),

              // ═══════════════════════════════════════
              // SCROLLABLE CONTENT BELOW
              // ═══════════════════════════════════════
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  children: [
                    // ── About Section ──
                    _SectionCard(
                      icon: Icons.info_outline_rounded,
                      title: l10n.aboutCompany,
                      child: Text(
                        description,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Ratings Section ──
                    if (company.ratings.isNotEmpty) ...[
                      _SectionCard(
                        icon: Icons.star_outline_rounded,
                        title: l10n.ratings,
                        child: Column(
                          children: company.ratings.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RatingRow(
                                label: _getLabel(e.key, l10n),
                                rating: e.value,
                                color: _getRatingColor(e.key),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Products Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.companyProducts,
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.noProductsFound,
                                    style: GoogleFonts.tajawal(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _CompanyProductCard(
                              product: products[index],
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading company: $e')),
      ),
    );
  }

  static String _getLabel(String key, AppLocalizations l10n) {
    switch (key.toLowerCase()) {
      case 'health':
        return l10n.ratingHealth;
      case 'taste':
        return l10n.ratingTaste;
      case 'quality':
        return l10n.ratingQuality;
      case 'price':
        return l10n.ratingPrice;
      default:
        return key.toUpperCase();
    }
  }

  static Color _getRatingColor(String key) {
    switch (key.toLowerCase()) {
      case 'health':
        return Colors.green;
      case 'taste':
        return Colors.orange;
      case 'quality':
        return Colors.blue;
      case 'price':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// ══════════════════════════════════════════════════════
// FIXED TOP HEADER — Company profile card
// ══════════════════════════════════════════════════════
class _CompanyHeader extends StatelessWidget {
  final Company company;
  final String name;
  final AsyncValue<bool> isFavoriteAsync;
  final AsyncValue<Company?> companyAsync;
  final WidgetRef ref;
  final AppLocalizations l10n;

  const _CompanyHeader({
    required this.company,
    required this.name,
    required this.isFavoriteAsync,
    required this.companyAsync,
    required this.ref,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar with back + favorite ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  isFavoriteAsync.when(
                    data: (isFav) => IconButton(
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                      onPressed: () async {
                        final repo = ref.read(favoritesRepositoryProvider);
                        if (isFav) {
                          await repo.removeFromFavorites(company.id);
                        } else {
                          await repo.addToFavorites(
                            FavoriteItem(
                              id: company.id,
                              type: FavoriteType.company,
                              name: company.localizedName(
                                Localizations.localeOf(context).languageCode,
                              ),
                              subtitle: company.location,
                              imageUrl: company.logoUrl,
                              addedAt: DateTime.now(),
                            ),
                          );
                        }
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Avatar + Name + Rating ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  // Logo avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: company.logoUrl != null
                          ? Image.network(
                              company.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: GoogleFonts.tajawal(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name + rating badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.tajawal(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (company.ratings.isNotEmpty)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _overallRatingColor(
                                    company.overallRating,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: _overallRatingColor(
                                        company.overallRating,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      company.overallRating.toStringAsFixed(1),
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _overallRatingColor(
                                          company.overallRating,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${company.ratings.length} categories',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Contact info row ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  if (company.location != null)
                    Expanded(
                      child: _ContactItem(
                        icon: Icons.location_on_outlined,
                        label: company.location!,
                        color: Colors.blue,
                        onTap: null,
                      ),
                    ),
                  if (company.phone != null) ...[
                    _ContactIconButton(
                      icon: Icons.phone_outlined,
                      color: Colors.green,
                      onTap: () => _launchUrl('tel:${company.phone}'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (company.email != null)
                    _ContactIconButton(
                      icon: Icons.email_outlined,
                      color: Colors.orange,
                      onTap: () => _launchUrl('mailto:${company.email}'),
                    ),
                  if (company.website != null) ...[
                    const SizedBox(width: 8),
                    _ContactIconButton(
                      icon: Icons.language_rounded,
                      color: AppColors.primary,
                      onTap: () => _launchUrl(company.website!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _overallRatingColor(double rating) {
    if (rating >= 4.0) return const Color(0xFF059669);
    if (rating >= 3.0) return const Color(0xFFD97706);
    return const Color(0xFFEF4444);
  }
}

// ══════════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════════

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final double rating;
  final Color color;

  const _RatingRow({
    required this.label,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rating / 5.0,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
      ],
    );
  }
}

class _CompanyProductCard extends StatelessWidget {
  final Product product;

  const _CompanyProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'product-details',
          pathParameters: {'barcode': product.barcode},
          extra: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
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
