import 'package:flutter/material.dart';

import '../../data/risk_help_text.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';
import '../widgets/location_row.dart';

class PersonalSafetyTab extends StatelessWidget {
  const PersonalSafetyTab({
    super.key,
    required this.locationInput,
    required this.safetyLevels,
    required this.onLocationChanged,
    required this.onSafetyFactorChanged,
    required this.overallScore,
  });

  final String locationInput;
  final List<int> safetyLevels;
  final ValueChanged<String> onLocationChanged;
  final void Function(int index, int level) onSafetyFactorChanged;
  final double overallScore;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const _factorLabels = [
    'Neighborhood & local incidents',
    'Property / theft exposure',
    'Personal violence exposure',
  ];

  @override
  Widget build(BuildContext context) {
    final slices = categorySlicesFromFactors(_factorLabels, safetyLevels);

    return ListView(
      children: [
        LocationRow(
          value: locationInput,
          onChanged: onLocationChanged,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CategoryTabOverviewHeader(
            overviewTitle: 'Personal Safety overview',
            overallLabel: 'Overall personal safety risk',
            overallScore: overallScore,
            slices: slices,
            scaleLabels: _scaleLabels,
            barCaption:
                'Each band is one topic below (equal width; hover for your level · colors match sliders)',
          ),
        ),
        const SizedBox(height: 20),
        CategorySection(
          title: 'Personal Safety',
          icon: Icons.security_outlined,
          factorLabels: _factorLabels,
          levels: safetyLevels,
          onLevelChanged: onSafetyFactorChanged,
          scaleLabels: _scaleLabels,
          titleHelp: RiskHelpText.subcategory('Personal Safety'),
          factorHelps:
              _factorLabels.map((l) => RiskHelpText.factor(l)).toList(),
        ),
      ],
    );
  }
}
