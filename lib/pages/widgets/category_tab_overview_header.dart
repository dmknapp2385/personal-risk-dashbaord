import 'package:flutter/material.dart';

import '../../models/category_overview_slice.dart';
import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_level_scale.dart';
import '../../utils/risk_score.dart';
import 'category_overview_score_bar.dart';

/// Builds overview bar slices from flat factor levels and engine per-subcategory
/// [engineSubShares] / [subScores]. Subcategories where **every** factor is 0 are
/// omitted; remaining shares renormalize to 1.
List<CategoryOverviewBarSlice> engineBarSlicesOmittingAllZeroSubcategories({
  required List<double> factorLevelsFlat,
  required List<double> engineSubShares,
  required List<double> subScores,
  required List<String> sectionTitles,
  required List<List<String>> sectionFactorLabels,
}) {
  assert(sectionTitles.length == sectionFactorLabels.length);
  assert(engineSubShares.length == sectionTitles.length);
  assert(subScores.length == sectionTitles.length);

  var offset = 0;
  final active = <({int index, List<double> seg})>[];
  for (var s = 0; s < sectionTitles.length; s++) {
    final labels = sectionFactorLabels[s];
    final n = labels.length;
    final seg = factorLevelsFlat.sublist(offset, offset + n);
    offset += n;
    final contributes = seg.any((l) => RiskLevelScale.clamp(l) > 0);
    if (contributes) {
      active.add((index: s, seg: List<double>.from(seg)));
    }
  }
  assert(
    offset == factorLevelsFlat.length,
    'factorLevelsFlat length does not match section factor counts',
  );

  if (active.isEmpty) return [];

  var shareSum = 0.0;
  for (final a in active) {
    shareSum += engineSubShares[a.index];
  }

  final out = <CategoryOverviewBarSlice>[];
  if (shareSum <= 1e-12) {
    final eq = 1.0 / active.length;
    for (final a in active) {
      final s = a.index;
      out.add(
        CategoryOverviewBarSlice(
          title: sectionTitles[s],
          share: eq,
          riskScore: subScores[s],
          factorLabels: sectionFactorLabels[s],
          factorLevels: a.seg,
        ),
      );
    }
  } else {
    for (final a in active) {
      final s = a.index;
      out.add(
        CategoryOverviewBarSlice(
          title: sectionTitles[s],
          share: engineSubShares[s] / shareSum,
          riskScore: subScores[s],
          factorLabels: sectionFactorLabels[s],
          factorLevels: a.seg,
        ),
      );
    }
  }
  return out;
}

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