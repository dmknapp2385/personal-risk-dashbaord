/// Digital / privacy questionnaire structure (same role as financial defs).
class DigitalPrivacySubcategoryDef {
  const DigitalPrivacySubcategoryDef({
    required this.title,
    required this.factorLabels,
  });

  final String title;
  final List<String> factorLabels;
}

const List<DigitalPrivacySubcategoryDef> kDigitalPrivacySubcategoryDefs = [
  DigitalPrivacySubcategoryDef(
    title: 'Identity & authentication',
    factorLabels: [
      'Password & MFA strength',
      'Recovery & backup codes',
      'Shared or reused credentials',
    ],
  ),
  DigitalPrivacySubcategoryDef(
    title: 'Phishing & social engineering',
    factorLabels: [
      'Email & SMS phishing exposure',
      'Phone & voice scam exposure',
      'Urgency or impersonation attempts',
    ],
  ),
  DigitalPrivacySubcategoryDef(
    title: 'Data exposure & account hygiene',
    factorLabels: [
      'Breach history & leaked passwords',
      'Cross-site password reuse',
      'Sensitive data in email or storage',
    ],
  ),
  DigitalPrivacySubcategoryDef(
    title: 'Devices & networks',
    factorLabels: [
      'Device lock & encryption',
      'Software updates & patching',
      'Public Wi‑Fi & untrusted networks',
    ],
  ),
  DigitalPrivacySubcategoryDef(
    title: 'Privacy & footprint',
    factorLabels: [
      'Social & public oversharing',
      'Location & tracking exposure',
      'Third‑party app permissions',
    ],
  ),
];

int get kDigitalPrivacyFactorCount => kDigitalPrivacySubcategoryDefs.fold<int>(
      0,
      (sum, d) => sum + d.factorLabels.length,
    );

List<String> get kDigitalPrivacyAllFactorLabels => [
      for (final d in kDigitalPrivacySubcategoryDefs) ...d.factorLabels,
    ];

/// Prior relative importance of each subcategory (normalized in adaptive state).
const List<double> kDigitalPrivacySubcategoryWeights = [
  1.20, // identity & authentication
  1.15, // phishing & social engineering
  1.18, // data exposure & account hygiene
  1.08, // devices & networks
  1.02, // privacy & footprint
];

/// Prior factor weights within each subcategory (same order as [factorLabels]).
const List<List<double>> kDigitalPrivacyFactorWeightPriors = [
  [1.15, 1.05, 1.20],
  [1.12, 1.18, 1.10],
  [1.20, 1.22, 1.05],
  [1.10, 1.15, 1.08],
  [1.08, 1.12, 1.05],
];
