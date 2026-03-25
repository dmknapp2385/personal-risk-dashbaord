import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class HealthTab extends StatelessWidget {
  const HealthTab({
    super.key,
    required this.healthLevels,
    required this.onHealthFactorChanged,
  });

  final List<int> healthLevels;
  final void Function(int index, int level) onHealthFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Chronic & acute health load',
      'Healthcare cost sensitivity',
      'Preventive care gaps',
      'Coverage & access adequacy',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Health',
          icon: Icons.health_and_safety_outlined,
          factorLabels: factorLabels,
          levels: healthLevels,
          onLevelChanged: onHealthFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}
