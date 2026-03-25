import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class CareerTab extends StatelessWidget {
  const CareerTab({
    super.key,
    required this.careerLevels,
    required this.onCareerFactorChanged,
  });

  final List<int> careerLevels;
  final void Function(int index, int level) onCareerFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Role & job security',
      'Income / bonus volatility',
      'Skills & training gap',
      'Workload & burnout',
      'Industry & market headwinds',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Career',
          icon: Icons.work_outline,
          factorLabels: factorLabels,
          levels: careerLevels,
          onLevelChanged: onCareerFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}
