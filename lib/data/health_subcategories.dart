class HealthSubcategoryDef {
  const HealthSubcategoryDef({
    required this.title,
    required this.factorLabels,
  });

  final String title;
  final List<String> factorLabels;
}

const List<HealthSubcategoryDef> kHealthSubcategoryDefs = [
  HealthSubcategoryDef(
    title: 'Physical health burden',
    factorLabels: [
      'Chronic or acute conditions you manage',
      'Day-to-day pain, fatigue, or symptoms',
      'Sleep quality and energy most weeks',
    ],
  ),
  HealthSubcategoryDef(
    title: 'Prevention & access',
    factorLabels: [
      'Preventive care and screenings you skip or delay',
      'Wait times, referrals, or specialist access',
      'Distance, cost, or logistics blocking care',
    ],
  ),
  HealthSubcategoryDef(
    title: 'Costs & coverage',
    factorLabels: [
      'Sensitivity to a large medical bill',
      'Gaps in insurance vs. what you might need',
      'Prescription and ongoing treatment affordability',
    ],
  ),
  HealthSubcategoryDef(
    title: 'Mental load & behavior',
    factorLabels: [
      'Stress, anxiety, or low mood impact on life',
      'Habits that could affect health (sleep, substance, etc.)',
      'Social support when things get hard',
    ],
  ),
  HealthSubcategoryDef(
    title: 'Dependents & caregiving',
    factorLabels: [
      'Health needs of children or elders you support',
      'Caregiving time and burnout risk',
      'Coverage and planning for dependents’ care',
    ],
  ),
];

int get kHealthFactorCount => kHealthSubcategoryDefs.fold<int>(
      0,
      (sum, d) => sum + d.factorLabels.length,
    );

List<String> get kHealthAllFactorLabels => [
      for (final d in kHealthSubcategoryDefs) ...d.factorLabels,
    ];

const List<double> kHealthSubcategoryWeights = [
  1.18,
  1.12,
  1.20,
  1.08,
  1.10,
];

const List<List<double>> kHealthFactorWeightPriors = [
  [1.12, 1.18, 1.08],
  [1.10, 1.14, 1.12],
  [1.20, 1.15, 1.10],
  [1.14, 1.08, 1.12],
  [1.16, 1.20, 1.06],
];
