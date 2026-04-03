import 'package:flutter/material.dart';

import '../../models/category_overview_slice.dart';
import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_score.dart';
import 'category_overview_score_bar.dart';

/// Shared header layout for category detail pages (matches financial overview pattern).
class CategoryTabOverviewHeader extends StatelessWidget {
  const CategoryTabOverviewHeader({
    super.key,
    required this.overviewTitle,
    required this.overallLabel,
    required this.overallScore,
    required this.slices,
    required this.scaleLabels,
    required this.barCaption,
    this.lowColor = const Color(0xFF16A34A),
    this.highColor = const Color(0xFFDC2626),
  });

  final String overviewTitle;
  final String overallLabel;
  final double overallScore;
  final List<CategoryOverviewBarSlice> slices;
  final List<String> scaleLabels;
  final String barCaption;
  final Color lowColor;
  final Color highColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = RiskScore.normalizedT(overallScore);
    final riskColor = Color.lerp(lowColor, highColor, t)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overviewTitle,
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
                overallLabel,
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
        CategoryOverviewScoreBar(
          overallScore: overallScore,
          slices: slices,
          scaleLabels: scaleLabels,
          caption: barCaption,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            for (var i = 0; i < slices.length; i++)
              CategoryOverviewLegendChip(
                color: CategoryRiskBarColors.fillForScore(slices[i].riskScore),
                title: slices[i].title,
                percentLabel: _formatPercent(slices[i].share),
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

class CategoryOverviewLegendChip extends StatelessWidget {
  const CategoryOverviewLegendChip({
    super.key,
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

/// Equal-width segments from flat factor lists (non-financial categories).
List<CategoryOverviewBarSlice> categorySlicesFromFactors(
  List<String> labels,
  List<int> levels,
) {
  final n = labels.length;
  if (n == 0) return [];
  return List.generate(n, (i) {
    final lv = levels[i].clamp(0, 4);
    return CategoryOverviewBarSlice(
      title: labels[i],
      share: 1.0 / n,
      riskScore: RiskScore.fromNorm(lv / 4.0),
      factorLabels: [labels[i]],
      factorLevels: [lv],
    );
  });
}
