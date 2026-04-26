import '../models/risk_category.dart';
import 'career_subcategories.dart';
import 'digital_privacy_subcategories.dart';
import 'financial_subcategories.dart';
import 'health_subcategories.dart';
import 'personal_safety_subcategories.dart';

/// Lines shown in the home overview hover card (keep in sync with category tabs).
List<String> categorySubPreviewLines(RiskCategory category) {
  switch (category) {
    case RiskCategory.health:
      return [
        for (final d in kHealthSubcategoryDefs) d.title,
      ];
    case RiskCategory.career:
      return [
        for (final d in kCareerSubcategoryDefs) d.title,
      ];
    case RiskCategory.financial:
      return [
        for (final d in kFinancialSubcategoryDefs) d.title,
      ];
    case RiskCategory.personalSafety:
      return [
        for (final d in kPersonalSafetySubcategoryDefs) d.title,
      ];
    case RiskCategory.digitalPrivacy:
      return [
        for (final d in kDigitalPrivacySubcategoryDefs) d.title,
      ];
  }
}
