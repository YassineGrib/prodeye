import '../../profile/models/user_profile.dart';
import '../../profile/models/health_condition.dart';

import '../models/product.dart';
import '../models/health_score_result.dart';

/// The core health score calculation engine
/// Based on WHO recommendations (see doc/health_score_model.md)
class HealthScoreEngine {
  // ── System Constants ──
  static const double _kSugarCal = 4.0; // kcal per gram
  static const double _kFatCal = 9.0;
  static const double _kProteinCal = 4.0;
  static const double _saltDailyLimit = 5.0; // grams
  static const double _additivesNormBase = 5.0;

  // ── Base Weights (sum = 1.0) ──
  static const Map<String, double> _baseWeights = {
    'sugar': 0.30,
    'salt': 0.15,
    'fat': 0.10,
    'saturatedFat': 0.10,
    'protein': 0.10,
    'additives': 0.25,
  };

  /// Calculate personalized health score for a product
  static HealthScoreResult calculate({
    required Product product,
    required UserProfile user,
  }) {
    // ── Step 1: Check allergen compatibility ──
    final warnings = <String>[];
    bool isCompatible = true;

    for (final condition in user.healthConditions) {
      final keywords = allergenKeywords(condition);
      if (keywords.isEmpty) continue;

      // Check product allergens and ingredients for matches
      final allProductText = [
        ...product.allergens.map((a) => a.toLowerCase()),
        ...product.ingredients.map((i) => i.toLowerCase()),
      ].join(' ');

      for (final keyword in keywords) {
        if (allProductText.contains(keyword.toLowerCase())) {
          warnings.add(_allergenWarning(condition, keyword));
          isCompatible = false;
        }
      }
    }

    // If allergen found → score = 0
    if (!isCompatible) {
      return HealthScoreResult(
        score: 0,
        classification: HealthClassification.unhealthy,
        isCompatible: false,
        warnings: warnings,
        nutrientRisks: {},
        dailySugarPct: 0,
        dailySaltPct: 0,
        dailyFatPct: 0,
        dailyProteinPct: 0,
      );
    }

    // ── Step 2: Calculate BMR & TEE ──
    final bmr = _calculateBMR(
      gender: user.gender ?? 'Male',
      weightKg: user.weight ?? 70,
      heightCm: user.height ?? 170,
      age: user.age ?? 30,
    );
    final pal = palFromLifestyle(user.lifestyle);
    final tee = bmr * pal;

    // ── Step 3: Daily Limits ──
    final limits = _dailyLimits(tee);

    // ── Step 4: Get serving nutrition ──
    final serving = product.nutritionPerServing;

    // ── Step 5: Normalize (μ) ──
    final mu = <String, double>{
      'sugar': serving.sugar / limits['sugar']!,
      'salt': serving.salt / limits['salt']!,
      'fat': serving.fat / limits['fat']!,
      'saturatedFat': serving.saturatedFat / limits['saturatedFat']!,
      'protein': serving.protein / limits['protein']!,
      'additives': serving.additivesCount / _additivesNormBase,
    };

    // ── Step 6: Risk Factors (f) ──
    final riskFactors = <String, double>{
      'sugar': mu['sugar']!,
      'salt': mu['salt']!,
      'fat': mu['fat']!,
      'saturatedFat': mu['saturatedFat']!,
      'protein': 1.0 - mu['protein']!.clamp(0.0, 1.0), // inverse
      'additives': mu['additives']!,
    };

    // Clamp all risk factors to [0, 1]
    riskFactors.updateAll((key, value) => value.clamp(0.0, 1.0));

    // ── Step 7: Adjust Weights per Health Conditions ──
    final adjustedWeights = _adjustWeights(user.healthConditions);

    // ── Step 8: Calculate Total Risk ──
    double totalRisk = 0;
    for (final key in _baseWeights.keys) {
      totalRisk += adjustedWeights[key]! * riskFactors[key]!;
    }

    // ── Step 9: Final Score ──
    final score = ((1.0 - totalRisk) * 100).clamp(0.0, 100.0);

    // ── Step 10: Classification ──
    final classification = _classify(score);

    // ── Daily percentage calculations ──
    final dailySugarPct = (serving.sugar / limits['sugar']! * 100);
    final dailySaltPct = (serving.salt / limits['salt']! * 100);
    final dailyFatPct = (serving.fat / limits['fat']! * 100);
    final dailyProteinPct = (serving.protein / limits['protein']! * 100);

    // Add nutritional warnings
    if (dailySugarPct > 50) warnings.add('نسبة سكر عالية');
    if (dailySaltPct > 50) warnings.add('نسبة ملح عالية');
    if (dailyFatPct > 50) warnings.add('نسبة دهون عالية');

    return HealthScoreResult(
      score: score,
      classification: classification,
      isCompatible: score >= 30, // compatible if score >= 30
      warnings: warnings,
      nutrientRisks: riskFactors,
      dailySugarPct: dailySugarPct.clamp(0, 999),
      dailySaltPct: dailySaltPct.clamp(0, 999),
      dailyFatPct: dailyFatPct.clamp(0, 999),
      dailyProteinPct: dailyProteinPct.clamp(0, 999),
    );
  }

  // ── Private Helpers ──

  /// Mifflin-St Jeor BMR equation
  static double _calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (gender == 'Female') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    }
  }

  /// Daily nutrient limits based on TEE (WHO recommendations)
  static Map<String, double> _dailyLimits(double tee) => {
    'sugar': 0.10 * tee / _kSugarCal, // 10% of energy from sugar
    'fat': 0.30 * tee / _kFatCal, // 30% of energy from fat
    'saturatedFat': 0.10 * tee / _kFatCal, // 10% of energy from sat fat
    'salt': _saltDailyLimit, // 5g fixed
    'protein': 0.15 * tee / _kProteinCal, // 15% of energy from protein
  };

  /// Adjust weights based on user's health conditions
  static Map<String, double> _adjustWeights(List<HealthCondition> conditions) {
    // Start with base weights
    final rawWeights = Map<String, double>.from(_baseWeights);

    // Apply each condition's α multipliers
    for (final condition in conditions) {
      final alphas = adjustmentFactors(condition);
      for (final entry in alphas.entries) {
        if (rawWeights.containsKey(entry.key)) {
          rawWeights[entry.key] = rawWeights[entry.key]! * entry.value;
        }
      }
    }

    // Renormalize so weights sum to 1.0
    final total = rawWeights.values.reduce((a, b) => a + b);
    rawWeights.updateAll((key, value) => value / total);

    return rawWeights;
  }

  /// Classify score into health category
  static HealthClassification _classify(double score) {
    if (score >= 80) return HealthClassification.healthy;
    if (score >= 50) return HealthClassification.moderate;
    return HealthClassification.unhealthy;
  }

  /// Generate allergen warning message
  static String _allergenWarning(HealthCondition condition, String keyword) {
    switch (condition) {
      case HealthCondition.lactoseIntolerance:
        return 'يحتوي على اللاكتوز ⚠️';
      case HealthCondition.glutenIntolerance:
        return 'يحتوي على الغلوتين ⚠️';
      case HealthCondition.nutAllergy:
        return 'يحتوي على المكسرات ⚠️';
      case HealthCondition.shellfishAllergy:
        return 'يحتوي على المحار ⚠️';
      default:
        return 'تحذير: يحتوي على $keyword ⚠️';
    }
  }
}
