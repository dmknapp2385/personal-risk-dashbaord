class CareerSubcategoryDef {
  const CareerSubcategoryDef({
    required this.title,
    required this.factorLabels,
  });

  final String title;
  final List<String> factorLabels;
}

const List<CareerSubcategoryDef> kCareerSubcategoryDefs = [
  CareerSubcategoryDef(
    title: 'Role & employment stability',
    factorLabels: [
      'Job or role security over the next year',
      'Contract end, layoff, or restructuring exposure',
      'Dependence on a single employer or client',
    ],
  ),
  CareerSubcategoryDef(
    title: 'Income & volatility',
    factorLabels: [
      'Bonus, commission, or irregular pay swings',
      'Dependence on one income stream',
      'Side work or second-job necessity',
    ],
  ),
  CareerSubcategoryDef(
    title: 'Skills & relevance',
    factorLabels: [
      'Gap between your skills and where the field is headed',
      'Training or certification you have not kept current',
      'Automation or outsourcing risk in your work',
    ],
  ),
  CareerSubcategoryDef(
    title: 'Workload & sustainability',
    factorLabels: [
      'Burnout, hours, or unsustainable pace',
      'Commute or schedule strain',
      'Fit with manager, team, or culture',
    ],
  ),
  CareerSubcategoryDef(
    title: 'Industry & external risk',
    factorLabels: [
      'Industry demand and market headwinds',
      'Regulation, licensing, or policy changes',
      'Geographic or relocation pressure for work',
    ],
  ),
];

int get kCareerFactorCount => kCareerSubcategoryDefs.fold<int>(
      0,
      (sum, d) => sum + d.factorLabels.length,
    );

List<String> get kCareerAllFactorLabels => [
      for (final d in kCareerSubcategoryDefs) ...d.factorLabels,
    ];

const List<double> kCareerSubcategoryWeights = [
  1.22,
  1.15,
  1.10,
  1.08,
  1.12,
];

const List<List<double>> kCareerFactorWeightPriors = [
  [1.20, 1.18, 1.14],
  [1.16, 1.20, 1.10],
  [1.12, 1.08, 1.18],
  [1.18, 1.10, 1.12],
  [1.14, 1.08, 1.16],
];
