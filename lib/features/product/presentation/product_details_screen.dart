import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/profile_repository.dart';
import '../models/product.dart';
import '../models/health_score_result.dart';
import '../data/health_score_engine.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../favorites/models/favorite_item.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileAsync = ref.watch(userProfileProvider);
    final isFavoriteAsync = ref.watch(isFavoriteProvider(product.id));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: userProfileAsync.when(
        data: (profile) {
          // Calculate health score
          final result = profile != null
              ? HealthScoreEngine.calculate(product: product, user: profile)
              : null;

          return Column(
            children: [
              // ── Top Bar ──
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                            ),
                            onPressed: () {
                              if (context.canPop()) context.pop();
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.productDetails,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isFavoriteAsync.when(
                            data: (isFavorite) => IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size:
                                    24, // Slightly larger for better touch target
                                color: isFavorite
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                              onPressed: () async {
                                final repo = ref.read(
                                  favoritesRepositoryProvider,
                                );
                                if (isFavorite) {
                                  await repo.removeFromFavorites(product.id);
                                } else {
                                  await repo.addToFavorites(
                                    FavoriteItem(
                                      id: product.id,
                                      name: product.name,
                                      subtitle: product.brand,
                                      barcode: product.barcode,
                                      imageUrl: product.imageUrl,
                                      companyId: product.companyId,
                                      addedAt: DateTime.now(),
                                    ),
                                  );
                                }
                              },
                            ),
                            loading: () => const SizedBox(
                              width: 40,
                              height: 40,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, __) => const Icon(Icons.error_outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Scrollable Content ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Product Info Card ──
                    _buildProductInfoCard(context, l10n, theme),

                    const SizedBox(height: 16),

                    // ── Health Score Card ──
                    if (result != null)
                      _buildHealthScoreCard(context, l10n, result, theme),

                    const SizedBox(height: 16),

                    // ── Compatibility Badge ──
                    if (result != null)
                      _buildCompatibilityCard(context, l10n, result),

                    if (result != null && result.warnings.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildWarningsCard(context, l10n, result),
                    ],

                    const SizedBox(height: 16),

                    // ── Nutrition Facts ──
                    _buildNutritionCard(context, l10n, result, theme),

                    const SizedBox(height: 16),

                    // ── Ingredients ──
                    if (product.ingredients.isNotEmpty)
                      _buildIngredientsCard(context, l10n),

                    if (product.allergens.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAllergensCard(context, l10n),
                    ],

                    if (product.additives.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAdditivesCard(context, l10n),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: GoogleFonts.tajawal())),
      ),
    );
  }

  // ───────────────────────────────────────────
  // Product Info Card
  // ───────────────────────────────────────────
  Widget _buildProductInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image/icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.inventory_2_outlined,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameAr.isNotEmpty ? product.nameAr : product.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.companyId != null)
                  InkWell(
                    onTap: () {
                      context.pushNamed(
                        'company-details',
                        pathParameters: {'id': product.companyId!},
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.brand,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    product.brand,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.barcode,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // Health Score Card (the big circular score)
  // ───────────────────────────────────────────
  Widget _buildHealthScoreCard(
    BuildContext context,
    AppLocalizations l10n,
    HealthScoreResult result,
    ThemeData theme,
  ) {
    final scoreColor = _scoreColor(result.classification);
    final scoreLabel = _scoreLabel(l10n, result.classification);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.healthScore,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          // Circular score
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: result.score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      result.score.toStringAsFixed(0),
                      style: GoogleFonts.tajawal(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Classification badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _scoreIcon(result.classification),
                  size: 18,
                  color: scoreColor,
                ),
                const SizedBox(width: 8),
                Text(
                  scoreLabel,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // Compatibility Card
  // ───────────────────────────────────────────
  Widget _buildCompatibilityCard(
    BuildContext context,
    AppLocalizations l10n,
    HealthScoreResult result,
  ) {
    final isOk = result.isCompatible;
    final color = isOk ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOk ? l10n.compatible : l10n.notCompatible,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (!isOk)
                  Text(
                    'بناءً على حالتك الصحية',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // Warnings Card
  // ───────────────────────────────────────────
  Widget _buildWarningsCard(
    BuildContext context,
    AppLocalizations l10n,
    HealthScoreResult result,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.warnings,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...result.warnings.map(
            (warning) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // Nutrition Facts Card
  // ───────────────────────────────────────────
  Widget _buildNutritionCard(
    BuildContext context,
    AppLocalizations l10n,
    HealthScoreResult? result,
    ThemeData theme,
  ) {
    final n = product.nutritionPerServing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.nutritionFacts,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${l10n.perServing} (${product.servingSize.toStringAsFixed(0)}g)',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calories highlight
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.calories,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${n.calories.toStringAsFixed(0)} kcal',
                      style: GoogleFonts.tajawal(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nutrient bars
          _buildNutrientBar(
            label: l10n.sugar,
            value: n.sugar,
            dailyPct: result?.dailySugarPct,
            color: Colors.orange,
            unit: 'g',
          ),
          _buildNutrientBar(
            label: l10n.fat,
            value: n.fat,
            dailyPct: result?.dailyFatPct,
            color: Colors.amber,
            unit: 'g',
          ),
          _buildNutrientBar(
            label: l10n.saturatedFat,
            value: n.saturatedFat,
            dailyPct: null,
            color: Colors.red,
            unit: 'g',
          ),
          _buildNutrientBar(
            label: l10n.salt,
            value: n.salt,
            dailyPct: result?.dailySaltPct,
            color: Colors.blue,
            unit: 'g',
          ),
          _buildNutrientBar(
            label: l10n.protein,
            value: n.protein,
            dailyPct: result?.dailyProteinPct,
            color: Colors.green,
            unit: 'g',
          ),
          if (n.fiber != null)
            _buildNutrientBar(
              label: l10n.fiber,
              value: n.fiber!,
              dailyPct: null,
              color: Colors.brown,
              unit: 'g',
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientBar({
    required String label,
    required double value,
    double? dailyPct,
    required Color color,
    required String unit,
  }) {
    final pct = dailyPct?.clamp(0.0, 100.0) ?? 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (dailyPct != null) ...[
                const SizedBox(width: 6),
                Text(
                  '(${dailyPct.toStringAsFixed(0)}%)',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: dailyPct > 50 ? Colors.red : Colors.grey.shade500,
                    fontWeight: dailyPct > 50
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 50 ? Colors.red.shade400 : color.withValues(alpha: 0.7),
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // Ingredients Card
  // ───────────────────────────────────────────
  Widget _buildIngredientsCard(BuildContext context, AppLocalizations l10n) {
    return _buildListCard(
      icon: Icons.list_alt_rounded,
      title: l10n.ingredients,
      items: product.ingredients,
      color: Colors.teal,
    );
  }

  Widget _buildAllergensCard(BuildContext context, AppLocalizations l10n) {
    return _buildListCard(
      icon: Icons.warning_rounded,
      title: l10n.allergens,
      items: product.allergens,
      color: Colors.red,
      isWarning: true,
    );
  }

  Widget _buildAdditivesCard(BuildContext context, AppLocalizations l10n) {
    return _buildListCard(
      icon: Icons.science_rounded,
      title: l10n.additives,
      items: product.additives,
      color: Colors.purple,
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isWarning ? Border.all(color: Colors.red.shade100) : null,
        boxShadow: isWarning
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.15)),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Color / Label helpers ──

  Color _scoreColor(HealthClassification c) {
    switch (c) {
      case HealthClassification.healthy:
        return Colors.green;
      case HealthClassification.moderate:
        return Colors.orange;
      case HealthClassification.unhealthy:
        return Colors.red;
    }
  }

  String _scoreLabel(AppLocalizations l10n, HealthClassification c) {
    switch (c) {
      case HealthClassification.healthy:
        return l10n.healthy;
      case HealthClassification.moderate:
        return l10n.moderate;
      case HealthClassification.unhealthy:
        return l10n.unhealthy;
    }
  }

  IconData _scoreIcon(HealthClassification c) {
    switch (c) {
      case HealthClassification.healthy:
        return Icons.thumb_up_rounded;
      case HealthClassification.moderate:
        return Icons.thumbs_up_down_rounded;
      case HealthClassification.unhealthy:
        return Icons.thumb_down_rounded;
    }
  }
}
