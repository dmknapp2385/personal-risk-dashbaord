import 'package:flutter/material.dart';

import '../../data/risk_help_text.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class CareerTab extends StatelessWidget {
  const CareerTab({
    super.key,
    required this.careerLevels,
    required this.onCareerFactorChanged,
    required this.overallScore,
  });

  final List<int> careerLevels;
  final void Function(int index, int level) onCareerFactorChanged;
  final double overallScore;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const _factorLabels = [
    'Role & job security',
    'Income / bonus volatility',
    'Skills & training gap',
    'Workload & burnout',
    'Industry & market headwinds',
  ];

  @override
  Widget build(BuildContext context) {
    final slices = categorySlicesFromFactors(_factorLabels, careerLevels);

    return ListView(
      children: [
        SizedBox(
          width: double.infinity,
          child: CategoryTabOverviewHeader(
            overviewTitle: 'Career overview',
            overallLabel: 'Overall career risk',
            overallScore: overallScore,
            slices: slices,
            scaleLabels: _scaleLabels,
            barCaption:
                'Each band is one topic below (equal width; hover for your level · colors match sliders)',
          ),
        ),
        const SizedBox(height: 20),
        CategorySection(
          title: 'Career',
          icon: Icons.work_outline,
          factorLabels: _factorLabels,
          levels: careerLevels,
          onLevelChanged: onCareerFactorChanged,
          scaleLabels: _scaleLabels,
          titleHelp: RiskHelpText.subcategory('Career'),
          factorHelps:
              _factorLabels.map((l) => RiskHelpText.factor(l)).toList(),
        ),
      ],
    );
  }
}
