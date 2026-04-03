import '../models/risk_category.dart';
import 'financial_subcategories.dart';

/// Lines shown in the home overview hover card (keep in sync with category tabs).
List<String> categorySubPreviewLines(RiskCategory category) {
  switch (category) {
    case RiskCategory.health:
      return const [
        'Chronic & acute health load',
        'Healthcare cost sensitivity',
        'Preventive care gaps',
        'Coverage & access adequacy',
      ];
    case RiskCategory.career:
      return const [
        'Role & job security',
        'Income / bonus volatility',
        'Skills & training gap',
        'Workload & burnout',
        'Industry & market headwinds',
      ];
    case RiskCategory.financial:
      return [
        for (final d in kFinancialSubcategoryDefs) d.title,
      ];
    case RiskCategory.personalSafety:
      return const [
        'Neighborhood & local incidents',
        'Property / theft exposure',
        'Personal violence exposure',
      ];
    case RiskCategory.digitalPrivacy:
      return const [
        'Password & MFA hygiene',
        'Phishing & scams exposure',
        'Data breach & account reuse',
        'Device & network security',
        'Oversharing & trace footprint',
      ];
  }
}
