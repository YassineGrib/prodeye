import '../../profile/models/health_condition.dart';
import '../../profile/models/lifestyle.dart';

/// The result of a health score calculation
class HealthScoreResult {
  final double score; // 0-100
  final HealthClassification classification;
  final bool isCompatible; // compatible with user's health?
  final List<String> warnings; // e.g. "Contains lactose"
  final Map<String, double> nutrientRisks; // per-nutrient risk breakdown
  final double dailySugarPct; // % of daily sugar limit
  final double dailySaltPct; // % of daily salt limit
  final double dailyFatPct; // % of daily fat limit
  final double dailyProteinPct; // % of daily protein limit

  const HealthScoreResult({
    required this.score,
    required this.classification,
    required this.isCompatible,
    this.warnings = const [],
    this.nutrientRisks = const {},
    this.dailySugarPct = 0,
    this.dailySaltPct = 0,
    this.dailyFatPct = 0,
    this.dailyProteinPct = 0,
  });
}

/// Health classification based on score
enum HealthClassification {
  healthy, // ≥ 80
  moderate, // 50 - 79
  unhealthy, // < 50
}

/// Physical Activity Level multipliers
double palFromLifestyle(Lifestyle lifestyle) {
  switch (lifestyle) {
    case Lifestyle.sedentary:
      return 1.2;
    case Lifestyle.active:
      return 1.55;
    case Lifestyle.bodybuilder:
      return 1.725;
    case Lifestyle.dieting:
      return 1.375;
  }
}

/// Adjustment factors (α) for each health condition
/// Maps: condition → { nutrient_key → α multiplier }
Map<String, double> adjustmentFactors(HealthCondition condition) {
  switch (condition) {
    case HealthCondition.diabetes:
      return {'sugar': 1.5, 'saturatedFat': 1.2};

    case HealthCondition.heartDisease:
      return {'saturatedFat': 1.5, 'salt': 1.4, 'fat': 1.2};

    case HealthCondition.highBloodPressure:
      return {'salt': 1.6, 'saturatedFat': 1.2};

    // Allergies are handled separately (score = 0 if allergen found)
    case HealthCondition.lactoseIntolerance:
    case HealthCondition.glutenIntolerance:
    case HealthCondition.nutAllergy:
    case HealthCondition.shellfishAllergy:
      return {}; // no weight adjustment, binary check

    case HealthCondition.kidneyDisease:
      return {'salt': 1.4, 'protein': 1.3}; // limit protein and salt

    case HealthCondition.vegan:
    case HealthCondition.vegetarian:
    case HealthCondition.none:
      return {};
  }
}

/// Maps health conditions to allergen keywords that trigger score = 0
List<String> allergenKeywords(HealthCondition condition) {
  switch (condition) {
    case HealthCondition.lactoseIntolerance:
      return ['lactose', 'milk', 'dairy', 'لاكتوز', 'حليب'];
    case HealthCondition.glutenIntolerance:
      return ['gluten', 'wheat', 'barley', 'rye', 'غلوتين', 'قمح'];
    case HealthCondition.nutAllergy:
      return ['nuts', 'peanut', 'almond', 'cashew', 'مكسرات', 'فول سوداني'];
    case HealthCondition.shellfishAllergy:
      return ['shellfish', 'shrimp', 'crab', 'lobster', 'محار', 'جمبري'];
    case HealthCondition.vegan:
      return [
        'meat',
        'chicken',
        'beef',
        'pork',
        'fish',
        'egg',
        'milk',
        'dairy',
        'honey',
        'لحم',
        'دجاج',
        'بيض',
        'حليب',
        'عسل',
      ];
    case HealthCondition.vegetarian:
      return ['meat', 'chicken', 'beef', 'pork', 'fish', 'لحم', 'دجاج', 'سمك'];
    default:
      return [];
  }
}
