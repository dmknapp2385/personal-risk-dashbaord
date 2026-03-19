import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';

void main() {
  runApp(const RiskDashboardApp());
}

class RiskDashboardApp extends StatelessWidget {
  const RiskDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalized Risk Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final normalized = (_creditNorm + _insuranceNorm + _crimeNorm + _climateNorm) / 4.0; // 0..1
    return _scoreFromNorm(normalized);
  }

  int get _creditRiskScore => _scoreFromNorm(_creditNorm);
  int get _insuranceRiskScore => _scoreFromNorm(_insuranceNorm);
  int get _crimeRiskScore => _scoreFromNorm(_crimeNorm);
  int get _climateRiskScore => _scoreFromNorm(_climateNorm);

  List<_DriverFactor> get _topDrivers {
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

    final factors = <_DriverFactor>[
      for (int i = 0; i < creditLabels.length; i++)
        _DriverFactor(
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
        _DriverFactor(
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
        _DriverFactor(
          label: crimeLabels[i],
          level: [
            _crimeIncidentFrequency,
            _crimePropertyCrime,
            _crimeViolentCrime,
          ][i],
          tabIndex: 3,
        ),
      for (int i = 0; i < climateLabels.length; i++)
        _DriverFactor(
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                        _OverallHomeTab(
                          overallScore: _overallRiskScore,
                          categoryScores: [
                            _HomeCategoryScore(
                              label: 'Credit',
                              score: _creditRiskScore,
                              tabIndex: 1,
                            ),
                            _HomeCategoryScore(
                              label: 'Insurance',
                              score: _insuranceRiskScore,
                              tabIndex: 2,
                            ),
                            _HomeCategoryScore(
                              label: 'Crime',
                              score: _crimeRiskScore,
                              tabIndex: 3,
                            ),
                            _HomeCategoryScore(
                              label: 'Climate',
                              score: _climateRiskScore,
                              tabIndex: 4,
                            ),
                          ],
                          topDrivers: _topDrivers,
                        ),
                        _CreditTab(
                          creditLevels: [
                            _creditDebtToIncome,
                            _creditUtilization,
                            _creditDelinquencies,
                            _creditPaymentStability,
                            _creditIncomeStability,
                          ],
                          onCreditFactorChanged: _setCreditFactor,
                        ),
                        _InsuranceTab(
                          insuranceLevels: [
                            _insuranceCoverageAdequacy,
                            _insuranceDeductibleSensitivity,
                            _insuranceLiabilityCoverage,
                            _insuranceAssetCoverage,
                          ],
                          onInsuranceFactorChanged: _setInsuranceFactor,
                        ),
                        _CrimeTab(
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
                        _ClimateTab(
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

class _OverallRiskCard extends StatelessWidget {
  const _OverallRiskCard({required this.score});

  final int score;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => (score - 1) / (1000 - 1); // 0..1

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  String get _label {
    if (score <= 200) return 'Very Low';
    if (score <= 400) return 'Low';
    if (score <= 600) return 'Moderate';
    if (score <= 800) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = _t;
    final riskColor = _riskColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              riskColor.withOpacity(0.22),
              cs.surfaceContainerHighest,
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Risk Score',
                  style: theme.textTheme.titleLarge,
                ),
                Chip(
                  label: Text(_label),
                  backgroundColor: riskColor.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    ' / 1000',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: t,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              backgroundColor: cs.outlineVariant.withOpacity(0.35),
            ),
            const SizedBox(height: 8),
            Text(
              '1 = very low risk (green) • 1000 = very high risk (red)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoryScore {
  const _HomeCategoryScore({
    required this.label,
    required this.score,
    required this.tabIndex,
  });

  final String label;
  final int score;
  final int tabIndex;
}

class _CategoryMiniRiskBar extends StatelessWidget {
  const _CategoryMiniRiskBar({
    required this.label,
    required this.score,
    required this.tabIndex,
  });

  final String label;
  final int score;
  final int tabIndex;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => (score - 1) / (1000 - 1); // 0..1

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    void go() {
      DefaultTabController.of(context).animateTo(
        tabIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    return InkWell(
      onTap: go,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '$score/1000',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _riskColor.withOpacity(0.16 + 0.65 * _t),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _riskColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallHomeTab extends StatelessWidget {
  const _OverallHomeTab({
    required this.overallScore,
    required this.categoryScores,
    required this.topDrivers,
  });

  final int overallScore;
  final List<_HomeCategoryScore> categoryScores;
  final List<_DriverFactor> topDrivers;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _OverallRiskCard(score: overallScore),
        const SizedBox(height: 16),
        Text(
          'Quick category snapshot (tap to edit)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            for (final c in categoryScores)
              _CategoryMiniRiskBar(
                label: c.label,
                score: c.score,
                tabIndex: c.tabIndex,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Top drivers (mock)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final d in topDrivers)
              _TopDriverChip(driver: d),
          ],
        ),
      ],
    );
  }
}

class _DriverFactor {
  const _DriverFactor({
    required this.label,
    required this.level,
    required this.tabIndex,
  });

  final String label;
  final int level; // 0..4
  final int tabIndex;
}

class _TopDriverChip extends StatelessWidget {
  const _TopDriverChip({required this.driver});

  final _DriverFactor driver;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => driver.level.clamp(0, 4) / 4.0;
  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tabLabel = _scaleLabels[driver.level.clamp(0, 4)];

    return InkWell(
      onTap: () {
        DefaultTabController.of(context).animateTo(
          driver.tabIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _riskColor.withOpacity(0.35)),
        ),
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driver.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _riskColor.withOpacity(0.18 + 0.65 * _t),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _riskColor.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impact: $tabLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionnaireCard extends StatelessWidget {
  const _QuestionnaireCard({
    required this.crimeLocationInput,
    required this.creditLevels,
    required this.insuranceLevels,
    required this.crimeLevels,
    required this.climateLevels,
    required this.onCrimeLocationChanged,
    required this.onCreditFactorChanged,
    required this.onInsuranceFactorChanged,
    required this.onCrimeFactorChanged,
    required this.onClimateFactorChanged,
  });

  final String crimeLocationInput;
  final List<int> creditLevels;
  final List<int> insuranceLevels;
  final List<int> crimeLevels;
  final List<int> climateLevels;
  final ValueChanged<String> onCrimeLocationChanged;
  final void Function(int index, int level) onCreditFactorChanged;
  final void Function(int index, int level) onInsuranceFactorChanged;
  final void Function(int index, int level) onCrimeFactorChanged;
  final void Function(int index, int level) onClimateFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Questionnaire (Mock)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Answer a few questions. Each sub-category contributes to the overall 1–1000 score, and the mini bars show the impact by factor.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _LocationRow(
              value: crimeLocationInput,
              onChanged: onCrimeLocationChanged,
            ),
            const SizedBox(height: 16),
            _CategorySection(
              title: 'Credit risk',
              icon: Icons.account_balance_wallet_outlined,
              factorLabels: creditLabels,
              levels: creditLevels,
              onLevelChanged: onCreditFactorChanged,
              scaleLabels: _scaleLabels,
            ),
            const SizedBox(height: 12),
            _CategorySection(
              title: 'Insurance gaps',
              icon: Icons.shield_outlined,
              factorLabels: insuranceLabels,
              levels: insuranceLevels,
              onLevelChanged: onInsuranceFactorChanged,
              scaleLabels: _scaleLabels,
            ),
            const SizedBox(height: 12),
            _CategorySection(
              title: 'Crime trends',
              icon: Icons.security_outlined,
              factorLabels: crimeLabels,
              levels: crimeLevels,
              onLevelChanged: onCrimeFactorChanged,
              scaleLabels: _scaleLabels,
            ),
            const SizedBox(height: 12),
            _CategorySection(
              title: 'Climate exposure',
              icon: Icons.public_outlined,
              factorLabels: climateLabels,
              levels: climateLevels,
              onLevelChanged: onClimateFactorChanged,
              scaleLabels: _scaleLabels,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatefulWidget {
  const _LocationRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_LocationRow> createState() => _LocationRowState();
}

class _LocationRowState extends State<_LocationRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant _LocationRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (for crime assessment later)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Example: 94110, San Francisco, CA',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _CreditTab extends StatelessWidget {
  const _CreditTab({
    required this.creditLevels,
    required this.onCreditFactorChanged,
  });

  final List<int> creditLevels;
  final void Function(int index, int level) onCreditFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Debt-to-income',
      'Utilization',
      'Delinquencies',
      'Payment stability',
      'Income stability',
    ];

    return ListView(
      children: [
        _CategorySection(
          title: 'Credit risk',
          icon: Icons.account_balance_wallet_outlined,
          factorLabels: factorLabels,
          levels: creditLevels,
          onLevelChanged: onCreditFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  const _InsuranceTab({
    required this.insuranceLevels,
    required this.onInsuranceFactorChanged,
  });

  final List<int> insuranceLevels;
  final void Function(int index, int level) onInsuranceFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Coverage adequacy',
      'Deductible sensitivity',
      'Liability coverage',
      'Asset coverage',
    ];

    return ListView(
      children: [
        _CategorySection(
          title: 'Insurance gaps',
          icon: Icons.shield_outlined,
          factorLabels: factorLabels,
          levels: insuranceLevels,
          onLevelChanged: onInsuranceFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

class _CrimeTab extends StatelessWidget {
  const _CrimeTab({
    required this.crimeLocationInput,
    required this.crimeLevels,
    required this.onCrimeLocationChanged,
    required this.onCrimeFactorChanged,
  });

  final String crimeLocationInput;
  final List<int> crimeLevels;
  final ValueChanged<String> onCrimeLocationChanged;
  final void Function(int index, int level) onCrimeFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Incident frequency',
      'Property crime',
      'Violent crime',
    ];

    return ListView(
      children: [
        _LocationRow(
          value: crimeLocationInput,
          onChanged: onCrimeLocationChanged,
        ),
        const SizedBox(height: 16),
        _CategorySection(
          title: 'Crime trends',
          icon: Icons.security_outlined,
          factorLabels: factorLabels,
          levels: crimeLevels,
          onLevelChanged: onCrimeFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

class _ClimateTab extends StatelessWidget {
  const _ClimateTab({
    required this.climateLevels,
    required this.onClimateFactorChanged,
  });

  final List<int> climateLevels;
  final void Function(int index, int level) onClimateFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Heat',
      'Flood',
      'Wildfire',
      'Storms',
      'Resilience',
    ];

    return ListView(
      children: [
        _CategorySection(
          title: 'Climate exposure',
          icon: Icons.public_outlined,
          factorLabels: factorLabels,
          levels: climateLevels,
          onLevelChanged: onClimateFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.factorLabels,
    required this.levels,
    required this.onLevelChanged,
    required this.scaleLabels,
  });

  final String title;
  final IconData icon;
  final List<String> factorLabels;
  final List<int> levels;
  final void Function(int index, int newLevel) onLevelChanged;
  final List<String> scaleLabels;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => levels.isEmpty ? 0 : _avgLevel / 4.0;

  double get _avgLevel {
    final sum = levels.isEmpty ? 0 : levels.reduce((a, b) => a + b);
    return sum.toDouble() / (levels.isEmpty ? 1 : levels.length);
  }

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  int get _pct => (_t * 100).round().clamp(0, 100);

  String get _impactLabel {
    if (_pct <= 19) return 'Very Low';
    if (_pct <= 39) return 'Low';
    if (_pct <= 59) return 'Moderate';
    if (_pct <= 79) return 'High';
    return 'Very High';
  }

  int get _riskScore => (1 + _t * (1000 - 1)).round().clamp(1, 1000);

  String get _riskLabel {
    final score = _riskScore;
    if (score <= 200) return 'Very Low';
    if (score <= 400) return 'Low';
    if (score <= 600) return 'Moderate';
    if (score <= 800) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final barColor = _riskColor.withOpacity(0.28);
    final outlineColor = _riskColor.withOpacity(0.55);
    final levelsSum = levels.isEmpty ? 0 : levels.reduce((a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_riskScore / 1000',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _riskColor,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(_riskLabel),
                backgroundColor: barColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Answer (mock)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < factorLabels.length; i++)
            _FactorSegmentedQuestion(
              question: factorLabels[i],
              level: levels[i],
              onLevelChanged: (newLevel) => onLevelChanged(i, newLevel),
              scaleLabels: scaleLabels,
            ),
          const SizedBox(height: 12),
          Text(
            'Impact by sub-category',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (int i = 0; i < factorLabels.length; i++)
                _MiniImpactBar(
                  label: factorLabels[i],
                  level: levels[i],
                  scaleLabels: scaleLabels,
                  contributionPct: levelsSum == 0
                      ? 0
                      : (levels[i] / levelsSum * 100).round(),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Overall category impact: $_impactLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorSegmentedQuestion extends StatelessWidget {
  const _FactorSegmentedQuestion({
    required this.question,
    required this.level,
    required this.onLevelChanged,
    required this.scaleLabels,
  });

  final String question;
  final int level;
  final ValueChanged<int> onLevelChanged;
  final List<String> scaleLabels;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  Color get _riskColor {
    final t = (level.clamp(0, 4)) / 4.0;
    return Color.lerp(_lowColor, _highColor, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: List.generate(5, (i) {
              final t = i / 4.0;
              final chipColor = Color.lerp(_lowColor, _highColor, t)!;
              final selected = level == i;
              return OutlinedButton(
                onPressed: () => onLevelChanged(i),
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected ? chipColor.withOpacity(0.14) : null,
                  side: BorderSide(
                    color: chipColor.withOpacity(selected ? 1.0 : 0.55),
                    width: selected ? 1.6 : 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  scaleLabels[i],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected ? chipColor : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniImpactBar extends StatelessWidget {
  const _MiniImpactBar({
    required this.label,
    required this.level,
    required this.scaleLabels,
    required this.contributionPct,
  });

  final String label;
  final int level;
  final List<String> scaleLabels;
  final int contributionPct;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final t = level.clamp(0, 4) / 4.0;
    final riskColor = Color.lerp(_lowColor, _highColor, t)!;

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.18 + 0.65 * t),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: riskColor.withOpacity(0.65),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${scaleLabels[level.clamp(0, 4)]} • ${contributionPct}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreNotesCard extends StatelessWidget {
  const _ScoreNotesCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How the mock score is calculated',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a UI mock for now: the score is computed from your questionnaire answers. Each category averages its sub-factors, then the four categories are weighted equally (for now). Location is captured for later auto-prefill, but not yet used in the scoring.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Current score: $score',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.surfaceContainerHighest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar_outlined, color: cs.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.headlineSmall),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 14),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskGrid extends StatelessWidget {
  const _RiskGrid({required this.children, required this.isWide});
  final List<Widget> children;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 3 : 1;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.7 : 2.6,
      children: children,
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...items.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(t)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
