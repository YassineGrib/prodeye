import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../models/health_condition.dart';
import '../models/lifestyle.dart';
import '../models/diet_type.dart';
import 'profile_controller.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  // Step 1: Personal Info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;

  // Step 2: Health Conditions
  final Set<HealthCondition> _selectedConditions = {};

  // Step 3: Lifestyle & Diet
  Lifestyle _selectedLifestyle = Lifestyle.sedentary;
  DietType _selectedDietType = DietType.balanced;

  late AnimationController _successAnimController;
  late Animation<double> _successScaleAnim;

  static const _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successScaleAnim = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentPage++);
      if (_currentPage == _totalSteps - 1) {
        _successAnimController.forward();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _saveAndFinish() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .saveFullProfile(
            name: _nameController.text.isNotEmpty ? _nameController.text : null,
            age: int.tryParse(_ageController.text),
            gender: _selectedGender,
            height: double.tryParse(_heightController.text),
            weight: double.tryParse(_weightController.text),
            healthConditions: _selectedConditions.toList(),
            lifestyle: _selectedLifestyle,
            dietType: _selectedDietType,
          );

      // Move to success page
      _nextPage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error saving profile. Please try again.',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with progress ──
            if (_currentPage < _totalSteps - 1) ...[
              _buildTopBar(),
              _buildProgressBar(),
            ],

            // ── Pages ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoPage(),
                  _buildHealthConditionsPage(),
                  _buildLifestyleDietPage(),
                  _buildSuccessPage(),
                ],
              ),
            ),

            // ── Bottom Buttons ──
            if (_currentPage < _totalSteps - 1) _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // TOP BAR
  // ════════════════════════════════════════════════════
  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.personalInfo,
      l10n.healthConditions,
      l10n.lifestyleDiet,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_currentPage > 0)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
                onPressed: _previousPage,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              titles[_currentPage],
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Skip button
          TextButton(
            onPressed: () => context.goNamed('home'),
            child: Text(
              l10n.skip,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentPage;
          final isCurrent = index == _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: isCurrent ? 6 : 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // PAGE 1: PERSONAL INFO
  // ════════════════════════════════════════════════════
  Widget _buildPersonalInfoPage() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        // Header illustration
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tell us about yourself',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),

        // Name field
        _buildInputCard(
          icon: Icons.badge_outlined,
          child: TextFormField(
            controller: _nameController,
            style: GoogleFonts.tajawal(fontSize: 15),
            decoration: InputDecoration(
              labelText: l10n.name,
              labelStyle: GoogleFonts.tajawal(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Gender selector
        _buildSectionLabel(l10n.gender),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                icon: Icons.male_rounded,
                label: l10n.male,
                value: 'Male',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                icon: Icons.female_rounded,
                label: l10n.female,
                value: 'Female',
                color: Colors.pink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Age
        _buildInputCard(
          icon: Icons.cake_outlined,
          child: TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.tajawal(fontSize: 15),
            decoration: InputDecoration(
              labelText: l10n.age,
              labelStyle: GoogleFonts.tajawal(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              suffixText: 'years',
              suffixStyle: GoogleFonts.tajawal(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Height & Weight row
        Row(
          children: [
            Expanded(
              child: _buildInputCard(
                icon: Icons.straighten_outlined,
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.tajawal(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: l10n.height,
                    labelStyle: GoogleFonts.tajawal(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    suffixText: l10n.cm,
                    suffixStyle: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputCard(
                icon: Icons.monitor_weight_outlined,
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.tajawal(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: l10n.weight,
                    labelStyle: GoogleFonts.tajawal(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    suffixText: l10n.kg,
                    suffixStyle: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80), // Bottom padding for nav
      ],
    );
  }

  // ════════════════════════════════════════════════════
  // PAGE 2: HEALTH CONDITIONS
  // ════════════════════════════════════════════════════
  Widget _buildHealthConditionsPage() {
    final l10n = AppLocalizations.of(context)!;
    final conditions = HealthCondition.values
        .where((c) => c != HealthCondition.none)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.red.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectHealthConditions,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        // Chips grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: conditions.map((condition) {
            final isSelected = _selectedConditions.contains(condition);
            return _buildConditionChip(
              label: condition.localizedName(l10n),
              icon: _getConditionIcon(condition),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedConditions.remove(condition);
                  } else {
                    _selectedConditions.add(condition);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // None option
        _buildConditionChip(
          label: l10n.none,
          icon: Icons.check_circle_outline,
          isSelected: _selectedConditions.isEmpty,
          onTap: () => setState(() => _selectedConditions.clear()),
          color: AppColors.primary,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  // PAGE 3: LIFESTYLE & DIET
  // ════════════════════════════════════════════════════
  Widget _buildLifestyleDietPage() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 48,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose your lifestyle and diet preferences',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),

        // Lifestyle
        _buildSectionLabel(l10n.selectLifestyle),
        const SizedBox(height: 12),
        ...Lifestyle.values.map(
          (ls) => _buildOptionTile(
            icon: _getLifestyleIcon(ls),
            label: ls.localizedName(l10n),
            isSelected: _selectedLifestyle == ls,
            color: Colors.orange,
            onTap: () => setState(() => _selectedLifestyle = ls),
          ),
        ),

        const SizedBox(height: 24),

        // Diet
        _buildSectionLabel(l10n.selectDiet),
        const SizedBox(height: 12),
        ...DietType.values.map(
          (dt) => _buildOptionTile(
            icon: _getDietIcon(dt),
            label: dt.localizedName(l10n),
            isSelected: _selectedDietType == dt,
            color: AppColors.primary,
            onTap: () => setState(() => _selectedDietType = dt),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  // PAGE 4: SUCCESS
  // ════════════════════════════════════════════════════
  Widget _buildSuccessPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScaleAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'You\'re all set! 🎉',
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your profile has been saved. ProdEye will now personalize health scores based on your needs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => context.goNamed('home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Scanning',
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // BOTTOM BUTTONS
  // ════════════════════════════════════════════════════
  Widget _buildBottomButtons() {
    final isLastFormPage = _currentPage == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSaving
              ? null
              : (isLastFormPage ? _saveAndFinish : _nextPage),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastFormPage ? 'Save & Finish' : 'Continue',
                      style: GoogleFonts.tajawal(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastFormPage
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // REUSABLE WIDGETS
  // ════════════════════════════════════════════════════

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildInputCard({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = Colors.redAccent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : icon,
              size: 18,
              color: isSelected ? color : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.1)
                    : Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? color : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : Colors.grey.shade700,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // ICON HELPERS
  // ════════════════════════════════════════════════════

  IconData _getConditionIcon(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.diabetes:
        return Icons.bloodtype_outlined;
      case HealthCondition.highBloodPressure:
        return Icons.speed_outlined;
      case HealthCondition.heartDisease:
        return Icons.monitor_heart_outlined;
      case HealthCondition.kidneyDisease:
        return Icons.health_and_safety_outlined;
      case HealthCondition.lactoseIntolerance:
        return Icons.no_food_outlined;
      case HealthCondition.glutenIntolerance:
        return Icons.grain_outlined;
      case HealthCondition.nutAllergy:
        return Icons.warning_amber_rounded;
      case HealthCondition.shellfishAllergy:
        return Icons.set_meal_outlined;
      case HealthCondition.vegan:
        return Icons.eco_outlined;
      case HealthCondition.vegetarian:
        return Icons.grass_outlined;
      case HealthCondition.none:
        return Icons.check_circle_outline;
    }
  }

  IconData _getLifestyleIcon(Lifestyle lifestyle) {
    switch (lifestyle) {
      case Lifestyle.sedentary:
        return Icons.weekend_outlined;
      case Lifestyle.active:
        return Icons.directions_run_rounded;
      case Lifestyle.bodybuilder:
        return Icons.fitness_center_rounded;
      case Lifestyle.dieting:
        return Icons.scale_outlined;
    }
  }

  IconData _getDietIcon(DietType diet) {
    switch (diet) {
      case DietType.balanced:
        return Icons.balance_outlined;
      case DietType.vegetarian:
        return Icons.grass_outlined;
      case DietType.vegan:
        return Icons.eco_outlined;
      case DietType.keto:
        return Icons.local_fire_department_outlined;
      case DietType.paleo:
        return Icons.nature_outlined;
      case DietType.mediterranean:
        return Icons.water_outlined;
    }
  }
}
