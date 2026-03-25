import 'package:flutter/material.dart';

import '../widgets/category_section.dart';
import '../widgets/location_row.dart';

class PersonalSafetyTab extends StatelessWidget {
  const PersonalSafetyTab({
    super.key,
    required this.locationInput,
    required this.safetyLevels,
    required this.onLocationChanged,
    required this.onSafetyFactorChanged,
  });

  final String locationInput;
  final List<int> safetyLevels;
  final ValueChanged<String> onLocationChanged;
  final void Function(int index, int level) onSafetyFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Neighborhood & local incidents',
      'Property / theft exposure',
      'Personal violence exposure',
    ];

    return ListView(
      children: [
        LocationRow(
          value: locationInput,
          onChanged: onLocationChanged,
        ),
        const SizedBox(height: 16),
        CategorySection(
          title: 'Personal Safety',
          icon: Icons.security_outlined,
          factorLabels: factorLabels,
          levels: safetyLevels,
          onLevelChanged: onSafetyFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}
