import 'package:flutter/material.dart';

/// Visually distinct "AI-generated rationale" affordance: a small sparkle icon
/// that shows the rationale in a tooltip on hover and a dialog on tap.
///
/// Pattern mirrors [ScoreInfoIcon] but uses a different icon/color so users
/// can tell at a glance which explanations are factual (the existing info
/// icon) and which are AI-generated guesses (this one).
class AiRationaleBadge extends StatelessWidget {
  const AiRationaleBadge({
    super.key,
    required this.rationale,
    this.dialogTitle = 'AI rationale',
  });

  final String rationale;
  final String dialogTitle;

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 18,
              color: Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(dialogTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rationale,
                style: Theme.of(ctx)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                'AI-generated explanation. The value may not match the data perfectly — adjust the slider manually if you disagree.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: rationale,
      waitDuration: const Duration(milliseconds: 350),
      preferBelow: false,
      triggerMode: TooltipTriggerMode.longPress,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: cs.primary,
            ),
          ),
        ),
      ),
    );
  }
}
