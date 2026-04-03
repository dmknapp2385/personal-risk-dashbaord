/// Financial risk questionnaire structure (equal weighting for now; weights TBD).
class FinancialSubcategoryDef {
  const FinancialSubcategoryDef({
    required this.title,
    required this.factorLabels,
  });

  final String title;
  final List<String> factorLabels;
}

const List<FinancialSubcategoryDef> kFinancialSubcategoryDefs = [
  FinancialSubcategoryDef(
    title: 'Liquidity and cash flow',
    factorLabels: [
      'Runway',
      'Net cash flow',
      'Cash flow volatility',
    ],
  ),
  FinancialSubcategoryDef(
    title: 'Obligations and leverage',
    factorLabels: [
      'Debt to income',
      'Debt service ratio',
      'Variable rate exposure',
      'Fixed obligations',
    ],
  ),
  FinancialSubcategoryDef(
    title: 'Asset risk',
    factorLabels: [
      'Portfolio volatility',
      'Drawdown',
      'Risky asset allocation',
    ],
  ),
  FinancialSubcategoryDef(
    title: 'Concentration risk',
    factorLabels: [
      'Income concentration',
      'Asset concentration',
      'Employer sector coupling',
    ],
  ),
  FinancialSubcategoryDef(
    title: 'Inflation and purchasing power',
    factorLabels: [
      'Real return',
      'Cash exposure',
      'Inflation mismatch',
    ],
  ),
];

int get kFinancialFactorCount => kFinancialSubcategoryDefs.fold<int>(
      0,
      (sum, d) => sum + d.factorLabels.length,
    );

List<String> get kFinancialAllFactorLabels => [
      for (final d in kFinancialSubcategoryDefs) ...d.factorLabels,
    ];

/// Prior relative importance of each subcategory (financial risk engine meta-layer
/// learns deviations from these over time). Need not sum to 1; normalized internally.
const List<double> kFinancialSubcategoryWeights = [
  1.15, // liquidity and cash flow
  1.25, // obligations and leverage
  1.10, // asset risk
  1.00, // concentration risk
  1.00, // inflation and purchasing power
];

/// Prior factor weights within each subcategory (same order as [factorLabels]).
/// The engine’s adaptive layer nudges these toward observed stress patterns.
const List<List<double>> kFinancialFactorWeightPriors = [
  [1.15, 1.05, 1.20], // liquidity: runway, cash flow, volatility
  [1.20, 1.25, 1.10, 1.05], // obligations
  [1.10, 1.20, 1.05], // asset risk
  [1.15, 1.10, 1.20], // concentration
  [1.10, 1.05, 1.15], // inflation / purchasing power
];
