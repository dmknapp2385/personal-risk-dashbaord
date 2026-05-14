import 'package:flutter/material.dart';

import '../../data/digital_privacy_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/digital_privacy_risk_types.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class DigitalPrivacyTab extends StatelessWidget {
  const DigitalPrivacyTab({
    super.key,
    required this.digitalLevels,
    required this.onDigitalFactorChanged,
    required this.digitalDetail,
  });

  final List<double> digitalLevels;
  final void Function(int index, double level) onDigitalFactorChanged;
  final DigitalPrivacyRiskResult digitalDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.key_outlined,
    Icons.report_gmailerrorred_outlined,
    Icons.cloud_off_outlined,
    Icons.devices_outlined,
    Icons.visibility_off_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      digitalLevels.length == kDigitalPrivacyFactorCount,
      'digitalLevels.length (${digitalLevels.length}) != $kDigitalPrivacyFactorCount',
    );
    assert(
      digitalDetail.subcategoryShare.length ==
          kDigitalPrivacySubcategoryDefs.length,
    );
    assert(
      digitalDetail.subcategoryScores.length ==
          kDigitalPrivacySubcategoryDefs.length,
    );

    final barSlices = engineBarSlicesOmittingAllZeroSubcategories(
      factorLevelsFlat: digitalLevels,
      engineSubShares: digitalDetail.subcategoryShare,
      subScores: digitalDetail.subcategoryScores,
      sectionTitles: [for (final d in kDigitalPrivacySubcategoryDefs) d.title],
      sectionFactorLabels: [
        for (final d in kDigitalPrivacySubcategoryDefs) d.factorLabels,
      ],
    );

    final children = <Widget>[
      SizedBox(
        width: double.infinity,
        child: CategoryTabOverviewHeader(
          overviewTitle: 'Digital / Privacy overview',
          overallLabel: 'Overall digital & privacy risk',
          overallScore: digitalDetail.pointScore,
          slices: barSlices,
          scaleLabels: _scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kDigitalPrivacySubcategoryDefs.length; s++) {
      final def = kDigitalPrivacySubcategoryDefs[s];
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
          levels: digitalLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              onDigitalFactorChanged(sectionBase + i, level),
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
