import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.title,
    required this.icon,
    required this.factorLabels,
    required this.levels,
    required this.onLevelChanged,
    required this.scaleLabels,
  });

  final String title;
  final IconData icon;
  final List<String> factorLabels;
  final List<int> levels;
  final void Function(int index, int newLevel) onLevelChanged;
  final List<String> scaleLabels;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  double get _t => levels.isEmpty ? 0 : _avgLevel / 4.0;

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

  int get _riskScore => (1 + _t * (1000 - 1)).round().clamp(1, 1000);

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
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_riskScore / 1000',
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
            'Answer (mock)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < factorLabels.length; i++)
            _FactorSegmentedQuestion(
              question: factorLabels[i],
              level: levels[i],
              onLevelChanged: (newLevel) => onLevelChanged(i, newLevel),
              scaleLabels: scaleLabels,
            ),
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
  });

  final String question;
  final int level;
  final ValueChanged<int> onLevelChanged;
  final List<String> scaleLabels;

  static const Color _lowColor = Color(0xFF16A34A); // green
  static const Color _highColor = Color(0xFFDC2626); // red

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: List.generate(5, (i) {
              final t = i / 4.0;
              final chipColor = Color.lerp(_lowColor, _highColor, t)!;
              final selected = level == i;
              return OutlinedButton(
                onPressed: () => onLevelChanged(i),
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected ? chipColor.withOpacity(0.14) : null,
                  side: BorderSide(
                    color: chipColor.withOpacity(selected ? 1.0 : 0.55),
                    width: selected ? 1.6 : 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  scaleLabels[i],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected ? chipColor : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              );
            }),
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

    final t = level.clamp(0, 4) / 4.0;
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
            '${scaleLabels[level.clamp(0, 4)]} • ${contributionPct}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

