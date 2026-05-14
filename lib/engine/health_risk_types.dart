import 'dart:math' as math;

import '../data/health_subcategories.dart';
import 'all_category_peer_norms.dart';

class HealthRiskInputs {
  const HealthRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
  });

  final List<double> factorLevels;
  final AllCategoryPeerNorms cross;

  final int horizonMonths;
}

class HealthRiskResult {
  const HealthRiskResult({
    required this.pointNorm,
    required this.pointScore,
    required this.subcategoryShare,
    required this.subcategoryScores,
  });

  final double pointNorm;
  final double pointScore;
  final List<double> subcategoryShare;
  final List<double> subcategoryScores;
}

class HealthAdaptiveState {
  HealthAdaptiveState({
    required this.subWeights,
    required this.factorWeights,
  });

  factory HealthAdaptiveState.initial() {
    assert(
      kHealthSubcategoryWeights.length == kHealthSubcategoryDefs.length,
    );
    assert(
      kHealthFactorWeightPriors.length == kHealthSubcategoryDefs.length,
    );
    final sw =
        _normalizePositive(List<double>.from(kHealthSubcategoryWeights));
    final fw = <List<double>>[];
    for (var s = 0; s < kHealthSubcategoryDefs.length; s++) {
      final pri = kHealthFactorWeightPriors[s];
      assert(pri.length == kHealthSubcategoryDefs[s].factorLabels.length);
      fw.add(_normalizePositive(List<double>.from(pri)));
    }
    return HealthAdaptiveState(subWeights: sw, factorWeights: fw);
  }

  List<double> subWeights;
  List<List<double>> factorWeights;

  static List<double> _normalizePositive(List<double> w) {
    final s = w.fold<double>(0, (a, b) => a + math.max(1e-9, b));
    return w.map((e) => math.max(1e-9, e) / s).toList();
  }
}
