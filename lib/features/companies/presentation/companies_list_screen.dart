import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/company_repository.dart';
import '../models/company.dart';
import '../../../../core/utils/company_seeder.dart';
import '../../product/data/seed_products.dart';

final companiesListProvider = FutureProvider<List<Company>>((ref) async {
  return ref.watch(companyRepositoryProvider).getAllCompanies();
});

final companySearchProvider = FutureProvider.family<List<Company>, String>((
  ref,
  query,
) async {
  return ref.watch(companyRepositoryProvider).searchCompanies(query);
});

class CompaniesListScreen extends ConsumerStatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  ConsumerState<CompaniesListScreen> createState() =>
      _CompaniesListScreenState();
}

class _CompaniesListScreenState extends ConsumerState<CompaniesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Decide which provider to watch
    final AsyncValue<List<Company>> companiesAsync = _searchQuery.isEmpty
        ? ref.watch(companiesListProvider)
        : ref.watch(companySearchProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          l10n.companies,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Companies List
          Expanded(
            child: companiesAsync.when(
              data: (companies) {
                if (companies.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noProductsFound, // Reusing existing string or add new one
                      style: GoogleFonts.tajawal(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return _CompanyCard(company: company);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  await _seedDatabase(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error seeding: $e')));
                }
              },
              child: const Icon(Icons.cloud_upload),
              tooltip: 'Seed Database (Dev)',
            )
          : null,
    );
  }

  Future<void> _seedDatabase(BuildContext context) async {
    // Seed companies
    final seeder = CompanySeeder();
    await seeder.seedCompanies();
    // Seed products
    await SeedProducts.seedAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Companies & Products seeded successfully!'),
        ),
      );
      // Refresh the list
      ref.invalidate(companiesListProvider);
    }
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'company-details',
          pathParameters: {'id': company.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: company.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        company.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.business, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.business, color: Colors.grey),
            ),
            const SizedBox(width: 16),

            // Name & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company
                        .name, // Accessing name directly, assumes localized helper or field usage
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (company.location != null)
                    Text(
                      company.location!,
                      style: GoogleFonts.tajawal(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
