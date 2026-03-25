enum RiskCategory {
  health,
  career,
  financial,
  personalSafety,
  digitalPrivacy,
}

extension RiskCategoryTitles on RiskCategory {
  String get shortLabel => switch (this) {
        RiskCategory.health => 'Health',
        RiskCategory.career => 'Career',
        RiskCategory.financial => 'Financial',
        RiskCategory.personalSafety => 'Personal Safety',
        RiskCategory.digitalPrivacy => 'Digital / Privacy',
      };
}
