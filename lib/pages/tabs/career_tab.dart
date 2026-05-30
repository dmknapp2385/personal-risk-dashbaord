import 'package:flutter/material.dart';

import '../../data/career_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/career_risk_types.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class CareerTab extends StatelessWidget {
  const CareerTab({
    super.key,
    required this.careerLevels,
    required this.onCareerFactorChanged,
    required this.careerDetail,
  });

  final List<double> careerLevels;
  final void Function(int index, double level) onCareerFactorChanged;
  final CareerRiskResult careerDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.badge_outlined,
    Icons.payments_outlined,
    Icons.school_outlined,
    Icons.schedule_outlined,
    Icons.public_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      careerLevels.length == kCareerFactorCount,
      'careerLevels.length (${careerLevels.length}) != $kCareerFactorCount',
    );
    assert(
      careerDetail.subcategoryShare.length == kCareerSubcategoryDefs.length,
    );
    assert(
      careerDetail.subcategoryScores.length == kCareerSubcategoryDefs.length,
    );

    final barSlices = engineBarSlicesOmittingAllZeroSubcategories(
      factorLevelsFlat: careerLevels,
      engineSubShares: careerDetail.subcategoryShare,
      subScores: careerDetail.subcategoryScores,
      sectionTitles: [for (final d in kCareerSubcategoryDefs) d.title],
      sectionFactorLabels: [for (final d in kCareerSubcategoryDefs) d.factorLabels],
    );

    final children = <Widget>[
      SizedBox(
        width: double.infinity,
        child: CategoryTabOverviewHeader(
          overviewTitle: 'Career overview',
          overallLabel: 'Overall career risk',
          overallScore: careerDetail.pointScore,
          slices: barSlices,
          scaleLabels: _scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kCareerSubcategoryDefs.length; s++) {
      final def = kCareerSubcategoryDefs[s];
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
          levels: careerLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              onCareerFactorChanged(sectionBase + i, level),
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
