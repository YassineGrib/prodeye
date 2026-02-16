import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/health_conditions_screen.dart';
import '../../features/profile/presentation/lifestyle_diet_screen.dart';
import '../../features/product/presentation/scan_result_screen.dart';
import '../../features/product/presentation/product_details_screen.dart';
import '../../features/product/presentation/product_not_found_screen.dart';
import '../../features/companies/presentation/company_details_screen.dart';
import '../../features/product/models/product.dart';
import '../../features/history/presentation/scan_history_screen.dart';
import '../../features/settings/presentation/help_support_screen.dart';
import '../../features/settings/presentation/terms_conditions_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
// Admin screens
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/admin/presentation/admin_products_screen.dart';
import '../../features/admin/presentation/admin_promos_screen.dart';
import '../../features/admin/presentation/admin_product_form_screen.dart';
import '../../features/admin/presentation/admin_companies_screen.dart';
import '../../features/admin/presentation/admin_company_form_screen.dart';
import '../../features/companies/models/company.dart';

// Keys for Navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  // TODO: Watch auth state here for redirect logic
  // final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/', // Start at splash
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/health',
        name: 'profile-health',
        builder: (context, state) => const HealthConditionsScreen(),
      ),
      GoRoute(
        path: '/profile/lifestyle',
        name: 'profile-lifestyle',
        builder: (context, state) => const LifestyleDietScreen(),
      ),
      // ── Product Routes ──
      GoRoute(
        path: '/scan-result/:barcode',
        name: 'scan-result',
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return ScanResultScreen(barcode: barcode);
        },
      ),
      GoRoute(
        path: '/product/:barcode',
        name: 'product-details',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/product-not-found/:barcode',
        name: 'product-not-found',
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return ProductNotFoundScreen(barcode: barcode);
        },
      ),
      GoRoute(
        path: '/scan-history',
        name: 'scan-history',
        builder: (context, state) => const ScanHistoryScreen(),
      ),
      GoRoute(
        path: '/company/:id',
        name: 'company-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CompanyDetailsScreen(companyId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/settings/terms',
        name: 'terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // ── Admin Routes ──
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        name: 'admin-products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/form',
        name: 'admin-product-form',
        builder: (context, state) {
          final product = state.extra as Product?;
          return AdminProductFormScreen(product: product);
        },
      ),
      GoRoute(
        path: '/admin/companies',
        name: 'admin-companies',
        builder: (context, state) => const AdminCompaniesScreen(),
      ),
      GoRoute(
        path: '/admin/companies/form',
        name: 'admin-company-form',
        builder: (context, state) {
          final company = state.extra as Company?;
          return AdminCompanyFormScreen(company: company);
        },
      ),
      GoRoute(
        path: '/admin/promos',
        name: 'admin-promos',
        builder: (context, state) => const AdminPromosScreen(),
      ),
    ],
  );
});
