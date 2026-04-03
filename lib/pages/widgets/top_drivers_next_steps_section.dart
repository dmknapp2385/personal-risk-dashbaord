import 'package:flutter/material.dart';

import '../../data/driver_mitigation_steps.dart';
import '../../models/driver_factor.dart';
import '../../models/risk_category.dart';

/// Home-page guidance tied to [topDrivers]: full playbooks for Financial and
/// Digital / Privacy; short placeholder for other categories until modeled.
class TopDriversNextStepsSection extends StatefulWidget {
  const TopDriversNextStepsSection({
    super.key,
    required this.topDrivers,
    required this.onOpenCategory,
  });

  final List<DriverFactor> topDrivers;
  final void Function(RiskCategory category) onOpenCategory;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  State<TopDriversNextStepsSection> createState() =>
      _TopDriversNextStepsSectionState();
}

class _TopDriversNextStepsSectionState extends State<TopDriversNextStepsSection> {
  /// Remaining drivers in the guided queue (mutates on dismiss).
  late List<DriverFactor> _queue;

  List<ExpansionTileController> _controllers = [];

  static const Color _impactLow = Color(0xFF16A34A);
  static const Color _impactHigh = Color(0xFFDC2626);

  static Color impactColorForLevel(int level) {
    final t = level.clamp(0, 4) / 4.0;
    return Color.lerp(_impactLow, _impactHigh, t)!;
  }

  @override
  void initState() {
    super.initState();
    _queue = List<DriverFactor>.from(widget.topDrivers);
    _rebuildControllers();
    _scheduleExpandFirst();
  }

  @override
  void didUpdateWidget(TopDriversNextStepsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameTopDrivers(oldWidget.topDrivers, widget.topDrivers)) {
      _queue = List<DriverFactor>.from(widget.topDrivers);
      _rebuildControllers();
      _scheduleExpandFirst();
    }
  }

  static bool _sameTopDrivers(List<DriverFactor> a, List<DriverFactor> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label ||
          a[i].level != b[i].level ||
          a[i].category != b[i].category) {
        return false;
      }
    }
    return true;
  }

  void _rebuildControllers() {
    _controllers = List<ExpansionTileController>.generate(
      _queue.length,
      (_) => ExpansionTileController(),
    );
  }

  void _scheduleExpandFirst() {
    if (_queue.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controllers.isEmpty) return;
      _controllers.first.expand();
    });
  }

  void _scheduleExpandIndex(int index) {
    if (index < 0 || index >= _controllers.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index >= _controllers.length) return;
      _controllers[index].expand();
    });
  }

  void _onExpansionChanged(int index, bool expanded) {
    if (!expanded) return;
    for (var j = 0; j < _controllers.length; j++) {
      if (j != index && _controllers[j].isExpanded) {
        _controllers[j].collapse();
      }
    }
  }

  /// Removes this row from the queue and focuses the next remaining driver.
  void _dismissAt(int index) {
    if (index < 0 || index >= _queue.length) return;
    setState(() {
      _queue.removeAt(index);
      _rebuildControllers();
    });
    if (_queue.isEmpty) return;
    final expandAt = index < _queue.length ? index : _queue.length - 1;
    _scheduleExpandIndex(expandAt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (widget.topDrivers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next steps',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _queue.isEmpty
                  ? 'Every driver was dismissed from this queue. It will repopulate when your top drivers above change.'
                  : 'Dismiss removes a driver from this queue and opens the next. '
                      'Impact colors match severity (green → red).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            if (_queue.isEmpty)
              _AllClearedCallout(theme: theme, cs: cs)
            else
              for (var i = 0; i < _queue.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _DriverMitigationBlock(
                  key: ValueKey(
                    '${_queue[i].label}|${_queue[i].category.name}|${_queue[i].level}|$i',
                  ),
                  driver: _queue[i],
                  scaleLabels: TopDriversNextStepsSection._scaleLabels,
                  controller: _controllers[i],
                  impactColor: impactColorForLevel(_queue[i].level),
                  onOpenCategory: widget.onOpenCategory,
                  onExpansionChanged: (expanded) =>
                      _onExpansionChanged(i, expanded),
                  onDismissFromQueue: () => _dismissAt(i),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _AllClearedCallout extends StatelessWidget {
  const _AllClearedCallout({
    required this.theme,
    required this.cs,
  });

  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.task_alt_rounded,
              color: cs.primary,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All next steps were cleared',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have cleared every driver from this queue. Update your inputs '
                    'so the top drivers above change, and this list will show again.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverMitigationBlock extends StatelessWidget {
  const _DriverMitigationBlock({
    super.key,
    required this.driver,
    required this.scaleLabels,
    required this.controller,
    required this.impactColor,
    required this.onOpenCategory,
    required this.onExpansionChanged,
    required this.onDismissFromQueue,
  });

  final DriverFactor driver;
  final List<String> scaleLabels;
  final ExpansionTileController controller;
  final Color impactColor;
  final void Function(RiskCategory category) onOpenCategory;
  final void Function(bool expanded) onExpansionChanged;
  final VoidCallback onDismissFromQueue;

  static const _tileRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final level = driver.level.clamp(0, 4);
    final impact = scaleLabels[level];
    final steps = DriverMitigationSteps.stepsFor(driver);
    final full = DriverMitigationSteps.hasFullPlaybook(driver.category);

    final borderSide =
        BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45));
    final tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_tileRadius),
      side: borderSide,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_tileRadius),
      child: Material(
        color: cs.surface,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            controller: controller,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            maintainState: true,
            shape: tileShape,
            collapsedShape: tileShape,
            onExpansionChanged: onExpansionChanged,
            title: Text(
              driver.label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    driver.category.shortLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _ImpactChip(
                    impact: impact,
                    color: impactColor,
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      runSpacing: 0,
                      children: [
                        TextButton(
                          onPressed: onDismissFromQueue,
                          child: const Text('Dismiss'),
                        ),
                        TextButton(
                          onPressed: () => onOpenCategory(driver.category),
                          child: const Text('Open tab'),
                        ),
                      ],
                    ),
                    if (full)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Start here:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    for (final step in steps)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 8),
                              child: Text(
                                '•',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.38,
                                  fontStyle: full
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactChip extends StatelessWidget {
  const _ImpactChip({
    required this.impact,
    required this.color,
  });

  final String impact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      backgroundColor: color.withValues(alpha: 0.18),
      side: BorderSide(color: color.withValues(alpha: 0.62)),
      label: Text(
        'Impact: $impact',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
