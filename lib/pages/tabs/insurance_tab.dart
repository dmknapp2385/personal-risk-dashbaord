import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class InsuranceTab extends StatelessWidget {
  const InsuranceTab({
    super.key,
    required this.insuranceLevels,
    required this.onInsuranceFactorChanged,
  });

  final List<int> insuranceLevels;
  final void Function(int index, int level) onInsuranceFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Coverage adequacy',
      'Deductible sensitivity',
      'Liability coverage',
      'Asset coverage',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Insurance gaps',
          icon: Icons.shield_outlined,
          factorLabels: factorLabels,
          levels: insuranceLevels,
          onLevelChanged: onInsuranceFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

