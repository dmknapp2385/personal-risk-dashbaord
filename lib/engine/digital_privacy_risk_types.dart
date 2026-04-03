import 'dart:math' as math;

import '../data/digital_privacy_subcategories.dart';

/// Peer category norms (0–1) for cross-category coupling into digital stress.
/// Use simple factor averages from other tabs to avoid circular engine dependency.
class DigitalPeerCrossSignals {
  const DigitalPeerCrossSignals({
    required this.financialNorm,
    required this.healthNorm,
    required this.careerNorm,
    required this.safetyNorm,
  });

  final double financialNorm;
  final double healthNorm;
  final double careerNorm;
  final double safetyNorm;
}

class DigitalPrivacyRiskInputs {
  const DigitalPrivacyRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
    this.monteCarloSamples = 384,
    this.randomSeed = 0xD16D1A1,
  });

  /// Flat list aligned with [kDigitalPrivacySubcategoryDefs] factor order.
  final List<int> factorLevels;
  final DigitalPeerCrossSignals cross;

  final int horizonMonths;
  final int monteCarloSamples;
  final int randomSeed;
}

class DigitalMonteCarloSummary {
  const DigitalMonteCarloSummary({
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

class DigitalPrivacyRiskResult {
  const DigitalPrivacyRiskResult({
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

  final double pointNorm;
  final double pointScore;
  final List<double> subcategoryStress;
  final List<double> subcategoryShare;
  final List<double> subcategoryScores;
  final double collapseTerm;
  final double correlationMultiplier;
  final double horizonFactor;
  final double maskingPenalty;
  final List<String> regimeTags;
  final DigitalMonteCarloSummary? monteCarlo;
}

class DigitalPrivacyAdaptiveState {
  DigitalPrivacyAdaptiveState({
    required this.subWeights,
    required this.factorWeights,
  });

  factory DigitalPrivacyAdaptiveState.initial() {
    assert(
      kDigitalPrivacySubcategoryWeights.length ==
          kDigitalPrivacySubcategoryDefs.length,
    );
    assert(
      kDigitalPrivacyFactorWeightPriors.length ==
          kDigitalPrivacySubcategoryDefs.length,
    );
    final sw =
        _normalizePositive(List<double>.from(kDigitalPrivacySubcategoryWeights));
    final fw = <List<double>>[];
    for (var s = 0; s < kDigitalPrivacySubcategoryDefs.length; s++) {
      final pri = kDigitalPrivacyFactorWeightPriors[s];
      assert(
        pri.length == kDigitalPrivacySubcategoryDefs[s].factorLabels.length,
      );
      fw.add(_normalizePositive(List<double>.from(pri)));
    }
    return DigitalPrivacyAdaptiveState(subWeights: sw, factorWeights: fw);
  }

  List<double> subWeights;
  List<List<double>> factorWeights;

  static List<double> _normalizePositive(List<double> w) {
    final s = w.fold<double>(0, (a, b) => a + math.max(1e-9, b));
    return w.map((e) => math.max(1e-9, e) / s).toList();
  }
}
