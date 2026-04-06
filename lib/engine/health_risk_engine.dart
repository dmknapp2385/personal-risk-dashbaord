import 'dart:math' as math;

import '../data/health_subcategories.dart';
import '../utils/risk_level_scale.dart';
import '../utils/risk_score.dart';
import 'all_category_peer_norms.dart';
import 'health_risk_types.dart';

/// Same hierarchical pipeline as [FinancialRiskEngine], tailored for health stress.
class HealthRiskEngine {
  HealthRiskEngine({
    this.subLearningRate = 0.045,
    this.factorLearningRate = 0.032,
    this.minSubWeight = 0.065,
    this.maxSubWeight = 0.42,
    this.powerMeanP = 2.15,
    this.tailBlend = 0.26,
    this.collapseGamma = 0.28,
  });

  final double subLearningRate;
  final double factorLearningRate;
  final double minSubWeight;
  final double maxSubWeight;
  final double powerMeanP;
  final double tailBlend;
  final double collapseGamma;

  HealthRiskResult evaluate(
    HealthRiskInputs inputs,
    HealthAdaptiveState adaptive, {
    bool updateAdaptive = true,
  }) {
    final levels = List<int>.from(inputs.factorLevels);
    final core = _evaluateCore(levels, inputs, adaptive);

    HealthMonteCarloSummary? mc;
    if (inputs.monteCarloSamples > 0) {
      mc = _runMonteCarlo(levels, inputs, adaptive);
    }

    if (updateAdaptive) {
      _onlineWeightUpdate(adaptive, core.subStressRaw, levels);
    }

    return HealthRiskResult(
      pointNorm: core.norm,
      pointScore: RiskScore.fromNorm(core.norm),
      subcategoryStress: List<double>.from(core.subStressRaw),
      subcategoryShare: List<double>.from(core.subShare),
      subcategoryScores: core.subStressRaw
          .map((u) => RiskScore.fromNorm(u.clamp(0.0, 1.0)))
          .toList(),
      collapseTerm: core.collapseTerm,
      correlationMultiplier: core.correlationMultiplier,
      horizonFactor: core.horizonFactor,
      maskingPenalty: core.maskingPenalty,
      regimeTags: core.regimeTags,
      monteCarlo: mc,
    );
  }

  _CoreOutcome _evaluateCore(
    List<int> levels,
    HealthRiskInputs inputs,
    HealthAdaptiveState adaptive,
  ) {
    final uFlat = levels.map(RiskLevelScale.toNorm).toList();

    final subStress = <double>[];
    var offset = 0;
    for (var s = 0; s < kHealthSubcategoryDefs.length; s++) {
      final n = kHealthSubcategoryDefs[s].factorLabels.length;
      final seg = uFlat.sublist(offset, offset + n);
      final w = adaptive.factorWeights[s];
      subStress.add(_subStress(seg, w));
      offset += n;
    }

    final collapse = _collapseTerm(subStress);
    var uAgg = _weightedAggregate(subStress, adaptive.subWeights);
    uAgg = (1 - collapseGamma) * uAgg +
        collapseGamma * math.max(uAgg, collapse.clamp(0.0, 0.48));

    final corr = _correlationMultiplier(inputs.cross);
    uAgg = (uAgg * corr).clamp(0.0, 1.0);

    final hFactor = _horizonFactor(inputs.horizonMonths);
    uAgg = (uAgg * hFactor).clamp(0.0, 1.0);

    final maskPen = _maskingPenalty(subStress, uAgg);
    uAgg = (uAgg + maskPen).clamp(0.0, 1.0);

    final share = _subShares(subStress, adaptive.subWeights);
    final tags = _regimeTags(subStress, collapse, uAgg, maskPen);

    return _CoreOutcome(
      norm: uAgg,
      subStressRaw: subStress,
      subShare: share,
      collapseTerm: collapse,
      correlationMultiplier: corr,
      horizonFactor: hFactor,
      maskingPenalty: maskPen,
      regimeTags: tags,
    );
  }

