import 'risk_category.dart';

class DriverFactor {
  const DriverFactor({
    required this.label,
    required this.level,
    required this.category,
  });

  final String label;
  // 0..4 (very low .. very high)
  final int level;
  final RiskCategory category;
}

