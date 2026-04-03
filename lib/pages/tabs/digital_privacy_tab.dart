import 'package:flutter/material.dart';

import '../../data/risk_help_text.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class DigitalPrivacyTab extends StatelessWidget {
  const DigitalPrivacyTab({
    super.key,
    required this.digitalLevels,
    required this.onDigitalFactorChanged,
    required this.overallScore,
  });

  final List<int> digitalLevels;
  final void Function(int index, int level) onDigitalFactorChanged;
  final double overallScore;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const _factorLabels = [
    'Password & MFA hygiene',
    'Phishing & scams exposure',
    'Data breach & account reuse',
    'Device & network security',
    'Oversharing & trace footprint',
  ];

  @override
  Widget build(BuildContext context) {
    final slices = categorySlicesFromFactors(_factorLabels, digitalLevels);

    return ListView(
      children: [
        SizedBox(
          width: double.infinity,
          child: CategoryTabOverviewHeader(
            overviewTitle: 'Digital / Privacy overview',
            overallLabel: 'Overall digital & privacy risk',
            overallScore: overallScore,
            slices: slices,
            scaleLabels: _scaleLabels,
            barCaption:
                'Each band is one topic below (equal width; hover for your level · colors match sliders)',
          ),
        ),
        const SizedBox(height: 20),
        CategorySection(
          title: 'Digital / Privacy',
          icon: Icons.lock_outline,
          factorLabels: _factorLabels,
          levels: digitalLevels,
          onLevelChanged: onDigitalFactorChanged,
          scaleLabels: _scaleLabels,
          titleHelp: RiskHelpText.subcategory('Digital / Privacy'),
          factorHelps:
              _factorLabels.map((l) => RiskHelpText.factor(l)).toList(),
        ),
      ],
    );
  }
}
