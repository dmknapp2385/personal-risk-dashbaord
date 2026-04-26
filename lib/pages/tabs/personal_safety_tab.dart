import 'package:flutter/material.dart';

import '../../data/personal_safety_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/personal_safety_risk_types.dart';
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
    required this.safetyDetail,
  });

  final String locationInput;
  final List<int> safetyLevels;
  final ValueChanged<String> onLocationChanged;
  final void Function(int index, int level) onSafetyFactorChanged;
  final PersonalSafetyRiskResult safetyDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.location_city_outlined,
    Icons.home_work_outlined,
    Icons.warning_amber_outlined,
    Icons.flight_takeoff_outlined,
    Icons.emergency_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      safetyLevels.length == kPersonalSafetyFactorCount,
      'safetyLevels.length (${safetyLevels.length}) != $kPersonalSafetyFactorCount',
    );
    assert(
      safetyDetail.subcategoryShare.length ==
          kPersonalSafetySubcategoryDefs.length,
    );
    assert(
      safetyDetail.subcategoryScores.length ==
          kPersonalSafetySubcategoryDefs.length,
    );

    final barSlices = engineBarSlicesOmittingAllZeroSubcategories(
      factorLevelsFlat: safetyLevels,
      engineSubShares: safetyDetail.subcategoryShare,
      subScores: safetyDetail.subcategoryScores,
      sectionTitles: [for (final d in kPersonalSafetySubcategoryDefs) d.title],
      sectionFactorLabels: [
        for (final d in kPersonalSafetySubcategoryDefs) d.factorLabels,
      ],
    );

    final children = <Widget>[
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
          overallScore: safetyDetail.pointScore,
          slices: barSlices,
          scaleLabels: _scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kPersonalSafetySubcategoryDefs.length; s++) {
      final def = kPersonalSafetySubcategoryDefs[s];
      final n = def.factorLabels.length;
      final sectionBase = offset;
      if (s > 0) {
        children.add(const SizedBox(height: 12));
      }
      children.add(
        CategorySection(
          title: def.title,
          icon: _sectionIcons[s],
          factorLabels: def.factorLabels,
          levels: safetyLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              onSafetyFactorChanged(sectionBase + i, level),
          scaleLabels: _scaleLabels,
          titleHelp: RiskHelpText.subcategory(def.title),
          factorHelps: def.factorLabels
              .map((l) => RiskHelpText.factor(l))
              .toList(),
        ),
      );
      offset += n;
    }

    return ListView(children: children);
  }
}
