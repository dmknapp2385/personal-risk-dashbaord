import 'package:flutter/material.dart';

import '../../utils/risk_level_scale.dart';
import '../../utils/risk_score.dart';
import 'risk_level_slider_field.dart';
import 'score_info_icon.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.title,
    required this.icon,
    required this.factorLabels,
    required this.levels,
    required this.onLevelChanged,
    required this.scaleLabels,
    this.showFactorImpactSection = true,
    this.titleHelp,
    this.factorHelps,
  });

  final String title;
  final IconData icon;
  final List<String> factorLabels;
  final List<int> levels;
  final void Function(int index, int newLevel) onLevelChanged;
  final List<String> scaleLabels;

  /// When false, hides “Impact by sub-category”, mini bars, and summary line.
  final bool showFactorImpactSection;

  /// Tooltip/dialog copy for what this subcategory (section) measures.
  final String? titleHelp;

  /// One entry per factor; use null where no info icon is needed.
  final List<String?>? factorHelps;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t =>
      levels.isEmpty ? 0 : _avgLevel / RiskLevelScale.max;

  double get _avgLevel {
    final sum = levels.isEmpty ? 0 : levels.reduce((a, b) => a + b);
    return sum.toDouble() / (levels.isEmpty ? 1 : levels.length);
  }

  Color get _riskColor => Color.lerp(_lowColor, _highColor, _t)!;

  int get _pct => (_t * 100).round().clamp(0, 100);

  String get _impactLabel {
    if (_pct <= 19) return 'Very Low';
    if (_pct <= 39) return 'Low';
    if (_pct <= 59) return 'Moderate';
    if (_pct <= 79) return 'High';
    return 'Very High';
  }

  double get _riskScore => RiskScore.fromNorm(_t);

  String get _riskLabel {
    final score = _riskScore;
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

    final barColor = _riskColor.withOpacity(0.28);
    final outlineColor = _riskColor.withOpacity(0.55);
    final levelsSum = levels.isEmpty ? 0 : levels.reduce((a, b) => a + b);
    assert(
      factorHelps == null || factorHelps!.length == factorLabels.length,
      'factorHelps length must match factorLabels',
    );

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (titleHelp != null)
                          ScoreInfoIcon(
                            message: titleHelp!,
                            dialogTitle: title,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${RiskScore.format(_riskScore)} / 1000',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _riskColor,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(_riskLabel),
                backgroundColor: barColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your estimate (0–100%)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(factorLabels.length, (i) {
            final factorIndex = i;
            return _FactorSegmentedQuestion(
              question: factorLabels[i],
              level: levels[i],
              onLevelChanged: (newLevel) =>
                  onLevelChanged(factorIndex, newLevel),
              scaleLabels: scaleLabels,
              questionHelp: factorHelps?[i],
            );
          }),
          if (showFactorImpactSection) ...[
            const SizedBox(height: 12),
            Text(
              'Impact by sub-category',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                for (int i = 0; i < factorLabels.length; i++)
                  _MiniImpactBar(
                    label: factorLabels[i],
                    level: levels[i],
                    scaleLabels: scaleLabels,
                    contributionPct: levelsSum == 0
                        ? 0
                        : (levels[i] / levelsSum * 100).round(),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Overall category impact: $_impactLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FactorSegmentedQuestion extends StatelessWidget {
  const _FactorSegmentedQuestion({
    required this.question,
    required this.level,
    required this.onLevelChanged,
    required this.scaleLabels,
    this.questionHelp,
  });

  final String question;
  final int level;
  final ValueChanged<int> onLevelChanged;
  final List<String> scaleLabels;
  final String? questionHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                question,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (questionHelp != null)
                ScoreInfoIcon(
                  message: questionHelp!,
                  dialogTitle: question,
                ),
            ],
          ),
          const SizedBox(height: 8),
          RiskLevelSliderField(
            value: RiskLevelScale.clamp(level),
            anchorLabels: scaleLabels,
            onChanged: onLevelChanged,
          ),
        ],
      ),
    );
  }
}

class _MiniImpactBar extends StatelessWidget {
  const _MiniImpactBar({
    required this.label,
    required this.level,
    required this.scaleLabels,
    required this.contributionPct,
  });

  final String label;
  final int level;
  final List<String> scaleLabels;
  final int contributionPct;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final t = RiskLevelScale.toNorm(level);
    final riskColor = Color.lerp(_lowColor, _highColor, t)!;

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.18 + 0.65 * t),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: riskColor.withOpacity(0.65),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${RiskLevelScale.clamp(level)}% · '
            '${scaleLabels[RiskLevelScale.bandIndex(level)]} · '
            '$contributionPct%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

