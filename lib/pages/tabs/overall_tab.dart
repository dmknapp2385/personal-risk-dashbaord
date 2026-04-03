import 'package:flutter/material.dart';

import '../../models/driver_factor.dart';
import '../../models/home_category_score.dart';
import '../../models/risk_category.dart';
import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_score.dart';
import '../widgets/overall_score_category_bar.dart';
import '../widgets/top_drivers_next_steps_section.dart';

class OverallTab extends StatelessWidget {
  const OverallTab({
    super.key,
    required this.overallScore,
    required this.categoryScores,
    required this.topDrivers,
    required this.onOpenCategory,
  });

  final double overallScore;
  final List<HomeCategoryScore> categoryScores;
  final List<DriverFactor> topDrivers;
  final void Function(RiskCategory category) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        OverallRiskCard(
          score: overallScore,
          categoryScores: categoryScores,
          onOpenCategory: onOpenCategory,
        ),
        const SizedBox(height: 16),
        Text(
          'Quick category snapshot (tap to open)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            for (final c in categoryScores)
              CategoryMiniRiskBar(
                score: c,
                onOpenCategory: onOpenCategory,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Top drivers (mock)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final d in topDrivers)
              TopDriverChip(
                driver: d,
                onOpenCategory: onOpenCategory,
              ),
          ],
        ),
        const SizedBox(height: 20),
        TopDriversNextStepsSection(
          topDrivers: topDrivers,
          onOpenCategory: onOpenCategory,
        ),
      ],
    );
  }
}

class OverallRiskCard extends StatelessWidget {
  const OverallRiskCard({
    super.key,
    required this.score,
    required this.categoryScores,
    required this.onOpenCategory,
  });

  final double score;
  final List<HomeCategoryScore> categoryScores;
  final void Function(RiskCategory category) onOpenCategory;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => RiskScore.normalizedT(score);

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  String get _label {
    if (score <= 200) return 'Very Low';
    if (score <= 400) return 'Low';
    if (score <= 600) return 'Moderate';
    if (score <= 800) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final riskColor = _riskColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              riskColor.withOpacity(0.22),
              cs.surfaceContainerHighest,
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Risk Score',
                  style: theme.textTheme.titleLarge,
                ),
                Chip(
                  label: Text(_label),
                  backgroundColor: riskColor.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  RiskScore.format(score),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    ' / 1000',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OverallScoreCategoryBar(
                overallScore: score,
                categoryScores: categoryScores,
                onOpenCategory: onOpenCategory,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bar length is 0–1000; fill stops at your score. Colors split that fill by category share.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryMiniRiskBar extends StatelessWidget {
  const CategoryMiniRiskBar({
    super.key,
    required this.score,
    required this.onOpenCategory,
  });

  final HomeCategoryScore score;
  final void Function(RiskCategory category) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onOpenCategory(score.category),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    score.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '${RiskScore.format(score.score)}/1000',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CategoryRiskBarColors.fillForScore(score.score),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: CategoryRiskBarColors.borderForScore(score.score),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopDriverChip extends StatelessWidget {
  const TopDriverChip({
    super.key,
    required this.driver,
    required this.onOpenCategory,
  });

  final DriverFactor driver;
  final void Function(RiskCategory category) onOpenCategory;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => driver.level.clamp(0, 4) / 4.0;

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tabLabel = _scaleLabels[driver.level.clamp(0, 4)];

    return InkWell(
      onTap: () => onOpenCategory(driver.category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _riskColor.withOpacity(0.35)),
        ),
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driver.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _riskColor.withOpacity(0.18 + 0.65 * _t),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _riskColor.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impact: $tabLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