  double _subStress(List<double> u, List<double> w) {
    assert(u.length == w.length);
    var num = 0.0;
    var den = 0.0;
    for (var i = 0; i < u.length; i++) {
      final wi = w[i].clamp(1e-9, 1.0);
      num += wi * math.pow(u[i].clamp(0.0, 1.0), powerMeanP);
      den += wi;
    }
    final pMean = den > 0
        ? math.pow(num / den, 1.0 / powerMeanP).toDouble()
        : 0.0;
    final mx = u.isEmpty ? 0.0 : u.reduce(math.max);
    return ((1 - tailBlend) * pMean + tailBlend * mx).clamp(0.0, 1.0);
  }

  /// Burden × cost strain × access friction (subs 0, 2, 1).
  double _collapseTerm(List<double> sub) {
    if (sub.length < 3) return 0;
    final burden = sub[0];
    final cost = sub[2];
    final access = sub[1];
    final raw = math.pow(math.max(1e-9, burden * cost), 0.55) *
        (1 + 0.24 * access);
    return raw.clamp(0.0, 0.48);
  }

  double _weightedAggregate(List<double> sub, List<double> w) {
    var t = 0.0;
    var s = 0.0;
    for (var i = 0; i < sub.length; i++) {
      t += w[i] * sub[i];
      s += w[i];
    }
    return s > 0 ? (t / s) : 0.0;
  }

  /// Peer categories (excluding health — use flat factor averages).
  double _correlationMultiplier(AllCategoryPeerNorms c) {
    const kFin = 0.09;
    const kDig = 0.07;
    const kCar = 0.08;
    const kSafe = 0.06;
    var m = 1.0 +
        kFin * (c.financialNorm - 0.5) +
        kDig * (c.digitalNorm - 0.5) +
        kCar * (c.careerNorm - 0.5) +
        kSafe * (c.safetyNorm - 0.5);
    return m.clamp(0.90, 1.14);
  }

  double _horizonFactor(int months) {
    if (months <= 0) return 1.0;
    final t = math.log(1 + months / 6.0);
    return (1 + 0.11 * t).clamp(1.0, 1.32);
  }

  double _maskingPenalty(List<double> sub, double aggregate) {
    if (sub.length < 2) return 0;
    final mean = sub.fold<double>(0, (a, b) => a + b) / sub.length;
    var v = 0.0;
    for (final s in sub) {
      v += (s - mean) * (s - mean);
    }
    final sd = math.sqrt(v / sub.length);
    if (mean > 0.22 && mean < 0.62 && sd < 0.075) {
      return 0.045;
    }
    if (aggregate > 0.38 && aggregate < 0.58 && sd < 0.055) {
      return 0.03;
    }
    return 0;
  }

  List<double> _subShares(List<double> stress, List<double> w) {
    final masses = <double>[];
    for (var i = 0; i < stress.length; i++) {
      masses.add(w[i] * (0.14 + stress[i]));
    }
    final sum = masses.fold<double>(0, (a, b) => a + b);
    if (sum <= 1e-12) {
      return List<double>.filled(stress.length, 1.0 / stress.length);
    }
    return masses.map((m) => m / sum).toList();
  }

  List<String> _regimeTags(
    List<double> sub,
    double collapse,
    double agg,
    double maskPen,
  ) {
    final tags = <String>[];
    if (sub.length >= 3 && sub[0] > 0.55 && sub[2] > 0.55) {
      tags.add('Burden–cost stress couplet');
    }
    if (collapse > 0.22) {
      tags.add('Access–cost coupling (tail dependent)');
    }
    if (sub.length > 1 && sub[1] > 0.6) {
      tags.add('Access / prevention amplification');
    }
    if (maskPen > 0) {
      tags.add('Low dispersion penalty (anti-masking)');
    }
    if (agg > 0.72) {
      tags.add('Elevated composite health stress');
    }
    if (tags.isEmpty) {
      tags.add('Baseline health profile');
    }
    return tags;
  }

