import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class DigitalPrivacyTab extends StatelessWidget {
  const DigitalPrivacyTab({
    super.key,
    required this.digitalLevels,
    required this.onDigitalFactorChanged,
  });

  final List<int> digitalLevels;
  final void Function(int index, int level) onDigitalFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Password & MFA hygiene',
      'Phishing & scams exposure',
      'Data breach & account reuse',
      'Device & network security',
      'Oversharing & trace footprint',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Digital / Privacy',
          icon: Icons.lock_outline,
          factorLabels: factorLabels,
          levels: digitalLevels,
          onLevelChanged: onDigitalFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}
