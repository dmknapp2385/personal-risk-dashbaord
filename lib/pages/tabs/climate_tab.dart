import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class ClimateTab extends StatelessWidget {
  const ClimateTab({
    super.key,
    required this.climateLevels,
    required this.onClimateFactorChanged,
  });

  final List<int> climateLevels;
  final void Function(int index, int level) onClimateFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Heat',
      'Flood',
      'Wildfire',
      'Storms',
      'Resilience',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Climate exposure',
          icon: Icons.public_outlined,
          factorLabels: factorLabels,
          levels: climateLevels,
          onLevelChanged: onClimateFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

