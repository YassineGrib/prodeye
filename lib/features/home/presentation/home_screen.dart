import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../companies/presentation/companies_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Tabs for the main content
  final List<Widget> _tabs = [
    const HomeTab(),
    const CompaniesListScreen(),
    const SizedBox(), // Placeholder for Scan (handled by separate action)
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Current content
    final currentTab = _currentIndex == 2
        ? const SizedBox()
        : _tabs[_currentIndex];

    return Scaffold(
      extendBody: true, // Important for floating nav bar
      body: Stack(
        children: [
          // Main Body
          Positioned.fill(child: currentTab),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  context.push('/scan');
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.business_outlined, // Companies
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: Icons.qr_code_scanner_rounded, // Scan
            isSelected: false, // Scan is always an action, not a state
            isHighlight:
                true, // Special styling for scan if desired, or standard
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: Icons.person_outline_rounded, // Profile
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHighlight;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFC107)
              : Colors.transparent, // Yellow color from the image reference
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}
