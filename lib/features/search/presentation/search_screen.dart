import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';
import '../../companies/data/company_repository.dart';
import '../../companies/models/company.dart';

// Providers for search results
final productSearchProvider = FutureProvider.family<List<Product>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.read(productRepositoryProvider);
  // Search by name
  final byName = await repo.searchProducts(query);
  return byName;
  // TODO: Merge with byNameAr if needed
});

final companySearchProvider = FutureProvider.family<List<Company>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.read(companyRepositoryProvider);
  return repo.searchCompanies(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {
      _query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
          ),
          style: GoogleFonts.tajawal(color: Colors.black87),
          textInputAction: TextInputAction.search,
          onChanged: _onSearch,
          onSubmitted: _onSearch,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _onSearch('');
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: l10n.scanProduct), // Using "Products" proxy
            Tab(text: l10n.companies),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductSearchResults(query: _query, l10n: l10n),
          _CompanySearchResults(query: _query, l10n: l10n),
        ],
      ),
    );
  }
}

class _ProductSearchResults extends ConsumerWidget {
  final String query;
  final AppLocalizations l10n;

  const _ProductSearchResults({required this.query, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.searchProduct,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final searchAsync = ref.watch(productSearchProvider(query));

    return searchAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(child: Text(l10n.productNotFound));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                context.pushNamed(
                  'product-details',
                  pathParameters: {'barcode': product.barcode},
                  extra: product,
                );
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.grey.shade300,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _CompanySearchResults extends ConsumerWidget {
  final String query;
  final AppLocalizations l10n;

  const _CompanySearchResults({required this.query, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.searchHint,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final searchAsync = ref.watch(companySearchProvider(query));

    return searchAsync.when(
      data: (companies) {
        if (companies.isEmpty) {
          return Center(child: Text(l10n.noProductsFound)); // Reusing string
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: companies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final company = companies[index];
            return GestureDetector(
              onTap: () {
                context.pushNamed(
                  'company-details',
                  pathParameters: {'id': company.id},
                );
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: company.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                company.logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.business,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            )
                          : Icon(Icons.business, color: Colors.grey.shade300),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.localizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (company.location != null)
                            Text(
                              company.location!,
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
