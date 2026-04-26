import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../data/category_overview_preview.dart';
import '../../models/home_category_score.dart';
import '../../models/risk_category.dart';
import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_score.dart';

/// 0–1000 track; filled portion = [overallScore]. Inside the fill, segments show
/// each category’s share (by score). Segment fill matches [CategoryMiniRiskBar].
class OverallScoreCategoryBar extends StatefulWidget {
  const OverallScoreCategoryBar({
    super.key,
    required this.overallScore,
    required this.categoryScores,
    required this.onOpenCategory,
  });

  final double overallScore;
  final List<HomeCategoryScore> categoryScores;
  final void Function(RiskCategory category) onOpenCategory;

  @override
  State<OverallScoreCategoryBar> createState() =>
      _OverallScoreCategoryBarState();
}

class _OverallScoreCategoryBarState extends State<OverallScoreCategoryBar>
    with SingleTickerProviderStateMixin {
  static const _barHeight = 26.0;
  static const _cardWidth = 280.0;
  static const _estCardH = 272.0;

  final GlobalKey _barKey = GlobalKey();
  OverlayEntry? _hoverOverlayEntry;
  late final Ticker _followTicker;

  int? _hoverIndex;
  Timer? _hideTimer;

  double _fillW = 0;

  @override
  void initState() {
    super.initState();
    _followTicker = createTicker((_) {
      if (_hoverIndex != null &&
          _hoverOverlayEntry != null &&
          mounted &&
          _barKey.currentContext != null) {
        _hoverOverlayEntry!.markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _followTicker.dispose();
    _removeHoverOverlay();
    super.dispose();
  }

  void _removeHoverOverlay() {
    _followTicker.stop();
    _hoverOverlayEntry?.remove();
    _hoverOverlayEntry = null;
  }

  /// Width of each segment; remainder goes to the last segment with share &gt; 0 only.
  static List<double> _segmentWidths(
    double fillWidth,
    List<double> shares,
    int n,
  ) {
    if (fillWidth <= 0 || n == 0) {
      return List<double>.filled(n, 0.0);
    }
    var lastPositive = -1;
    for (var i = n - 1; i >= 0; i--) {
      if (shares[i] > 1e-12) {
        lastPositive = i;
        break;
      }
    }
    if (lastPositive < 0) {
      return List<double>.filled(n, 0.0);
    }
    final widths = List<double>.filled(n, 0.0);
    var used = 0.0;
    for (var i = 0; i < n; i++) {
      final share = shares[i].clamp(0.0, 1.0);
      if (share <= 1e-12) continue;
      if (i == lastPositive) {
        widths[i] = (fillWidth - used).clamp(0.0, fillWidth);
      } else {
        final w = (fillWidth * share).clamp(0.0, fillWidth);
        widths[i] = w;
        used += w;
      }
    }
    return widths;
  }

  /// Center X of segment [index] from track left (matches [_segmentWidths]).
  static double _segmentCenterX(
    double fillWidth,
    List<double> shares,
    int n,
    int index,
  ) {
    final widths = _segmentWidths(fillWidth, shares, n);
    if (index < 0 || index >= n) return fillWidth / 2;
    var x = 0.0;
    for (var i = 0; i < n; i++) {
      final w = widths[i];
      if (i == index) {
        return x + w / 2;
      }
      x += w;
    }
    return fillWidth / 2;
  }

  Widget _overlayBuilder(BuildContext overlayContext) {
    final barBox = _barKey.currentContext?.findRenderObject() as RenderBox?;
    final i = _hoverIndex;
    if (barBox == null || !barBox.hasSize || !barBox.attached || i == null) {
      return const SizedBox.shrink();
    }

    final origin = barBox.localToGlobal(Offset.zero);
    final sh = _shares(widget.categoryScores);
    final n = widget.categoryScores.length;
    if (i < 0 || i >= n || _fillW <= 0) {
      return const SizedBox.shrink();
    }

    final cx = origin.dx + _segmentCenterX(_fillW, sh, n, i);
    final media = MediaQuery.of(overlayContext);
    final screen = media.size;
    final pad = media.padding;
    const cardW = _cardWidth;

    var left = cx - cardW / 2;
    left = left.clamp(8.0, screen.width - cardW - 8.0);

    var top = origin.dy - _estCardH - 12;
    final minTop = pad.top + 8.0;
    if (top < minTop) {
      top = origin.dy + _barHeight + 10;
    }
    final maxTop = screen.height - _estCardH - pad.bottom - 8;
    if (top > maxTop) {
      top = maxTop.clamp(minTop, maxTop);
    }

    final cs = Theme.of(overlayContext).colorScheme;

    return Positioned(
      left: left,
      top: top,
      width: cardW,
      child: MouseRegion(
        onEnter: (_) => _cancelHide(),
        onExit: (_) => _scheduleHide(),
        child: Material(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
          color: cs.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _CategoryHoverPreview(score: widget.categoryScores[i]),
          ),
        ),
      ),
    );
  }

  void _ensureHoverOverlay() {
    if (_hoverIndex == null || !mounted) return;
    if (_hoverOverlayEntry == null) {
      _hoverOverlayEntry = OverlayEntry(builder: _overlayBuilder);
      Overlay.of(context, rootOverlay: true).insert(_hoverOverlayEntry!);
    } else {
      _hoverOverlayEntry!.markNeedsBuild();
    }
    if (!_followTicker.isActive) {
      _followTicker.start();
    }
  }

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() => _hoverIndex = null);
      _removeHoverOverlay();
    });
  }

  static List<double> _shares(List<HomeCategoryScore> scores) {
    final raw = scores.map((e) => e.score.clamp(0.0, 1000.0)).toList();
    final sum = raw.fold<double>(0, (a, b) => a + b);
    // When every category is at 0, do not split the bar equally (that implied each
    // still "owned" part of the mix). Zero share → no colored slice.
    if (sum <= 1e-9) {
      return List<double>.filled(scores.length, 0.0);
    }
    return raw.map((s) => s / sum).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scores = widget.categoryScores;
    final shares = _shares(scores);
    final t = RiskScore.normalizedT(widget.overallScore);

    return LayoutBuilder(
      builder: (context, constraints) {
        var w = constraints.maxWidth;
        if (!w.isFinite || w <= 0) {
          w = (MediaQuery.sizeOf(context).width - 80).clamp(200.0, 1100.0);
        }
        final fillW = (w * t).clamp(0.0, w);
        _fillW = fillW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Category mix inside your score (hover · tap segment to open)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              key: _barKey,
              width: w,
              height: _barHeight,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(_barHeight / 2),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.65),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: cs.surfaceContainerHighest),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: fillW,
                      height: _barHeight,
                      child: fillW <= 0
                          ? const SizedBox.shrink()
                          : _FilledCategorySegmentRow(
                              fillWidth: fillW,
                              height: _barHeight,
                              colorScheme: cs,
                              scores: scores,
                              shares: shares,
                              segmentFill: (i) => CategoryRiskBarColors.fillForScore(
                                    scores[i].score,
                                  ),
                              onHoverEnter: (i) {
                                _cancelHide();
                                setState(() => _hoverIndex = i);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted || _hoverIndex == null) return;
                                  _ensureHoverOverlay();
                                });
                              },
                              onHoverExit: _scheduleHide,
                              onTap: (cat) => widget.onOpenCategory(cat),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '1000',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilledCategorySegmentRow extends StatelessWidget {
  const _FilledCategorySegmentRow({
    required this.fillWidth,
    required this.height,
    required this.colorScheme,
    required this.scores,
    required this.shares,
    required this.segmentFill,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onTap,
  });

  final double fillWidth;
  final double height;
  final ColorScheme colorScheme;
  final List<HomeCategoryScore> scores;
  final List<double> shares;
  final Color Function(int index) segmentFill;
  final void Function(int index) onHoverEnter;
  final VoidCallback onHoverExit;
  final void Function(RiskCategory category) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    if (fillWidth <= 0 || scores.isEmpty) {
      return const SizedBox.shrink();
    }

    final widths = _OverallScoreCategoryBarState._segmentWidths(
      fillWidth,
      shares,
      scores.length,
    );

    final divider = BorderSide(
      color: cs.outline.withValues(alpha: 0.42),
      width: 0.5,
    );

    final children = <Widget>[];
    var firstPainted = false;

    for (var i = 0; i < scores.length; i++) {
      final segW = widths[i];
      if (segW <= 0) continue;

      children.add(
        SizedBox(
          width: segW,
          height: height,
          child: MouseRegion(
            onEnter: (_) => onHoverEnter(i),
            onExit: (_) => onHoverExit(),
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(scores[i].category),
                splashColor: cs.primary.withValues(alpha: 0.15),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: segmentFill(i),
                    border: Border(
                      left: firstPainted ? divider : BorderSide.none,
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      );
      firstPainted = true;
    }

    if (children.isEmpty) {
      // All categories at 0 (or fill is tiny): neutral slab, not first category color.
      return ColoredBox(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.85),
        child: SizedBox(width: fillWidth, height: height),
      );
    }

    return Row(children: children);
  }
}

class _CategoryHoverPreview extends StatelessWidget {
  const _CategoryHoverPreview({required this.score});

  final HomeCategoryScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lines = categorySubPreviewLines(score.category);
    const maxLines = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          score.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${RiskScore.format(score.score)} / 1000',
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sub-factors',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...lines.take(maxLines).map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '· ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        if (lines.length > maxLines)
          Text(
            '…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Tap segment to open',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
