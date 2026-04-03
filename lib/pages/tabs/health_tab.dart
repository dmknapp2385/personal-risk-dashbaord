import 'package:flutter/material.dart';

import '../../data/risk_help_text.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class HealthTab extends StatelessWidget {
  const HealthTab({
    super.key,
    required this.healthLevels,
    required this.onHealthFactorChanged,
    required this.overallScore,
  });

  final List<int> healthLevels;
  final void Function(int index, int level) onHealthFactorChanged;
  final double overallScore;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const _factorLabels = [
    'Chronic & acute health load',
    'Healthcare cost sensitivity',
    'Preventive care gaps',
    'Coverage & access adequacy',
  ];

  @override
  Widget build(BuildContext context) {
    final slices = categorySlicesFromFactors(_factorLabels, healthLevels);

    return ListView(
      children: [
        SizedBox(
          width: double.infinity,
          child: CategoryTabOverviewHeader(
            overviewTitle: 'Health overview',
            overallLabel: 'Overall health risk',
            overallScore: overallScore,
            slices: slices,
            scaleLabels: _scaleLabels,
            barCaption:
                'Each band is one topic below (equal width; hover for your level · colors match sliders)',
          ),
        ),
        const SizedBox(height: 20),
        CategorySection(
          title: 'Health',
          icon: Icons.health_and_safety_outlined,
          factorLabels: _factorLabels,
          levels: healthLevels,
          onLevelChanged: onHealthFactorChanged,
          scaleLabels: _scaleLabels,
          titleHelp: RiskHelpText.subcategory('Health'),
          factorHelps:
              _factorLabels.map((l) => RiskHelpText.factor(l)).toList(),
        ),
      ],
    );
  }
}
