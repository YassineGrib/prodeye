import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
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
            return Center(
              child: Text(l10n.productNotFound), // Fallback or new string
            );
          }

          final locale = Localizations.localeOf(context).languageCode;
          final name = company.localizedName(locale);
          final description = company.localizedDescription(locale);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Banner / Background
                      Container(
                        color: Colors.grey.shade100,
                        child: company.logoUrl != null
                            ? Image.network(
                                company.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.business,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.business,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  isFavoriteAsync.when(
                    data: (isFavorite) => IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        final repo = ref.read(favoritesRepositoryProvider);
                        if (isFavorite) {
                          await repo.removeFromFavorites(companyId);
                        } else if (companyAsync.value != null) {
                          final company = companyAsync.value!;
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

              // Company Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Website
                      // Location & Website
                      if (company.location != null || company.website != null)
                        Row(
                          children: [
                            if (company.location != null) ...[
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company.location!,
                                style: GoogleFonts.tajawal(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (company.website != null)
                              InkWell(
                                onTap: () => _launchUrl(company.website!),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.visitWebsite,
                                      style: GoogleFonts.tajawal(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        l10n.aboutCompany,
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ratings
                      if (company.ratings.isNotEmpty) ...[
                        Text(
                          l10n.ratings,
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailedRatingsCard(
                          l10n: l10n,
                          ratings: company.ratings,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Products Header
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
              ),

              // Products Grid
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(l10n.noProductsFound),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return _CompanyProductCard(product: product);
                      }, childCount: products.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading company: $e')),
      ),
    );
  }

  void _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _DetailedRatingsCard extends StatelessWidget {
  final Map<String, double> ratings;
  final AppLocalizations l10n;

  const _DetailedRatingsCard({required this.ratings, required this.l10n});

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
        children: ratings.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _RatingRow(
              label: _getLabel(e.key),
              rating: e.value,
              color: _getRatingColor(e.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(String key) {
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

  Color _getRatingColor(String key) {
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
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rating / 5.0,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 30,
          alignment: Alignment.center,
          child: Text(
            rating.toString(),
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    top: Radius.circular(12),
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Icon(Icons.qr_code_2, size: 40, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                  Row(
                    children: [
                      // Simple Health Score Indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getScoreColor(
                            80,
                          ), // Mock score since we don't have user context easily here
                        ),
                      ),
                      const SizedBox(width: 4),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF059669);
    if (score >= 50) return const Color(0xFFD97706);
    return const Color(0xFFEF4444);
  }
}
