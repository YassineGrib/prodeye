import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_repository.dart';
import '../models/health_condition.dart';
import '../models/lifestyle.dart';
import '../models/diet_type.dart';
import 'profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  Lifestyle? _selectedLifestyle;
  DietType? _selectedDietType;
  List<HealthCondition> _selectedHealthConditions = [];
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: userProfileAsync.when(
        data: (profile) {
          if (!_isInitialized && profile != null) {
            _nameController.text = profile.name ?? '';
            _ageController.text = profile.age?.toString() ?? '';
            _heightController.text = profile.height?.toString() ?? '';
            _weightController.text = profile.weight?.toString() ?? '';
            _selectedGender = profile.gender;
            _selectedLifestyle = profile.lifestyle;
            _selectedDietType = profile.dietType;
            _selectedHealthConditions = List.from(profile.healthConditions);
            _isInitialized = true;
          }

          return Column(
            children: [
              // ── Fixed App Bar ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        // Back button
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
                            onPressed: () {
                              if (context.canPop()) context.pop();
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.editProfile,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Invisible placeholder for symmetry
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Scrollable Form ──
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    children: [
                      // ── Avatar Section ──
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.15),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.1),
                                backgroundImage: AssetImage(
                                  _selectedGender == 'Female'
                                      ? 'assets/img/girl.png'
                                      : 'assets/img/man.png',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Section: Personal Info ──
                      _buildSectionHeader(
                        icon: Icons.person_outline_rounded,
                        title: l10n.personalInfo,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: l10n.name,
                            icon: Icons.badge_outlined,
                            validator: (value) =>
                                value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                          ),
                          _buildDivider(),
                          _buildTextField(
                            controller: null,
                            label: l10n.email,
                            icon: Icons.email_outlined,
                            initialValue: profile?.email ?? '',
                            enabled: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Section: Physical Info ──
                      _buildSectionHeader(
                        icon: Icons.accessibility_new_rounded,
                        title: 'المعلومات الجسدية',
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        children: [
                          // Age & Gender row
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ageController,
                                  label: l10n.age,
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  suffix: 'سنة',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 56,
                                color: Colors.grey.shade200,
                              ),
                              Expanded(
                                child: _buildDropdown<String>(
                                  value: _selectedGender,
                                  label: l10n.gender,
                                  icon: Icons.wc_outlined,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text(
                                        l10n.male,
                                        style: GoogleFonts.tajawal(),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text(
                                        l10n.female,
                                        style: GoogleFonts.tajawal(),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _selectedGender = value),
                                ),
                              ),
                            ],
                          ),
                          _buildDivider(),
                          // Height & Weight row
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _heightController,
                                  label: l10n.height,
                                  icon: Icons.straighten_outlined,
                                  keyboardType: TextInputType.number,
                                  suffix: l10n.cm,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 56,
                                color: Colors.grey.shade200,
                              ),
                              Expanded(
                                child: _buildTextField(
                                  controller: _weightController,
                                  label: l10n.weight,
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: TextInputType.number,
                                  suffix: l10n.kg,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Section: Lifestyle & Diet ──
                      _buildSectionHeader(
                        icon: Icons.fitness_center_rounded,
                        title: l10n.lifestyleDiet,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        children: [
                          // Lifestyle
                          _buildSelectionTile(
                            icon: Icons.directions_run_rounded,
                            label: l10n.selectLifestyle,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: Lifestyle.values.map((lifestyle) {
                                final isSelected =
                                    _selectedLifestyle == lifestyle;
                                return _buildChoiceChip(
                                  label: lifestyle.localizedName(l10n),
                                  isSelected: isSelected,
                                  onTap: () => setState(
                                    () => _selectedLifestyle = lifestyle,
                                  ),
                                  color: Colors.orange,
                                );
                              }).toList(),
                            ),
                          ),
                          _buildDivider(),
                          // Diet
                          _buildSelectionTile(
                            icon: Icons.restaurant_outlined,
                            label: l10n.selectDiet,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: DietType.values.map((diet) {
                                final isSelected = _selectedDietType == diet;
                                return _buildChoiceChip(
                                  label: diet.localizedName(l10n),
                                  isSelected: isSelected,
                                  onTap: () =>
                                      setState(() => _selectedDietType = diet),
                                  color: Colors.green,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Section: Health Conditions ──
                      _buildSectionHeader(
                        icon: Icons.favorite_border_rounded,
                        title: l10n.healthConditions,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        children: [
                          _buildSelectionTile(
                            icon: Icons.medical_services_outlined,
                            label: l10n.selectHealthConditions,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: HealthCondition.values.map((condition) {
                                final isSelected = _selectedHealthConditions
                                    .contains(condition);
                                return _buildChoiceChip(
                                  label: condition.localizedName(l10n),
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (condition == HealthCondition.none) {
                                        _selectedHealthConditions = [
                                          HealthCondition.none,
                                        ];
                                      } else {
                                        _selectedHealthConditions.remove(
                                          HealthCondition.none,
                                        );
                                        if (isSelected) {
                                          _selectedHealthConditions.remove(
                                            condition,
                                          );
                                        } else {
                                          _selectedHealthConditions.add(
                                            condition,
                                          );
                                        }
                                      }
                                    });
                                  },
                                  color: Colors.red,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Save Button ──
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isSaving ? null : _saveProfile,
                            child: Center(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          l10n.saveChanges,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل البيانات',
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: Text('إعادة المحاولة', style: GoogleFonts.tajawal()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build Helpers ──

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 20,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    String? initialValue,
    bool enabled = true,
    TextInputType? keyboardType,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.tajawal(
          fontSize: 15,
          color: enabled ? Colors.black87 : Colors.grey.shade500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.tajawal(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
          suffixText: suffix,
          suffixStyle: GoogleFonts.tajawal(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.tajawal(fontSize: 15, color: Colors.black87),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.tajawal(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
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

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, size: 16, color: color),
              const SizedBox(width: 6),
            ],
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        // Save ALL profile fields in a single Firestore write
        await ref
            .read(profileControllerProvider.notifier)
            .saveFullProfile(
              name: _nameController.text,
              age: int.tryParse(_ageController.text),
              gender: _selectedGender,
              height: double.tryParse(_heightController.text),
              weight: double.tryParse(_weightController.text),
              healthConditions: _selectedHealthConditions,
              lifestyle: _selectedLifestyle,
              dietType: _selectedDietType,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'تم حفظ التغييرات بنجاح',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'حدث خطأ أثناء الحفظ',
                    style: GoogleFonts.tajawal(color: Colors.white),
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
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
}
