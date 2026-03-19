import 'package:flutter/material.dart';

import '../models/driver_factor.dart';
import '../models/home_category_score.dart';
import 'tabs/climate_tab.dart';
import 'tabs/credit_tab.dart';
import 'tabs/crime_tab.dart';
import 'tabs/insurance_tab.dart';
import 'tabs/overall_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // MOCK questionnaire answers: each level is 0..4 where
  // 0 = very low, 4 = very high. (Later you'll replace these with real inputs.)
  int _creditDebtToIncome = 2;
  int _creditUtilization = 1;
  int _creditDelinquencies = 1;
  int _creditPaymentStability = 2;
  int _creditIncomeStability = 1;

  int _insuranceCoverageAdequacy = 2;
  int _insuranceDeductibleSensitivity = 1;
  int _insuranceLiabilityCoverage = 2;
  int _insuranceAssetCoverage = 1;

  int _crimeIncidentFrequency = 2;
  int _crimePropertyCrime = 1;
  int _crimeViolentCrime = 1;

  int _climateHeat = 2;
  int _climateFlood = 1;
  int _climateWildfire = 1;
  int _climateStorm = 2;
  int _climateResilience = 1;

  String _crimeLocationInput = '';

  double _avgNorm(List<int> levels) {
    if (levels.isEmpty) return 0;
    final sum = levels.reduce((a, b) => a + b).toDouble();
    return sum / (levels.length * 4.0); // levels are 0..4
  }

  double get _creditNorm => _avgNorm([
        _creditDebtToIncome,
        _creditUtilization,
        _creditDelinquencies,
        _creditPaymentStability,
        _creditIncomeStability,
      ]);

  double get _insuranceNorm => _avgNorm([
        _insuranceCoverageAdequacy,
        _insuranceDeductibleSensitivity,
        _insuranceLiabilityCoverage,
        _insuranceAssetCoverage,
      ]);

  double get _crimeNorm => _avgNorm([
        _crimeIncidentFrequency,
        _crimePropertyCrime,
        _crimeViolentCrime,
      ]);

  double get _climateNorm => _avgNorm([
        _climateHeat,
        _climateFlood,
        _climateWildfire,
        _climateStorm,
        _climateResilience,
      ]);

  int _scoreFromNorm(double norm) {
    final score = 1 + norm.clamp(0, 1) * (1000 - 1);
    return score.round().clamp(1, 1000);
  }

  int get _overallRiskScore {
    // MOCK composite: equal weight across all categories for now.
    final normalized =
        (_creditNorm + _insuranceNorm + _crimeNorm + _climateNorm) / 4.0; // 0..1
    return _scoreFromNorm(normalized);
  }

  int get _creditRiskScore => _scoreFromNorm(_creditNorm);
  int get _insuranceRiskScore => _scoreFromNorm(_insuranceNorm);
  int get _crimeRiskScore => _scoreFromNorm(_crimeNorm);
  int get _climateRiskScore => _scoreFromNorm(_climateNorm);

  List<DriverFactor> get _topDrivers {
    const creditLabels = [
      'Debt-to-income',
      'Utilization',
      'Delinquencies',
      'Payment stability',
      'Income stability',
    ];
    const insuranceLabels = [
      'Coverage adequacy',
      'Deductible sensitivity',
      'Liability coverage',
      'Asset coverage',
    ];
    const crimeLabels = [
      'Incident frequency',
      'Property crime',
      'Violent crime',
    ];
    const climateLabels = [
      'Heat',
      'Flood',
      'Wildfire',
      'Storms',
      'Resilience',
    ];

    final factors = <DriverFactor>[
      for (int i = 0; i < creditLabels.length; i++)
        DriverFactor(
          label: creditLabels[i],
          level: [
            _creditDebtToIncome,
            _creditUtilization,
            _creditDelinquencies,
            _creditPaymentStability,
            _creditIncomeStability,
          ][i],
          tabIndex: 1,
        ),
      for (int i = 0; i < insuranceLabels.length; i++)
        DriverFactor(
          label: insuranceLabels[i],
          level: [
            _insuranceCoverageAdequacy,
            _insuranceDeductibleSensitivity,
            _insuranceLiabilityCoverage,
            _insuranceAssetCoverage,
          ][i],
          tabIndex: 2,
        ),
      for (int i = 0; i < crimeLabels.length; i++)
        DriverFactor(
          label: crimeLabels[i],
          level: [
            _crimeIncidentFrequency,
            _crimePropertyCrime,
            _crimeViolentCrime,
          ][i],
          tabIndex: 3,
        ),
      for (int i = 0; i < climateLabels.length; i++)
        DriverFactor(
          label: climateLabels[i],
          level: [
            _climateHeat,
            _climateFlood,
            _climateWildfire,
            _climateStorm,
            _climateResilience,
          ][i],
          tabIndex: 4,
        ),
    ];

    factors.sort((a, b) => b.level.compareTo(a.level));
    return factors.take(6).toList();
  }

  void _setCreditFactor(int index, int level) {
    final v = level.clamp(0, 4);
    setState(() {
      switch (index) {
        case 0:
          _creditDebtToIncome = v;
        case 1:
          _creditUtilization = v;
        case 2:
          _creditDelinquencies = v;
        case 3:
          _creditPaymentStability = v;
        case 4:
          _creditIncomeStability = v;
        default:
      }
    });
  }

  void _setInsuranceFactor(int index, int level) {
    final v = level.clamp(0, 4);
    setState(() {
      switch (index) {
        case 0:
          _insuranceCoverageAdequacy = v;
        case 1:
          _insuranceDeductibleSensitivity = v;
        case 2:
          _insuranceLiabilityCoverage = v;
        case 3:
          _insuranceAssetCoverage = v;
        default:
      }
    });
  }

  void _setCrimeFactor(int index, int level) {
    final v = level.clamp(0, 4);
    setState(() {
      switch (index) {
        case 0:
          _crimeIncidentFrequency = v;
        case 1:
          _crimePropertyCrime = v;
        case 2:
          _crimeViolentCrime = v;
        default:
      }
    });
  }

  void _setClimateFactor(int index, int level) {
    final v = level.clamp(0, 4);
    setState(() {
      switch (index) {
        case 0:
          _climateHeat = v;
        case 1:
          _climateFlood = v;
        case 2:
          _climateWildfire = v;
        case 3:
          _climateStorm = v;
        case 4:
          _climateResilience = v;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Personalized Risk Dashboard'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: DefaultTabController(
            length: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TabBar(
                      isScrollable: true,
                      indicatorColor: cs.primary,
                      labelColor: cs.onSurface,
                      unselectedLabelColor: cs.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Overall'),
                        Tab(text: 'Credit'),
                        Tab(text: 'Insurance'),
                        Tab(text: 'Crime'),
                        Tab(text: 'Climate'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        OverallTab(
                          overallScore: _overallRiskScore,
                          categoryScores: [
                            HomeCategoryScore(
                              label: 'Credit',
                              score: _creditRiskScore,
                              tabIndex: 1,
                            ),
                            HomeCategoryScore(
                              label: 'Insurance',
                              score: _insuranceRiskScore,
                              tabIndex: 2,
                            ),
                            HomeCategoryScore(
                              label: 'Crime',
                              score: _crimeRiskScore,
                              tabIndex: 3,
                            ),
                            HomeCategoryScore(
                              label: 'Climate',
                              score: _climateRiskScore,
                              tabIndex: 4,
                            ),
                          ],
                          topDrivers: _topDrivers,
                        ),
                        CreditTab(
                          creditLevels: [
                            _creditDebtToIncome,
                            _creditUtilization,
                            _creditDelinquencies,
                            _creditPaymentStability,
                            _creditIncomeStability,
                          ],
                          onCreditFactorChanged: _setCreditFactor,
                        ),
                        InsuranceTab(
                          insuranceLevels: [
                            _insuranceCoverageAdequacy,
                            _insuranceDeductibleSensitivity,
                            _insuranceLiabilityCoverage,
                            _insuranceAssetCoverage,
                          ],
                          onInsuranceFactorChanged: _setInsuranceFactor,
                        ),
                        CrimeTab(
                          crimeLocationInput: _crimeLocationInput,
                          crimeLevels: [
                            _crimeIncidentFrequency,
                            _crimePropertyCrime,
                            _crimeViolentCrime,
                          ],
                          onCrimeLocationChanged: (v) =>
                              setState(() => _crimeLocationInput = v),
                          onCrimeFactorChanged: _setCrimeFactor,
                        ),
                        ClimateTab(
                          climateLevels: [
                            _climateHeat,
                            _climateFlood,
                            _climateWildfire,
                            _climateStorm,
                            _climateResilience,
                          ],
                          onClimateFactorChanged: _setClimateFactor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

