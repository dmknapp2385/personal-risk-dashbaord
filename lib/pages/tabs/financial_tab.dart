import 'package:flutter/material.dart';

import '../../data/financial_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/financial_risk_types.dart';
import '../../models/category_overview_slice.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';

class FinancialTab extends StatelessWidget {
  const FinancialTab({
    super.key,
    required this.financialLevels,
    required this.onFinancialFactorChanged,
    required this.financialDetail,
  });

  final List<int> financialLevels;
  final void Function(int index, int level) onFinancialFactorChanged;
  final FinancialRiskResult financialDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.savings_outlined,
    Icons.receipt_long_outlined,
    Icons.stacked_line_chart_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.price_change_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      financialLevels.length == kFinancialFactorCount,
      'financialLevels.length (${financialLevels.length}) != $kFinancialFactorCount',
    );
    assert(
      financialDetail.subcategoryShare.length == kFinancialSubcategoryDefs.length,
    );
    assert(
      financialDetail.subcategoryScores.length == kFinancialSubcategoryDefs.length,
    );

    final barSlices = _buildBarSlices(
      financialLevels,
      financialDetail.subcategoryShare,
      financialDetail.subcategoryScores,
    );

    final children = <Widget>[
      SizedBox(
        width: double.infinity,
        child: CategoryTabOverviewHeader(
          overviewTitle: 'Financial overview',
          overallLabel: 'Overall financial risk',
          overallScore: financialDetail.pointScore,
          slices: barSlices,
          scaleLabels: _scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kFinancialSubcategoryDefs.length; s++) {
      final def = kFinancialSubcategoryDefs[s];
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
          levels: financialLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              onFinancialFactorChanged(sectionBase + i, level),
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
  List<int> financialLevels,
  List<double> shares,
  List<double> subScores,
) {
  var offset = 0;
  final out = <CategoryOverviewBarSlice>[];
  for (var s = 0; s < kFinancialSubcategoryDefs.length; s++) {
    final def = kFinancialSubcategoryDefs[s];
    final n = def.factorLabels.length;
    final seg = financialLevels.sublist(offset, offset + n);
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
