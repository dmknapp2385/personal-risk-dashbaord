import 'package:flutter/foundation.dart';

import '../data/career_subcategories.dart';
import '../data/digital_privacy_subcategories.dart';
import '../data/financial_subcategories.dart';
import '../data/health_subcategories.dart';
import '../data/personal_safety_subcategories.dart';
import '../engine/all_category_peer_norms.dart';
import '../engine/career_risk_engine.dart';
import '../engine/career_risk_types.dart';
import '../engine/digital_privacy_risk_engine.dart';
import '../engine/digital_privacy_risk_types.dart';
import '../engine/financial_risk_engine.dart';
import '../engine/financial_risk_types.dart';
import '../engine/health_risk_engine.dart';
import '../engine/health_risk_types.dart';
import '../engine/personal_safety_risk_engine.dart';
import '../engine/personal_safety_risk_types.dart';
import '../models/driver_factor.dart';
import '../models/risk_category.dart';
import '../utils/risk_level_scale.dart';
import '../utils/risk_score.dart';

/// Holds all mock questionnaire state; notifies listeners so pushed routes stay in sync.
class RiskInputsController extends ChangeNotifier {
  /// One score per financial factor (0–100); see [kFinancialSubcategoryDefs].
  List<int> financialFactorLevels = [
    50, 25, 25, // liquidity
    50, 25, 25, 25, // obligations
    50, 25, 25, // asset risk
    50, 25, 25, // concentration
    50, 25, 25, // inflation
  ];

  /// One score per health factor (0–100); see [kHealthSubcategoryDefs].
  List<int> healthFactorLevels = [
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
  ];

  /// One score per career factor (0–100); see [kCareerSubcategoryDefs].
  List<int> careerFactorLevels = [
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
  ];

  /// One score per personal-safety factor (0–100); see [kPersonalSafetySubcategoryDefs].
  List<int> personalSafetyFactorLevels = [
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
    50, 25, 25,
  ];

  /// One score per digital factor (0–100); see [kDigitalPrivacySubcategoryDefs].
  List<int> digitalFactorLevels = [
    50, 25, 25, // identity & authentication
    50, 25, 25, // phishing & social engineering
    50, 25, 25, // data exposure & account hygiene
    50, 25, 25, // devices & networks
    50, 25, 25, // privacy & footprint
  ];

  String crimeLocationInput = '';

  final FinancialAdaptiveState _financialAdaptive = FinancialAdaptiveState.initial();
  final FinancialRiskEngine _financialEngine = FinancialRiskEngine();
  FinancialRiskResult? _financialRiskCache;

  final DigitalPrivacyAdaptiveState _digitalAdaptive =
      DigitalPrivacyAdaptiveState.initial();
  final DigitalPrivacyRiskEngine _digitalEngine = DigitalPrivacyRiskEngine();
  DigitalPrivacyRiskResult? _digitalRiskCache;

  final HealthAdaptiveState _healthAdaptive = HealthAdaptiveState.initial();
  final HealthRiskEngine _healthEngine = HealthRiskEngine();
  HealthRiskResult? _healthRiskCache;

  final CareerAdaptiveState _careerAdaptive = CareerAdaptiveState.initial();
  final CareerRiskEngine _careerEngine = CareerRiskEngine();
  CareerRiskResult? _careerRiskCache;

  final PersonalSafetyAdaptiveState _personalSafetyAdaptive =
      PersonalSafetyAdaptiveState.initial();
  final PersonalSafetyRiskEngine _personalSafetyEngine =
      PersonalSafetyRiskEngine();
  PersonalSafetyRiskResult? _personalSafetyRiskCache;

  @override
  void notifyListeners() {
    _financialRiskCache = null;
    _digitalRiskCache = null;
    _healthRiskCache = null;
    _careerRiskCache = null;
    _personalSafetyRiskCache = null;
    super.notifyListeners();
  }

  /// Flat averages (0–1) for cross-category coupling—no engine self-loop.
  AllCategoryPeerNorms get _peerNorms => AllCategoryPeerNorms(
        financialNorm: _avgNorm(financialFactorLevels),
        digitalNorm: _avgNorm(digitalFactorLevels),
        healthNorm: _avgNorm(healthFactorLevels),
        careerNorm: _avgNorm(careerFactorLevels),
        safetyNorm: _avgNorm(personalSafetyFactorLevels),
      );

  FinancialRiskResult get financialRiskResult {
    final p = _peerNorms;
    _financialRiskCache ??= _financialEngine.evaluate(
      FinancialRiskInputs(
        factorLevels: financialFactorLevels,
        cross: CategoryCrossSignals(
          healthNorm: p.healthNorm,
          careerNorm: p.careerNorm,
          safetyNorm: p.safetyNorm,
          digitalNorm: p.digitalNorm,
        ),
      ),
      _financialAdaptive,
    );
    return _financialRiskCache!;
  }

  DigitalPrivacyRiskResult get digitalRiskResult {
    final p = _peerNorms;
    _digitalRiskCache ??= _digitalEngine.evaluate(
      DigitalPrivacyRiskInputs(
        factorLevels: digitalFactorLevels,
        cross: DigitalPeerCrossSignals(
          financialNorm: p.financialNorm,
          healthNorm: p.healthNorm,
          careerNorm: p.careerNorm,
          safetyNorm: p.safetyNorm,
        ),
      ),
      _digitalAdaptive,
    );
    return _digitalRiskCache!;
  }

  HealthRiskResult get healthRiskResult {
    _healthRiskCache ??= _healthEngine.evaluate(
      HealthRiskInputs(
        factorLevels: healthFactorLevels,
        cross: _peerNorms,
      ),
      _healthAdaptive,
    );
    return _healthRiskCache!;
  }

