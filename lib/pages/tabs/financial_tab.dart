import 'package:flutter/material.dart';

import '../../data/financial_subcategories.dart';
import '../../engine/financial_risk_types.dart';
import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_score.dart';
import '../widgets/category_section.dart';
import '../widgets/financial_overview_score_bar.dart';

class FinancialTab extends StatelessWidget {
  const FinancialTab({
    super.key,
    required this.financialLevels,
    required this.onFinancialFactorChanged,
    required this.financialDetail,
  });

  /// Length must match [kFinancialFactorCount] (one level per sub-sub factor).
  final List<int> financialLevels;
  final void Function(int index, int level) onFinancialFactorChanged;

  /// Full [FinancialRiskResult] from the engine (Monte Carlo & regime tags are not shown in UI).
  final FinancialRiskResult financialDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.savings_outlined,
    Icons.receipt_long_outlined,
    Icons.stacked_line_chart_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.price_change_outlined,
  ];

  static const Color _lowColor = Color(0xFF16A34A);
  static const Color _highColor = Color(0xFFDC2626);

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
        child: _FinancialOverviewHeader(
          financialDetail: financialDetail,
          barSlices: barSlices,
          lowColor: _lowColor,
          highColor: _highColor,
          scaleLabels: _scaleLabels,
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
        ),
      );
      offset += n;
    }

    return ListView(children: children);
  }
}

List<FinancialOverviewBarSlice> _buildBarSlices(
  List<int> financialLevels,
  List<double> shares,
  List<double> subScores,
) {
  var offset = 0;
  final out = <FinancialOverviewBarSlice>[];
  for (var s = 0; s < kFinancialSubcategoryDefs.length; s++) {
    final def = kFinancialSubcategoryDefs[s];
    final n = def.factorLabels.length;
    final seg = financialLevels.sublist(offset, offset + n);
    offset += n;
    out.add(
      FinancialOverviewBarSlice(
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

class _FinancialOverviewHeader extends StatelessWidget {
  const _FinancialOverviewHeader({
    required this.financialDetail,
    required this.barSlices,
    required this.lowColor,
    required this.highColor,
    required this.scaleLabels,
  });

  final FinancialRiskResult financialDetail;
  final List<FinancialOverviewBarSlice> barSlices;
  final Color lowColor;
  final Color highColor;
  final List<String> scaleLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overallScore = financialDetail.pointScore;
    final t = RiskScore.normalizedT(overallScore);
    final riskColor = Color.lerp(lowColor, highColor, t)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Overall financial risk',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${RiskScore.format(overallScore)} / 1000',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: riskColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FinancialOverviewScoreBar(
          overallScore: overallScore,
          slices: barSlices,
          scaleLabels: scaleLabels,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            for (var i = 0; i < barSlices.length; i++)
              _LegendChip(
                color: CategoryRiskBarColors.fillForScore(barSlices[i].riskScore),
                title: barSlices[i].title,
                percentLabel: _formatPercent(barSlices[i].share),
              ),
          ],
        ),
      ],
    );
  }

  static String _formatPercent(double share) {
    final p = share * 100;
    if (p >= 9.95 || p == 0) {
      return '${p.round()}%';
    }
    if (p < 0.05 && p > 0) {
      return '<1%';
    }
    return '${p.toStringAsFixed(1)}%';
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.title,
    required this.percentLabel,
  });

  final Color color;
  final String title;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          percentLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
