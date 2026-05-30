import 'dart:math' as math;

import '../data/financial_subcategories.dart';

/// External category norms (0–1) used for cross-category coupling with financial stress.
class CategoryCrossSignals {
  const CategoryCrossSignals({
    required this.healthNorm,
    required this.careerNorm,
    required this.safetyNorm,
    required this.digitalNorm,
  });

  final double healthNorm;
  final double careerNorm;
  final double safetyNorm;
  final double digitalNorm;
}

/// Single evaluation of the financial risk engine.
class FinancialRiskInputs {
  const FinancialRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
  });

  /// Flat list aligned with [kFinancialSubcategoryDefs] factor order
  /// (each 0.00–100.00).
  final List<double> factorLevels;
  final CategoryCrossSignals cross;

  /// Forward-looking horizon (months). Scales tail amplification gently.
  final int horizonMonths;
}

/// Outcome of [FinancialRiskEngine.evaluate].
class FinancialRiskResult {
  const FinancialRiskResult({
    required this.pointNorm,
    required this.pointScore,
    required this.subcategoryShare,
    required this.subcategoryScores,
  });

  /// Latent financial stress in \[0, 1\] after all layers.
  final double pointNorm;

  /// Mapped to \[0, 1000\] via [RiskScore.fromNorm].
  final double pointScore;

  /// Normalized masses for UI bar (sum ≈ 1).
  final List<double> subcategoryShare;

  /// Per-subcategory scores on 0–1000 scale (for coloring mini-style segments).
  final List<double> subcategoryScores;
}

/// Mutable adaptive weights (persist to storage in a future iteration).
class FinancialAdaptiveState {
  FinancialAdaptiveState({
    required this.subWeights,
    required this.factorWeights,
  });

  factory FinancialAdaptiveState.initial() {
    assert(
      kFinancialSubcategoryWeights.length == kFinancialSubcategoryDefs.length,
    );
    assert(
      kFinancialFactorWeightPriors.length == kFinancialSubcategoryDefs.length,
    );
    final sw = _normalizePositive(List<double>.from(kFinancialSubcategoryWeights));
    final fw = <List<double>>[];
    for (var s = 0; s < kFinancialSubcategoryDefs.length; s++) {
      final pri = kFinancialFactorWeightPriors[s];
      assert(pri.length == kFinancialSubcategoryDefs[s].factorLabels.length);
      fw.add(_normalizePositive(List<double>.from(pri)));
    }
    return FinancialAdaptiveState(subWeights: sw, factorWeights: fw);
  }

  /// Subcategory weights on the probability simplex (sum 1).
  List<double> subWeights;

  /// Factor weights within each subcategory (each row sums to 1).
  List<List<double>> factorWeights;

  static List<double> _normalizePositive(List<double> w) {
    final s = w.fold<double>(0, (a, b) => a + math.max(1e-9, b));
    return w.map((e) => math.max(1e-9, e) / s).toList();
  }
}
