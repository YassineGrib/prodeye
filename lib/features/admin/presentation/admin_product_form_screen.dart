import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';
import '../../companies/data/company_repository.dart';
import '../../companies/models/company.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null = create, non-null = edit

  const AdminProductFormScreen({super.key, this.product});

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _allergensCtrl;
  // Nutrition
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _saturatedFatCtrl;
  late final TextEditingController _sugarCtrl;
  late final TextEditingController _saltCtrl;
  late final TextEditingController _fiberCtrl;

  String? _selectedCompanyId;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _nameArCtrl = TextEditingController(text: p?.nameAr ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _ingredientsCtrl = TextEditingController(
      text: p?.ingredients.join(', ') ?? '',
    );
    _allergensCtrl = TextEditingController(text: p?.allergens.join(', ') ?? '');
    _caloriesCtrl = TextEditingController(
      text: p?.nutritionPer100g.calories.toString() ?? '0',
    );
    _proteinCtrl = TextEditingController(
      text: p?.nutritionPer100g.protein.toString() ?? '0',
    );
    _fatCtrl = TextEditingController(
      text: p?.nutritionPer100g.fat.toString() ?? '0',
    );
    _saturatedFatCtrl = TextEditingController(
      text: p?.nutritionPer100g.saturatedFat.toString() ?? '0',
    );
    _sugarCtrl = TextEditingController(
      text: p?.nutritionPer100g.sugar.toString() ?? '0',
    );
    _saltCtrl = TextEditingController(
      text: p?.nutritionPer100g.salt.toString() ?? '0',
    );
    _fiberCtrl = TextEditingController(
      text: p?.nutritionPer100g.fiber?.toString() ?? '0',
    );
    _selectedCompanyId = p?.companyId;
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _brandCtrl.dispose();
    _imageUrlCtrl.dispose();
    _ingredientsCtrl.dispose();
    _allergensCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _saturatedFatCtrl.dispose();
    _sugarCtrl.dispose();
    _saltCtrl.dispose();
    _fiberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(
      FutureProvider<List<Company>>((ref) {
        return ref.watch(companyRepositoryProvider).getAllCompanies();
      }),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            isEditing ? 'تعديل المنتج' : 'منتج جديد',
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
              // ── Basic Info ──
              _SectionHeader(title: 'المعلومات الأساسية'),
              const SizedBox(height: 10),
              _buildField(
                'الباركود *',
                _barcodeCtrl,
                enabled: !isEditing,
                validator: _requiredValidator,
              ),
              _buildField(
                'الاسم (إنجليزي) *',
                _nameCtrl,
                validator: _requiredValidator,
              ),
              _buildField('الاسم (عربي)', _nameArCtrl),
              _buildField(
                'العلامة التجارية *',
                _brandCtrl,
                validator: _requiredValidator,
              ),
              _buildField('رابط الصورة', _imageUrlCtrl),

              // ── Company ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'الشركة'),
              const SizedBox(height: 10),
              companiesAsync.when(
                data: (companies) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedCompanyId,
                      isExpanded: true,
                      hint: Text(
                        'اختر الشركة',
                        style: GoogleFonts.tajawal(color: Colors.grey),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('بدون', style: GoogleFonts.tajawal()),
                        ),
                        ...companies.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name, style: GoogleFonts.tajawal()),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedCompanyId = v),
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text(
                  'تعذر تحميل الشركات',
                  style: GoogleFonts.tajawal(color: Colors.red),
                ),
              ),

              // ── Nutrition ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'القيمة الغذائية (لكل 100غ)'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'السعرات',
                      _caloriesCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      'البروتين',
                      _proteinCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'الدهون',
                      _fatCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      'دهون مشبعة',
                      _saturatedFatCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'السكر',
                      _sugarCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      'الملح',
                      _saltCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildField(
                'الألياف',
                _fiberCtrl,
                keyboardType: TextInputType.number,
              ),

              // ── Ingredients & Allergens ──
              const SizedBox(height: 16),
              _SectionHeader(title: 'المكونات والحساسية'),
              const SizedBox(height: 10),
              _buildField(
                'المكونات (مفصولة بفاصلة)',
                _ingredientsCtrl,
                maxLines: 3,
              ),
              _buildField(
                'مسببات الحساسية (مفصولة بفاصلة)',
                _allergensCtrl,
                maxLines: 2,
              ),

              // ── Submit ──
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'تحديث المنتج' : 'إنشاء المنتج',
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

  List<String> _parseList(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  double _parseDouble(String text) {
    return double.tryParse(text.trim()) ?? 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final barcode = _barcodeCtrl.text.trim();
      final product = Product(
        id: barcode,
        barcode: barcode,
        name: _nameCtrl.text.trim(),
        nameAr: _nameArCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
        companyId: _selectedCompanyId,
        ingredients: _parseList(_ingredientsCtrl.text),
        allergens: _parseList(_allergensCtrl.text),
        nutritionPer100g: NutritionInfo(
          calories: _parseDouble(_caloriesCtrl.text),
          protein: _parseDouble(_proteinCtrl.text),
          fat: _parseDouble(_fatCtrl.text),
          saturatedFat: _parseDouble(_saturatedFatCtrl.text),
          sugar: _parseDouble(_sugarCtrl.text),
          salt: _parseDouble(_saltCtrl.text),
          fiber: _parseDouble(_fiberCtrl.text),
        ),
      );

      final repo = ref.read(productRepositoryProvider);
      if (isEditing) {
        await repo.updateProduct(product);
      } else {
        await repo.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تحديث المنتج!' : 'تم إنشاء المنتج!'),
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
