import '../../../l10n/app_localizations.dart';

enum DietType { balanced, vegetarian, vegan, keto, paleo, mediterranean }

extension DietTypeExtension on DietType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case DietType.balanced:
        return l10n.balanced;
      case DietType.vegetarian:
        return l10n.vegetarian;
      case DietType.vegan:
        return l10n.vegan;
      case DietType.keto:
        return l10n.keto;
      case DietType.paleo:
        return l10n.paleo;
      case DietType.mediterranean:
        return l10n.mediterranean;
    }
  }

  static DietType fromString(String value) {
    return DietType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DietType.balanced,
    );
  }
}
