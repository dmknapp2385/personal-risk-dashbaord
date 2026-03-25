import 'package:flutter/foundation.dart';

import '../data/financial_subcategories.dart';
import '../engine/financial_risk_engine.dart';
import '../engine/financial_risk_types.dart';
import '../models/driver_factor.dart';
import '../models/risk_category.dart';
import '../utils/risk_score.dart';

/// Holds all mock questionnaire state; notifies listeners so pushed routes stay in sync.
class RiskInputsController extends ChangeNotifier {
  /// One level per financial sub-sub factor (0..4); see [kFinancialSubcategoryDefs].
  List<int> financialFactorLevels = [
    2, 1, 1, // liquidity
    2, 1, 1, 1, // obligations
    2, 1, 1, // asset risk
    2, 1, 1, // concentration
    2, 1, 1, // inflation
  ];

  int insuranceCoverageAdequacy = 2;
  int insuranceDeductibleSensitivity = 1;
  int insuranceLiabilityCoverage = 2;
  int insuranceAssetCoverage = 1;

  int crimeIncidentFrequency = 2;
  int crimePropertyCrime = 1;
  int crimeViolentCrime = 1;

  int climateHeat = 2;
  int climateFlood = 1;
  int climateWildfire = 1;
  int climateStorm = 2;
  int climateResilience = 1;

  int digitalPasswordHygiene = 2;
  int digitalPhishingExposure = 1;
  int digitalBreachExposure = 1;
  int digitalDeviceSecurity = 2;
  int digitalOversharing = 1;

  String crimeLocationInput = '';

  final FinancialAdaptiveState _financialAdaptive = FinancialAdaptiveState.initial();
  final FinancialRiskEngine _financialEngine = FinancialRiskEngine();
  FinancialRiskResult? _financialRiskCache;

  @override
  void notifyListeners() {
    _financialRiskCache = null;
    super.notifyListeners();
  }

  FinancialRiskResult get financialRiskResult {
    _financialRiskCache ??= _financialEngine.evaluate(
      FinancialRiskInputs(
        factorLevels: financialFactorLevels,
        cross: CategoryCrossSignals(
          healthNorm: insuranceNorm,
          careerNorm: climateNorm,
          safetyNorm: crimeNorm,
          digitalNorm: digitalNorm,
        ),
      ),
      _financialAdaptive,
    );
    return _financialRiskCache!;
  }

  double _avgNorm(List<int> levels) {
    if (levels.isEmpty) return 0;
    final sum = levels.reduce((a, b) => a + b).toDouble();
    return sum / (levels.length * 4.0);
  }

  /// Latent stress \[0,1\] from the financial risk engine (not a flat average).
  double get financialNorm => financialRiskResult.pointNorm;

  double get insuranceNorm => _avgNorm([
        insuranceCoverageAdequacy,
        insuranceDeductibleSensitivity,
        insuranceLiabilityCoverage,
        insuranceAssetCoverage,
      ]);

  double get crimeNorm => _avgNorm([
        crimeIncidentFrequency,
        crimePropertyCrime,
        crimeViolentCrime,
      ]);

  double get climateNorm => _avgNorm([
        climateHeat,
        climateFlood,
        climateWildfire,
        climateStorm,
        climateResilience,
      ]);

  double get digitalNorm => _avgNorm([
        digitalPasswordHygiene,
        digitalPhishingExposure,
        digitalBreachExposure,
        digitalDeviceSecurity,
        digitalOversharing,
      ]);

  double get overallRiskScore {
    final normalized =
        (insuranceNorm + climateNorm + financialNorm + crimeNorm + digitalNorm) /
            5.0;
    return RiskScore.fromNorm(normalized);
  }

  double get healthRiskScore => RiskScore.fromNorm(insuranceNorm);
  double get careerRiskScore => RiskScore.fromNorm(climateNorm);
  double get financialRiskScore => financialRiskResult.pointScore;

  /// Bar visualization: engine-derived share of each financial subcategory.
  List<double> get financialSubcategoryShares =>
      financialRiskResult.subcategoryShare;