  void _onlineWeightUpdate(
    HealthAdaptiveState adaptive,
    List<double> subStress,
    List<int> levels,
  ) {
    final idealSub = subStress.map((s) => s + 0.14).toList();
    _normalizeIdeal(idealSub);
    for (var i = 0; i < adaptive.subWeights.length; i++) {
      adaptive.subWeights[i] = (1 - subLearningRate) * adaptive.subWeights[i] +
          subLearningRate * idealSub[i];
    }
    _clampRenormalize(adaptive.subWeights, minSubWeight, maxSubWeight);

    var offset = 0;
    for (var s = 0; s < kHealthSubcategoryDefs.length; s++) {
      final n = kHealthSubcategoryDefs[s].factorLabels.length;
      final seg = levels.sublist(offset, offset + n);
      final u = seg.map(RiskLevelScale.toNorm).toList();
      final idealF = u.map((x) => x + 0.08).toList();
      _normalizeIdeal(idealF);
      final row = adaptive.factorWeights[s];
      for (var i = 0; i < row.length; i++) {
        row[i] =
            (1 - factorLearningRate) * row[i] + factorLearningRate * idealF[i];
      }
      _clampRenormalize(row, 0.08, 0.55);
      offset += n;
    }
  }

  static void _normalizeIdeal(List<double> v) {
    final s = v.fold<double>(0, (a, b) => a + b);
    if (s <= 1e-12) return;
    for (var i = 0; i < v.length; i++) {
      v[i] /= s;
    }
  }

  static void _clampRenormalize(List<double> w, double lo, double hi) {
    for (var i = 0; i < w.length; i++) {
      w[i] = w[i].clamp(lo, hi);
    }
    final s = w.fold<double>(0, (a, b) => a + b);
    if (s <= 1e-12) return;
    for (var i = 0; i < w.length; i++) {
      w[i] /= s;
    }
  }

  HealthMonteCarloSummary _runMonteCarlo(
    List<int> baseLevels,
    HealthRiskInputs inputs,
    HealthAdaptiveState adaptive,
  ) {
    final rnd = math.Random(inputs.randomSeed);
    final scores = <double>[];
    final n = inputs.monteCarloSamples;
    for (var k = 0; k < n; k++) {
      final perturbed = _perturbLevels(baseLevels, rnd);
      final c = _evaluateCore(perturbed, inputs, adaptive);
      scores.add(RiskScore.fromNorm(c.norm));
    }
    scores.sort();
    double q(List<double> a, double p) {
      if (a.isEmpty) return 0;
      final idx = (p * (a.length - 1)).round().clamp(0, a.length - 1);
      return a[idx];
    }

    final mean = scores.fold<double>(0, (a, b) => a + b) / scores.length;
    return HealthMonteCarloSummary(
      mean: mean,
      p10: q(scores, 0.10),
      p50: q(scores, 0.50),
      p90: q(scores, 0.90),
      samples: n,
    );
  }

  List<int> _perturbLevels(List<int> base, math.Random rnd) {
    return base.map((L) {
      final u = RiskLevelScale.toNorm(L);
      final sigma = 0.055 + 0.11 * u;
      var up = u + _gaussian(rnd) * sigma;
      up = up.clamp(0.0, 1.0);
      return RiskLevelScale.clamp((up * RiskLevelScale.max).round());
    }).toList();
  }

  double _gaussian(math.Random rnd) {
    final u1 = rnd.nextDouble();
    final u2 = rnd.nextDouble();
    return math.sqrt(-2 * math.log(u1.clamp(1e-12, 1.0))) *
        math.cos(2 * math.pi * u2);
  }
}

class _CoreOutcome {
  _CoreOutcome({
    required this.norm,
    required this.subStressRaw,
    required this.subShare,
    required this.collapseTerm,
    required this.correlationMultiplier,
    required this.horizonFactor,
    required this.maskingPenalty,
    required this.regimeTags,
  });

  final double norm;
  final List<double> subStressRaw;
  final List<double> subShare;
  final double collapseTerm;
  final double correlationMultiplier;
  final double horizonFactor;
  final double maskingPenalty;
  final List<String> regimeTags;
}
