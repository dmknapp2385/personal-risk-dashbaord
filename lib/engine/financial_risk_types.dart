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
    this.monteCarloSamples = 384,
    this.randomSeed = 0xF15CA1E,
  });

  /// Flat list aligned with [kFinancialSubcategoryDefs] factor order (each 0–100).
  final List<int> factorLevels;
  final CategoryCrossSignals cross;

  /// Forward-looking horizon (months). Scales tail amplification gently.
  final int horizonMonths;

  /// If &gt; 0, run Monte Carlo on factor stress; 0 skips (faster).
  final int monteCarloSamples;

  /// Base seed for reproducible scenarios.
  final int randomSeed;
}

/// Summary of Monte Carlo distribution on final 0–1000 score.
class FinancialMonteCarloSummary {
  const FinancialMonteCarloSummary({
    required this.mean,
    required this.p10,
    required this.p50,
    required this.p90,
    required this.samples,
  });

  final double mean;
  final double p10;
  final double p50;
  final double p90;
  final int samples;
}

/// Outcome of [FinancialRiskEngine.evaluate].
class FinancialRiskResult {
  const FinancialRiskResult({
    required this.pointNorm,
    required this.pointScore,
    required this.subcategoryStress,
    required this.subcategoryShare,
    required this.subcategoryScores,
    required this.collapseTerm,
    required this.correlationMultiplier,
    required this.horizonFactor,
    required this.maskingPenalty,
    required this.regimeTags,
    this.monteCarlo,
  });

  /// Latent financial stress in \[0, 1\] after all layers.
  final double pointNorm;

  /// Mapped to \[0, 1000\] via [RiskScore.fromNorm].
  final double pointScore;

  /// Per-subcategory stress \[0, 1\] (five entries).
  final List<double> subcategoryStress;

  /// Normalized masses for UI bar (sum ≈ 1).
  final List<double> subcategoryShare;

  /// Per-subcategory scores on 0–1000 scale (for coloring mini-style segments).
  final List<double> subcategoryScores;

  /// Non-linear “liquidity × leverage × concentration” coupling term (diagnostic).
  final double collapseTerm;

  /// Multiplier applied from cross-category signals.
  final double correlationMultiplier;

  /// Time-horizon amplification factor.
  final double horizonFactor;

  /// Extra latent stress added when low dispersion masks tail risk.
  final double maskingPenalty;

  /// Named regimes triggered by this profile (for logging / future UI).
  final List<String> regimeTags;
  final FinancialMonteCarloSummary? monteCarlo;
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
