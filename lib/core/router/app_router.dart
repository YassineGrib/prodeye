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
import '../../features/product/models/product.dart';

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
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile Setup TODO'))),
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
    ],
  );
});
