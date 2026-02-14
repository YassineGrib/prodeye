import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Ensure correct import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  // App Name Animations
  late Animation<double> _nameFadeAnimation;
  late Animation<Offset> _nameSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Total animation duration
    );

    // 1. Logo Animation (0.0 -> 0.6)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // 2. Name Animation (0.4 -> 1.0) - Staggered
    _nameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _nameSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.5), // Start slightly below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    // Navigate to Login after delay + buffer
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.goNamed('login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: SvgPicture.asset(
                  'assets/logo/logo.svg',
                  height: 120, // Keep consistent size
                  width: 120,
                  placeholderBuilder: (BuildContext context) => const SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Animated App Name (SVG)
            FadeTransition(
              opacity: _nameFadeAnimation,
              child: SlideTransition(
                position: _nameSlideAnimation,
                child: SvgPicture.asset(
                  'assets/logo/appname.svg',
                  height: 40, // Adjust height as needed for text balance
                  // width: 150, // Let width auto-scale or set if needed
                  // colorFilter: const ColorFilter.mode(
                  //   AppColors.primary,
                  //   BlendMode.srcIn,
                  // ), // Tint with brand color if the SVG is monochrome
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
