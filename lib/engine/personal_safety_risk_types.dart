import 'dart:math' as math;

import '../data/personal_safety_subcategories.dart';
import 'all_category_peer_norms.dart';

class PersonalSafetyRiskInputs {
  const PersonalSafetyRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
    this.monteCarloSamples = 384,
    this.randomSeed = 0x5AF371,
  });

  final List<int> factorLevels;
  final AllCategoryPeerNorms cross;

  final int horizonMonths;
  final int monteCarloSamples;
  final int randomSeed;
}

class PersonalSafetyMonteCarloSummary {
  const PersonalSafetyMonteCarloSummary({
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

class PersonalSafetyRiskResult {
  const PersonalSafetyRiskResult({
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
  final PersonalSafetyMonteCarloSummary? monteCarlo;
}

class PersonalSafetyAdaptiveState {
  PersonalSafetyAdaptiveState({
    required this.subWeights,
    required this.factorWeights,
  });

  factory PersonalSafetyAdaptiveState.initial() {
    assert(
      kPersonalSafetySubcategoryWeights.length ==
          kPersonalSafetySubcategoryDefs.length,
    );
    assert(
      kPersonalSafetyFactorWeightPriors.length ==
          kPersonalSafetySubcategoryDefs.length,
    );
    final sw = _normalizePositive(
      List<double>.from(kPersonalSafetySubcategoryWeights),
    );
    final fw = <List<double>>[];
    for (var s = 0; s < kPersonalSafetySubcategoryDefs.length; s++) {
      final pri = kPersonalSafetyFactorWeightPriors[s];
      assert(
        pri.length == kPersonalSafetySubcategoryDefs[s].factorLabels.length,
      );
      fw.add(_normalizePositive(List<double>.from(pri)));
    }
    return PersonalSafetyAdaptiveState(subWeights: sw, factorWeights: fw);
  }

  List<double> subWeights;
  List<List<double>> factorWeights;

  static List<double> _normalizePositive(List<double> w) {
    final s = w.fold<double>(0, (a, b) => a + math.max(1e-9, b));
    return w.map((e) => math.max(1e-9, e) / s).toList();
  }
}
