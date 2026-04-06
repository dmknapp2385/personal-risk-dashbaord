import 'dart:math' as math;

import '../data/career_subcategories.dart';
import 'all_category_peer_norms.dart';

class CareerRiskInputs {
  const CareerRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
    this.monteCarloSamples = 384,
    this.randomSeed = 0xC4E12C,
  });

  final List<int> factorLevels;
  final AllCategoryPeerNorms cross;

  final int horizonMonths;
  final int monteCarloSamples;
  final int randomSeed;
}

class CareerMonteCarloSummary {
  const CareerMonteCarloSummary({
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

class CareerRiskResult {
  const CareerRiskResult({
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
  final CareerMonteCarloSummary? monteCarlo;
}

class CareerAdaptiveState {
  CareerAdaptiveState({
    required this.subWeights,
    required this.factorWeights,
  });

  factory CareerAdaptiveState.initial() {
    assert(
      kCareerSubcategoryWeights.length == kCareerSubcategoryDefs.length,
    );
    assert(
      kCareerFactorWeightPriors.length == kCareerSubcategoryDefs.length,
    );
    final sw =
        _normalizePositive(List<double>.from(kCareerSubcategoryWeights));
    final fw = <List<double>>[];
    for (var s = 0; s < kCareerSubcategoryDefs.length; s++) {
      final pri = kCareerFactorWeightPriors[s];
      assert(pri.length == kCareerSubcategoryDefs[s].factorLabels.length);
      fw.add(_normalizePositive(List<double>.from(pri)));
    }
    return CareerAdaptiveState(subWeights: sw, factorWeights: fw);
  }

  List<double> subWeights;
  List<List<double>> factorWeights;

  static List<double> _normalizePositive(List<double> w) {
    final s = w.fold<double>(0, (a, b) => a + math.max(1e-9, b));
    return w.map((e) => math.max(1e-9, e) / s).toList();
  }
}