  CareerRiskResult get careerRiskResult {
    _careerRiskCache ??= _careerEngine.evaluate(
      CareerRiskInputs(
        factorLevels: careerFactorLevels,
        cross: _peerNorms,
      ),
      _careerAdaptive,
    );
    return _careerRiskCache!;
  }

  PersonalSafetyRiskResult get personalSafetyRiskResult {
    _personalSafetyRiskCache ??= _personalSafetyEngine.evaluate(
      PersonalSafetyRiskInputs(
        factorLevels: personalSafetyFactorLevels,
        cross: _peerNorms,
      ),
      _personalSafetyAdaptive,
    );
    return _personalSafetyRiskCache!;
  }

  double _avgNorm(List<int> levels) {
    if (levels.isEmpty) return 0;
    final sum = levels.reduce((a, b) => a + b).toDouble();
    return sum / (levels.length * RiskLevelScale.max);
  }

  /// Latent stress \[0,1\] from the financial risk engine.
  double get financialNorm => financialRiskResult.pointNorm;

  /// Latent stress \[0,1\] from the digital / privacy risk engine.
  double get digitalNorm => digitalRiskResult.pointNorm;

  double get overallRiskScore {
    final normalized = (healthRiskResult.pointNorm +
            careerRiskResult.pointNorm +
            financialRiskResult.pointNorm +
            personalSafetyRiskResult.pointNorm +
            digitalRiskResult.pointNorm) /
        5.0;
    return RiskScore.fromNorm(normalized);
  }

  double get healthRiskScore => healthRiskResult.pointScore;
  double get careerRiskScore => careerRiskResult.pointScore;
  double get financialRiskScore => financialRiskResult.pointScore;
  double get personalSafetyRiskScore => personalSafetyRiskResult.pointScore;
  double get digitalPrivacyRiskScore => digitalRiskResult.pointScore;

  List<double> get financialSubcategoryShares =>
      financialRiskResult.subcategoryShare;

  List<double> get financialSubcategoryScores =>
      financialRiskResult.subcategoryScores;

  List<double> get digitalSubcategoryShares =>
      digitalRiskResult.subcategoryShare;

  List<double> get digitalSubcategoryScores =>
      digitalRiskResult.subcategoryScores;

  List<double> get healthSubcategoryShares => healthRiskResult.subcategoryShare;

  List<double> get healthSubcategoryScores =>
      healthRiskResult.subcategoryScores;

  List<double> get careerSubcategoryShares => careerRiskResult.subcategoryShare;

  List<double> get careerSubcategoryScores =>
      careerRiskResult.subcategoryScores;

  List<double> get personalSafetySubcategoryShares =>
      personalSafetyRiskResult.subcategoryShare;

  List<double> get personalSafetySubcategoryScores =>
      personalSafetyRiskResult.subcategoryScores;

  List<DriverFactor> get topDrivers {
    final financialLabels = kFinancialAllFactorLabels;
    final digitalLabels = kDigitalPrivacyAllFactorLabels;
    final healthLabels = kHealthAllFactorLabels;
    final careerLabels = kCareerAllFactorLabels;
    final safetyLabels = kPersonalSafetyAllFactorLabels;

    final factors = <DriverFactor>[
      for (int i = 0; i < healthLabels.length; i++)
        DriverFactor(
          label: healthLabels[i],
          level: healthFactorLevels[i],
          category: RiskCategory.health,
        ),
      for (int i = 0; i < careerLabels.length; i++)
        DriverFactor(
          label: careerLabels[i],
          level: careerFactorLevels[i],
          category: RiskCategory.career,
        ),
      for (int i = 0; i < financialLabels.length; i++)
        DriverFactor(
          label: financialLabels[i],
          level: financialFactorLevels[i],
          category: RiskCategory.financial,
        ),
      for (int i = 0; i < safetyLabels.length; i++)
        DriverFactor(
          label: safetyLabels[i],
          level: personalSafetyFactorLevels[i],
          category: RiskCategory.personalSafety,
        ),
      for (int i = 0; i < digitalLabels.length; i++)
        DriverFactor(
          label: digitalLabels[i],
          level: digitalFactorLevels[i],
          category: RiskCategory.digitalPrivacy,
        ),
    ];

    factors.sort((a, b) => b.level.compareTo(a.level));
    return factors.take(6).toList();
  }

  void setFinancialFactor(int index, int level) {
    if (index < 0 || index >= financialFactorLevels.length) return;
    financialFactorLevels[index] = RiskLevelScale.clamp(level);
    notifyListeners();
  }

  void setHealthFactor(int index, int level) {
    if (index < 0 || index >= healthFactorLevels.length) return;
    healthFactorLevels[index] = RiskLevelScale.clamp(level);
    notifyListeners();
  }

  void setCareerFactor(int index, int level) {
    if (index < 0 || index >= careerFactorLevels.length) return;
    careerFactorLevels[index] = RiskLevelScale.clamp(level);
    notifyListeners();
  }

  void setPersonalSafetyFactor(int index, int level) {
    if (index < 0 || index >= personalSafetyFactorLevels.length) return;
    personalSafetyFactorLevels[index] = RiskLevelScale.clamp(level);
    notifyListeners();
  }

  void setDigitalFactor(int index, int level) {
    if (index < 0 || index >= digitalFactorLevels.length) return;
    digitalFactorLevels[index] = RiskLevelScale.clamp(level);
    notifyListeners();
  }

  void setCrimeLocationInput(String value) {
    crimeLocationInput = value;
    notifyListeners();
  }
}
