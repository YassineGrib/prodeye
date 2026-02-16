import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../companies/data/company_repository.dart';
import '../../companies/models/company.dart';

class AdminCompanyFormScreen extends ConsumerStatefulWidget {
  final Company? company; // null = create, non-null = edit

  const AdminCompanyFormScreen({super.key, this.company});

  @override
  ConsumerState<AdminCompanyFormScreen> createState() =>
      _AdminCompanyFormScreenState();
}

class _AdminCompanyFormScreenState
    extends ConsumerState<AdminCompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _descriptionArCtrl;
  late final TextEditingController _logoUrlCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  // Ratings
  late final TextEditingController _ratingHealthCtrl;
  late final TextEditingController _ratingTasteCtrl;
  late final TextEditingController _ratingQualityCtrl;
  late final TextEditingController _ratingPriceCtrl;

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _idCtrl = TextEditingController(text: c?.id ?? '');
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _nameArCtrl = TextEditingController(text: c?.nameAr ?? '');
    _descriptionCtrl = TextEditingController(text: c?.description ?? '');
    _descriptionArCtrl = TextEditingController(text: c?.descriptionAr ?? '');
    _logoUrlCtrl = TextEditingController(text: c?.logoUrl ?? '');
    _websiteCtrl = TextEditingController(text: c?.website ?? '');
    _locationCtrl = TextEditingController(text: c?.location ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _ratingHealthCtrl = TextEditingController(
      text: c?.ratings['health']?.toString() ?? '3.0',
    );
    _ratingTasteCtrl = TextEditingController(
      text: c?.ratings['taste']?.toString() ?? '3.0',
    );
    _ratingQualityCtrl = TextEditingController(
      text: c?.ratings['quality']?.toString() ?? '3.0',
    );
    _ratingPriceCtrl = TextEditingController(
      text: c?.ratings['price']?.toString() ?? '3.0',
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _descriptionCtrl.dispose();
    _descriptionArCtrl.dispose();
    _logoUrlCtrl.dispose();
    _websiteCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ratingHealthCtrl.dispose();
    _ratingTasteCtrl.dispose();
    _ratingQualityCtrl.dispose();
    _ratingPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            isEditing ? 'تعديل الشركة' : 'شركة جديدة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Identity ──
              _SectionHeader(title: 'الهوية'),
              const SizedBox(height: 10),
              _buildField(
                'المعرّف (snake_case) *',
                _idCtrl,
                enabled: !isEditing,
                validator: _requiredValidator,
              ),
              _buildField(
                'الاسم (إنجليزي) *',
                _nameCtrl,
                validator: _requiredValidator,
              ),
              _buildField('الاسم (عربي)', _nameArCtrl),
              _buildField('رابط الشعار', _logoUrlCtrl),

              // ── Contact & Location ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'التواصل والموقع'),
              const SizedBox(height: 10),
              _buildField('الموقع الإلكتروني', _websiteCtrl),
              _buildField(
                'الموقع الجغرافي *',
                _locationCtrl,
                validator: _requiredValidator,
              ),
              _buildField(
                'البريد الإلكتروني',
                _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildField(
                'الهاتف',
                _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),

              // ── Description ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'الوصف'),
              const SizedBox(height: 10),
              _buildField('الوصف (إنجليزي)', _descriptionCtrl, maxLines: 4),
              _buildField('الوصف (عربي)', _descriptionArCtrl, maxLines: 4),

              // ── Ratings ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'التقييمات (0.0 – 5.0)'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'الصحة',
                      _ratingHealthCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      'المذاق',
                      _ratingTasteCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'الجودة',
                      _ratingQualityCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      'السعر',
                      _ratingPriceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // ── Submit ──
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'تحديث الشركة' : 'إنشاء الشركة',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.tajawal(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.tajawal(fontSize: 13),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final company = Company(
        id: _idCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        nameAr: _nameArCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        descriptionAr: _descriptionArCtrl.text.trim(),
        logoUrl: _logoUrlCtrl.text.trim().isEmpty
            ? null
            : _logoUrlCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        ratings: {
          'health': double.tryParse(_ratingHealthCtrl.text.trim()) ?? 3.0,
          'taste': double.tryParse(_ratingTasteCtrl.text.trim()) ?? 3.0,
          'quality': double.tryParse(_ratingQualityCtrl.text.trim()) ?? 3.0,
          'price': double.tryParse(_ratingPriceCtrl.text.trim()) ?? 3.0,
        },
      );

      final repo = ref.read(companyRepositoryProvider);
      if (isEditing) {
        await repo.updateCompany(company);
      } else {
        await repo.addCompany(company.id, company);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تحديث الشركة!' : 'تم إنشاء الشركة!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }
}
