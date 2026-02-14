import '../../../l10n/app_localizations.dart';

enum Lifestyle {
  sedentary, // Normal/Low activity
  active, // Athlete
  bodybuilder,
  dieting, // Weight loss focus
}

extension LifestyleExtension on Lifestyle {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case Lifestyle.sedentary:
        return l10n.sedentary;
      case Lifestyle.active:
        return l10n.active;
      case Lifestyle.bodybuilder:
        return l10n.bodybuilder;
      case Lifestyle.dieting:
        return l10n.dieting;
    }
  }

  static Lifestyle fromString(String value) {
    return Lifestyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Lifestyle.sedentary,
    );
  }
}