  /// Per–sub-category scores on 0–1000 (for segment coloring).
  List<double> get financialSubcategoryScores =>
      financialRiskResult.subcategoryScores;
  double get personalSafetyRiskScore => RiskScore.fromNorm(crimeNorm);
  double get digitalPrivacyRiskScore => RiskScore.fromNorm(digitalNorm);

  List<DriverFactor> get topDrivers {
    const healthLabels = [
      'Chronic & acute health load',
      'Healthcare cost sensitivity',
      'Preventive care gaps',
      'Coverage & access adequacy',
    ];
    const careerLabels = [
      'Role & job security',
      'Income / bonus volatility',
      'Skills & training gap',
      'Workload & burnout',
      'Industry & market headwinds',
    ];
    final financialLabels = kFinancialAllFactorLabels;
    const safetyLabels = [
      'Neighborhood & local incidents',
      'Property / theft exposure',
      'Personal violence exposure',
    ];
    const digitalLabels = [
      'Password & MFA hygiene',
      'Phishing & scams exposure',
      'Data breach & account reuse',
      'Device & network security',
      'Oversharing & trace footprint',
    ];

    final factors = <DriverFactor>[
      for (int i = 0; i < healthLabels.length; i++)
        DriverFactor(
          label: healthLabels[i],
          level: [
            insuranceCoverageAdequacy,
            insuranceDeductibleSensitivity,
            insuranceLiabilityCoverage,
            insuranceAssetCoverage,
          ][i],
          category: RiskCategory.health,
        ),
      for (int i = 0; i < careerLabels.length; i++)
        DriverFactor(
          label: careerLabels[i],
          level: [
            climateHeat,
            climateFlood,
            climateWildfire,
            climateStorm,
            climateResilience,
          ][i],
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
          level: [
            crimeIncidentFrequency,
            crimePropertyCrime,
            crimeViolentCrime,
          ][i],
          category: RiskCategory.personalSafety,
        ),
      for (int i = 0; i < digitalLabels.length; i++)
        DriverFactor(
          label: digitalLabels[i],
          level: [
            digitalPasswordHygiene,
            digitalPhishingExposure,
            digitalBreachExposure,
            digitalDeviceSecurity,
            digitalOversharing,
          ][i],
          category: RiskCategory.digitalPrivacy,
        ),
    ];

    factors.sort((a, b) => b.level.compareTo(a.level));
    return factors.take(6).toList();
  }

  void setFinancialFactor(int index, int level) {
    if (index < 0 || index >= financialFactorLevels.length) return;
    financialFactorLevels[index] = level.clamp(0, 4);
    notifyListeners();
  }

  void setInsuranceFactor(int index, int level) {
    final v = level.clamp(0, 4);
    switch (index) {
      case 0:
        insuranceCoverageAdequacy = v;
        break;
      case 1:
        insuranceDeductibleSensitivity = v;
        break;
      case 2:
        insuranceLiabilityCoverage = v;
        break;
      case 3:
        insuranceAssetCoverage = v;
        break;
    }
    notifyListeners();
  }

  void setCrimeFactor(int index, int level) {
    final v = level.clamp(0, 4);
    switch (index) {
      case 0:
        crimeIncidentFrequency = v;
        break;
      case 1:
        crimePropertyCrime = v;
        break;
      case 2:
        crimeViolentCrime = v;
        break;
    }
    notifyListeners();
  }

  void setClimateFactor(int index, int level) {
    final v = level.clamp(0, 4);
    switch (index) {
      case 0:
        climateHeat = v;
        break;
      case 1:
        climateFlood = v;
        break;
      case 2:
        climateWildfire = v;
        break;
      case 3:
        climateStorm = v;
        break;
      case 4:
        climateResilience = v;
        break;
    }
    notifyListeners();
  }

  void setDigitalFactor(int index, int level) {
    final v = level.clamp(0, 4);
    switch (index) {
      case 0:
        digitalPasswordHygiene = v;
        break;
      case 1:
        digitalPhishingExposure = v;
        break;
      case 2:
        digitalBreachExposure = v;
        break;
      case 3:
        digitalDeviceSecurity = v;
        break;
      case 4:
        digitalOversharing = v;
        break;
    }
    notifyListeners();
  }

  void setCrimeLocationInput(String value) {
    crimeLocationInput = value;
    notifyListeners();
  }
}
