import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../utils/category_risk_bar_colors.dart';
import '../../utils/risk_score.dart';

/// One row in the financial overview bar + hover card.
class FinancialOverviewBarSlice {
  const FinancialOverviewBarSlice({
    required this.title,
    required this.share,
    required this.riskScore,
    required this.factorLabels,
    required this.factorLevels,
  });

  final String title;
  final double share;
  /// 0–1000, from average factor levels in this subcategory (same norm as category score).
  final double riskScore;
  final List<String> factorLabels;
  final List<int> factorLevels;
}

/// 0–1000 track; fill = [overallScore]. Segments use [CategoryRiskBarColors] from each
/// subcategory’s local risk (matches home “mini bar” logic). Hover shows factors + levels.
class FinancialOverviewScoreBar extends StatefulWidget {
  const FinancialOverviewScoreBar({
    super.key,
    required this.overallScore,
    required this.slices,
    this.scaleLabels = const ['VL', 'L', 'M', 'H', 'VH'],
  });

  final double overallScore;
  final List<FinancialOverviewBarSlice> slices;
  final List<String> scaleLabels;

  @override
  State<FinancialOverviewScoreBar> createState() =>
      _FinancialOverviewScoreBarState();
}

class _FinancialOverviewScoreBarState extends State<FinancialOverviewScoreBar>
    with SingleTickerProviderStateMixin {
  static const _barHeight = 26.0;
  static const _cardWidth = 300.0;
  static const _estCardH = 300.0;

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
    _removeHoverOverlay();
    _followTicker.dispose();
    super.dispose();
  }

  void _removeHoverOverlay() {
    _followTicker.stop();
    _hoverOverlayEntry?.remove();
    _hoverOverlayEntry = null;
  }

  static double _segmentCenterX(
    double fillWidth,
    List<double> shares,
    int n,
    int index,
  ) {
    var used = 0.0;
    for (var i = 0; i < n; i++) {
      final isLast = i == n - 1;
      final share = shares[i].clamp(0.0, 1.0);
      final segW = isLast
          ? (fillWidth - used).clamp(0.0, fillWidth)
          : (fillWidth * share).clamp(0.0, fillWidth);
      if (i == index) {
        return used + segW / 2;
      }
      if (!isLast) {
        used += segW;
      }
    }
    return fillWidth / 2;
  }

  List<double> _shares() {
    final raw = widget.slices.map((e) => e.share.clamp(0.0, 1.0)).toList();
    final sum = raw.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) {
      final n = widget.slices.length;
      return List<double>.filled(n, 1.0 / n);
    }
    return raw.map((s) => s / sum).toList();
  }

  Widget _overlayBuilder(BuildContext overlayContext) {
    final barBox = _barKey.currentContext?.findRenderObject() as RenderBox?;
    final i = _hoverIndex;
    if (barBox == null || !barBox.hasSize || !barBox.attached || i == null) {
      return const SizedBox.shrink();
    }

    final slices = widget.slices;
    if (i < 0 || i >= slices.length || _fillW <= 0) {
      return const SizedBox.shrink();
    }

    final origin = barBox.localToGlobal(Offset.zero);
    final sh = _shares();
    final cx = origin.dx + _segmentCenterX(_fillW, sh, slices.length, i);
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
            child: _SliceHoverPreview(
              slice: slices[i],
              shareLabel: _formatPercent(slices[i].share),
              scaleLabels: widget.scaleLabels,
            ),
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final slices = widget.slices;
    final shares = _shares();
    final t = RiskScore.normalizedT(widget.overallScore);

    return LayoutBuilder(
      builder: (context, constraints) {
        var w = constraints.maxWidth;
        if (!w.isFinite || w <= 0) {
          w = (MediaQuery.sizeOf(context).width - 48).clamp(280.0, 1100.0);
        }
        final fillW = (w * t).clamp(0.0, w);
        _fillW = fillW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Weighted share inside your score (hover for factors · same colors as risk level below)',
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
                      child: fillW <= 0 || slices.isEmpty
                          ? const SizedBox.shrink()
                          : _FilledFinancialSegmentRow(
                              fillWidth: fillW,
                              height: _barHeight,
                              slices: slices,
                              shares: shares,
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

class _FilledFinancialSegmentRow extends StatelessWidget {
  const _FilledFinancialSegmentRow({
    required this.fillWidth,
    required this.height,
    required this.slices,
    required this.shares,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  final double fillWidth;
  final double height;
  final List<FinancialOverviewBarSlice> slices;
  final List<double> shares;
  final void Function(int index) onHoverEnter;
  final VoidCallback onHoverExit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (fillWidth <= 0 || slices.isEmpty) {
      return const SizedBox.shrink();
    }

    final divider = BorderSide(
      color: cs.outline.withValues(alpha: 0.42),
      width: 0.5,
    );

    final children = <Widget>[];
    var used = 0.0;

    for (var i = 0; i < slices.length; i++) {
      final isLast = i == slices.length - 1;
      final share = shares[i].clamp(0.0, 1.0);
      final segW = isLast
          ? (fillWidth - used).clamp(0.0, fillWidth)
          : (fillWidth * share).clamp(0.0, fillWidth);
      if (segW <= 0) continue;

      children.add(
        SizedBox(
          width: segW,
          height: height,
          child: MouseRegion(
            onEnter: (_) => onHoverEnter(i),
            onExit: (_) => onHoverExit(),
            cursor: SystemMouseCursors.basic,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CategoryRiskBarColors.fillForScore(slices[i].riskScore),
                border: Border(
                  left: i > 0 ? divider : BorderSide.none,
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      if (!isLast) {
        used += segW;
      }
    }

    if (children.isEmpty) {
      return ColoredBox(
        color: CategoryRiskBarColors.fillForScore(slices[0].riskScore),
        child: SizedBox(width: fillWidth, height: height),
      );
    }

    return Row(children: children);
  }
}

class _SliceHoverPreview extends StatelessWidget {
  const _SliceHoverPreview({
    required this.slice,
    required this.shareLabel,
    required this.scaleLabels,
  });

  final FinancialOverviewBarSlice slice;
  final String shareLabel;
  final List<String> scaleLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const maxFactors = 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slice.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${RiskScore.format(slice.riskScore)} / 1000 · $shareLabel of filled bar',
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Factors',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...List.generate(
          slice.factorLabels.length.clamp(0, maxFactors),
          (j) {
            final label = slice.factorLabels[j];
            final lvl = slice.factorLevels[j].clamp(0, 4);
            final tab = scaleLabels[lvl.clamp(0, scaleLabels.length - 1)];
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Text(
                    tab,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (slice.factorLabels.length > maxFactors)
          Text(
            '…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
