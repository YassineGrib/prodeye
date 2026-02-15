import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../data/favorites_repository.dart';
import '../models/favorite_item.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(favoritesStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            l10n.favorites,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(
                text: l10n.scanProduct,
              ), // Using "Scan Product" as proxy for "Products" for now
              const Tab(text: 'Companies'), // TODO: Add to l10n
            ],
          ),
        ),
        body: favoritesAsync.when(
          data: (favorites) {
            final products = favorites
                .where((i) => i.type == FavoriteType.product)
                .toList();
            final companies = favorites
                .where((i) => i.type == FavoriteType.company)
                .toList();

            return TabBarView(
              children: [
                _FavoritesList(items: products, l10n: l10n, isProduct: true),
                _FavoritesList(items: companies, l10n: l10n, isProduct: false),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<FavoriteItem> items;
  final AppLocalizations l10n;
  final bool isProduct;

  const _FavoritesList({
    required this.items,
    required this.l10n,
    required this.isProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isProduct
                  ? Icons.favorite_border_rounded
                  : Icons.business_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noHistory, // Fallback
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _FavoriteItemCard(item: items[index]);
      },
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;

  const _FavoriteItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.type == FavoriteType.product && item.barcode != null) {
          context.pushNamed(
            'scan-result',
            pathParameters: {'barcode': item.barcode!},
          );
        } else if (item.type == FavoriteType.company) {
          context.pushNamed('company-details', pathParameters: {'id': item.id});
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          item.type == FavoriteType.product
                              ? Icons.inventory_2_outlined
                              : Icons.business,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    )
                  : Icon(
                      item.type == FavoriteType.product
                          ? Icons.inventory_2_outlined
                          : Icons.business,
                      color: Colors.grey.shade300,
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
