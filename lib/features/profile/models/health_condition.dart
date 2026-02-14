import '../../../l10n/app_localizations.dart';

enum HealthCondition {
  diabetes,
  highBloodPressure,
  heartDisease,
  kidneyDisease,
  lactoseIntolerance,
  glutenIntolerance,
  nutAllergy,
  shellfishAllergy,
  vegan, // Can be treated as a condition/restriction for filtering
  vegetarian,
  none,
}

extension HealthConditionExtension on HealthCondition {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case HealthCondition.diabetes:
        return l10n.diabetes;
      case HealthCondition.highBloodPressure:
        return l10n.highBloodPressure;
      case HealthCondition.heartDisease:
        return l10n.heartDisease;
      case HealthCondition.kidneyDisease:
        return l10n.kidneyDisease;
      case HealthCondition.lactoseIntolerance:
        return l10n.lactoseIntolerance;
      case HealthCondition.glutenIntolerance:
        return l10n.glutenIntolerance;
      case HealthCondition.nutAllergy:
        return l10n.nutAllergy;
      case HealthCondition.shellfishAllergy:
        return l10n.shellfishAllergy;
      case HealthCondition.vegan:
        return l10n.vegan;
      case HealthCondition.vegetarian:
        return l10n.vegetarian;
      case HealthCondition.none:
        return l10n.none;
    }
  }

  // Helper to map from string stored in DB
  static HealthCondition fromString(String value) {
    return HealthCondition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HealthCondition.none,
    );
  }
}
