import 'risk_category.dart';

class DriverFactor {
  const DriverFactor({
    required this.label,
    required this.level,
    required this.category,
  });

  final String label;
  /// Self-reported stress / exposure for this driver (0–100).
  final int level;
  final RiskCategory category;
}

