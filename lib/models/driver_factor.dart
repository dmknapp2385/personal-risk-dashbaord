import 'risk_category.dart';

class DriverFactor {
  const DriverFactor({
    required this.label,
    required this.level,
    required this.category,
  });

  final String label;

  /// Self-reported stress / exposure for this driver (0.00–100.00).
  final double level;

  final RiskCategory category;
}
