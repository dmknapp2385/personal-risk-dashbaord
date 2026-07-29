import 'package:flutter/material.dart';

import '../../services/dashboard_insight_service.dart';

/// Renders a [DashboardInsight] in a focused dialog: short summary,
/// the single biggest concern, and a list of thought-out actions.
class AiInsightDialog extends StatelessWidget {
  const AiInsightDialog({
    super.key,
    required this.insight,
  });

  final DashboardInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          const Text('AI Insight'),
        ],
      ),
      content: SelectionArea(
        child: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (insight.summary.isNotEmpty) ...[
                Text(
                  insight.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
              ],
              if (insight.topConcern != null) ...[
                _TopConcernCard(concern: insight.topConcern!),
                const SizedBox(height: 16),
              ],
              if (insight.recommendedActions.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.checklist_rounded,
                        size: 18, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Recommended actions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < insight.recommendedActions.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          i == insight.recommendedActions.length - 1 ? 4 : 10,
                    ),
                    child: _RecommendedActionCard(
                      index: i + 1,
                      action: insight.recommendedActions[i],
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Plain error dialog for when the model call or parsing fails.
class AiInsightErrorDialog extends StatelessWidget {
  const AiInsightErrorDialog({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 8),
          const Text('AI Insight unavailable'),
        ],
      ),
      content: SelectionArea(
        child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              error,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 10),
            Text(
              'Chrome / web checklist:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '• Quit Ollama, set user env var OLLAMA_ORIGINS=*, restart Ollama.\n'
              '• Model must be pulled: ollama pull qwen2.5:3b\n'
              '• Test in Chrome: open http://localhost:11434\n'
              '• DevTools → Network → /api/generate (CORS shows as failed fetch)\n'
              '• Desktop workaround: flutter run -d windows (no CORS)',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _TopConcernCard extends StatelessWidget {
  const _TopConcernCard({required this.concern});

  final TopConcern concern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.error.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high_rounded, color: cs.error, size: 18),
              const SizedBox(width: 6),
              Text(
                'Top concern',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (concern.label.isNotEmpty)
            Text(
              concern.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          if (concern.category.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                concern.category,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          if (concern.why.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              concern.why,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendedActionCard extends StatelessWidget {
  const _RecommendedActionCard({
    required this.index,
    required this.action,
  });

  final int index;
  final RecommendedAction action;

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Health':
        return const Color(0xFF16A34A);
      case 'Career':
        return const Color(0xFF7C3AED);
      case 'Financial':
        return const Color(0xFF2563EB);
      case 'Personal Safety':
        return const Color(0xFFDC2626);
      case 'Digital / Privacy':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _categoryColor(action.category);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.55),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  action.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (action.why.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                action.why,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (action.category.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  action.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
