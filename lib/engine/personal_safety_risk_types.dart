import 'dart:math' as math;

import '../data/personal_safety_subcategories.dart';
import 'all_category_peer_norms.dart';

class PersonalSafetyRiskInputs {
  const PersonalSafetyRiskInputs({
    required this.factorLevels,
    required this.cross,
    this.horizonMonths = 12,
  });

  final List<double> factorLevels;
  final AllCategoryPeerNorms cross;

  final int horizonMonths;
}

class PersonalSafetyRiskResult {
  const PersonalSafetyRiskResult({
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
