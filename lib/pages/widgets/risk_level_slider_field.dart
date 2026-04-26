import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/risk_level_scale.dart';

/// Slider + percentage field + optional anchor presets (VL … VH).
class RiskLevelSliderField extends StatefulWidget {
  const RiskLevelSliderField({
    super.key,
    required this.value,
    required this.onChanged,
    this.anchorLabels = RiskLevelScale.anchorLabels,
  });

  final int value;
  final ValueChanged<int> onChanged;

  /// Labels for the five preset chips (default VL…VH).
  final List<String> anchorLabels;

  @override
  State<RiskLevelSliderField> createState() => _RiskLevelSliderFieldState();
}

class _RiskLevelSliderFieldState extends State<RiskLevelSliderField> {
  late TextEditingController _text;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: '${widget.value}');
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _commitText();
    }
  }

  @override
  void didUpdateWidget(RiskLevelSliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focus.hasFocus) {
      _text.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  void _commitText() {
    final parsed = int.tryParse(_text.text.trim());
    if (parsed == null) {
      _text.text = '${widget.value}';
      return;
    }
    final v = RiskLevelScale.clamp(parsed);
    _text.text = '$v';
    if (v != widget.value) {
      widget.onChanged(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final v = RiskLevelScale.clamp(widget.value);
    final t = RiskLevelScale.toNorm(v);
    const low = Color(0xFF16A34A);
    const high = Color(0xFFDC2626);
    final accent = Color.lerp(low, high, t)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: accent.withValues(alpha: 0.22),
                  thumbColor: accent,
                  overlayColor: accent.withValues(alpha: 0.18),
                  trackHeight: 4,
                ),
                child: Slider(
                  min: 0,
                  max: RiskLevelScale.max.toDouble(),
                  divisions: RiskLevelScale.max,
                  value: v.toDouble(),
                  label: '$v%',
                  onChanged: (x) {
                    final n = x.round();
                    _text.text = '$n';
                    widget.onChanged(n);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: TextField(
                controller: _text,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  suffixText: '%',
                  suffixStyle: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                onSubmitted: (_) => _commitText(),
                onEditingComplete: _commitText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(5, (i) {
            final anchor = RiskLevelScale.anchorValue(i);
            final selected = v == anchor;
            final chipColor = Color.lerp(low, high, i / 4.0)!;
            return ActionChip(
              label: Text(widget.anchorLabels[i]),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                _text.text = '$anchor';
                widget.onChanged(anchor);
              },
              backgroundColor: selected
                  ? chipColor.withValues(alpha: 0.2)
                  : cs.surfaceContainerHighest,
              side: BorderSide(
                color: selected
                    ? chipColor
                    : cs.outlineVariant.withValues(alpha: 0.6),
                width: selected ? 1.4 : 1,
              ),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: selected ? chipColor : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            );
          }),
        ),
      ],
    );
  }
}
