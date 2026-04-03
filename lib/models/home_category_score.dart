import 'risk_category.dart';

class HomeCategoryScore {
  const HomeCategoryScore({
    required this.label,
    required this.score,
    required this.category,
  });

  final String label;
  final double score;
  final RiskCategory category;
}

