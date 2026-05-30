import 'package:flutter/material.dart';

import '../../data/health_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/health_risk_types.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class HealthTab extends StatelessWidget {
  const HealthTab({
    super.key,
    required this.healthLevels,
    required this.onHealthFactorChanged,
    required this.healthDetail,
  });

  final List<double> healthLevels;
  final void Function(int index, double level) onHealthFactorChanged;
  final HealthRiskResult healthDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.favorite_outline,
    Icons.event_available_outlined,
    Icons.medical_information_outlined,
    Icons.psychology_outlined,
    Icons.family_restroom_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      healthLevels.length == kHealthFactorCount,
      'healthLevels.length (${healthLevels.length}) != $kHealthFactorCount',
    );
    assert(
      healthDetail.subcategoryShare.length == kHealthSubcategoryDefs.length,
    );
    assert(
      healthDetail.subcategoryScores.length == kHealthSubcategoryDefs.length,
    );

    final barSlices = engineBarSlicesOmittingAllZeroSubcategories(
      factorLevelsFlat: healthLevels,
      engineSubShares: healthDetail.subcategoryShare,
      subScores: healthDetail.subcategoryScores,
      sectionTitles: [for (final d in kHealthSubcategoryDefs) d.title],
      sectionFactorLabels: [for (final d in kHealthSubcategoryDefs) d.factorLabels],
    );

    final children = <Widget>[
      SizedBox(
        width: double.infinity,
        child: CategoryTabOverviewHeader(
          overviewTitle: 'Health overview',
          overallLabel: 'Overall health risk',
          overallScore: healthDetail.pointScore,
          slices: barSlices,
          scaleLabels: _scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kHealthSubcategoryDefs.length; s++) {
      final def = kHealthSubcategoryDefs[s];
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
          levels: healthLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              onHealthFactorChanged(sectionBase + i, level),
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
