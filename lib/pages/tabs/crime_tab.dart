import 'package:flutter/material.dart';

import '../widgets/category_section.dart';
import '../widgets/location_row.dart';

class CrimeTab extends StatelessWidget {
  const CrimeTab({
    super.key,
    required this.crimeLocationInput,
    required this.crimeLevels,
    required this.onCrimeLocationChanged,
    required this.onCrimeFactorChanged,
  });

  final String crimeLocationInput;
  final List<int> crimeLevels;
  final ValueChanged<String> onCrimeLocationChanged;
  final void Function(int index, int level) onCrimeFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Incident frequency',
      'Property crime',
      'Violent crime',
    ];

    return ListView(
      children: [
        LocationRow(
          value: crimeLocationInput,
          onChanged: onCrimeLocationChanged,
        ),
        const SizedBox(height: 16),
        CategorySection(
          title: 'Crime trends',
          icon: Icons.security_outlined,
          factorLabels: factorLabels,
          levels: crimeLevels,
          onLevelChanged: onCrimeFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

