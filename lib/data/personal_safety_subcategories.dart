class PersonalSafetySubcategoryDef {
  const PersonalSafetySubcategoryDef({
    required this.title,
    required this.factorLabels,
  });

  final String title;
  final List<String> factorLabels;
}

const List<PersonalSafetySubcategoryDef> kPersonalSafetySubcategoryDefs = [
  PersonalSafetySubcategoryDef(
    title: 'Neighborhood & everyday exposure',
    factorLabels: [
      'Local crime, disorder, or safety where you live',
      'Routine outings (shops, transit, evenings out)',
      'Sense of safety walking alone in your area',
    ],
  ),
  PersonalSafetySubcategoryDef(
    title: 'Property & theft',
    factorLabels: [
      'Home break-in or burglary concern',
      'Vehicle theft or vandalism',
      'Packages, bikes, or storage security',
    ],
  ),
  PersonalSafetySubcategoryDef(
    title: 'Personal violence & conflict',
    factorLabels: [
      'Risk of assault, harassment, or targeted harm',
      'Safety in workplaces or schools you use',
      'Conflict or coercion in close relationships (self-assessed)',
    ],
  ),
  PersonalSafetySubcategoryDef(
    title: 'Travel & unfamiliar places',
    factorLabels: [
      'Work travel or unfamiliar cities',
      'Late-night or isolated routes',
      'Large crowds or events',
    ],
  ),
  PersonalSafetySubcategoryDef(
    title: 'Awareness & readiness',
    factorLabels: [
      'How prepared you feel for an emergency',
      'Communication plan with household',
      'Lighting, locks, and basic security habits',
    ],
  ),
];

int get kPersonalSafetyFactorCount =>
    kPersonalSafetySubcategoryDefs.fold<int>(
      0,
      (sum, d) => sum + d.factorLabels.length,
    );

List<String> get kPersonalSafetyAllFactorLabels => [
      for (final d in kPersonalSafetySubcategoryDefs) ...d.factorLabels,
    ];

const List<double> kPersonalSafetySubcategoryWeights = [
  1.15,
  1.12,
  1.22,
  1.08,
  1.05,
];

const List<List<double>> kPersonalSafetyFactorWeightPriors = [
  [1.14, 1.12, 1.16],
  [1.18, 1.12, 1.10],
  [1.22, 1.18, 1.20],
  [1.10, 1.14, 1.08],
  [1.08, 1.06, 1.10],
];
