import 'package:flutter/material.dart';

import '../../data/career_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/career_risk_types.dart';
import '../../models/category_overview_slice.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class CareerTab extends StatelessWidget {
  const CareerTab({
    super.key,
    required this.careerLevels,
    required this.onCareerFactorChanged,
    required this.careerDetail,
  });

  final List<int> careerLevels;
  final void Function(int index, int level) onCareerFactorChanged;
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

    final barSlices = _buildBarSlices(
      careerLevels,
      careerDetail.subcategoryShare,
      careerDetail.subcategoryScores,
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

List<CategoryOverviewBarSlice> _buildBarSlices(
  List<int> careerLevels,
  List<double> shares,
  List<double> subScores,
) {
  var offset = 0;
  final out = <CategoryOverviewBarSlice>[];
  for (var s = 0; s < kCareerSubcategoryDefs.length; s++) {
    final def = kCareerSubcategoryDefs[s];
    final n = def.factorLabels.length;
    final seg = careerLevels.sublist(offset, offset + n);
    offset += n;
    out.add(
      CategoryOverviewBarSlice(
        title: def.title,
        share: shares[s],
        riskScore: subScores[s],
        factorLabels: def.factorLabels,
        factorLevels: List<int>.from(seg),
      ),
    );
  }
  return out;
}
